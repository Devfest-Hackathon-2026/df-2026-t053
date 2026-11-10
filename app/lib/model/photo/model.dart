import 'package:app/model/assets/model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'model.freezed.dart';

enum CluePhotoPhase { idle, loading, ready, failed }

/// 手がかり写真の取得状態。パスは表示専用で、失敗データには含めない。
@freezed
abstract class CluePhotoState with _$CluePhotoState {
  const factory CluePhotoState({
    @Default(CluePhotoPhase.idle) CluePhotoPhase phase,
    String? alt,
    String? path,
    int? width,
    int? height,
    @Default(0) double progress,
    AssetFailureKind? failure,
  }) = _CluePhotoState;
}
