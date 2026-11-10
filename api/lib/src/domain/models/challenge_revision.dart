// サーバー内部のドメインモデルと同名の公開 DTO は使わないので隠す。
import 'package:photohunt_shared/photohunt_shared.dart'
    hide
        Challenge,
        ChallengeRevision,
        Credit,
        Landmark,
        ModeConfig,
        PlaySession,
        Shot;

import 'asset.dart';
import 'credit.dart';
import 'landmark.dart';
import 'mode_config.dart';

/// 撮影の正解姿勢。公開 DTO には載せない。
class const GoalPose({
  required final double x,
  required final double y,
  required final double z,
  required final double yawDeg,
  required final double pitchDeg,
});

/// 撮影後にだけ見せる内容。正解姿勢・story・highlight。
class const RevisionSecrets({
  required final GoalPose goal,
  required final String story,
  required final String highlight,
});

/// 出題の版（内部モデル）。
///
/// [secrets] は `findRevisionWithSecrets` で読んだときだけ入り、`findRevision`
/// では null。公開 DTO へ変換する層は [secrets] を参照しない。
/// [modes]・[landmarks]・[credits] は変更できないコピーで持つ（渡した元のリストを
/// 変えても影響しない）。
class ChallengeRevision({
  required final int id,
  required final int challengeId,
  required final int revisionNo,
  required final String sceneProfile,
  required final String scoringVersion,
  required final Asset photo,
  required final Asset map,
  required final String photoAlt,
  required final MapBounds mapBounds,
  required final double eyeHeightM,
  required final double shotFovDeg,
  required final DateTime? publishedAt,
  required final DateTime createdAt,
  required List<ModeConfig> modes,
  required List<Landmark> landmarks,
  required List<Credit> credits,
  required final RevisionSecrets? secrets,
}) {
  final List<ModeConfig> modes = List.unmodifiable(modes);
  final List<Landmark> landmarks = List.unmodifiable(landmarks);
  final List<Credit> credits = List.unmodifiable(credits);
}
