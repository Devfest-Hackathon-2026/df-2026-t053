/// 「直前までの commit が GCS に複製された」ことを確認する。
/// 失敗・タイムアウト・不正な応答は `ReplicationUnavailableException`。
abstract interface class ReplicationConfirmer() {
  Future<void> confirm({required Duration timeout});
}

/// 複製確認に使う待ち時間: `min(8 秒, RPC 全体の残り時間)`。
Duration syncTimeout(Duration remaining) {
  const max = Duration(seconds: 8);
  if (remaining <= Duration.zero) return Duration.zero;
  return remaining < max ? remaining : max;
}
