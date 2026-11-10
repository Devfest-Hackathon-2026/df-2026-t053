import 'dart:async';
import 'dart:developer';

import 'package:app/model/assets/model.dart';
import 'package:app/model/photo/model.dart';
import 'package:app/provider/assets/provider.dart';
import 'package:app/provider/assets/validation.dart';
import 'package:app/provider/challenge/provider.dart';
import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'provider.g.dart';

/// 出題版の手がかり写真を取得し、モード選択から結果表示まで参照を保持する。
@Riverpod(keepAlive: true)
class CluePhotoNotifier extends _$CluePhotoNotifier {
  @override
  CluePhotoState build() {
    ref.onDispose(_release);
    ref.listen(challengeProvider, (previous, next) {
      if (previous?.revision?.id == next.revision?.id &&
          previous?.revision?.photo.sha256 == next.revision?.photo.sha256) {
        return;
      }
      unawaited(_sync(next.revision));
    });
    final revision = ref.read(challengeProvider).revision;
    if (revision != null) {
      // build 中に state を書き換えない。listen は現在値では発火しない。
      unawaited(
        Future<void>.microtask(() {
          if (ref.mounted) unawaited(_sync(revision));
        }),
      );
    }
    return const CluePhotoState();
  }

  AssetLease? _lease;
  StreamSubscription<AssetProgress>? _progress;
  Future<void>? _inflight;
  int _generation = 0;
  int? _revisionId;
  String? _sha;

  /// [revision] の写真を準備する。進行中ならそれを待ち、失敗していれば一度取り直す。
  /// 準備完了でその版と一致しなければ [AssetFailure] を投げる。
  Future<void> ensureReady(ChallengeRevision revision) async {
    if (!_isRevision(revision) || state.phase != .ready) {
      await _sync(revision);
    }
    if (!ref.mounted) throw const AssetFailure(.cancelled);
    if (state.phase == .ready && _isRevision(revision)) return;
    throw AssetFailure(state.failure ?? .unavailable);
  }

  bool _isRevision(ChallengeRevision revision) =>
      _revisionId == revision.id && _sha == revision.photo.sha256;

  /// 同じ版の失敗を、利用者の操作で取り直す。
  Future<void> retry() {
    _revisionId = null;
    _sha = null;
    return _sync(ref.read(challengeProvider).revision);
  }

  Future<void> _sync(ChallengeRevision? revision) {
    if (revision != null &&
        _revisionId == revision.id &&
        _sha == revision.photo.sha256 &&
        state.phase != .failed) {
      if (state.phase == .ready) return Future<void>.value();
      final pending = _inflight;
      if (pending != null) return pending;
    }
    final run = _load(revision);
    _inflight = run;
    return run.whenComplete(() {
      if (identical(_inflight, run)) _inflight = null;
    });
  }

  Future<void> _load(ChallengeRevision? revision) async {
    final generation = ++_generation;
    _release();
    if (revision == null) {
      _revisionId = null;
      _sha = null;
      if (ref.mounted && generation == _generation) {
        state = const CluePhotoState();
      }
      return;
    }
    _revisionId = revision.id;
    _sha = revision.photo.sha256;
    if (!ref.mounted || generation != _generation) return;
    state = CluePhotoState(phase: .loading, alt: revision.photoAlt);
    try {
      final lease = ref.read(assetsProvider.notifier).acquire(revision.photo);
      if (!ref.mounted || generation != _generation) {
        lease.release();
        return;
      }
      _lease = lease;
      _progress = lease.changes.listen((progress) {
        if (!ref.mounted || generation != _generation || progress.total <= 0) {
          return;
        }
        state = state.copyWith(progress: progress.received / progress.total);
      });
      final file = await lease.file;
      final size = await readImageSize(file);
      if (!ref.mounted || generation != _generation) return;
      state = CluePhotoState(
        phase: .ready,
        alt: revision.photoAlt,
        path: file.path,
        width: size.width,
        height: size.height,
        progress: 1,
      );
    } on AssetFailure catch (error, stackTrace) {
      if (!ref.mounted || generation != _generation) return;
      log('手がかり写真の取得に失敗しました', error: error.runtimeType, stackTrace: stackTrace);
      _release();
      state = CluePhotoState(
        phase: .failed,
        alt: revision.photoAlt,
        failure: error.kind,
      );
    } catch (error, stackTrace) {
      if (!ref.mounted || generation != _generation) return;
      log('手がかり写真の取得に失敗しました', error: error.runtimeType, stackTrace: stackTrace);
      _release();
      state = const CluePhotoState(phase: .failed, failure: .unavailable);
    }
  }

  void _release() {
    unawaited(_progress?.cancel());
    _progress = null;
    final lease = _lease;
    _lease = null;
    lease?.release();
  }
}
