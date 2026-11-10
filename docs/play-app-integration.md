# Flutter共通基盤・プレイ進行の統合記録

仕様の正本は[specs.md](specs.md)。本書はPR #103の接続先と検証記録を扱う。
初回の基準はmain `f1e442f` と既存PR #103 `1fbaafb`。レビュー対応で#123・#124を含むmain `f5f10f7`を追加統合した。中止された別実装の作業ツリーは参照・取り込み・変更していない。

## 担当Issueの対応

親は #13。#108〜#114は既存PR #103の実装を検証・補強する内訳として扱い、別Providerを二重に作らない。

| Issue | 既存実装と今回の確認先 |
| --- | --- |
| #108 | `provider/auth/provider.dart`。SDKセッション復旧・初回作成・一時失敗・Client変更後の旧応答対策 |
| #109 | `challengeProvider.notifier.listChallenges()`。ランキングの既存呼出契約を保持 |
| #110 | `challengeProvider.notifier.loadCurrent()`内部で単一出題を取得。公開終了・notFound・通信失敗を変換 |
| #111 | `loadCurrent()`と`loadRevision(int)`。不変版を保持し古いロード応答を破棄。復旧では記録の版を取得 |
| #112 | `playProvider.notifier.createSession(revisionId:, mode:)`。連打合流・条件とrequestId固定・unknown拒否 |
| #113 | `checkShotResult()`・`restorePending()`。completed／active／期限切れ／notFound／アカウント不一致 |
| #114 | `submitShot()`・`resendShot()`。保存前に同期的に固定・保存完了後送信・同一姿勢再送・入力拒否確認 |
| #120 | `healthProvider.notifier.ping()`。生成型`HealthResponse`、10秒期限、認証前の疎通と任意の版照合 |

Issueは実装の存在だけで完了扱いにしない。PR #103と本書を証拠として受け入れ条件を確認する。

## 他担当が使う接続口

- 共有Client：`app/lib/provider/api_client/provider.dart`の`apiClientProvider`。closeは同Providerが所有する。
- 認証：`app/lib/provider/auth/provider.dart`の`authProvider.notifier.ensureSignedIn()`。認証主体は`authProvider.authUserId`。トークンの正本・保存はSDK。
- 現在の出題版：`app/lib/provider/challenge/provider.dart`の`challengeProvider.revision`。ランキング用`listChallenges()`は自動再試行を重ねず、呼出側の世代管理を維持する。
- プレイの版・mode・ID：`app/lib/provider/play/provider.dart`の`playProvider.session`にある`revisionId`・`mode`・`id`。結果からは公開中の新版へ置き換えない。
- ガイド要求：`app/lib/usecase/play/play_controller.dart`の`guideRequestSnapshotProvider`が返す関数を要求時に呼ぶ。実セッション・現在の位置とyaw・`ja-JP`を固定した`ExplainNearbyRequest`になる。未確定なら失敗する。
- 結果→ランキング：既存`RankingScreen(revisionId: session.revisionId, initialMode: explorationMode, onClose: ...)`を使用。撮影時順位は結果DTOのスナップショットで表示。
- 別プレイ・終了・認証主体変更で、進行側から既存`guidePanelViewModelProvider.notifier.close()`を呼ぶ。

#123のguide Providerをmainから統合し、共有streamを一括切断しない実装を維持した。`play_guide_integration_test.dart`で実PlayControllerから生成Clientのguide入口へセッション・位置・yaw・ja-JPが渡ることと、終了／別プレイ／認証主体変更での購読取消・プレイヤー破棄・音声ファイル削除を確認。音声と通信応答はダブルであり、実機の可聴音声の確認ではない。
#124の設定・ranking/profileをmainから統合。ホームの設定ルートと探索内の設定overlayの両方へ取得済み`revision.credits`を渡す。`settings_route_test.dart`でホームから設定への出典表示・プロフィール取得・保存を確認。settings/ranking/profile自体は再実装していない。
#121の座標・歩行・shared/APIの変更は含めない。PlayControllerの座標計算は従来実装を維持し、セッションの寿命だけを接続する。

