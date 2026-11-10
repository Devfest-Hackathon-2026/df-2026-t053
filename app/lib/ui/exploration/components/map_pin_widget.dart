import 'dart:math' as math;

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';
import 'package:app/model/map/model.dart';
import 'package:app/utils/color.dart';

/// 地図ピンウィジェット。
///
/// カプセル型ラベル（白背景・テーマ色ボーダー・テーマ色テキスト）と
/// 円形アイコンバッジ（白縁取り・テーマ色背景・白ドット）で構成される。
class MapPinWidget extends StatelessWidget {
  const MapPinWidget({
    super.key,
    required this.pin,
    this.onTap,
    this.scale = 1.0,
  });

  final MapPinData pin;
  final VoidCallback? onTap;

  /// 地図の拡大倍率。親の InteractiveViewer 等で地図が拡大されている場合、
  /// ピンの画面サイズを一定に保つため 1/scale で縮小する。
  final double scale;

  /// 基準のピン全体の配置幅（中心合わせ用）
  static const double _basePinWidth = 64.0;

  /// 基準のピンアイコンの直径
  static const double _baseIconSize = 8.0;

  /// ラベルとピンアイコン間の隙間
  static const double _baseGap = 1.0;

  /// 画面上のピン幅の最小値（極端に小さくならないよう制限）
  static const double _minPinWidth = 28.0;

  /// 画面上のアイコンサイズの最小値
  static const double _minIconSize = 4.0;

  /// 画面上のラベルフォントサイズの最小値
  static const double _minFontSize = 4.0;

  /// [scale] に応じたピン全体の配置幅を返す。
  static double pinWidthFor({double scale = 1.0}) {
    final inverseScale = 1.0 / scale.clamp(0.5, 4.0);
    return math.max(_basePinWidth * inverseScale, _minPinWidth);
  }

  /// [scale] に応じた、ピン上端からアイコン中心までのオフセットを返す。
  static double anchorTopOffsetFor({double scale = 1.0}) {
    final inverseScale = 1.0 / scale.clamp(0.5, 4.0);
    final iconSize = math.max(_baseIconSize * inverseScale, _minIconSize);
    final fontSize = math.max(5.5 * inverseScale, _minFontSize);
    final gap = _baseGap * inverseScale;
    return (fontSize * 1.05 + 2 + gap + iconSize / 2).clamp(8.0, 20.0);
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = pin.color;
    final effectiveScale = scale.clamp(0.5, 4.0);
    final inverseScale = 1.0 / effectiveScale;

    final pinWidth = math.max(_basePinWidth * inverseScale, _minPinWidth);
    final iconSize = math.max(_baseIconSize * inverseScale, _minIconSize);
    final gap = _baseGap * inverseScale;
    final fontSize = math.max(5.5 * inverseScale, _minFontSize);
    final innerDotSize = 2.2 * inverseScale;
    final borderWidth = 0.7 * inverseScale;
    final iconBorderWidth = 1.0 * inverseScale;
    final horizontalPadding = 3.0 * inverseScale;

    return GestureDetector(
      onTap: onTap,
      behavior: .opaque,
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .center,
        children: [
          // 1. カプセル型ラベル（テキストピル）
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: pinWidth,
              minWidth: 16 * inverseScale,
            ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: StadiumBorder(
                  side: BorderSide(
                    color: themeColor,
                    width: borderWidth,
                  ),
                ),
                shadows: [
                  BoxShadow(
                    color: const Color(0x22000000),
                    blurRadius: 1.5 * inverseScale,
                    offset: Offset(0, 0.5 * inverseScale),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: .min,
                children: [
                  Gap(1.0 * inverseScale),
                  Text(
                    pin.name,
                    maxLines: 1,
                    overflow: .ellipsis,
                    textAlign: .center,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: .w700,
                      color: themeColor,
                      letterSpacing: -0.2 * inverseScale,
                      height: 1.05,
                    ),
                  ),
                  Gap(1.0 * inverseScale),
                ],
              ),
            ),
          ),
          Gap(gap),
          // 2. 円形アイコンバッジ（ピン）
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: themeColor,
              shape: .circle,
              border: Border.all(
                color: Colors.white,
                width: iconBorderWidth,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x2E000000),
                  blurRadius: 2 * inverseScale,
                  offset: Offset(0, 0.5 * inverseScale),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: innerDotSize,
                height: innerDotSize,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: .circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ユーザーの現在地と視線方向（向き）を地図上に表示するマーカーウィジェット。
///
/// 密集したピンの中で現在地を見失わないよう、大きめのドットと
/// 視野コーンに加え、中心から広がるパルスリングを繰り返し描く。
class MapPlayerMarkerWidget extends HookWidget {
  const MapPlayerMarkerWidget({
    super.key,
    required this.headingRadians,
  });

  /// 地図上の北（上向き）を 0 とし、時計回り（東＝+π/2）を正とする角度（ラジアン）
  final double headingRadians;

  /// マーカー全体のサイズ（中心が現在地座標）
  static const double size = 28.0;

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 2000),
    );
    useEffect(() {
      controller.repeat();
      return null;
    }, [controller]);
    final pulsePhase = useAnimation(controller);
    return IgnorePointer(
      child: SizedBox(
        width: size,
        height: size,
        child: Transform.rotate(
          angle: headingRadians,
          child: CustomPaint(
            painter: _PlayerMarkerPainter(pulsePhase: pulsePhase),
          ),
        ),
      ),
    );
  }
}

