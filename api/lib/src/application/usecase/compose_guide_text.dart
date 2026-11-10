import 'dart:async';

import '../../domain/ports/guide_cancellation.dart';
import '../../domain/ports/guide_text_generator.dart';
import '../dto/guide_text_result.dart';

/// 本文の上限（文字数）。目標は 150〜250 字程度（docs/specs.md「モデル・本文・音声の検証」）。
const int kGuideTextMaxChars = 400;

/// 文生成の待ち上限。
const Duration kGuideTextTimeout = Duration(seconds: 15);

/// 選定済みの構造物から本文を確定する。
///
/// 生成に失敗したら（空・拒否・形式不正・400 字超・タイムアウト・通信の失敗）、先頭の
/// 構造物の固定の代替文に切り替え、`aiGenerated=false` にする。取消は失敗ではないので、
/// 切り替えずに [GuideCancelledException] をそのまま返す。
///
/// 出典はモデルに作らせず、登録資料から付ける。文字数を確かめても事実性は保証されない
/// ので、公開前に複数の生成結果を資料と照合する（手作業）。
class ComposeGuideText(final GuideTextGenerator _generator) {
  Future<GuideTextResult> execute(
    List<GuideMaterial> materials, {
    String locale = 'ja-JP',
    Duration timeout = kGuideTextTimeout,
    GuideCancellation? cancellation,
  }) async {
    if (materials.isEmpty) {
      throw ArgumentError.value(materials, 'materials', '選定済みの構造物が要る');
    }
    final input = GuideTextInput(
      locale: locale,
      subjects: [
        for (final m in materials)
          GuideSubject(
            name: m.name,
            facts: m.facts,
            direction: m.direction,
            distanceBand: GuideDistanceBand.fromMeters(m.distanceMeters),
          ),
      ],
    );

    GuideTextFailure? failure;
    try {
      final generated = await _generator
          .generate(input, timeout: timeout, cancellation: cancellation)
          // 実装が待ち上限を守らなくても、ここで打ち切る（少し余裕を持たせる）。
          .timeout(
            timeout + const Duration(seconds: 1),
            onTimeout: () =>
                throw const GuideTextException(GuideTextFailure.timeout),
          );
      final text = generated.text.trim();
      if (text.isEmpty) {
        failure = GuideTextFailure.empty;
      } else if (text.runes.length > kGuideTextMaxChars) {
        failure = GuideTextFailure.invalidFormat;
      } else {
        return GuideTextResult(
          text: text,
          aiGenerated: true,
          structureIds: [for (final m in materials) m.structureId],
          sources: [for (final m in materials) ...m.sources],
        );
      }
    } on GuideTextException catch (error) {
      failure = error.reason;
    }
    // 取消（GuideCancelledException）はここまで来ない（上で捕まえずに投げ直される）。
    if (cancellation?.isCancelled ?? false) {
      throw const GuideCancelledException();
    }

    final first = materials.first;
    return GuideTextResult(
      text: first.fallbackText,
      aiGenerated: false,
      structureIds: [first.structureId],
      sources: first.sources,
      fallbackReason: failure,
    );
  }
}
