import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../../application/dto/ranking_result.dart';
import '../../domain/exceptions.dart';
import '../di/ranking_dependencies.dart';
import '../endpoint_call.dart';

class RankingEndpoint() extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<ListRankingEntriesResponse> listRankingEntries(
    Session session,
    ListRankingEntriesRequest request,
  ) => _call(session, () async {
    final rows = await listRankingEntriesUseCase(session)
        .execute(_authUserId(session), request.revisionId, request.mode);
    return ListRankingEntriesResponse(entries: rows.map(_entry).toList());
  });

  Future<RankingEntry> getMyRankingEntry(
    Session session,
    GetMyRankingEntryRequest request,
  ) => _call(
    session,
    () async => _entry(
      await getMyRankingEntryUseCase(session)
          .execute(_authUserId(session), request.revisionId, request.mode),
    ),
  );
}

UuidValue _authUserId(Session session) {
  final id = session.authenticated?.authUserId;
  if (id == null) throw StateError('認証済みのセッションが必要です');
  return id;
}

RankingEntry _entry(RankingResult result) => RankingEntry(
  rank: result.rank,
  nickname: result.nickname,
  score: result.score,
  achieveTime: result.achieveTime,
  mine: result.mine,
);

Future<T> _call<T>(Session session, Future<T> Function() action) {
  return guardUnclassifiedFailure(
    session: session,
    logLabel: '順位処理に失敗しました',
    action: () async {
      try {
        return await action();
      } on RankingException catch (error) {
        switch (error.reason) {
          case .invalidRequest:
            throw ApiException(
              code: .invalidArgument,
              reason: ApiErrorReasons.invalidRequest,
              message: '探索モードを確認してください',
              fieldViolations: [
                FieldViolation(field: 'mode', reason: 'UNKNOWN'),
              ],
            );
          case .revisionNotFound:
            throw ApiException(
              code: .notFound,
              reason: ApiErrorReasons.revisionNotFound,
              message: '指定された出題版が見つかりません',
            );
          case .entryNotFound:
            throw ApiException(
              code: .notFound,
              reason: ApiErrorReasons.rankingEntryNotFound,
              message: 'この版・モードの記録はまだありません',
            );
          case .profileNotInitialized:
            session.log('認証主体のプロフィールが欠落しています', level: .error);
            throw ApiException(
              code: .failedPrecondition,
              reason: ApiErrorReasons.profileNotInitialized,
              message: '認証を更新してから再取得してください',
            );
        }
      }
    },
  );
}
