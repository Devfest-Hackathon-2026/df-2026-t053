# ガイド音声のバッファ上限

実 HTTP アダプターは音声応答の `data` を受信中に base64 復号する。
JSON 全体や base64 全体を文字列として保持しない。音声以外の JSON は最大 64 KiB、
音声は最大 10 MiB。PCM の前に WAV ヘッダー用 44 bytes を予約し、変換時は同じ領域に書く。
最終 WAV が 10 MiB を超える PCM はヘッダー書き込み前に拒否する。

管理する大容量バッファの上限（同時 2 件）：

| 領域 | 1 件 | 2 件 |
| --- | ---: | ---: |
| 音声（ヘッダー余白含む） | 10 MiB + 44 bytes | 20 MiB + 88 bytes |
| JSON metadata の byte 配列 | 64 KiB | 128 KiB |
| 復号に渡す base64 小片 | 4 Ki 文字 | 8 Ki 文字 |
| 送信キュー（#32） | 128 KiB / 接続 | 256 KiB / 2 接続 |

metadata の UTF-8 変換・JSON 解析、base64 小片の復号、32 KiB chunk のシリアライズも
上の小さい上限内で行う。WAV→chunk は view で、WAV 全体のコピーは作らない。
24 MiB はこれらのアプリケーションバッファの制約であり、Dart VM のヒープ、GC がまだ回収して
いない領域、HTTP/TLS/OS の内部バッファを含むプロセス RSS の上限ではない。
Cloud Run のプロセスメモリは別途実測する。

`bounded_audio_json_test.dart` は最大 WAV 2 件を分割受信し、2 接続の送信を停止して
各 128 KiB を同時に保持した状態で主要確保領域が 24 MiB 未満、
PCM→WAV の buffer が同一であることを検査する。実 HTTP 分割受信は
`gemini_transport_test.dart`、遅い TCP 受信者への送信は #32 の `bounded_socket_sink_test.dart` で検査する。

JSON の構文検査は標準 `jsonDecode` に任せる。音声 `data` は第一候補の `inlineData` 内の
1 個だけを許可し、別の場所・複数個・不正 base64・途中切断を拒否する。
音声なしの拒否応答は既存の失敗分類へ渡す。非音声応答も 64 KiB で中断する。
公開ポートやモデル設定は変更しない。偽 transport が返す従来の base64 文字列はテスト互換用に扱う。
