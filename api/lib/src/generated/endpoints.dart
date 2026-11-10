/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:photohunt_shared/photohunt_shared.dart' as _ix5zeh3i;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;

import '../presentation/endpoints/anonymous_idp_endpoint.dart' as _iu7ss4ge;
import '../presentation/endpoints/challenge_endpoint.dart' as _ii0t45ej;
import '../presentation/endpoints/guide_endpoint.dart' as _iq7cz1o1;
import '../presentation/endpoints/health_endpoint.dart' as _i8c057yn;
import '../presentation/endpoints/jwt_refresh_endpoint.dart' as _iqinjkcs;
import '../presentation/endpoints/pavilion_endpoint.dart' as _icr3ugjj;
import '../presentation/endpoints/play_endpoint.dart' as _iz32zu55;
import '../presentation/endpoints/profile_endpoint.dart' as _ijv7ldi1;
import '../presentation/endpoints/ranking_endpoint.dart' as _ijzln7sj;

class Endpoints extends _is.EndpointDispatch {
  @override
  void initializeEndpoints(_is.Server server) {
    var endpoints = <String, _is.Endpoint>{
      'anonymousIdp': _iu7ss4ge.AnonymousIdpEndpoint()
        ..initialize(server, 'anonymousIdp', null),
      'challenge': _ii0t45ej.ChallengeEndpoint()
        ..initialize(server, 'challenge', null),
      'guide': _iq7cz1o1.GuideEndpoint()..initialize(server, 'guide', null),
      'health': _i8c057yn.HealthEndpoint()..initialize(server, 'health', null),
      'jwtRefresh': _iqinjkcs.JwtRefreshEndpoint()
        ..initialize(server, 'jwtRefresh', null),
      'pavilion': _icr3ugjj.PavilionEndpoint()
        ..initialize(server, 'pavilion', null),
      'play': _iz32zu55.PlayEndpoint()..initialize(server, 'play', null),
      'profile': _ijv7ldi1.ProfileEndpoint()
        ..initialize(server, 'profile', null),
      'ranking': _ijzln7sj.RankingEndpoint()
        ..initialize(server, 'ranking', null),
    };
    connectors['anonymousIdp'] = _is.EndpointConnector(
      name: 'anonymousIdp',
      endpoint: endpoints['anonymousIdp']!,
      methodConnectors: {
        'login': _is.MethodConnector(
          name: 'login',
          params: {
            'token': _is.ParameterDescription(
              name: 'token',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['anonymousIdp'] as _iu7ss4ge.AnonymousIdpEndpoint)
                  .login(session, token: params['token']),
        ),
      },
    );
    connectors['challenge'] = _is.EndpointConnector(
      name: 'challenge',
      endpoint: endpoints['challenge']!,
      methodConnectors: {
        'listChallenges': _is.MethodConnector(
          name: 'listChallenges',
          params: {
            'request': _is.ParameterDescription(
              name: 'request',
              type: _is.getType<_ix5zeh3i.ListChallengesRequest>(),
              nullable: false,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['challenge'] as _ii0t45ej.ChallengeEndpoint)
                  .listChallenges(session, params['request']),
        ),
        'getChallenge': _is.MethodConnector(
          name: 'getChallenge',
          params: {
            'request': _is.ParameterDescription(
              name: 'request',
              type: _is.getType<_ix5zeh3i.GetChallengeRequest>(),
              nullable: false,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['challenge'] as _ii0t45ej.ChallengeEndpoint)
                  .getChallenge(session, params['request']),
        ),
        'getChallengeRevision': _is.MethodConnector(
          name: 'getChallengeRevision',
          params: {
            'request': _is.ParameterDescription(
              name: 'request',
              type: _is.getType<_ix5zeh3i.GetChallengeRevisionRequest>(),
              nullable: false,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['challenge'] as _ii0t45ej.ChallengeEndpoint)
                  .getChallengeRevision(session, params['request']),
        ),
      },
    );
    connectors['guide'] = _is.EndpointConnector(
      name: 'guide',
      endpoint: endpoints['guide']!,
      methodConnectors: {
        'explainNearby': _is.MethodStreamConnector(
          name: 'explainNearby',
          params: {
            'request': _is.ParameterDescription(
              name: 'request',
              type: _is.getType<_ix5zeh3i.ExplainNearbyRequest>(),
              nullable: false,
            ),
          },
          streamParams: {},
          returnType: _is.MethodStreamReturnType.streamType,
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['guide'] as _iq7cz1o1.GuideEndpoint)
                  .explainNearby(session, params['request']),
        ),
      },
    );
    connectors['health'] = _is.EndpointConnector(
      name: 'health',
      endpoint: endpoints['health']!,
      methodConnectors: {
        'ping': _is.MethodConnector(
          name: 'ping',
          params: {
            'request': _is.ParameterDescription(
              name: 'request',
              type: _is.getType<_ix5zeh3i.HealthRequest>(),
              nullable: false,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['health'] as _i8c057yn.HealthEndpoint).ping(
                session,
                params['request'],
              ),
        ),
      },
    );
    connectors['jwtRefresh'] = _is.EndpointConnector(
      name: 'jwtRefresh',
      endpoint: endpoints['jwtRefresh']!,
      methodConnectors: {
        'refreshAccessToken': _is.MethodConnector(
          name: 'refreshAccessToken',
          params: {
            'refreshToken': _is.ParameterDescription(
              name: 'refreshToken',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['jwtRefresh'] as _iqinjkcs.JwtRefreshEndpoint)
                  .refreshAccessToken(
                    session,
                    refreshToken: params['refreshToken'],
                  ),
        ),
      },
    );
    connectors['pavilion'] = _is.EndpointConnector(
      name: 'pavilion',
      endpoint: endpoints['pavilion']!,
      methodConnectors: {
        'listPavilions': _is.MethodConnector(
          name: 'listPavilions',
          params: {},
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['pavilion'] as _icr3ugjj.PavilionEndpoint)
                  .listPavilions(session),
        ),
      },
    );
    connectors['play'] = _is.EndpointConnector(
      name: 'play',
      endpoint: endpoints['play']!,
      methodConnectors: {
        'createPlaySession': _is.MethodConnector(
          name: 'createPlaySession',
          params: {
            'request': _is.ParameterDescription(
              name: 'request',
              type: _is.getType<_ix5zeh3i.CreatePlaySessionRequest>(),
              nullable: false,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['play'] as _iz32zu55.PlayEndpoint).createPlaySession(
                session,
                params['request'],
              ),
        ),
        'submitShot': _is.MethodConnector(
          name: 'submitShot',
          params: {
            'request': _is.ParameterDescription(
              name: 'request',
              type: _is.getType<_ix5zeh3i.SubmitShotRequest>(),
              nullable: false,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['play'] as _iz32zu55.PlayEndpoint).submitShot(
                session,
                params['request'],
              ),
        ),
        'getPlaySession': _is.MethodConnector(
          name: 'getPlaySession',
          params: {
            'request': _is.ParameterDescription(
              name: 'request',
              type: _is.getType<_ix5zeh3i.GetPlaySessionRequest>(),
              nullable: false,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['play'] as _iz32zu55.PlayEndpoint).getPlaySession(
                session,
                params['request'],
              ),
        ),
      },
    );
    connectors['profile'] = _is.EndpointConnector(
      name: 'profile',
      endpoint: endpoints['profile']!,
      methodConnectors: {
        'getMyProfile': _is.MethodConnector(
          name: 'getMyProfile',
          params: {
            'request': _is.ParameterDescription(
              name: 'request',
              type: _is.getType<_ix5zeh3i.GetMyProfileRequest>(),
              nullable: false,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['profile'] as _ijv7ldi1.ProfileEndpoint).getMyProfile(
                session,
                params['request'],
              ),
        ),
        'updateNickname': _is.MethodConnector(
          name: 'updateNickname',
          params: {
            'request': _is.ParameterDescription(
              name: 'request',
              type: _is.getType<_ix5zeh3i.UpdateNicknameRequest>(),
              nullable: false,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['profile'] as _ijv7ldi1.ProfileEndpoint)
                  .updateNickname(session, params['request']),
        ),
      },
    );
    connectors['ranking'] = _is.EndpointConnector(
      name: 'ranking',
      endpoint: endpoints['ranking']!,
      methodConnectors: {
        'listRankingEntries': _is.MethodConnector(
          name: 'listRankingEntries',
          params: {
            'request': _is.ParameterDescription(
              name: 'request',
              type: _is.getType<_ix5zeh3i.ListRankingEntriesRequest>(),
              nullable: false,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['ranking'] as _ijzln7sj.RankingEndpoint)
                  .listRankingEntries(session, params['request']),
        ),
        'getMyRankingEntry': _is.MethodConnector(
          name: 'getMyRankingEntry',
          params: {
            'request': _is.ParameterDescription(
              name: 'request',
              type: _is.getType<_ix5zeh3i.GetMyRankingEntryRequest>(),
              nullable: false,
            ),
          },
          call: (_is.Session session, Map<String, dynamic> params) async =>
              (endpoints['ranking'] as _ijzln7sj.RankingEndpoint)
                  .getMyRankingEntry(session, params['request']),
        ),
      },
    );
    modules['serverpod_auth_idp'] = _iais.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _iacs.Endpoints()
      ..initializeEndpoints(server);
  }
}
