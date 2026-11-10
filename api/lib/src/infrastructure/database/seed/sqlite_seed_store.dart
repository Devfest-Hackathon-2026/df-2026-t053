import 'package:photohunt_shared/photohunt_shared.dart' show PlayMode;
import 'package:sqlite3/sqlite3.dart';

import '../../../application/seed/seed_ports.dart';
import '../../../application/seed/seed_input.dart';
import '../mappers/json_columns.dart';

/// [SeedStore] の SQLite 実装。管理用 CLI（`bin/seed.dart`）だけが使う。
///
/// API の Serverpod とは別プロセスで、writer 所有権を取ったうえで DB ファイルを直接開く
/// （`scripts/seed.sh`）。ORM は Serverpod の起動を前提にするので使わない。
/// 列名は `infrastructure/database/tables/*.spy.yaml` と同じ。
class SqliteSeedStore(final Database _db) implements SeedStore {
  /// [path] の DB を開く。外部キーを有効にし、書き込み待ちは 5 秒まで待つ。
  factory open(String path) {
    final db = sqlite3.open(path, mode: OpenMode.readWrite);
    db.execute('PRAGMA foreign_keys = ON;');
    db.execute('PRAGMA busy_timeout = 5000;');
    return SqliteSeedStore(db);
  }

  void close() => _db.close();

  @override
  Future<String?> findAssetObjectPath(String sha256) async {
    final rows = _db.select('SELECT object_path FROM asset WHERE sha256 = ?', [
      sha256,
    ]);
    return rows.isEmpty ? null : rows.single['object_path'] as String;
  }

  @override
  Future<Set<String>> pavilionKeys() async => {
    for (final row in _db.select('SELECT source_key FROM pavilion'))
      row['source_key'] as String,
  };

  @override
  Future<
    ({SeedLoadOutcome outcome, int revisionId, SeedPublishOutcome? published})
  >
  loadDraft(SeedDraft draft, {bool publish = false}) async =>
      // 公開まで求めるときは同じトランザクションで行う。公開に失敗したら下書きも残さない。
      _transaction(() {
        final loaded = _loadDraft(draft);
        final published = publish
            ? _publish(
                slug: draft.input.slug,
                revisionNo: draft.input.revisionNo,
                now: draft.now,
              )
            : null;
        return (
          outcome: loaded.outcome,
          revisionId: loaded.revisionId,
          published: published,
        );
      });

