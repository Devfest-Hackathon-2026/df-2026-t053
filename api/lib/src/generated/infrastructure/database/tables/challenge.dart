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

/// 出題。slug は一意。未公開のあいだ current_revision_id は null。
abstract class ChallengeRow
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  ChallengeRow._({
    this.id,
    required this.slug,
    required this.title,
    this.currentRevisionId,
    required this.createdAt,
  });

  factory ChallengeRow({
    int? id,
    required String slug,
    required String title,
    int? currentRevisionId,
    required DateTime createdAt,
  }) = _ChallengeRowImpl;

  factory ChallengeRow.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChallengeRow(
      id: jsonSerialization['id'] as int?,
      slug: jsonSerialization['slug'] as String,
      title: jsonSerialization['title'] as String,
      currentRevisionId: jsonSerialization['currentRevisionId'] as int?,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = ChallengeRowTable();

  static const db = ChallengeRowRepository._();

  @override
  int? id;

  String slug;

  String title;

  int? currentRevisionId;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [ChallengeRow]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ChallengeRow copyWith({
    int? id,
    String? slug,
    String? title,
    int? currentRevisionId,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ChallengeRow',
      if (id != null) 'id': id,
      'slug': slug,
      'title': title,
      if (currentRevisionId != null) 'currentRevisionId': currentRevisionId,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static ChallengeRowInclude include() {
    return ChallengeRowInclude._();
  }

  static ChallengeRowIncludeList includeList({
    _is.WhereExpressionBuilder<ChallengeRowTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ChallengeRowTable>? orderBy,
    _is.OrderByListBuilder<ChallengeRowTable>? orderByList,
    ChallengeRowInclude? include,
  }) {
    return ChallengeRowIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ChallengeRow.t),
      orderByList: orderByList?.call(ChallengeRow.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ChallengeRowImpl extends ChallengeRow {
  _ChallengeRowImpl({
    int? id,
    required String slug,
    required String title,
    int? currentRevisionId,
    required DateTime createdAt,
  }) : super._(
         id: id,
         slug: slug,
         title: title,
         currentRevisionId: currentRevisionId,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [ChallengeRow]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ChallengeRow copyWith({
    Object? id = _Undefined,
    String? slug,
    String? title,
    Object? currentRevisionId = _Undefined,
    DateTime? createdAt,
  }) {
    return ChallengeRow(
      id: id is int? ? id : this.id,
      slug: slug ?? this.slug,
      title: title ?? this.title,
      currentRevisionId: currentRevisionId is int?
          ? currentRevisionId
          : this.currentRevisionId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ChallengeRowUpdateTable extends _is.UpdateTable<ChallengeRowTable> {
  ChallengeRowUpdateTable(super.table);

  _is.ColumnValue<String, String> slug(String value) =>
      _is.ColumnValue(table.slug, value);

  _is.ColumnValue<String, String> title(String value) =>
      _is.ColumnValue(table.title, value);

  _is.ColumnValue<int, int> currentRevisionId(int? value) =>
      _is.ColumnValue(table.currentRevisionId, value);

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(table.createdAt, value);
}

class ChallengeRowTable extends _is.Table<int?> {
  ChallengeRowTable({super.tableRelation}) : super(tableName: 'challenge') {
    updateTable = ChallengeRowUpdateTable(this);
    slug = _is.ColumnString('slug', this);
    title = _is.ColumnString('title', this);
    currentRevisionId = _is.ColumnInt(
      'current_revision_id',
      this,
      fieldName: 'currentRevisionId',
    );
    createdAt = _is.ColumnDateTime('created_at', this, fieldName: 'createdAt');
  }

  late final ChallengeRowUpdateTable updateTable;

  late final _is.ColumnString slug;

  late final _is.ColumnString title;

  late final _is.ColumnInt currentRevisionId;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    slug,
    title,
    currentRevisionId,
    createdAt,
  ];
}

class ChallengeRowInclude extends _is.IncludeObject {
  ChallengeRowInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => ChallengeRow.t;
}

class ChallengeRowIncludeList extends _is.IncludeList {
  ChallengeRowIncludeList._({
    _is.WhereExpressionBuilder<ChallengeRowTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ChallengeRow.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => ChallengeRow.t;
}

class ChallengeRowRepository {
  const ChallengeRowRepository._();

  /// Returns a list of [ChallengeRow]s matching the given query parameters.
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
  Future<List<ChallengeRow>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ChallengeRowTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ChallengeRowTable>? orderBy,
    _is.OrderByListBuilder<ChallengeRowTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ChallengeRow>(
      where: where?.call(ChallengeRow.t),
      orderBy: orderBy?.call(ChallengeRow.t),
      orderByList: orderByList?.call(ChallengeRow.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [ChallengeRow]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `ChallengeRow.t`.
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
  _ida.Stream<List<ChallengeRow>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ChallengeRowTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ChallengeRowTable>? orderBy,
    _is.OrderByListBuilder<ChallengeRowTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<ChallengeRow>(
      where: where?.call(ChallengeRow.t),
      orderBy: orderBy?.call(ChallengeRow.t),
      orderByList: orderByList?.call(ChallengeRow.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [ChallengeRow] matching the given query parameters.
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
  Future<ChallengeRow?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ChallengeRowTable>? where,
    int? offset,
    _is.OrderByBuilder<ChallengeRowTable>? orderBy,
    _is.OrderByListBuilder<ChallengeRowTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ChallengeRow>(
      where: where?.call(ChallengeRow.t),
      orderBy: orderBy?.call(ChallengeRow.t),
      orderByList: orderByList?.call(ChallengeRow.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ChallengeRow] by its [id] or null if no such row exists.
  Future<ChallengeRow?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ChallengeRow>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ChallengeRow]s in the list and returns the inserted rows.
  ///
  /// The returned [ChallengeRow]s will have their `id` fields set.
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
  Future<List<ChallengeRow>> insert(
    _is.DatabaseSession session,
    List<ChallengeRow> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<ChallengeRow>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [ChallengeRow] and returns the inserted row.
  ///
  /// The returned [ChallengeRow] will have its `id` field set.
  Future<ChallengeRow> insertRow(
    _is.DatabaseSession session,
    ChallengeRow row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<ChallengeRow>(row, transaction: transaction);
  }

  /// Upserts all [ChallengeRow]s in the list and returns the resulting rows.
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
  /// The returned [ChallengeRow]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ChallengeRow>> upsert(
    _is.DatabaseSession session,
    List<ChallengeRow> rows, {
    required _is.ColumnSelections<ChallengeRowTable> conflictColumns,
    _is.ColumnSelections<ChallengeRowTable>? updateColumns,
    _is.WhereExpressionBuilder<ChallengeRowTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<ChallengeRow>(
      rows,
      conflictColumns: conflictColumns(ChallengeRow.t),
      updateColumns: updateColumns?.call(ChallengeRow.t),
      updateWhere: updateWhere?.call(ChallengeRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [ChallengeRow] and returns the resulting row.
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
  /// The returned [ChallengeRow] will have its `id` field set.
  Future<ChallengeRow?> upsertRow(
    _is.DatabaseSession session,
    ChallengeRow row, {
    required _is.ColumnSelections<ChallengeRowTable> conflictColumns,
    _is.ColumnSelections<ChallengeRowTable>? updateColumns,
    _is.WhereExpressionBuilder<ChallengeRowTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<ChallengeRow>(
      row,
      conflictColumns: conflictColumns(ChallengeRow.t),
      updateColumns: updateColumns?.call(ChallengeRow.t),
      updateWhere: updateWhere?.call(ChallengeRow.t),
      transaction: transaction,
    );
  }

  /// Updates all [ChallengeRow]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ChallengeRow>> update(
    _is.DatabaseSession session,
    List<ChallengeRow> rows, {
    _is.ColumnSelections<ChallengeRowTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<ChallengeRow>(
      rows,
      columns: columns?.call(ChallengeRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [ChallengeRow]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ChallengeRow> updateRow(
    _is.DatabaseSession session,
    ChallengeRow row, {
    _is.ColumnSelections<ChallengeRowTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<ChallengeRow>(
      row,
      columns: columns?.call(ChallengeRow.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ChallengeRow] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ChallengeRow?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<ChallengeRowUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<ChallengeRow>(
      id,
      columnValues: columnValues(ChallengeRow.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ChallengeRow]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ChallengeRow>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ChallengeRowUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<ChallengeRowTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ChallengeRowTable>? orderBy,
    _is.OrderByListBuilder<ChallengeRowTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<ChallengeRow>(
      columnValues: columnValues(ChallengeRow.t.updateTable),
      where: where(ChallengeRow.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ChallengeRow.t),
      orderByList: orderByList?.call(ChallengeRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [ChallengeRow]s in the list and returns the deleted rows.
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
  Future<List<ChallengeRow>> delete(
    _is.DatabaseSession session,
    List<ChallengeRow> rows, {
    _is.OrderByBuilder<ChallengeRowTable>? orderBy,
    _is.OrderByListBuilder<ChallengeRowTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<ChallengeRow>(
      rows,
      orderBy: orderBy?.call(ChallengeRow.t),
      orderByList: orderByList?.call(ChallengeRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [ChallengeRow].
  Future<ChallengeRow> deleteRow(
    _is.DatabaseSession session,
    ChallengeRow row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ChallengeRow>(row, transaction: transaction);
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ChallengeRow>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ChallengeRowTable> where,
    _is.OrderByBuilder<ChallengeRowTable>? orderBy,
    _is.OrderByListBuilder<ChallengeRowTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<ChallengeRow>(
      where: where(ChallengeRow.t),
      orderBy: orderBy?.call(ChallengeRow.t),
      orderByList: orderByList?.call(ChallengeRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ChallengeRowTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<ChallengeRow>(
      where: where?.call(ChallengeRow.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ChallengeRow] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ChallengeRowTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ChallengeRow>(
      where: where(ChallengeRow.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
