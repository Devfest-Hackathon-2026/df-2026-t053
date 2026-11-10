import 'package:flutter_test/flutter_test.dart';
import 'package:photohunt_client/photohunt_client.dart';
import 'package:serverpod_auth_core_flutter/serverpod_auth_core_flutter.dart';

/// 未設定のendpointを呼んだ場合の既定動作。偽の成功を作らない。
Future<T> _unset<T>(Object? request) => throw StateError('テストダブルが未設定です');

Future<AuthSuccess> _unsetLogin() => throw StateError('テストダブルが未設定です');

/// 生成Clientの公開インターフェースを差し替えるテストダブル。
class TestApiClient extends Fake implements Client {
  TestApiClient({
    required Future<Profile> Function(GetMyProfileRequest) getProfile,
    required Future<Profile> Function(UpdateNicknameRequest) setNickname,
    required Future<void> Function() refreshAuthentication,
    Future<ListChallengesResponse> Function(ListChallengesRequest)?
    listChallenges,
    Future<Challenge> Function(GetChallengeRequest)? getChallenge,
    Future<ChallengeRevision> Function(GetChallengeRevisionRequest)?
    getChallengeRevision,
    Future<PlaySession> Function(CreatePlaySessionRequest)? createPlaySession,
    Future<SubmitShotResponse> Function(SubmitShotRequest)? submitShot,
    Future<PlaySession> Function(GetPlaySessionRequest)? getPlaySession,
    Future<AuthSuccess> Function()? login,
    Future<HealthResponse> Function(HealthRequest)? ping,
    Stream<NearbyGuideEvent> Function(ExplainNearbyRequest)? explainNearby,
    Future<ListRankingEntriesResponse> Function(ListRankingEntriesRequest)?
    listRanking,
    Future<RankingEntry> Function(GetMyRankingEntryRequest)? myRanking,
  }) : health = TestHealthEndpoint(ping ?? _unset),
       guide = TestGuideEndpoint(explainNearby),
       ranking = TestRankingEndpoint(
         listRanking ?? _unset,
         myRanking ?? _unset,
       ),
       profile = TestProfileEndpoint(getProfile, setNickname),
       challenge = TestChallengeEndpoint(
         listChallenges ?? _unset,
         getChallenge ?? _unset,
         getChallengeRevision ?? _unset,
       ),
       play = TestPlayEndpoint(
         createPlaySession ?? _unset,
         submitShot ?? _unset,
         getPlaySession ?? _unset,
       ),
       anonymousIdp = TestAnonymousIdpEndpoint(login ?? _unsetLogin),
       authKeyProvider = TestAuthentication(refreshAuthentication);

  @override
  final EndpointHealth health;

  @override
  final EndpointGuide guide;

  @override
  final EndpointRanking ranking;

  @override
  final EndpointProfile profile;

  @override
  final EndpointChallenge challenge;

  @override
  final EndpointPlay play;

  @override
  final EndpointAnonymousIdp anonymousIdp;

  @override
  ClientAuthKeyProvider? authKeyProvider;
}

class TestProfileEndpoint(
  final Future<Profile> Function(GetMyProfileRequest) load,
  final Future<Profile> Function(UpdateNicknameRequest) save,
) extends Fake implements EndpointProfile {
  @override
  Future<Profile> getMyProfile(GetMyProfileRequest request) => load(request);

  @override
  Future<Profile> updateNickname(UpdateNicknameRequest request) =>
      save(request);
}

class TestChallengeEndpoint(
  final Future<ListChallengesResponse> Function(ListChallengesRequest) list,
  final Future<Challenge> Function(GetChallengeRequest) get,
  final Future<ChallengeRevision> Function(GetChallengeRevisionRequest)
  getRevision,
) extends Fake implements EndpointChallenge {
  @override
  Future<ListChallengesResponse> listChallenges(
    ListChallengesRequest request,
  ) => list(request);

  @override
  Future<Challenge> getChallenge(GetChallengeRequest request) => get(request);

  @override
  Future<ChallengeRevision> getChallengeRevision(
    GetChallengeRevisionRequest request,
  ) => getRevision(request);
}

class TestPlayEndpoint(
  final Future<PlaySession> Function(CreatePlaySessionRequest) create,
  final Future<SubmitShotResponse> Function(SubmitShotRequest) submit,
  final Future<PlaySession> Function(GetPlaySessionRequest) get,
) extends Fake implements EndpointPlay {
  @override
  Future<PlaySession> createPlaySession(CreatePlaySessionRequest request) =>
      create(request);

  @override
  Future<SubmitShotResponse> submitShot(SubmitShotRequest request) =>
      submit(request);

  @override
  Future<PlaySession> getPlaySession(GetPlaySessionRequest request) =>
      get(request);
}

class TestAnonymousIdpEndpoint(final Future<AuthSuccess> Function() loginImpl)
    extends Fake
    implements EndpointAnonymousIdp {
  @override
  Future<AuthSuccess> login({String? token}) => loginImpl();
}

class TestAuthentication(final Future<void> Function() refresh)
    implements RefresherClientAuthKeyProvider {
  @override
  Future<String?> get authHeaderValue async => 'Bearer test-only';

  @override
  Future<RefreshAuthKeyResult> refreshAuthKey({bool force = false}) async {
    expect(force, isTrue);
    await refresh();
    return .success;
  }
}

class TestHealthEndpoint(
  final Future<HealthResponse> Function(HealthRequest) call,
) extends Fake implements EndpointHealth {
  @override
  Future<HealthResponse> ping(HealthRequest request) => call(request);
}

class TestGuideEndpoint(
  final Stream<NearbyGuideEvent> Function(ExplainNearbyRequest)? explain,
) extends Fake implements EndpointGuide {
  @override
  Stream<NearbyGuideEvent> explainNearby(ExplainNearbyRequest request) {
    final call = explain;
    if (call == null) throw StateError('テストダブルが未設定です');
    return call(request);
  }
}

class TestRankingEndpoint(
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
