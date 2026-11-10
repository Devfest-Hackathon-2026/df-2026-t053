---
name: ui-package
description: Flutter UIでmaterial_uiを使用し、flutter/material.dartを直接使用しないためのパッケージ規約。
---

# UIパッケージ

## 必須インポート
Flutter 3.47以降のプロジェクトでは、`flutter/material.dart`を直接インポートせず、UIパッケージとして提供される`material_ui`を使用する。これにより、FlutterのバージョンアップやUIコンポーネントの変更に柔軟に対応できる。
このプロジェクトではFlutter UIの提供元として`material_ui`を使用する。標準のMaterialライブラリを直接インポートしない。

```dart
import 'package:material_ui/material_ui.dart';
```

## 禁止事項

```dart
// 使用しない
import 'package:flutter/material.dart';
```

- 新規ファイルで`flutter/material.dart`をインポートしない。
- 既存ファイルを変更するときも、対象範囲外のUIパッケージ移行を勝手に始めない。
- `material_ui`にないAPIを推測で作らない。必要なら依存パッケージの実装・ドキュメントを確認する。

## 確認方法

- 変更ファイルのimportを確認する。
- `flutter analyze`で利用中のウィジェットや定数が解決できることを確認する。
- Flutter 3.47のプロジェクト環境と互換性がある実装か確認する。