  ({SeedLoadOutcome outcome, int revisionId}) _loadDraft(SeedDraft draft) {
    final now = draft.now.millisecondsSinceEpoch;
    final input = draft.input;

    for (final p in draft.pavilions) {
      _upsertPavilion(p);
    }
    final photoId = _ensureAsset(draft.photo, now);
    final mapId = _ensureAsset(draft.map, now);

    _checkConflicts(input, draft.digest);
    final challengeId = _challengeId(input.slug);
    final int cid;
    if (challengeId == null) {
      _db.execute(
        'INSERT INTO challenge (slug, title, created_at) VALUES (?, ?, ?)',
        [input.slug, input.title, now],
      );
      cid = _db.lastInsertRowId;
    } else {
      // 題名は出題に 1 つ。版がない（全て delete-draft した）出題だけ、この入力の題名に合わせる。
      // 版がある出題で題名が違う登録は _checkConflicts が拒否している。
      _db.execute(
        'UPDATE challenge SET title = ? WHERE id = ? AND title <> ?',
        [input.title, challengeId, input.title],
      );
      cid = challengeId;
      final existing = _db.select(
        'SELECT id FROM challenge_revision WHERE challenge_id = ? AND revision_no = ?',
        [challengeId, input.revisionNo],
      );
      if (existing.isNotEmpty) {
        // _checkConflicts で digest の一致を確かめてある。
        return (
          outcome: SeedLoadOutcome.unchanged,
          revisionId: existing.single['id'] as int,
        );
      }
    }

    final goal = input.goal;
    _db.execute(
      'INSERT INTO challenge_revision ('
      'challenge_id, revision_no, scene_profile, scoring_version, '
      'photo_asset_id, map_asset_id, photo_alt, map_bounds_xz, '
      'eye_height_m, shot_fov_deg, goal_x, goal_y, goal_z, '
      'goal_yaw_deg, goal_pitch_deg, story, highlight, '
      'published_at, seed_digest, created_at'
      ') VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NULL, ?, ?)',
      [
        cid,
        input.revisionNo,
        input.sceneProfile,
        input.scoringVersion,
        photoId,
        mapId,
        input.photoAlt,
        mapBoundsToJson(input.bounds),
        input.eyeHeightMeters,
        input.shotVerticalFovDegrees,
        goal.x,
        goal.y,
        goal.z,
        goal.yawDegrees,
        goal.pitchDegrees,
        input.story,
        input.highlight,
        draft.digest,
        now,
      ],
    );
    final revisionId = _db.lastInsertRowId;

    for (final mode in input.modes) {
      _db.execute(
        'INSERT INTO mode_config (revision_id, mode, walkable) VALUES (?, ?, ?)',
        [revisionId, _modeName(mode.mode), walkableToJson(mode.walkable)],
      );
      final modeId = _db.lastInsertRowId;
      for (var i = 0; i < mode.spawns.length; i++) {
        final s = mode.spawns[i];
        _db.execute(
          'INSERT INTO spawn_point '
          '(mode_config_id, x, y, z, yaw_deg, sort_order, label) '
          'VALUES (?, ?, ?, ?, ?, ?, ?)',
          [
            modeId,
            s.positionX,
            s.positionY,
            s.positionZ,
            s.yawDegrees,
            i,
            s.label,
          ],
        );
      }
    }

    for (final l in input.landmarks) {
      _db.execute(
        'INSERT INTO landmark (revision_id, pavilion_id, display_name, pos_x, pos_z, lat, lon) '
        'VALUES (?, ?, ?, ?, ?, ?, ?)',
        [
          revisionId,
          _pavilionId(l.pavilionKey),
          l.displayName,
          l.positionX,
          l.positionZ,
          l.latitude,
          l.longitude,
        ],
      );
    }

    for (var i = 0; i < input.credits.length; i++) {
      final c = input.credits[i];
      _db.execute(
        'INSERT INTO credit (revision_id, name, url, sort_order) VALUES (?, ?, ?, ?)',
        [revisionId, c.name, c.url, i],
      );
    }

    for (final s in input.structures) {
      final key = s.pavilionKey;
      _db.execute(
        'INSERT INTO structure (revision_id, pavilion_id, name, pos_x, pos_z, facts, fallback_text) '
        'VALUES (?, ?, ?, ?, ?, ?, ?)',
        [
          revisionId,
          key == null ? null : _pavilionId(key),
          s.name,
          s.positionX,
          s.positionZ,
          s.facts,
          s.fallbackText,
        ],
      );
      final structureId = _db.lastInsertRowId;
      for (var i = 0; i < s.sources.length; i++) {
        final source = s.sources[i];
        _db.execute(
          'INSERT INTO structure_source (structure_id, title, url, sort_order) '
          'VALUES (?, ?, ?, ?)',
          [structureId, source.title, source.url, i],
        );
      }
    }

    return (outcome: SeedLoadOutcome.inserted, revisionId: revisionId);
  }

  @override
  Future<SeedPublishOutcome> publish({
    required String slug,
    required int revisionNo,
    required DateTime now,
  }) async => _transaction(
    () => _publish(slug: slug, revisionNo: revisionNo, now: now),
  );

