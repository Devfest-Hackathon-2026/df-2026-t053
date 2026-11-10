import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:app/model/assets/model.dart';
import 'package:app/provider/assets/storage.dart';
import 'package:app/provider/assets/validation.dart';
import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'provider.g.dart';

@riverpod
AssetCacheSettings assetCacheSettings(Ref ref) => AssetCacheSettings(
  baseUrl: Uri.parse(const String.fromEnvironment('ASSET_BASE_URL')),
);

@Riverpod(keepAlive: true)
Future<Directory> assetCacheDirectory(Ref ref) async {
  final directory = await prepareAssetDirectory();
  // 前プロセスの未確定ファイルは公開・再利用しない。
  final parts = Directory('${directory.path}/.part');
  if (await parts.exists()) await parts.delete(recursive: true);
  return directory;
}

/// アプリ全体で取得と参照を共有する。モデル素材・RPC・画面状態は扱わない。
@Riverpod(keepAlive: true)
class AssetsNotifier extends _$AssetsNotifier {
  final _jobs = <String, _AssetJob>{};
  final _queue = <_AssetJob>[];
  var _active = 0;
  var _reservedBytes = 0;
  var _disposed = false;
  Future<void> _storageTail = Future.value();

  @override
  void build() {
    ref.onDispose(() {
      _disposed = true;
      for (final job in _jobs.values.toList()) {
        job.cancel();
      }
    });
  }

  /// 呼び出しごとに参照を取得する。準備取消・画面破棄時は必ずreleaseする。
  /// 完了後も参照がある間は容量整理でファイルを削除しない。
  AssetLease acquire(AssetRef reference) {
    if (_disposed) throw const AssetFailure(.cancelled);
    final settings = ref.read(assetCacheSettingsProvider);
    final uri = validateAssetReference(reference, settings);
    final snapshot = reference.copyWith();
    final key = '${snapshot.sha256}/${uri.pathSegments.last}';
    final existing = _jobs[key];
    // 同じSHAでも宣言内容が違う要求を合流させない。
    for (final job in _jobs.values) {
      if (job.asset.sha256 == snapshot.sha256 &&
          (job.asset.byteLength != snapshot.byteLength ||
              job.asset.contentType != snapshot.contentType)) {
        throw const AssetFailure(.invalidReference);
      }
    }
    final job = existing ?? _AssetJob(snapshot, uri, key, settings);
    job.result.future.ignore();
    job.references++;
    if (existing == null) {
      _jobs[key] = job;
      job.timer = Timer(settings.totalTimeout, () {
        if (identical(_jobs[key], job)) _jobs.remove(key);
        job.timeout();
      });
      _queue.add(job);
      _pump();
    }
    return AssetLease._(job, () {
      job.references--;
      if (job.references == 0) {
        if (identical(_jobs[key], job)) _jobs.remove(key);
        job.cancel();
      }
    });
  }

  void _pump() {
    while (!_disposed && _active < 2 && _queue.isNotEmpty) {
      final job = _queue.removeAt(0);
      if (job.cancelled) continue;
      _active++;
      unawaited(
        _run(job).whenComplete(() {
          _active--;
          _pump();
        }),
      );
    }
  }

  Future<T> _storage<T>(Future<T> Function() operation) {
    final next = _storageTail.then((_) => operation());
    _storageTail = next.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return next;
  }

  Future<void> _run(_AssetJob job) async {
    var reserved = false;
    try {
      final directory = await ref.read(assetCacheDirectoryProvider.future);
      job.checkActive();
      final file = File('${directory.path}/${job.key}');
      // キャッシュの検証・再利用判定と削除を直列化する。
      // 削除開始後に届いた新参照が、削除中のファイルを読み始めないようにする。
      final reused = await _storage(() async {
        job.checkActive();
        if (await file.exists()) {
          var verified = false;
          try {
            await verifyAssetFile(file, job.asset);
            verified = true;
          } on AssetFailure {
            await file.delete();
          }
          if (verified) {
            job.checkActive();
            await file.setLastModified(DateTime.now());
            return true;
          }
        }
        job.checkActive();
        await _makeRoom(directory, job);
        _reservedBytes += job.asset.byteLength;
        reserved = true;
        return false;
      });
      if (reused) {
        job.complete(file);
        return;
      }
      await file.parent.create(recursive: true);
      // createTempで試行ごとの固有パスを作り、同じFS内でrenameする。
      final parts = await Directory('${directory.path}/.part')
          .create(recursive: true);
      final temporary = await parts.createTemp();
      final part = File('${temporary.path}/download.part');
      try {
        await _download(job, part);
        await verifyAssetFile(part, job.asset);
        await _storage(() async {
          job.checkActive();
          await part.rename(file.path);
          _reservedBytes -= job.asset.byteLength;
          reserved = false;
          job.checkActive();
          job.complete(file);
        });
      } finally {
        await temporary.delete(recursive: true);
      }
    } catch (error, stackTrace) {
      final failure = job.cancelled
          ? AssetFailure(job.timedOut ? .unavailable : .cancelled)
          : error is AssetFailure
          ? error
          : AssetFailure(
              error is FileSystemException ? .storage : .unavailable,
            );
      log(
        '素材の取得または検証に失敗しました',
        error: error.runtimeType,
        stackTrace: stackTrace,
      );
      if (identical(_jobs[job.key], job)) _jobs.remove(job.key);
      job.fail(failure);
    } finally {
      job.closeClient();
      if (reserved) {
        await _storage(() async {
          _reservedBytes -= job.asset.byteLength;
        });
      }
      // 失敗したジョブは再試行可能。古い参照のreleaseで新しいジョブを消さない。
      if (!job.succeeded && identical(_jobs[job.key], job)) {
        _jobs.remove(job.key);
      }
    }
  }

