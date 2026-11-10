---
name: modern-dart-syntax
description: Dart 3.13以降を前提に、Primary Constructorを中心とした最新Dart記法を一つの方針として適用するための統合ルール。
---

# 最新のDart記法

このSKILLは、Dartのバージョン、Primary Constructor、const/named/factory constructor、移行規則、推奨例、制約、lint、エージェントの自己確認、公式参照を一つの内容として扱う。これらを別SKILLへ分割せず、構文を採用する判断から検証まで一続きで確認する。

## Dart Version

このプロジェクトではDart 3.13以降を前提とする。Dart 3.12ではPrimary ConstructorがExperimentalであり、Dart 3.13でStableになった。言語バージョンが要件を満たさないファイルでは、新構文を導入せず、まずプロジェクトのSDK制約を確認する。

## Primary Constructor

### 基本方針

単純なフィールド宣言とメインconstructorの組み合わせは、クラス宣言のヘッダーへまとめるPrimary Constructorを優先する。

```dart
// 従来の冗長な形式
class Bar {
  const Bar({
    required this.foo,
  });

  final String foo;
}

// Primary Constructor
class Bar({required final String foo});
```

declaring parameterに`final`または`var`を付けると、そのパラメータからインスタンスフィールドが生成される。`final`は不変値、`var`は変更可能なフィールドに使う。

```dart
class User({
  required final String name,
  required final int age,
});

class Counter({var int count});
```

### `final`を省略しない

次の形式はフィールドを生成せず、単なるconstructorパラメータになる。

```dart
class Bar({required String foo});
```

既存の`final String foo;`と`this.foo`を置き換える場合は、必ず`final String foo`または`var String foo`のようにdeclaring parameterとして記述する。パラメータをフィールドとして保持しない場合だけ、`final`や`var`を付けない。

```dart
class Parser({required String input});
```

### const constructor

既存のconst constructorをPrimary Constructorへ移行できる。ただし、機械的な短縮よりもconst性、初期化順序、可読性、既存の動作を優先する。移行前後で呼び出し側がconstとして利用できることを確認する。

```dart
// 移行前
class Point {
  const Point({
    required this.x,
    required this.y,
  });

  final int x;
  final int y;
}

// 移行後のプロジェクト規約例
class const Point(
  final int x,
  final int y,
);
```

### named constructor

Primary Constructorには名前付きconstructorを組み合わせられる。body内でconstructorを宣言する場合は、Dart 3.13以降の`new`構文を使ってクラス名の重複を避けられる。

```dart
class Point.custom(
  final int x,
  final int y,
);

class Point {
  final int x;
  final int y;

  new(this.x, this.y);

  new origin()
      : x = 0,
        y = 0;
}
```

### factory constructor

factory constructorは、既存インスタンスの再利用や外部データからの生成など、通常の生成constructorでは表現できない生成処理に使う。Primary Constructorと組み合わせる場合も、変換・検証・デフォルト値の責任を明確にする。

```dart
class User(final String name) {
  factory fromJson(Map<String, dynamic> json) {
    return User(json['name'] as String);
  }
}
```

## Migration Rules

既存コードを移行するときは次の順序で判断する。

1. 単純なフィールド宣言とメインconstructorの組み合わせか確認する。
2. `final String foo;`と`this.foo`を`final String foo`へ統合できるか確認する。
3. フィールドを生成するパラメータには`final`または`var`を付ける。
4. 既存の不変フィールドには原則`final`を維持する。
5. 複雑な初期化、複数constructor、redirecting/non-redirectingの関係がある場合は無理に移行しない。
6. 動作変更のリファクタリングと構文短縮のリファクタリングを同時に行わない。
7. クラス名はUpperCamelCaseで記述する。

## Preferred Examples

単純な不変値オブジェクトでは、次のようなPrimary Constructorを優先する。

```dart
class User({
  required final String name,
  required final String email,
});
```

次のような冗長な形式は、複雑な初期化などの理由がない限り避ける。

```dart
class User {
  const User({
    required this.name,
    required this.email,
  });

  final String name;
  final String email;
}
```

## Primary Constructorの制約

- `final`または`var`を付けたパラメータだけが暗黙のフィールドを生成する。
- パラメータ名をクラス内の別フィールドやメソッド名と衝突させない。
- Primary Constructorのパラメータはinitializer scope内で再代入できない。
- `late`や`external`はdeclaring parameterに使用できない。
- Primary Constructorを持つクラスでは、常にPrimary Constructorを実行する必要があるため、他のnon-redirecting generative constructorとの組み合わせに制約がある。
- 複雑な初期化を無理に一行へ圧縮しない。

制約に該当する場合は、従来のin-body constructorを維持する。新構文を使うこと自体を目的にしない。

## Constructor Syntax

Dart 3.13以降では、body内constructorでクラス名を繰り返さず`new`や`factory`を使える。

```dart
class Point {
  final int x;
  final int y;

  new(this.x, this.y);

  new origin()
      : x = 0,
        y = 0;

  factory fromJson(Map<String, dynamic> json) {
    return Point(
      json['x'] as int,
      json['y'] as int,
    );
  }
}
```

Primary Constructorへ表現できる単純なクラスではクラスヘッダーへまとめ、複雑なconstructor関係ではbody内構文を使う。

## Lints

Dart 3.13以降のlintでPrimary Constructorへの移行可能性を確認する。lintの指摘は機械的に適用せず、既存の動作と可読性を確認してから適用する。

- `use_declaring_parameters`: フィールド生成可能なパラメータをdeclaring parameterへ変換する。
- `empty_container_bodies`: 空のクラスbodyなどを`{}`ではなく`;`にする。
- `unnecessary_primary_constructor_body`: 不要なPrimary Constructor bodyを削除する。
- `unnecessary_type_name_in_constructor`: constructor宣言でクラス名を繰り返さず`new`を使う。
- `initialize_in_field_declaration`: initializer listの初期化を可能な場合にフィールド宣言へ移す。

## Agent Instructions

Dartコードを新規作成・変更するときは、Dart 3.13以降を前提にPrimary Constructorを利用できるか検討する。特に次の変換候補を見つけたら検討する。

```dart
class Foo {
  Foo({
    required this.bar,
  });

  final String bar;
}
```

```dart
class Foo({required final String bar});
```

ただし、変換で可読性が低下する場合、constructorが複雑な場合、複数constructorの関係が複雑な場合はin-body constructorを維持する。`class Foo({required String bar});`は`bar`フィールドを生成しないため、`final String bar;`と`this.bar`の置き換えに使わない。

## Version Reference

- Dart 3.12: Primary ConstructorはExperimental。
- Dart 3.13: Primary ConstructorがStable。
- Primary Constructorを利用するにはDart language version 3.13以上が必要。
- 本ルールの構文を実際に採用する前に、プロジェクトのSDK制約と使用中のDart SDKで検証する。

公式参照:

- https://dart.dev/blog/announcing-dart-3-13
- https://dart.dev/language/primary-constructors
- https://dart.dev/language/constructors

## 最終チェック

- Dart SDKと言語バージョンが要件を満たしているか確認する。
- declaring parameterの`final`/`var`を省略していないか確認する。
- constructor移行で動作、const性、初期化順序を変えていないか確認する。
- lintの自動修正を無批判に適用していないか確認する。
- 変更後に`dart analyze`または`flutter analyze`を実行する。
