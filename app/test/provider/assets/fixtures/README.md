localhostのTLS試験専用の自己署名証明書と公開ダミー鍵です。本番認証には使用しません。
テストはこの証明書だけを追加で信頼し、実装側のHTTPS検証は無効化しません。

再生成:

```sh
openssl req -x509 -newkey rsa:2048 -nodes \
  -keyout localhost-key.pem -out localhost-cert.pem -days 3650 \
  -subj '/CN=localhost' -addext 'subjectAltName=DNS:localhost,IP:127.0.0.1'
```