class _PlayerMarkerPainter extends CustomPainter {
  const _PlayerMarkerPainter({required this.pulsePhase});

  /// パルスリングの進行度（0.0〜1.0）。時間経過で繰り返す。
  final double pulsePhase;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // 1. 視線方向の扇形（視野コーン：上向き -π/2 を基準に左右 ±32°）
    const coneRadius = 13.0;
    const spreadAngle = 64.0 * math.pi / 180.0;
    const startAngle = -math.pi / 2 - spreadAngle / 2;

    final conePath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: coneRadius),
        startAngle,
        spreadAngle,
        false,
      )
      ..close();

    final conePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColor.expoRed.withValues(alpha: 0.55),
          AppColor.expoRed.withValues(alpha: 0.05),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: coneRadius));
    canvas.drawPath(conePath, conePaint);

    // 2. パルスリング（中心から広がりながら薄くなる）
    final pulseRadius = 5.0 + (13.0 - 5.0) * pulsePhase;
    canvas.drawCircle(
      center,
      pulseRadius,
      Paint()
        ..color = AppColor.expoRed.withValues(alpha: 0.45 * (1 - pulsePhase))
        ..style = .stroke
        ..strokeWidth = 1.8 - 1.0 * pulsePhase,
    );

    // 3. 進行方向の小さな矢印ポインタ（上向き先端）
    final arrowPath = Path()
      ..moveTo(center.dx, center.dy - 8.5)
      ..lineTo(center.dx - 3.2, center.dy - 3.2)
      ..lineTo(center.dx + 3.2, center.dy - 3.2)
      ..close();
    canvas.drawPath(
      arrowPath,
      Paint()
        ..color = AppColor.expoRed
        ..style = .fill,
    );

    // 4. 外側の白縁シャドウ付きサークル
    canvas.drawCircle(
      center + const Offset(0, 0.6),
      4.5,
      Paint()
        ..color = const Color(0x40000000)
        ..maskFilter = const MaskFilter.blur(.normal, 1.5),
    );
    canvas.drawCircle(
      center,
      4.5,
      Paint()
        ..color = Colors.white
        ..style = .fill,
    );

    // 5. 内側の現在地ドット（万博レッド）
    canvas.drawCircle(
      center,
      3.2,
      Paint()
        ..color = AppColor.expoRed
        ..style = .fill,
    );
  }

  @override
  bool shouldRepaint(covariant _PlayerMarkerPainter oldDelegate) =>
      oldDelegate.pulsePhase != pulsePhase;
}
