import 'package:photohunt_shared/photohunt_shared.dart' show PlayMode;
import 'package:serverpod/serverpod.dart';

import '../../../domain/exceptions.dart';
import '../../../domain/models/models.dart';
import '../../../domain/repositories/challenge_repository.dart';
import '../../../generated/protocol.dart';
import '../mappers/challenge_mappers.dart';
import '../mappers/play_mode_mapper.dart';

/// [ChallengeRepository] の ORM 実装。
///
/// [session] と [transaction] は呼び出し側（共通ゲート #24）が渡す。
class OrmChallengeRepository(
  final DatabaseSession _session, {
  final Transaction? _transaction,
}) implements ChallengeRepository {
  @override
  Future<List<Challenge>> listPublished() async {
    final rows = await ChallengeRow.db.find(
      _session,
      where: (t) => t.currentRevisionId.notEquals(null),
      orderBy: (t) => t.id,
      transaction: _transaction,
    );
    return rows.map(challengeFromRow).toList();
  }

  @override
  Future<Challenge?> findById(int id) async {
    final row = await ChallengeRow.db.findById(
      _session,
      id,
      transaction: _transaction,
    );
    return row == null ? null : challengeFromRow(row);
  }

  @override
  Future<Challenge?> findPublicById(int id) async {
    final challenge = await findById(id);
    if (challenge == null) return null;
    if (challenge.currentRevisionId != null) return challenge;
    // 公開が終わった出題は、公開済みの版が残っている。下書きだけの出題にはない。
    final published = await ChallengeRevisionRow.db.count(
      _session,
      where: (t) => t.challengeId.equals(id) & t.publishedAt.notEquals(null),
      limit: 1,
      transaction: _transaction,
    );
    return published > 0 ? challenge : null;
  }

  @override
  Future<ChallengeRevision?> findRevision(int revisionId) =>
      _find(revisionId, includeSecrets: false);

  @override
  Future<({int challengeId, bool published})?> findRevisionStatus(
    int revisionId,
  ) async {
    final row = await ChallengeRevisionRow.db.findById(
      _session,
      revisionId,
      transaction: _transaction,
    );
    return row == null
        ? null
        : (challengeId: row.challengeId, published: row.publishedAt != null);
  }

  @override
  Future<List<SpawnPoint>> listSpawnPoints(
    int revisionId,
    PlayMode mode,
  ) async {
    final modeRow = await ModeConfigRow.db.findFirstRow(
      _session,
      where: (t) =>
          t.revisionId.equals(revisionId) & t.mode.equals(playModeToRow(mode)),
      transaction: _transaction,
    );
    if (modeRow == null) return const [];
    final rows = await SpawnPointRow.db.find(
      _session,
      where: (t) => t.modeConfigId.equals(modeRow.id!),
      orderBy: (t) => t.sortOrder,
      transaction: _transaction,
    );
    return rows.map(spawnPointFromRow).toList();
  }

  @override
  Future<SpawnPoint?> findSpawnPoint(int spawnPointId) async {
    final row = await SpawnPointRow.db.findById(
      _session,
      spawnPointId,
      transaction: _transaction,
    );
    return row == null ? null : spawnPointFromRow(row);
  }

  @override
  Future<ChallengeRevision?> findPublishedRevision(int revisionId) =>
      _find(revisionId, includeSecrets: false, publishedOnly: true);

  @override
  Future<ChallengeRevision?> findRevisionWithSecrets(int revisionId) =>
      _find(revisionId, includeSecrets: true);

  Future<ChallengeRevision?> _find(
    int revisionId, {
    required bool includeSecrets,
    bool publishedOnly = false,
  }) async {
    final row = await ChallengeRevisionRow.db.findById(
      _session,
      revisionId,
      transaction: _transaction,
    );
    if (row == null) return null;
    // 下書きは、素材・モード・地点などの子データを読む前に（壊れていても読み込みに失敗
    // しないよう）存在しないものとして返す。
    if (publishedOnly && row.publishedAt == null) return null;

    final assetRows = await AssetRow.db.find(
      _session,
      where: (t) => t.id.inSet(<int>{row.photoAssetId, row.mapAssetId}),
      transaction: _transaction,
    );
    final assets = {for (final a in assetRows) a.id!: assetFromRow(a)};
    Asset asset(int id, String field) =>
        assets[id] ??
        (throw CorruptedDataException(
          entity: 'challenge_revision',
          field: field,
          message: 'asset $id が存在しない',
        ));

    final modeRows = await ModeConfigRow.db.find(
      _session,
      where: (t) => t.revisionId.equals(revisionId),
      orderBy: (t) => t.id,
      transaction: _transaction,
    );
    final spawnRows = modeRows.isEmpty
        ? <SpawnPointRow>[]
        : await SpawnPointRow.db.find(
            _session,
            where: (t) =>
                t.modeConfigId.inSet(<int>{for (final m in modeRows) m.id!}),
            transaction: _transaction,
          );
    final modes = [
      for (final m in modeRows)
        modeConfigFromRow(m, [
          for (final s in spawnRows)
            if (s.modeConfigId == m.id) s,
        ]),
    ];

    final landmarks = await LandmarkRow.db.find(
      _session,
      where: (t) => t.revisionId.equals(revisionId),
      transaction: _transaction,
    );
    final credits = await CreditRow.db.find(
      _session,
      where: (t) => t.revisionId.equals(revisionId),
      transaction: _transaction,
    );

    return challengeRevisionFromRows(
      row: row,
      photo: asset(row.photoAssetId, 'photo_asset_id'),
      map: asset(row.mapAssetId, 'map_asset_id'),
      modes: modes,
      landmarks: landmarks,
      credits: credits,
      includeSecrets: includeSecrets,
    );
  }
}
