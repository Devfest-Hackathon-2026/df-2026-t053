import 'package:photohunt_server/src/application/usecase/get_my_ranking_entry.dart';
import 'package:photohunt_server/src/application/usecase/list_ranking_entries.dart';
import 'package:photohunt_server/src/domain/exceptions.dart';
import 'package:photohunt_server/src/domain/models/ranked_score.dart';
import 'package:photohunt_server/src/domain/models/user_profile.dart';
import 'package:photohunt_server/src/domain/repositories/ranking_repository.dart';
import 'package:photohunt_server/src/domain/repositories/user_profile_repository.dart';
import 'package:photohunt_shared/photohunt_shared.dart' show PlayMode;
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

final userId = UuidValue.fromString('11111111-1111-4111-8111-111111111111');
final at = DateTime.utc(2026, 11, 9);

RankedScore row(int rank, int profileId) => RankedScore(
  rank: rank,
  userProfileId: profileId,
  nickname: '同じ名前',
  score: 900 - rank,
  achievedAt: at,
);

Matcher fails(RankingFailure reason) =>
    throwsA(isA<RankingException>().having((e) => e.reason, 'reason', reason));

void main() {
  late _Rankings rankings;
  late _Profiles profiles;
  late ListRankingEntries list;
  late GetMyRankingEntry get;
  setUp(() {
    rankings = _Rankings();
    profiles = _Profiles();
    list = ListRankingEntries(rankings, profiles);
    get = GetMyRankingEntry(rankings, profiles);
  });

  test('一覧は100件を要求し、名前ではなくIDで本人だけを識別する', () async {
    rankings.top = [row(1, 2), row(2, 1)];
    final result = await list.execute(userId, 12, .near);
    expect(rankings.limit, 100);
    expect(rankings.revisionId, 12);
    expect(rankings.mode, PlayMode.near);
    expect(result.map((r) => r.mine), [false, true]);
    expect(result.first.nickname, '同じ名前');
    expect(result.last.rank, 2);
    expect(result.last.achieveTime, at);
    expect(profiles.lastId, userId);
  });

  test('上位100件にいない本人も、その順位で返す', () async {
    rankings.mine = row(101, 1);
    final result = await get.execute(userId, 12, .free);
    expect(result.rank, 101);
    expect(result.mine, isTrue);
    expect(rankings.profileId, 1);
    expect(rankings.revisionId, 12);
    expect(rankings.mode, PlayMode.free);
  });

  test('空一覧は成功し、本人の記録なしは専用の失敗にする', () async {
    expect(await list.execute(userId, 12, .free), isEmpty);
    await expectLater(get.execute(userId, 12, .free), fails(.entryNotFound));
  });

  for (final mine in [false, true]) {
    test('${mine ? '本人' : '一覧'}: unknownはDBへアクセスする前に拒否する', () async {
      await expectLater(
        mine
            ? get.execute(userId, 12, .unknown)
            : list.execute(userId, 12, .unknown),
        fails(.invalidRequest),
      );
      expect(rankings.lookups, 0);
      expect(profiles.reads, 0);
    });

    test('${mine ? '本人' : '一覧'}: 未存在の版を空のランキングと混同しない', () async {
      rankings.exists = false;
      await expectLater(
        mine
            ? get.execute(userId, 999, .free)
            : list.execute(userId, 999, .free),
        fails(.revisionNotFound),
      );
      expect(rankings.lookups, 1);
      expect(profiles.reads, 0);
    });

    test('${mine ? '本人' : '一覧'}: プロフィール欠落を作成や記録なしで隠さない', () async {
      profiles.row = null;
      await expectLater(
        mine ? get.execute(userId, 12, .free) : list.execute(userId, 12, .free),
        fails(.profileNotInitialized),
      );
      expect(rankings.lookups, 1);
      expect(profiles.reads, 1);
    });
  }
}

class _Rankings() implements RankingRepository {
  bool exists = true;
  List<RankedScore> top = [];
  RankedScore? mine;
  int lookups = 0;
  int? limit, revisionId, profileId;
  PlayMode? mode;
  @override
  Future<bool> publishedRevisionExists(int id) async {
    lookups++;
    return exists;
  }

  @override
  Future<List<RankedScore>> listTop({
    required int revisionId,
    required PlayMode mode,
    required int limit,
  }) async {
    lookups++;
    this.limit = limit;
    this.revisionId = revisionId;
    this.mode = mode;
    return top;
  }

  @override
  Future<RankedScore?> findMine({
    required int revisionId,
    required PlayMode mode,
    required int userProfileId,
  }) async {
    lookups++;
    this.revisionId = revisionId;
    this.mode = mode;
    profileId = userProfileId;
    return mine;
  }
}

class _Profiles() implements UserProfileRepository {
  UserProfile? row = UserProfile(
    id: 1,
    authUserId: userId,
    nickname: '本人',
    createdAt: at,
  );
  var reads = 0;
  UuidValue? lastId;
  @override
  Future<UserProfile?> findByAuthUserId(UuidValue id) async {
    reads++;
    lastId = id;
    return row;
  }

  @override
  Future<UserProfile> insert(UserProfile profile) =>
      throw StateError('読み取りで作成しない');
  @override
  Future<UserProfile?> updateNickname(int id, String nickname) =>
      throw StateError('読み取りで改名しない');
}
