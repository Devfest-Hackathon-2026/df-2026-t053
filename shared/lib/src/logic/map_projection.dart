import 'dart:math' as math;

import '../generated/map_bounds.dart';

/// モデルローカルの (x, z) を会場図画像内の正規化位置へ変換する。
///
/// 画像の原点は左上で、u が右（＋X）、v が下（＋Z）。
/// 範囲外の値を端に吸着させず、0〜1 の外もそのまま返す。
({double u, double v}) toMapUv(MapBounds bounds, double x, double z) {
  return (
    u: (x - bounds.minX) / (bounds.maxX - bounds.minX),
    v: (z - bounds.minZ) / (bounds.maxZ - bounds.minZ),
  );
}

/// 国土地理院タイル基準の夢洲地図画像の幾何パラメータ
const double kYumeshimaNwLat = 34.656621;
const double kYumeshimaNwLon = 135.372784;
const double kYumeshimaSeLat = 34.6459241;
const double kYumeshimaSeLon = 135.3889618;
const int kYumeshimaZoom = 18;
const double kYumeshimaImageWidth = 3139.0;
const double kYumeshimaImageHeight = 2472.0;

/// タイル結合画像（3328×2560）から会場図画像（3139×2472）を切り出した際の左上オフセット（px）
const double kYumeshimaCropOffsetX = 188.0;
const double kYumeshimaCropOffsetY = 78.0;

/// 3D空間の大屋根リング中心（m）と会場図画像上の大屋根リング中心（px）・スケール（px/m）
const double kYumeshimaRingCenterWorldX = -4.2;
const double kYumeshimaRingCenterWorldZ = 0.2;
const double kYumeshimaRingCenterPxX = 1928.0;
const double kYumeshimaRingCenterPxY = 1716.0;
const double kYumeshimaPxPerMeter = 2.0346;

/// 緯度経度（WGS84）を国土地理院タイル基準の会場図画像内の正規化位置（u, v）へ変換する。
///
/// 画像の原点は左上で、u が右（東方向）、v が下（南方向）。
/// 0.0〜1.0 の範囲外もそのまま返す。
({double u, double v}) latLonToMapUv(
  double lat,
  double lon, {
  double nwLat = kYumeshimaNwLat,
  double nwLon = kYumeshimaNwLon,
  int zoom = kYumeshimaZoom,
  double imageWidth = kYumeshimaImageWidth,
  double imageHeight = kYumeshimaImageHeight,
  double cropOffsetX = kYumeshimaCropOffsetX,
  double cropOffsetY = kYumeshimaCropOffsetY,
}) {
  final n = math.pow(2.0, zoom).toDouble();

  // 左上タイルの原点インデックス
  final nwLonTile = ((nwLon + 180.0) / 360.0 * n).floorToDouble();
  final nwLatRad = nwLat * math.pi / 180.0;
  final nwAsinhTan = math.log(math.tan(nwLatRad) + 1.0 / math.cos(nwLatRad));
  final nwLatTile = ((1.0 - nwAsinhTan / math.pi) / 2.0 * n).floorToDouble();

  // 対象座標のグローバルピクセル座標
  final gx = (lon + 180.0) / 360.0 * (256.0 * n);
  final latRad = lat * math.pi / 180.0;
  final asinhTan = math.log(math.tan(latRad) + 1.0 / math.cos(latRad));
  final gy = (1.0 - asinhTan / math.pi) / 2.0 * (256.0 * n);

  final px = gx - nwLonTile * 256.0 - cropOffsetX;
  final py = gy - nwLatTile * 256.0 - cropOffsetY;

  return (u: px / imageWidth, v: py / imageHeight);
}

/// 3D空間のワールド座標 (x, z) を夢洲会場図画像内の正規化位置 (u, v) へ変換する。
///
/// 3D空間は +X が東、+Z が北。画像の原点は左上で、u が右（東）、v が下（南）。
({double u, double v}) worldXzToMapUv(
  double x,
  double z, {
  double imageWidth = kYumeshimaImageWidth,
  double imageHeight = kYumeshimaImageHeight,
}) {
  final px =
      kYumeshimaRingCenterPxX +
      (x - kYumeshimaRingCenterWorldX) * kYumeshimaPxPerMeter;
  final py =
      kYumeshimaRingCenterPxY -
      (z - kYumeshimaRingCenterWorldZ) * kYumeshimaPxPerMeter;
  return (u: px / imageWidth, v: py / imageHeight);
}
