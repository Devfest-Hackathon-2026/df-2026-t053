# Serverpod Client 4.1.1 の開始前キャンセル修正 (#122)

pub.dev の `serverpod_client` 4.1.1 から `lib/`、LICENSE、README.md、
CHANGELOG.md、pubspec.yaml を収録する。BSD 3-Clause の LICENSE を保持する。
元アーカイブの pubspec.lock SHA-256:
`44f4cc17f3fd410f7d28d355288c2da359a99ed57df1bf2e15cbed739bd2899f`。

https://pub.dev/packages/serverpod_client/versions/4.1.1

アプリだけを dependency_overrides でこのコピーへ向ける。生成ClientやAPI側の
依存・プロトコルは変更しない。上流workspace外で使うため pubspec.yaml の
`resolution: workspace` を除去した。

## パッチ

`lib/src/client_method_stream_manager.dart` のみ変更する。

- 最初の非同期接続より前に onCancel を登録し、取消済みの状態を保持する。
- 開始確認成功後、取消済みならその connectionId だけに Close を送り、
  既存の解放処理を使う。入力streamの購読は開始しない。
- 開始済みの取消・共有socketの寿命判定は既存処理を使う。
- 認証再試行にも取消状態を引き継ぎ、取消後の開始拒否では再認証しない。

最後のstreamならsocketを閉じ、他streamがあれば維持する。
開始応答が来ないケースのタイムアウト仕様は変更しない。

## 検証と除去条件

`app/test/provider/guide/client_connection_test.dart` の実生成Clientとローカル
WebSocket peerで、接続前・開始応答待ち・本文後の取消、並行stream、
接続失敗後の再接続、Guideの即時終了、通常終了を検証する。
SDK原本では開始前取消の回帰テストが失敗する。

同等の修正を含む上流リリースでこれらのテストが通ることを確認後、
通常のSDK更新とともにoverrideとこのディレクトリを削除する。
独自の機能追加や生成コードの変更はここへ入れない。
