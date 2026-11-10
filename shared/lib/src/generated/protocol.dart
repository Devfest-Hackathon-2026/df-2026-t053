/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:photohunt_shared/photohunt_shared.dart' as _ix5zeh3i;
import 'package:serverpod_serialization/serverpod_serialization.dart' as _iss;

import 'api_error_code.dart' as _i8kzjahn;
import 'api_exception.dart' as _iozummgq;
import 'asset_ref.dart' as _ibtyf05g;
import 'camera_pose.dart' as _inm2mhm8;
import 'challenge.dart' as _ijvmy76x;
import 'challenge_revision.dart' as _iwkiidn3;
import 'credit.dart' as _iiocvpzn;
import 'field_violation.dart' as _i8gcykjk;
import 'guide/guide_audio_unavailable_reason.dart' as _i6neeqzq;
import 'guide/nearby_guide_event.dart' as _iwx3qa7h;
import 'guide_source.dart' as _ieaxfcpn;
import 'health_request.dart' as _i870j7w2;
import 'health_response.dart' as _i50lwsk9;
import 'landmark.dart' as _iukl7gif;
import 'map_bounds.dart' as _i0agetmq;
import 'mode_config.dart' as _ie1t35ud;
import 'pavilion.dart' as _i5gqoy0o;
import 'play_mode.dart' as _ixcvq5ql;
import 'play_session.dart' as _ivpttrnq;
import 'play_session_state.dart' as _izjuizqd;
import 'point_xz.dart' as _i0oipb17;
import 'profile.dart' as _ilz0o8l0;
import 'ranking_entry.dart' as _iy2yc34w;
import 'requests/create_play_session_request.dart' as _i6xpafdb;
import 'requests/explain_nearby_request.dart' as _illo5yhi;
import 'requests/get_challenge_request.dart' as _ik98l12b;
import 'requests/get_challenge_revision_request.dart' as _ivte9ub5;
import 'requests/get_my_profile_request.dart' as _ifeazbqt;
import 'requests/get_my_ranking_entry_request.dart' as _ij6onplx;
import 'requests/get_play_session_request.dart' as _i7t9l4ob;
import 'requests/list_challenges_request.dart' as _i46bkuwv;
import 'requests/list_ranking_entries_request.dart' as _i8ubv3an;
import 'requests/submit_shot_request.dart' as _i5ic124w;
import 'requests/update_nickname_request.dart' as _ifze6cum;
import 'responses/list_challenges_response.dart' as _i6xqk9zj;
import 'responses/list_pavilions_response.dart' as _iqez2ob1;
import 'responses/list_ranking_entries_response.dart' as _ib5ytboh;
import 'responses/submit_shot_response.dart' as _ih9nnssc;
import 'reveal.dart' as _i9h2gfpa;
import 'shot.dart' as _ikzltuid;
import 'shot_input.dart' as _iwq2300m;
import 'spawn.dart' as _itlkswb8;
import 'spawn_entrance.dart' as _iba18tzr;
import 'venue_map.dart' as _i49z0bdd;
import 'walkable_area.dart' as _ieu1nkpc;
export 'api_error_code.dart';
export 'api_exception.dart';
export 'asset_ref.dart';
export 'camera_pose.dart';
export 'challenge.dart';
export 'challenge_revision.dart';
export 'credit.dart';
export 'field_violation.dart';
export 'guide/guide_audio_unavailable_reason.dart';
export 'guide/nearby_guide_event.dart';
export 'guide_source.dart';
export 'health_request.dart';
export 'health_response.dart';
export 'landmark.dart';
export 'map_bounds.dart';
export 'mode_config.dart';
export 'pavilion.dart';
export 'play_mode.dart';
export 'play_session.dart';
export 'play_session_state.dart';
export 'point_xz.dart';
export 'profile.dart';
export 'ranking_entry.dart';
export 'requests/create_play_session_request.dart';
export 'requests/explain_nearby_request.dart';
export 'requests/get_challenge_request.dart';
export 'requests/get_challenge_revision_request.dart';
export 'requests/get_my_profile_request.dart';
export 'requests/get_my_ranking_entry_request.dart';
export 'requests/get_play_session_request.dart';
export 'requests/list_challenges_request.dart';
export 'requests/list_ranking_entries_request.dart';
export 'requests/submit_shot_request.dart';
export 'requests/update_nickname_request.dart';
export 'responses/list_challenges_response.dart';
export 'responses/list_pavilions_response.dart';
export 'responses/list_ranking_entries_response.dart';
export 'responses/submit_shot_response.dart';
export 'reveal.dart';
export 'shot.dart';
export 'shot_input.dart';
export 'spawn.dart';
export 'spawn_entrance.dart';
export 'venue_map.dart';
export 'walkable_area.dart';

