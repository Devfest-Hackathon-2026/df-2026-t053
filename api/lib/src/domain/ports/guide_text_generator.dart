import 'guide_cancellation.dart';

/// 構造物がある方向（利用者の向きからの相対）。方向が決まらなければ [none]。
enum GuideDirection() {
  front,
  left,
  right,

  /// 背後。近くに候補がなく、最寄りの構造物を選んだときだけ使う。
  behind,
  none,
}

/// 構造物までの距離の帯。正確な位置を生成側へ渡さないために帯で伝える。
enum GuideDistanceBand() {
  /// 5 m 未満。
  veryNear,

  /// 5 m 以上 15 m 未満。
  near,

  /// 15 m 以上 30 m 以下（近くの候補の上限）。
  far,

  /// 30 m を超え 100 m 未満。近くに候補がなく、最寄りを選んだとき。
  distant,

  /// 100 m 以上。近くに候補がなく、最寄りを選んだとき。
  remote;

  static GuideDistanceBand fromMeters(double meters) => meters < 5
      ? veryNear
      : meters < 15
      ? near
      : meters <= 30
      ? far
      : meters < 100
      ? distant
      : remote;
}

/// 説明文の対象 1 件。選定済みの構造物の、名称・確認済みの事実・方向・距離帯だけを持つ。
class const GuideSubject({
  required final String name,
  required final String facts,
  required final GuideDirection direction,
  required final GuideDistanceBand distanceBand,
});

/// 文生成の入力。
///
/// 写真・正解のカメラ・点数・撮影後の固定解説（story・highlight）・正確な位置は、型として
/// 持たない（docs/specs.md「構造物の選定」）。生成側へ渡せるのは、ここにある値だけ。
class const GuideTextInput({
  required final List<GuideSubject> subjects,

  /// 提出版は `ja-JP` だけ。
  required final String locale,
});

/// 生成した本文。
class const GeneratedGuideText({
  required final String text,

  /// 生成に使ったモデル（ログ・記録用）。
  required final String model,
});

/// 文生成の失敗の分類。どれも、呼び出し側は固定文へ切り替える。
enum GuideTextFailure() {
  /// 本文が空。
  empty,

  /// 安全性などの理由で、生成を拒否された。
  refused,

  /// 応答の形が想定と違う。
  invalidFormat,

  /// 時間内に終わらなかった。
  timeout,

  /// 通信・認証・上限など、そのほかの失敗。
  unavailable,
}

class const GuideTextException(
  final GuideTextFailure reason, {
  final String? detail,
}) implements Exception {
  @override
  String toString() => 'GuideTextException($reason)';
}

/// 選定済み資料だけから、日本語の説明文を作る。
abstract interface class GuideTextGenerator() {
  /// 失敗したら [GuideTextException]、取り消されたら [GuideCancelledException]。
  Future<GeneratedGuideText> generate(
    GuideTextInput input, {
    required Duration timeout,
    GuideCancellation? cancellation,
  });
}
