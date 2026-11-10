import 'dart:ui' show Color;

/// design/palette.html のカラーパレット。
abstract final class AppColor {
  // EXPO 2025 main colors
  static const Color white = Color(0xFFFFFFFF);

  // EXPO 2025 secondary colors
  static const Color expoRed = Color(0xFFE60012);
  static const Color expoBlue = Color(0xFF0068B7);
  static const Color expoLightGray = Color(0xFFD2D7DA);
  static const Color expoMidGray = Color(0xFF828487);
  static const Color expoDarkGray = Color(0xFF222426);

  // Venue map zone pin colors
  static const Color empoweringZone = Color(0xFF45B7D1);
  static const Color signatureZone = Color(0xFF9B59B6);
  static const Color savingZone = Color(0xFFE67E22);
  static const Color connectingZone = Color(0xFFFF6B6B);
  static const Color japanPr = Color(0xFF2ECC71);
  static const Color ukPavilion = Color(0xFF003366);
  static const Color samplePavilion = Color(0xFF9AA0A3);

  // Material 3 roles
  static const Color primary = expoBlue;
  static const Color onPrimary = white;
  static const Color primaryContainer = Color(0xFFD7EAF6);
  static const Color onPrimaryContainer = Color(0xFF00385F);
  static const Color secondary = expoRed;
  static const Color onSecondary = white;
  static const Color secondaryContainer = Color(0xFFFBD9DC);
  static const Color onSecondaryContainer = Color(0xFF7A000A);
  static const Color surface = white;
  static const Color surfaceLow = Color(0xFFF4F6F7);
  static const Color surfaceMid = Color(0xFFE9EDEF);
  static const Color surfaceHigh = Color(0xFFDDE3E6);
  static const Color onSurface = expoDarkGray;
  static const Color onSurfaceVariant = Color(0xFF4A4E51);
  static const Color outline = Color(0xFFB9C0C4);
}
