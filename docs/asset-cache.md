# 写真・会場図の端末キャッシュ

仕様の正本は [specs.md](specs.md#端末の素材取得と通信断)。この文書は #11 のAPI非依存部分の接続手順と検証範囲を記す。

## 配置と呼び出し

- `app/lib/provider/assets/provider.dart` の生成 `assetsProvider.notifier` が通信・共有ジョブ・キャッシュの寿命を管理する。
- `model/assets/model.dart` はFreezedの設定・進捗・失敗データだけを持つ。表示文言と画面状態は接続先のViewModelへ置く。
- 公開の `AssetRef` をそのまま入力する。API DTOの再定義や生成Clientへの依存はない。
- 既存の `asset_store.dart` は同梱3Dモデル用のまま維持する。今回の取得対象は写真と会場図だけ。

ViewModelは `ref.read(assetsProvider.notifier).acquire(assetRef)` で `AssetLease` を取得し、`await lease.file` で検証・画像デコード済みのファイルを受け取る。`lease.progress` は現在の受信量、`lease.changes` は後続の進捗を表す。
準備から探索終了まで参照を保持し、取消・再試行の旧参照・画面破棄時には `lease.release()` を必ず呼ぶ。複数画面で共有した取得は最後の参照の解放時だけ止まり、完了ファイルは参照中の容量整理から保護される。

`AssetFailure.kind` は入力不備、検証失敗、通信・期限、保存領域、取消を区別する。例外の文字列を画面へ直接表示せず、ViewModelで写真の再試行、地図の簡易図への切替などを判断する。

## 環境と保存

`ASSET_BASE_URL` はHTTPSのバケットURL（例 `https://media.example.com/bucket`）。その配下の `media/{sha256}/{photo|map}.{jpg|png|webp}` だけを許可する。署名クエリ、ユーザー情報、フラグメント、非正規パスは拒否する。リダイレクトは同一originも含めて追従しない。

ローカルfake-gcs-serverのHTTP URLをこの取得処理に通す例外は設けていない。APIなしの試験にはlocalhostのHTTPSサーバーを使用する。

アプリ専用Application Supportの `assets/` に保存する。iOSは専用MethodChannelでこのディレクトリだけをバックアップから除外し、AndroidはAuto Backupと端末間移行の除外規則を指定する。起動時に前プロセスの `.part/` を破棄する。

取得数は2本、画像は各5 MiB・最大辺4096px、キャッシュは100 MiB。検証後の同一FS内renameまで未確定ファイルを公開しない。予約済みの受信容量も上限へ含め、未使用ファイルを最終利用時刻順に削除する。保護対象しか残らなければ保存領域の失敗を返す。

## 検証と後続

`mise //app:test` でAPIを立ち上げずに、実HTTPS・SHA/サイズ・画像デコード・共有取得と取消・並行数・容量整理・タイムアウトを検証できる。テストの自己署名証明書とダミー鍵はlocalhost専用で、証明書の照合をテスト内だけで行う。

手がかり写真は `app/lib/provider/photo/provider.dart` が出題版の `photo` を `acquire` し、モード選択・準備・探索の写真パネル・結果の実写側が同じ参照を使う。会場図の接続、地図失敗時の簡易図、実機での通信断とバックアップ除外の確認は未了で、#11 全体の完了にはしない。