  SeedPublishOutcome _publish({
    required String slug,
    required int revisionNo,
    required DateTime now,
  }) {
    final challenge = _challenge(slug);
    final challengeId = challenge['id'] as int;
    final revision = _revision(challengeId, slug, revisionNo);
    final revisionId = revision['id'] as int;

    _checkNoOtherPublished(slug);
    if (challenge['current_revision_id'] == revisionId) {
      return SeedPublishOutcome.unchanged;
    }

    final wasDraft = revision['published_at'] == null;
    if (wasDraft) {
      _db.execute(
        'UPDATE challenge_revision SET published_at = ? WHERE id = ?',
        [now.toUtc().millisecondsSinceEpoch, revisionId],
      );
    }
    _db.execute('UPDATE challenge SET current_revision_id = ? WHERE id = ?', [
      revisionId,
      challengeId,
    ]);

    final current = _db.select(
      'SELECT count(*) AS n FROM challenge WHERE current_revision_id IS NOT NULL',
    );
    if (current.single['n'] != 1) {
      throw const SeedConflictException('公開中の出題が 1 件にならない');
    }
    return wasDraft
        ? SeedPublishOutcome.published
        : SeedPublishOutcome.switched;
  }

  @override
  Future<void> unpublish({required String slug}) async => _transaction(() {
    final challenge = _challenge(slug);
    _db.execute(
      'UPDATE challenge SET current_revision_id = NULL WHERE id = ?',
      [challenge['id']],
    );
  });

  @override
  Future<void> deleteDraft({
    required String slug,
    required int revisionNo,
  }) async => _transaction(() {
    final challenge = _challenge(slug);
    final revision = _revision(challenge['id'] as int, slug, revisionNo);
    if (revision['published_at'] != null) {
      throw SeedConflictException('$slug r$revisionNo は公開済みなので削除できない');
    }
    // 子（モード・開始点・地点・出典・構造物）は Cascade で消える。
    _db.execute('DELETE FROM challenge_revision WHERE id = ?', [
      revision['id'],
    ]);
  });

  @override
  Future<void> checkDraft(
    SeedRevision input,
    String digest, {
    bool publish = false,
  }) async {
    _checkConflicts(input, digest);
    if (publish) _checkNoOtherPublished(input.slug);
  }

  /// 提出版で公開中にできる出題は 1 件だけ。[slug] 以外の出題が公開中なら衝突にする。
  void _checkNoOtherPublished(String slug) {
    final others = _db.select(
      'SELECT slug FROM challenge WHERE current_revision_id IS NOT NULL AND slug <> ?',
      [slug],
    );
    if (others.isNotEmpty) {
      throw SeedConflictException(
        '別の出題が公開中（${others.map((r) => r['slug']).join(', ')}）。'
        '提出版で公開中にできる出題は 1 件だけなので、先に unpublish する',
      );
    }
  }

  /// 登録済みの内容と両立しないなら [SeedConflictException]。DB は変えない。
  ///
  /// - 同じ版番号が別の内容（digest）で登録済み。
  /// - 版が登録済みの出題の題名を変えようとしている。題名は出題に 1 つなので、どの版の入力も
  ///   出題の題名と同じにする（別の版の題名で公開されたり、再投入が衝突したりしないように）。
  void _checkConflicts(SeedRevision input, String digest) {
    final rows = _db.select('SELECT id, title FROM challenge WHERE slug = ?', [
      input.slug,
    ]);
    if (rows.isEmpty) return;
    final challenge = rows.single;
    final existing = _db.select(
      'SELECT seed_digest FROM challenge_revision '
      'WHERE challenge_id = ? AND revision_no = ?',
      [challenge['id'], input.revisionNo],
    );
    if (existing.isNotEmpty && existing.single['seed_digest'] != digest) {
      throw SeedConflictException(
        '${input.slug} r${input.revisionNo} は別の内容で登録済み。'
        '修正は新しい版番号で登録する',
      );
    }
    if (challenge['title'] != input.title) {
      final revisions = _db.select(
        'SELECT 1 FROM challenge_revision WHERE challenge_id = ? LIMIT 1',
        [challenge['id']],
      );
      if (revisions.isNotEmpty) {
        throw SeedConflictException(
          '${input.slug} には登録済みの版があるため、題名を「${challenge['title']}」から'
          '「${input.title}」へ変えられない（題名は出題に 1 つで、全ての版の入力をそろえる。'
          '変えるには未公開の版を delete-draft するか、別の slug にする）',
        );
      }
    }
  }

