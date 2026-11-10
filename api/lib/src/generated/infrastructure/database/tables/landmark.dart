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

/// 版に固定した会場図上の地点。表示座標（pos_x/pos_z）と地理座標（lat/lon）は別物。
abstract class LandmarkRow
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  LandmarkRow._({
    this.id,
    required this.revisionId,
    required this.pavilionId,
    required this.displayName,
    required this.posX,
    required this.posZ,
    this.lat,
    this.lon,
  });

  factory LandmarkRow({
    int? id,
    required int revisionId,
    required int pavilionId,
    required String displayName,
    required double posX,
    required double posZ,
    double? lat,
    double? lon,
  }) = _LandmarkRowImpl;

  factory LandmarkRow.fromJson(Map<String, dynamic> jsonSerialization) {
    return LandmarkRow(
      id: jsonSerialization['id'] as int?,
      revisionId: jsonSerialization['revisionId'] as int,
      pavilionId: jsonSerialization['pavilionId'] as int,
      displayName: jsonSerialization['displayName'] as String,
      posX: (jsonSerialization['posX'] as num).toDouble(),
      posZ: (jsonSerialization['posZ'] as num).toDouble(),
      lat: (jsonSerialization['lat'] as num?)?.toDouble(),
      lon: (jsonSerialization['lon'] as num?)?.toDouble(),
    );
  }

  static final t = LandmarkRowTable();

  static const db = LandmarkRowRepository._();

  @override
  int? id;

  int revisionId;

  int pavilionId;

  String displayName;

  double posX;

  double posZ;

  double? lat;

  double? lon;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [LandmarkRow]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  LandmarkRow copyWith({
    int? id,
    int? revisionId,
    int? pavilionId,
    String? displayName,
    double? posX,
    double? posZ,
    double? lat,
    double? lon,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'LandmarkRow',
      if (id != null) 'id': id,
      'revisionId': revisionId,
      'pavilionId': pavilionId,
      'displayName': displayName,
      'posX': posX,
      'posZ': posZ,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static LandmarkRowInclude include() {
    return LandmarkRowInclude._();
  }

  static LandmarkRowIncludeList includeList({
    _is.WhereExpressionBuilder<LandmarkRowTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<LandmarkRowTable>? orderBy,
    _is.OrderByListBuilder<LandmarkRowTable>? orderByList,
    LandmarkRowInclude? include,
  }) {
    return LandmarkRowIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(LandmarkRow.t),
      orderByList: orderByList?.call(LandmarkRow.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _LandmarkRowImpl extends LandmarkRow {
  _LandmarkRowImpl({
    int? id,
    required int revisionId,
    required int pavilionId,
    required String displayName,
    required double posX,
    required double posZ,
    double? lat,
    double? lon,
  }) : super._(
         id: id,
         revisionId: revisionId,
         pavilionId: pavilionId,
         displayName: displayName,
         posX: posX,
         posZ: posZ,
         lat: lat,
         lon: lon,
       );

  /// Returns a shallow copy of this [LandmarkRow]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  LandmarkRow copyWith({
    Object? id = _Undefined,
    int? revisionId,
    int? pavilionId,
    String? displayName,
    double? posX,
    double? posZ,
    Object? lat = _Undefined,
    Object? lon = _Undefined,
  }) {
    return LandmarkRow(
      id: id is int? ? id : this.id,
      revisionId: revisionId ?? this.revisionId,
      pavilionId: pavilionId ?? this.pavilionId,
      displayName: displayName ?? this.displayName,
      posX: posX ?? this.posX,
      posZ: posZ ?? this.posZ,
      lat: lat is double? ? lat : this.lat,
      lon: lon is double? ? lon : this.lon,
    );
  }
}

class LandmarkRowUpdateTable extends _is.UpdateTable<LandmarkRowTable> {
  LandmarkRowUpdateTable(super.table);

  _is.ColumnValue<int, int> revisionId(int value) =>
      _is.ColumnValue(table.revisionId, value);

  _is.ColumnValue<int, int> pavilionId(int value) =>
      _is.ColumnValue(table.pavilionId, value);

  _is.ColumnValue<String, String> displayName(String value) =>
      _is.ColumnValue(table.displayName, value);

  _is.ColumnValue<double, double> posX(double value) =>
      _is.ColumnValue(table.posX, value);

  _is.ColumnValue<double, double> posZ(double value) =>
      _is.ColumnValue(table.posZ, value);

  _is.ColumnValue<double, double> lat(double? value) =>
      _is.ColumnValue(table.lat, value);

  _is.ColumnValue<double, double> lon(double? value) =>
      _is.ColumnValue(table.lon, value);
}

class LandmarkRowTable extends _is.Table<int?> {
  LandmarkRowTable({super.tableRelation}) : super(tableName: 'landmark') {
    updateTable = LandmarkRowUpdateTable(this);
    revisionId = _is.ColumnInt('revision_id', this, fieldName: 'revisionId');
    pavilionId = _is.ColumnInt('pavilion_id', this, fieldName: 'pavilionId');
    displayName = _is.ColumnString(
      'display_name',
      this,
      fieldName: 'displayName',
    );
    posX = _is.ColumnDouble('pos_x', this, fieldName: 'posX');
    posZ = _is.ColumnDouble('pos_z', this, fieldName: 'posZ');
    lat = _is.ColumnDouble('lat', this);
    lon = _is.ColumnDouble('lon', this);
  }

  late final LandmarkRowUpdateTable updateTable;

  late final _is.ColumnInt revisionId;

  late final _is.ColumnInt pavilionId;

  late final _is.ColumnString displayName;

  late final _is.ColumnDouble posX;

  late final _is.ColumnDouble posZ;

  late final _is.ColumnDouble lat;

  late final _is.ColumnDouble lon;

  @override
  List<_is.Column> get columns => [
    id,
    revisionId,
    pavilionId,
    displayName,
    posX,
    posZ,
    lat,
    lon,
  ];
}

class LandmarkRowInclude extends _is.IncludeObject {
  LandmarkRowInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => LandmarkRow.t;
}

class LandmarkRowIncludeList extends _is.IncludeList {
  LandmarkRowIncludeList._({
    _is.WhereExpressionBuilder<LandmarkRowTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(LandmarkRow.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => LandmarkRow.t;
}

class LandmarkRowRepository {
  const LandmarkRowRepository._();

  /// Returns a list of [LandmarkRow]s matching the given query parameters.
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
  Future<List<LandmarkRow>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<LandmarkRowTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<LandmarkRowTable>? orderBy,
    _is.OrderByListBuilder<LandmarkRowTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<LandmarkRow>(
      where: where?.call(LandmarkRow.t),
      orderBy: orderBy?.call(LandmarkRow.t),
      orderByList: orderByList?.call(LandmarkRow.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [LandmarkRow]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `LandmarkRow.t`.
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
  _ida.Stream<List<LandmarkRow>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<LandmarkRowTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<LandmarkRowTable>? orderBy,
    _is.OrderByListBuilder<LandmarkRowTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<LandmarkRow>(
      where: where?.call(LandmarkRow.t),
      orderBy: orderBy?.call(LandmarkRow.t),
      orderByList: orderByList?.call(LandmarkRow.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [LandmarkRow] matching the given query parameters.
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
  Future<LandmarkRow?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<LandmarkRowTable>? where,
    int? offset,
    _is.OrderByBuilder<LandmarkRowTable>? orderBy,
    _is.OrderByListBuilder<LandmarkRowTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<LandmarkRow>(
      where: where?.call(LandmarkRow.t),
      orderBy: orderBy?.call(LandmarkRow.t),
      orderByList: orderByList?.call(LandmarkRow.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [LandmarkRow] by its [id] or null if no such row exists.
  Future<LandmarkRow?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<LandmarkRow>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [LandmarkRow]s in the list and returns the inserted rows.
  ///
  /// The returned [LandmarkRow]s will have their `id` fields set.
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
  Future<List<LandmarkRow>> insert(
    _is.DatabaseSession session,
    List<LandmarkRow> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<LandmarkRow>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [LandmarkRow] and returns the inserted row.
  ///
  /// The returned [LandmarkRow] will have its `id` field set.
  Future<LandmarkRow> insertRow(
    _is.DatabaseSession session,
    LandmarkRow row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<LandmarkRow>(row, transaction: transaction);
  }

  /// Upserts all [LandmarkRow]s in the list and returns the resulting rows.
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
  /// The returned [LandmarkRow]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<LandmarkRow>> upsert(
    _is.DatabaseSession session,
    List<LandmarkRow> rows, {
    required _is.ColumnSelections<LandmarkRowTable> conflictColumns,
    _is.ColumnSelections<LandmarkRowTable>? updateColumns,
    _is.WhereExpressionBuilder<LandmarkRowTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<LandmarkRow>(
      rows,
      conflictColumns: conflictColumns(LandmarkRow.t),
      updateColumns: updateColumns?.call(LandmarkRow.t),
      updateWhere: updateWhere?.call(LandmarkRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [LandmarkRow] and returns the resulting row.
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
  /// The returned [LandmarkRow] will have its `id` field set.
  Future<LandmarkRow?> upsertRow(
    _is.DatabaseSession session,
    LandmarkRow row, {
    required _is.ColumnSelections<LandmarkRowTable> conflictColumns,
    _is.ColumnSelections<LandmarkRowTable>? updateColumns,
    _is.WhereExpressionBuilder<LandmarkRowTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<LandmarkRow>(
      row,
      conflictColumns: conflictColumns(LandmarkRow.t),
      updateColumns: updateColumns?.call(LandmarkRow.t),
      updateWhere: updateWhere?.call(LandmarkRow.t),
      transaction: transaction,
    );
  }

  /// Updates all [LandmarkRow]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<LandmarkRow>> update(
    _is.DatabaseSession session,
    List<LandmarkRow> rows, {
    _is.ColumnSelections<LandmarkRowTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<LandmarkRow>(
      rows,
      columns: columns?.call(LandmarkRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [LandmarkRow]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<LandmarkRow> updateRow(
    _is.DatabaseSession session,
    LandmarkRow row, {
    _is.ColumnSelections<LandmarkRowTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<LandmarkRow>(
      row,
      columns: columns?.call(LandmarkRow.t),
      transaction: transaction,
    );
  }

  /// Updates a single [LandmarkRow] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<LandmarkRow?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<LandmarkRowUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<LandmarkRow>(
      id,
      columnValues: columnValues(LandmarkRow.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [LandmarkRow]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<LandmarkRow>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<LandmarkRowUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<LandmarkRowTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<LandmarkRowTable>? orderBy,
    _is.OrderByListBuilder<LandmarkRowTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<LandmarkRow>(
      columnValues: columnValues(LandmarkRow.t.updateTable),
      where: where(LandmarkRow.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(LandmarkRow.t),
      orderByList: orderByList?.call(LandmarkRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [LandmarkRow]s in the list and returns the deleted rows.
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
  Future<List<LandmarkRow>> delete(
    _is.DatabaseSession session,
    List<LandmarkRow> rows, {
    _is.OrderByBuilder<LandmarkRowTable>? orderBy,
    _is.OrderByListBuilder<LandmarkRowTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<LandmarkRow>(
      rows,
      orderBy: orderBy?.call(LandmarkRow.t),
      orderByList: orderByList?.call(LandmarkRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [LandmarkRow].
  Future<LandmarkRow> deleteRow(
    _is.DatabaseSession session,
    LandmarkRow row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<LandmarkRow>(row, transaction: transaction);
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<LandmarkRow>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<LandmarkRowTable> where,
    _is.OrderByBuilder<LandmarkRowTable>? orderBy,
    _is.OrderByListBuilder<LandmarkRowTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<LandmarkRow>(
      where: where(LandmarkRow.t),
      orderBy: orderBy?.call(LandmarkRow.t),
      orderByList: orderByList?.call(LandmarkRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<LandmarkRowTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<LandmarkRow>(
      where: where?.call(LandmarkRow.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [LandmarkRow] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<LandmarkRowTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<LandmarkRow>(
      where: where(LandmarkRow.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
