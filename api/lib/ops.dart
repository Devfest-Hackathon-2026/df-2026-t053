import 'dart:convert';
import 'dart:io';

import 'package:sqlite3/sqlite3.dart';

import 'src/domain/ports/persistence_gate.dart';
import 'src/infrastructure/config/replication_settings.dart';
import 'src/infrastructure/database/replication/gcs_object_client.dart';
import 'src/infrastructure/database/replication/litestream_confirmer.dart';
import 'src/infrastructure/database/replication/writer_ownership.dart';
import 'src/infrastructure/database/schema/schema_manifest.dart';
import 'src/infrastructure/google/access_token_provider.dart';

/// 運用用 CLI の本体。
///
/// ```
/// ops owner acquire --out FILE     writer 所有権を取得し、generation を FILE に書く
/// ops owner release --file FILE    FILE の generation を指定して所有権を解放する
/// ops owner show                   現在の所有権オブジェクトを表示する
/// ops owner clear --generation N   残留した所有権を、generation を指定して手動で解除する
/// ops verify-db --db PATH --migrations DIR
/// ops sync --socket PATH --db PATH  Litestream に POST /sync し、GCS 複製まで確認する
/// ```
///
/// 終了コード:
/// - 0: 成功
/// - 1: 使い方・DB 破損などの失敗
/// - 20: 所有権を取得できない（別の writer が持つ、または GCS の失敗）
/// - 21: 所有権を解放できない
/// - 10: DB に未適用の migration がある（`MAINTENANCE`）
/// - 11: DB が image より新しい（`SCHEMA_TOO_NEW`）
Future<int> runOps(List<String> args, Map<String, String> env) async {
  if (args.isEmpty) return _usage();
  switch (args.first) {
    case 'owner':
      if (args.length < 2) return _usage();
      return _owner(args[1], _options(args.skip(2)), env);
    case 'verify-db':
      return _verifyDb(_options(args.skip(1)));
    case 'sync':
      return _sync(_options(args.skip(1)));
    default:
      return _usage();
  }
}

int _usage() {
  stderr.writeln(
    'usage: ops owner acquire --out FILE | owner release --file FILE | '
    'owner show | owner clear --generation N | '
    'verify-db --db PATH --migrations DIR | sync --socket PATH --db PATH',
  );
  return 1;
}

Map<String, String> _options(Iterable<String> args) {
  final list = args.toList();
  final options = <String, String>{};
  for (var i = 0; i + 1 < list.length; i += 2) {
    if (!list[i].startsWith('--')) continue;
    options[list[i].substring(2)] = list[i + 1];
  }
  return options;
}

WriterOwnershipManager _manager(Map<String, String> env) {
  rejectEmulatorOnCloudRun(env);
  String need(String key) {
    final value = env[key];
    if (value == null || value.isEmpty) {
      throw StateError('必須の設定がありません: $key');
    }
    return value;
  }

  return WriterOwnershipManager(
    gcs: HttpGcsObjectClient(
      emulatorHost: env['STORAGE_EMULATOR_HOST'],
      tokens: MetadataServerAccessTokenProvider(),
    ),
    bucket: need('DB_REPLICA_BUCKET'),
    object: need('DB_WRITER_OWNER_OBJECT'),
    releaseId: need('RELEASE_ID'),
  );
}

