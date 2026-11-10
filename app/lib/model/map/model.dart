import 'dart:ui';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:photohunt_shared/photohunt_shared.dart';

import 'package:app/utils/color.dart';

part 'model.freezed.dart';

/// 会場マップ上に描画するピン情報。
@freezed
abstract class MapPinData with _$MapPinData {
  const MapPinData._();

  const factory MapPinData({
    required int id,
    required String name,
    String? sourceKey,
    double? latitude,
    double? longitude,
  }) = _MapPinData;

  /// shared の latLonToMapUv を用いて算出した正規化UV座標（u: 0..1, v: 0..1）
  ({double u, double v})? get uv {
    final lat = latitude;
    final lon = longitude;
    if (lat == null || lon == null) return null;
    return latLonToMapUv(lat, lon);
  }

  /// sourceKey のプレフィックスに応じたゾーン色。
  /// sourceKey がない landmark ピンはデフォルトの expoBlue とする。
  Color get color => _colorOf(sourceKey);
}

Color _colorOf(String? sourceKey) {
  if (sourceKey == null) return AppColor.expoBlue;
  if (sourceKey.startsWith('JpPr')) return AppColor.japanPr;
  if (sourceKey.startsWith('emp')) return AppColor.empoweringZone;
  if (sourceKey.startsWith('sig')) return AppColor.signatureZone;
  if (sourceKey.startsWith('sv')) return AppColor.savingZone;
  if (sourceKey.startsWith('co')) return AppColor.connectingZone;
  if (sourceKey == 'uk-pavilion') return AppColor.ukPavilion;
  if (sourceKey.startsWith('sample')) return AppColor.samplePavilion;
  return AppColor.expoBlue;
}
