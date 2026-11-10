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

/// 版に固定した出典表記。
abstract class CreditRow
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  CreditRow._({
    this.id,
    required this.revisionId,
    required this.name,
    this.url,
    required this.sortOrder,
  });

  factory CreditRow({
    int? id,
    required int revisionId,
    required String name,
    String? url,
    required int sortOrder,
  }) = _CreditRowImpl;

  factory CreditRow.fromJson(Map<String, dynamic> jsonSerialization) {
    return CreditRow(
      id: jsonSerialization['id'] as int?,
      revisionId: jsonSerialization['revisionId'] as int,
      name: jsonSerialization['name'] as String,
      url: jsonSerialization['url'] as String?,
      sortOrder: jsonSerialization['sortOrder'] as int,
    );
  }

  static final t = CreditRowTable();

  static const db = CreditRowRepository._();

  @override
  int? id;

  int revisionId;

  String name;

  String? url;

  int sortOrder;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [CreditRow]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CreditRow copyWith({
    int? id,
    int? revisionId,
    String? name,
    String? url,
    int? sortOrder,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CreditRow',
      if (id != null) 'id': id,
      'revisionId': revisionId,
      'name': name,
      if (url != null) 'url': url,
      'sortOrder': sortOrder,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CreditRowInclude include() {
    return CreditRowInclude._();
  }

  static CreditRowIncludeList includeList({
    _is.WhereExpressionBuilder<CreditRowTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CreditRowTable>? orderBy,
    _is.OrderByListBuilder<CreditRowTable>? orderByList,
    CreditRowInclude? include,
  }) {
    return CreditRowIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CreditRow.t),
      orderByList: orderByList?.call(CreditRow.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CreditRowImpl extends CreditRow {
  _CreditRowImpl({
    int? id,
    required int revisionId,
    required String name,
    String? url,
    required int sortOrder,
  }) : super._(
         id: id,
         revisionId: revisionId,
         name: name,
         url: url,
         sortOrder: sortOrder,
       );

  /// Returns a shallow copy of this [CreditRow]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CreditRow copyWith({
    Object? id = _Undefined,
    int? revisionId,
    String? name,
    Object? url = _Undefined,
    int? sortOrder,
  }) {
    return CreditRow(
      id: id is int? ? id : this.id,
      revisionId: revisionId ?? this.revisionId,
      name: name ?? this.name,
      url: url is String? ? url : this.url,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class CreditRowUpdateTable extends _is.UpdateTable<CreditRowTable> {
  CreditRowUpdateTable(super.table);

  _is.ColumnValue<int, int> revisionId(int value) =>
      _is.ColumnValue(table.revisionId, value);

  _is.ColumnValue<String, String> name(String value) =>
      _is.ColumnValue(table.name, value);

  _is.ColumnValue<String, String> url(String? value) =>
      _is.ColumnValue(table.url, value);

  _is.ColumnValue<int, int> sortOrder(int value) =>
      _is.ColumnValue(table.sortOrder, value);
}

class CreditRowTable extends _is.Table<int?> {
  CreditRowTable({super.tableRelation}) : super(tableName: 'credit') {
    updateTable = CreditRowUpdateTable(this);
    revisionId = _is.ColumnInt('revision_id', this, fieldName: 'revisionId');
    name = _is.ColumnString('name', this);
    url = _is.ColumnString('url', this);
    sortOrder = _is.ColumnInt('sort_order', this, fieldName: 'sortOrder');
  }

  late final CreditRowUpdateTable updateTable;

  late final _is.ColumnInt revisionId;

  late final _is.ColumnString name;

  late final _is.ColumnString url;

  late final _is.ColumnInt sortOrder;

  @override
  List<_is.Column> get columns => [id, revisionId, name, url, sortOrder];
}

class CreditRowInclude extends _is.IncludeObject {
  CreditRowInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => CreditRow.t;
}

class CreditRowIncludeList extends _is.IncludeList {
  CreditRowIncludeList._({
    _is.WhereExpressionBuilder<CreditRowTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CreditRow.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => CreditRow.t;
}

class CreditRowRepository {
  const CreditRowRepository._();

  /// Returns a list of [CreditRow]s matching the given query parameters.
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
  Future<List<CreditRow>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CreditRowTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CreditRowTable>? orderBy,
    _is.OrderByListBuilder<CreditRowTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CreditRow>(
      where: where?.call(CreditRow.t),
      orderBy: orderBy?.call(CreditRow.t),
      orderByList: orderByList?.call(CreditRow.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [CreditRow]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `CreditRow.t`.
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
  _ida.Stream<List<CreditRow>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CreditRowTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CreditRowTable>? orderBy,
    _is.OrderByListBuilder<CreditRowTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<CreditRow>(
      where: where?.call(CreditRow.t),
      orderBy: orderBy?.call(CreditRow.t),
      orderByList: orderByList?.call(CreditRow.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [CreditRow] matching the given query parameters.
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
  Future<CreditRow?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CreditRowTable>? where,
    int? offset,
    _is.OrderByBuilder<CreditRowTable>? orderBy,
    _is.OrderByListBuilder<CreditRowTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CreditRow>(
      where: where?.call(CreditRow.t),
      orderBy: orderBy?.call(CreditRow.t),
      orderByList: orderByList?.call(CreditRow.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CreditRow] by its [id] or null if no such row exists.
  Future<CreditRow?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CreditRow>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CreditRow]s in the list and returns the inserted rows.
  ///
  /// The returned [CreditRow]s will have their `id` fields set.
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
  Future<List<CreditRow>> insert(
    _is.DatabaseSession session,
    List<CreditRow> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CreditRow>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CreditRow] and returns the inserted row.
  ///
  /// The returned [CreditRow] will have its `id` field set.
  Future<CreditRow> insertRow(
    _is.DatabaseSession session,
    CreditRow row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CreditRow>(row, transaction: transaction);
  }

  /// Upserts all [CreditRow]s in the list and returns the resulting rows.
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
  /// The returned [CreditRow]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CreditRow>> upsert(
    _is.DatabaseSession session,
    List<CreditRow> rows, {
    required _is.ColumnSelections<CreditRowTable> conflictColumns,
    _is.ColumnSelections<CreditRowTable>? updateColumns,
    _is.WhereExpressionBuilder<CreditRowTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CreditRow>(
      rows,
      conflictColumns: conflictColumns(CreditRow.t),
      updateColumns: updateColumns?.call(CreditRow.t),
      updateWhere: updateWhere?.call(CreditRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CreditRow] and returns the resulting row.
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
  /// The returned [CreditRow] will have its `id` field set.
  Future<CreditRow?> upsertRow(
    _is.DatabaseSession session,
    CreditRow row, {
    required _is.ColumnSelections<CreditRowTable> conflictColumns,
    _is.ColumnSelections<CreditRowTable>? updateColumns,
    _is.WhereExpressionBuilder<CreditRowTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CreditRow>(
      row,
      conflictColumns: conflictColumns(CreditRow.t),
      updateColumns: updateColumns?.call(CreditRow.t),
      updateWhere: updateWhere?.call(CreditRow.t),
      transaction: transaction,
    );
  }

  /// Updates all [CreditRow]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CreditRow>> update(
    _is.DatabaseSession session,
    List<CreditRow> rows, {
    _is.ColumnSelections<CreditRowTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CreditRow>(
      rows,
      columns: columns?.call(CreditRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CreditRow]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CreditRow> updateRow(
    _is.DatabaseSession session,
    CreditRow row, {
    _is.ColumnSelections<CreditRowTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CreditRow>(
      row,
      columns: columns?.call(CreditRow.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CreditRow] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CreditRow?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<CreditRowUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CreditRow>(
      id,
      columnValues: columnValues(CreditRow.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CreditRow]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CreditRow>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CreditRowUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<CreditRowTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CreditRowTable>? orderBy,
    _is.OrderByListBuilder<CreditRowTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CreditRow>(
      columnValues: columnValues(CreditRow.t.updateTable),
      where: where(CreditRow.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CreditRow.t),
      orderByList: orderByList?.call(CreditRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CreditRow]s in the list and returns the deleted rows.
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
  Future<List<CreditRow>> delete(
    _is.DatabaseSession session,
    List<CreditRow> rows, {
    _is.OrderByBuilder<CreditRowTable>? orderBy,
    _is.OrderByListBuilder<CreditRowTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CreditRow>(
      rows,
      orderBy: orderBy?.call(CreditRow.t),
      orderByList: orderByList?.call(CreditRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CreditRow].
  Future<CreditRow> deleteRow(
    _is.DatabaseSession session,
    CreditRow row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CreditRow>(row, transaction: transaction);
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CreditRow>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CreditRowTable> where,
    _is.OrderByBuilder<CreditRowTable>? orderBy,
    _is.OrderByListBuilder<CreditRowTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CreditRow>(
      where: where(CreditRow.t),
      orderBy: orderBy?.call(CreditRow.t),
      orderByList: orderByList?.call(CreditRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CreditRowTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CreditRow>(
      where: where?.call(CreditRow.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CreditRow] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CreditRowTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CreditRow>(
      where: where(CreditRow.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
