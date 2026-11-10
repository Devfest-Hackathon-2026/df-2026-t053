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

/// 内容アドレスの素材。sha256 は小文字の 16 進 64 桁、byte_length は 1 以上。
abstract class AssetRow
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  AssetRow._({
    this.id,
    required this.sha256,
    required this.objectPath,
    required this.contentType,
    required this.byteLength,
    required this.createdAt,
  });

  factory AssetRow({
    int? id,
    required String sha256,
    required String objectPath,
    required String contentType,
    required int byteLength,
    required DateTime createdAt,
  }) = _AssetRowImpl;

  factory AssetRow.fromJson(Map<String, dynamic> jsonSerialization) {
    return AssetRow(
      id: jsonSerialization['id'] as int?,
      sha256: jsonSerialization['sha256'] as String,
      objectPath: jsonSerialization['objectPath'] as String,
      contentType: jsonSerialization['contentType'] as String,
      byteLength: jsonSerialization['byteLength'] as int,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = AssetRowTable();

  static const db = AssetRowRepository._();

  @override
  int? id;

  String sha256;

  String objectPath;

  String contentType;

  int byteLength;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [AssetRow]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AssetRow copyWith({
    int? id,
    String? sha256,
    String? objectPath,
    String? contentType,
    int? byteLength,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AssetRow',
      if (id != null) 'id': id,
      'sha256': sha256,
      'objectPath': objectPath,
      'contentType': contentType,
      'byteLength': byteLength,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static AssetRowInclude include() {
    return AssetRowInclude._();
  }

  static AssetRowIncludeList includeList({
    _is.WhereExpressionBuilder<AssetRowTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AssetRowTable>? orderBy,
    _is.OrderByListBuilder<AssetRowTable>? orderByList,
    AssetRowInclude? include,
  }) {
    return AssetRowIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AssetRow.t),
      orderByList: orderByList?.call(AssetRow.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AssetRowImpl extends AssetRow {
  _AssetRowImpl({
    int? id,
    required String sha256,
    required String objectPath,
    required String contentType,
    required int byteLength,
    required DateTime createdAt,
  }) : super._(
         id: id,
         sha256: sha256,
         objectPath: objectPath,
         contentType: contentType,
         byteLength: byteLength,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [AssetRow]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  AssetRow copyWith({
    Object? id = _Undefined,
    String? sha256,
    String? objectPath,
    String? contentType,
    int? byteLength,
    DateTime? createdAt,
  }) {
    return AssetRow(
      id: id is int? ? id : this.id,
      sha256: sha256 ?? this.sha256,
      objectPath: objectPath ?? this.objectPath,
      contentType: contentType ?? this.contentType,
      byteLength: byteLength ?? this.byteLength,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class AssetRowUpdateTable extends _is.UpdateTable<AssetRowTable> {
  AssetRowUpdateTable(super.table);

  _is.ColumnValue<String, String> sha256(String value) =>
      _is.ColumnValue(table.sha256, value);

  _is.ColumnValue<String, String> objectPath(String value) =>
      _is.ColumnValue(table.objectPath, value);

  _is.ColumnValue<String, String> contentType(String value) =>
      _is.ColumnValue(table.contentType, value);

  _is.ColumnValue<int, int> byteLength(int value) =>
      _is.ColumnValue(table.byteLength, value);

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(table.createdAt, value);
}

class AssetRowTable extends _is.Table<int?> {
  AssetRowTable({super.tableRelation}) : super(tableName: 'asset') {
    updateTable = AssetRowUpdateTable(this);
    sha256 = _is.ColumnString('sha256', this);
    objectPath = _is.ColumnString('object_path', this, fieldName: 'objectPath');
    contentType = _is.ColumnString(
      'content_type',
      this,
      fieldName: 'contentType',
    );
    byteLength = _is.ColumnInt('byte_length', this, fieldName: 'byteLength');
    createdAt = _is.ColumnDateTime('created_at', this, fieldName: 'createdAt');
  }

  late final AssetRowUpdateTable updateTable;

  late final _is.ColumnString sha256;

  late final _is.ColumnString objectPath;

  late final _is.ColumnString contentType;

  late final _is.ColumnInt byteLength;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    sha256,
    objectPath,
    contentType,
    byteLength,
    createdAt,
  ];
}

class AssetRowInclude extends _is.IncludeObject {
  AssetRowInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => AssetRow.t;
}

class AssetRowIncludeList extends _is.IncludeList {
  AssetRowIncludeList._({
    _is.WhereExpressionBuilder<AssetRowTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AssetRow.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => AssetRow.t;
}

class AssetRowRepository {
  const AssetRowRepository._();

  /// Returns a list of [AssetRow]s matching the given query parameters.
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
  Future<List<AssetRow>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AssetRowTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AssetRowTable>? orderBy,
    _is.OrderByListBuilder<AssetRowTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AssetRow>(
      where: where?.call(AssetRow.t),
      orderBy: orderBy?.call(AssetRow.t),
      orderByList: orderByList?.call(AssetRow.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [AssetRow]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `AssetRow.t`.
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
  _ida.Stream<List<AssetRow>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AssetRowTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AssetRowTable>? orderBy,
    _is.OrderByListBuilder<AssetRowTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<AssetRow>(
      where: where?.call(AssetRow.t),
      orderBy: orderBy?.call(AssetRow.t),
      orderByList: orderByList?.call(AssetRow.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [AssetRow] matching the given query parameters.
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
  Future<AssetRow?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AssetRowTable>? where,
    int? offset,
    _is.OrderByBuilder<AssetRowTable>? orderBy,
    _is.OrderByListBuilder<AssetRowTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AssetRow>(
      where: where?.call(AssetRow.t),
      orderBy: orderBy?.call(AssetRow.t),
      orderByList: orderByList?.call(AssetRow.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AssetRow] by its [id] or null if no such row exists.
  Future<AssetRow?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AssetRow>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AssetRow]s in the list and returns the inserted rows.
  ///
  /// The returned [AssetRow]s will have their `id` fields set.
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
  Future<List<AssetRow>> insert(
    _is.DatabaseSession session,
    List<AssetRow> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<AssetRow>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [AssetRow] and returns the inserted row.
  ///
  /// The returned [AssetRow] will have its `id` field set.
  Future<AssetRow> insertRow(
    _is.DatabaseSession session,
    AssetRow row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<AssetRow>(row, transaction: transaction);
  }

  /// Upserts all [AssetRow]s in the list and returns the resulting rows.
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
  /// The returned [AssetRow]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AssetRow>> upsert(
    _is.DatabaseSession session,
    List<AssetRow> rows, {
    required _is.ColumnSelections<AssetRowTable> conflictColumns,
    _is.ColumnSelections<AssetRowTable>? updateColumns,
    _is.WhereExpressionBuilder<AssetRowTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<AssetRow>(
      rows,
      conflictColumns: conflictColumns(AssetRow.t),
      updateColumns: updateColumns?.call(AssetRow.t),
      updateWhere: updateWhere?.call(AssetRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [AssetRow] and returns the resulting row.
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
  /// The returned [AssetRow] will have its `id` field set.
  Future<AssetRow?> upsertRow(
    _is.DatabaseSession session,
    AssetRow row, {
    required _is.ColumnSelections<AssetRowTable> conflictColumns,
    _is.ColumnSelections<AssetRowTable>? updateColumns,
    _is.WhereExpressionBuilder<AssetRowTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<AssetRow>(
      row,
      conflictColumns: conflictColumns(AssetRow.t),
      updateColumns: updateColumns?.call(AssetRow.t),
      updateWhere: updateWhere?.call(AssetRow.t),
      transaction: transaction,
    );
  }

  /// Updates all [AssetRow]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AssetRow>> update(
    _is.DatabaseSession session,
    List<AssetRow> rows, {
    _is.ColumnSelections<AssetRowTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<AssetRow>(
      rows,
      columns: columns?.call(AssetRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [AssetRow]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AssetRow> updateRow(
    _is.DatabaseSession session,
    AssetRow row, {
    _is.ColumnSelections<AssetRowTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<AssetRow>(
      row,
      columns: columns?.call(AssetRow.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AssetRow] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AssetRow?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<AssetRowUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<AssetRow>(
      id,
      columnValues: columnValues(AssetRow.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AssetRow]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AssetRow>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<AssetRowUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<AssetRowTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AssetRowTable>? orderBy,
    _is.OrderByListBuilder<AssetRowTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<AssetRow>(
      columnValues: columnValues(AssetRow.t.updateTable),
      where: where(AssetRow.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AssetRow.t),
      orderByList: orderByList?.call(AssetRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [AssetRow]s in the list and returns the deleted rows.
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
  Future<List<AssetRow>> delete(
    _is.DatabaseSession session,
    List<AssetRow> rows, {
    _is.OrderByBuilder<AssetRowTable>? orderBy,
    _is.OrderByListBuilder<AssetRowTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<AssetRow>(
      rows,
      orderBy: orderBy?.call(AssetRow.t),
      orderByList: orderByList?.call(AssetRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [AssetRow].
  Future<AssetRow> deleteRow(
    _is.DatabaseSession session,
    AssetRow row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AssetRow>(row, transaction: transaction);
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AssetRow>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AssetRowTable> where,
    _is.OrderByBuilder<AssetRowTable>? orderBy,
    _is.OrderByListBuilder<AssetRowTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<AssetRow>(
      where: where(AssetRow.t),
      orderBy: orderBy?.call(AssetRow.t),
      orderByList: orderByList?.call(AssetRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AssetRowTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<AssetRow>(
      where: where?.call(AssetRow.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AssetRow] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AssetRowTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AssetRow>(
      where: where(AssetRow.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