  /// 1 トランザクションで実行する。書き込みの競合は開始時に検出する（BEGIN IMMEDIATE）。
  T _transaction<T>(T Function() body) {
    _db.execute('BEGIN IMMEDIATE;');
    try {
      final result = body();
      _db.execute('COMMIT;');
      return result;
    } on Object {
      // SQLite が自分でロールバックすることがある（RAISE(ROLLBACK)、ディスクフル、I/O エラー）。
      // そのときの ROLLBACK は失敗し、元のエラーを隠してしまうので、取り消されていなければ行う。
      if (!_db.autocommit) _db.execute('ROLLBACK;');
      rethrow;
    }
  }

  void _upsertPavilion(SeedPavilion p) {
    final rows = _db.select(
      'SELECT id, name, lat, lon FROM pavilion WHERE source_key = ?',
      [p.sourceKey],
    );
    if (rows.isEmpty) {
      _db.execute(
        'INSERT INTO pavilion (source_key, name, lat, lon) VALUES (?, ?, ?, ?)',
        [p.sourceKey, p.name, p.latitude, p.longitude],
      );
      return;
    }
    final row = rows.single;
    // マスターは版に固定しない参照データ。版の地点は名前と座標を自分で持つ。
    if (row['name'] != p.name ||
        row['lat'] != p.latitude ||
        row['lon'] != p.longitude) {
      _db.execute(
        'UPDATE pavilion SET name = ?, lat = ?, lon = ? WHERE id = ?',
        [p.name, p.latitude, p.longitude, row['id']],
      );
    }
  }

  int _ensureAsset(SeedAssetRecord asset, int now) {
    final rows = _db.select(
      'SELECT id, object_path, content_type, byte_length FROM asset WHERE sha256 = ?',
      [asset.sha256],
    );
    if (rows.isEmpty) {
      _db.execute(
        'INSERT INTO asset (sha256, object_path, content_type, byte_length, created_at) '
        'VALUES (?, ?, ?, ?, ?)',
        [
          asset.sha256,
          asset.objectPath,
          asset.contentType,
          asset.byteLength,
          now,
        ],
      );
      return _db.lastInsertRowId;
    }
    final row = rows.single;
    if (row['object_path'] != asset.objectPath ||
        row['content_type'] != asset.contentType ||
        row['byte_length'] != asset.byteLength) {
      throw SeedConflictException(
        '素材 ${asset.sha256} は別のメタデータで登録済み'
        '（${row['object_path']}, ${row['content_type']}, ${row['byte_length']}）',
      );
    }
    return row['id'] as int;
  }

  int? _challengeId(String slug) {
    final rows = _db.select('SELECT id FROM challenge WHERE slug = ?', [slug]);
    return rows.isEmpty ? null : rows.single['id'] as int;
  }

  Row _challenge(String slug) {
    final rows = _db.select(
      'SELECT id, current_revision_id FROM challenge WHERE slug = ?',
      [slug],
    );
    if (rows.isEmpty) throw SeedNotFoundException('出題 $slug がない');
    return rows.single;
  }

  Row _revision(int challengeId, String slug, int revisionNo) {
    final rows = _db.select(
      'SELECT id, published_at FROM challenge_revision '
      'WHERE challenge_id = ? AND revision_no = ?',
      [challengeId, revisionNo],
    );
    if (rows.isEmpty) throw SeedNotFoundException('版 $slug r$revisionNo がない');
    return rows.single;
  }

  int _pavilionId(String sourceKey) {
    final rows = _db.select('SELECT id FROM pavilion WHERE source_key = ?', [
      sourceKey,
    ]);
    if (rows.isEmpty) {
      // 検証で弾いているので来ない。
      throw SeedNotFoundException('pavilion $sourceKey がない');
    }
    return rows.single['id'] as int;
  }

  /// Serverpod の enum 列（`serialized: byName`）と同じ表現。
  String _modeName(PlayMode mode) => mode.name;
}
