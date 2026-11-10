/// 新規のプレイ開始の頻度を制限する（アカウントごと）。
///
/// メモリ上の補助的な制限で、再起動で消えてよい（docs/specs.md「認証と開始要求の制限」）。
/// 数えるのは、実際にセッションを作った開始だけ。版の確認などで失敗した開始は数えない。
abstract interface class StartRateLimiter() {
  /// 上限に達していれば、再試行までの秒数を返す。達していなければ null。回数は使わない。
  int? retryAfter(int userProfileId);

  /// 新規の開始を 1 回分として記録する。セッションを保存できたときだけ呼ぶ。
  void record(int userProfileId);
}
