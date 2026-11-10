import '../../domain/models/models.dart';

/// プレイの開始・取得の結果。公開 DTO へ変換する前の、ユースケースの出力。
///
/// 撮影済み（[completed]）なら [shot] と [reveal] の両方が入り、未撮影なら両方とも null。
class PlayResult {
  /// 未撮影のプレイ。
  const new active({required this.session, required this.spawn})
    : shot = null,
      reveal = null;

  /// 撮影済みのプレイ。撮影結果と、撮影後に明かす正解・解説を持つ。
  const new completed({
    required this.session,
    required this.spawn,
    required Shot this.shot,
    required PlayReveal this.reveal,
  });

  final PlaySession session;

  /// 保存した開始点（足元の位置と向き）。
  final SpawnPoint spawn;

  final Shot? shot;
  final PlayReveal? reveal;

  bool get completed => shot != null;
}

/// 撮影後に明かす正解と解説。撮影済みのときだけ、ユースケースが版から読む。
class const PlayReveal({
  required final GoalPose goal,
  required final String story,
  required final String highlight,

  /// 版で固定した撮影の画角（正解のカメラの画角）。
  required final double verticalFovDeg,
});
