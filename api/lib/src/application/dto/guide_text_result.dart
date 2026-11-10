import '../../domain/models/models.dart';
import '../../domain/ports/guide_text_generator.dart';

/// 説明文の材料 1 件。選定済みの構造物（PR #76 の `SelectedStructure`）から #32 が作る。
///
/// 固定の代替文と出典は、生成側（Gemini）へは渡さない。代替文は失敗時の切り替えに、
/// 出典は応答に付けるのに使う。
class const GuideMaterial({
  required final int structureId,
  required final String name,
  required final String facts,
  required final String fallbackText,

  /// 登録済みの出典（sortOrder の昇順）。
  required final List<StructureSource> sources,
  required final GuideDirection direction,
  required final double distanceMeters,
});

/// 確定した本文。#32 が `GuideText` として最初に返し、同じ本文を音声生成へ渡す。
class const GuideTextResult({
  required final String text,

  /// 生成した本文なら true、固定の代替文に切り替えたなら false。
  required final bool aiGenerated,

  /// 本文が扱う構造物（応答の対象名・ログ用）。
  required final List<int> structureIds,

  /// 登録資料から付けた出典（モデルに作らせない）。
  required final List<StructureSource> sources,

  /// 固定文に切り替えた理由。生成した本文なら null（ログの分類用）。
  final GuideTextFailure? fallbackReason,
});
