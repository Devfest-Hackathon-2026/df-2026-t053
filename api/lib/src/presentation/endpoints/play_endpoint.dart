import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../../domain/exceptions.dart';
import '../../domain/services/shot_scorer.dart';
import '../di/play_dependencies.dart';
import '../endpoint_call.dart';
import '../mappers/play_api_exception.dart';
import '../mappers/play_session_response.dart';

/// プレイの開始・撮影と現在状態の取得（docs/specs.md「出題版・開始・結果の再取得」）。
///
/// 撮影直後・再送・撮影済みの取得は共通の mapper を使う。
class PlayEndpoint() extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<PlaySession> createPlaySession(
    Session session,
    CreatePlaySessionRequest request,
  ) => _call(session, () async {
    final result = await startPlayUseCase(session).execute(
      _authUserId(session),
      revisionId: request.revisionId,
      mode: request.mode,
      requestId: request.requestId,
      spawnPointId: request.spawnPointId,
    );
    return playSessionResponse(result);
  });

  Future<SubmitShotResponse> submitShot(
    Session session,
    SubmitShotRequest request,
  ) => _call(session, () async {
    final camera = request.camera;
    final result = await submitShotUseCase(session).execute(
      _authUserId(session),
      playSessionId: request.playSessionId,
      requestId: request.requestId,
      camera: ScoringPose(
        positionX: camera.positionX,
        positionZ: camera.positionZ,
        yawDegrees: camera.yawDegrees,
        pitchDegrees: camera.pitchDegrees,
      ),
    );
    return submitShotResponse(result);
  });

  Future<PlaySession> getPlaySession(
    Session session,
    GetPlaySessionRequest request,
  ) => _call(session, () async {
    final result = await getPlaySessionUseCase(session)
        .execute(_authUserId(session), request.playSessionId);
    return playSessionResponse(result);
  });
}

UuidValue _authUserId(Session session) {
  final id = session.authenticated?.authUserId;
  if (id == null) throw StateError('認証済みのセッションが必要です');
  return id;
}

Future<T> _call<T>(Session session, Future<T> Function() action) {
  return guardUnclassifiedFailure(
    session: session,
    logLabel: 'プレイ処理に失敗しました',
    action: () async {
      try {
        return await action();
      } on ShotException catch (error) {
        throw switch (error.reason) {
          .invalidCamera => ApiException(
            code: .invalidArgument,
            reason: ApiErrorReasons.invalidCamera,
            message: '撮影の位置と向きを確認してください',
            fieldViolations: [
              for (final field in error.fields)
                FieldViolation(field: field, reason: '有限の値を操作可能な範囲で指定してください'),
            ],
          ),
          .alreadySubmitted => ApiException(
            code: .alreadyExists,
            reason: ApiErrorReasons.shotAlreadySubmitted,
            message: '撮影済みです。結果を再取得してください',
          ),
          .sessionExpired => ApiException(
            code: .failedPrecondition,
            reason: ApiErrorReasons.sessionExpired,
            message: 'プレイの期限が切れています',
          ),
        };
      } on PlayException catch (error) {
        throw playApiException(session, error);
      } on CorruptedDataException catch (error) {
        // DB の値が前提を満たさない。詳細はログに残し、応答には固定の説明だけを返す。
        session.log('プレイのデータが壊れている: $error', level: LogLevel.error);
        throw ApiException(
          code: .internal,
          reason: ApiErrorReasons.internal,
          message: 'プレイのデータを読み取れませんでした',
        );
      }
    },
  );
}
