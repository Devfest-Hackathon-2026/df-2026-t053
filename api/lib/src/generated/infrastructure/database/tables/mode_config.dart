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

/// 版ごとのモード設定。walkable は WalkableArea の JSON 文字列。
abstract class ModeConfigRow
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  ModeConfigRow._({
    this.id,
    required this.revisionId,
    required this.mode,
    required this.walkable,
  });

  factory ModeConfigRow({
    int? id,
    required int revisionId,
    required _ix5zeh3i.PlayMode mode,
    required String walkable,
  }) = _ModeConfigRowImpl;

  factory ModeConfigRow.fromJson(Map<String, dynamic> jsonSerialization) {
    return ModeConfigRow(
      id: jsonSerialization['id'] as int?,
      revisionId: jsonSerialization['revisionId'] as int,
      mode: _ix5zeh3i.PlayMode.fromJson((jsonSerialization['mode'] as String)),
      walkable: jsonSerialization['walkable'] as String,
    );
  }

  static final t = ModeConfigRowTable();

  static const db = ModeConfigRowRepository._();

  @override
  int? id;

  int revisionId;

  _ix5zeh3i.PlayMode mode;

  String walkable;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [ModeConfigRow]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ModeConfigRow copyWith({
    int? id,
    int? revisionId,
    _ix5zeh3i.PlayMode? mode,
    String? walkable,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ModeConfigRow',
      if (id != null) 'id': id,
      'revisionId': revisionId,
      'mode': mode.toJson(),
      'walkable': walkable,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static ModeConfigRowInclude include() {
    return ModeConfigRowInclude._();
  }

  static ModeConfigRowIncludeList includeList({
    _is.WhereExpressionBuilder<ModeConfigRowTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ModeConfigRowTable>? orderBy,
    _is.OrderByListBuilder<ModeConfigRowTable>? orderByList,
    ModeConfigRowInclude? include,
  }) {
    return ModeConfigRowIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ModeConfigRow.t),
      orderByList: orderByList?.call(ModeConfigRow.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ModeConfigRowImpl extends ModeConfigRow {
  _ModeConfigRowImpl({
    int? id,
    required int revisionId,
    required _ix5zeh3i.PlayMode mode,
    required String walkable,
  }) : super._(id: id, revisionId: revisionId, mode: mode, walkable: walkable);

  /// Returns a shallow copy of this [ModeConfigRow]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ModeConfigRow copyWith({
    Object? id = _Undefined,
    int? revisionId,
    _ix5zeh3i.PlayMode? mode,
    String? walkable,
  }) {
    return ModeConfigRow(
      id: id is int? ? id : this.id,
      revisionId: revisionId ?? this.revisionId,
      mode: mode ?? this.mode,
      walkable: walkable ?? this.walkable,
    );
  }
}

class ModeConfigRowUpdateTable extends _is.UpdateTable<ModeConfigRowTable> {
  ModeConfigRowUpdateTable(super.table);

  _is.ColumnValue<int, int> revisionId(int value) =>
      _is.ColumnValue(table.revisionId, value);

  _is.ColumnValue<_ix5zeh3i.PlayMode, _ix5zeh3i.PlayMode> mode(
    _ix5zeh3i.PlayMode value,
  ) => _is.ColumnValue(table.mode, value);

  _is.ColumnValue<String, String> walkable(String value) =>
      _is.ColumnValue(table.walkable, value);
}

class ModeConfigRowTable extends _is.Table<int?> {
  ModeConfigRowTable({super.tableRelation}) : super(tableName: 'mode_config') {
    updateTable = ModeConfigRowUpdateTable(this);
    revisionId = _is.ColumnInt('revision_id', this, fieldName: 'revisionId');
    mode = _is.ColumnEnum('mode', this, _is.EnumSerialization.byName);
    walkable = _is.ColumnString('walkable', this);
  }

  late final ModeConfigRowUpdateTable updateTable;

  late final _is.ColumnInt revisionId;

  late final _is.ColumnEnum<_ix5zeh3i.PlayMode> mode;

  late final _is.ColumnString walkable;

  @override
  List<_is.Column> get columns => [id, revisionId, mode, walkable];
}

class ModeConfigRowInclude extends _is.IncludeObject {
  ModeConfigRowInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => ModeConfigRow.t;
}

class ModeConfigRowIncludeList extends _is.IncludeList {
  ModeConfigRowIncludeList._({
    _is.WhereExpressionBuilder<ModeConfigRowTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ModeConfigRow.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => ModeConfigRow.t;
}

class ModeConfigRowRepository {
  const ModeConfigRowRepository._();

  /// Returns a list of [ModeConfigRow]s matching the given query parameters.
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
  Future<List<ModeConfigRow>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ModeConfigRowTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ModeConfigRowTable>? orderBy,
    _is.OrderByListBuilder<ModeConfigRowTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ModeConfigRow>(
      where: where?.call(ModeConfigRow.t),
      orderBy: orderBy?.call(ModeConfigRow.t),
      orderByList: orderByList?.call(ModeConfigRow.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [ModeConfigRow]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `ModeConfigRow.t`.
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
  _ida.Stream<List<ModeConfigRow>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ModeConfigRowTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ModeConfigRowTable>? orderBy,
    _is.OrderByListBuilder<ModeConfigRowTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<ModeConfigRow>(
      where: where?.call(ModeConfigRow.t),
      orderBy: orderBy?.call(ModeConfigRow.t),
      orderByList: orderByList?.call(ModeConfigRow.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [ModeConfigRow] matching the given query parameters.
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
  Future<ModeConfigRow?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ModeConfigRowTable>? where,
    int? offset,
    _is.OrderByBuilder<ModeConfigRowTable>? orderBy,
    _is.OrderByListBuilder<ModeConfigRowTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ModeConfigRow>(
      where: where?.call(ModeConfigRow.t),
      orderBy: orderBy?.call(ModeConfigRow.t),
      orderByList: orderByList?.call(ModeConfigRow.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ModeConfigRow] by its [id] or null if no such row exists.
  Future<ModeConfigRow?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ModeConfigRow>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ModeConfigRow]s in the list and returns the inserted rows.
  ///
  /// The returned [ModeConfigRow]s will have their `id` fields set.
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
  Future<List<ModeConfigRow>> insert(
    _is.DatabaseSession session,
    List<ModeConfigRow> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<ModeConfigRow>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [ModeConfigRow] and returns the inserted row.
  ///
  /// The returned [ModeConfigRow] will have its `id` field set.
  Future<ModeConfigRow> insertRow(
    _is.DatabaseSession session,
    ModeConfigRow row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<ModeConfigRow>(row, transaction: transaction);
  }

  /// Upserts all [ModeConfigRow]s in the list and returns the resulting rows.
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
  /// The returned [ModeConfigRow]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ModeConfigRow>> upsert(
    _is.DatabaseSession session,
    List<ModeConfigRow> rows, {
    required _is.ColumnSelections<ModeConfigRowTable> conflictColumns,
    _is.ColumnSelections<ModeConfigRowTable>? updateColumns,
    _is.WhereExpressionBuilder<ModeConfigRowTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<ModeConfigRow>(
      rows,
      conflictColumns: conflictColumns(ModeConfigRow.t),
      updateColumns: updateColumns?.call(ModeConfigRow.t),
      updateWhere: updateWhere?.call(ModeConfigRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [ModeConfigRow] and returns the resulting row.
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
  /// The returned [ModeConfigRow] will have its `id` field set.
  Future<ModeConfigRow?> upsertRow(
    _is.DatabaseSession session,
    ModeConfigRow row, {
    required _is.ColumnSelections<ModeConfigRowTable> conflictColumns,
    _is.ColumnSelections<ModeConfigRowTable>? updateColumns,
    _is.WhereExpressionBuilder<ModeConfigRowTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<ModeConfigRow>(
      row,
      conflictColumns: conflictColumns(ModeConfigRow.t),
      updateColumns: updateColumns?.call(ModeConfigRow.t),
      updateWhere: updateWhere?.call(ModeConfigRow.t),
      transaction: transaction,
    );
  }

  /// Updates all [ModeConfigRow]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ModeConfigRow>> update(
    _is.DatabaseSession session,
    List<ModeConfigRow> rows, {
    _is.ColumnSelections<ModeConfigRowTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<ModeConfigRow>(
      rows,
      columns: columns?.call(ModeConfigRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [ModeConfigRow]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ModeConfigRow> updateRow(
    _is.DatabaseSession session,
    ModeConfigRow row, {
    _is.ColumnSelections<ModeConfigRowTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<ModeConfigRow>(
      row,
      columns: columns?.call(ModeConfigRow.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ModeConfigRow] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ModeConfigRow?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<ModeConfigRowUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<ModeConfigRow>(
      id,
      columnValues: columnValues(ModeConfigRow.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ModeConfigRow]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ModeConfigRow>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ModeConfigRowUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<ModeConfigRowTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ModeConfigRowTable>? orderBy,
    _is.OrderByListBuilder<ModeConfigRowTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<ModeConfigRow>(
      columnValues: columnValues(ModeConfigRow.t.updateTable),
      where: where(ModeConfigRow.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ModeConfigRow.t),
      orderByList: orderByList?.call(ModeConfigRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [ModeConfigRow]s in the list and returns the deleted rows.
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
  Future<List<ModeConfigRow>> delete(
    _is.DatabaseSession session,
    List<ModeConfigRow> rows, {
    _is.OrderByBuilder<ModeConfigRowTable>? orderBy,
    _is.OrderByListBuilder<ModeConfigRowTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<ModeConfigRow>(
      rows,
      orderBy: orderBy?.call(ModeConfigRow.t),
      orderByList: orderByList?.call(ModeConfigRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [ModeConfigRow].
  Future<ModeConfigRow> deleteRow(
    _is.DatabaseSession session,
    ModeConfigRow row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ModeConfigRow>(row, transaction: transaction);
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ModeConfigRow>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ModeConfigRowTable> where,
    _is.OrderByBuilder<ModeConfigRowTable>? orderBy,
    _is.OrderByListBuilder<ModeConfigRowTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<ModeConfigRow>(
      where: where(ModeConfigRow.t),
      orderBy: orderBy?.call(ModeConfigRow.t),
      orderByList: orderByList?.call(ModeConfigRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ModeConfigRowTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<ModeConfigRow>(
      where: where?.call(ModeConfigRow.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ModeConfigRow] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ModeConfigRowTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ModeConfigRow>(
      where: where(ModeConfigRow.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
