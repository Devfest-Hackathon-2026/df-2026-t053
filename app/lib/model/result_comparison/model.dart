import 'dart:ui' as ui;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'model.freezed.dart';

/// 視点ごとの区画を読み込んでから固定した比較画像。寿命はViewModelが管理する。
@freezed
abstract class ResultComparisonImages with _$ResultComparisonImages {
  const factory ResultComparisonImages({
    required ui.Image shot,
    required ui.Image goal,
  }) = _ResultComparisonImages;
}
