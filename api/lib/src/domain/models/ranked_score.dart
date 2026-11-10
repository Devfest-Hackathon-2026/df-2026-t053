/// ランキングの読み取り結果。プロフィールIDは本人判定だけに使い公開しない。
class const RankedScore({
  required final int rank,
  required final int userProfileId,
  required final String nickname,
  required final int score,
  required final DateTime achievedAt,
});