class Protocol extends _iss.SerializationManager
    implements _iss.ProtocolDeserializationProvider {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  final Set<_iss.SerializationManager> _hostProtocols = {};

  @override
  _iss.ProtocolDeserialization get deserializationMetadata =>
      _iss.ProtocolDeserialization.cached(
        this,
        types: const [
          _iss.getType<_i8kzjahn.ApiErrorCode>,
          _iss.getType<_iozummgq.ApiException>,
          _iss.getType<_ibtyf05g.AssetRef>,
          _iss.getType<_inm2mhm8.CameraPose>,
          _iss.getType<_ijvmy76x.Challenge>,
          _iss.getType<_iwkiidn3.ChallengeRevision>,
          _iss.getType<_iiocvpzn.Credit>,
          _iss.getType<_i8gcykjk.FieldViolation>,
          _iss.getType<_iwx3qa7h.GuideAudioChunk>,
          _iss.getType<_iwx3qa7h.GuideAudioUnavailable>,
          _iss.getType<_i6neeqzq.GuideAudioUnavailableReason>,
          _iss.getType<_iwx3qa7h.GuideText>,
          _iss.getType<_ieaxfcpn.GuideSource>,
          _iss.getType<_i870j7w2.HealthRequest>,
          _iss.getType<_i50lwsk9.HealthResponse>,
          _iss.getType<_iukl7gif.Landmark>,
          _iss.getType<_i0agetmq.MapBounds>,
          _iss.getType<_ie1t35ud.ModeConfig>,
          _iss.getType<_i5gqoy0o.Pavilion>,
          _iss.getType<_ixcvq5ql.PlayMode>,
          _iss.getType<_ivpttrnq.PlaySession>,
          _iss.getType<_izjuizqd.PlaySessionState>,
          _iss.getType<_i0oipb17.PointXZ>,
          _iss.getType<_ilz0o8l0.Profile>,
          _iss.getType<_iy2yc34w.RankingEntry>,
          _iss.getType<_i6xpafdb.CreatePlaySessionRequest>,
          _iss.getType<_illo5yhi.ExplainNearbyRequest>,
          _iss.getType<_ik98l12b.GetChallengeRequest>,
          _iss.getType<_ivte9ub5.GetChallengeRevisionRequest>,
          _iss.getType<_ifeazbqt.GetMyProfileRequest>,
          _iss.getType<_ij6onplx.GetMyRankingEntryRequest>,
          _iss.getType<_i7t9l4ob.GetPlaySessionRequest>,
          _iss.getType<_i46bkuwv.ListChallengesRequest>,
          _iss.getType<_i8ubv3an.ListRankingEntriesRequest>,
          _iss.getType<_i5ic124w.SubmitShotRequest>,
          _iss.getType<_ifze6cum.UpdateNicknameRequest>,
          _iss.getType<_i6xqk9zj.ListChallengesResponse>,
          _iss.getType<_iqez2ob1.ListPavilionsResponse>,
          _iss.getType<_ib5ytboh.ListRankingEntriesResponse>,
          _iss.getType<_ih9nnssc.SubmitShotResponse>,
          _iss.getType<_i9h2gfpa.Reveal>,
          _iss.getType<_ikzltuid.Shot>,
          _iss.getType<_iwq2300m.ShotInput>,
          _iss.getType<_itlkswb8.Spawn>,
          _iss.getType<_iba18tzr.SpawnEntrance>,
          _iss.getType<_i49z0bdd.VenueMap>,
          _iss.getType<_ieu1nkpc.WalkableArea>,
          _iss.getType<_i8kzjahn.ApiErrorCode?>,
          _iss.getType<_iozummgq.ApiException?>,
          _iss.getType<_ibtyf05g.AssetRef?>,
          _iss.getType<_inm2mhm8.CameraPose?>,
          _iss.getType<_ijvmy76x.Challenge?>,
          _iss.getType<_iwkiidn3.ChallengeRevision?>,
          _iss.getType<_iiocvpzn.Credit?>,
          _iss.getType<_i8gcykjk.FieldViolation?>,
          _iss.getType<_iwx3qa7h.GuideAudioChunk?>,
          _iss.getType<_iwx3qa7h.GuideAudioUnavailable?>,
          _iss.getType<_i6neeqzq.GuideAudioUnavailableReason?>,
          _iss.getType<_iwx3qa7h.GuideText?>,
          _iss.getType<_ieaxfcpn.GuideSource?>,
          _iss.getType<_i870j7w2.HealthRequest?>,
          _iss.getType<_i50lwsk9.HealthResponse?>,
          _iss.getType<_iukl7gif.Landmark?>,
          _iss.getType<_i0agetmq.MapBounds?>,
          _iss.getType<_ie1t35ud.ModeConfig?>,
          _iss.getType<_i5gqoy0o.Pavilion?>,
          _iss.getType<_ixcvq5ql.PlayMode?>,
          _iss.getType<_ivpttrnq.PlaySession?>,
          _iss.getType<_izjuizqd.PlaySessionState?>,
          _iss.getType<_i0oipb17.PointXZ?>,
          _iss.getType<_ilz0o8l0.Profile?>,
          _iss.getType<_iy2yc34w.RankingEntry?>,
          _iss.getType<_i6xpafdb.CreatePlaySessionRequest?>,
          _iss.getType<_illo5yhi.ExplainNearbyRequest?>,
          _iss.getType<_ik98l12b.GetChallengeRequest?>,
          _iss.getType<_ivte9ub5.GetChallengeRevisionRequest?>,
          _iss.getType<_ifeazbqt.GetMyProfileRequest?>,
          _iss.getType<_ij6onplx.GetMyRankingEntryRequest?>,
          _iss.getType<_i7t9l4ob.GetPlaySessionRequest?>,
          _iss.getType<_i46bkuwv.ListChallengesRequest?>,
          _iss.getType<_i8ubv3an.ListRankingEntriesRequest?>,
          _iss.getType<_i5ic124w.SubmitShotRequest?>,
          _iss.getType<_ifze6cum.UpdateNicknameRequest?>,
          _iss.getType<_i6xqk9zj.ListChallengesResponse?>,
          _iss.getType<_iqez2ob1.ListPavilionsResponse?>,
          _iss.getType<_ib5ytboh.ListRankingEntriesResponse?>,
          _iss.getType<_ih9nnssc.SubmitShotResponse?>,
          _iss.getType<_i9h2gfpa.Reveal?>,
          _iss.getType<_ikzltuid.Shot?>,
          _iss.getType<_iwq2300m.ShotInput?>,
          _iss.getType<_itlkswb8.Spawn?>,
          _iss.getType<_iba18tzr.SpawnEntrance?>,
          _iss.getType<_i49z0bdd.VenueMap?>,
          _iss.getType<_ieu1nkpc.WalkableArea?>,
          _iss.getType<List<_ix5zeh3i.FieldViolation>>,
          _iss.getType<List<_ix5zeh3i.FieldViolation>?>,
          _iss.getType<List<_ix5zeh3i.ModeConfig>>,
          _iss.getType<List<_ix5zeh3i.Credit>>,
          _iss.getType<List<String>>,
          _iss.getType<List<_ix5zeh3i.GuideSource>>,
          _iss.getType<List<_ix5zeh3i.SpawnEntrance>>,
          _iss.getType<List<_ix5zeh3i.Challenge>>,
          _iss.getType<List<_ix5zeh3i.Pavilion>>,
          _iss.getType<List<_ix5zeh3i.RankingEntry>>,
          _iss.getType<List<_ix5zeh3i.Landmark>>,
          _iss.getType<List<_ix5zeh3i.PointXZ>>,
          _iss.getType<List<List<_ix5zeh3i.PointXZ>>>,
        ],
        modules: const [],
        classNames: const [
          'ApiErrorCode',
          'ApiException',
          'AssetRef',
          'CameraPose',
          'Challenge',
          'ChallengeRevision',
          'Credit',
          'FieldViolation',
          'GuideAudioChunk',
          'GuideAudioUnavailable',
          'GuideAudioUnavailableReason',
          'GuideText',
          'GuideSource',
          'HealthRequest',
          'HealthResponse',
          'Landmark',
          'MapBounds',
          'ModeConfig',
          'Pavilion',
          'PlayMode',
          'PlaySession',
          'PlaySessionState',
          'PointXZ',
          'Profile',
          'RankingEntry',
          'CreatePlaySessionRequest',
          'ExplainNearbyRequest',
          'GetChallengeRequest',
          'GetChallengeRevisionRequest',
          'GetMyProfileRequest',
          'GetMyRankingEntryRequest',
          'GetPlaySessionRequest',
          'ListChallengesRequest',
          'ListRankingEntriesRequest',
          'SubmitShotRequest',
          'UpdateNicknameRequest',
          'ListChallengesResponse',
          'ListPavilionsResponse',
          'ListRankingEntriesResponse',
          'SubmitShotResponse',
          'Reveal',
          'Shot',
          'ShotInput',
          'Spawn',
          'SpawnEntrance',
          'VenueMap',
          'WalkableArea',
        ],
      );

  void registerHostProtocol(
    String projectName,
    _iss.SerializationManager protocol,
  ) {
    _hostProtocols.add(protocol);
  }

  static String? getClassNameFromObjectJson(dynamic data) =>
      _iss.ProtocolDeserialization.readClassName(data);

  @override
  T deserialize<T>(dynamic data, [Type? t]) {
    t ??= T;
    final rawDataClassName = _iss.ProtocolDeserialization.readClassName(data);
    final dataClassName = rawDataClassName;
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _iss.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i8kzjahn.ApiErrorCode) {
      return _i8kzjahn.ApiErrorCode.fromJson(data) as T;
    }
    if (t == _iozummgq.ApiException) {
      return _iozummgq.ApiException.fromJson(data) as T;
    }
    if (t == _ibtyf05g.AssetRef) {
      return _ibtyf05g.AssetRef.fromJson(data) as T;
    }
    if (t == _inm2mhm8.CameraPose) {
      return _inm2mhm8.CameraPose.fromJson(data) as T;
    }
    if (t == _ijvmy76x.Challenge) {
      return _ijvmy76x.Challenge.fromJson(data) as T;
    }
    if (t == _iwkiidn3.ChallengeRevision) {
      return _iwkiidn3.ChallengeRevision.fromJson(data) as T;
    }
    if (t == _iiocvpzn.Credit) {
      return _iiocvpzn.Credit.fromJson(data) as T;
    }
    if (t == _i8gcykjk.FieldViolation) {
      return _i8gcykjk.FieldViolation.fromJson(data) as T;
    }
    if (t == _iwx3qa7h.GuideAudioChunk) {
      return _iwx3qa7h.GuideAudioChunk.fromJson(data) as T;
    }
    if (t == _iwx3qa7h.GuideAudioUnavailable) {
      return _iwx3qa7h.GuideAudioUnavailable.fromJson(data) as T;
    }
    if (t == _i6neeqzq.GuideAudioUnavailableReason) {
      return _i6neeqzq.GuideAudioUnavailableReason.fromJson(data) as T;
    }
    if (t == _iwx3qa7h.GuideText) {
      return _iwx3qa7h.GuideText.fromJson(data) as T;
    }
    if (t == _ieaxfcpn.GuideSource) {
      return _ieaxfcpn.GuideSource.fromJson(data) as T;
    }
    if (t == _i870j7w2.HealthRequest) {
      return _i870j7w2.HealthRequest.fromJson(data) as T;
    }
    if (t == _i50lwsk9.HealthResponse) {
      return _i50lwsk9.HealthResponse.fromJson(data) as T;
    }
    if (t == _iukl7gif.Landmark) {
      return _iukl7gif.Landmark.fromJson(data) as T;
    }
    if (t == _i0agetmq.MapBounds) {
      return _i0agetmq.MapBounds.fromJson(data) as T;
    }
    if (t == _ie1t35ud.ModeConfig) {
      return _ie1t35ud.ModeConfig.fromJson(data) as T;
    }
    if (t == _i5gqoy0o.Pavilion) {
      return _i5gqoy0o.Pavilion.fromJson(data) as T;
    }
    if (t == _ixcvq5ql.PlayMode) {
      return _ixcvq5ql.PlayMode.fromJson(data) as T;
    }
    if (t == _ivpttrnq.PlaySession) {
      return _ivpttrnq.PlaySession.fromJson(data) as T;
    }
    if (t == _izjuizqd.PlaySessionState) {
      return _izjuizqd.PlaySessionState.fromJson(data) as T;
    }
    if (t == _i0oipb17.PointXZ) {
      return _i0oipb17.PointXZ.fromJson(data) as T;
    }
    if (t == _ilz0o8l0.Profile) {
      return _ilz0o8l0.Profile.fromJson(data) as T;
    }
    if (t == _iy2yc34w.RankingEntry) {
      return _iy2yc34w.RankingEntry.fromJson(data) as T;
    }
    if (t == _i6xpafdb.CreatePlaySessionRequest) {
      return _i6xpafdb.CreatePlaySessionRequest.fromJson(data) as T;
    }
    if (t == _illo5yhi.ExplainNearbyRequest) {
      return _illo5yhi.ExplainNearbyRequest.fromJson(data) as T;
    }
    if (t == _ik98l12b.GetChallengeRequest) {
      return _ik98l12b.GetChallengeRequest.fromJson(data) as T;
    }
    if (t == _ivte9ub5.GetChallengeRevisionRequest) {
      return _ivte9ub5.GetChallengeRevisionRequest.fromJson(data) as T;
    }
    if (t == _ifeazbqt.GetMyProfileRequest) {
      return _ifeazbqt.GetMyProfileRequest.fromJson(data) as T;
    }
    if (t == _ij6onplx.GetMyRankingEntryRequest) {
      return _ij6onplx.GetMyRankingEntryRequest.fromJson(data) as T;
    }
    if (t == _i7t9l4ob.GetPlaySessionRequest) {
      return _i7t9l4ob.GetPlaySessionRequest.fromJson(data) as T;
    }
    if (t == _i46bkuwv.ListChallengesRequest) {
      return _i46bkuwv.ListChallengesRequest.fromJson(data) as T;
    }
    if (t == _i8ubv3an.ListRankingEntriesRequest) {
      return _i8ubv3an.ListRankingEntriesRequest.fromJson(data) as T;
    }
    if (t == _i5ic124w.SubmitShotRequest) {
      return _i5ic124w.SubmitShotRequest.fromJson(data) as T;
    }
    if (t == _ifze6cum.UpdateNicknameRequest) {
      return _ifze6cum.UpdateNicknameRequest.fromJson(data) as T;
    }
    if (t == _i6xqk9zj.ListChallengesResponse) {
      return _i6xqk9zj.ListChallengesResponse.fromJson(data) as T;
    }
    if (t == _iqez2ob1.ListPavilionsResponse) {
      return _iqez2ob1.ListPavilionsResponse.fromJson(data) as T;
    }
    if (t == _ib5ytboh.ListRankingEntriesResponse) {
      return _ib5ytboh.ListRankingEntriesResponse.fromJson(data) as T;
    }
    if (t == _ih9nnssc.SubmitShotResponse) {
      return _ih9nnssc.SubmitShotResponse.fromJson(data) as T;
    }
    if (t == _i9h2gfpa.Reveal) {
      return _i9h2gfpa.Reveal.fromJson(data) as T;
    }
    if (t == _ikzltuid.Shot) {
      return _ikzltuid.Shot.fromJson(data) as T;
    }
    if (t == _iwq2300m.ShotInput) {
      return _iwq2300m.ShotInput.fromJson(data) as T;
    }
    if (t == _itlkswb8.Spawn) {
      return _itlkswb8.Spawn.fromJson(data) as T;
    }
    if (t == _iba18tzr.SpawnEntrance) {
      return _iba18tzr.SpawnEntrance.fromJson(data) as T;
    }
    if (t == _i49z0bdd.VenueMap) {
      return _i49z0bdd.VenueMap.fromJson(data) as T;
    }
    if (t == _ieu1nkpc.WalkableArea) {
      return _ieu1nkpc.WalkableArea.fromJson(data) as T;
    }
    if (t == _iss.getType<_i8kzjahn.ApiErrorCode?>()) {
      return (data != null ? _i8kzjahn.ApiErrorCode.fromJson(data) : null) as T;
    }
    if (t == _iss.getType<_iozummgq.ApiException?>()) {
      return (data != null ? _iozummgq.ApiException.fromJson(data) : null) as T;
    }
    if (t == _iss.getType<_ibtyf05g.AssetRef?>()) {
      return (data != null ? _ibtyf05g.AssetRef.fromJson(data) : null) as T;
    }
    if (t == _iss.getType<_inm2mhm8.CameraPose?>()) {
      return (data != null ? _inm2mhm8.CameraPose.fromJson(data) : null) as T;
    }
    if (t == _iss.getType<_ijvmy76x.Challenge?>()) {
      return (data != null ? _ijvmy76x.Challenge.fromJson(data) : null) as T;
    }
    if (t == _iss.getType<_iwkiidn3.ChallengeRevision?>()) {
      return (data != null ? _iwkiidn3.ChallengeRevision.fromJson(data) : null)
          as T;
    }
    if (t == _iss.getType<_iiocvpzn.Credit?>()) {
      return (data != null ? _iiocvpzn.Credit.fromJson(data) : null) as T;
    }
    if (t == _iss.getType<_i8gcykjk.FieldViolation?>()) {
      return (data != null ? _i8gcykjk.FieldViolation.fromJson(data) : null)
          as T;
    }
    if (t == _iss.getType<_iwx3qa7h.GuideAudioChunk?>()) {
      return (data != null ? _iwx3qa7h.GuideAudioChunk.fromJson(data) : null)
          as T;
    }
    if (t == _iss.getType<_iwx3qa7h.GuideAudioUnavailable?>()) {
      return (data != null
              ? _iwx3qa7h.GuideAudioUnavailable.fromJson(data)
              : null)
          as T;
    }
    if (t == _iss.getType<_i6neeqzq.GuideAudioUnavailableReason?>()) {
      return (data != null
              ? _i6neeqzq.GuideAudioUnavailableReason.fromJson(data)
              : null)
          as T;
    }
    if (t == _iss.getType<_iwx3qa7h.GuideText?>()) {
      return (data != null ? _iwx3qa7h.GuideText.fromJson(data) : null) as T;
    }
    if (t == _iss.getType<_ieaxfcpn.GuideSource?>()) {
      return (data != null ? _ieaxfcpn.GuideSource.fromJson(data) : null) as T;
    }
    if (t == _iss.getType<_i870j7w2.HealthRequest?>()) {
      return (data != null ? _i870j7w2.HealthRequest.fromJson(data) : null)
          as T;
    }
    if (t == _iss.getType<_i50lwsk9.HealthResponse?>()) {
      return (data != null ? _i50lwsk9.HealthResponse.fromJson(data) : null)
          as T;
    }
    if (t == _iss.getType<_iukl7gif.Landmark?>()) {
      return (data != null ? _iukl7gif.Landmark.fromJson(data) : null) as T;
    }
    if (t == _iss.getType<_i0agetmq.MapBounds?>()) {
      return (data != null ? _i0agetmq.MapBounds.fromJson(data) : null) as T;
    }
    if (t == _iss.getType<_ie1t35ud.ModeConfig?>()) {
      return (data != null ? _ie1t35ud.ModeConfig.fromJson(data) : null) as T;
    }
    if (t == _iss.getType<_i5gqoy0o.Pavilion?>()) {
      return (data != null ? _i5gqoy0o.Pavilion.fromJson(data) : null) as T;
    }
    if (t == _iss.getType<_ixcvq5ql.PlayMode?>()) {
      return (data != null ? _ixcvq5ql.PlayMode.fromJson(data) : null) as T;
    }
    if (t == _iss.getType<_ivpttrnq.PlaySession?>()) {
      return (data != null ? _ivpttrnq.PlaySession.fromJson(data) : null) as T;
    }
    if (t == _iss.getType<_izjuizqd.PlaySessionState?>()) {
      return (data != null ? _izjuizqd.PlaySessionState.fromJson(data) : null)
          as T;
    }
    if (t == _iss.getType<_i0oipb17.PointXZ?>()) {
      return (data != null ? _i0oipb17.PointXZ.fromJson(data) : null) as T;
    }
    if (t == _iss.getType<_ilz0o8l0.Profile?>()) {
      return (data != null ? _ilz0o8l0.Profile.fromJson(data) : null) as T;
    }
    if (t == _iss.getType<_iy2yc34w.RankingEntry?>()) {
      return (data != null ? _iy2yc34w.RankingEntry.fromJson(data) : null) as T;
    }
    if (t == _iss.getType<_i6xpafdb.CreatePlaySessionRequest?>()) {
      return (data != null
              ? _i6xpafdb.CreatePlaySessionRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _iss.getType<_illo5yhi.ExplainNearbyRequest?>()) {
      return (data != null
              ? _illo5yhi.ExplainNearbyRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _iss.getType<_ik98l12b.GetChallengeRequest?>()) {
      return (data != null
              ? _ik98l12b.GetChallengeRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _iss.getType<_ivte9ub5.GetChallengeRevisionRequest?>()) {
      return (data != null
              ? _ivte9ub5.GetChallengeRevisionRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _iss.getType<_ifeazbqt.GetMyProfileRequest?>()) {
      return (data != null
              ? _ifeazbqt.GetMyProfileRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _iss.getType<_ij6onplx.GetMyRankingEntryRequest?>()) {
      return (data != null
              ? _ij6onplx.GetMyRankingEntryRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _iss.getType<_i7t9l4ob.GetPlaySessionRequest?>()) {
      return (data != null
              ? _i7t9l4ob.GetPlaySessionRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _iss.getType<_i46bkuwv.ListChallengesRequest?>()) {
      return (data != null
              ? _i46bkuwv.ListChallengesRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _iss.getType<_i8ubv3an.ListRankingEntriesRequest?>()) {
      return (data != null
              ? _i8ubv3an.ListRankingEntriesRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _iss.getType<_i5ic124w.SubmitShotRequest?>()) {
      return (data != null ? _i5ic124w.SubmitShotRequest.fromJson(data) : null)
          as T;
    }
    if (t == _iss.getType<_ifze6cum.UpdateNicknameRequest?>()) {
      return (data != null
              ? _ifze6cum.UpdateNicknameRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _iss.getType<_i6xqk9zj.ListChallengesResponse?>()) {
      return (data != null
              ? _i6xqk9zj.ListChallengesResponse.fromJson(data)
              : null)
          as T;
    }
    if (t == _iss.getType<_iqez2ob1.ListPavilionsResponse?>()) {
      return (data != null
              ? _iqez2ob1.ListPavilionsResponse.fromJson(data)
              : null)
          as T;
    }
    if (t == _iss.getType<_ib5ytboh.ListRankingEntriesResponse?>()) {
      return (data != null
              ? _ib5ytboh.ListRankingEntriesResponse.fromJson(data)
              : null)
          as T;
    }
    if (t == _iss.getType<_ih9nnssc.SubmitShotResponse?>()) {
      return (data != null ? _ih9nnssc.SubmitShotResponse.fromJson(data) : null)
          as T;
    }
    if (t == _iss.getType<_i9h2gfpa.Reveal?>()) {
      return (data != null ? _i9h2gfpa.Reveal.fromJson(data) : null) as T;
    }
    if (t == _iss.getType<_ikzltuid.Shot?>()) {
      return (data != null ? _ikzltuid.Shot.fromJson(data) : null) as T;
    }
    if (t == _iss.getType<_iwq2300m.ShotInput?>()) {
      return (data != null ? _iwq2300m.ShotInput.fromJson(data) : null) as T;
    }
    if (t == _iss.getType<_itlkswb8.Spawn?>()) {
      return (data != null ? _itlkswb8.Spawn.fromJson(data) : null) as T;
    }
    if (t == _iss.getType<_iba18tzr.SpawnEntrance?>()) {
      return (data != null ? _iba18tzr.SpawnEntrance.fromJson(data) : null)
          as T;
    }
    if (t == _iss.getType<_i49z0bdd.VenueMap?>()) {
      return (data != null ? _i49z0bdd.VenueMap.fromJson(data) : null) as T;
    }
    if (t == _iss.getType<_ieu1nkpc.WalkableArea?>()) {
      return (data != null ? _ieu1nkpc.WalkableArea.fromJson(data) : null) as T;
    }
    if (t == List<_ix5zeh3i.FieldViolation>) {
      return (data as List)
              .map((e) => deserialize<_ix5zeh3i.FieldViolation>(e))
              .toList()
          as T;
    }
    if (t == _iss.getType<List<_ix5zeh3i.FieldViolation>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_ix5zeh3i.FieldViolation>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_ix5zeh3i.ModeConfig>) {
      return (data as List)
              .map((e) => deserialize<_ix5zeh3i.ModeConfig>(e))
              .toList()
          as T;
    }
    if (t == List<_ix5zeh3i.Credit>) {
      return (data as List)
              .map((e) => deserialize<_ix5zeh3i.Credit>(e))
              .toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_ix5zeh3i.GuideSource>) {
      return (data as List)
              .map((e) => deserialize<_ix5zeh3i.GuideSource>(e))
              .toList()
          as T;
    }
    if (t == List<_ix5zeh3i.SpawnEntrance>) {
      return (data as List)
              .map((e) => deserialize<_ix5zeh3i.SpawnEntrance>(e))
              .toList()
          as T;
    }
    if (t == List<_ix5zeh3i.Challenge>) {
      return (data as List)
              .map((e) => deserialize<_ix5zeh3i.Challenge>(e))
              .toList()
          as T;
    }
    if (t == List<_ix5zeh3i.Pavilion>) {
      return (data as List)
              .map((e) => deserialize<_ix5zeh3i.Pavilion>(e))
              .toList()
          as T;
    }
    if (t == List<_ix5zeh3i.RankingEntry>) {
      return (data as List)
              .map((e) => deserialize<_ix5zeh3i.RankingEntry>(e))
              .toList()
          as T;
    }
    if (t == List<_ix5zeh3i.Landmark>) {
      return (data as List)
              .map((e) => deserialize<_ix5zeh3i.Landmark>(e))
              .toList()
          as T;
    }
    if (t == List<_ix5zeh3i.PointXZ>) {
      return (data as List)
              .map((e) => deserialize<_ix5zeh3i.PointXZ>(e))
              .toList()
          as T;
    }
    if (t == List<List<_ix5zeh3i.PointXZ>>) {
      return (data as List)
              .map((e) => deserialize<List<_ix5zeh3i.PointXZ>>(e))
              .toList()
          as T;
    }
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i8kzjahn.ApiErrorCode => 'ApiErrorCode',
      _iozummgq.ApiException => 'ApiException',
      _ibtyf05g.AssetRef => 'AssetRef',
      _inm2mhm8.CameraPose => 'CameraPose',
      _ijvmy76x.Challenge => 'Challenge',
      _iwkiidn3.ChallengeRevision => 'ChallengeRevision',
      _iiocvpzn.Credit => 'Credit',
      _i8gcykjk.FieldViolation => 'FieldViolation',
      _iwx3qa7h.GuideAudioChunk => 'GuideAudioChunk',
      _iwx3qa7h.GuideAudioUnavailable => 'GuideAudioUnavailable',
      _i6neeqzq.GuideAudioUnavailableReason => 'GuideAudioUnavailableReason',
      _iwx3qa7h.GuideText => 'GuideText',
      _ieaxfcpn.GuideSource => 'GuideSource',
      _i870j7w2.HealthRequest => 'HealthRequest',
      _i50lwsk9.HealthResponse => 'HealthResponse',
      _iukl7gif.Landmark => 'Landmark',
      _i0agetmq.MapBounds => 'MapBounds',
      _ie1t35ud.ModeConfig => 'ModeConfig',
      _i5gqoy0o.Pavilion => 'Pavilion',
      _ixcvq5ql.PlayMode => 'PlayMode',
      _ivpttrnq.PlaySession => 'PlaySession',
      _izjuizqd.PlaySessionState => 'PlaySessionState',
      _i0oipb17.PointXZ => 'PointXZ',
      _ilz0o8l0.Profile => 'Profile',
      _iy2yc34w.RankingEntry => 'RankingEntry',
      _i6xpafdb.CreatePlaySessionRequest => 'CreatePlaySessionRequest',
      _illo5yhi.ExplainNearbyRequest => 'ExplainNearbyRequest',
      _ik98l12b.GetChallengeRequest => 'GetChallengeRequest',
      _ivte9ub5.GetChallengeRevisionRequest => 'GetChallengeRevisionRequest',
      _ifeazbqt.GetMyProfileRequest => 'GetMyProfileRequest',
      _ij6onplx.GetMyRankingEntryRequest => 'GetMyRankingEntryRequest',
      _i7t9l4ob.GetPlaySessionRequest => 'GetPlaySessionRequest',
      _i46bkuwv.ListChallengesRequest => 'ListChallengesRequest',
      _i8ubv3an.ListRankingEntriesRequest => 'ListRankingEntriesRequest',
      _i5ic124w.SubmitShotRequest => 'SubmitShotRequest',
      _ifze6cum.UpdateNicknameRequest => 'UpdateNicknameRequest',
      _i6xqk9zj.ListChallengesResponse => 'ListChallengesResponse',
      _iqez2ob1.ListPavilionsResponse => 'ListPavilionsResponse',
      _ib5ytboh.ListRankingEntriesResponse => 'ListRankingEntriesResponse',
      _ih9nnssc.SubmitShotResponse => 'SubmitShotResponse',
      _i9h2gfpa.Reveal => 'Reveal',
      _ikzltuid.Shot => 'Shot',
      _iwq2300m.ShotInput => 'ShotInput',
      _itlkswb8.Spawn => 'Spawn',
      _iba18tzr.SpawnEntrance => 'SpawnEntrance',
      _i49z0bdd.VenueMap => 'VenueMap',
      _ieu1nkpc.WalkableArea => 'WalkableArea',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('photohunt.', '');
    }

    switch (data) {
      case _i8kzjahn.ApiErrorCode():
        return 'ApiErrorCode';
      case _iozummgq.ApiException():
        return 'ApiException';
      case _ibtyf05g.AssetRef():
        return 'AssetRef';
      case _inm2mhm8.CameraPose():
        return 'CameraPose';
      case _ijvmy76x.Challenge():
        return 'Challenge';
      case _iwkiidn3.ChallengeRevision():
        return 'ChallengeRevision';
      case _iiocvpzn.Credit():
        return 'Credit';
      case _i8gcykjk.FieldViolation():
        return 'FieldViolation';
      case _iwx3qa7h.GuideAudioChunk():
        return 'GuideAudioChunk';
      case _iwx3qa7h.GuideAudioUnavailable():
        return 'GuideAudioUnavailable';
      case _i6neeqzq.GuideAudioUnavailableReason():
        return 'GuideAudioUnavailableReason';
      case _iwx3qa7h.GuideText():
        return 'GuideText';
      case _ieaxfcpn.GuideSource():
        return 'GuideSource';
      case _i870j7w2.HealthRequest():
        return 'HealthRequest';
      case _i50lwsk9.HealthResponse():
        return 'HealthResponse';
      case _iukl7gif.Landmark():
        return 'Landmark';
      case _i0agetmq.MapBounds():
        return 'MapBounds';
      case _ie1t35ud.ModeConfig():
        return 'ModeConfig';
      case _i5gqoy0o.Pavilion():
        return 'Pavilion';
      case _ixcvq5ql.PlayMode():
        return 'PlayMode';
      case _ivpttrnq.PlaySession():
        return 'PlaySession';
      case _izjuizqd.PlaySessionState():
        return 'PlaySessionState';
      case _i0oipb17.PointXZ():
        return 'PointXZ';
      case _ilz0o8l0.Profile():
        return 'Profile';
      case _iy2yc34w.RankingEntry():
        return 'RankingEntry';
      case _i6xpafdb.CreatePlaySessionRequest():
        return 'CreatePlaySessionRequest';
      case _illo5yhi.ExplainNearbyRequest():
        return 'ExplainNearbyRequest';
      case _ik98l12b.GetChallengeRequest():
        return 'GetChallengeRequest';
      case _ivte9ub5.GetChallengeRevisionRequest():
        return 'GetChallengeRevisionRequest';
      case _ifeazbqt.GetMyProfileRequest():
        return 'GetMyProfileRequest';
      case _ij6onplx.GetMyRankingEntryRequest():
        return 'GetMyRankingEntryRequest';
      case _i7t9l4ob.GetPlaySessionRequest():
        return 'GetPlaySessionRequest';
      case _i46bkuwv.ListChallengesRequest():
        return 'ListChallengesRequest';
      case _i8ubv3an.ListRankingEntriesRequest():
        return 'ListRankingEntriesRequest';
      case _i5ic124w.SubmitShotRequest():
        return 'SubmitShotRequest';
      case _ifze6cum.UpdateNicknameRequest():
        return 'UpdateNicknameRequest';
      case _i6xqk9zj.ListChallengesResponse():
        return 'ListChallengesResponse';
      case _iqez2ob1.ListPavilionsResponse():
        return 'ListPavilionsResponse';
      case _ib5ytboh.ListRankingEntriesResponse():
        return 'ListRankingEntriesResponse';
      case _ih9nnssc.SubmitShotResponse():
        return 'SubmitShotResponse';
      case _i9h2gfpa.Reveal():
        return 'Reveal';
      case _ikzltuid.Shot():
        return 'Shot';
      case _iwq2300m.ShotInput():
        return 'ShotInput';
      case _itlkswb8.Spawn():
        return 'Spawn';
      case _iba18tzr.SpawnEntrance():
        return 'SpawnEntrance';
      case _i49z0bdd.VenueMap():
        return 'VenueMap';
      case _ieu1nkpc.WalkableArea():
        return 'WalkableArea';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'ApiErrorCode') {
      return deserialize<_i8kzjahn.ApiErrorCode>(data['data']);
    }
    if (dataClassName == 'ApiException') {
      return deserialize<_iozummgq.ApiException>(data['data']);
    }
    if (dataClassName == 'AssetRef') {
      return deserialize<_ibtyf05g.AssetRef>(data['data']);
    }
    if (dataClassName == 'CameraPose') {
      return deserialize<_inm2mhm8.CameraPose>(data['data']);
    }
    if (dataClassName == 'Challenge') {
      return deserialize<_ijvmy76x.Challenge>(data['data']);
    }
    if (dataClassName == 'ChallengeRevision') {
      return deserialize<_iwkiidn3.ChallengeRevision>(data['data']);
    }
    if (dataClassName == 'Credit') {
      return deserialize<_iiocvpzn.Credit>(data['data']);
    }
    if (dataClassName == 'FieldViolation') {
      return deserialize<_i8gcykjk.FieldViolation>(data['data']);
    }
    if (dataClassName == 'GuideAudioChunk') {
      return deserialize<_iwx3qa7h.GuideAudioChunk>(data['data']);
    }
    if (dataClassName == 'GuideAudioUnavailable') {
      return deserialize<_iwx3qa7h.GuideAudioUnavailable>(data['data']);
    }
    if (dataClassName == 'GuideAudioUnavailableReason') {
      return deserialize<_i6neeqzq.GuideAudioUnavailableReason>(data['data']);
    }
    if (dataClassName == 'GuideText') {
      return deserialize<_iwx3qa7h.GuideText>(data['data']);
    }
    if (dataClassName == 'GuideSource') {
      return deserialize<_ieaxfcpn.GuideSource>(data['data']);
    }
    if (dataClassName == 'HealthRequest') {
      return deserialize<_i870j7w2.HealthRequest>(data['data']);
    }
    if (dataClassName == 'HealthResponse') {
      return deserialize<_i50lwsk9.HealthResponse>(data['data']);
    }
    if (dataClassName == 'Landmark') {
      return deserialize<_iukl7gif.Landmark>(data['data']);
    }
    if (dataClassName == 'MapBounds') {
      return deserialize<_i0agetmq.MapBounds>(data['data']);
    }
    if (dataClassName == 'ModeConfig') {
      return deserialize<_ie1t35ud.ModeConfig>(data['data']);
    }
    if (dataClassName == 'Pavilion') {
      return deserialize<_i5gqoy0o.Pavilion>(data['data']);
    }
    if (dataClassName == 'PlayMode') {
      return deserialize<_ixcvq5ql.PlayMode>(data['data']);
    }
    if (dataClassName == 'PlaySession') {
      return deserialize<_ivpttrnq.PlaySession>(data['data']);
    }
    if (dataClassName == 'PlaySessionState') {
      return deserialize<_izjuizqd.PlaySessionState>(data['data']);
    }
    if (dataClassName == 'PointXZ') {
      return deserialize<_i0oipb17.PointXZ>(data['data']);
    }
    if (dataClassName == 'Profile') {
      return deserialize<_ilz0o8l0.Profile>(data['data']);
    }
    if (dataClassName == 'RankingEntry') {
      return deserialize<_iy2yc34w.RankingEntry>(data['data']);
    }
    if (dataClassName == 'CreatePlaySessionRequest') {
      return deserialize<_i6xpafdb.CreatePlaySessionRequest>(data['data']);
    }
    if (dataClassName == 'ExplainNearbyRequest') {
      return deserialize<_illo5yhi.ExplainNearbyRequest>(data['data']);
    }
    if (dataClassName == 'GetChallengeRequest') {
      return deserialize<_ik98l12b.GetChallengeRequest>(data['data']);
    }
    if (dataClassName == 'GetChallengeRevisionRequest') {
      return deserialize<_ivte9ub5.GetChallengeRevisionRequest>(data['data']);
    }
    if (dataClassName == 'GetMyProfileRequest') {
      return deserialize<_ifeazbqt.GetMyProfileRequest>(data['data']);
    }
    if (dataClassName == 'GetMyRankingEntryRequest') {
      return deserialize<_ij6onplx.GetMyRankingEntryRequest>(data['data']);
    }
    if (dataClassName == 'GetPlaySessionRequest') {
      return deserialize<_i7t9l4ob.GetPlaySessionRequest>(data['data']);
    }
    if (dataClassName == 'ListChallengesRequest') {
      return deserialize<_i46bkuwv.ListChallengesRequest>(data['data']);
    }
    if (dataClassName == 'ListRankingEntriesRequest') {
      return deserialize<_i8ubv3an.ListRankingEntriesRequest>(data['data']);
    }
    if (dataClassName == 'SubmitShotRequest') {
      return deserialize<_i5ic124w.SubmitShotRequest>(data['data']);
    }
    if (dataClassName == 'UpdateNicknameRequest') {
      return deserialize<_ifze6cum.UpdateNicknameRequest>(data['data']);
    }
    if (dataClassName == 'ListChallengesResponse') {
      return deserialize<_i6xqk9zj.ListChallengesResponse>(data['data']);
    }
    if (dataClassName == 'ListPavilionsResponse') {
      return deserialize<_iqez2ob1.ListPavilionsResponse>(data['data']);
    }
    if (dataClassName == 'ListRankingEntriesResponse') {
      return deserialize<_ib5ytboh.ListRankingEntriesResponse>(data['data']);
    }
    if (dataClassName == 'SubmitShotResponse') {
      return deserialize<_ih9nnssc.SubmitShotResponse>(data['data']);
    }
    if (dataClassName == 'Reveal') {
      return deserialize<_i9h2gfpa.Reveal>(data['data']);
    }
    if (dataClassName == 'Shot') {
      return deserialize<_ikzltuid.Shot>(data['data']);
    }
    if (dataClassName == 'ShotInput') {
      return deserialize<_iwq2300m.ShotInput>(data['data']);
    }
    if (dataClassName == 'Spawn') {
      return deserialize<_itlkswb8.Spawn>(data['data']);
    }
    if (dataClassName == 'SpawnEntrance') {
      return deserialize<_iba18tzr.SpawnEntrance>(data['data']);
    }
    if (dataClassName == 'VenueMap') {
      return deserialize<_i49z0bdd.VenueMap>(data['data']);
    }
    if (dataClassName == 'WalkableArea') {
      return deserialize<_ieu1nkpc.WalkableArea>(data['data']);
    }
    return super.deserializeByClassName(data);
  }

  @override
  Object? dynamicFieldToJson(Object? object, {bool forProtocol = false}) {
    if ((object is List || object is Set || object is Map) ||
        getClassNameForObject(object) != null) {
      return super.dynamicFieldToJson(object, forProtocol: forProtocol);
    }
    for (final protocol in _hostProtocols) {
      final className = protocol.getClassNameForObject(object);
      if (className == null) continue;
      final host = protocol.getModuleName();
      final wrapped = {
        'className': className.contains('.') ? className : '$host.$className',
        'data': object,
      };
      return forProtocol
          ? _iss.SerializationManager.toEncodableForProtocol(wrapped)
          : _iss.SerializationManager.toEncodable(wrapped);
    }
    return super.dynamicFieldToJson(object, forProtocol: forProtocol);
  }

  @override
  dynamic deserializeDynamicFieldValue(Object? value) {
    if (value == null) return null;
    if (value is! Map<String, dynamic> || value['className'] is! String) {
      throw FormatException(
        'Dynamic fields are encoded as a Map with className and data, but got '
        '${value.runtimeType} instead.',
      );
    }
    final className = value['className'] as String;
    for (final protocol in _hostProtocols) {
      final host = protocol.getModuleName();
      final hostPrefix = '$host.';
      if (className.startsWith(hostPrefix)) {
        final strippedClassName = className.substring(hostPrefix.length);
        if (strippedClassName.contains('.')) {
          throw FormatException(
            'Dynamic field className must not use multiple prefixes: $className',
          );
        }
        final hostData = Map<String, dynamic>.from(value);
        hostData['className'] = strippedClassName;
        return protocol.deserializeByClassName(hostData);
      }
    }
    if (className.contains('.')) {
      for (final protocol in _hostProtocols) {
        try {
          return protocol.deserializeByClassName(value);
        } on _iss.DeserializationClassNameNotFoundException catch (_) {}
      }
    }
    return deserializeByClassName(value);
  }

  @override
  String getModuleName() => 'photohunt';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
