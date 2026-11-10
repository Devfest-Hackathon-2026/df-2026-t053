import 'package:flutter/services.dart';

/// アプリ全体の画面の向きを横画面（左右どちらも）に固定する。
Future<void> lockLandscapeOrientation() {
  return SystemChrome.setPreferredOrientations(const [
    .landscapeLeft,
    .landscapeRight,
  ]);
}
