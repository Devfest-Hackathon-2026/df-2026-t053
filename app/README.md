# かさね旅 — Flutter アプリ

## アプリ名とアイコン

画面タイトルと Android／iOS のホーム画面表示名は「かさね旅」。
既存のインストール・認証との互換性を保つため、パッケージ名・Bundle ID・内部識別子は変更しない。

アイコン原本は [`design/branding/app-icon.png`](../design/branding/app-icon.png)、
生成時のプロンプトは [`app-icon-prompt.txt`](../design/branding/app-icon-prompt.txt)。
原本は承認済みの正方形・不透明 PNG を使い、OS が適用する角丸は画像へ焼き込まない。
Android の `mipmap-*` と iOS の `AppIcon.appiconset` はリポジトリルートで次のコマンドを実行して再生成する（macOS の `sips` が必要）。

```sh
bash app/tool/generate_app_icons.sh
```

原本と生成した全サイズの PNG を同じ変更に含める。
端末への反映は再ビルドして更新インストールした後に、ホーム画面の表示名とアイコンを確認する。

## 構成の対応

[仕様が参照するhandson_pub_dev完成版](https://github.com/pochipochi-tsudoi/handson_pub_dev/tree/6e78ff796f0646eae43609095b7c8a71888e1e88/lib/complete)
と同じ、機能別Provider／ViewModel／Screen／componentsの構成を使う。

| 参照実装 | この機能での配置・責務 |
| --- | --- |
| `provider/dio/provider.dart` | `provider/api_client/provider.dart`: RiverpodによるRPC接続の注入 |
| `provider/package/provider.dart` | `provider/profile/provider.dart`: `@riverpod` NotifierでRPCと例外変換 |
| `model/package/model.dart` | 公開DTOはsharedの生成型。アプリ専用の失敗は `model/profile/model.dart` のFreezedデータ型。表示文言はViewModelで変換 |
| `ui/details/view_model.dart` | `ui/settings/view_model.dart`: Stateと画面操作、機能別Provider呼び出し |
| `ui/details/screen.dart`・`components/` | `ui/settings/screen.dart`・`components/`: 全体の組み立てと入力・表示部品 |

## 設定画面のプロフィール接続（#15の先行分）

`provider/profile/provider.dart` の生成Riverpod Notifier が公開DTOとRPCエラーを扱い、
`ui/settings/view_model.dart` が取得・編集・保存の状態を管理する。
取得前に仮の名前は出さず、保存応答の成功後だけ「保存しました」と表示する。
失敗時は入力を保持して手動で再試行できる。

共通 `apiClientProvider` が `api/client` の生成 `Client` を提供し、プロフィールProviderが
`client.profile.getMyProfile` / `client.profile.updateNickname` を呼ぶ。
接続先は `API_BASE_URL`（`run:local` が設定）。省略時はローカルiOSシミュレーター用の
`http://localhost:8080/`。公開DTOは `shared` の生成型を使用する。

認証の保管・復旧は #13 の残作業。接続側で同じClientへSDKの認証機構を設定する。
テストや認証主体の切替時は `apiClientProvider` をoverrideする。
Providerが生成したClientはProviderが破棄時に閉じ、overrideしたClientは注入側が管理する。
設定画面で別Clientや匿名アカウントを作成しない。認証主体を切り替える場合は
`apiClientProvider` の値も切り替え、利用者ごとに接続を更新する。
機能別ProviderとViewModelがその切替を監視し、旧応答を新しい利用者の表示へ反映しない。

`PROFILE_NOT_INITIALIZED` はSDKの `refreshAuthKey(force: true)` が成功した場合だけ、同じ要求を一度再実行する。
入力エラー・未認証・通信失敗は別扱いとし、生のAPIメッセージや認証情報を表示・ログ出力しない。
入力欄ではtrim後1〜20書記素を確認し、制御・書式文字などの厳密な判定はAPIを正とする。

テストダブルでの確認:

```sh
cd app
mise exec -- flutter test test/provider/profile test/ui/settings
cd ..
mise check
```

ランキング・自己ベスト・撮影時順位との区別は引き続き#15、
認証の保管・復旧と実Clientの接続は#13で扱う。

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
