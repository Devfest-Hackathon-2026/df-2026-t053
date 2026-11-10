---
name: build-runner
description: Providerなどの生成コードに対してbuild_runnerを必要なときだけ実行するための運用ルール。
---

# Build Runner

## 方針

Provider生成などで必要な`.g.dart`が一度生成済みなら、関数を作るたび・変更するたびに`build_runner`を実行しない。生成処理は時間がかかるため、生成対象に実際の変更がある場合だけ実行する。

特にRiverpodでは、`void build() {}`などのProvider生成対象となる宣言を変更した場合を除き、基本的に再生成は不要である。Provider内部の処理や補助関数を追加・変更しただけで、毎回生成コマンドを実行してはならない。

```dart
// このbuildのシグネチャやアノテーションを変更した場合は再生成を検討する
@riverpod
class UserController extends _$UserController {
  @override
  void build() {}
}
```

```dart
// build_runnerの再実行は基本的に不要
String formatUserName(User user) {
  return user.name.trim();
}
```

```sh
flutter pub run build_runner build --delete-conflicting-outputs
```

## 実行する場合

- 新しいアノテーション付きファイルを追加した。
- Providerやシリアライザなど、生成対象の構造を変更した。
- Riverpodの`void build() {}`など、Providerの生成対象となるメソッドの宣言、戻り値、引数、シグネチャを変更した。
- Riverpodの`@riverpod`など、生成対象のアノテーションを追加・変更・削除した。
- 対応する`.g.dart`が存在しない、または古くてコンパイルできない。
- 依存パッケージや生成設定を変更した。

## 実行しない場合

- 生成済みProviderの関数本体だけを変更した。
- `void build() {}`の本体の処理だけを変更した。
- Provider内に補助関数を追加・変更した。
- Providerから呼び出すRepositoryやサービスの処理を変更した。
- UIや呼び出し側のロジックを変更した。
- 生成コードに影響しないUIやロジックを変更した。
- 既存の`.g.dart`が最新で、コンパイルと解析が通っている。

## チェックリスト

- まず生成対象と`.g.dart`の存在・差分を確認する。
- 関数を作るたびに実行しようとしていないか確認する。
- `void build() {}`の本体変更だけなら、基本的に実行しない。
- Providerの宣言・シグネチャ・アノテーション変更と、関数本体の変更を区別する。
- 実行前に生成対象外の変更を混ぜない。
- 実行後は生成ファイルの差分が意図したものだけか確認する。
- コマンドを実行しなかった場合も、その理由を変更内容から説明できるようにする。
