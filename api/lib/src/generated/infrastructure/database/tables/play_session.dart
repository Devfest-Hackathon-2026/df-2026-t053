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

/// 1 回のプレイ。id はサーバーが生成する UUID（認証の代わりにはならない）。
abstract class PlaySessionRow
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  PlaySessionRow._({
    this.id,
    required this.requestId,
    required this.revisionId,
    required this.mode,
    required this.spawnPointId,
    required this.userProfileId,
    required this.startedAt,
    required this.expiresAt,
  });

  factory PlaySessionRow({
    _is.UuidValue? id,
    required _is.UuidValue requestId,
    required int revisionId,
    required _ix5zeh3i.PlayMode mode,
    required int spawnPointId,
    required int userProfileId,
    required DateTime startedAt,
    required DateTime expiresAt,
  }) = _PlaySessionRowImpl;

  factory PlaySessionRow.fromJson(Map<String, dynamic> jsonSerialization) {
    return PlaySessionRow(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      requestId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['requestId'],
      ),
      revisionId: jsonSerialization['revisionId'] as int,
      mode: _ix5zeh3i.PlayMode.fromJson((jsonSerialization['mode'] as String)),
      spawnPointId: jsonSerialization['spawnPointId'] as int,
      userProfileId: jsonSerialization['userProfileId'] as int,
      startedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['startedAt'],
      ),
      expiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
    );
  }

  static final t = PlaySessionRowTable();

  static const db = PlaySessionRowRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue requestId;

  int revisionId;

  _ix5zeh3i.PlayMode mode;

  int spawnPointId;

  int userProfileId;

  DateTime startedAt;

  DateTime expiresAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [PlaySessionRow]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  PlaySessionRow copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? requestId,
    int? revisionId,
    _ix5zeh3i.PlayMode? mode,
    int? spawnPointId,
    int? userProfileId,
    DateTime? startedAt,
    DateTime? expiresAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PlaySessionRow',
      if (id != null) 'id': id?.toJson(),
      'requestId': requestId.toJson(),
      'revisionId': revisionId,
      'mode': mode.toJson(),
      'spawnPointId': spawnPointId,
      'userProfileId': userProfileId,
      'startedAt': startedAt.toJson(),
      'expiresAt': expiresAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static PlaySessionRowInclude include() {
    return PlaySessionRowInclude._();
  }

  static PlaySessionRowIncludeList includeList({
    _is.WhereExpressionBuilder<PlaySessionRowTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PlaySessionRowTable>? orderBy,
    _is.OrderByListBuilder<PlaySessionRowTable>? orderByList,
    PlaySessionRowInclude? include,
  }) {
    return PlaySessionRowIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PlaySessionRow.t),
      orderByList: orderByList?.call(PlaySessionRow.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _PlaySessionRowImpl extends PlaySessionRow {
  _PlaySessionRowImpl({
    _is.UuidValue? id,
    required _is.UuidValue requestId,
    required int revisionId,
    required _ix5zeh3i.PlayMode mode,
    required int spawnPointId,
    required int userProfileId,
    required DateTime startedAt,
    required DateTime expiresAt,
  }) : super._(
         id: id,
         requestId: requestId,
         revisionId: revisionId,
         mode: mode,
         spawnPointId: spawnPointId,
         userProfileId: userProfileId,
         startedAt: startedAt,
         expiresAt: expiresAt,
       );

  /// Returns a shallow copy of this [PlaySessionRow]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  PlaySessionRow copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? requestId,
    int? revisionId,
    _ix5zeh3i.PlayMode? mode,
    int? spawnPointId,
    int? userProfileId,
    DateTime? startedAt,
    DateTime? expiresAt,
  }) {
    return PlaySessionRow(
      id: id is _is.UndefinedSentinel ? this.id : id,
      requestId: requestId ?? this.requestId,
      revisionId: revisionId ?? this.revisionId,
      mode: mode ?? this.mode,
      spawnPointId: spawnPointId ?? this.spawnPointId,
      userProfileId: userProfileId ?? this.userProfileId,
      startedAt: startedAt ?? this.startedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

class PlaySessionRowUpdateTable extends _is.UpdateTable<PlaySessionRowTable> {
  PlaySessionRowUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> requestId(
    _is.UuidValue value,
  ) => _is.ColumnValue(table.requestId, value);

  _is.ColumnValue<int, int> revisionId(int value) =>
      _is.ColumnValue(table.revisionId, value);

  _is.ColumnValue<_ix5zeh3i.PlayMode, _ix5zeh3i.PlayMode> mode(
    _ix5zeh3i.PlayMode value,
  ) => _is.ColumnValue(table.mode, value);

  _is.ColumnValue<int, int> spawnPointId(int value) =>
      _is.ColumnValue(table.spawnPointId, value);

  _is.ColumnValue<int, int> userProfileId(int value) =>
      _is.ColumnValue(table.userProfileId, value);

  _is.ColumnValue<DateTime, DateTime> startedAt(DateTime value) =>
      _is.ColumnValue(table.startedAt, value);

  _is.ColumnValue<DateTime, DateTime> expiresAt(DateTime value) =>
      _is.ColumnValue(table.expiresAt, value);
}

class PlaySessionRowTable extends _is.Table<_is.UuidValue?> {
  PlaySessionRowTable({super.tableRelation})
    : super(tableName: 'play_session') {
    updateTable = PlaySessionRowUpdateTable(this);
    requestId = _is.ColumnUuid('request_id', this, fieldName: 'requestId');
    revisionId = _is.ColumnInt('revision_id', this, fieldName: 'revisionId');
    mode = _is.ColumnEnum('mode', this, _is.EnumSerialization.byName);
    spawnPointId = _is.ColumnInt(
      'spawn_point_id',
      this,
      fieldName: 'spawnPointId',
    );
    userProfileId = _is.ColumnInt(
      'user_profile_id',
      this,
      fieldName: 'userProfileId',
    );
    startedAt = _is.ColumnDateTime('started_at', this, fieldName: 'startedAt');
    expiresAt = _is.ColumnDateTime('expires_at', this, fieldName: 'expiresAt');
  }

  late final PlaySessionRowUpdateTable updateTable;

  late final _is.ColumnUuid requestId;

  late final _is.ColumnInt revisionId;

  late final _is.ColumnEnum<_ix5zeh3i.PlayMode> mode;

  late final _is.ColumnInt spawnPointId;

  late final _is.ColumnInt userProfileId;

  late final _is.ColumnDateTime startedAt;

  late final _is.ColumnDateTime expiresAt;

  @override
  List<_is.Column> get columns => [
    id,
    requestId,
    revisionId,
    mode,
    spawnPointId,
    userProfileId,
    startedAt,
    expiresAt,
  ];
}

class PlaySessionRowInclude extends _is.IncludeObject {
  PlaySessionRowInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => PlaySessionRow.t;
}

class PlaySessionRowIncludeList extends _is.IncludeList {
  PlaySessionRowIncludeList._({
    _is.WhereExpressionBuilder<PlaySessionRowTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PlaySessionRow.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => PlaySessionRow.t;
}

class PlaySessionRowRepository {
  const PlaySessionRowRepository._();

  /// Returns a list of [PlaySessionRow]s matching the given query parameters.
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
  Future<List<PlaySessionRow>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PlaySessionRowTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PlaySessionRowTable>? orderBy,
    _is.OrderByListBuilder<PlaySessionRowTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PlaySessionRow>(
      where: where?.call(PlaySessionRow.t),
      orderBy: orderBy?.call(PlaySessionRow.t),
      orderByList: orderByList?.call(PlaySessionRow.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [PlaySessionRow]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `PlaySessionRow.t`.
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
  _ida.Stream<List<PlaySessionRow>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PlaySessionRowTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PlaySessionRowTable>? orderBy,
    _is.OrderByListBuilder<PlaySessionRowTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<PlaySessionRow>(
      where: where?.call(PlaySessionRow.t),
      orderBy: orderBy?.call(PlaySessionRow.t),
      orderByList: orderByList?.call(PlaySessionRow.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [PlaySessionRow] matching the given query parameters.
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
  Future<PlaySessionRow?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PlaySessionRowTable>? where,
    int? offset,
    _is.OrderByBuilder<PlaySessionRowTable>? orderBy,
    _is.OrderByListBuilder<PlaySessionRowTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PlaySessionRow>(
      where: where?.call(PlaySessionRow.t),
      orderBy: orderBy?.call(PlaySessionRow.t),
      orderByList: orderByList?.call(PlaySessionRow.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PlaySessionRow] by its [id] or null if no such row exists.
  Future<PlaySessionRow?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PlaySessionRow>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PlaySessionRow]s in the list and returns the inserted rows.
  ///
  /// The returned [PlaySessionRow]s will have their `id` fields set.
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
  Future<List<PlaySessionRow>> insert(
    _is.DatabaseSession session,
    List<PlaySessionRow> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<PlaySessionRow>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [PlaySessionRow] and returns the inserted row.
  ///
  /// The returned [PlaySessionRow] will have its `id` field set.
  Future<PlaySessionRow> insertRow(
    _is.DatabaseSession session,
    PlaySessionRow row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<PlaySessionRow>(row, transaction: transaction);
  }

  /// Upserts all [PlaySessionRow]s in the list and returns the resulting rows.
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
  /// The returned [PlaySessionRow]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PlaySessionRow>> upsert(
    _is.DatabaseSession session,
    List<PlaySessionRow> rows, {
    required _is.ColumnSelections<PlaySessionRowTable> conflictColumns,
    _is.ColumnSelections<PlaySessionRowTable>? updateColumns,
    _is.WhereExpressionBuilder<PlaySessionRowTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<PlaySessionRow>(
      rows,
      conflictColumns: conflictColumns(PlaySessionRow.t),
      updateColumns: updateColumns?.call(PlaySessionRow.t),
      updateWhere: updateWhere?.call(PlaySessionRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [PlaySessionRow] and returns the resulting row.
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
  /// The returned [PlaySessionRow] will have its `id` field set.
  Future<PlaySessionRow?> upsertRow(
    _is.DatabaseSession session,
    PlaySessionRow row, {
    required _is.ColumnSelections<PlaySessionRowTable> conflictColumns,
    _is.ColumnSelections<PlaySessionRowTable>? updateColumns,
    _is.WhereExpressionBuilder<PlaySessionRowTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<PlaySessionRow>(
      row,
      conflictColumns: conflictColumns(PlaySessionRow.t),
      updateColumns: updateColumns?.call(PlaySessionRow.t),
      updateWhere: updateWhere?.call(PlaySessionRow.t),
      transaction: transaction,
    );
  }

  /// Updates all [PlaySessionRow]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PlaySessionRow>> update(
    _is.DatabaseSession session,
    List<PlaySessionRow> rows, {
    _is.ColumnSelections<PlaySessionRowTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<PlaySessionRow>(
      rows,
      columns: columns?.call(PlaySessionRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [PlaySessionRow]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PlaySessionRow> updateRow(
    _is.DatabaseSession session,
    PlaySessionRow row, {
    _is.ColumnSelections<PlaySessionRowTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<PlaySessionRow>(
      row,
      columns: columns?.call(PlaySessionRow.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PlaySessionRow] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PlaySessionRow?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<PlaySessionRowUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<PlaySessionRow>(
      id,
      columnValues: columnValues(PlaySessionRow.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PlaySessionRow]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PlaySessionRow>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<PlaySessionRowUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<PlaySessionRowTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PlaySessionRowTable>? orderBy,
    _is.OrderByListBuilder<PlaySessionRowTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<PlaySessionRow>(
      columnValues: columnValues(PlaySessionRow.t.updateTable),
      where: where(PlaySessionRow.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PlaySessionRow.t),
      orderByList: orderByList?.call(PlaySessionRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [PlaySessionRow]s in the list and returns the deleted rows.
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
  Future<List<PlaySessionRow>> delete(
    _is.DatabaseSession session,
    List<PlaySessionRow> rows, {
    _is.OrderByBuilder<PlaySessionRowTable>? orderBy,
    _is.OrderByListBuilder<PlaySessionRowTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<PlaySessionRow>(
      rows,
      orderBy: orderBy?.call(PlaySessionRow.t),
      orderByList: orderByList?.call(PlaySessionRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [PlaySessionRow].
  Future<PlaySessionRow> deleteRow(
    _is.DatabaseSession session,
    PlaySessionRow row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PlaySessionRow>(row, transaction: transaction);
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PlaySessionRow>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PlaySessionRowTable> where,
    _is.OrderByBuilder<PlaySessionRowTable>? orderBy,
    _is.OrderByListBuilder<PlaySessionRowTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<PlaySessionRow>(
      where: where(PlaySessionRow.t),
      orderBy: orderBy?.call(PlaySessionRow.t),
      orderByList: orderByList?.call(PlaySessionRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PlaySessionRowTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<PlaySessionRow>(
      where: where?.call(PlaySessionRow.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PlaySessionRow] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PlaySessionRowTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PlaySessionRow>(
      where: where(PlaySessionRow.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
