# ランキング・プロフィールの接続確認（#15 / #115〜#118）

確認したmainは `f1e442f`。PR [#70](https://github.com/penguins-osaka/gdg_hack/pull/70)・[#100](https://github.com/penguins-osaka/gdg_hack/pull/100)・[#104](https://github.com/penguins-osaka/gdg_hack/pull/104) の実装・説明・コメントと、各Issueの受け入れ条件を照合した。
新しいProviderや画面は作り直さず、既存の接続を使用する。
仕様の正本は [specs.md](specs.md) の「リポジトリ内の責務」「一覧の上限と整列」「匿名認証とプロフィール」「順位と結果の不変性」。

## 条件と既存実装の対応

| Issue | 既存mainで満たす条件 | 今回補うもの | 担当外・未検証 |
| --- | --- | --- | --- |
| #115 一覧 | #104の`RankingNotifier.listRankingEntries`とS11。版×モード、10秒上限、上位100件、空一覧、取得時刻、更新・再試行。更新中の連打はViewModelとボタンで抑止 | fake Clientで0・1・100件を明示検証。101位以下を別取得して表示する説明 | 認証済み通常起動・実機での導線 |
| #116 本人順位 | #104の`getMyRankingEntry`とS11。101位以下、本人未記録だけnull、別のnotFoundは失敗。結果から版・初期モードを指定できる | 既存Provider・ViewModel・Widgetテストを再実行。最新順位／撮影時順位の表示契約を引継ぎ | S02/S09の接続・submitShotのスナップショット保持は#13/#120担当。こちらでは結果画面を変更しない |
| #117 プロフィール取得 | #70のS12取得・現在名・失敗・再読み込み。#100で共通生成Clientへ接続 | RPCと認証復旧を合わせて10秒で打切り。期限超過・Provider再生成後に旧要求を再送しない | S01での認証・起動接続は#13担当 |
| #118 改名 | #70/#100の保存中・成功・型付き拒否・入力保持・手動再試行。成功時は返されたProfileで設定の現在名と編集値を同期 | 保存にも10秒上限。期限後の旧成功が次の保存を上書きしないテスト | 通常起動からの認証済み実機確認 |
| #15 出典・利用案内 | 匿名記録の引継ぎ不可は#70で案内済み | `Credit`の出典名・HTTPS URL表示とコピー、利用案内、出典未提供時の確認中表示 | 出題から`credits`を渡す呼出側の接続、公開素材の最終クレジット・許諾確定、署名実機・本番 |

プロフィールProviderはRPCを実行する生成Notifierで、別のプロフィールキャッシュは持たない。
成功した更新応答をSettingsViewModelが表示へ反映し、`getMyProfile()`は呼出時にサーバーの現在値を取得する。
新たな取得用／更新用Providerは増やさない。

## 共通基盤担当へ渡す画面API

[PR #103への引継ぎコメント](https://github.com/penguins-osaka/gdg_hack/pull/103#issuecomment-6741571007)

```dart
RankingScreen(
  onClose: closeRanking,
  revisionId: playSession.revisionId,
  initialMode: explorationMode,
)

SettingsScreen(
  onClose: closeSettings,
  credits: revision.credits,
)
```

- `RankingScreen.initialMode`はアプリの`ExplorationMode`。sharedの`PlayMode.free/near`から呼出側で明示的に対応付ける。未知のモードをfreeへ置き換えない。
- 結果からは撮影した`revisionId`を必ず渡す。版を省略するのはホームから公開中の版を解決する場合だけ。その画面を開いている間の更新は解決済みの版を維持する。
- S09は`SubmitShotResponse.myRankingEntry`の撮影時スナップショットを使う。S11はranking APIで最新順位を取得する。改名や最新取得でS09の名前・順位を上書きしない。
- S11のViewModelは`challengeProvider.notifier.listChallenges()`を使用する。challengeの取得・認証復旧は共通基盤担当に集約し、こちらで別実装を作らない。
- profile/rankingは既存`apiClientProvider`を利用する。認証主体変更時はこのProviderの依存を更新し、旧応答を表示へ反映させない。
- 設定の`credits`はsharedの`List<Credit>`で省略可能。取得済みの`ChallengeRevision.credits`を渡す。設定画面でRPCや別Clientを追加しない。
- 出典URLはHTTPS・ホストあり・認証情報なしの場合に表示し、長押しでコピーできる。ブラウザを開く機能は含まない。依存追加は行っていない。

## 出典と利用条件

確認した[出典記録](../content/provenance/README.md)は動作確認用の仮データで、公開用素材への置換が残っている。
固定の撮影者名やモデルの許諾を推測して埋めない。出典が渡されない場合は、この画面で確認できる情報がないことを表示する。
出典がある場合も、利用条件は各提供元で確認する案内とし、自由利用や配布許諾を推定しない。
利用案内はspecs.mdに記載された写真と3Dでの探索、GPS非取得、公開ニックネーム、匿名記録の引継ぎ不可、版・モード別順位に基づく。

## ローカル確認

```text
cd app
mise exec -- flutter test test/provider/profile test/provider/ranking test/ui/settings test/ui/ranking --reporter expanded
00:03 +58: All tests passed!
```

- 生成Providerへfake Clientを注入し、DTO・例外・画面状態まで確認した。
- 版・モード切替、Client override、画面破棄、遅い旧応答、未記録、101位以下、取得失敗と再試行は既存テストを継続使用。
- 追加した期限テストは実時間を待たず、Widgetテストの時計を進める。取得・保存の認証復旧が10秒を超えた場合、期限後に欠落応答が来た場合、同じClientでProviderを再生成した場合を確認。
- 設定・ランキングを320×640／800×350、文字2倍で操作し、長い名前・出典URL・100件の一覧を確認。
- Providerの宣言・引数・戻り値・アノテーションは変更していない。処理本体と補助メソッドだけの変更のため、build-runner Skillに従い再生成は不要。
- #104に記録されたローカル実API（撮影→改名→最新順位と撮影時スナップショット）検証は過去の証拠。今回の実API再実行や署名実機での確認とは扱わない。

`mise check`は全プロジェクトのlint成功、shared 100件・インフラbootstrap 7件／stack 19件成功。
appは144件成功・既存歩行テスト2件失敗でexit 1。失敗は`move_player_use_case_test.dart`の
`diagonal input does not exceed walking speed`（0.08に対し0.07999999736645286）と
`a long frame moves at most 50 ms worth`（−0.1に対し−0.10000000149011612）で、許容誤差1e-9を超える。
歩行のソース・テストはmainと同一。fail-fastで途中終了したAPIテストは`mise //api:test`を単独で再実行し、462件成功した。
対象テストの成功と、全体チェックの成功を混同しない。

表示部品の確認画像は公開用ブランチから除外した（Widgetテスト、日本語フォント、390×844で取得したもの）。

## 配置と参照実装

[handson_pub_devの固定コミット](https://github.com/pochipochi-tsudoi/handson_pub_dev/tree/6e78ff796f0646eae43609095b7c8a71888e1e88/lib/complete)の実コードを読んで確認した。

| 参照コード | 今回の配置・責務 |
| --- | --- |
| `provider/dio/provider.dart` | 既存`provider/api_client`による生成Client注入（変更なし） |
| `provider/package/provider.dart` | `provider/profile`の生成Notifier内でRPC・期限・例外変換 |
| `ui/home/view_model.dart` | `ui/settings/view_model.dart`が画面操作・表示用URLの判断を担当 |
| `ui/home/screen.dart`・`components/search_list.dart` | 設定Screenは組み立て、`sources_section.dart`は出典と案内、ランキング`ranking_content.dart`は本人順位と一覧の説明 |

公開DTOはsharedのProfile・Credit・RankingEntryをそのまま使い、独自のRepository／Serviceやデータモデルを追加していない。

## 完了扱いにしないもの

- #116のS02/S09、#117のS01、出題のcredits受渡しは共通基盤担当の接続・合流後に確認する。
- 公開素材のクレジット・利用条件の確定は#3/#15の残件。
- 署名実機での通し操作、本番APIは未確認。
- 親Issue #15全体は閉じない。細分化Issueも、担当外の接続や全体チェックの残件を明記して扱う。
