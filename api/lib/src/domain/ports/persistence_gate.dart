/// 複製が確認できず、成功を返せない。呼び出し側は `TEMPORARILY_UNAVAILABLE` に対応付ける。
class const ReplicationUnavailableException(final String reason)
    implements Exception {
  @override
  String toString() => 'ReplicationUnavailableException($reason)';
}

/// 業務・認証の DB 処理を直列にし、「SQLite 更新 → GCS 複製確認」を 1 区間にする共通ゲート。
///
/// - 上流 API（Gemini など）の待ちの間は保持しない。stream 全体を囲まない。
/// - 書き込みの成功は、GCS への複製を確認した後にだけ返す。
abstract interface class PersistenceGate() {
  /// 書き込み。[fn] の commit 後に GCS への複製完了を確認してから値を返す。
  ///
  /// [deadline] は RPC 全体の残り時間。複製確認の待ちはこれを超えない。
  /// [immediate] が true のとき、書き込み権を最初に取る（`BEGIN IMMEDIATE` 相当）。
  Future<T> runWrite<T>(
    Future<T> Function() fn, {
    required Duration deadline,
    bool immediate = false,
  });

  /// 読み取り。前の要求の未複製データを応答に含めないため、ゲートを通す。
  Future<T> runRead<T>(Future<T> Function() fn);
}
