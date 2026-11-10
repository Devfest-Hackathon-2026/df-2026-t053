import 'package:freezed_annotation/freezed_annotation.dart';

part 'model.freezed.dart';

enum AssetFailureKind {
  invalidReference,
  integrity,
  unavailable,
  storage,
  cancelled,
}

/// 表示文言は接続先のViewModelで決める。URL・内部パスを失敗データに含めない。
@freezed
abstract class AssetFailure with _$AssetFailure implements Exception {
  const factory AssetFailure(AssetFailureKind kind) = _AssetFailure;
}

@freezed
abstract class AssetProgress with _$AssetProgress {
  const factory AssetProgress({required int received, required int total}) =
      _AssetProgress;
}

@freezed
abstract class AssetCacheSettings with _$AssetCacheSettings {
  const factory AssetCacheSettings({
    required Uri baseUrl,
    @Default(100 * 1024 * 1024) int capacityBytes,
    @Default(Duration(seconds: 10)) Duration connectTimeout,
    @Default(Duration(seconds: 15)) Duration idleTimeout,
    @Default(Duration(seconds: 120)) Duration totalTimeout,
  }) = _AssetCacheSettings;
}
