/// 開始点の抽選。テストで差し替えられるようにする。
abstract interface class SpawnChooser() {
  /// [count] 個の候補から 0 以上 [count] 未満の添字を一様に選ぶ。
  int choose(int count);
}
