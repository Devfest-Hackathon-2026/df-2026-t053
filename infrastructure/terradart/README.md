# infrastructure/terradart

万博フォトハントの GCP 構成を [TerraDart](https://terradart.dev/) で管理する。
設計（2 層の Stack、IAM、CI/CD、保守経由のデプロイ）は [`docs/infrastructure.md`](../../docs/infrastructure.md) を正とする。

| パッケージ | 中身 | 適用者 | state |
| --- | --- | --- | --- |
| [`bootstrap/`](bootstrap/) | API の有効化、tfstate バケット、SA、プロジェクト単位の IAM、GitHub Actions の WIF、予算通知 | インフラ担当が手元から | 初回はローカル → `gs://<project>-tfstate/bootstrap/prod` |
| [`stack/`](stack/) | Artifact Registry、DB・素材バケット、Secret Manager の器、Cloud Run `photohunt-api`、Job `photohunt-migrate`・`photohunt-seed`、監視 | CI（`sa-ci-deploy`）。緊急時は手元から | `gs://<project>-tfstate/stack/prod` |

どちらも `terradart init` の雛形をもとにしている。部品のファイル（`lib/*.dart`）は resource を返す関数だけを持ち、`add(...)` は `lib/stack.dart` だけが呼ぶ。

## 版の固定

| 対象 | 固定先 |
| --- | --- |
| Dart | `mise.toml`（api と同じ 3.13.7） |
| TerraDart CLI・core・google | 各パッケージの `pubspec.yaml`（`^` なし、0.36.0）と `pubspec.lock` |
| OpenTofu | 各パッケージの `pubspec.yaml` の `terradart.opentofu_version`（mise では入れない）。PATH に別の `tofu` があるとそちらが使われるので、`engine-check` が版の違いを止める |
| google provider | `tf-out/prod/.terraform.lock.hcl`（コミットする） |

CLI は `dart run terradart_cli:terradart <command>` で呼ぶ（mise のタスクが包んでいる）。`dart pub global activate` は使わない。

## タスク

```sh
mise //infrastructure/terradart:setup      # 依存の取得
mise //infrastructure/terradart:lint       # analyze と format
mise //infrastructure/terradart:test       # synth した構成の検査（資格情報・ネットワーク不要。mise check に含まれる）
mise //infrastructure/terradart:engine-check   # 使われる OpenTofu が固定版か確かめる（validate・plan・apply・outputs の前に自動で実行）
mise //infrastructure/terradart:validate   # terradart validate（資格情報不要。初回は OpenTofu と provider をダウンロード）
mise //infrastructure/terradart:plan bootstrap
mise //infrastructure/terradart:apply bootstrap
mise //infrastructure/terradart:plan stack     # API_IMAGE・RELEASE_ID が要る
mise //infrastructure/terradart:outputs        # .terradart/dart_defines.prod.json を書く
mise //app:run:prod                            # 上の define file を読み、アプリを Cloud Run につないで起動する
```

`stack` の synth は、配備のたびに変わる値を Terraform 変数ではなく環境変数から読む。

| 環境変数 | 内容 |
| --- | --- |
| `API_IMAGE` | `asia-northeast1-docker.pkg.dev/<project>/photohunt/api@sha256:<64桁>`。タグ指定は synth で拒否する |
| `RELEASE_ID` | コミット SHA |
| `MAINTENANCE_MODE` | 保守リビジョンを作るときだけ `true`（既定 `false`） |

infra だけを変える plan・apply でも、稼働中の digest を `API_IMAGE` に渡す。

```sh
gcloud run services describe photohunt-api --region asia-northeast1 \
  --format='value(spec.template.spec.containers[0].image)'
```

## 初回構築（prod）

1. GCP プロジェクトを作り、課金アカウントを紐付ける（手作業）。
2. `bootstrap/lib/env.dart` と `stack/lib/env.dart` の値（プロジェクト ID・番号、課金アカウント、バケット名）が正しいか確認する（INF-01 で確定済み）。
3. インフラ担当の利用者認証で bootstrap を適用する。

   ```sh
   gcloud auth application-default login
   gcloud auth application-default set-quota-project <project>   # GCS backend の初期化が 404 にならないように
   export GOOGLE_BILLING_PROJECT=<project>                          # 予算 API の quota project
   mise //infrastructure/terradart:apply bootstrap
   ```

4. `bootstrap/lib/env.dart` の `stateBucket` に `<project>-tfstate` を入れ、state をバケットへ移す。

   ```sh
   cd infrastructure/terradart/bootstrap
   dart run terradart_cli:terradart state migrate
   ```

5. 出力（`sa_*_email`、`wif_*_provider`）を GitHub の Variables に登録する（`docs/infrastructure.md` 8.7）。
6. secret の器と Artifact Registry だけを先に作り、secret の値を入れる（値は state にも Git にも残さない）。
   Cloud Run は固定した版を参照するので、版がないと作れないため。

   ```sh
   cd infrastructure/terradart/stack
   PHOTOHUNT_SYNTH_PLACEHOLDER=1 dart run terradart_cli:terradart apply -- \
     -target=google_secret_manager_secret.jwtHmacKey \
     -target=google_secret_manager_secret.jwtRefreshPepper \
     -target=google_artifact_registry_repository.photohunt
   openssl rand -base64 48 | gcloud secrets versions add serverpod-jwt-hmac-key --data-file=-
   openssl rand -base64 48 | gcloud secrets versions add serverpod-jwt-refresh-pepper --data-file=-
   ```

7. 最初の image をビルドして Artifact Registry に push し、その digest で、**保守モードで** stack を適用する。
   DB のレプリカはまだないので、通常モードの API は復元できずに起動しない（`start.sh` が終了コード 30）。
   保守リビジョンは所有権も DB も使わないので、レプリカがなくても準備完了になる。

   ```sh
   API_IMAGE=<digest 付き> RELEASE_ID=<sha> MAINTENANCE_MODE=true mise //infrastructure/terradart:apply stack
   ```

8. 初回の DB を作る（migration Job の CLI。レプリカが既にあれば終了コード 6 で拒否される）。

   ```sh
   gcloud run jobs execute photohunt-migrate --region asia-northeast1 --args=init --wait
   ```

9. 必要なら出題を登録する（下の「出題の追加・切替」）。
10. 通常モードで適用する。新しいリビジョンが所有権取得 → 復元 → 版の照合を経て準備完了になる。

    ```sh
    API_IMAGE=<同じ digest> RELEASE_ID=<sha> mise //infrastructure/terradart:apply stack
    ```

11. 保守経由のデプロイを一度通して、GCS の権限・復元・所有権の引渡しを確認する（INF-04 の計測を含む）。

## 出題の追加・切替

seed の入力（`content/seeds`）は API の image に入れず、非公開の seeds バケット（`photohunt-seeds-prod`）に置く。
seed Job（`photohunt-seed`）はこのバケットを `/content/seeds` に読み取り専用でマウントし、ローカルの compose と同じ引数で動く。
出題を足しても API の image の再ビルドは要らない（`docs/specs.md`「リポジトリ内の責務」）。

1. 入力を検証してから、seeds バケットへ上げる（削除はしない。公開済みの版は DB が正本なので、上書きしても変わらない）。
   上げられるのは、プロジェクト単位の権限を持つ人と、`stack/lib/env.dart` の `mediaUploaders`（素材担当）に登録した人。
   `mediaUploaders` に登録すると、素材バケットと seeds バケットの両方に `objectAdmin` が付く。

   ```sh
   # ローカルで検証する（DB・所有権を使わない）
   docker compose -f infrastructure/local/compose.yaml --profile tools run --rm seed \
     verify --dir /content/seeds/<slug>/r<n>
   gcloud storage rsync -r content/seeds gs://photohunt-seeds-prod
   ```

2. seed は DB に書くので、API と同じ writer 所有権が要る。保守経由で実行する（保守リビジョンへ切り替え、旧 writer の停止を確かめてから）。

   ```sh
   gcloud run jobs execute photohunt-seed --region asia-northeast1 --wait \
     --args=load,--dir,/content/seeds/<slug>/r<n>,--publish,true
   ```

   CI から実行する場合は、`deploy.yml` を `job=seed`、`job_args=load,--dir,/content/seeds/<slug>/r<n>,--publish,true` で手動実行する。

## 守ること

- apply の前に plan の差分をレビューする。CI 以外で `--auto-approve` を付けない。
- トラフィックの切り替えと Job の実行は apply でしない（`docs/infrastructure.md` 8.5）。
- writer 所有権オブジェクト（`owner/writer.json`）は apply で作らない・消さない。
- `stack/lib/env.dart` の `dbReplicaPrefix` を変えると空の DB へ切り替わるのと同じになる。データ移行として別に扱う。
- state の手動編集・`state rm`・`import` は、対象を確認してから行う。

## 配備（保守経由）

配備は毎回、保守リビジョンを経由する（`docs/infrastructure.md` 8.5）。手順の本体は [`scripts/deploy.sh`](scripts/deploy.sh) で、GitHub Actions の `deploy.yml` も同じものを呼ぶ。`deploy.yml` は main への push（`api`・`shared`・`.dockerignore`・`stack`・`scripts` の変更。テスト・文書を除く）で自動実行され、seed や途中からの再開は main からの手動実行で行う。

```sh
mise //infrastructure/terradart:deploy -- --help          # 段階と使い方
mise //infrastructure/terradart:deploy -- resolve         # 配備する image と RELEASE_ID（NEED_BUILD=1 ならビルドが要る）
mise //infrastructure/terradart:deploy -- build           # 手元でビルドして push する
API_IMAGE=<digest 付き> RELEASE_ID=<sha> mise //infrastructure/terradart:deploy -- all
API_IMAGE=... RELEASE_ID=... mise //infrastructure/terradart:deploy -- --from wait-owner-released all   # 途中から再開
```

- `all` は plan の判定に従って、変更なし・apply だけ・保守経由のどれかを実行する。plan を取得・判定できないときは配備せずに止まる。
- 出題の登録・切替は `--job seed --job-args <引数>` で実行する。image や infra に差分がなくても保守経由で seed を実行する。`--job-args` は seed のときだけ使える。

| 段階 | 失敗したときの状態 | 再開 |
| --- | --- | --- |
| maintenance-revision・switch-maintenance | 旧リビジョンが稼働したまま | そのまま再実行 |
| wait-owner-released | 保守中。トラフィックのないリビジョンは削除済みで、所有権が残っている | Job とアップロードの停止を確認し、表示された `gcloud storage rm --if-generation-match=<N>` で解除してから `--from wait-owner-released`。この段階はトラフィックのないリビジョン（候補を含む）を削除する |
| job | 保守中。レプリカは元の版のまま | Job のログを確認して原因を除き、`--from job` |
| release-revision | 保守中 | 新リビジョンの起動ログ（`start.sh`）を確認し、`--from release-revision` |
| check-candidate | 保守中。新リビジョンは利用者に公開されていない | 新リビジョンが所有権を持っている可能性があるので、停止と解放を確認してから再実行 |
| switch-release | 保守中のまま | `--from switch-release` |

途中で止まっても、トラフィックは旧リビジョンか保守リビジョンにあり、空の DB で営業を再開しない。

### GitHub の Variables

bootstrap の出力を登録する（秘密ではないので Secrets ではなく Variables）。

| 名前 | 値 |
| --- | --- |
| `GCP_WIF_PLAN_PROVIDER` | 出力 `wif_plan_provider` |
| `GCP_WIF_DEPLOY_PROVIDER` | 出力 `wif_deploy_provider` |
| `GCP_PLAN_SA` | 出力 `sa_ciPlan_email` |
| `GCP_DEPLOY_SA` | 出力 `sa_ciDeploy_email` |
| `DEPLOY_ON_PUSH`（任意） | `false` にすると main への push で自動配備しない（手動実行だけになる） |

`GCP_WIF_PLAN_PROVIDER` が未設定の間、`infra.yml` は資格情報の要らない検査（lint・test・validate）だけを行う。
