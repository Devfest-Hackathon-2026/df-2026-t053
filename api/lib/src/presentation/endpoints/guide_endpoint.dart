import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../../application/dto/guide_output.dart';
import '../../application/usecase/guide_preconditions.dart';
import '../../domain/exceptions.dart';
import '../../domain/ports/guide_admission.dart';
import '../di/guide_dependencies.dart';
import '../di/guide_stream_dependencies.dart';
import '../mappers/play_api_exception.dart';
import '../middleware/guide_stream.dart';

class GuideEndpoint() extends Endpoint {
  @override
  bool get requireLogin => true;

  Stream<NearbyGuideEvent> explainNearby(
    Session session,
    ExplainNearbyRequest request,
  ) {
    // streamを返す前の同期例外も同じApiExceptionへ変換する。
    // locale と停止の規則は guide_preconditions が正本。
    try {
      rejectUnsupportedGuideLocale(request.locale);
      final generators = guideGenerators();
      if (generators == null) rejectDisabledGuide();
      final userId = session.authenticated?.authUserId;
      if (userId == null) throw StateError('認証済みのセッションが必要です');
      final guideId = const Uuid().v4obj();
      final useCase = explainNearbyUseCase(session, generators);
      return _drained(
        session,
        useCase
            .execute(
              userId: userId,
              locale: request.locale,
              remaining: () => guideRemaining(session),
              load: () => guideStreamContext(session).database(
                session,
                () => prepareNearbyGuide(session).execute(
                  userId,
                  request.playSessionId,
                  x: request.positionX,
                  z: request.positionZ,
                  yaw: request.yawDegrees,
                ),
              ),
            )
            .map((event) => _event(guideId, event))
            .handleError((Object error, StackTrace stack) {
              throw _error(session, error);
            }),
      );
    } catch (error) {
      return Stream.error(_error(session, error));
    }
  }
}

Stream<NearbyGuideEvent> _drained(
  Session session,
  Stream<NearbyGuideEvent> source,
) async* {
  await for (final event in source) {
    yield event;
    await drainGuideTransport(session);
  }
}

NearbyGuideEvent _event(UuidValue id, GuideOutput output) => switch (output) {
  GuideTextOutput(:final result, :final names) => GuideText(
    guideId: id,
    text: result.text,
    structures: names,
    aiGenerated: result.aiGenerated,
    sources: [
      for (final source in result.sources)
        GuideSource(title: source.title, url: source.url),
    ],
  ),
  GuideAudioOutput(:final sequence, :final data, :final last) =>
    GuideAudioChunk(
      guideId: id,
      sequence: sequence,
      data: data,
      contentType: 'audio/wav',
      last: last,
    ),
  GuideUnavailableOutput(:final reason) => GuideAudioUnavailable(
    guideId: id,
    reason: switch (reason) {
      .textFallback => .TEXT_FALLBACK,
      .ttsFailed => .TTS_FAILED,
      .timeout => .AUDIO_TIMEOUT,
      .disabled => .UNKNOWN,
    },
  ),
};

ApiException _error(Session session, Object error) {
  if (error is ApiException) return error;
  if (error is PlayException) {
    return playApiException(
      session,
      error,
      message: 'この解説を開始できません。状態を確認してやり直してください',
    );
  }
  if (error is GuideRateLimitedException) {
    return ApiException(
      code: .resourceExhausted,
      reason: ApiErrorReasons.guideRateLimited,
      message: 'しばらく待ってから解説を開始してください',
      retryAfterSeconds: error.retryAfterSeconds,
    );
  }
  final (ApiErrorCode, String) failure = switch (error) {
    GuidePreconditionException(reason: .unsupportedLocale) => (
      .invalidArgument,
      ApiErrorReasons.unsupportedLocale,
    ),
    GuidePreconditionException(reason: .disabled) => (
      .failedPrecondition,
      ApiErrorReasons.guideDisabled,
    ),
    GuidePreconditionException(reason: .completed) => (
      .failedPrecondition,
      ApiErrorReasons.sessionCompleted,
    ),
    GuidePreconditionException(reason: .expired) => (
      .failedPrecondition,
      ApiErrorReasons.sessionExpired,
    ),
    GuidePreconditionException(reason: .deadline) => (
      .unavailable,
      ApiErrorReasons.temporarilyUnavailable,
    ),
    InvalidGuidePoseException() => (
      .invalidArgument,
      ApiErrorReasons.invalidCamera,
    ),
    NoGuideTargetException() => (
      .failedPrecondition,
      ApiErrorReasons.noGuideTarget,
    ),
    _ => (.internal, ApiErrorReasons.internal),
  };
  if (failure.$1 == .internal) {
    session.log('ガイド処理に失敗しました: ${error.runtimeType}', level: .error);
  }
  return ApiException(
    code: failure.$1,
    reason: failure.$2,
    message: 'この解説を開始できません。状態を確認してやり直してください',
  );
}
