import 'package:serverpod_auth_idp_server/core.dart';

import '../di/profile_dependencies.dart';

/// JWT の更新。client が自動更新に使う。
class JwtRefreshEndpoint() extends RefreshJwtTokensEndpoint {
  /// 親の `jwt` を、プロフィールを復旧する実装で包む（初回の参照で 1 回だけ作る）。
  late final Jwt _repairingJwt = profileRepairingJwt(super.jwt);

  @override
  Jwt get jwt => _repairingJwt;
}
