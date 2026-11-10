import 'dart:io';

import 'package:photohunt_client/photohunt_client.dart';
import 'package:photohunt_server/server.dart';
import 'package:photohunt_server/src/generated/protocol.dart'
    show UserProfileRow, ShotRow;
import 'package:photohunt_server/src/infrastructure/database/repositories/orm_user_profile_repository.dart';
import 'package:serverpod/serverpod.dart' show Serverpod;
import 'package:serverpod_client/serverpod_client.dart';
import 'package:test/test.dart';

import 'database/ranking_support.dart';
import 'database/support.dart' show Fixture, insertFixture, insertProfile;

class _BearerProvider() implements ClientAuthKeyProvider {
  String? token;
  @override
  Future<String?> get authHeaderValue async {
    final value = token;
    return value == null ? null : wrapAsBearerAuthHeaderValue(value);
  }
}

Matcher apiFailure(ApiErrorCode code, String reason) => throwsA(
  isA<ApiException>()
      .having((e) => e.code, 'code', code)
      .having((e) => e.reason, 'reason', reason),
);

void main() {
  late Serverpod pod;
  late Client client;
  late Fixture fixture;
  late String ownerToken;
  final auth = _BearerProvider();
  ShotRow? originalShot;

  setUpAll(() async {
    for (final suffix in ['', '-wal', '-shm']) {
      final file = File('data/test.sqlite$suffix');
      if (file.existsSync()) file.deleteSync();
    }
    pod = createServer(['--mode', 'test', '--apply-migrations']);
    await pod.start();
    client = Client('http://localhost:8180/')..authKeyProvider = auth;
    await pod.withSession((session) async {
      fixture = await insertFixture(session);
      await publishFixture(session, fixture);
    });
  });

  tearDownAll(() async {
    client.close();
    await pod.shutdown(exitProcess: false);
  });

  test('両メソッドを生成Clientから呼び、未認証なら標準の例外で拒否する', () async {
    await expectLater(
      client.ranking.listRankingEntries(
        ListRankingEntriesRequest(
          revisionId: fixture.revision.id!,
          mode: .free,
        ),
      ),
      throwsA(isA<ServerpodClientUnauthorized>()),
    );
    await expectLater(
      client.ranking.getMyRankingEntry(
        GetMyRankingEntryRequest(revisionId: fixture.revision.id!, mode: .free),
      ),
      throwsA(isA<ServerpodClientUnauthorized>()),
    );
  });

  test('プロフィール欠落は専用の型付き例外で返し、読取で復旧しない', () async {
    final success = await client.anonymousIdp.login();
    ownerToken = success.token;
    auth.token = ownerToken;
    // #25の認証フローがプロフィールを初期化する構成でも、欠落を明示的に再現する。
    await pod.withSession((s) async {
      await UserProfileRow.db.deleteWhere(
        s,
        where: (t) => t.authUserId.equals(success.authUserId),
      );
    });
    for (final action in <Future<Object> Function()>[
      () => client.ranking.listRankingEntries(
        ListRankingEntriesRequest(
          revisionId: fixture.revision.id!,
          mode: .free,
        ),
      ),
      () => client.ranking.getMyRankingEntry(
        GetMyRankingEntryRequest(revisionId: fixture.revision.id!, mode: .free),
      ),
    ]) {
      await expectLater(
        action(),
        throwsA(
          isA<ApiException>()
              .having((e) => e.code, 'code', ApiErrorCode.failedPrecondition)
              .having(
                (e) => e.reason,
                'reason',
                ApiErrorReasons.profileNotInitialized,
              )
              .having((e) => e.retryAfterSeconds, 'retryAfterSeconds', isNull),
        ),
      );
    }
    await pod.withSession((s) async {
      expect(
        await UserProfileRow.db.count(
          s,
          where: (t) => t.authUserId.equals(success.authUserId),
        ),
        0,
      );
      // #29を待たず、既存DB制約を満たす保存済みの記録をfixtureで用意する。
      await UserProfileRow.db.updateRow(
        s,
        fixture.profile.copyWith(
          authUserId: success.authUserId,
          nickname: '本人',
        ),
        columns: (t) => [t.authUserId, t.nickname],
      );
      originalShot = await insertRankedScore(s, fixture, score: 900);
      final other = await insertProfile(s);
      await insertRankedScore(s, fixture, profile: other, score: 950);
    });
  });

  test('本人だけmine=trueで返し、公開JSONには内部IDを含めない', () async {
    final response = await client.ranking.listRankingEntries(
      ListRankingEntriesRequest(revisionId: fixture.revision.id!, mode: .free),
    );
    expect(response.entries.map((e) => e.rank), [1, 2]);
    expect(response.entries.map((e) => e.mine), [false, true]);
    final mine = await client.ranking.getMyRankingEntry(
      GetMyRankingEntryRequest(revisionId: fixture.revision.id!, mode: .free),
    );
    expect(mine.rank, 2);
    expect(mine.nickname, '本人');
    expect(mine.score, 900);
    expect(mine.achieveTime.isUtc, isTrue);
    for (final row in [...response.entries, mine]) {
      expect(row.toJson().keys.toSet(), {
        '__className__',
        'rank',
        'nickname',
        'score',
        'achieveTime',
        'mine',
      });
    }
  });

  test('未記録のモードは空一覧とRANKING_ENTRY_NOT_FOUNDで返す', () async {
    final response = await client.ranking.listRankingEntries(
      ListRankingEntriesRequest(revisionId: fixture.revision.id!, mode: .near),
    );
    expect(response.entries, isEmpty);
    await expectLater(
      client.ranking.getMyRankingEntry(
        GetMyRankingEntryRequest(revisionId: fixture.revision.id!, mode: .near),
      ),
      apiFailure(.notFound, ApiErrorReasons.rankingEntryNotFound),
    );
  });

  test('unknownモードと未存在の版を型付きエラーで返す', () async {
    for (final mode in [PlayMode.free, PlayMode.unknown]) {
      for (final action in <Future<Object> Function()>[
        () => client.ranking.listRankingEntries(
          ListRankingEntriesRequest(revisionId: 999999, mode: mode),
        ),
        () => client.ranking.getMyRankingEntry(
          GetMyRankingEntryRequest(revisionId: 999999, mode: mode),
        ),
      ]) {
        await expectLater(
          action(),
          mode == .unknown
              ? apiFailure(.invalidArgument, ApiErrorReasons.invalidRequest)
              : apiFailure(.notFound, ApiErrorReasons.revisionNotFound),
        );
      }
    }
  });

  test('下書きの版は、存在を公開せず未存在の版と同じエラーで返す', () async {
    final draftRevisionId = await pod.withSession(
      (session) async => (await insertFixture(session)).revision.id!,
    );
    await expectLater(
      client.ranking.listRankingEntries(
        ListRankingEntriesRequest(revisionId: draftRevisionId, mode: .free),
      ),
      apiFailure(.notFound, ApiErrorReasons.revisionNotFound),
    );
    await expectLater(
      client.ranking.getMyRankingEntry(
        GetMyRankingEntryRequest(revisionId: draftRevisionId, mode: .free),
      ),
      apiFailure(.notFound, ApiErrorReasons.revisionNotFound),
    );
  });

  test('別の認証主体の本人Getに元の利用者の記録を返さない', () async {
    final unauthenticated = Client('http://localhost:8180/');
    final other = await unauthenticated.anonymousIdp.login().whenComplete(
      unauthenticated.close,
    );
    await pod.withSession((s) async {
      if (await UserProfileRow.db.count(
            s,
            where: (t) => t.authUserId.equals(other.authUserId),
          ) ==
          0) {
        await insertProfile(s, authUserId: other.authUserId);
      }
    });
    auth.token = other.token;
    try {
      await expectLater(
        client.ranking.getMyRankingEntry(
          GetMyRankingEntryRequest(
            revisionId: fixture.revision.id!,
            mode: .free,
          ),
        ),
        apiFailure(.notFound, ApiErrorReasons.rankingEntryNotFound),
      );
      final response = await client.ranking.listRankingEntries(
        ListRankingEntriesRequest(
          revisionId: fixture.revision.id!,
          mode: .free,
        ),
      );
      expect(response.entries.every((e) => !e.mine), isTrue);
    } finally {
      auth.token = ownerToken;
    }
  });

  test('名前変更はListと本人Getに反映し、撮影結果の行は変えない', () async {
    final shot = originalShot;
    if (shot == null) fail('保存済み撮影が必要です');
    await pod.withSession((s) async {
      await OrmUserProfileRepository(s)
          .updateNickname(fixture.profile.id!, '現在の名前');
    });
    final list = await client.ranking.listRankingEntries(
      ListRankingEntriesRequest(revisionId: fixture.revision.id!, mode: .free),
    );
    expect(list.entries.singleWhere((e) => e.mine).nickname, '現在の名前');
    final mine = await client.ranking.getMyRankingEntry(
      GetMyRankingEntryRequest(revisionId: fixture.revision.id!, mode: .free),
    );
    expect(mine.nickname, '現在の名前');
    await pod.withSession((s) async {
      expect((await ShotRow.db.findById(s, shot.id!))?.toJson(), shot.toJson());
    });
  });
}
