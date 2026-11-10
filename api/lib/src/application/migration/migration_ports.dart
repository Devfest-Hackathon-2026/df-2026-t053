/// migration Job（`bin/migrate.dart`）が使う外部の境界（docs/specs.md「DBマイグレーション」）。
///
/// 実装は infrastructure（GCS の writer 所有権、Litestream、子プロセスの Serverpod、SQLite）。
library;

/// writer 所有権を取得・解放できなかった（別の writer が持つ、GCS の失敗、generation の不一致）。
class const WriterLockUnavailable(final String message) implements Exception {
  @override
  String toString() => 'WriterLockUnavailable($message)';
}

/// API・seed と共通の writer 所有権。取れなければ DB に何もしない。
abstract interface class WriterLock() {
  Future<HeldWriterLock> acquire();
}

/// 取得済みの所有権。解放は、Litestream の停止と複製の確認を終えてからだけ行う。
abstract interface class HeldWriterLock() {
  /// ログに出す識別（ownerId と generation）。
  String get description;

  Future<void> release();
}

/// レプリカを復元できなかった（認証・権限・通信・破損）。空の DB で続けない。
class const ReplicaRestoreFailed(final String message) implements Exception {
  @override
  String toString() => 'ReplicaRestoreFailed($message)';
}

/// migration の適用に失敗した。作業中のローカル DB は複製しない。
class const MigrationApplyFailed(final String message) implements Exception {
  @override
  String toString() => 'MigrationApplyFailed($message)';
}

/// Litestream の起動・GCS への複製の確認ができなかった。
class const ReplicationFailed(final String message) implements Exception {
  @override
  String toString() => 'ReplicationFailed($message)';
}

/// 復元の結果。
enum RestoreResult() {
  /// レプリカから作業用の DB を作った。
  restored,

  /// レプリカがまだない（初回）。
  noReplica,
}

/// 作業用の DB の状態。
sealed class SchemaState();

/// image が期待する版と一致している。
class const SchemaReady(final Map<String, String> applied)
    implements SchemaState;

/// 必要な版が未適用。
class const SchemaNeedsMigration({
  required final Map<String, String> applied,
  required final Map<String, String> expected,
}) implements SchemaState;

/// DB の版が image より新しい、または未知のモジュールがある。
class const SchemaTooNew({
  required final Map<String, String> applied,
  required final Map<String, String> expected,
}) implements SchemaState;

/// DB が使えない（整合性・外部キーの違反、版の表がない）。
class const SchemaCorrupt(final String reason) implements SchemaState;

/// 作業用のローカル DB と、その上の操作。
abstract interface class MigrationWorkspace() {
  /// 作業用の DB とその付随ファイル（WAL、Litestream の位置情報）を消す。
  Future<void> clear();

  /// レプリカを作業用の DB へ復元する。失敗は [ReplicaRestoreFailed]。
  Future<RestoreResult> restore();

  /// 作業用の DB を照合する（整合性・外部キー・適用版）。
  Future<SchemaState> inspect();

  /// 同じ image の Serverpod（保守 role）で migration を適用する。失敗は [MigrationApplyFailed]。
  /// DB がなければ作る。
  Future<void> applyMigrations();

  /// Litestream を起動する。準備できなければ [ReplicationFailed]。
  Future<ReplicationRun> startReplication();
}

/// 起動中の Litestream。
abstract interface class ReplicationRun() {
  /// 作業用の DB の変更が GCS まで複製されたことを確かめる。失敗は [ReplicationFailed]。
  Future<void> confirm();

  /// 停止を待つ。猶予内に止まらなければ false（アップロードが残っている可能性がある）。
  Future<bool> stop();
}
