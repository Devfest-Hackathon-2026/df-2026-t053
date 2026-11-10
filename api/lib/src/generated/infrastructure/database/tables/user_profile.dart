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

/// 認証ユーザーに 1 対 1 のプロフィール。nickname は重複可。
abstract class UserProfileRow
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  UserProfileRow._({
    this.id,
    required this.authUserId,
    required this.nickname,
    required this.createdAt,
  });

  factory UserProfileRow({
    int? id,
    required _is.UuidValue authUserId,
    required String nickname,
    required DateTime createdAt,
  }) = _UserProfileRowImpl;

  factory UserProfileRow.fromJson(Map<String, dynamic> jsonSerialization) {
    return UserProfileRow(
      id: jsonSerialization['id'] as int?,
      authUserId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      nickname: jsonSerialization['nickname'] as String,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = UserProfileRowTable();

  static const db = UserProfileRowRepository._();

  @override
  int? id;

  _is.UuidValue authUserId;

  String nickname;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [UserProfileRow]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  UserProfileRow copyWith({
    int? id,
    _is.UuidValue? authUserId,
    String? nickname,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UserProfileRow',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      'nickname': nickname,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static UserProfileRowInclude include() {
    return UserProfileRowInclude._();
  }

  static UserProfileRowIncludeList includeList({
    _is.WhereExpressionBuilder<UserProfileRowTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<UserProfileRowTable>? orderBy,
    _is.OrderByListBuilder<UserProfileRowTable>? orderByList,
    UserProfileRowInclude? include,
  }) {
    return UserProfileRowIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(UserProfileRow.t),
      orderByList: orderByList?.call(UserProfileRow.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UserProfileRowImpl extends UserProfileRow {
  _UserProfileRowImpl({
    int? id,
    required _is.UuidValue authUserId,
    required String nickname,
    required DateTime createdAt,
  }) : super._(
         id: id,
         authUserId: authUserId,
         nickname: nickname,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [UserProfileRow]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  UserProfileRow copyWith({
    Object? id = _Undefined,
    _is.UuidValue? authUserId,
    String? nickname,
    DateTime? createdAt,
  }) {
    return UserProfileRow(
      id: id is int? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      nickname: nickname ?? this.nickname,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class UserProfileRowUpdateTable extends _is.UpdateTable<UserProfileRowTable> {
  UserProfileRowUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> authUserId(
    _is.UuidValue value,
  ) => _is.ColumnValue(table.authUserId, value);

  _is.ColumnValue<String, String> nickname(String value) =>
      _is.ColumnValue(table.nickname, value);

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(table.createdAt, value);
}

class UserProfileRowTable extends _is.Table<int?> {
  UserProfileRowTable({super.tableRelation})
    : super(tableName: 'user_profile') {
    updateTable = UserProfileRowUpdateTable(this);
    authUserId = _is.ColumnUuid('auth_user_id', this, fieldName: 'authUserId');
    nickname = _is.ColumnString('nickname', this);
    createdAt = _is.ColumnDateTime('created_at', this, fieldName: 'createdAt');
  }

  late final UserProfileRowUpdateTable updateTable;

  late final _is.ColumnUuid authUserId;

  late final _is.ColumnString nickname;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [id, authUserId, nickname, createdAt];
}

class UserProfileRowInclude extends _is.IncludeObject {
  UserProfileRowInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => UserProfileRow.t;
}

class UserProfileRowIncludeList extends _is.IncludeList {
  UserProfileRowIncludeList._({
    _is.WhereExpressionBuilder<UserProfileRowTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(UserProfileRow.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => UserProfileRow.t;
}

class UserProfileRowRepository {
  const UserProfileRowRepository._();

  /// Returns a list of [UserProfileRow]s matching the given query parameters.
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
  Future<List<UserProfileRow>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<UserProfileRowTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<UserProfileRowTable>? orderBy,
    _is.OrderByListBuilder<UserProfileRowTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<UserProfileRow>(
      where: where?.call(UserProfileRow.t),
      orderBy: orderBy?.call(UserProfileRow.t),
      orderByList: orderByList?.call(UserProfileRow.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [UserProfileRow]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `UserProfileRow.t`.
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
  _ida.Stream<List<UserProfileRow>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<UserProfileRowTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<UserProfileRowTable>? orderBy,
    _is.OrderByListBuilder<UserProfileRowTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<UserProfileRow>(
      where: where?.call(UserProfileRow.t),
      orderBy: orderBy?.call(UserProfileRow.t),
      orderByList: orderByList?.call(UserProfileRow.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [UserProfileRow] matching the given query parameters.
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
  Future<UserProfileRow?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<UserProfileRowTable>? where,
    int? offset,
    _is.OrderByBuilder<UserProfileRowTable>? orderBy,
    _is.OrderByListBuilder<UserProfileRowTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<UserProfileRow>(
      where: where?.call(UserProfileRow.t),
      orderBy: orderBy?.call(UserProfileRow.t),
      orderByList: orderByList?.call(UserProfileRow.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [UserProfileRow] by its [id] or null if no such row exists.
  Future<UserProfileRow?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<UserProfileRow>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [UserProfileRow]s in the list and returns the inserted rows.
  ///
  /// The returned [UserProfileRow]s will have their `id` fields set.
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
  Future<List<UserProfileRow>> insert(
    _is.DatabaseSession session,
    List<UserProfileRow> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<UserProfileRow>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [UserProfileRow] and returns the inserted row.
  ///
  /// The returned [UserProfileRow] will have its `id` field set.
  Future<UserProfileRow> insertRow(
    _is.DatabaseSession session,
    UserProfileRow row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<UserProfileRow>(row, transaction: transaction);
  }

  /// Upserts all [UserProfileRow]s in the list and returns the resulting rows.
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
  /// The returned [UserProfileRow]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<UserProfileRow>> upsert(
    _is.DatabaseSession session,
    List<UserProfileRow> rows, {
    required _is.ColumnSelections<UserProfileRowTable> conflictColumns,
    _is.ColumnSelections<UserProfileRowTable>? updateColumns,
    _is.WhereExpressionBuilder<UserProfileRowTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<UserProfileRow>(
      rows,
      conflictColumns: conflictColumns(UserProfileRow.t),
      updateColumns: updateColumns?.call(UserProfileRow.t),
      updateWhere: updateWhere?.call(UserProfileRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [UserProfileRow] and returns the resulting row.
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
  /// The returned [UserProfileRow] will have its `id` field set.
  Future<UserProfileRow?> upsertRow(
    _is.DatabaseSession session,
    UserProfileRow row, {
    required _is.ColumnSelections<UserProfileRowTable> conflictColumns,
    _is.ColumnSelections<UserProfileRowTable>? updateColumns,
    _is.WhereExpressionBuilder<UserProfileRowTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<UserProfileRow>(
      row,
      conflictColumns: conflictColumns(UserProfileRow.t),
      updateColumns: updateColumns?.call(UserProfileRow.t),
      updateWhere: updateWhere?.call(UserProfileRow.t),
      transaction: transaction,
    );
  }

  /// Updates all [UserProfileRow]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<UserProfileRow>> update(
    _is.DatabaseSession session,
    List<UserProfileRow> rows, {
    _is.ColumnSelections<UserProfileRowTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<UserProfileRow>(
      rows,
      columns: columns?.call(UserProfileRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [UserProfileRow]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<UserProfileRow> updateRow(
    _is.DatabaseSession session,
    UserProfileRow row, {
    _is.ColumnSelections<UserProfileRowTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<UserProfileRow>(
      row,
      columns: columns?.call(UserProfileRow.t),
      transaction: transaction,
    );
  }

  /// Updates a single [UserProfileRow] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<UserProfileRow?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<UserProfileRowUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<UserProfileRow>(
      id,
      columnValues: columnValues(UserProfileRow.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [UserProfileRow]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<UserProfileRow>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<UserProfileRowUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<UserProfileRowTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<UserProfileRowTable>? orderBy,
    _is.OrderByListBuilder<UserProfileRowTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<UserProfileRow>(
      columnValues: columnValues(UserProfileRow.t.updateTable),
      where: where(UserProfileRow.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(UserProfileRow.t),
      orderByList: orderByList?.call(UserProfileRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [UserProfileRow]s in the list and returns the deleted rows.
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
  Future<List<UserProfileRow>> delete(
    _is.DatabaseSession session,
    List<UserProfileRow> rows, {
    _is.OrderByBuilder<UserProfileRowTable>? orderBy,
    _is.OrderByListBuilder<UserProfileRowTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<UserProfileRow>(
      rows,
      orderBy: orderBy?.call(UserProfileRow.t),
      orderByList: orderByList?.call(UserProfileRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [UserProfileRow].
  Future<UserProfileRow> deleteRow(
    _is.DatabaseSession session,
    UserProfileRow row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<UserProfileRow>(row, transaction: transaction);
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<UserProfileRow>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<UserProfileRowTable> where,
    _is.OrderByBuilder<UserProfileRowTable>? orderBy,
    _is.OrderByListBuilder<UserProfileRowTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<UserProfileRow>(
      where: where(UserProfileRow.t),
      orderBy: orderBy?.call(UserProfileRow.t),
      orderByList: orderByList?.call(UserProfileRow.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<UserProfileRowTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<UserProfileRow>(
      where: where?.call(UserProfileRow.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [UserProfileRow] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<UserProfileRowTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<UserProfileRow>(
      where: where(UserProfileRow.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
