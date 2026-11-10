import 'package:photohunt_shared/photohunt_shared.dart';

import '../../support/api_client.dart';

class TestProfiles() {
  Future<Profile> Function() load = () async =>
      Profile(nickname: '旅人0042', anonymous: true);
  Future<Profile> Function(String) save = (name) async =>
      Profile(nickname: name, anonymous: true);
  TestApiClient get client => TestApiClient(
    getProfile: (_) => getMyProfile(),
    setNickname: (request) => updateNickname(request.nickname),
    refreshAuthentication: () async {},
  );

  var loads = 0;
  final saves = <String>[];

  Future<Profile> getMyProfile() {
    loads++;
    return load();
  }

  Future<Profile> updateNickname(String nickname) {
    saves.add(nickname);
    return save(nickname);
  }
}
