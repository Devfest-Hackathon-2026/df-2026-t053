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
import 'dart:async' as _ida;

import 'package:serverpod/serverpod.dart' as _is;

/// 出題の版。published_at を設定した後は内容を更新しない（公開処理 #26 が担保する）。
abstract class ChallengeRevisionRow
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  ChallengeRevisionRow._({
    this.id,
    required this.challengeId,
    required this.revisionNo,
    required this.sceneProfile,
    required this.scoringVersion,
    required this.photoAssetId,
    required this.mapAssetId,
    required this.photoAlt,
    required this.mapBoundsXz,
    required this.eyeHeightM,
    required this.shotFovDeg,
    required this.goalX,
    required this.goalY,
    required this.goalZ,
    required this.goalYawDeg,
    required this.goalPitchDeg,
    required this.story,
    required this.highlight,
    this.publishedAt,
    this.seedDigest,
    required this.createdAt,
  });

  factory ChallengeRevisionRow({
    int? id,
    required int challengeId,
    required int revisionNo,
    required String sceneProfile,
    required String scoringVersion,
    required int photoAssetId,
    required int mapAssetId,
    required String photoAlt,
    required String mapBoundsXz,
    required double eyeHeightM,
    required double shotFovDeg,
    required double goalX,
    required double goalY,
    required double goalZ,
    required double goalYawDeg,
    required double goalPitchDeg,
    required String story,
    required String highlight,
    DateTime? publishedAt,
    String? seedDigest,
    required DateTime createdAt,
  }) = _ChallengeRevisionRowImpl;

  factory ChallengeRevisionRow.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return ChallengeRevisionRow(
      id: jsonSerialization['id'] as int?,
      challengeId: jsonSerialization['challengeId'] as int,
      revisionNo: jsonSerialization['revisionNo'] as int,
      sceneProfile: jsonSerialization['sceneProfile'] as String,
      scoringVersion: jsonSerialization['scoringVersion'] as String,
      photoAssetId: jsonSerialization['photoAssetId'] as int,
      mapAssetId: jsonSerialization['mapAssetId'] as int,
      photoAlt: jsonSerialization['photoAlt'] as String,
      mapBoundsXz: jsonSerialization['mapBoundsXz'] as String,
      eyeHeightM: (jsonSerialization['eyeHeightM'] as num).toDouble(),
      shotFovDeg: (jsonSerialization['shotFovDeg'] as num).toDouble(),
      goalX: (jsonSerialization['goalX'] as num).toDouble(),
      goalY: (jsonSerialization['goalY'] as num).toDouble(),
      goalZ: (jsonSerialization['goalZ'] as num).toDouble(),
      goalYawDeg: (jsonSerialization['goalYawDeg'] as num).toDouble(),
      goalPitchDeg: (jsonSerialization['goalPitchDeg'] as num).toDouble(),
      story: jsonSerialization['story'] as String,
      highlight: jsonSerialization['highlight'] as String,
      publishedAt: jsonSerialization['publishedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['publishedAt'],
            ),
      seedDigest: jsonSerialization['seedDigest'] as String?,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = ChallengeRevisionRowTable();

  static const db = ChallengeRevisionRowRepository._();

  @override
  int? id;

  int challengeId;

  int revisionNo;

  String sceneProfile;

  String scoringVersion;

  int photoAssetId;

  int mapAssetId;

  String photoAlt;

  String mapBoundsXz;

  double eyeHeightM;

  double shotFovDeg;

  double goalX;

  double goalY;

  double goalZ;

  double goalYawDeg;

  double goalPitchDeg;

  String story;

  String highlight;

  DateTime? publishedAt;

  /// seed 入力（素材の内容を含む）を正規化した SHA-256。同じ版番号の再投入で内容を比べる（#26）。
  String? seedDigest;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [ChallengeRevisionRow]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ChallengeRevisionRow copyWith({
    int? id,
    int? challengeId,
    int? revisionNo,
    String? sceneProfile,
    String? scoringVersion,
    int? photoAssetId,
    int? mapAssetId,
    String? photoAlt,
    String? mapBoundsXz,
    double? eyeHeightM,
    double? shotFovDeg,
    double? goalX,
    double? goalY,
    double? goalZ,
    double? goalYawDeg,
    double? goalPitchDeg,
    String? story,
    String? highlight,
    DateTime? publishedAt = const _is.$UndefinedDateTime(),
    String? seedDigest,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ChallengeRevisionRow',
      if (id != null) 'id': id,
      'challengeId': challengeId,
      'revisionNo': revisionNo,
      'sceneProfile': sceneProfile,
      'scoringVersion': scoringVersion,
      'photoAssetId': photoAssetId,
      'mapAssetId': mapAssetId,
      'photoAlt': photoAlt,
      'mapBoundsXz': mapBoundsXz,
      'eyeHeightM': eyeHeightM,
      'shotFovDeg': shotFovDeg,
      'goalX': goalX,
      'goalY': goalY,
      'goalZ': goalZ,
      'goalYawDeg': goalYawDeg,
      'goalPitchDeg': goalPitchDeg,
      'story': story,
      'highlight': highlight,
      if (publishedAt != null) 'publishedAt': publishedAt?.toJson(),
      if (seedDigest != null) 'seedDigest': seedDigest,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static ChallengeRevisionRowInclude include() {
    return ChallengeRevisionRowInclude._();
  }

  static ChallengeRevisionRowIncludeList includeList({
    _is.WhereExpressionBuilder<ChallengeRevisionRowTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ChallengeRevisionRowTable>? orderBy,
    _is.OrderByListBuilder<ChallengeRevisionRowTable>? orderByList,
    ChallengeRevisionRowInclude? include,
  }) {
    return ChallengeRevisionRowIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ChallengeRevisionRow.t),
      orderByList: orderByList?.call(ChallengeRevisionRow.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ChallengeRevisionRowImpl extends ChallengeRevisionRow {
  _ChallengeRevisionRowImpl({
    int? id,
    required int challengeId,
    required int revisionNo,
    required String sceneProfile,
    required String scoringVersion,
    required int photoAssetId,
    required int mapAssetId,
    required String photoAlt,
    required String mapBoundsXz,
    required double eyeHeightM,
    required double shotFovDeg,
    required double goalX,
    required double goalY,
    required double goalZ,
    required double goalYawDeg,
    required double goalPitchDeg,
    required String story,
    required String highlight,
    DateTime? publishedAt,
    String? seedDigest,
    required DateTime createdAt,
  }) : super._(
         id: id,
         challengeId: challengeId,
         revisionNo: revisionNo,
         sceneProfile: sceneProfile,
         scoringVersion: scoringVersion,
         photoAssetId: photoAssetId,
         mapAssetId: mapAssetId,
         photoAlt: photoAlt,
         mapBoundsXz: mapBoundsXz,
         eyeHeightM: eyeHeightM,
         shotFovDeg: shotFovDeg,
         goalX: goalX,
         goalY: goalY,
         goalZ: goalZ,
         goalYawDeg: goalYawDeg,
         goalPitchDeg: goalPitchDeg,
         story: story,
         highlight: highlight,
         publishedAt: publishedAt,
         seedDigest: seedDigest,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [ChallengeRevisionRow]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ChallengeRevisionRow copyWith({
    Object? id = _Undefined,
    int? challengeId,
    int? revisionNo,
    String? sceneProfile,
    String? scoringVersion,
    int? photoAssetId,
    int? mapAssetId,
    String? photoAlt,
    String? mapBoundsXz,
    double? eyeHeightM,
    double? shotFovDeg,
    double? goalX,
    double? goalY,
    double? goalZ,
    double? goalYawDeg,
    double? goalPitchDeg,
    String? story,
    String? highlight,
    DateTime? publishedAt = const _is.$UndefinedDateTime(),
    Object? seedDigest = _Undefined,
    DateTime? createdAt,
  }) {
    return ChallengeRevisionRow(
      id: id is int? ? id : this.id,
      challengeId: challengeId ?? this.challengeId,
      revisionNo: revisionNo ?? this.revisionNo,
      sceneProfile: sceneProfile ?? this.sceneProfile,
      scoringVersion: scoringVersion ?? this.scoringVersion,
      photoAssetId: photoAssetId ?? this.photoAssetId,
      mapAssetId: mapAssetId ?? this.mapAssetId,
      photoAlt: photoAlt ?? this.photoAlt,
      mapBoundsXz: mapBoundsXz ?? this.mapBoundsXz,
      eyeHeightM: eyeHeightM ?? this.eyeHeightM,
      shotFovDeg: shotFovDeg ?? this.shotFovDeg,
      goalX: goalX ?? this.goalX,
      goalY: goalY ?? this.goalY,
      goalZ: goalZ ?? this.goalZ,
      goalYawDeg: goalYawDeg ?? this.goalYawDeg,
      goalPitchDeg: goalPitchDeg ?? this.goalPitchDeg,
      story: story ?? this.story,
      highlight: highlight ?? this.highlight,
      publishedAt: publishedAt is _is.UndefinedSentinel
          ? this.publishedAt
          : publishedAt,
      seedDigest: seedDigest is String? ? seedDigest : this.seedDigest,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ChallengeRevisionRowUpdateTable
    extends _is.UpdateTable<ChallengeRevisionRowTable> {
  ChallengeRevisionRowUpdateTable(super.table);

  _is.ColumnValue<int, int> challengeId(int value) =>
      _is.ColumnValue(table.challengeId, value);

  _is.ColumnValue<int, int> revisionNo(int value) =>
      _is.ColumnValue(table.revisionNo, value);

  _is.ColumnValue<String, String> sceneProfile(String value) =>
      _is.ColumnValue(table.sceneProfile, value);

  _is.ColumnValue<String, String> scoringVersion(String value) =>
      _is.ColumnValue(table.scoringVersion, value);

  _is.ColumnValue<int, int> photoAssetId(int value) =>
      _is.ColumnValue(table.photoAssetId, value);

  _is.ColumnValue<int, int> mapAssetId(int value) =>
      _is.ColumnValue(table.mapAssetId, value);

  _is.ColumnValue<String, String> photoAlt(String value) =>
      _is.ColumnValue(table.photoAlt, value);

  _is.ColumnValue<String, String> mapBoundsXz(String value) =>
      _is.ColumnValue(table.mapBoundsXz, value);

  _is.ColumnValue<double, double> eyeHeightM(double value) =>
      _is.ColumnValue(table.eyeHeightM, value);

  _is.ColumnValue<double, double> shotFovDeg(double value) =>
      _is.ColumnValue(table.shotFovDeg, value);

  _is.ColumnValue<double, double> goalX(double value) =>
      _is.ColumnValue(table.goalX, value);

  _is.ColumnValue<double, double> goalY(double value) =>
      _is.ColumnValue(table.goalY, value);

  _is.ColumnValue<double, double> goalZ(double value) =>
      _is.ColumnValue(table.goalZ, value);

  _is.ColumnValue<double, double> goalYawDeg(double value) =>
      _is.ColumnValue(table.goalYawDeg, value);

  _is.ColumnValue<double, double> goalPitchDeg(double value) =>
      _is.ColumnValue(table.goalPitchDeg, value);

  _is.ColumnValue<String, String> story(String value) =>
      _is.ColumnValue(table.story, value);

  _is.ColumnValue<String, String> highlight(String value) =>
      _is.ColumnValue(table.highlight, value);

  _is.ColumnValue<DateTime, DateTime> publishedAt(DateTime? value) =>
      _is.ColumnValue(table.publishedAt, value);

  _is.ColumnValue<String, String> seedDigest(String? value) =>
      _is.ColumnValue(table.seedDigest, value);

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(table.createdAt, value);
}

class ChallengeRevisionRowTable extends _is.Table<int?> {
  ChallengeRevisionRowTable({super.tableRelation})
    : super(tableName: 'challenge_revision') {
    updateTable = ChallengeRevisionRowUpdateTable(this);
    challengeId = _is.ColumnInt('challenge_id', this, fieldName: 'challengeId');
    revisionNo = _is.ColumnInt('revision_no', this, fieldName: 'revisionNo');
    sceneProfile = _is.ColumnString(
      'scene_profile',
      this,
      fieldName: 'sceneProfile',
    );
    scoringVersion = _is.ColumnString(
      'scoring_version',
      this,
      fieldName: 'scoringVersion',
    );
    photoAssetId = _is.ColumnInt(
      'photo_asset_id',
      this,
      fieldName: 'photoAssetId',
    );
    mapAssetId = _is.ColumnInt('map_asset_id', this, fieldName: 'mapAssetId');
    photoAlt = _is.ColumnString('photo_alt', this, fieldName: 'photoAlt');
    mapBoundsXz = _is.ColumnString(
      'map_bounds_xz',
      this,
      fieldName: 'mapBoundsXz',
    );
    eyeHeightM = _is.ColumnDouble(
      'eye_height_m',
      this,
      fieldName: 'eyeHeightM',
    );
    shotFovDeg = _is.ColumnDouble(
      'shot_fov_deg',
      this,
      fieldName: 'shotFovDeg',
    );
    goalX = _is.ColumnDouble('goal_x', this, fieldName: 'goalX');
    goalY = _is.ColumnDouble('goal_y', this, fieldName: 'goalY');
    goalZ = _is.ColumnDouble('goal_z', this, fieldName: 'goalZ');
    goalYawDeg = _is.ColumnDouble(
      'goal_yaw_deg',
      this,
      fieldName: 'goalYawDeg',
    );
    goalPitchDeg = _is.ColumnDouble(
      'goal_pitch_deg',
      this,
      fieldName: 'goalPitchDeg',
    );
    story = _is.ColumnString('story', this);
    highlight = _is.ColumnString('highlight', this);
    publishedAt = _is.ColumnDateTime(
      'published_at',
      this,
      fieldName: 'publishedAt',
    );
    seedDigest = _is.ColumnString('seed_digest', this, fieldName: 'seedDigest');
    createdAt = _is.ColumnDateTime('created_at', this, fieldName: 'createdAt');
  }

  late final ChallengeRevisionRowUpdateTable updateTable;

  late final _is.ColumnInt challengeId;

  late final _is.ColumnInt revisionNo;

  late final _is.ColumnString sceneProfile;

  late final _is.ColumnString scoringVersion;

  late final _is.ColumnInt photoAssetId;

  late final _is.ColumnInt mapAssetId;

  late final _is.ColumnString photoAlt;

  late final _is.ColumnString mapBoundsXz;

  late final _is.ColumnDouble eyeHeightM;

  late final _is.ColumnDouble shotFovDeg;

  late final _is.ColumnDouble goalX;

  late final _is.ColumnDouble goalY;

  late final _is.ColumnDouble goalZ;

  late final _is.ColumnDouble goalYawDeg;

  late final _is.ColumnDouble goalPitchDeg;

  late final _is.ColumnString story;

  late final _is.ColumnString highlight;

  late final _is.ColumnDateTime publishedAt;

  /// seed 入力（素材の内容を含む）を正規化した SHA-256。同じ版番号の再投入で内容を比べる（#26）。
  late final _is.ColumnString seedDigest;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    challengeId,
    revisionNo,
    sceneProfile,
    scoringVersion,
    photoAssetId,
    mapAssetId,
    photoAlt,
    mapBoundsXz,
    eyeHeightM,
    shotFovDeg,
    goalX,
    goalY,
    goalZ,
    goalYawDeg,
    goalPitchDeg,
    story,
    highlight,
    publishedAt,
    seedDigest,
    createdAt,
  ];
}

class ChallengeRevisionRowInclude extends _is.IncludeObject {
  ChallengeRevisionRowInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => ChallengeRevisionRow.t;
}

class ChallengeRevisionRowIncludeList extends _is.IncludeList {
  ChallengeRevisionRowIncludeList._({
    _is.WhereExpressionBuilder<ChallengeRevisionRowTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ChallengeRevisionRow.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => ChallengeRevisionRow.t;
}

class ChallengeRevisionRowRepository {
  const ChallengeRevisionRowRepository._();

  /// Returns a list of [ChallengeRevisionRow]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<ChallengeRevisionRow>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ChallengeRevisionRowTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ChallengeRevisionRowTable>? orderBy,
    _is.OrderByListBuilder<ChallengeRevisionRowTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ChallengeRevisionRow>(
      where: where?.call(ChallengeRevisionRow.t),
      orderBy: orderBy?.call(ChallengeRevisionRow.t),
      orderByList: orderByList?.call(ChallengeRevisionRow.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [ChallengeRevisionRow]s matching the given query parameters every time the
  /// source tables are modified.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// Use [throttle] to specify the minimum interval between queries. It can
  /// also be set to `null`, in which case the stream will only be throttled
  /// when its subscription is paused.
  ///
  /// Source tables are collected from the queried table, [where], [orderBy],
  /// [orderByList], and the [include] graph. [alsoTriggerOnTables] is added
  /// to that set. Pass [Table] instances such as `ChallengeRevisionRow.t`.
  ///
  /// Raw [Expression] SQL is not inspected. Tables referenced only in raw
  /// SQL must be passed via [alsoTriggerOnTables].
  ///
  /// The stream always reads committed state and never joins an ambient
  /// [Transaction]. Emissions for a write fire after that write commits.
  ///
  /// Currently only supported on SQLite. Calling this method on PostgreSQL
  /// throws an [UnsupportedError].
  ///
  /// ```dart
  /// var subscription = Persons.db.watch(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// ).listen((persons) {
  ///   // Handle the latest matching rows.
  /// });
  /// ```
  _ida.Stream<List<ChallengeRevisionRow>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ChallengeRevisionRowTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ChallengeRevisionRowTable>? orderBy,
    _is.OrderByListBuilder<ChallengeRevisionRowTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<ChallengeRevisionRow>(
      where: where?.call(ChallengeRevisionRow.t),
      orderBy: orderBy?.call(ChallengeRevisionRow.t),
      orderByList: orderByList?.call(ChallengeRevisionRow.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [ChallengeRevisionRow] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<ChallengeRevisionRow?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ChallengeRevisionRowTable>? where,
    int? offset,
    _is.OrderByBuilder<ChallengeRevisionRowTable>? orderBy,
    _is.OrderByListBuilder<ChallengeRevisionRowTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ChallengeRevisionRow>(
      where: where?.call(ChallengeRevisionRow.t),
      orderBy: orderBy?.call(ChallengeRevisionRow.t),
      orderByList: orderByList?.call(ChallengeRevisionRow.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ChallengeRevisionRow] by its [id] or null if no such row exists.
  Future<ChallengeRevisionRow?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ChallengeRevisionRow>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ChallengeRevisionRow]s in the list and returns the inserted rows.
  ///
  /// The returned [ChallengeRevisionRow]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  ///
  /// If [noReturn] is set to `true`, the inserted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ChallengeRevisionRow>> insert(
    _is.DatabaseSession session,
    List<ChallengeRevisionRow> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<ChallengeRevisionRow>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [ChallengeRevisionRow] and returns the inserted row.
  ///
  /// The returned [ChallengeRevisionRow] will have its `id` field set.
  Future<ChallengeRevisionRow> insertRow(
    _is.DatabaseSession session,
    ChallengeRevisionRow row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<ChallengeRevisionRow>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [ChallengeRevisionRow]s in the list and returns the resulting rows.
  ///
  /// If a row conflicts on the given [conflictColumns], the existing row is
  /// updated with the new values. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies to rows matching the
  /// given expression. Conflicting rows that don't match are skipped and not
  /// returned, so the resulting list may be shorter than [rows].
  ///
  /// The returned [ChallengeRevisionRow]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ChallengeRevisionRow>> upsert(
    _is.DatabaseSession session,
    List<ChallengeRevisionRow> rows, {
    required _is.ColumnSelections<ChallengeRevisionRowTable> conflictColumns,
    _is.ColumnSelections<ChallengeRevisionRowTable>? updateColumns,
    _is.WhereExpressionBuilder<ChallengeRevisionRowTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<ChallengeRevisionRow>(
      rows,
      conflictColumns: conflictColumns(ChallengeRevisionRow.t),
      updateColumns: updateColumns?.call(ChallengeRevisionRow.t),
      updateWhere: updateWhere?.call(ChallengeRevisionRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [ChallengeRevisionRow] and returns the resulting row.
  ///
  /// If the row conflicts on the given [conflictColumns], the existing row is
  /// updated. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies when the existing
  /// row matches the expression. Returns `null` if no row was affected — for
  /// example when [updateWhere] does not match the conflicting row.
  ///
  /// The returned [ChallengeRevisionRow] will have its `id` field set.
  Future<ChallengeRevisionRow?> upsertRow(
    _is.DatabaseSession session,
    ChallengeRevisionRow row, {
    required _is.ColumnSelections<ChallengeRevisionRowTable> conflictColumns,
    _is.ColumnSelections<ChallengeRevisionRowTable>? updateColumns,
    _is.WhereExpressionBuilder<ChallengeRevisionRowTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<ChallengeRevisionRow>(
      row,
      conflictColumns: conflictColumns(ChallengeRevisionRow.t),
      updateColumns: updateColumns?.call(ChallengeRevisionRow.t),
      updateWhere: updateWhere?.call(ChallengeRevisionRow.t),
      transaction: transaction,
    );
  }

  /// Updates all [ChallengeRevisionRow]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ChallengeRevisionRow>> update(
    _is.DatabaseSession session,
    List<ChallengeRevisionRow> rows, {
    _is.ColumnSelections<ChallengeRevisionRowTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<ChallengeRevisionRow>(
      rows,
      columns: columns?.call(ChallengeRevisionRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [ChallengeRevisionRow]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ChallengeRevisionRow> updateRow(
    _is.DatabaseSession session,
    ChallengeRevisionRow row, {
    _is.ColumnSelections<ChallengeRevisionRowTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<ChallengeRevisionRow>(
      row,
      columns: columns?.call(ChallengeRevisionRow.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ChallengeRevisionRow] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ChallengeRevisionRow?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<ChallengeRevisionRowUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<ChallengeRevisionRow>(
      id,
      columnValues: columnValues(ChallengeRevisionRow.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ChallengeRevisionRow]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ChallengeRevisionRow>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ChallengeRevisionRowUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<ChallengeRevisionRowTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ChallengeRevisionRowTable>? orderBy,
    _is.OrderByListBuilder<ChallengeRevisionRowTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<ChallengeRevisionRow>(
      columnValues: columnValues(ChallengeRevisionRow.t.updateTable),
      where: where(ChallengeRevisionRow.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ChallengeRevisionRow.t),
      orderByList: orderByList?.call(ChallengeRevisionRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [ChallengeRevisionRow]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ChallengeRevisionRow>> delete(
    _is.DatabaseSession session,
    List<ChallengeRevisionRow> rows, {
    _is.OrderByBuilder<ChallengeRevisionRowTable>? orderBy,
    _is.OrderByListBuilder<ChallengeRevisionRowTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<ChallengeRevisionRow>(
      rows,
      orderBy: orderBy?.call(ChallengeRevisionRow.t),
      orderByList: orderByList?.call(ChallengeRevisionRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [ChallengeRevisionRow].
  Future<ChallengeRevisionRow> deleteRow(
    _is.DatabaseSession session,
    ChallengeRevisionRow row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ChallengeRevisionRow>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ChallengeRevisionRow>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ChallengeRevisionRowTable> where,
    _is.OrderByBuilder<ChallengeRevisionRowTable>? orderBy,
    _is.OrderByListBuilder<ChallengeRevisionRowTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<ChallengeRevisionRow>(
      where: where(ChallengeRevisionRow.t),
      orderBy: orderBy?.call(ChallengeRevisionRow.t),
      orderByList: orderByList?.call(ChallengeRevisionRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ChallengeRevisionRowTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<ChallengeRevisionRow>(
      where: where?.call(ChallengeRevisionRow.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ChallengeRevisionRow] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ChallengeRevisionRowTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ChallengeRevisionRow>(
      where: where(ChallengeRevisionRow.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
