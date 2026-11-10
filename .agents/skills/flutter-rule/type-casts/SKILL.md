---
name: type-casts
description: 不要なasによる手動型固定を避け、Dartの型推論と安全な変換を優先するためのルール。
---

# 型キャスト

## 方針

`as Map<String, dynamic>`のような手動キャストは、必要性が明確でない限り書かない。`as`は実行時に失敗する可能性があり、型の不一致を早期に発見しにくくするため、エラーの温床になる。JSONモデルの`fromJson`は基本的にFreezedを使用し、生成コードへ処理を委譲する。

手書きの`fromJson`は原則として作成・使用しない。Freezedを導入できない既存モデルなど、例外が必要な場合も、理由と対象範囲を確認せずに独自実装を追加してはならない。

## 遵守事項

- まずAPIやメソッドの戻り値型を確認し、型推論を利用する。
- ジェネリクス、型付きモデル、パターンマッチなど、キャスト以外の表現を検討する。
- JSON境界では、Freezedモデルの生成`fromJson`へ変換責任を集約する。
- Freezedのアノテーションと生成対象を正しく定義し、手書きのJSON変換処理を増やさない。
- `as`が本当に必要な場合は、なぜ静的型だけでは表現できないか確認する。

```dart
// 避ける: 型を確認せず手動で固定する
final data = value as Map<String, dynamic>;

// 優先: FreezedでfromJsonを生成する
@freezed
class User with _$User {
  const factory User({required String name}) = _User;

  factory User.fromJson(Map<String, Object?> json) =>
      _$UserFromJson(json);
}

// 呼び出し側は生成された型付きfromJsonを使用する
final user = User.fromJson(json);
```

Freezedの`fromJson`本体やJSONキーごとの`as`キャストを手書きしない。モデル定義を変更した場合は、必要に応じて生成コードを更新し、生成された`.g.dart`の差分が意図した内容か確認する。

## チェックリスト

- 追加した`as`がなくてもコンパイルできないか確認する。
- キャストの対象が外部入力なら、失敗時の扱いを確認する。
- `fromJson`を手書きしていないか確認し、基本的にFreezedの生成処理を使用する。
- Freezedの生成対象と`.g.dart`が存在し、モデル定義と一致しているか確認する。
- `as`を削除したことで型安全性やエラー検出が低下していないか確認する。
