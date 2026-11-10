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

import 'package:photohunt_shared/photohunt_shared.dart' as _ix5zeh3i;
import 'package:serverpod/serverpod.dart' as _is;

/// 本人・版・モードごとの自己ベスト。ランキングの元データ。
abstract class BestScoreRow
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  BestScoreRow._({
    this.id,
    required this.userProfileId,
    required this.revisionId,
    required this.mode,
    required this.shotId,
    required this.score,
    required this.achievedAt,
  });

  factory BestScoreRow({
    int? id,
    required int userProfileId,
    required int revisionId,
    required _ix5zeh3i.PlayMode mode,
    required int shotId,
    required int score,
    required DateTime achievedAt,
  }) = _BestScoreRowImpl;

  factory BestScoreRow.fromJson(Map<String, dynamic> jsonSerialization) {
    return BestScoreRow(
      id: jsonSerialization['id'] as int?,
      userProfileId: jsonSerialization['userProfileId'] as int,
      revisionId: jsonSerialization['revisionId'] as int,
      mode: _ix5zeh3i.PlayMode.fromJson((jsonSerialization['mode'] as String)),
      shotId: jsonSerialization['shotId'] as int,
      score: jsonSerialization['score'] as int,
      achievedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['achievedAt'],
      ),
    );
  }

  static final t = BestScoreRowTable();

  static const db = BestScoreRowRepository._();

  @override
  int? id;

  int userProfileId;

  int revisionId;

  _ix5zeh3i.PlayMode mode;

  int shotId;

  int score;

  DateTime achievedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [BestScoreRow]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  BestScoreRow copyWith({
    int? id,
    int? userProfileId,
    int? revisionId,
    _ix5zeh3i.PlayMode? mode,
    int? shotId,
    int? score,
    DateTime? achievedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'BestScoreRow',
      if (id != null) 'id': id,
      'userProfileId': userProfileId,
      'revisionId': revisionId,
      'mode': mode.toJson(),
      'shotId': shotId,
      'score': score,
      'achievedAt': achievedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static BestScoreRowInclude include() {
    return BestScoreRowInclude._();
  }

  static BestScoreRowIncludeList includeList({
    _is.WhereExpressionBuilder<BestScoreRowTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<BestScoreRowTable>? orderBy,
    _is.OrderByListBuilder<BestScoreRowTable>? orderByList,
    BestScoreRowInclude? include,
  }) {
    return BestScoreRowIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(BestScoreRow.t),
      orderByList: orderByList?.call(BestScoreRow.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _BestScoreRowImpl extends BestScoreRow {
  _BestScoreRowImpl({
    int? id,
    required int userProfileId,
    required int revisionId,
    required _ix5zeh3i.PlayMode mode,
    required int shotId,
    required int score,
    required DateTime achievedAt,
  }) : super._(
         id: id,
         userProfileId: userProfileId,
         revisionId: revisionId,
         mode: mode,
         shotId: shotId,
         score: score,
         achievedAt: achievedAt,
       );

  /// Returns a shallow copy of this [BestScoreRow]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  BestScoreRow copyWith({
    Object? id = _Undefined,
    int? userProfileId,
    int? revisionId,
    _ix5zeh3i.PlayMode? mode,
    int? shotId,
    int? score,
    DateTime? achievedAt,
  }) {
    return BestScoreRow(
      id: id is int? ? id : this.id,
      userProfileId: userProfileId ?? this.userProfileId,
      revisionId: revisionId ?? this.revisionId,
      mode: mode ?? this.mode,
      shotId: shotId ?? this.shotId,
      score: score ?? this.score,
      achievedAt: achievedAt ?? this.achievedAt,
    );
  }
}

class BestScoreRowUpdateTable extends _is.UpdateTable<BestScoreRowTable> {
  BestScoreRowUpdateTable(super.table);

  _is.ColumnValue<int, int> userProfileId(int value) =>
      _is.ColumnValue(table.userProfileId, value);

  _is.ColumnValue<int, int> revisionId(int value) =>
      _is.ColumnValue(table.revisionId, value);

  _is.ColumnValue<_ix5zeh3i.PlayMode, _ix5zeh3i.PlayMode> mode(
    _ix5zeh3i.PlayMode value,
  ) => _is.ColumnValue(table.mode, value);

  _is.ColumnValue<int, int> shotId(int value) =>
      _is.ColumnValue(table.shotId, value);

  _is.ColumnValue<int, int> score(int value) =>
      _is.ColumnValue(table.score, value);

  _is.ColumnValue<DateTime, DateTime> achievedAt(DateTime value) =>
      _is.ColumnValue(table.achievedAt, value);
}

class BestScoreRowTable extends _is.Table<int?> {
  BestScoreRowTable({super.tableRelation}) : super(tableName: 'best_score') {
    updateTable = BestScoreRowUpdateTable(this);
    userProfileId = _is.ColumnInt(
      'user_profile_id',
      this,
      fieldName: 'userProfileId',
    );
    revisionId = _is.ColumnInt('revision_id', this, fieldName: 'revisionId');
    mode = _is.ColumnEnum('mode', this, _is.EnumSerialization.byName);
    shotId = _is.ColumnInt('shot_id', this, fieldName: 'shotId');
    score = _is.ColumnInt('score', this);
    achievedAt = _is.ColumnDateTime(
      'achieved_at',
      this,
      fieldName: 'achievedAt',
    );
  }

  late final BestScoreRowUpdateTable updateTable;

  late final _is.ColumnInt userProfileId;

  late final _is.ColumnInt revisionId;

  late final _is.ColumnEnum<_ix5zeh3i.PlayMode> mode;

  late final _is.ColumnInt shotId;

  late final _is.ColumnInt score;

  late final _is.ColumnDateTime achievedAt;

  @override
  List<_is.Column> get columns => [
    id,
    userProfileId,
    revisionId,
    mode,
    shotId,
    score,
    achievedAt,
  ];
}

class BestScoreRowInclude extends _is.IncludeObject {
  BestScoreRowInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => BestScoreRow.t;
}

class BestScoreRowIncludeList extends _is.IncludeList {
  BestScoreRowIncludeList._({
    _is.WhereExpressionBuilder<BestScoreRowTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(BestScoreRow.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => BestScoreRow.t;
}

class BestScoreRowRepository {
  const BestScoreRowRepository._();

  /// Returns a list of [BestScoreRow]s matching the given query parameters.
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
  Future<List<BestScoreRow>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<BestScoreRowTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<BestScoreRowTable>? orderBy,
    _is.OrderByListBuilder<BestScoreRowTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<BestScoreRow>(
      where: where?.call(BestScoreRow.t),
      orderBy: orderBy?.call(BestScoreRow.t),
      orderByList: orderByList?.call(BestScoreRow.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [BestScoreRow]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `BestScoreRow.t`.
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
  _ida.Stream<List<BestScoreRow>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<BestScoreRowTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<BestScoreRowTable>? orderBy,
    _is.OrderByListBuilder<BestScoreRowTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<BestScoreRow>(
      where: where?.call(BestScoreRow.t),
      orderBy: orderBy?.call(BestScoreRow.t),
      orderByList: orderByList?.call(BestScoreRow.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [BestScoreRow] matching the given query parameters.
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
  Future<BestScoreRow?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<BestScoreRowTable>? where,
    int? offset,
    _is.OrderByBuilder<BestScoreRowTable>? orderBy,
    _is.OrderByListBuilder<BestScoreRowTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<BestScoreRow>(
      where: where?.call(BestScoreRow.t),
      orderBy: orderBy?.call(BestScoreRow.t),
      orderByList: orderByList?.call(BestScoreRow.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [BestScoreRow] by its [id] or null if no such row exists.
  Future<BestScoreRow?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<BestScoreRow>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [BestScoreRow]s in the list and returns the inserted rows.
  ///
  /// The returned [BestScoreRow]s will have their `id` fields set.
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
  Future<List<BestScoreRow>> insert(
    _is.DatabaseSession session,
    List<BestScoreRow> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<BestScoreRow>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [BestScoreRow] and returns the inserted row.
  ///
  /// The returned [BestScoreRow] will have its `id` field set.
  Future<BestScoreRow> insertRow(
    _is.DatabaseSession session,
    BestScoreRow row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<BestScoreRow>(row, transaction: transaction);
  }

  /// Upserts all [BestScoreRow]s in the list and returns the resulting rows.
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
  /// The returned [BestScoreRow]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<BestScoreRow>> upsert(
    _is.DatabaseSession session,
    List<BestScoreRow> rows, {
    required _is.ColumnSelections<BestScoreRowTable> conflictColumns,
    _is.ColumnSelections<BestScoreRowTable>? updateColumns,
    _is.WhereExpressionBuilder<BestScoreRowTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<BestScoreRow>(
      rows,
      conflictColumns: conflictColumns(BestScoreRow.t),
      updateColumns: updateColumns?.call(BestScoreRow.t),
      updateWhere: updateWhere?.call(BestScoreRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [BestScoreRow] and returns the resulting row.
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
  /// The returned [BestScoreRow] will have its `id` field set.
  Future<BestScoreRow?> upsertRow(
    _is.DatabaseSession session,
    BestScoreRow row, {
    required _is.ColumnSelections<BestScoreRowTable> conflictColumns,
    _is.ColumnSelections<BestScoreRowTable>? updateColumns,
    _is.WhereExpressionBuilder<BestScoreRowTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<BestScoreRow>(
      row,
      conflictColumns: conflictColumns(BestScoreRow.t),
      updateColumns: updateColumns?.call(BestScoreRow.t),
      updateWhere: updateWhere?.call(BestScoreRow.t),
      transaction: transaction,
    );
  }

  /// Updates all [BestScoreRow]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<BestScoreRow>> update(
    _is.DatabaseSession session,
    List<BestScoreRow> rows, {
    _is.ColumnSelections<BestScoreRowTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<BestScoreRow>(
      rows,
      columns: columns?.call(BestScoreRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [BestScoreRow]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<BestScoreRow> updateRow(
    _is.DatabaseSession session,
    BestScoreRow row, {
    _is.ColumnSelections<BestScoreRowTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<BestScoreRow>(
      row,
      columns: columns?.call(BestScoreRow.t),
      transaction: transaction,
    );
  }

  /// Updates a single [BestScoreRow] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<BestScoreRow?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<BestScoreRowUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<BestScoreRow>(
      id,
      columnValues: columnValues(BestScoreRow.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [BestScoreRow]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<BestScoreRow>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<BestScoreRowUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<BestScoreRowTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<BestScoreRowTable>? orderBy,
    _is.OrderByListBuilder<BestScoreRowTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<BestScoreRow>(
      columnValues: columnValues(BestScoreRow.t.updateTable),
      where: where(BestScoreRow.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(BestScoreRow.t),
      orderByList: orderByList?.call(BestScoreRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [BestScoreRow]s in the list and returns the deleted rows.
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
  Future<List<BestScoreRow>> delete(
    _is.DatabaseSession session,
    List<BestScoreRow> rows, {
    _is.OrderByBuilder<BestScoreRowTable>? orderBy,
    _is.OrderByListBuilder<BestScoreRowTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<BestScoreRow>(
      rows,
      orderBy: orderBy?.call(BestScoreRow.t),
      orderByList: orderByList?.call(BestScoreRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [BestScoreRow].
  Future<BestScoreRow> deleteRow(
    _is.DatabaseSession session,
    BestScoreRow row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<BestScoreRow>(row, transaction: transaction);
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<BestScoreRow>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<BestScoreRowTable> where,
    _is.OrderByBuilder<BestScoreRowTable>? orderBy,
    _is.OrderByListBuilder<BestScoreRowTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<BestScoreRow>(
      where: where(BestScoreRow.t),
      orderBy: orderBy?.call(BestScoreRow.t),
      orderByList: orderByList?.call(BestScoreRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<BestScoreRowTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<BestScoreRow>(
      where: where?.call(BestScoreRow.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [BestScoreRow] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<BestScoreRowTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<BestScoreRow>(
      where: where(BestScoreRow.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
