# AGENTS.md

AI エージェント（Claude Code / Codex など）と人間が、同じ前提で作業するための指示書。
仕様の正本は [`docs/specs.md`](docs/specs.md)。ここには仕様を書き写さず、参照先だけを示す。

## プロジェクト概要

かさね旅（旧称 PhotoHunt／万博フォトハント）は、訪問者の写真を手がかりに 3D 空間を歩き、同じ撮影視点を探す観光アプリ。
Flutter の Android / iOS ネイティブアプリと、Serverpod（Dart）の API で構成する。
仕様・設計判断・未決事項は [`docs/specs.md`](docs/specs.md) を読む。

## ディレクトリ構成

ルートの `mise.toml` が monorepo root で、次の 5 つを config root として登録している。

| パス | 役割 |
| --- | --- |
| `app/` | Flutter アプリ（Android / iOS）。Dart は Flutter 同梱のものを使う |
| `api/` | Serverpod の API サーバー。パッケージ本体は #20 で作る |
| `shared/` | app と api が共有する公開 DTO と純 Dart のロジック（座標変換など） |
| `infrastructure/local/` | ローカル開発環境（docker compose と fake-gcs-server）。手順は [`infrastructure/local/README.md`](infrastructure/local/README.md) |
| `infrastructure/terradart/` | TerraDart による GCP の構成管理（`bootstrap/` と `stack/`）。手順は [`infrastructure/terradart/README.md`](infrastructure/terradart/README.md)、設計は [`docs/infrastructure.md`](docs/infrastructure.md) |

- `api/client/` は Serverpod が生成するクライアント（`photohunt_client`）。**生成物**で、config root にも入れない。
- 実装時のディレクトリ配置は `docs/specs.md` の「リポジトリ内の責務」が正。
- `.agents/skills/` はエージェント向けのスキル、`.github/` は Issue・PR のテンプレート。

## セットアップとよく使うコマンド