  Future<void> _download(_AssetJob job, File part) async {
    job.checkActive();
    final client = HttpClient()
      ..connectionTimeout = job.settings.connectTimeout;
    client.autoUncompress = false;
    job.client = client;
    final request = await client
        .getUrl(job.uri)
        .timeout(job.settings.connectTimeout);
    request.followRedirects = false;
    request.headers.set(HttpHeaders.acceptEncodingHeader, 'identity');
    final response = await request.close().timeout(job.settings.connectTimeout);
    job.checkActive();
    if (response.statusCode != HttpStatus.ok ||
        response.headers.contentType?.mimeType != job.asset.contentType ||
        response.headers.value(HttpHeaders.contentEncodingHeader) != null ||
        (response.contentLength >= 0 &&
            response.contentLength != job.asset.byteLength)) {
      throw const AssetFailure(.integrity);
    }
    final sink = part.openWrite();
    var received = 0;
    try {
      await for (final bytes in response.timeout(job.settings.idleTimeout)) {
        job.checkActive();
        received += bytes.length;
        if (received > job.asset.byteLength || received > maxImageBytes) {
          throw const AssetFailure(.integrity);
        }
        sink.add(bytes);
        // flushでファイル書き込みの失敗とbackpressureを逐次扱う。
        await sink.flush();
        job.report(received);
      }
    } finally {
      await sink.close();
    }
  }

  Future<void> _makeRoom(Directory directory, _AssetJob job) async {
    final files = <({File file, DateTime modified, int bytes})>[];
    var occupied = _reservedBytes;
    await for (final entry in directory.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entry is File && !entry.path.endsWith('.part')) {
        final bytes = await entry.length();
        files.add((
          file: entry,
          modified: await entry.lastModified(),
          bytes: bytes,
        ));
        occupied += bytes;
      }
    }
    files.sort((a, b) => a.modified.compareTo(b.modified));
    for (final candidate in files) {
      final file = candidate.file;
      if (occupied + job.asset.byteLength <= job.settings.capacityBytes) return;
      final protected = _jobs.values.any(
        (other) =>
            other.references > 0 &&
            file.path == '${directory.path}/${other.key}',
      );
      if (protected) continue;
      occupied -= candidate.bytes;
      await file.delete();
    }
    if (occupied + job.asset.byteLength > job.settings.capacityBytes) {
      throw const AssetFailure(.storage);
    }
  }
}

/// ファイルの所有権ではなく利用参照。データモデルではなく解放可能な資源ハンドル。
class AssetLease._(final _AssetJob _job, final void Function() _release) {
  final _released = Completer<File>();
  var _isReleased = false;

  Future<File> get file async {
    if (_isReleased) throw const AssetFailure(.cancelled);
    final file = await Future.any([_job.result.future, _released.future]);
    try {
      await verifyAssetFile(file, _job.asset);
    } catch (error, stackTrace) {
      log('素材の再利用検証に失敗しました', error: error.runtimeType, stackTrace: stackTrace);
      if (error is AssetFailure) rethrow;
      throw AssetFailure(error is FileSystemException ? .storage : .integrity);
    }
    if (_isReleased) throw const AssetFailure(.cancelled);
    return file;
  }

  AssetProgress get progress => _job.progress;
  Stream<AssetProgress> get changes => _job.changes.stream;

  void release() {
    if (_isReleased) return;
    _isReleased = true;
    _release();
    _released.future.ignore();
    _released.completeError(const AssetFailure(.cancelled));
  }
}

/// 取得ジョブの可変な寿命管理。アプリの不変データはmodel/assetsへ置く。
class _AssetJob(
  final AssetRef asset,
  final Uri uri,
  final String key,
  final AssetCacheSettings settings,
) {
  final result = Completer<File>();
  final changes = StreamController<AssetProgress>.broadcast();
  var references = 0;
  var cancelled = false;
  var timedOut = false;
  var succeeded = false;
  HttpClient? client;
  Timer? timer;
  late AssetProgress progress = AssetProgress(
    received: 0,
    total: asset.byteLength,
  );

  void checkActive() {
    if (cancelled) throw AssetFailure(timedOut ? .unavailable : .cancelled);
  }

  void report(int received) {
    progress = AssetProgress(received: received, total: asset.byteLength);
    if (!changes.isClosed) changes.add(progress);
  }

  void complete(File file) {
    timer?.cancel();
    succeeded = true;
    report(asset.byteLength);
    if (!result.isCompleted) result.complete(file);
    unawaited(changes.close());
  }

  void fail(AssetFailure failure) {
    timer?.cancel();
    if (!result.isCompleted) result.completeError(failure);
    unawaited(changes.close());
  }

  void closeClient() {
    client?.close(force: true);
  }

  void timeout() {
    timedOut = true;
    cancel();
  }

  void cancel() {
    cancelled = true;
    closeClient();
    if (!result.isCompleted) {
      fail(AssetFailure(timedOut ? .unavailable : .cancelled));
    }
  }
}
