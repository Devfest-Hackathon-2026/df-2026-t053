import 'package:flutter_test/flutter_test.dart';
import 'package:photohunt_client/photohunt_client.dart';
import 'package:serverpod_client/serverpod_client.dart';

RankingEntry entry({
  int rank = 1,
  int score = 900,
  String name = '旅人',
  bool mine = false,
}) => RankingEntry(
  rank: rank,
  nickname: name,
  score: score,
  achieveTime: DateTime.utc(2026, 11, 9, 8),
  mine: mine,
);

ApiException noEntry() => ApiException(
  code: .notFound,
  reason: ApiErrorReasons.rankingEntryNotFound,
  message: '内部情報',
);

class TestRankings() {
  Future<ListChallengesResponse> Function() challenges = () async =>
      ListChallengesResponse(
        challenges: [Challenge(id: 1, title: '広場', currentRevisionId: 7)],
      );
  Future<ListRankingEntriesResponse> Function(ListRankingEntriesRequest) list =
      (_) async => ListRankingEntriesResponse(entries: [entry()]);
  Future<RankingEntry> Function(GetMyRankingEntryRequest) mine = (_) async =>
      entry(rank: 101, mine: true);
  final lists = <ListRankingEntriesRequest>[];
  final gets = <GetMyRankingEntryRequest>[];
  int challengeCalls = 0;
  int refreshes = 0;
  final forceRefreshes = <bool>[];
  Future<void> Function() refresh = () async {};

  late final Client client = RankingTestClient(
    ranking: RankingTestEndpoint(
      (request) {
        lists.add(request);
        return list(request);
      },
      (request) {
        gets.add(request);
        return mine(request);
      },
    ),
    challenge: ChallengeTestEndpoint(() {
      challengeCalls++;
      return challenges();
    }),
    authKeyProvider: RankingTestAuthentication((force) {
      forceRefreshes.add(force);
      refreshes++;
      return refresh();
    }),
  );
}

class RankingTestAuthentication(final Future<void> Function(bool) refresh)
    implements RefresherClientAuthKeyProvider {
  @override
  Future<String?> get authHeaderValue async => 'Bearer test-only';

  @override
  Future<RefreshAuthKeyResult> refreshAuthKey({bool force = false}) async {
    await refresh(force);
    return .success;
  }
}

class RankingTestClient({
  @override required final EndpointRanking ranking,
  @override required final EndpointChallenge challenge,
  required this.authKeyProvider,
}) extends Fake implements Client {
  @override
  ClientAuthKeyProvider? authKeyProvider;
}

class RankingTestEndpoint(
  final Future<ListRankingEntriesResponse> Function(ListRankingEntriesRequest)
  list,
  final Future<RankingEntry> Function(GetMyRankingEntryRequest) mine,
) extends Fake implements EndpointRanking {
  @override
  Future<ListRankingEntriesResponse> listRankingEntries(
    ListRankingEntriesRequest request,
  ) => list(request);
  @override
  Future<RankingEntry> getMyRankingEntry(GetMyRankingEntryRequest request) =>
      mine(request);
}

class ChallengeTestEndpoint(
  final Future<ListChallengesResponse> Function() list,
) extends Fake implements EndpointChallenge {
  @override
  Future<ListChallengesResponse> listChallenges(
    ListChallengesRequest request,
  ) => list();
}
