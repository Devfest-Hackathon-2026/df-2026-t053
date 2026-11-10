# 実API・GPUのプレイ通しテスト

`playthrough_test.dart` は通常のアプリを起動し、画面操作で両モードの開始・撮影・結果比較・再挑戦・再撮影を確認する。
Provider・HTTP・SceneAdapterは差し替えない。ローカルAPIへテスト用のプレイ／撮影記録が作成される。
API_BASE_URLがlocalhost・127.0.0.1・Android emulatorの10.0.2.2以外なら開始前に失敗する。

先にローカルAPI・GCSを起動し、入口名付きの出題を公開する。
旧サンプルの更新手順は `infrastructure/local/README.md` の「入口選択導入前のデータを更新する」を参照。
実写との構図を確認するときは英国パビリオンr2を公開する。

`app/` で実行する（端末IDは `mise exec -- flutter devices` で確認）。

```sh
mise exec -- flutter test integration_test/playthrough_test.dart \
  -d <iOSシミュレーターID> \
  --dart-define=API_BASE_URL=http://localhost:8080/ \
  --dart-define=ASSET_BASE_URL=http://localhost:4443/photohunt-media-local/ \
  --dart-define=ALLOW_LOCAL_ASSET_HTTP=true
```

Android emulatorは両URLのhostを10.0.2.2へ変更し、APIが返す素材URLも合わせる。
テストは端末・ローカルサービスが必要なので、通常の `mise check` では実行しない。
この成功は実機のフレーム性能・メモリ・写真とモデルの視覚的一致の合格を意味しない。

`--dart-define=CAPTURE_PLAYTHROUGH=true` を追加すると、nearの結果の3列比較を
アプリの一時ディレクトリ `kasane-playthrough/near-comparison.png` へ保存する。
iOSシミュレーターのデータディレクトリは
`xcrun simctl get_app_container <端末ID> com.example.app data` で確認できる。
`flutter test` が終了時にアプリを削除する環境では、実行中にホストへコピーする必要がある。
起動時の保存結果復旧を対象にしたテストではないため、前回の実行はモード選択まで完了させておく。
