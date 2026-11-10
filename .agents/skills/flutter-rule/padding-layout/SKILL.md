---
name: padding-layout
description: Flutter UIの横方向PaddingとGapによる縦方向余白を統一するレイアウトルール。
---

# Paddingとレイアウト

## 基本方針

Paddingの指定は横方向を`horizontal`で統一し、縦方向の間隔は`Gap()`で表現する。`vertical`は安易に使用せず、基本的に使用しない。余白の責任をPaddingとGapへ分け、ウィジェットごとの独自の余白指定を増やさない。

## 禁止事項

- `EdgeInsets.only`を使用しない。
- `EdgeInsets.all`を使用しない。
- `EdgeInsets.symmetric(vertical: ...)`など、`vertical`を使った縦方向のPaddingを基本的に使用しない。
- 上下方向の間隔をPaddingへ埋め込まない。
- `symmetric`を使う場合も、横方向だけを指定する。プロジェクトの規約に反する縦方向の値を同時に指定しない。

```dart
// 避ける
padding: const EdgeInsets.only(left: 16, top: 8),
padding: const EdgeInsets.all(16),
padding: const EdgeInsets.symmetric(vertical: 16),

// 使用する
padding: const EdgeInsets.symmetric(horizontal: 16),
Column(
  children: [
    const Header(),
    Gap(8),
    const Body(),
  ],
)
```

## チェックリスト

- `only`と`all`が追加されていないか検索する。
- `vertical`を安易に使用していないか確認する。基本的に縦方向の余白は`Gap()`で表現する。
- 横の余白が`horizontal`に集約されているか確認する。
- 縦の余白が`Gap()`で表現されているか確認する。
- 画面全体の余白と子要素間の間隔を混同していないか確認する。
