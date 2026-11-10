import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' show SqliteException;

import 'src/application/seed/load_seed_revision.dart';
import 'src/application/seed/seed_input.dart';
import 'src/application/seed/seed_ports.dart';
import 'src/infrastructure/config/replication_settings.dart';
import 'src/infrastructure/database/replication/gcs_object_client.dart';
import 'src/infrastructure/database/seed/sqlite_seed_store.dart';
import 'src/infrastructure/google/access_token_provider.dart';
import 'src/infrastructure/seed/seed_reader.dart';
import 'src/infrastructure/storage/gcs_media_store.dart';

export 'src/infrastructure/seed/seed_reader.dart'
    show SeedInputException, readSeedBundle;

/// 出題の seed を登録・公開する管理用 CLI の本体（#26）。
///
/// ```
/// seed verify  --dir DIR [--pavilions FILE]          # DB・所有権を使わない
/// seed load    --dir DIR [--pavilions FILE] --db PATH [--publish true]
/// seed publish --slug SLUG --revision N --db PATH   # 切り戻しも同じ
/// seed unpublish --slug SLUG --db PATH
/// seed delete-draft --slug SLUG --revision N --db PATH
/// ```
///
/// - DIR は `content/seeds/<slug>/r<n>`（`revision.yaml` と素材）。
/// - `--pavilions` の既定値は `DIR/../../pavilions.yaml`（`content/seeds/pavilions.yaml`）。
/// - DB に書くコマンドは writer 所有権を取ってから実行する（`scripts/seed.sh`）。
/// - 素材は `ASSET_BUCKET` へ置く。ローカルは `STORAGE_EMULATOR_HOST` の fake-gcs-server。
///
/// 終了コード: 0 成功、1 使い方・入力の失敗、2 検証の違反、3 登録済みの内容と両立しない、
/// 4 外部の失敗（GCS の通信、SQLite のロック・制約、DB ファイルがない、ファイルの読み取り失敗）。
/// 入力ファイルがない・YAML の形が違うのは 1（入力の誤り）。
Future<int> runSeed(List<String> args, Map<String, String> env) async {
  if (args.isEmpty) return _usage();
  final allowed = _commandOptions[args.first];
  if (allowed == null) return _usage();
  final options = _options(args.skip(1), allowed);
  if (options == null) return _usage();
  try {
    switch (args.first) {
      case 'verify':
        return await _load(options, env, verifyOnly: true);
      case 'load':
        return await _load(options, env, verifyOnly: false);
      case 'publish':
        return await _withStore(options, (store) async {
          final slug = options['slug'];
          final revision = int.tryParse(options['revision'] ?? '');
          if (slug == null || revision == null) return _usage();
          final outcome = await store.publish(
            slug: slug,
            revisionNo: revision,
            now: DateTime.now(),
          );
          stdout.writeln('seed: $slug r$revision を公開中にした（${outcome.name}）');
          return 0;
        });
      case 'unpublish':
        return await _withStore(options, (store) async {
          final slug = options['slug'];
          if (slug == null) return _usage();
          await store.unpublish(slug: slug);
          stdout.writeln('seed: $slug を公開中でなくした');
          return 0;
        });
      case 'delete-draft':
        return await _withStore(options, (store) async {
          final slug = options['slug'];
          final revision = int.tryParse(options['revision'] ?? '');
          if (slug == null || revision == null) return _usage();
          await store.deleteDraft(slug: slug, revisionNo: revision);
          stdout.writeln('seed: 未公開の $slug r$revision を削除した');
          return 0;
        });
      default:
        return _usage();
    }
  } on SeedConflictException catch (e) {
    stderr.writeln('seed: 登録済みの内容と両立しない: ${e.message}');
    return 3;
  } on SeedNotFoundException catch (e) {
    stderr.writeln('seed: ${e.message}');
    return 1;
  } on SeedInputException catch (e) {
    stderr.writeln('seed: 入力を読めない: ${e.message}');
    return 1;
  } on GcsException catch (e) {
    // 素材の置き場に届かない・拒否された。DB は変えていない（素材は DB より先に置く）。
    stderr.writeln('seed: 素材の置き場（GCS）で失敗した: $e');
    return 4;
  } on SqliteException catch (e) {
    // DB が開けない・ロックされている・制約（トリガー）で拒否された。トランザクションは取り消されている。
    stderr.writeln('seed: DB の操作に失敗した: $e');
    return 4;
  } on FileSystemException catch (e) {
    // DB ファイルがない、素材・入力ファイルを権限などで読めない。
    stderr.writeln('seed: ファイルを扱えない: $e');
    return 4;
  }
}

int _usage() {
  stderr.writeln(
    'usage: seed verify --dir DIR [--pavilions FILE] | '
    'load --dir DIR [--pavilions FILE] --db PATH [--publish true] | '
    'publish --slug SLUG --revision N --db PATH | '
    'unpublish --slug SLUG --db PATH | '
    'delete-draft --slug SLUG --revision N --db PATH',
  );
  return 1;
}

/// コマンドごとに受け付けるオプション。`--名前 値` の組だけを受け付ける。
/// コマンドに意味のないオプション（`unpublish` の `--revision` など）も、黙って無視しない。
const _commandOptions = {
  'verify': {'dir', 'pavilions'},
  'load': {'dir', 'pavilions', 'db', 'publish'},
  'publish': {'slug', 'revision', 'db'},
  'unpublish': {'slug', 'db'},
  'delete-draft': {'slug', 'revision', 'db'},
};

