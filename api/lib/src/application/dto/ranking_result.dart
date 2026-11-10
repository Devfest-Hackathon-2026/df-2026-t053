/// 公開レスポンスへ変換するための結果。内部IDは含めない。
class const RankingResult({
  required final int rank,
  required final String nickname,
  required final int score,
  required final DateTime achieveTime,
  required final bool mine,
});
