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

/// 撮影の確定結果。1 プレイに 1 行で、書き換えない。score は 0〜1000。
abstract class ShotRow
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  ShotRow._({
    this.id,
    required this.requestId,
    required this.playSessionId,
    required this.x,
    required this.y,
    required this.z,
    required this.yawDeg,
    required this.pitchDeg,
    required this.fovDeg,
    required this.distanceM,
    required this.yawDiffDeg,
    required this.pitchDiffDeg,
    required this.score,
    required this.rankAtSubmission,
    required this.bestScoreAtSubmission,
    required this.nicknameAtSubmission,
    required this.bestAchieveTimeAtSubmission,
    required this.createdAt,
  });

  factory ShotRow({
    int? id,
    required _is.UuidValue requestId,
    required _is.UuidValue playSessionId,
    required double x,
    required double y,
    required double z,
    required double yawDeg,
    required double pitchDeg,
    required double fovDeg,
    required double distanceM,
    required double yawDiffDeg,
    required double pitchDiffDeg,
    required int score,
    required int rankAtSubmission,
    required int bestScoreAtSubmission,
    required String nicknameAtSubmission,
    required DateTime bestAchieveTimeAtSubmission,
    required DateTime createdAt,
  }) = _ShotRowImpl;

  factory ShotRow.fromJson(Map<String, dynamic> jsonSerialization) {
    return ShotRow(
      id: jsonSerialization['id'] as int?,
      requestId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['requestId'],
      ),
      playSessionId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['playSessionId'],
      ),
      x: (jsonSerialization['x'] as num).toDouble(),
      y: (jsonSerialization['y'] as num).toDouble(),
      z: (jsonSerialization['z'] as num).toDouble(),
      yawDeg: (jsonSerialization['yawDeg'] as num).toDouble(),
      pitchDeg: (jsonSerialization['pitchDeg'] as num).toDouble(),
      fovDeg: (jsonSerialization['fovDeg'] as num).toDouble(),
      distanceM: (jsonSerialization['distanceM'] as num).toDouble(),
      yawDiffDeg: (jsonSerialization['yawDiffDeg'] as num).toDouble(),
      pitchDiffDeg: (jsonSerialization['pitchDiffDeg'] as num).toDouble(),
      score: jsonSerialization['score'] as int,
      rankAtSubmission: jsonSerialization['rankAtSubmission'] as int,
      bestScoreAtSubmission: jsonSerialization['bestScoreAtSubmission'] as int,
      nicknameAtSubmission: jsonSerialization['nicknameAtSubmission'] as String,
      bestAchieveTimeAtSubmission: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['bestAchieveTimeAtSubmission'],
      ),
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = ShotRowTable();

  static const db = ShotRowRepository._();

  @override
  int? id;

  _is.UuidValue requestId;

  _is.UuidValue playSessionId;

  double x;

  double y;

  double z;

  double yawDeg;

  double pitchDeg;

  double fovDeg;

  double distanceM;

  double yawDiffDeg;

  double pitchDiffDeg;

  int score;

  int rankAtSubmission;

  int bestScoreAtSubmission;

  String nicknameAtSubmission;

  DateTime bestAchieveTimeAtSubmission;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [ShotRow]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ShotRow copyWith({
    int? id,
    _is.UuidValue? requestId,
    _is.UuidValue? playSessionId,
    double? x,
    double? y,
    double? z,
    double? yawDeg,
    double? pitchDeg,
    double? fovDeg,
    double? distanceM,
    double? yawDiffDeg,
    double? pitchDiffDeg,
    int? score,
    int? rankAtSubmission,
    int? bestScoreAtSubmission,
    String? nicknameAtSubmission,
    DateTime? bestAchieveTimeAtSubmission,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ShotRow',
      if (id != null) 'id': id,
      'requestId': requestId.toJson(),
      'playSessionId': playSessionId.toJson(),
      'x': x,
      'y': y,
      'z': z,
      'yawDeg': yawDeg,
      'pitchDeg': pitchDeg,
      'fovDeg': fovDeg,
      'distanceM': distanceM,
      'yawDiffDeg': yawDiffDeg,
      'pitchDiffDeg': pitchDiffDeg,
      'score': score,
      'rankAtSubmission': rankAtSubmission,
      'bestScoreAtSubmission': bestScoreAtSubmission,
      'nicknameAtSubmission': nicknameAtSubmission,
      'bestAchieveTimeAtSubmission': bestAchieveTimeAtSubmission.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static ShotRowInclude include() {
    return ShotRowInclude._();
  }

  static ShotRowIncludeList includeList({
    _is.WhereExpressionBuilder<ShotRowTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ShotRowTable>? orderBy,
    _is.OrderByListBuilder<ShotRowTable>? orderByList,
    ShotRowInclude? include,
  }) {
    return ShotRowIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ShotRow.t),
      orderByList: orderByList?.call(ShotRow.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ShotRowImpl extends ShotRow {
  _ShotRowImpl({
    int? id,
    required _is.UuidValue requestId,
    required _is.UuidValue playSessionId,
    required double x,
    required double y,
    required double z,
    required double yawDeg,
    required double pitchDeg,
    required double fovDeg,
    required double distanceM,
    required double yawDiffDeg,
    required double pitchDiffDeg,
    required int score,
    required int rankAtSubmission,
    required int bestScoreAtSubmission,
    required String nicknameAtSubmission,
    required DateTime bestAchieveTimeAtSubmission,
    required DateTime createdAt,
  }) : super._(
         id: id,
         requestId: requestId,
         playSessionId: playSessionId,
         x: x,
         y: y,
         z: z,
         yawDeg: yawDeg,
         pitchDeg: pitchDeg,
         fovDeg: fovDeg,
         distanceM: distanceM,
         yawDiffDeg: yawDiffDeg,
         pitchDiffDeg: pitchDiffDeg,
         score: score,
         rankAtSubmission: rankAtSubmission,
         bestScoreAtSubmission: bestScoreAtSubmission,
         nicknameAtSubmission: nicknameAtSubmission,
         bestAchieveTimeAtSubmission: bestAchieveTimeAtSubmission,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [ShotRow]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ShotRow copyWith({
    Object? id = _Undefined,
    _is.UuidValue? requestId,
    _is.UuidValue? playSessionId,
    double? x,
    double? y,
    double? z,
    double? yawDeg,
    double? pitchDeg,
    double? fovDeg,
    double? distanceM,
    double? yawDiffDeg,
    double? pitchDiffDeg,
    int? score,
    int? rankAtSubmission,
    int? bestScoreAtSubmission,
    String? nicknameAtSubmission,
    DateTime? bestAchieveTimeAtSubmission,
    DateTime? createdAt,
  }) {
    return ShotRow(
      id: id is int? ? id : this.id,
      requestId: requestId ?? this.requestId,
      playSessionId: playSessionId ?? this.playSessionId,
      x: x ?? this.x,
      y: y ?? this.y,
      z: z ?? this.z,
      yawDeg: yawDeg ?? this.yawDeg,
      pitchDeg: pitchDeg ?? this.pitchDeg,
      fovDeg: fovDeg ?? this.fovDeg,
      distanceM: distanceM ?? this.distanceM,
      yawDiffDeg: yawDiffDeg ?? this.yawDiffDeg,
      pitchDiffDeg: pitchDiffDeg ?? this.pitchDiffDeg,
      score: score ?? this.score,
      rankAtSubmission: rankAtSubmission ?? this.rankAtSubmission,
      bestScoreAtSubmission:
          bestScoreAtSubmission ?? this.bestScoreAtSubmission,
      nicknameAtSubmission: nicknameAtSubmission ?? this.nicknameAtSubmission,
      bestAchieveTimeAtSubmission:
          bestAchieveTimeAtSubmission ?? this.bestAchieveTimeAtSubmission,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ShotRowUpdateTable extends _is.UpdateTable<ShotRowTable> {
  ShotRowUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> requestId(
    _is.UuidValue value,
  ) => _is.ColumnValue(table.requestId, value);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> playSessionId(
    _is.UuidValue value,
  ) => _is.ColumnValue(table.playSessionId, value);

  _is.ColumnValue<double, double> x(double value) =>
      _is.ColumnValue(table.x, value);

  _is.ColumnValue<double, double> y(double value) =>
      _is.ColumnValue(table.y, value);

  _is.ColumnValue<double, double> z(double value) =>
      _is.ColumnValue(table.z, value);

  _is.ColumnValue<double, double> yawDeg(double value) =>
      _is.ColumnValue(table.yawDeg, value);

  _is.ColumnValue<double, double> pitchDeg(double value) =>
      _is.ColumnValue(table.pitchDeg, value);

  _is.ColumnValue<double, double> fovDeg(double value) =>
      _is.ColumnValue(table.fovDeg, value);

  _is.ColumnValue<double, double> distanceM(double value) =>
      _is.ColumnValue(table.distanceM, value);

  _is.ColumnValue<double, double> yawDiffDeg(double value) =>
      _is.ColumnValue(table.yawDiffDeg, value);

  _is.ColumnValue<double, double> pitchDiffDeg(double value) =>
      _is.ColumnValue(table.pitchDiffDeg, value);

  _is.ColumnValue<int, int> score(int value) =>
      _is.ColumnValue(table.score, value);

  _is.ColumnValue<int, int> rankAtSubmission(int value) =>
      _is.ColumnValue(table.rankAtSubmission, value);

  _is.ColumnValue<int, int> bestScoreAtSubmission(int value) =>
      _is.ColumnValue(table.bestScoreAtSubmission, value);

  _is.ColumnValue<String, String> nicknameAtSubmission(String value) =>
      _is.ColumnValue(table.nicknameAtSubmission, value);

  _is.ColumnValue<DateTime, DateTime> bestAchieveTimeAtSubmission(
    DateTime value,
  ) => _is.ColumnValue(table.bestAchieveTimeAtSubmission, value);

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(table.createdAt, value);
}

class ShotRowTable extends _is.Table<int?> {
  ShotRowTable({super.tableRelation}) : super(tableName: 'shot') {
    updateTable = ShotRowUpdateTable(this);
    requestId = _is.ColumnUuid('request_id', this, fieldName: 'requestId');
    playSessionId = _is.ColumnUuid(
      'play_session_id',
      this,
      fieldName: 'playSessionId',
    );
    x = _is.ColumnDouble('x', this);
    y = _is.ColumnDouble('y', this);
    z = _is.ColumnDouble('z', this);
    yawDeg = _is.ColumnDouble('yaw_deg', this, fieldName: 'yawDeg');
    pitchDeg = _is.ColumnDouble('pitch_deg', this, fieldName: 'pitchDeg');
    fovDeg = _is.ColumnDouble('fov_deg', this, fieldName: 'fovDeg');
    distanceM = _is.ColumnDouble('distance_m', this, fieldName: 'distanceM');
    yawDiffDeg = _is.ColumnDouble(
      'yaw_diff_deg',
      this,
      fieldName: 'yawDiffDeg',
    );
    pitchDiffDeg = _is.ColumnDouble(
      'pitch_diff_deg',
      this,
      fieldName: 'pitchDiffDeg',
    );
    score = _is.ColumnInt('score', this);
    rankAtSubmission = _is.ColumnInt(
      'rank_at_submission',
      this,
      fieldName: 'rankAtSubmission',
    );
    bestScoreAtSubmission = _is.ColumnInt(
      'best_score_at_submission',
      this,
      fieldName: 'bestScoreAtSubmission',
    );
    nicknameAtSubmission = _is.ColumnString(
      'nickname_at_submission',
      this,
      fieldName: 'nicknameAtSubmission',
    );
    bestAchieveTimeAtSubmission = _is.ColumnDateTime(
      'best_achieve_time_at_submission',
      this,
      fieldName: 'bestAchieveTimeAtSubmission',
    );
    createdAt = _is.ColumnDateTime('created_at', this, fieldName: 'createdAt');
  }

  late final ShotRowUpdateTable updateTable;

  late final _is.ColumnUuid requestId;

  late final _is.ColumnUuid playSessionId;

  late final _is.ColumnDouble x;

  late final _is.ColumnDouble y;

  late final _is.ColumnDouble z;

  late final _is.ColumnDouble yawDeg;

  late final _is.ColumnDouble pitchDeg;

  late final _is.ColumnDouble fovDeg;

  late final _is.ColumnDouble distanceM;

  late final _is.ColumnDouble yawDiffDeg;

  late final _is.ColumnDouble pitchDiffDeg;

  late final _is.ColumnInt score;

  late final _is.ColumnInt rankAtSubmission;

  late final _is.ColumnInt bestScoreAtSubmission;

  late final _is.ColumnString nicknameAtSubmission;

  late final _is.ColumnDateTime bestAchieveTimeAtSubmission;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    requestId,
    playSessionId,
    x,
    y,
    z,
    yawDeg,
    pitchDeg,
    fovDeg,
    distanceM,
    yawDiffDeg,
    pitchDiffDeg,
    score,
    rankAtSubmission,
    bestScoreAtSubmission,
    nicknameAtSubmission,
    bestAchieveTimeAtSubmission,
    createdAt,
  ];
}

class ShotRowInclude extends _is.IncludeObject {
  ShotRowInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => ShotRow.t;
}

class ShotRowIncludeList extends _is.IncludeList {
  ShotRowIncludeList._({
    _is.WhereExpressionBuilder<ShotRowTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ShotRow.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => ShotRow.t;
}

class ShotRowRepository {
  const ShotRowRepository._();

  /// Returns a list of [ShotRow]s matching the given query parameters.
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
  Future<List<ShotRow>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ShotRowTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ShotRowTable>? orderBy,
    _is.OrderByListBuilder<ShotRowTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ShotRow>(
      where: where?.call(ShotRow.t),
      orderBy: orderBy?.call(ShotRow.t),
      orderByList: orderByList?.call(ShotRow.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [ShotRow]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `ShotRow.t`.
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
  _ida.Stream<List<ShotRow>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ShotRowTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ShotRowTable>? orderBy,
    _is.OrderByListBuilder<ShotRowTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<ShotRow>(
      where: where?.call(ShotRow.t),
      orderBy: orderBy?.call(ShotRow.t),
      orderByList: orderByList?.call(ShotRow.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [ShotRow] matching the given query parameters.
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
  Future<ShotRow?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ShotRowTable>? where,
    int? offset,
    _is.OrderByBuilder<ShotRowTable>? orderBy,
    _is.OrderByListBuilder<ShotRowTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ShotRow>(
      where: where?.call(ShotRow.t),
      orderBy: orderBy?.call(ShotRow.t),
      orderByList: orderByList?.call(ShotRow.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ShotRow] by its [id] or null if no such row exists.
  Future<ShotRow?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ShotRow>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ShotRow]s in the list and returns the inserted rows.
  ///
  /// The returned [ShotRow]s will have their `id` fields set.
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
  Future<List<ShotRow>> insert(
    _is.DatabaseSession session,
    List<ShotRow> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<ShotRow>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [ShotRow] and returns the inserted row.
  ///
  /// The returned [ShotRow] will have its `id` field set.
  Future<ShotRow> insertRow(
    _is.DatabaseSession session,
    ShotRow row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<ShotRow>(row, transaction: transaction);
  }

  /// Upserts all [ShotRow]s in the list and returns the resulting rows.
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
  /// The returned [ShotRow]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ShotRow>> upsert(
    _is.DatabaseSession session,
    List<ShotRow> rows, {
    required _is.ColumnSelections<ShotRowTable> conflictColumns,
    _is.ColumnSelections<ShotRowTable>? updateColumns,
    _is.WhereExpressionBuilder<ShotRowTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<ShotRow>(
      rows,
      conflictColumns: conflictColumns(ShotRow.t),
      updateColumns: updateColumns?.call(ShotRow.t),
      updateWhere: updateWhere?.call(ShotRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [ShotRow] and returns the resulting row.
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
  /// The returned [ShotRow] will have its `id` field set.
  Future<ShotRow?> upsertRow(
    _is.DatabaseSession session,
    ShotRow row, {
    required _is.ColumnSelections<ShotRowTable> conflictColumns,
    _is.ColumnSelections<ShotRowTable>? updateColumns,
    _is.WhereExpressionBuilder<ShotRowTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<ShotRow>(
      row,
      conflictColumns: conflictColumns(ShotRow.t),
      updateColumns: updateColumns?.call(ShotRow.t),
      updateWhere: updateWhere?.call(ShotRow.t),
      transaction: transaction,
    );
  }

  /// Updates all [ShotRow]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ShotRow>> update(
    _is.DatabaseSession session,
    List<ShotRow> rows, {
    _is.ColumnSelections<ShotRowTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<ShotRow>(
      rows,
      columns: columns?.call(ShotRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [ShotRow]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ShotRow> updateRow(
    _is.DatabaseSession session,
    ShotRow row, {
    _is.ColumnSelections<ShotRowTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<ShotRow>(
      row,
      columns: columns?.call(ShotRow.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ShotRow] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ShotRow?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<ShotRowUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<ShotRow>(
      id,
      columnValues: columnValues(ShotRow.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ShotRow]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ShotRow>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ShotRowUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<ShotRowTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ShotRowTable>? orderBy,
    _is.OrderByListBuilder<ShotRowTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<ShotRow>(
      columnValues: columnValues(ShotRow.t.updateTable),
      where: where(ShotRow.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ShotRow.t),
      orderByList: orderByList?.call(ShotRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [ShotRow]s in the list and returns the deleted rows.
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
  Future<List<ShotRow>> delete(
    _is.DatabaseSession session,
    List<ShotRow> rows, {
    _is.OrderByBuilder<ShotRowTable>? orderBy,
    _is.OrderByListBuilder<ShotRowTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<ShotRow>(
      rows,
      orderBy: orderBy?.call(ShotRow.t),
      orderByList: orderByList?.call(ShotRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [ShotRow].
  Future<ShotRow> deleteRow(
    _is.DatabaseSession session,
    ShotRow row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ShotRow>(row, transaction: transaction);
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ShotRow>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ShotRowTable> where,
    _is.OrderByBuilder<ShotRowTable>? orderBy,
    _is.OrderByListBuilder<ShotRowTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<ShotRow>(
      where: where(ShotRow.t),
      orderBy: orderBy?.call(ShotRow.t),
      orderByList: orderByList?.call(ShotRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ShotRowTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<ShotRow>(
      where: where?.call(ShotRow.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ShotRow] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ShotRowTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ShotRow>(
      where: where(ShotRow.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
