# api_client 修正とアーキテクチャ確認（2026-11-09）

対象は `origin/main` の `e3c0d0f`。仕様の正本は [specs.md「リポジトリ内の責務」](specs.md#リポジトリ内の責務)。今回の実装は共通Clientとその呼び出し元・テストに限定し、下記の他機能の指摘は未修正として記録する。

## 今回の修正

- `provider/api_client/provider.dart` は `apiBaseUrlProvider` と、生成 `Client` を返す `apiClientProvider` だけを持つ。接続先は `API_BASE_URL`、省略時はローカルiOSシミュレーター用の `http://localhost:8080/`。Providerが作成したClientは破棄時に閉じる。overrideするClientの寿命は注入側が管理する。
- `photohunt_client` は `api/client` の既存生成パッケージ。公開DTO・enum・例外は `shared` の `photohunt_shared` を引き続き使い、アプリへ再定義しない。
- プロフィール専用の `ProfileApiClient` と `profileApiClientProvider` を削除。`ProfileNotifier` が共通Clientの `profile.getMyProfile` / `profile.updateNickname` を呼び、例外を `ProfileFailure` に変換する。
- `PROFILE_NOT_INITIALIZED` のときだけ、同じClientに設定されたSDK認証機構の `refreshAuthKey(force: true)` を呼ぶ。成功時だけ一度再試行し、接続先変更・破棄後の旧要求は再送しない。
- `GuideApiClient` は `provider/guide/provider.dart`、プレイの `guideRequestSnapshotProvider` は `usecase/play/play_controller.dart` へ移動。共通Clientから機能固有のDTOとプレイ状態の取得責務を除去した。
- `main` の生成Clientにはまだguide endpointがない。ガイド接続口は未接続のまま維持し、APIを推測して追加していない。匿名認証の保管・復旧と実プレイの接続も #13 の残作業。

## 参照実装との対応

実コードを読んだ参照は [handson_pub_dev の固定コミット](https://github.com/pochipochi-tsudoi/handson_pub_dev/tree/6e78ff796f0646eae43609095b7c8a71888e1e88/lib/complete)。

| 参照した実コード | 今回の配置・責務 |
| --- | --- |
| `provider/dio/provider.dart` | `provider/api_client/provider.dart`：機能に依存しないClientの注入。既存Serverpod生成Clientをそのまま使う |
| `provider/package/provider.dart`、`provider/search/provider.dart` | `provider/profile/provider.dart`：`@riverpod` の生成NotifierからClientを呼ぶ |
| `ui/home/view_model.dart` | `ui/settings/view_model.dart`：機能別Notifierを呼び、ロード・入力・保存・画面エラーを管理。実装変更なし |
| `ui/home/screen.dart`、`components/search_field.dart`、`components/search_list.dart` | 画面組み立てと表示部品の分離を確認。今回のUI変更は移動した取得口のimport整理だけ |
| `model/package/model.dart` | 既存の `model/profile/model.dart` と `model/guide/model.dart` はFreezed。公開DTOはsharedの生成型 |

## 他に見つかった指摘（未修正）

### 優先度高：歩行位置の正本が描画側にある

`app/lib/ui/exploration/view_model.dart` の `onTick` は `adapter.player.localTransform` から現在位置を読み、衝突判定を実行し、描画ノードへ位置を書き戻す。`teleportTo` も `SceneAdapter` を直接移動させる。`PlayController` は入力と向きを持つが、現在の足元位置を保持していない。

仕様では足元位置・向きはPlayControllerの正本で、Sceneは表示担当。描画ノードの破棄・再生成に状態が引きずられ、撮影・ガイド・地図が同じ確定座標を参照する保証がない。#12 / #13 で位置と移動・衝突判定の制御をPlayControllerへ移し、Sceneをその状態の表示へ接続する必要がある。衝突グリッドの `rootBundle.load` もViewModelが直接行っており、素材取得の責務を分離する。

### 優先度中：地図の座標変換がsharedと重複する

`app/lib/usecase/map/map_projection.dart` の `worldToMap` は正規化座標を独自計算している。`shared/lib/src/logic/map_projection.dart` の `toMapUv` が公開されているが呼んでいない。仕様の「共通座標変換を使う地図用処理」に合わず、軸・bounds契約の修正が片側だけに入る余地がある。#14 でsharedへ委譲し、Flutter側には表示矩形との変換を残す。

### 優先度中：CollisionGridの公開データが変更可能

`app/lib/model/collision_grid.dart` はFreezedではなく、公開された `Uint8List cells` の要素を書き換えられる。`final` は参照の再代入を止めるだけで、読み込んだ歩行判定データの不変性を保証しない。#12 で不変なデータ型とバイナリ解釈・判定処理の境界を整理する。既存の座標モデルも `model/<機能>/model.dart` ではなく直下にあり、新機能へ同じ配置をコピーしない。

### 優先度中：ランキング・結果の画面ファイルが表示部品を内包

`app/lib/ui/ranking/screen.dart` の `_ModeSegment`、`_RankingTable`、`_MyRankCard` など、`app/lib/ui/result/screen.dart` の `_CompareSection`、`_ScorePanel`、`_EpisodeSection` などが画面組み立てと同じファイルにある。画面ごとの `components/` へ分離する規約に合わない。

さらに `ui/ranking/view_model.dart` に手書きの `RankingRow` モデルが同居する。#15 でアプリ表示用なら `model/ranking/model.dart` のFreezed型、通信上の記録ならsharedの `RankingEntry` として責務を分離する。

### 未接続として区別する項目

- `ui/result/view_model.dart` は842点などを既定値として持ち、`ui/ranking/view_model.dart` は固定ランキング、`ui/mode_select/view_model.dart` は固定ニックネームを持つ。`submitShot` はRPCではなくタイマーで結果を表示する。正式な結果取得・保存として完了扱いにできない（#13 / #15）。
- `provider/assets/asset_store.dart` の `verifyIntegrity` は常にtrueを返す旧スタブ。現在の呼び出し有無とは別に、検証済みという契約として再利用してはいけない。実際の素材検証は `provider/assets/provider.dart` / `validation.dart` にある（#11）。
- ガイドの未接続口、会場マップのプレースホルダー、認証の保管・復旧は既存の残作業。今回の構造修正で機能完成とはしていない（#13 / #14 / #16 / #32）。

## 確認範囲と限界

アプリの手書きコードの配置・import、Provider／ViewModel／モデル／PlayController／Scene／Mapの主要処理、sharedの依存、APIの層間依存検査を確認対象にした。sharedからWidget・Riverpod・Session・DB行への依存、アプリからサーバー内部モデルへのimportは見つからなかった。APIにはASTによる既存の層間依存・DIのDBアクセス検査がある。vendor・生成コード全件の意味的レビュー、実機・本番APIの結合確認は対象外。

## 検証結果

```text
$ cd app && mise exec -- dart run build_runner build --delete-conflicting-outputs
Built with build_runner/aot in 109s; wrote 41 outputs.
# --delete-conflicting-outputsは使用中の版で廃止済みのため無視された。
# 無関係な既存2ファイルのhash差分は戻した。生成物の手編集なし。

$ mise check
[//app:lint] No issues found! (ran in 7.2s)
[//api:lint] No issues found!  # server / clientともに成功
[//shared:lint] No issues found!
[//infrastructure/terradart:lint] No issues found!  # bootstrap / stackともに成功
[//api:test] +438: All tests passed!
[//shared:test] +100: All tests passed!
[//infrastructure/terradart:test] +7 / +18: All tests passed!
[//app:test] +114 -2: Some tests failed.
# exit 1
```

アプリの失敗は、今回変更していない `test/usecase/play/move_player_use_case_test.dart` の2件。

- `diagonal input does not exceed walking speed`：期待0.08、実際0.07999999736645286、差2.6335471442484604e-9。
- `a long frame moves at most 50 ms worth`：期待−0.1、実際−0.10000000149011612、差1.4901161138336505e-9。

両方とも許容誤差1e-9を超える。歩行のソース・生成物・Positionモデル・テストが `origin/main` と同一であることを確認した。歩行処理の精度とテストの許容値の整理は #12 で扱い、今回のClient修正に混ぜていない。全体チェックの成功とは報告しない。

最初のチェックではmainで追加されたTerraDart stackの依存が未取得だったため、`mise //infrastructure/terradart:setup` 後に再実行した。アプリの重複importの指摘も修正済み。

共通Clientの接続先override・所有接続の破棄、プロフィールDTOの受渡し・SDK認証更新の成功／失敗・旧要求の再送防止、設定画面の旧応答破棄、ガイドの取消・音声解放をテストで確認した。匿名ログインからの実API結合、実機の音声再生は未検証。

対象の回帰テストをまとめて再実行した結果：

```text
$ cd app && mise exec -- flutter test test/provider/api_client test/provider/profile test/provider/guide test/ui/settings test/ui/exploration/guide_view_model_test.dart
00:02 +62: All tests passed!
# exit 0
```

テストが変更したvendorのshaderbundleは復元済み。

## セルフレビュー

`origin/main` との差分全体（新規テスト、生成物、依存・lock、README、ガイド接続手順、レビュー記録を含む）を確認。共通Clientに機能固有のDTO・処理が残っていないこと、プロフィールの依存方向、古い接続に対する再送の抑止、既存の例外分類・ガイド資源の破棄の維持を確認した。`git diff --check` は成功。未追跡の既存 `output/` は変更していない。
