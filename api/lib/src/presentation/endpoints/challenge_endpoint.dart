// サーバー内部のドメインモデルと同名の公開 DTO があるので、ドメインには接頭辞を付ける。
import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:serverpod/serverpod.dart';

import '../../domain/exceptions.dart';
import '../../domain/models/models.dart' as domain;
import '../../domain/ports/asset_url_resolver.dart';
import '../di/challenge_dependencies.dart';
import '../endpoint_call.dart';

/// 公開中の出題と、不変の版を返す（docs/specs.md「出題版・開始・結果の再取得」）。
///
/// 版には正解姿勢・撮影後の解説・開始候補・構造物資料・採点式・オブジェクト名を含めない。
/// 3D モデルはアプリ同梱のため、モデルの素材参照も返さない。
class ChallengeEndpoint() extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<ListChallengesResponse> listChallenges(
    Session session,
    ListChallengesRequest request,
  ) => _call(session, () async {
    final challenges = await listChallengesUseCase(session).execute();
    return ListChallengesResponse(
      challenges: challenges.map(_challenge).toList(),
    );
  });

  Future<Challenge> getChallenge(
    Session session,
    GetChallengeRequest request,
  ) => _call(
    session,
    () async => _challenge(
      await getChallengeUseCase(session).execute(request.challengeId),
    ),
  );

  Future<ChallengeRevision> getChallengeRevision(
    Session session,
    GetChallengeRevisionRequest request,
  ) => _call(session, () async {
    final revision = await getChallengeRevisionUseCase(session)
        .execute(request.revisionId);
    return _revision(revision, assetUrlResolver(session));
  });
}

List<SpawnEntrance> _entrances(domain.ModeConfig mode) {
  if (mode.mode != .free) return const [];
  final entrances = <SpawnEntrance>[];
  for (final spawn in mode.spawnPoints) {
    final label = spawn.label;
    if (label == null) continue;
    entrances.add(SpawnEntrance(id: spawn.id, label: label));
  }
  return entrances;
}

Challenge _challenge(domain.Challenge c) =>
    Challenge(id: c.id, title: c.title, currentRevisionId: c.currentRevisionId);

ChallengeRevision _revision(domain.ChallengeRevision r, AssetUrlResolver urls) {
  AssetRef asset(domain.Asset a) => AssetRef(
    url: urls.urlFor(a),
    sha256: a.sha256,
    byteLength: a.byteLength,
    contentType: a.contentType,
  );
  return ChallengeRevision(
    id: r.id,
    challengeId: r.challengeId,
    sceneProfile: r.sceneProfile,
    photo: asset(r.photo),
    photoAlt: r.photoAlt,
    map: VenueMap(
      image: asset(r.map),
      bounds: r.mapBounds,
      landmarks: [
        for (final l in r.landmarks)
          Landmark(
            id: l.id,
            name: l.displayName,
            positionX: l.posX,
            positionZ: l.posZ,
            latitude: l.lat,
            longitude: l.lon,
          ),
      ],
    ),
    modes: [
      for (final m in r.modes)
        ModeConfig(
          mode: m.mode,
          walkable: m.walkable,
          entrances: _entrances(m),
        ),
    ],
    eyeHeightMeters: r.eyeHeightM,
    shotVerticalFovDegrees: r.shotFovDeg,
    credits: [for (final c in r.credits) Credit(name: c.name, url: c.url)],
  );
}

Future<T> _call<T>(Session session, Future<T> Function() action) {
  return guardUnclassifiedFailure(
    session: session,
    logLabel: '出題処理に失敗しました',
    action: () async {
      try {
        return await action();
      } on ChallengeException catch (error) {
        switch (error.reason) {
          case .invalidRequest:
            throw ApiException(
              code: .invalidArgument,
              reason: ApiErrorReasons.invalidRequest,
              message: 'ID は 1 以上にしてください',
            );
          case .challengeNotFound:
            throw ApiException(
              code: .notFound,
              reason: ApiErrorReasons.challengeNotFound,
              message: '指定された出題が見つかりません',
            );
          case .revisionNotFound:
            throw ApiException(
              code: .notFound,
              reason: ApiErrorReasons.revisionNotFound,
              message: '指定された出題版が見つかりません',
            );
        }
      } on CorruptedDataException catch (error) {
        // DB の値が前提を満たさない。詳細はログに残し、応答には固定の説明だけを返す。
        session.log('出題データが壊れている: $error', level: LogLevel.error);
        throw ApiException(
          code: .internal,
          reason: ApiErrorReasons.internal,
          message: '出題データを読み取れませんでした',
        );
      }
    },
  );
}
