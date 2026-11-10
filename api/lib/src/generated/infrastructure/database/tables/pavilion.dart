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

/// 万博 seed の参照用マスター。出題・採点はパビリオン種別に依存しない。
abstract class PavilionRow
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  PavilionRow._({
    this.id,
    required this.sourceKey,
    required this.name,
    this.lat,
    this.lon,
  });

  factory PavilionRow({
    int? id,
    required String sourceKey,
    required String name,
    double? lat,
    double? lon,
  }) = _PavilionRowImpl;

  factory PavilionRow.fromJson(Map<String, dynamic> jsonSerialization) {
    return PavilionRow(
      id: jsonSerialization['id'] as int?,
      sourceKey: jsonSerialization['sourceKey'] as String,
      name: jsonSerialization['name'] as String,
      lat: (jsonSerialization['lat'] as num?)?.toDouble(),
      lon: (jsonSerialization['lon'] as num?)?.toDouble(),
    );
  }

  static final t = PavilionRowTable();

  static const db = PavilionRowRepository._();

  @override
  int? id;

  String sourceKey;

  String name;

  double? lat;

  double? lon;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [PavilionRow]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  PavilionRow copyWith({
    int? id,
    String? sourceKey,
    String? name,
    double? lat,
    double? lon,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PavilionRow',
      if (id != null) 'id': id,
      'sourceKey': sourceKey,
      'name': name,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static PavilionRowInclude include() {
    return PavilionRowInclude._();
  }

  static PavilionRowIncludeList includeList({
    _is.WhereExpressionBuilder<PavilionRowTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PavilionRowTable>? orderBy,
    _is.OrderByListBuilder<PavilionRowTable>? orderByList,
    PavilionRowInclude? include,
  }) {
    return PavilionRowIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PavilionRow.t),
      orderByList: orderByList?.call(PavilionRow.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PavilionRowImpl extends PavilionRow {
  _PavilionRowImpl({
    int? id,
    required String sourceKey,
    required String name,
    double? lat,
    double? lon,
  }) : super._(id: id, sourceKey: sourceKey, name: name, lat: lat, lon: lon);

  /// Returns a shallow copy of this [PavilionRow]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  PavilionRow copyWith({
    Object? id = _Undefined,
    String? sourceKey,
    String? name,
    Object? lat = _Undefined,
    Object? lon = _Undefined,
  }) {
    return PavilionRow(
      id: id is int? ? id : this.id,
      sourceKey: sourceKey ?? this.sourceKey,
      name: name ?? this.name,
      lat: lat is double? ? lat : this.lat,
      lon: lon is double? ? lon : this.lon,
    );
  }
}

class PavilionRowUpdateTable extends _is.UpdateTable<PavilionRowTable> {
  PavilionRowUpdateTable(super.table);

  _is.ColumnValue<String, String> sourceKey(String value) =>
      _is.ColumnValue(table.sourceKey, value);

  _is.ColumnValue<String, String> name(String value) =>
      _is.ColumnValue(table.name, value);

  _is.ColumnValue<double, double> lat(double? value) =>
      _is.ColumnValue(table.lat, value);

  _is.ColumnValue<double, double> lon(double? value) =>
      _is.ColumnValue(table.lon, value);
}

class PavilionRowTable extends _is.Table<int?> {
  PavilionRowTable({super.tableRelation}) : super(tableName: 'pavilion') {
    updateTable = PavilionRowUpdateTable(this);
    sourceKey = _is.ColumnString('source_key', this, fieldName: 'sourceKey');
    name = _is.ColumnString('name', this);
    lat = _is.ColumnDouble('lat', this);
    lon = _is.ColumnDouble('lon', this);
  }

  late final PavilionRowUpdateTable updateTable;

  late final _is.ColumnString sourceKey;

  late final _is.ColumnString name;

  late final _is.ColumnDouble lat;

  late final _is.ColumnDouble lon;

  @override
  List<_is.Column> get columns => [id, sourceKey, name, lat, lon];
}

class PavilionRowInclude extends _is.IncludeObject {
  PavilionRowInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => PavilionRow.t;
}

class PavilionRowIncludeList extends _is.IncludeList {
  PavilionRowIncludeList._({
    _is.WhereExpressionBuilder<PavilionRowTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PavilionRow.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => PavilionRow.t;
}

class PavilionRowRepository {
  const PavilionRowRepository._();

  /// Returns a list of [PavilionRow]s matching the given query parameters.
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
  Future<List<PavilionRow>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PavilionRowTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PavilionRowTable>? orderBy,
    _is.OrderByListBuilder<PavilionRowTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PavilionRow>(
      where: where?.call(PavilionRow.t),
      orderBy: orderBy?.call(PavilionRow.t),
      orderByList: orderByList?.call(PavilionRow.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [PavilionRow]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `PavilionRow.t`.
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
  _ida.Stream<List<PavilionRow>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PavilionRowTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PavilionRowTable>? orderBy,
    _is.OrderByListBuilder<PavilionRowTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<PavilionRow>(
      where: where?.call(PavilionRow.t),
      orderBy: orderBy?.call(PavilionRow.t),
      orderByList: orderByList?.call(PavilionRow.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [PavilionRow] matching the given query parameters.
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
  Future<PavilionRow?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PavilionRowTable>? where,
    int? offset,
    _is.OrderByBuilder<PavilionRowTable>? orderBy,
    _is.OrderByListBuilder<PavilionRowTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PavilionRow>(
      where: where?.call(PavilionRow.t),
      orderBy: orderBy?.call(PavilionRow.t),
      orderByList: orderByList?.call(PavilionRow.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PavilionRow] by its [id] or null if no such row exists.
  Future<PavilionRow?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PavilionRow>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PavilionRow]s in the list and returns the inserted rows.
  ///
  /// The returned [PavilionRow]s will have their `id` fields set.
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
  Future<List<PavilionRow>> insert(
    _is.DatabaseSession session,
    List<PavilionRow> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<PavilionRow>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [PavilionRow] and returns the inserted row.
  ///
  /// The returned [PavilionRow] will have its `id` field set.
  Future<PavilionRow> insertRow(
    _is.DatabaseSession session,
    PavilionRow row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<PavilionRow>(row, transaction: transaction);
  }

  /// Upserts all [PavilionRow]s in the list and returns the resulting rows.
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
  /// The returned [PavilionRow]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PavilionRow>> upsert(
    _is.DatabaseSession session,
    List<PavilionRow> rows, {
    required _is.ColumnSelections<PavilionRowTable> conflictColumns,
    _is.ColumnSelections<PavilionRowTable>? updateColumns,
    _is.WhereExpressionBuilder<PavilionRowTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<PavilionRow>(
      rows,
      conflictColumns: conflictColumns(PavilionRow.t),
      updateColumns: updateColumns?.call(PavilionRow.t),
      updateWhere: updateWhere?.call(PavilionRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [PavilionRow] and returns the resulting row.
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
  /// The returned [PavilionRow] will have its `id` field set.
  Future<PavilionRow?> upsertRow(
    _is.DatabaseSession session,
    PavilionRow row, {
    required _is.ColumnSelections<PavilionRowTable> conflictColumns,
    _is.ColumnSelections<PavilionRowTable>? updateColumns,
    _is.WhereExpressionBuilder<PavilionRowTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<PavilionRow>(
      row,
      conflictColumns: conflictColumns(PavilionRow.t),
      updateColumns: updateColumns?.call(PavilionRow.t),
      updateWhere: updateWhere?.call(PavilionRow.t),
      transaction: transaction,
    );
  }

  /// Updates all [PavilionRow]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PavilionRow>> update(
    _is.DatabaseSession session,
    List<PavilionRow> rows, {
    _is.ColumnSelections<PavilionRowTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<PavilionRow>(
      rows,
      columns: columns?.call(PavilionRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [PavilionRow]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PavilionRow> updateRow(
    _is.DatabaseSession session,
    PavilionRow row, {
    _is.ColumnSelections<PavilionRowTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<PavilionRow>(
      row,
      columns: columns?.call(PavilionRow.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PavilionRow] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PavilionRow?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<PavilionRowUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<PavilionRow>(
      id,
      columnValues: columnValues(PavilionRow.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PavilionRow]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PavilionRow>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<PavilionRowUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<PavilionRowTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PavilionRowTable>? orderBy,
    _is.OrderByListBuilder<PavilionRowTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<PavilionRow>(
      columnValues: columnValues(PavilionRow.t.updateTable),
      where: where(PavilionRow.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PavilionRow.t),
      orderByList: orderByList?.call(PavilionRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [PavilionRow]s in the list and returns the deleted rows.
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
  Future<List<PavilionRow>> delete(
    _is.DatabaseSession session,
    List<PavilionRow> rows, {
    _is.OrderByBuilder<PavilionRowTable>? orderBy,
    _is.OrderByListBuilder<PavilionRowTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<PavilionRow>(
      rows,
      orderBy: orderBy?.call(PavilionRow.t),
      orderByList: orderByList?.call(PavilionRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [PavilionRow].
  Future<PavilionRow> deleteRow(
    _is.DatabaseSession session,
    PavilionRow row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PavilionRow>(row, transaction: transaction);
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PavilionRow>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PavilionRowTable> where,
    _is.OrderByBuilder<PavilionRowTable>? orderBy,
    _is.OrderByListBuilder<PavilionRowTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<PavilionRow>(
      where: where(PavilionRow.t),
      orderBy: orderBy?.call(PavilionRow.t),
      orderByList: orderByList?.call(PavilionRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PavilionRowTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<PavilionRow>(
      where: where?.call(PavilionRow.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PavilionRow] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PavilionRowTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PavilionRow>(
      where: where(PavilionRow.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
