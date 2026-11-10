import 'package:photohunt_server/src/application/usecase/get_my_profile.dart';
import 'package:photohunt_server/src/application/usecase/get_play_session.dart';
import 'package:photohunt_server/src/application/usecase/list_challenges.dart';
import 'package:photohunt_server/src/application/usecase/list_ranking_entries.dart';
import 'package:photohunt_server/src/domain/exceptions.dart';
import 'package:photohunt_server/src/presentation/endpoints/challenge_endpoint.dart';
import 'package:photohunt_server/src/presentation/endpoints/play_endpoint.dart';
import 'package:photohunt_server/src/presentation/endpoints/profile_endpoint.dart';
import 'package:photohunt_server/src/presentation/endpoints/ranking_endpoint.dart';
import 'package:photohunt_server/src/presentation/mappers/play_api_exception.dart';
import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

const _secret = '撮影が完了していません';
const _guideMessage = 'この解説を開始できません。状態を確認してやり直してください';

void main() {
  late _LoggingSession session;

  setUp(() => session = _LoggingSession.authenticated());
  tearDown(() {
    listChallengesExecuteForTest = null;
    getPlaySessionExecuteForTest = null;
    listRankingEntriesExecuteForTest = null;
    getMyProfileExecuteForTest = null;
  });

  group('PlayException の変換表', () {
    test('play の code・reason・message・retryAfterSeconds を返す', () {
      final limited = playApiException(
        session,
        const PlayException(.sessionRateLimited, retryAfterSeconds: 12),
      );
      expect(limited.code, ApiErrorCode.resourceExhausted);
      expect(limited.reason, ApiErrorReasons.sessionRateLimited);
      expect(limited.retryAfterSeconds, 12);
      expect(limited.message, '開始の回数が上限に達しました。しばらくしてからやり直してください');

      final missing = playApiException(
        session,
        const PlayException(.sessionNotFound),
      );
      expect(missing.code, ApiErrorCode.notFound);
      expect(missing.reason, ApiErrorReasons.playSessionNotFound);
      expect(missing.message, '指定されたプレイが見つかりません');
      expect(session.logs, isEmpty);
    });

    test('プロフィール欠落はエラーログを残し、ガイドは説明文だけを差し替える', () {
      final guide = playApiException(
        session,
        const PlayException(.profileNotInitialized),
        message: _guideMessage,
      );
      expect(guide.code, ApiErrorCode.failedPrecondition);
      expect(guide.reason, ApiErrorReasons.profileNotInitialized);
      expect(guide.message, _guideMessage);
      expect(session.logs.single.message, '認証主体のプロフィールが欠落しています');
      expect(session.logs.single.exception, isNull);
    });
  });

  group('想定外の失敗', () {
    test(
      'challenge は StateError を INTERNAL にし、認証例外と ApiException はそのまま返す',
      () async {
        final endpoint = ChallengeEndpoint();
        final request = ListChallengesRequest();
        var calls = 0;
        listChallengesExecuteForTest = () async {
          calls++;
          throw StateError(_secret);
        };
        await expectLater(
          endpoint.listChallenges(session, request),
          _internal(_secret),
        );
        expect(calls, 1);
        expect(session.logs.single.message, '出題処理に失敗しました: StateError');
        expect(session.logs.single.message, isNot(contains(_secret)));
        expect(session.logs.single.exception, isNull);
        expect(session.logs.single.stackTrace, isNotNull);
        expect(session.logs.single.level, LogLevel.error);

        session.logs.clear();
        listChallengesExecuteForTest = () async {
          throw const CorruptedDataException(
            entity: 'challenge',
            field: 'title',
            message: 'テスト用の壊れた値',
          );
        };
        await expectLater(
          endpoint.listChallenges(session, request),
          throwsA(
            isA<ApiException>()
                .having((e) => e.code, 'code', ApiErrorCode.internal)
                .having((e) => e.reason, 'reason', ApiErrorReasons.internal)
                .having((e) => e.message, 'message', '出題データを読み取れませんでした')
                .having(
                  (e) => e.message,
                  'message',
                  isNot(contains('テスト用の壊れた値')),
                ),
          ),
        );
        expect(session.logs.single.message, contains('テスト用の壊れた値'));

        session.logs.clear();
        listChallengesExecuteForTest = () async {
          throw ApiException(
            code: .notFound,
            reason: ApiErrorReasons.challengeNotFound,
            message: '指定された出題が見つかりません',
          );
        };
        await expectLater(
          endpoint.listChallenges(session, request),
          throwsA(
            isA<ApiException>()
                .having(
                  (e) => e.reason,
                  'reason',
                  ApiErrorReasons.challengeNotFound,
                )
                .having((e) => e.message, 'message', '指定された出題が見つかりません'),
          ),
        );
        expect(session.logs, isEmpty);

        listChallengesExecuteForTest = () async {
          throw NotAuthorizedException(reason: .unauthenticated);
        };
        await expectLater(
          endpoint.listChallenges(session, request),
          throwsA(isA<NotAuthorizedException>()),
        );
        expect(session.logs, isEmpty);
      },
    );

    test(
      'play は usecase の StateError を INTERNAL にし、PlayException は変換表を使う',
      () async {
        final endpoint = PlayEndpoint();
        final request = GetPlaySessionRequest(
          playSessionId: const Uuid().v4obj(),
        );
        var calls = 0;
        getPlaySessionExecuteForTest = (_, _) async {
          calls++;
          throw StateError(_secret);
        };
        await expectLater(
          endpoint.getPlaySession(session, request),
          _internal(_secret),
        );
        expect(calls, 1);
        expect(session.logs.single.message, 'プレイ処理に失敗しました: StateError');

        session.logs.clear();
        getPlaySessionExecuteForTest = (_, _) async {
          throw const PlayException(.notSessionOwner);
        };
        await expectLater(
          endpoint.getPlaySession(session, request),
          throwsA(
            isA<ApiException>()
                .having((e) => e.code, 'code', ApiErrorCode.permissionDenied)
                .having(
                  (e) => e.reason,
                  'reason',
                  ApiErrorReasons.notSessionOwner,
                )
                .having((e) => e.message, 'message', 'このプレイにはアクセスできません'),
          ),
        );
      },
    );

    test('ranking は usecase の StateError を INTERNAL にする', () async {
      var calls = 0;
      listRankingEntriesExecuteForTest = (_, _, _) async {
        calls++;
        throw StateError(_secret);
      };
      await expectLater(
        RankingEndpoint().listRankingEntries(
          session,
          ListRankingEntriesRequest(revisionId: 1, mode: .free),
        ),
        _internal(_secret),
      );
      expect(calls, 1);
      expect(session.logs.single.message, '順位処理に失敗しました: StateError');
    });

    test('profile は usecase の StateError を INTERNAL にする', () async {
      var calls = 0;
      getMyProfileExecuteForTest = (_) async {
        calls++;
        throw StateError(_secret);
      };
      await expectLater(
        ProfileEndpoint().getMyProfile(session, GetMyProfileRequest()),
        _internal(_secret),
      );
      expect(calls, 1);
      expect(session.logs.single.message, 'プロフィール処理に失敗しました: StateError');
    });
  });
}

Matcher _internal(String secret) => throwsA(
  isA<ApiException>()
      .having((e) => e.code, 'code', ApiErrorCode.internal)
      .having((e) => e.reason, 'reason', ApiErrorReasons.internal)
      .having((e) => e.message, 'message', '処理を完了できませんでした')
      .having((e) => e.message, 'message', isNot(contains(secret)))
      .having((e) => e.retryAfterSeconds, 'retryAfterSeconds', isNull)
      .having((e) => e.fieldViolations, 'fieldViolations', isNull),
);

class _Log(
  final String message,
  final LogLevel? level,
  final Object? exception,
  final StackTrace? stackTrace,
);

class _LoggingSession({
  @override required final AuthenticationInfo? authenticated,
}) implements Session {
  factory authenticated() {
    final id = const Uuid().v4();
    return _LoggingSession(
      authenticated: AuthenticationInfo(id, const {}, authId: id),
    );
  }

  final logs = <_Log>[];

  @override
  void log(
    String message, {
    LogLevel? level,
    dynamic exception,
    StackTrace? stackTrace,
    Map<String, Object?>? metadata,
  }) {
    logs.add(_Log(message, level, exception, stackTrace));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}