前提は mise `2026.11.0` 以上と Docker（詳細は [README の「前提」](README.md#前提)）。

```sh
mise trust --all          # ルートと各 config root の mise.toml を信頼する
mise install --monorepo   # mise.lock で固定したツールを全 config root 分入れる
mise setup                # 全プロジェクトの依存を取得する
mise check                # 全プロジェクトの lint と test。作業の最後に必ず実行する
```

- タスクは `mise //<path>:<task>` で、どのディレクトリからでも呼べる（例 `mise //app:test`）。`//...:test` は全 project の `test`。
- タスクの一覧は `mise tasks ls --all`。記法の詳細は [README の「タスクの参照記法」](README.md#タスクの参照記法)。
- 中身が未実装のタスクは `TODO(#NN)` を echo するだけ。成功しても何もしていないので、扱う Issue の番号を確認する。
- `mise check` は初回に Flutter のビルドが走るため、数分かかることがある。

| タスク | 内容 |
| --- | --- |
| `mise //app:lint` / `mise //app:test` | `flutter analyze` / `flutter test` |
| `mise //app:run:local` | ローカル API につないでアプリを起動する（`ios` / `android` / `device`） |
| `mise //app:run:prod` | Cloud Run（prod）の API につないでアプリを起動する。事前に `mise //infrastructure/terradart:outputs` |
| `mise //api:generate` | Serverpod のコード生成。`api/client` などを作り直す（#20） |
| `mise //api:migration:create` | DB マイグレーションを作る（#20） |
| `mise //api:check:generated` / `check:migration` | 生成物・migration の更新忘れを検査する。CI（`.github/workflows/api.yml`）と同じもの |
| `mise //infrastructure/local:up` | ローカル環境を起動する。事前に `.env.example` を `.env.local` にコピーする |

## 開発ルール

- 既存コードは必要な範囲を超えて変更しない。ついでの整形・リファクタリングはしない。
- 生成物（`api/client` など）は手で編集せず、`mise //api:generate` で作り直す。`.spy.yaml` と生成差分は同じコミットに入れる。
- ツールの版を変えるときは `mise.lock` を更新し、差分をレビューに出す（手順は [README](README.md#ツールの版を更新する)）。
- 秘密情報（`infrastructure/local/.env.local`、`api/config/passwords.yaml`）はコミットしない。
- `flutter test` を実行すると `app/vendor/flutter_scene/build/shaderbundles/*` に差分が出る。作業と関係なければコミットせずに戻す。

### Flutter/Dart 実装ルール（厳格遵守）

Flutter/Dart の実装・修正・レビューを行う際は、**必ず事前に [`flutter-rule` Skill](.agents/skills/flutter-rule/SKILL.md) を確認し、そのルールに完全に従って作業を行ってください。**

- **ルールの絶対遵守**: すべての Flutter/Dart コード変更において、`flutter-rule`（および該当する個別SKILL）の規定を完全に遵守してください。自己判断によるルールの無視や例外的な実装は一切認めません。
- **違反の禁止**: ルールに反する実装（不適切な型キャスト、指定外のUIコンポーネント使用、不適切なNull安全性の扱い、不要な既存コードの変更など）は厳禁です。
- **作業前の確認**: コードの記述・変更を開始する前に、必ず関連する個別SKILLを参照し、ルールに則った方針であることを確認した上で実装してください。複数の領域に関係する変更では、該当する個別SKILLをすべて適用してください。

## ブランチ・コミット・PR の規約

- **ブランチ**：`<種別>/issue_<番号>/<要約>`（例 `feature/issue_19/mise-monorepo`、`docs/issue_18/update-specs`）
- **コミット**：`feat:` / `fix:` / `refactor:` / `docs:` などの接頭辞＋日本語の要約（例 `feat: miseのmonorepo構成を追加`）
- **PR**：[`.github/pull_request_template.md`](.github/pull_request_template.md) に沿って書き、関連 Issue を `Closes #番号` で結ぶ。確認結果には実行したコマンドと出力を貼る
- **Issue**：[`.github/ISSUE_TEMPLATE/`](.github/ISSUE_TEMPLATE/) の `task`（作業）か `bug`（不具合）を使う

## 作業を始める前に

1. 担当 Issue の「前提・決定事項」と「スコープ外」を読む。前提・決定事項は作業中に変えない。
2. スコープ外の作業が必要になったら、その場で実装せず別 Issue にする。
3. 「注意点・未確定事項」の結論は、PR の「レビューしてほしい点」に理由と一緒に書く。

### Flutterの構成を変更する前後の確認（必須）

1. `docs/specs.md` の「リポジトリ内の責務」と境界表を読む。
   参照リンクを見ただけで確認済みにせず、[handson_pub_devの完成版](https://github.com/pochipochi-tsudoi/handson_pub_dev/tree/6e78ff796f0646eae43609095b7c8a71888e1e88/lib/complete) の
   `provider/dio/provider.dart`、機能別の `provider/*/provider.dart`、
   `ui/*/view_model.dart`・`screen.dart`・`components/` の実コードを読む。
2. 編集前に、変更するファイルの役割・配置先・呼び出す層を参照実装と対応付ける。
   仕様の配置契約と合わない独自ディレクトリ・Repository／Service層を自己判断で追加しない。
   既存ファイルの配置が異なる場合も、それを新しい機能へコピーする根拠にしない。
3. 新しい機能別Providerは `provider/<機能>/provider.dart` に置き、参照実装と同じ
   `@riverpod` と生成Notifier／Providerを使う。通信を通常のクラスへ集めて
   手書きの `Provider(...)` で包むだけの代替構成にしない。
   ViewModelは機能別ProviderのNotifierを呼び、画面状態を扱う。
4. `screen.dart` は画面全体の組み立てに留め、入力欄・表示セクションは
   その画面の `components/` へ分ける。画面・Provider・モデルの責務を同じファイルへ混在させない。
   公開DTOはsharedの生成型を使い、アプリ専用のモデルは `model/<機能>/model.dart` を基準に配置する。
   新規のアプリ専用データモデルは参照実装と同じFreezedの不変データ型にする。
   モデルにRPC・Widget・日本語の表示文言への変換を持たせず、表示の判断はViewModelへ置く。
5. 提出前に新規・変更ファイルの一覧で上の対応を再確認し、PRに参照した実コードと
   今回の配置・責務の対応を記載する。`mise check` の成功だけで構成が正しいとは判断しない。
   生成対象を変えた場合はbuild_runnerで再生成し、Providerのoverride・破棄・旧応答の挙動も確認する。

この確認は、対象機能の実装・レビュー・リファクタリングのすべてに適用する。
構成への指摘を受けた場合は、指示書の追記だけで済ませず、指摘されたPRの実装と検証結果も修正する。

## push前のセルフレビュー（必須）

1. push前に、PRのベースブランチとの差分全体と未コミット・ステージ済みの差分を読み直す。
   直近の修正箇所だけで済ませず、新規ファイル・生成物・依存・テスト・説明文も対象にする。
2. Issueの範囲、仕様・参照実装との対応、配置・依存方向・責務、モデルの不変性、
   エラー処理、非同期処理と寿命、既存動作への影響、秘密情報の混入を確認する。
   lint・testの実行はセルフレビューの代わりにしない。
3. 指摘を見つけたら修正し、影響する検証と差分の再レビューを終えてからpushする。
   指摘対応の小さな追加コミットでも省略しない。レビュー後に変更した場合は変更箇所を再確認する。
4. PRの「セルフレビュー」に対象差分・確認観点・指摘と修正・未検証事項を具体的に記録する。
   問題が見つからなかった場合も確認した範囲を書く。未実装・未接続・未検証を完了扱いにしない。
