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

/// 構造物資料の出典。
abstract class StructureSourceRow
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  StructureSourceRow._({
    this.id,
    required this.structureId,
    required this.title,
    required this.url,
    required this.sortOrder,
  });

  factory StructureSourceRow({
    int? id,
    required int structureId,
    required String title,
    required String url,
    required int sortOrder,
  }) = _StructureSourceRowImpl;

  factory StructureSourceRow.fromJson(Map<String, dynamic> jsonSerialization) {
    return StructureSourceRow(
      id: jsonSerialization['id'] as int?,
      structureId: jsonSerialization['structureId'] as int,
      title: jsonSerialization['title'] as String,
      url: jsonSerialization['url'] as String,
      sortOrder: jsonSerialization['sortOrder'] as int,
    );
  }

  static final t = StructureSourceRowTable();

  static const db = StructureSourceRowRepository._();

  @override
  int? id;

  int structureId;

  String title;

  String url;

  int sortOrder;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [StructureSourceRow]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  StructureSourceRow copyWith({
    int? id,
    int? structureId,
    String? title,
    String? url,
    int? sortOrder,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'StructureSourceRow',
      if (id != null) 'id': id,
      'structureId': structureId,
      'title': title,
      'url': url,
      'sortOrder': sortOrder,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static StructureSourceRowInclude include() {
    return StructureSourceRowInclude._();
  }

  static StructureSourceRowIncludeList includeList({
    _is.WhereExpressionBuilder<StructureSourceRowTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StructureSourceRowTable>? orderBy,
    _is.OrderByListBuilder<StructureSourceRowTable>? orderByList,
    StructureSourceRowInclude? include,
  }) {
    return StructureSourceRowIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(StructureSourceRow.t),
      orderByList: orderByList?.call(StructureSourceRow.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _StructureSourceRowImpl extends StructureSourceRow {
  _StructureSourceRowImpl({
    int? id,
    required int structureId,
    required String title,
    required String url,
    required int sortOrder,
  }) : super._(
         id: id,
         structureId: structureId,
         title: title,
         url: url,
         sortOrder: sortOrder,
       );

  /// Returns a shallow copy of this [StructureSourceRow]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  StructureSourceRow copyWith({
    Object? id = _Undefined,
    int? structureId,
    String? title,
    String? url,
    int? sortOrder,
  }) {
    return StructureSourceRow(
      id: id is int? ? id : this.id,
      structureId: structureId ?? this.structureId,
      title: title ?? this.title,
      url: url ?? this.url,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class StructureSourceRowUpdateTable
    extends _is.UpdateTable<StructureSourceRowTable> {
  StructureSourceRowUpdateTable(super.table);

  _is.ColumnValue<int, int> structureId(int value) =>
      _is.ColumnValue(table.structureId, value);

  _is.ColumnValue<String, String> title(String value) =>
      _is.ColumnValue(table.title, value);

  _is.ColumnValue<String, String> url(String value) =>
      _is.ColumnValue(table.url, value);

  _is.ColumnValue<int, int> sortOrder(int value) =>
      _is.ColumnValue(table.sortOrder, value);
}

class StructureSourceRowTable extends _is.Table<int?> {
  StructureSourceRowTable({super.tableRelation})
    : super(tableName: 'structure_source') {
    updateTable = StructureSourceRowUpdateTable(this);
    structureId = _is.ColumnInt('structure_id', this, fieldName: 'structureId');
    title = _is.ColumnString('title', this);
    url = _is.ColumnString('url', this);
    sortOrder = _is.ColumnInt('sort_order', this, fieldName: 'sortOrder');
  }

  late final StructureSourceRowUpdateTable updateTable;

  late final _is.ColumnInt structureId;

  late final _is.ColumnString title;

  late final _is.ColumnString url;

  late final _is.ColumnInt sortOrder;

  @override
  List<_is.Column> get columns => [id, structureId, title, url, sortOrder];
}

class StructureSourceRowInclude extends _is.IncludeObject {
  StructureSourceRowInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => StructureSourceRow.t;
}

class StructureSourceRowIncludeList extends _is.IncludeList {
  StructureSourceRowIncludeList._({
    _is.WhereExpressionBuilder<StructureSourceRowTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(StructureSourceRow.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => StructureSourceRow.t;
}

class StructureSourceRowRepository {
  const StructureSourceRowRepository._();

  /// Returns a list of [StructureSourceRow]s matching the given query parameters.
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
  Future<List<StructureSourceRow>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StructureSourceRowTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StructureSourceRowTable>? orderBy,
    _is.OrderByListBuilder<StructureSourceRowTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<StructureSourceRow>(
      where: where?.call(StructureSourceRow.t),
      orderBy: orderBy?.call(StructureSourceRow.t),
      orderByList: orderByList?.call(StructureSourceRow.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [StructureSourceRow]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `StructureSourceRow.t`.
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
  _ida.Stream<List<StructureSourceRow>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StructureSourceRowTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StructureSourceRowTable>? orderBy,
    _is.OrderByListBuilder<StructureSourceRowTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<StructureSourceRow>(
      where: where?.call(StructureSourceRow.t),
      orderBy: orderBy?.call(StructureSourceRow.t),
      orderByList: orderByList?.call(StructureSourceRow.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [StructureSourceRow] matching the given query parameters.
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
  Future<StructureSourceRow?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StructureSourceRowTable>? where,
    int? offset,
    _is.OrderByBuilder<StructureSourceRowTable>? orderBy,
    _is.OrderByListBuilder<StructureSourceRowTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<StructureSourceRow>(
      where: where?.call(StructureSourceRow.t),
      orderBy: orderBy?.call(StructureSourceRow.t),
      orderByList: orderByList?.call(StructureSourceRow.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [StructureSourceRow] by its [id] or null if no such row exists.
  Future<StructureSourceRow?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<StructureSourceRow>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [StructureSourceRow]s in the list and returns the inserted rows.
  ///
  /// The returned [StructureSourceRow]s will have their `id` fields set.
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
  Future<List<StructureSourceRow>> insert(
    _is.DatabaseSession session,
    List<StructureSourceRow> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<StructureSourceRow>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [StructureSourceRow] and returns the inserted row.
  ///
  /// The returned [StructureSourceRow] will have its `id` field set.
  Future<StructureSourceRow> insertRow(
    _is.DatabaseSession session,
    StructureSourceRow row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<StructureSourceRow>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [StructureSourceRow]s in the list and returns the resulting rows.
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
  /// The returned [StructureSourceRow]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StructureSourceRow>> upsert(
    _is.DatabaseSession session,
    List<StructureSourceRow> rows, {
    required _is.ColumnSelections<StructureSourceRowTable> conflictColumns,
    _is.ColumnSelections<StructureSourceRowTable>? updateColumns,
    _is.WhereExpressionBuilder<StructureSourceRowTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<StructureSourceRow>(
      rows,
      conflictColumns: conflictColumns(StructureSourceRow.t),
      updateColumns: updateColumns?.call(StructureSourceRow.t),
      updateWhere: updateWhere?.call(StructureSourceRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [StructureSourceRow] and returns the resulting row.
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
  /// The returned [StructureSourceRow] will have its `id` field set.
  Future<StructureSourceRow?> upsertRow(
    _is.DatabaseSession session,
    StructureSourceRow row, {
    required _is.ColumnSelections<StructureSourceRowTable> conflictColumns,
    _is.ColumnSelections<StructureSourceRowTable>? updateColumns,
    _is.WhereExpressionBuilder<StructureSourceRowTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<StructureSourceRow>(
      row,
      conflictColumns: conflictColumns(StructureSourceRow.t),
      updateColumns: updateColumns?.call(StructureSourceRow.t),
      updateWhere: updateWhere?.call(StructureSourceRow.t),
      transaction: transaction,
    );
  }

  /// Updates all [StructureSourceRow]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StructureSourceRow>> update(
    _is.DatabaseSession session,
    List<StructureSourceRow> rows, {
    _is.ColumnSelections<StructureSourceRowTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<StructureSourceRow>(
      rows,
      columns: columns?.call(StructureSourceRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [StructureSourceRow]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<StructureSourceRow> updateRow(
    _is.DatabaseSession session,
    StructureSourceRow row, {
    _is.ColumnSelections<StructureSourceRowTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<StructureSourceRow>(
      row,
      columns: columns?.call(StructureSourceRow.t),
      transaction: transaction,
    );
  }

  /// Updates a single [StructureSourceRow] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<StructureSourceRow?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<StructureSourceRowUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<StructureSourceRow>(
      id,
      columnValues: columnValues(StructureSourceRow.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [StructureSourceRow]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StructureSourceRow>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<StructureSourceRowUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<StructureSourceRowTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StructureSourceRowTable>? orderBy,
    _is.OrderByListBuilder<StructureSourceRowTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<StructureSourceRow>(
      columnValues: columnValues(StructureSourceRow.t.updateTable),
      where: where(StructureSourceRow.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(StructureSourceRow.t),
      orderByList: orderByList?.call(StructureSourceRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [StructureSourceRow]s in the list and returns the deleted rows.
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
  Future<List<StructureSourceRow>> delete(
    _is.DatabaseSession session,
    List<StructureSourceRow> rows, {
    _is.OrderByBuilder<StructureSourceRowTable>? orderBy,
    _is.OrderByListBuilder<StructureSourceRowTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<StructureSourceRow>(
      rows,
      orderBy: orderBy?.call(StructureSourceRow.t),
      orderByList: orderByList?.call(StructureSourceRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [StructureSourceRow].
  Future<StructureSourceRow> deleteRow(
    _is.DatabaseSession session,
    StructureSourceRow row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<StructureSourceRow>(
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
  Future<List<StructureSourceRow>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<StructureSourceRowTable> where,
    _is.OrderByBuilder<StructureSourceRowTable>? orderBy,
    _is.OrderByListBuilder<StructureSourceRowTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<StructureSourceRow>(
      where: where(StructureSourceRow.t),
      orderBy: orderBy?.call(StructureSourceRow.t),
      orderByList: orderByList?.call(StructureSourceRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StructureSourceRowTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<StructureSourceRow>(
      where: where?.call(StructureSourceRow.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [StructureSourceRow] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<StructureSourceRowTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<StructureSourceRow>(
      where: where(StructureSourceRow.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