Future<int> _owner(
  String action,
  Map<String, String> options,
  Map<String, String> env,
) async {
  final manager = _manager(env);
  switch (action) {
    case 'acquire':
      final out = options['out'];
      if (out == null) return _usage();
      try {
        final ownership = await manager.acquire();
        File(out).writeAsStringSync(
          jsonEncode({
            'ownerId': ownership.ownerId,
            'generation': ownership.generation,
            'bucket': ownership.bucket,
            'object': ownership.object,
          }),
        );
        stdout.writeln(
          'writer 所有権を取得した ownerId=${ownership.ownerId} '
          'generation=${ownership.generation}',
        );
        return 0;
      } on WriterOwnershipUnavailable catch (e) {
        stderr.writeln('writer 所有権を取得できない: ${e.message}');
        return 20;
      }
    case 'release':
      final file = options['file'];
      if (file == null) return _usage();
      final json = jsonDecode(File(file).readAsStringSync());
      if (json is! Map<String, Object?>) {
        stderr.writeln('所有権ファイルの形が違う');
        return 1;
      }
      final ownership = WriterOwnership(
        ownerId: json['ownerId']! as String,
        generation: json['generation']! as String,
        bucket: json['bucket']! as String,
        object: json['object']! as String,
      );
      try {
        await manager.release(ownership);
        stdout.writeln('writer 所有権を解放した ownerId=${ownership.ownerId}');
        return 0;
      } on WriterOwnershipUnavailable catch (e) {
        stderr.writeln('writer 所有権を解放できない: ${e.message}');
        return 21;
      }
    case 'clear':
      // 異常終了で残った所有権を、運用者が旧プロセス・Job・未完了アップロードの
      // 停止を確認したうえで解除する。generation を指定するので、確認後に別の
      // writer が取り直した所有権は消さない。
      final generation = options['generation'];
      if (generation == null) return _usage();
      try {
        await manager.release(
          WriterOwnership(
            ownerId: 'manual-clear',
            generation: generation,
            bucket: manager.bucket,
            object: manager.object,
          ),
        );
        stdout.writeln('writer 所有権を解除した generation=$generation');
        return 0;
      } on WriterOwnershipUnavailable catch (e) {
        stderr.writeln('writer 所有権を解除できない: ${e.message}');
        return 21;
      }
    case 'show':
      final current = await HttpGcsObjectClient(
        emulatorHost: env['STORAGE_EMULATOR_HOST'],
        tokens: MetadataServerAccessTokenProvider(),
      ).read(manager.bucket, manager.object);
      stdout.writeln(
        current == null
            ? '所有権オブジェクトはない'
            : 'generation=${current.generation} ${current.content}',
      );
      return 0;
    default:
      return _usage();
  }
}

/// 復元した DB が使えるかを確かめる。壊れていれば 1、migration の過不足は 10 / 11。
int _verifyDb(Map<String, String> options) {
  final path = options['db'];
  final migrations = options['migrations'];
  if (path == null || migrations == null) return _usage();
  if (!File(path).existsSync()) {
    stderr.writeln('DB ファイルがない: $path');
    return 1;
  }

  final db = sqlite3.open(path, mode: OpenMode.readOnly);
  try {
    final integrity = db.select('PRAGMA integrity_check;');
    if (integrity.length != 1 || integrity.first.values.first != 'ok') {
      stderr.writeln('integrity_check に失敗した: ${integrity.toList()}');
      return 1;
    }
    final violations = db.select('PRAGMA foreign_key_check;');
    if (violations.isNotEmpty) {
      stderr.writeln('foreign_key_check に失敗した: ${violations.length} 件');
      return 1;
    }

    final Map<String, String> applied;
    try {
      applied = {
        for (final row in db.select(
          'SELECT module, version FROM serverpod_migrations;',
        ))
          row['module'] as String: row['version'] as String,
      };
    } on SqliteException {
      // 初回 DB の作成は専用 Job の仕事。空の DB を正常として扱わない。
      stderr.writeln('serverpod_migrations がない（初期化されていない DB）');
      return 10;
    }

    final manifest = SchemaManifest.fromMigrationsDirectory(migrations);
    switch (manifest.check(applied)) {
      case SchemaCheck.ok:
        stdout.writeln('DB の検証に成功した（適用版 $applied）');
        return 0;
      case SchemaCheck.needsMigration:
        stderr.writeln(
          '未適用の migration がある 期待=${manifest.expected} 適用=$applied',
        );
        return 10;
      case SchemaCheck.tooNew:
        stderr.writeln('DB が image より新しい 期待=${manifest.expected} 適用=$applied');
        return 11;
    }
  } finally {
    db.close();
  }
}

/// Litestream が同期要求を受けられる状態か、複製が追いついているかを確かめる。
/// 起動時の準備待ちと、migration 後の複製確認に使う。成功 0、確認できなければ 1。
Future<int> _sync(Map<String, String> options) async {
  final socket = options['socket'];
  final db = options['db'];
  if (socket == null || db == null) return _usage();
  try {
    await LitestreamConfirmer(
      socketPath: socket,
      dbPath: db,
    ).confirm(timeout: Duration(seconds: int.parse(options['timeout'] ?? '5')));
    return 0;
  } on ReplicationUnavailableException catch (e) {
    stderr.writeln(e.reason);
    return 1;
  }
}
