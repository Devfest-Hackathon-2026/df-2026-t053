---
name: dart-omission-syntax
description: Dart 3.38以降でプロパティ名と型名が一致する値の省略記法を強制するためのルール。
---

# Dart省略記法

## 目的

Dart 3.38以降では、プロパティ名から値の型やenumの所属を読み取れる場合に、型名を繰り返さず`.値`の形式で記述する。Flutterのレイアウトプロパティや`FontWeight`など、対象になるすべての箇所でこの記法を使用する。

## 遵守事項

- プロパティ名とクラス名が一致する値は、クラス名を省略する。
- `Alignment`、`MainAxisSize`、`MainAxisAlignment`、`CrossAxisAlignment`、`FontWeight`なども例外にしない。
- 新規コードだけでなく、変更した行の周辺に同じ違反があれば同時に確認する。
- 型推論が成立しない場合は、無理に省略せずコンパイラの診断を優先する。

## 例

```dart
// 避ける
mainAxisSize: MainAxisSize.min,
fontWeight: FontWeight.bold,

// 使用する
mainAxisSize: .min,
fontWeight: .bold,
```

## 自己チェック

- `MainAxisSize.`や`FontWeight.`など、プロパティ値で不要に型名を繰り返していないか確認する。
- `dart analyze`で省略後の型解決に問題がないことを確認する。
- コード出力前に、対象クラスの列挙値・定数値がすべて省略記法になっているか確認する。
