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

/// モードごとの開始点。free は 2〜32 行、near は 1 行（行数の検証は #26）。
abstract class SpawnPointRow
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  SpawnPointRow._({
    this.id,
    required this.modeConfigId,
    required this.x,
    required this.y,
    required this.z,
    required this.yawDeg,
    required this.sortOrder,
    this.label,
  });

  factory SpawnPointRow({
    int? id,
    required int modeConfigId,
    required double x,
    required double y,
    required double z,
    required double yawDeg,
    required int sortOrder,
    String? label,
  }) = _SpawnPointRowImpl;

  factory SpawnPointRow.fromJson(Map<String, dynamic> jsonSerialization) {
    return SpawnPointRow(
      id: jsonSerialization['id'] as int?,
      modeConfigId: jsonSerialization['modeConfigId'] as int,
      x: (jsonSerialization['x'] as num).toDouble(),
      y: (jsonSerialization['y'] as num).toDouble(),
      z: (jsonSerialization['z'] as num).toDouble(),
      yawDeg: (jsonSerialization['yawDeg'] as num).toDouble(),
      sortOrder: jsonSerialization['sortOrder'] as int,
      label: jsonSerialization['label'] as String?,
    );
  }

  static final t = SpawnPointRowTable();

  static const db = SpawnPointRowRepository._();

  @override
  int? id;

  int modeConfigId;

  double x;

  double y;

  double z;

  double yawDeg;

  int sortOrder;

  /// 自由探索の入口名。null は周辺探索の開始点で、公開しない。
  String? label;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [SpawnPointRow]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SpawnPointRow copyWith({
    int? id,
    int? modeConfigId,
    double? x,
    double? y,
    double? z,
    double? yawDeg,
    int? sortOrder,
    String? label,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SpawnPointRow',
      if (id != null) 'id': id,
      'modeConfigId': modeConfigId,
      'x': x,
      'y': y,
      'z': z,
      'yawDeg': yawDeg,
      'sortOrder': sortOrder,
      if (label != null) 'label': label,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static SpawnPointRowInclude include() {
    return SpawnPointRowInclude._();
  }

  static SpawnPointRowIncludeList includeList({
    _is.WhereExpressionBuilder<SpawnPointRowTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SpawnPointRowTable>? orderBy,
    _is.OrderByListBuilder<SpawnPointRowTable>? orderByList,
    SpawnPointRowInclude? include,
  }) {
    return SpawnPointRowIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SpawnPointRow.t),
      orderByList: orderByList?.call(SpawnPointRow.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SpawnPointRowImpl extends SpawnPointRow {
  _SpawnPointRowImpl({
    int? id,
    required int modeConfigId,
    required double x,
    required double y,
    required double z,
    required double yawDeg,
    required int sortOrder,
    String? label,
  }) : super._(
         id: id,
         modeConfigId: modeConfigId,
         x: x,
         y: y,
         z: z,
         yawDeg: yawDeg,
         sortOrder: sortOrder,
         label: label,
       );

  /// Returns a shallow copy of this [SpawnPointRow]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SpawnPointRow copyWith({
    Object? id = _Undefined,
    int? modeConfigId,
    double? x,
    double? y,
    double? z,
    double? yawDeg,
    int? sortOrder,
    Object? label = _Undefined,
  }) {
    return SpawnPointRow(
      id: id is int? ? id : this.id,
      modeConfigId: modeConfigId ?? this.modeConfigId,
      x: x ?? this.x,
      y: y ?? this.y,
      z: z ?? this.z,
      yawDeg: yawDeg ?? this.yawDeg,
      sortOrder: sortOrder ?? this.sortOrder,
      label: label is String? ? label : this.label,
    );
  }
}

class SpawnPointRowUpdateTable extends _is.UpdateTable<SpawnPointRowTable> {
  SpawnPointRowUpdateTable(super.table);

  _is.ColumnValue<int, int> modeConfigId(int value) =>
      _is.ColumnValue(table.modeConfigId, value);

  _is.ColumnValue<double, double> x(double value) =>
      _is.ColumnValue(table.x, value);

  _is.ColumnValue<double, double> y(double value) =>
      _is.ColumnValue(table.y, value);

  _is.ColumnValue<double, double> z(double value) =>
      _is.ColumnValue(table.z, value);

  _is.ColumnValue<double, double> yawDeg(double value) =>
      _is.ColumnValue(table.yawDeg, value);

  _is.ColumnValue<int, int> sortOrder(int value) =>
      _is.ColumnValue(table.sortOrder, value);

  _is.ColumnValue<String, String> label(String? value) =>
      _is.ColumnValue(table.label, value);
}

class SpawnPointRowTable extends _is.Table<int?> {
  SpawnPointRowTable({super.tableRelation}) : super(tableName: 'spawn_point') {
    updateTable = SpawnPointRowUpdateTable(this);
    modeConfigId = _is.ColumnInt(
      'mode_config_id',
      this,
      fieldName: 'modeConfigId',
    );
    x = _is.ColumnDouble('x', this);
    y = _is.ColumnDouble('y', this);
    z = _is.ColumnDouble('z', this);
    yawDeg = _is.ColumnDouble('yaw_deg', this, fieldName: 'yawDeg');
    sortOrder = _is.ColumnInt('sort_order', this, fieldName: 'sortOrder');
    label = _is.ColumnString('label', this);
  }

  late final SpawnPointRowUpdateTable updateTable;

  late final _is.ColumnInt modeConfigId;

  late final _is.ColumnDouble x;

  late final _is.ColumnDouble y;

  late final _is.ColumnDouble z;

  late final _is.ColumnDouble yawDeg;

  late final _is.ColumnInt sortOrder;

  /// 自由探索の入口名。null は周辺探索の開始点で、公開しない。
  late final _is.ColumnString label;

  @override
  List<_is.Column> get columns => [
    id,
    modeConfigId,
    x,
    y,
    z,
    yawDeg,
    sortOrder,
    label,
  ];
}

class SpawnPointRowInclude extends _is.IncludeObject {
  SpawnPointRowInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => SpawnPointRow.t;
}

class SpawnPointRowIncludeList extends _is.IncludeList {
  SpawnPointRowIncludeList._({
    _is.WhereExpressionBuilder<SpawnPointRowTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(SpawnPointRow.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => SpawnPointRow.t;
}

class SpawnPointRowRepository {
  const SpawnPointRowRepository._();

  /// Returns a list of [SpawnPointRow]s matching the given query parameters.
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
  Future<List<SpawnPointRow>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SpawnPointRowTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SpawnPointRowTable>? orderBy,
    _is.OrderByListBuilder<SpawnPointRowTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<SpawnPointRow>(
      where: where?.call(SpawnPointRow.t),
      orderBy: orderBy?.call(SpawnPointRow.t),
      orderByList: orderByList?.call(SpawnPointRow.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [SpawnPointRow]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `SpawnPointRow.t`.
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
  _ida.Stream<List<SpawnPointRow>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SpawnPointRowTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SpawnPointRowTable>? orderBy,
    _is.OrderByListBuilder<SpawnPointRowTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<SpawnPointRow>(
      where: where?.call(SpawnPointRow.t),
      orderBy: orderBy?.call(SpawnPointRow.t),
      orderByList: orderByList?.call(SpawnPointRow.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [SpawnPointRow] matching the given query parameters.
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
  Future<SpawnPointRow?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SpawnPointRowTable>? where,
    int? offset,
    _is.OrderByBuilder<SpawnPointRowTable>? orderBy,
    _is.OrderByListBuilder<SpawnPointRowTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<SpawnPointRow>(
      where: where?.call(SpawnPointRow.t),
      orderBy: orderBy?.call(SpawnPointRow.t),
      orderByList: orderByList?.call(SpawnPointRow.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [SpawnPointRow] by its [id] or null if no such row exists.
  Future<SpawnPointRow?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<SpawnPointRow>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [SpawnPointRow]s in the list and returns the inserted rows.
  ///
  /// The returned [SpawnPointRow]s will have their `id` fields set.
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
  Future<List<SpawnPointRow>> insert(
    _is.DatabaseSession session,
    List<SpawnPointRow> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<SpawnPointRow>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [SpawnPointRow] and returns the inserted row.
  ///
  /// The returned [SpawnPointRow] will have its `id` field set.
  Future<SpawnPointRow> insertRow(
    _is.DatabaseSession session,
    SpawnPointRow row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<SpawnPointRow>(row, transaction: transaction);
  }

  /// Upserts all [SpawnPointRow]s in the list and returns the resulting rows.
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
  /// The returned [SpawnPointRow]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SpawnPointRow>> upsert(
    _is.DatabaseSession session,
    List<SpawnPointRow> rows, {
    required _is.ColumnSelections<SpawnPointRowTable> conflictColumns,
    _is.ColumnSelections<SpawnPointRowTable>? updateColumns,
    _is.WhereExpressionBuilder<SpawnPointRowTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<SpawnPointRow>(
      rows,
      conflictColumns: conflictColumns(SpawnPointRow.t),
      updateColumns: updateColumns?.call(SpawnPointRow.t),
      updateWhere: updateWhere?.call(SpawnPointRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [SpawnPointRow] and returns the resulting row.
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
  /// The returned [SpawnPointRow] will have its `id` field set.
  Future<SpawnPointRow?> upsertRow(
    _is.DatabaseSession session,
    SpawnPointRow row, {
    required _is.ColumnSelections<SpawnPointRowTable> conflictColumns,
    _is.ColumnSelections<SpawnPointRowTable>? updateColumns,
    _is.WhereExpressionBuilder<SpawnPointRowTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<SpawnPointRow>(
      row,
      conflictColumns: conflictColumns(SpawnPointRow.t),
      updateColumns: updateColumns?.call(SpawnPointRow.t),
      updateWhere: updateWhere?.call(SpawnPointRow.t),
      transaction: transaction,
    );
  }

  /// Updates all [SpawnPointRow]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SpawnPointRow>> update(
    _is.DatabaseSession session,
    List<SpawnPointRow> rows, {
    _is.ColumnSelections<SpawnPointRowTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<SpawnPointRow>(
      rows,
      columns: columns?.call(SpawnPointRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [SpawnPointRow]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<SpawnPointRow> updateRow(
    _is.DatabaseSession session,
    SpawnPointRow row, {
    _is.ColumnSelections<SpawnPointRowTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<SpawnPointRow>(
      row,
      columns: columns?.call(SpawnPointRow.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SpawnPointRow] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<SpawnPointRow?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<SpawnPointRowUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<SpawnPointRow>(
      id,
      columnValues: columnValues(SpawnPointRow.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [SpawnPointRow]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SpawnPointRow>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<SpawnPointRowUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<SpawnPointRowTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SpawnPointRowTable>? orderBy,
    _is.OrderByListBuilder<SpawnPointRowTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<SpawnPointRow>(
      columnValues: columnValues(SpawnPointRow.t.updateTable),
      where: where(SpawnPointRow.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SpawnPointRow.t),
      orderByList: orderByList?.call(SpawnPointRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [SpawnPointRow]s in the list and returns the deleted rows.
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
  Future<List<SpawnPointRow>> delete(
    _is.DatabaseSession session,
    List<SpawnPointRow> rows, {
    _is.OrderByBuilder<SpawnPointRowTable>? orderBy,
    _is.OrderByListBuilder<SpawnPointRowTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<SpawnPointRow>(
      rows,
      orderBy: orderBy?.call(SpawnPointRow.t),
      orderByList: orderByList?.call(SpawnPointRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [SpawnPointRow].
  Future<SpawnPointRow> deleteRow(
    _is.DatabaseSession session,
    SpawnPointRow row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<SpawnPointRow>(row, transaction: transaction);
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SpawnPointRow>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SpawnPointRowTable> where,
    _is.OrderByBuilder<SpawnPointRowTable>? orderBy,
    _is.OrderByListBuilder<SpawnPointRowTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<SpawnPointRow>(
      where: where(SpawnPointRow.t),
      orderBy: orderBy?.call(SpawnPointRow.t),
      orderByList: orderByList?.call(SpawnPointRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SpawnPointRowTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<SpawnPointRow>(
      where: where?.call(SpawnPointRow.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [SpawnPointRow] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SpawnPointRowTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<SpawnPointRow>(
      where: where(SpawnPointRow.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