## 起動とhealth

既存の`API_BASE_URL`を使う。pingは認証・プロフィール取得より先に呼び、失敗時はAPIに届かない旨と再試行を表示する。
`--dart-define=API_RELEASE_ID=<期待するreleaseId>`を渡した場合だけ、応答のreleaseIdを照合して不一致を分ける。未指定時は疎通確認のみ。
これは業務API・DB・素材・Vertexの準備完了を保証するチェックではない。

## ローカル検証と残件

- build_runnerでFreezed・JSON・Providerを生成。端末記録はFreezedモデルと生成JSONで扱い、初期PRの平坦な保存形式も読み込む。
- 保存中連打・開始応答消失の手動再試行・期限切れ・別アカウント・古い応答・破損記録・再起動復旧・再挑戦後終了をテストする。
- 実生成ClientとSDKセッション管理を使うローカルHTTPテストで、認証前pingと認証後のBearerヘッダーを確認。匿名ログイン・OS secure storage自体はテストダブルの検証であり、実サーバー・実機検証ではない。
- `flutter test test/provider test/ui --reporter expanded`、`flutter test test/provider/health/provider_test.dart --dart-define=API_RELEASE_ID=test-release --reporter expanded`を実行。確定した件数・出力はPRの確認結果に記載。
- `mise check`は実行し、既存の`move_player_use_case_test.dart`の2件が浮動小数点許容誤差で失敗する。歩行ソース・テストはmainから変更していない。#121側で確認が必要。
- 未検証：両OSのsecure storageとOSプロセス終了・再起動、実APIでの合流後の両モード完走と回線断、背景復帰・描画資源・実機の表示と可聴音声。実機・本番の完了とは記載しない。
- 写真・会場図素材の表示や描画の完成は#11・#14・#10等との統合確認が別途必要。GCPの構築・設定・デプロイは行っていない。

## 構成の照合

AGENTS.md指定のhandson_pub_dev `6e78ff7` の`provider/dio/provider.dart`、`provider/package/provider.dart`・`provider/search/provider.dart`、`ui/home/view_model.dart`・`screen.dart`・`components/*`、Freezedモデルを実コードで確認。
生成Clientの注入→機能別の生成Notifier→ViewModel→Screen/componentsの方向を維持する。公開DTOはsharedの生成型を使い、端末記録と失敗モデルは`model/<機能>/model.dart`のFreezedに置く。結果ViewModelには結果DTOのスナップショットを渡し、探索ViewModelや最新ランキングを参照させない。

## マージ前指摘への対応

- `_verifyRejected()`の照会に10秒期限を設定。時計を進めるテストで10秒後に結果不明へ戻り、保留記録が残り、遅い成功応答でも状態・記録を変更しないことを確認。
- `PlayMode.unknown`をfreeへ変換しない。照会の入口とモード選択・探索の変換で拒否し、active／completedの復旧どちらもセッション・結果として採用しない。セッション不明時の再開は再照会し、取得まで探索へ進めない。
- モード選択ViewModelの通しテストで、同じClientの認証・出題・開始→探索→撮影→結果→撮影版・modeを指定した最新ランキング→新requestIdでの再挑戦→終了を両モードで確認。描画は置換し、正式点数は結果DTOを使う。
- 保存記録を引き継ぐ新しいProviderContainerを両モードで作成。元コンテナの破棄後に復旧・再送し、同じsession・姿勢・requestIdを保持して新規開始RPCを呼ばないことを確認。OSプロセス強制終了の実機検証を代替するものではない。
- 合流後のProvider・UIテストは180件成功・版照合専用1件skip。`mise check`は全project lint成功、appは206件成功・1件skip・既存歩行テスト2件失敗。全体成功とは記載しない。
- 今回はProviderの宣言・build引数・アノテーション・モデルを変更していないため、build_runnerの再実行は不要。
