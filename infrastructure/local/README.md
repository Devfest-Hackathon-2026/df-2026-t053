# infrastructure/local

API をローカルで動かすための docker compose 環境。
本番と同じ `api/Dockerfile` の image と、GCS の emulator（[fake-gcs-server](https://github.com/fsouza/fake-gcs-server)）を組み合わせる。
操作はルートから `mise //infrastructure/local:<task>` で行う。

| ファイル | 内容 |
| --- | --- |
| `compose.yaml` | `gcs`・`api` と、tools profile の `migrate`・`seed` |
| `.env.example` | 設定値の見本。`.env.local` にコピーして使う（`.env.local` は Git 管理外） |
| `gcs/init/` | 起動時に読み込む初期バケット。直下のディレクトリ名がバケット名になる |
| `mise.toml` | タスク定義 |

## 1. 前提

- mise `2026.11.0` 以上と Docker（ルートの [README](../../README.md#前提)）
- `mise trust --all` と `mise install --monorepo` を済ませている

## 2. 初回の準備

```sh
cp infrastructure/local/.env.example infrastructure/local/.env.local
mise //infrastructure/local:up
```

`up` は `//api:docker:build` で image をビルドしてから、`gcs` と `api` を起動して healthy になるまで待つ。
`.env.local` が無いと、`up` などのタスクはコピーの手順を表示して止まる（自動ではコピーしない）。

英国パビリオンの出題を入れるときは、続けて `mise //infrastructure/local:seed` を実行する（「4. seed の投入」）。

`up` は、先に `migrate` で DB を用意してレプリカへ複製し、そのあと `api` がレプリカから復元して起動する。
API の起動には `--apply-migrations` を付けない（空 DB のまま営業を始めないため）。
`migrate` は本番の Cloud Run Job `photohunt-migrate` と同じ CLI（`api/bin/migrate.dart`）で、ローカルでは `apply --init-if-missing` で動く。
レプリカがなければ最初の DB を作り、あれば未適用の migration だけを適用する（適用済みなら何も変えない）。

```sh
mise //infrastructure/local:migrate              # apply --init-if-missing（compose の既定）
mise //infrastructure/local:migrate -- status    # 適用版の照合だけ（所有権を取らず、何も書かない）
mise //infrastructure/local:migrate -- init      # 初回作成だけ（レプリカがあれば終了コード 6 で拒否）
```

終了コードは `api/lib/migrate.dart` を参照（2 所有権を取れない、3 復元できない、4 適用の失敗、5 複製を確認できない、など）。
`seed` と `migrate` も `//api:docker:build` に依存するので、image が無い状態でこの順に実行してもよい。

## 3. 起動・停止・リセット

| タスク | 内容 |
| --- | --- |
| `mise //infrastructure/local:up` | image をビルドして `gcs` と `api` を起動する |
| `mise //infrastructure/local:down` | コンテナを止めて消す。GCS のデータ（volume）は残る |
| `mise //infrastructure/local:reset` | volume も消し、`gcs` だけを初期バケットの状態で起動し直す。**`api` は止まったまま**なので、続けて `up` を実行する |
| `mise //infrastructure/local:logs` | `api` のログを追う |

- GCS のオブジェクトは volume（`photohunt-local_gcs-storage`）に残るので、`down` → `up` では消えない。`reset` で消える。
- `api` の `/data`（SQLite）は volume にしない。コンテナを消すと空になり、起動時にレプリカ（`replica` volume）から復元する。
- `up` は毎回 image をビルドする。変更が無ければ docker のキャッシュで数秒で終わる。
- バケットは `gcs/init/<バケット名>/.keep` から作る。`.keep` は空のバケットを Git で持つための置き場で、`reset` 後も 1 件残る。
  - `photohunt-media-local`: 公開素材
  - `photohunt-db-local`: writer 所有権（`owner/local/writer.json`）。Litestream のレプリカは GCS ではなく `replica` volume（[本番との差分](#7-本番との差分)）

### 動作確認

```sh
curl -s http://localhost:4443/storage/v1/b | grep -o '"name":"[^"]*"'                 # バケット 2 つ
curl -s -X POST http://localhost:8080/health/ping \
  -H 'Content-Type: application/json' -d '{"request":{}}'                              # health.ping
```

### 永続化の実証（#24）

「成功応答した記録は、コンテナを捨てても復元される」ことを手で確かめる。

```sh
mise //infrastructure/local:up
curl -s -X POST http://localhost:8080/anonymousIdp/login -H 'Content-Type: application/json' -d '{}'   # refreshToken を控える
docker compose -f infrastructure/local/compose.yaml rm -sf api                                       # api コンテナを捨てる
mise //infrastructure/local:up                                                                       # レプリカから復元して起動する
curl -s -X POST http://localhost:8080/jwtRefresh/refreshAccessToken -H 'Content-Type: application/json' \
  -d '{"refreshToken":"<控えた値>"}'                                                                 # 200 なら記録が残っている
```

同じ内容に、二重起動の拒否と Litestream 停止時の閉塞を加えて自動で確かめるのが `mise //infrastructure/local:verify` （Docker が要る。環境を作り直す）。

起動ログで、次の順に進んだことが確認できる。

1. `writer 所有権を取得した`
2. `start.sh: GCS から復元する`（ローカルは volume から）
3. `DB の検証に成功した`（整合性・外部キー・スキーマ版）
4. `start.sh: Litestream を起動する`
5. `start.sh: Serverpod を起動する`

`docker compose stop api` では、Serverpod 停止 → Litestream 停止 → `writer 所有権を解放した` の順に終わる。

#### 所有権が残ったとき

Litestream が猶予内に止まらないなど、異常終了では所有権（`owner/local/writer.json`）が残り、次の `api` は起動しない（終了コード 20）。
**自動では奪わない**。旧プロセスと未完了のアップロードが止まったことを確認してから、generation を指定して解除する。

```sh
docker compose -f infrastructure/local/compose.yaml --profile tools run --rm --entrypoint /app/ops/bin/ops migrate owner show
docker compose -f infrastructure/local/compose.yaml --profile tools run --rm --entrypoint /app/ops/bin/ops migrate owner clear --generation <show の generation>
```

`reset` は volume ごと消すので、所有権も消える。

## 4. seed の投入

```sh
mise //infrastructure/local:seed
```

`content/seeds/uk-pavilion/r5`（英国パビリオンの出題）の素材を `photohunt-media-local` の `media/{sha256}/…` に置き、DB に下書きとして登録して公開する。
`seed` は api と同じ writer 所有権を使うので、タスクは api を止めてから実行し、終わったら（失敗しても）api を起動し直す。
seed の中身（`api/scripts/seed.sh`）は、所有権の取得 → レプリカから復元・検証 → Litestream 起動 → 書き込み → 複製の確認 → 所有権の解放の順で動く。
同じ入力をもう一度実行しても DB は変わらない（`同じ内容で登録済み（変更なし）`）。
表示名や digest の版を変えたあとに、同じ版番号へ再投入すると exit 3（登録済みの内容と両立しない）になる。`mise //infrastructure/local:reset` のあと `mise //infrastructure/local:up` と `mise //infrastructure/local:seed` で、volume ごと作り直す。

| 終了コード | 意味 |
| --- | --- |
| 0 | 成功（変更なしを含む） |
| 2 | 検証の違反。違反を全件表示し、素材も DB も書かない |
| 3 | 登録済みの内容と両立しない（同じ版番号に違う内容、公開済みの版の削除、別の出題が公開中など） |
| 4 | 外部の失敗（素材の置き場 GCS に届かない、DB ファイルがない・開けない・ロックされている・トリガーが拒否した、ファイルを権限などで読めない）。DB は変えていない |
| 1 | 使い方の誤り（`--名前 値` の組でない、そのコマンドで使えないオプション（`verify` の `--db`、`unpublish` の `--revision` など）、`--publish` が true／false でない）、入力ファイルがない・YAML の形が違う・知らない項目がある |
| 20 / 30 / 31 / 32 / 43 | 所有権・復元・DB 検証・Litestream・複製確認の失敗（`seed.sh` の冒頭を参照） |

seed CLI を動かした後に複製を確認できないまま終わったとき（exit 43、確認前の SIGTERM・Ctrl-C）は、`seed.sh` は所有権を**解放しない**。
次の api が、seed の書き込みを含まないレプリカから復元しないためである。レプリカを確かめてから、「所有権が残ったとき」の手順で解除する。
確認できた後の停止なら、所有権は解放される。

既定以外の操作は、api を止めてから seed サービスに CLI の引数を渡す（`--db` は `seed.sh` が付ける）。

```sh
cd infrastructure/local
docker compose stop api
docker compose --profile tools run --rm seed verify --dir /content/seeds/uk-pavilion/r5   # DB に書かず検証だけ
docker compose --profile tools run --rm seed load --dir /content/seeds/<slug>/r<n>          # 下書き登録だけ
docker compose --profile tools run --rm seed publish --slug <slug> --revision <n>           # 公開・切り戻し
docker compose --profile tools run --rm seed unpublish --slug <slug>
docker compose --profile tools run --rm seed delete-draft --slug <slug> --revision <n>      # 未公開の版だけ
docker compose up -d --wait api
```

`verify` は DB も所有権も使わないので、手元でも `cd api && dart run bin/seed.dart verify --dir ../content/seeds/uk-pavilion/r5` で確認できる。
入力の形式は `content/seeds/uk-pavilion/r5/revision.yaml` と `content/seeds/pavilions.yaml` を見本にする。
写真・会場図は JPEG・PNG・WebP（各 5 MiB 以下・最大辺 4096 px）で、メタデータは除いてから置く。PNG はテキスト／EXIF チャンク、JPEG は APP1・APP3・APP13・コメント、WebP は EXIF／XMP を持つと違反になる。途中で切れたファイルも違反（読めない）になる。

公開素材のバケットへ手でファイルを置いて試すこともできる。

```sh
curl -X POST --data-binary @a.txt -H 'Content-Type: text/plain' \
  'http://localhost:4443/upload/storage/v1/b/photohunt-media-local/o?uploadType=media&name=models/a.txt'
curl http://localhost:4443/photohunt-media-local/models/a.txt   # 匿名で取得できる
```

素材の URL は `http://<GCS_PUBLIC_HOST>/<バケット>/<オブジェクト>` の形式で、これが `ASSET_BASE_URL`（`http://localhost:4443/photohunt-media-local/`）になる。

### 入口選択導入前のデータを更新する（#206）

`up` はAPIとDBスキーマを更新しますが、登録済みの出題の内容は変えません。
古い公開版の開始点に `label` がない場合、自由探索は「入口を確認できませんでした」で停止します。
公開済みの `r1` のファイルを書き換えて再投入しても、内容の衝突として拒否されます。
データをresetせず、入口名を持つ**新しい版**を登録・公開してください。

既定の出題は、次の手順で `uk-pavilion/r5` へ更新します。

```sh
mise //infrastructure/local:up
mise //infrastructure/local:seed
# seed: uk-pavilion r5 を公開中にした（...）
```

`seed` の既定は第5版です。登録と公開は同一トランザクションで実行し、失敗すれば旧公開版を維持します。
成功後も旧版・旧開始点・セッション・撮影記録・素材は残り、同じコマンドを再実行できます。
アプリは起動し直して新しい出題版を取得してください。旧版の記録は新しい版の自己記録には合算されません。

別の出題が公開中の場合、上の公開は安全のため拒否されます。
別出題への切替は、先に対象を**下書き登録**して成功を確認し、旧出題を `unpublish` してから対象を `publish` します。
公開に失敗した場合は旧slug・revisionを `publish` して戻します。`unpublish` はデータ削除ではありません。
切替中はAPIを停止し、途中の非公開状態をアプリへ見せないでください。

## 5. アプリからの接続

`run:local` はdebugビルドに `ALLOW_LOCAL_ASSET_HTTP=true` を渡し、localhost・ループバック・RFC1918のLANアドレスのGCS emulatorだけHTTP取得を許可します。
素材は設定したorigin・バケットパス配下に限定し、SHA・サイズ・デコード検査は省略しません。
通常の起動・`run:prod`・release/profileではHTTPS必須です。独自コマンドでローカルdebugを起動する場合も、このdefineを明示してください。

匿名ログイン後は生成Clientの `profile.getMyProfile(GetMyProfileRequest())` で
初期名（旅人＋4桁）を取得し、`profile.updateNickname(UpdateNicknameRequest(nickname: ...))`
で変更できる。名前は前後空白を除いた1〜20書記素、改行・制御文字なし。
プロフィールが欠落している場合はトークン更新時に同じ認証主体で復旧する。
`getMyProfile` 自体は読み取り専用。

匿名作成は接続元IPごと100件/時。ローカルの `.env.example` では、Docker越しの
接続元が共通になるため `ANON_SIGNUP_LIMIT_PER_HOUR=1000` にしている。
既存の `.env.local` に設定が無ければ100件/時となる。Cloud Runでは100件/時を
超える設定を拒否する。ローカルでは `X-Forwarded-For` を無視し、socketのIPを使う。
`K_SERVICE` のあるCloud Run直結経路では、`X-Forwarded-For` の右端だけを使う。
IPv6は/64単位。Cloud Runの実際のproxy chainと偽装耐性は、[Issue #65](https://github.com/penguins-osaka/gdg_hack/issues/65) で追跡し
デプロイ環境での実証が必要（ローカルのHTTPテストはその契約を模擬するもの）。

```sh
mise //app:run:local              # iOS シミュレーター（既定）
mise //app:run:local android      # Android エミュレーター
mise //app:run:local device       # 実機（macOS の en0 の IP を自動で使う。Linux などでは IP を指定する）
mise //app:run:local device 192.168.0.10   # 実機（IP を指定）
```

| 実行先 | API_BASE_URL | ASSET_BASE_URL のホスト |
| --- | --- | --- |
| iOS シミュレーター | `http://localhost:8080/` | `localhost:4443` |
| Android エミュレーター | `http://10.0.2.2:8080/` | `10.0.2.2:4443` |
| 実機 | `http://<LAN IP>:8080/` | `<LAN IP>:4443` |

`run:local` は上の値を `--dart-define` で渡して `flutter run` を呼ぶ（ポートは `.env.local` の `API_HOST_PORT` / `GCS_HOST_PORT` に従う）。

素材の URL（`AssetRef.url`）は **サーバーが `ASSET_BASE_URL` から作る**。端末から届くホストに合わせるため、実行先を変えるときは `.env.local` を直して `up` し直す。

| 実行先 | `.env.local` の `GCS_PUBLIC_HOST` | `.env.local` の `ASSET_BASE_URL` |
| --- | --- | --- |
| iOS シミュレーター | `localhost:4443` | `http://localhost:4443/photohunt-media-local/` |
| Android エミュレーター | `10.0.2.2:4443` | `http://10.0.2.2:4443/photohunt-media-local/` |
| 実機 | `<LAN IP>:4443` | `http://<LAN IP>:4443/photohunt-media-local/` |

食い違っていると `run:local` が警告を出す。

- **Android の平文 HTTP**: debug ビルドで `http://` を許す設定（`android:usesCleartextTraffic` など）は app 側の作業。この環境では設定しない。
- **iOS の平文 HTTP**: ATS の例外（`NSAllowsLocalNetworking` など）も app 側の作業。
- 実機は、Mac と同じネットワークにつなぎ、ファイアウォールで 8080 / 4443 を許可する。

## 6. よくある問題

| 症状 | 原因と対処 |
| --- | --- |
| `.env.local がありません` | `cp infrastructure/local/.env.example infrastructure/local/.env.local` を実行する |
| `port is already allocated` | 8080 / 4443 を別のプロセスが使っている。`.env.local` の `API_HOST_PORT` / `GCS_HOST_PORT` を変えて `up` し直す。`GCS_HOST_PORT` を変えたら `GCS_PUBLIC_HOST` と `ASSET_BASE_URL` のポートも合わせる |
| `up` が `api` の healthcheck で止まる | `mise //infrastructure/local:logs` を見る。`SERVERPOD_PASSWORD_*` が空だと起動に失敗する |
| 素材の URL が 404 | バケット名とオブジェクト名を確認する。`reset` はアップロードしたオブジェクトも消す |
| emulator の限界 | fake-gcs-server は認証・IAM・署名 URL の検証をしない。素材の公開範囲や書込権限の検証には使えない |

## 7. 本番との差分

| 項目 | ローカル | 本番 |
| --- | --- | --- |
| GCS | fake-gcs-server（`STORAGE_EMULATOR_HOST` を設定） | 実 GCS（`STORAGE_EMULATOR_HOST` は未設定） |
| ガイド | `GUIDE_BACKEND=fake` だけ。実際の Vertex AI は呼ばない（コンテナにはメタデータサーバーがなく、実行 SA の認証を使えない） | `gemini`。Vertex AI に実行 SA の認証（ADC）で接続する |
| 素材 URL | HTTP（`http://localhost:4443/...`） | HTTPS |
| 認証 | Serverpod の匿名 provider。秘密は `.env.local` のダミー値 | Secret Manager から注入 |
| Litestream の複製先 | **Docker volume（`type: file`）**。`infrastructure/local/litestream/litestream.yml` | GCS（`type: gs`）。`api/config/litestream.yml` |
| writer 所有権 | fake-gcs-server（本番と同じ条件付き作成・削除。削除は `generation` も併記する） | 実 GCS |

Litestream（v0.5.18）の複製先を fake-gcs-server にしない理由と、確認した結果は次のとおり。

- **複製（replicate）と `POST /sync` は fake-gcs-server でも動く。** `status: synced` / `no_change` と `replicated_txid` が返る。
- **復元（restore）は 404 で失敗する。** Litestream の GCS クライアントは、オブジェクトを `/<バケット>/<名前>`（名前の `/` は `%2F`）で読む。fake-gcs-server 1.56.1 は、この形式を **`Host` が `-public-host` と一致する要求にしか返さない**。コンテナ内の接続先（`gcs:4443`）と、端末から使う素材 URL の公開ホスト（`localhost:4443`）は両立しないので、複製先だけ file にした。本番の構成は変えない。
- fake-gcs-server は、**削除の `ifGenerationMatch` を無視する**（誤った generation でも消える）。所有権の解放は `ifGenerationMatch` と `generation` の両方を送る。`generation` は守られるので、他人の所有権を消さない。実 GCS では併記しても意味は同じ。
- 作成の `ifGenerationMatch=0`（2 回目は 412）は期待どおり動く。

したがって、ローカルでは「GCS への複製」そのものは検証できない。GCS の認証・権限・複製の確認は、本番相当の環境で行う（#33・#34）。