/// `--名前 値` を読む。値のない `--名前`、`--名前=値`、[allowed] にない名前、重複、
/// `--publish` の true／false 以外は、黙って無視せず null（使い方の誤り）にする。
Map<String, String>? _options(Iterable<String> args, Set<String> allowed) {
  final list = args.toList();
  final options = <String, String>{};
  for (var i = 0; i < list.length; i += 2) {
    final key = list[i];
    if (!key.startsWith('--') || i + 1 >= list.length) {
      stderr.writeln('seed: オプションは --名前 値 の組で指定する: $key');
      return null;
    }
    final name = key.substring(2);
    if (!allowed.contains(name)) {
      stderr.writeln('seed: このコマンドでは使えないオプション: $key');
      return null;
    }
    if (options.containsKey(name)) {
      stderr.writeln('seed: オプションが重複している: $key');
      return null;
    }
    options[name] = list[i + 1];
  }
  final publish = options['publish'];
  if (publish != null && publish != 'true' && publish != 'false') {
    stderr.writeln('seed: --publish は true か false にする: $publish');
    return null;
  }
  return options;
}

Future<int> _withStore(
  Map<String, String> options,
  Future<int> Function(SqliteSeedStore store) body,
) async {
  final db = options['db'];
  if (db == null) return _usage();
  if (!File(db).existsSync()) {
    throw FileSystemException('DB ファイルがない', db);
  }
  final store = SqliteSeedStore.open(db);
  try {
    return await body(store);
  } finally {
    store.close();
  }
}

Future<int> _load(
  Map<String, String> options,
  Map<String, String> env, {
  required bool verifyOnly,
}) async {
  final dir = options['dir'];
  if (dir == null) return _usage();
  final pavilionsPath =
      options['pavilions'] ?? p.join(dir, '..', '..', 'pavilions.yaml');
  final bundle = readSeedBundle(dir: dir, pavilionsPath: pavilionsPath);

  // verify は DB も所有権も使わない（pavilion は入力のマスターだけで照合する）。
  // 稼働中の DB を所有権の外で読み書きで開かないよう、--db は受け付けない（_commandOptions）。
  if (verifyOnly) {
    return _report(
      await LoadSeedRevision(
        store: const _NoDatabase(),
        media: const _NoMedia(),
        clock: DateTime.now,
      ).execute(bundle, verifyOnly: true),
      bundle,
    );
  }

  return _withStore(options, (store) async {
    final bucket = env['ASSET_BUCKET'];
    if (bucket == null || bucket.isEmpty) {
      throw const SeedInputException('ASSET_BUCKET が未設定');
    }
    rejectEmulatorOnCloudRun(env);
    final tokens = MetadataServerAccessTokenProvider();
    final gcs = HttpGcsObjectClient(
      emulatorHost: env['STORAGE_EMULATOR_HOST'],
      tokens: tokens,
    );
    try {
      final result = await LoadSeedRevision(
        store: store,
        media: GcsMediaStore(gcs: gcs, bucket: bucket),
        clock: DateTime.now,
      ).execute(bundle, publish: options['publish'] == 'true');
      return _report(result, bundle);
    } finally {
      gcs.close();
      tokens.close();
    }
  });
}

int _report(LoadSeedResult result, SeedBundle bundle) {
  final name = '${bundle.input.slug} r${bundle.input.revisionNo}';
  switch (result) {
    case LoadSeedInvalid(:final violations):
      stderr.writeln('seed: $name の検証で ${violations.length} 件の違反がある');
      for (final v in violations) {
        stderr.writeln('  - $v');
      }
      return 2;
    case LoadSeedVerified():
      stdout.writeln('seed: $name の検証に通った');
      return 0;
    case LoadSeedLoaded(
      :final outcome,
      :final revisionId,
      :final uploaded,
      :final published,
    ):
      for (final path in uploaded) {
        stdout.writeln('seed: 素材を置いた $path');
      }
      stdout.writeln(
        outcome == SeedLoadOutcome.unchanged
            ? 'seed: $name は同じ内容で登録済み（変更なし） revisionId=$revisionId'
            : 'seed: $name を下書きとして登録した revisionId=$revisionId',
      );
      if (published != null) {
        stdout.writeln('seed: $name を公開中にした（${published.name}）');
      }
      return 0;
  }
}

/// verify を DB なしで実行するための空の実装。
class const _NoDatabase() implements SeedStore {
  @override
  Future<String?> findAssetObjectPath(String sha256) async => null;

  @override
  Future<Set<String>> pavilionKeys() async => const {};

  @override
  Future<void> checkDraft(
    SeedRevision input,
    String digest, {
    bool publish = false,
  }) async {}

  @override
  Future<
    ({SeedLoadOutcome outcome, int revisionId, SeedPublishOutcome? published})
  >
  loadDraft(SeedDraft draft, {bool publish = false}) =>
      throw UnsupportedError('verify は DB に書かない');

  @override
  Future<SeedPublishOutcome> publish({
    required String slug,
    required int revisionNo,
    required DateTime now,
  }) => throw UnsupportedError('verify は DB に書かない');

  @override
  Future<void> unpublish({required String slug}) =>
      throw UnsupportedError('verify は DB に書かない');

  @override
  Future<void> deleteDraft({required String slug, required int revisionNo}) =>
      throw UnsupportedError('verify は DB に書かない');
}

class const _NoMedia() implements SeedMediaStore {
  @override
  Future<bool> putIfAbsent(
    String objectPath,
    List<int> bytes,
    String contentType,
  ) => throw UnsupportedError('verify は素材を置かない');
}
