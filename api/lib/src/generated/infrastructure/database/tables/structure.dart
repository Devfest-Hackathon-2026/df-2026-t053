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

/// 版に固定したガイド用の構造物資料。
abstract class StructureRow
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  StructureRow._({
    this.id,
    required this.revisionId,
    this.pavilionId,
    required this.name,
    required this.posX,
    required this.posZ,
    required this.facts,
    required this.fallbackText,
  });

  factory StructureRow({
    int? id,
    required int revisionId,
    int? pavilionId,
    required String name,
    required double posX,
    required double posZ,
    required String facts,
    required String fallbackText,
  }) = _StructureRowImpl;

  factory StructureRow.fromJson(Map<String, dynamic> jsonSerialization) {
    return StructureRow(
      id: jsonSerialization['id'] as int?,
      revisionId: jsonSerialization['revisionId'] as int,
      pavilionId: jsonSerialization['pavilionId'] as int?,
      name: jsonSerialization['name'] as String,
      posX: (jsonSerialization['posX'] as num).toDouble(),
      posZ: (jsonSerialization['posZ'] as num).toDouble(),
      facts: jsonSerialization['facts'] as String,
      fallbackText: jsonSerialization['fallbackText'] as String,
    );
  }

  static final t = StructureRowTable();

  static const db = StructureRowRepository._();

  @override
  int? id;

  int revisionId;

  int? pavilionId;

  String name;

  double posX;

  double posZ;

  String facts;

  String fallbackText;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [StructureRow]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  StructureRow copyWith({
    int? id,
    int? revisionId,
    int? pavilionId,
    String? name,
    double? posX,
    double? posZ,
    String? facts,
    String? fallbackText,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'StructureRow',
      if (id != null) 'id': id,
      'revisionId': revisionId,
      if (pavilionId != null) 'pavilionId': pavilionId,
      'name': name,
      'posX': posX,
      'posZ': posZ,
      'facts': facts,
      'fallbackText': fallbackText,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static StructureRowInclude include() {
    return StructureRowInclude._();
  }

  static StructureRowIncludeList includeList({
    _is.WhereExpressionBuilder<StructureRowTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StructureRowTable>? orderBy,
    _is.OrderByListBuilder<StructureRowTable>? orderByList,
    StructureRowInclude? include,
  }) {
    return StructureRowIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(StructureRow.t),
      orderByList: orderByList?.call(StructureRow.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _StructureRowImpl extends StructureRow {
  _StructureRowImpl({
    int? id,
    required int revisionId,
    int? pavilionId,
    required String name,
    required double posX,
    required double posZ,
    required String facts,
    required String fallbackText,
  }) : super._(
         id: id,
         revisionId: revisionId,
         pavilionId: pavilionId,
         name: name,
         posX: posX,
         posZ: posZ,
         facts: facts,
         fallbackText: fallbackText,
       );

  /// Returns a shallow copy of this [StructureRow]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  StructureRow copyWith({
    Object? id = _Undefined,
    int? revisionId,
    Object? pavilionId = _Undefined,
    String? name,
    double? posX,
    double? posZ,
    String? facts,
    String? fallbackText,
  }) {
    return StructureRow(
      id: id is int? ? id : this.id,
      revisionId: revisionId ?? this.revisionId,
      pavilionId: pavilionId is int? ? pavilionId : this.pavilionId,
      name: name ?? this.name,
      posX: posX ?? this.posX,
      posZ: posZ ?? this.posZ,
      facts: facts ?? this.facts,
      fallbackText: fallbackText ?? this.fallbackText,
    );
  }
}

class StructureRowUpdateTable extends _is.UpdateTable<StructureRowTable> {
  StructureRowUpdateTable(super.table);

  _is.ColumnValue<int, int> revisionId(int value) =>
      _is.ColumnValue(table.revisionId, value);

  _is.ColumnValue<int, int> pavilionId(int? value) =>
      _is.ColumnValue(table.pavilionId, value);

  _is.ColumnValue<String, String> name(String value) =>
      _is.ColumnValue(table.name, value);

  _is.ColumnValue<double, double> posX(double value) =>
      _is.ColumnValue(table.posX, value);

  _is.ColumnValue<double, double> posZ(double value) =>
      _is.ColumnValue(table.posZ, value);

  _is.ColumnValue<String, String> facts(String value) =>
      _is.ColumnValue(table.facts, value);

  _is.ColumnValue<String, String> fallbackText(String value) =>
      _is.ColumnValue(table.fallbackText, value);
}

class StructureRowTable extends _is.Table<int?> {
  StructureRowTable({super.tableRelation}) : super(tableName: 'structure') {
    updateTable = StructureRowUpdateTable(this);
    revisionId = _is.ColumnInt('revision_id', this, fieldName: 'revisionId');
    pavilionId = _is.ColumnInt('pavilion_id', this, fieldName: 'pavilionId');
    name = _is.ColumnString('name', this);
    posX = _is.ColumnDouble('pos_x', this, fieldName: 'posX');
    posZ = _is.ColumnDouble('pos_z', this, fieldName: 'posZ');
    facts = _is.ColumnString('facts', this);
    fallbackText = _is.ColumnString(
      'fallback_text',
      this,
      fieldName: 'fallbackText',
    );
  }

  late final StructureRowUpdateTable updateTable;

  late final _is.ColumnInt revisionId;

  late final _is.ColumnInt pavilionId;

  late final _is.ColumnString name;

  late final _is.ColumnDouble posX;

  late final _is.ColumnDouble posZ;

  late final _is.ColumnString facts;

  late final _is.ColumnString fallbackText;

  @override
  List<_is.Column> get columns => [
    id,
    revisionId,
    pavilionId,
    name,
    posX,
    posZ,
    facts,
    fallbackText,
  ];
}

class StructureRowInclude extends _is.IncludeObject {
  StructureRowInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => StructureRow.t;
}

class StructureRowIncludeList extends _is.IncludeList {
  StructureRowIncludeList._({
    _is.WhereExpressionBuilder<StructureRowTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(StructureRow.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => StructureRow.t;
}

class StructureRowRepository {
  const StructureRowRepository._();

  /// Returns a list of [StructureRow]s matching the given query parameters.
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
  Future<List<StructureRow>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StructureRowTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StructureRowTable>? orderBy,
    _is.OrderByListBuilder<StructureRowTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<StructureRow>(
      where: where?.call(StructureRow.t),
      orderBy: orderBy?.call(StructureRow.t),
      orderByList: orderByList?.call(StructureRow.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [StructureRow]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `StructureRow.t`.
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
  _ida.Stream<List<StructureRow>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StructureRowTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StructureRowTable>? orderBy,
    _is.OrderByListBuilder<StructureRowTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<StructureRow>(
      where: where?.call(StructureRow.t),
      orderBy: orderBy?.call(StructureRow.t),
      orderByList: orderByList?.call(StructureRow.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [StructureRow] matching the given query parameters.
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
  Future<StructureRow?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StructureRowTable>? where,
    int? offset,
    _is.OrderByBuilder<StructureRowTable>? orderBy,
    _is.OrderByListBuilder<StructureRowTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<StructureRow>(
      where: where?.call(StructureRow.t),
      orderBy: orderBy?.call(StructureRow.t),
      orderByList: orderByList?.call(StructureRow.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [StructureRow] by its [id] or null if no such row exists.
  Future<StructureRow?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<StructureRow>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [StructureRow]s in the list and returns the inserted rows.
  ///
  /// The returned [StructureRow]s will have their `id` fields set.
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
  Future<List<StructureRow>> insert(
    _is.DatabaseSession session,
    List<StructureRow> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<StructureRow>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [StructureRow] and returns the inserted row.
  ///
  /// The returned [StructureRow] will have its `id` field set.
  Future<StructureRow> insertRow(
    _is.DatabaseSession session,
    StructureRow row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<StructureRow>(row, transaction: transaction);
  }

  /// Upserts all [StructureRow]s in the list and returns the resulting rows.
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
  /// The returned [StructureRow]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StructureRow>> upsert(
    _is.DatabaseSession session,
    List<StructureRow> rows, {
    required _is.ColumnSelections<StructureRowTable> conflictColumns,
    _is.ColumnSelections<StructureRowTable>? updateColumns,
    _is.WhereExpressionBuilder<StructureRowTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<StructureRow>(
      rows,
      conflictColumns: conflictColumns(StructureRow.t),
      updateColumns: updateColumns?.call(StructureRow.t),
      updateWhere: updateWhere?.call(StructureRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [StructureRow] and returns the resulting row.
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
  /// The returned [StructureRow] will have its `id` field set.
  Future<StructureRow?> upsertRow(
    _is.DatabaseSession session,
    StructureRow row, {
    required _is.ColumnSelections<StructureRowTable> conflictColumns,
    _is.ColumnSelections<StructureRowTable>? updateColumns,
    _is.WhereExpressionBuilder<StructureRowTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<StructureRow>(
      row,
      conflictColumns: conflictColumns(StructureRow.t),
      updateColumns: updateColumns?.call(StructureRow.t),
      updateWhere: updateWhere?.call(StructureRow.t),
      transaction: transaction,
    );
  }

  /// Updates all [StructureRow]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StructureRow>> update(
    _is.DatabaseSession session,
    List<StructureRow> rows, {
    _is.ColumnSelections<StructureRowTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<StructureRow>(
      rows,
      columns: columns?.call(StructureRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [StructureRow]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<StructureRow> updateRow(
    _is.DatabaseSession session,
    StructureRow row, {
    _is.ColumnSelections<StructureRowTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<StructureRow>(
      row,
      columns: columns?.call(StructureRow.t),
      transaction: transaction,
    );
  }

  /// Updates a single [StructureRow] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<StructureRow?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<StructureRowUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<StructureRow>(
      id,
      columnValues: columnValues(StructureRow.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [StructureRow]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StructureRow>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<StructureRowUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<StructureRowTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StructureRowTable>? orderBy,
    _is.OrderByListBuilder<StructureRowTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<StructureRow>(
      columnValues: columnValues(StructureRow.t.updateTable),
      where: where(StructureRow.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(StructureRow.t),
      orderByList: orderByList?.call(StructureRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [StructureRow]s in the list and returns the deleted rows.
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
  Future<List<StructureRow>> delete(
    _is.DatabaseSession session,
    List<StructureRow> rows, {
    _is.OrderByBuilder<StructureRowTable>? orderBy,
    _is.OrderByListBuilder<StructureRowTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<StructureRow>(
      rows,
      orderBy: orderBy?.call(StructureRow.t),
      orderByList: orderByList?.call(StructureRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [StructureRow].
  Future<StructureRow> deleteRow(
    _is.DatabaseSession session,
    StructureRow row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<StructureRow>(row, transaction: transaction);
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StructureRow>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<StructureRowTable> where,
    _is.OrderByBuilder<StructureRowTable>? orderBy,
    _is.OrderByListBuilder<StructureRowTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<StructureRow>(
      where: where(StructureRow.t),
      orderBy: orderBy?.call(StructureRow.t),
      orderByList: orderByList?.call(StructureRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StructureRowTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<StructureRow>(
      where: where?.call(StructureRow.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [StructureRow] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<StructureRowTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<StructureRow>(
      where: where(StructureRow.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
