#!/usr/bin/env bash
# 保守経由のデプロイ（docs/infrastructure.md 8.5）。手元と GitHub Actions（deploy.yml）で同じものを使う。
#
# 単一 writer のため、新旧のリビジョンは同時に所有権を持てない。ローリング更新はせず、毎回次の順に切り替える。
#   1 maintenance-revision  保守リビジョン M を作る（MAINTENANCE_MODE=true。所有権を取らない）
#   2 switch-maintenance    トラフィックを M へ移す
#   3 wait-owner-released   トラフィックのない旧リビジョンを削除して止め、所有権の解放を待つ
#   4 job                   Job（migrate か seed）を実行する
#   5 release-revision      新リビジョン N を作る（所有権取得 → 復元 → 版照合を経て準備完了になる）
#   6 check-candidate       N にタグ candidate を付け、タグ URL で疎通を確認する（トラフィックは M のまま）
#   7 switch-release        トラフィックを N へ移し、タグ r-<sha12> を付ける
#
# どの段階で止まっても、トラフィックは旧リビジョンか保守リビジョンにあり、空の DB で営業を再開しない。
# 各段階は何度実行しても同じ結果になるので、`--from <段階>` で続きから再開できる。
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STACK_DIR="$SCRIPT_DIR/../stack"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

STEPS=(maintenance-revision switch-maintenance wait-owner-released job release-revision check-candidate switch-release)
# api image の中身に関係するパス。テストと文書は image に入らないので、変わってもビルドし直さない。
# deploy.yml の push の paths と揃える。
IMAGE_PATHSPEC=(
  api shared .dockerignore
  ':(exclude)api/test' ':(exclude)api/docs' ':(exclude)shared/test' ':(exclude,glob)**/*.md'
)
OWNER_WAIT_SECONDS="${OWNER_WAIT_SECONDS:-300}"

usage() {
  cat <<'EOF'
使い方: deploy.sh [オプション] <コマンド>

コマンド:
  resolve              配備する image と RELEASE_ID を決めて KEY=VALUE で出す（NEED_BUILD=1 ならビルドが要る）
  build                api image をビルドして Artifact Registry へ push し、IMAGE=<digest 付き> を出す
  current-image        サービスの設定（template）の image を出す（Terraform が入れた digest）
  plan                 stack の plan を見て、hop（保守経由）/ apply / none のどれが要るかを出す
  all                  plan の結果に従って配備する（hop なら 1〜7 を順に実行）
  maintenance-revision | switch-maintenance | wait-owner-released | job |
  release-revision | check-candidate | switch-release
                       保守経由デプロイの各段階を 1 つだけ実行する

オプション:
  --image <ref>        配備する image（digest 指定）。既定は環境変数 API_IMAGE
  --release <sha>      RELEASE_ID。既定は環境変数 RELEASE_ID
  --job <migrate|seed> 段階 4 で実行する Job（既定 migrate。migration CLI の apply。適用済みなら何も変えない）
  --job-args <a,b,...> seed の引数（gcloud run jobs execute --args に渡す）
  --from <段階>        all で、保守経由デプロイをこの段階から再開する（plan の判定を飛ばす）
  --yes                apply の確認を省く（CI 用。手元では付けない）
  -h, --help           この説明を出す

環境変数 OWNER_WAIT_SECONDS（既定 300）で、段階 3 が旧リビジョンを削除したあとに待つ時間を変えられる。
EOF
}

log() { echo "deploy.sh: $*" >&2; }
die() { log "$*"; exit 1; }
# GitHub Actions ではジョブ概要へも書く（docs/infrastructure.md 8.4）。手元では何もしない。
summary() { [ -z "${GITHUB_STEP_SUMMARY:-}" ] || printf '%s\n' "$@" >>"$GITHUB_STEP_SUMMARY"; }

image="${API_IMAGE:-}"
release="${RELEASE_ID:-}"
job=migrate
job_args=""
from=""
yes=0
command=""

while [ $# -gt 0 ]; do
  case "$1" in
    --image) image="${2:?--image に値がない}"; shift 2 ;;
    --release) release="${2:?--release に値がない}"; shift 2 ;;
    --job) job="${2:?--job に値がない}"; shift 2 ;;
    --job-args) job_args="${2:?--job-args に値がない}"; shift 2 ;;
    --from) from="${2:?--from に値がない}"; shift 2 ;;
    --yes) yes=1; shift ;;
    -h | --help) usage; exit 0 ;;
    -*) usage >&2; die "不明なオプション: $1" ;;
    *) [ -z "$command" ] || die "コマンドは 1 つだけ指定する"; command="$1"; shift ;;
  esac
done
[ -n "$command" ] || { usage >&2; exit 64; }

# 名前の正本は stack/lib（Env・apiServiceName・ApiJob）。ここで書き直さない。
describe="$(cd "$STACK_DIR" && dart run bin/describe.dart)"
eval "$describe"
: "${GCP_PROJECT_ID:?}" "${GCP_REGION:?}" "${API_SERVICE:?}" "${MIGRATE_JOB:?}" "${SEED_JOB:?}"
: "${DB_BUCKET:?}" "${DB_WRITER_OWNER_OBJECT:?}" "${IMAGE_REPOSITORY:?}"

gc() { gcloud --project="$GCP_PROJECT_ID" --quiet "$@"; }
run_gc() { gc run "$@" --region="$GCP_REGION"; }
# terradart を呼ぶ前に、使われる OpenTofu が固定版か一度だけ確かめる（scripts/engine-check.sh）。
engine_checked=0
td() {
  if [ "$engine_checked" = 0 ]; then
    # $(...) や || の中では set -e が効かないので、失敗を明示的に返す。
    "$SCRIPT_DIR/engine-check.sh" || return 1
    engine_checked=1
  fi
  (cd "$STACK_DIR" && PHOTOHUNT_SYNTH_PLACEHOLDER='' dart run terradart_cli:terradart "$@")
}

require_release() {
  [ -n "$image" ] || die "API_IMAGE（--image）がない"
  [ -n "$release" ] || die "RELEASE_ID（--release）がない"
}

# サービスの設定（template）のコンテナ。Terraform が入れた値のまま残る（image は渡した digest）。
# リビジョンの image は Cloud Run が解決した amd64 の manifest の digest になり、image index の
# digest とは一致しないので、配備設定の image と RELEASE_ID はリビジョンではなくここから読む（#106）。
service_container() {
  run_gc services describe "$API_SERVICE" --format=json | jq -c '.spec.template.spec.containers[0]'
}

container_env() {
  jq -r --arg name "$2" '.env[]? | select(.name == $name) | .value // empty' <<<"$1"
}

# ラベル mode（stack/lib/api_service.dart）と RELEASE_ID で、作ったリビジョンを探す。最も新しいもの。
# image では照合しない（上の理由で、リビジョンの image は渡した digest と一致しない）。
find_revision() {
  local mode="$1" want_release="$2" listing
  listing="$(run_gc revisions list --service="$API_SERVICE" \
    --filter="metadata.labels.mode=$mode" --format=json)"
  jq -r --arg release "$want_release" '
    [.[] | select(any(.spec.containers[0].env[]?; .name == "RELEASE_ID" and .value == $release))]
    | sort_by(.metadata.creationTimestamp) | last | .metadata.name // empty' <<<"$listing"
}

apply_stack() {
  local maintenance="$1"
  require_release
  local flags=()
  if [ "$yes" = 1 ]; then flags=(--no-input --auto-approve); fi
  log "apply（MAINTENANCE_MODE=$maintenance, API_IMAGE=${image}）"
  API_IMAGE="$image" RELEASE_ID="$release" MAINTENANCE_MODE="$maintenance" td apply ${flags[@]+"${flags[@]}"}
}

cmd_current_image() {
  local container current_image
  container="$(service_container)"
  current_image="$(jq -r '.image // empty' <<<"$container")"
  [ -n "$current_image" ] || die "サービスの設定に image がない"
  echo "$current_image"
}

# 配備する image と RELEASE_ID を決める。api・shared・image の定義がサービスの設定の版から変わっていなければ、
# 設定の image と RELEASE_ID をそのまま使う（infra だけの変更で保守を挟まないため）。
cmd_resolve() {
  local head container current_image current_release
  head="$(git -C "$REPO_ROOT" rev-parse HEAD)"
  # 初回（サービスがまだない）は空になり、下でビルドの要否を決める。
  container="$(service_container 2>/dev/null || true)"
  if [ -n "$container" ] && [ "$container" != null ]; then
    current_image="$(jq -r '.image // empty' <<<"$container")"
    current_release="$(container_env "$container" RELEASE_ID)"
    if [ -n "$current_image" ] && [ -n "$current_release" ] &&
      git -C "$REPO_ROOT" cat-file -e "$current_release^{commit}" 2>/dev/null &&
      git -C "$REPO_ROOT" diff --quiet "$current_release" "$head" -- "${IMAGE_PATHSPEC[@]}"; then
      echo "API_IMAGE=$current_image"
      echo "RELEASE_ID=$current_release"
      echo "NEED_BUILD=0"
      return
    fi
  fi
  local digest
  digest="$(gc artifacts docker images describe "$IMAGE_REPOSITORY/api:$head" \
    --format='value(image_summary.digest)' 2>/dev/null || true)"
  if [ -n "$digest" ]; then
    echo "API_IMAGE=$IMAGE_REPOSITORY/api@$digest"
    echo "RELEASE_ID=$head"
    echo "NEED_BUILD=0"
  else
    echo "IMAGE_TAG=$IMAGE_REPOSITORY/api:$head"
    echo "RELEASE_ID=$head"
    echo "NEED_BUILD=1"
  fi
}

cmd_build() {
  local head metadata digest
  head="$(git -C "$REPO_ROOT" rev-parse HEAD)"
  metadata="$(mktemp)"
  gcloud auth configure-docker "${GCP_REGION}-docker.pkg.dev" --quiet >&2
  docker buildx build --platform linux/amd64 -f "$REPO_ROOT/api/Dockerfile" \
    -t "$IMAGE_REPOSITORY/api:$head" --push --metadata-file "$metadata" "$REPO_ROOT" >&2
  digest="$(jq -r '."containerimage.digest"' "$metadata")"
  rm -f "$metadata"
  echo "API_IMAGE=$IMAGE_REPOSITORY/api@$digest"
  echo "RELEASE_ID=$head"
}

# terradart plan --json の変更一覧から、Cloud Run サービスか Job の定義が変わるかを判定する。
cmd_plan() {
  require_release
  local out status=0
  out="$(API_IMAGE="$image" RELEASE_ID="$release" MAINTENANCE_MODE=false td plan --json --detailed-exitcode)" || status=$?
  case "$status" in
    0) echo none; return ;;
    2) ;;
    *) echo "$out" >&2; die "plan に失敗した（終了コード ${status}）" ;;
  esac
  # terradart の JSON は件数だけなので、同じ作業ディレクトリ（init 済み）で engine に plan を保存させ、
  # show -json の resource_changes から変わる resource を読む。state は書かない（-lock=false）。
  # all からは $(cmd_plan) で呼ばれ set -e が効かないので、判定できなければ明示的に止める。
  local engine workdir="$STACK_DIR/tf-out/prod" plan_json addresses address show_status=0
  engine="$(td engine --json | jq -r '.engine.path')" || die "engine の場所を取得できない"
  [ -x "$engine" ] || die "engine が見つからない: $engine"
  "$engine" -chdir="$workdir" plan -input=false -lock=false -out=deploy.tfplan >&2 ||
    die "engine の plan に失敗した"
  plan_json="$("$engine" -chdir="$workdir" show -json deploy.tfplan)" || show_status=$?
  rm -f "$workdir/deploy.tfplan"
  [ "$show_status" = 0 ] || die "保存した plan を読めない（終了コード ${show_status}）"
  # resource_changes がない・変わる resource が 0 件なら jq -e が失敗する（変更ありの判定と矛盾するので止める）。
  addresses="$(jq -er '
    [.resource_changes[] | select(.change.actions | map(. != "no-op" and . != "read") | any) | .address]
    | unique | .[]' <<<"$plan_json")" || die "plan から変更される resource を取り出せない"
  log "変更される resource:"$'\n'"$addresses"
  summary "- 変更される resource:"
  while read -r address; do summary "  - \`$address\`"; done <<<"$addresses"
  if echo "$addresses" | grep -Eq '^google_cloud_run_v2_(service\.api|job\.[A-Za-z0-9_-]+)$'; then
    echo hop
  else
    echo apply
  fi
}

step_maintenance_revision() { apply_stack true; }

step_switch_maintenance() {
  require_release
  local revision
  revision="$(find_revision maintenance "$release")"
  [ -n "$revision" ] || die "RELEASE_ID $release の保守リビジョンがない。maintenance-revision から実行する"
  log "トラフィックを保守リビジョン $revision へ移す"
  run_gc services update-traffic "$API_SERVICE" --to-revisions="$revision=100" >&2
}

# CPU を常時割り当てているため、トラフィックを 0% にしても Cloud Run は旧インスタンスを数分以上残す。
# その間 writer 所有権が解放されず、待つだけでは 300 秒で失敗する（INF-04）。
# トラフィックを受けていないリビジョンを削除すると SIGTERM が届き、start.sh が所有権を解放する。
# 受けているリビジョンは削除しない。削除後も残る所有権は Job か異常終了なので、自動では消さない。
stop_unserving_revisions() {
  local service_json revisions_json serving_json stop_json tags name out
  local serving_count still_count traffic_plan assignment sum
  local -a update
  service_json="$(run_gc services describe "$API_SERVICE" --format=json)"
  serving_json="$(jq -c '
    [.spec.traffic[]?, .status.traffic[]?
     | select((.percent // 0) > 0)
     | .revisionName | select(. != null)]
    | unique
  ' <<<"$service_json")"
  if [ "$serving_json" = "[]" ]; then
    die "トラフィックを受けているリビジョンが特定できない。旧リビジョンは削除しない"
  fi
  revisions_json="$(run_gc revisions list --service="$API_SERVICE" --format=json)"
  stop_json="$(jq -c --argjson serving "$serving_json" '
    [.[].metadata.name | select(. as $n | $serving | index($n) | not)]
  ' <<<"$revisions_json")"
  if [ "$stop_json" = "[]" ]; then
    log "トラフィックのない旧リビジョンはない"
    return
  fi
  # 0% の割り当てやタグが残っていると、リビジョンを削除できない。受けているものだけに固定する。
  traffic_plan="$(jq -c --argjson serving "$serving_json" '
    def rows:
      if ([.status.traffic[]? | select((.percent // 0) > 0)] | length) > 0
      then .status.traffic else .spec.traffic end;
    rows
    | map(select((.percent // 0) > 0 and (.revisionName as $n | $serving | index($n))))
    | unique_by(.revisionName)
    | {sum: (map(.percent) | add), assignment: (map("\(.revisionName)=\(.percent)") | join(","))}
  ' <<<"$service_json")"
  assignment="$(jq -r '.assignment' <<<"$traffic_plan")"
  sum="$(jq -r '.sum' <<<"$traffic_plan")"
  [ "$sum" = "100" ] ||
    die "受けているトラフィックの合計が ${sum}% である（${assignment}）。旧リビジョンは削除しない"
  tags="$(jq -r --argjson stop "$stop_json" '
    [.spec.traffic[]?, .status.traffic[]?
     | select(.tag != null and (.revisionName as $n | $stop | index($n)))
     | .tag]
    | unique | join(",")
  ' <<<"$service_json")"
  log "トラフィックを受けているリビジョンに固定する: $assignment"
  update=(--to-revisions="$assignment")
  if [ -n "$tags" ]; then
    log "トラフィックのないリビジョンのタグを外す: $tags"
    update+=(--remove-tags="$tags")
  fi
  run_gc services update-traffic "$API_SERVICE" "${update[@]}" >&2
  service_json="$(run_gc services describe "$API_SERVICE" --format=json)"
  serving_count="$(jq 'length' <<<"$serving_json")"
  still_count="$(jq --argjson serving "$serving_json" '
    [.spec.traffic[]?, .status.traffic[]?
     | select((.percent // 0) > 0)
     | .revisionName
     | select(. != null and (. as $n | $serving | index($n)))]
    | unique | length
  ' <<<"$service_json")"
  [ "$still_count" = "$serving_count" ] ||
    die "トラフィックを固定したあと、受けていたリビジョンが外れた。旧リビジョンは削除しない"
  while read -r name; do
    [ -n "$name" ] || continue
    log "旧リビジョン $name を削除してインスタンスの停止を促す"
    if ! out="$(run_gc revisions delete "$name" 2>&1)"; then
      if echo "$out" | grep -Eqi 'not found|NOT_FOUND|could not be found|Could not find'; then
        log "旧リビジョン $name は既に削除されている"
      else
        printf '%s\n' "$out" >&2
        die "旧リビジョン $name を削除できない"
      fi
    fi
  done < <(jq -r '.[]' <<<"$stop_json")
}

step_wait_owner_released() {
  local object="gs://$DB_BUCKET/$DB_WRITER_OWNER_OBJECT" waited=0 out
  stop_unserving_revisions
  log "旧 writer の所有権の解放を待つ（最大 ${OWNER_WAIT_SECONDS} 秒）: $object"
  while :; do
    if out="$(gc storage objects describe "$object" --format='value(generation)' 2>&1)"; then
      if [ "$waited" -ge "$OWNER_WAIT_SECONDS" ]; then
        log "所有権が残っている（generation ${out}）。トラフィックのないリビジョンは削除済み。Job の実行と未完了のアップロードが止まっていることを確認してから解除する:"
        log "  gcloud storage rm --if-generation-match=$out $object"
        log "  その後 deploy.sh --from wait-owner-released all で再開する（runbook「所有権の残留」）"
        exit 20
      fi
      sleep 10
      waited=$((waited + 10))
    elif echo "$out" | grep -Eqi 'not ?found|404|No URLs matched'; then
      log "所有権は解放されている"
      return
    else
      die "所有権オブジェクトを確認できない: $out"
    fi
  done
}

# 保守へ切り替えた後に止まらないよう、all では段階 1 より前に確かめる。
validate_job() {
  case "$job" in
    migrate) [ -z "$job_args" ] || die "--job-args は seed のときだけ使う（初回の init は README の手順で実行する）" ;;
    seed) [ -n "$job_args" ] || die "seed には --job-args が要る（例 load,--dir,/content/seeds/...,--publish,true）" ;;
    *) die "--job は migrate か seed にする: $job" ;;
  esac
}

step_job() {
  local name args=()
  validate_job
  case "$job" in
    migrate) name="$MIGRATE_JOB" ;;
    seed) name="$SEED_JOB" ;;
  esac
  if [ -n "$job_args" ]; then args=(--args="$job_args"); fi
  log "Job $name を実行する"
  run_gc jobs execute "$name" --wait ${args[@]+"${args[@]}"} >&2
}

step_release_revision() { apply_stack false; }

candidate_revision() {
  require_release
  local revision
  revision="$(find_revision normal "$release")"
  [ -n "$revision" ] || die "RELEASE_ID $release の通常リビジョンがない。release-revision から実行する"
  echo "$revision"
}

step_check_candidate() {
  local revision url
  revision="$(candidate_revision)"
  run_gc services update-traffic "$API_SERVICE" --update-tags="candidate=$revision" >&2
  url="$(run_gc services describe "$API_SERVICE" --format=json |
    jq -r '.status.traffic[] | select(.tag == "candidate") | .url')"
  [ -n "$url" ] || die "タグ candidate の URL がない"
  log "候補 $revision を確認する: $url/health/ping"
  # 初回の要求は所有権の取得・復元を含むので、待ち時間を長めにとる。
  curl -fsS --retry 3 --retry-all-errors --max-time 180 \
    -X POST -H 'Content-Type: application/json' -d '{"request":{}}' \
    "$url/health/ping" >/dev/null
  log "候補の疎通を確認した"
}

step_switch_release() {
  local revision tag
  revision="$(candidate_revision)"
  tag="r-${release:0:12}"
  log "トラフィックを $revision へ移す（タグ ${tag}）"
  run_gc services update-traffic "$API_SERVICE" --to-revisions="$revision=100" >&2
  # 再実行では candidate が既に外れているので、残っているときだけ外す。
  local traffic remove=()
  traffic="$(run_gc services describe "$API_SERVICE" --format=json)"
  if jq -e 'any(.status.traffic[]?; .tag == "candidate")' <<<"$traffic" >/dev/null; then
    remove=(--remove-tags=candidate)
  fi
  run_gc services update-traffic "$API_SERVICE" --update-tags="$tag=$revision" ${remove[@]+"${remove[@]}"} >&2
}

run_step() {
  case "$1" in
    maintenance-revision) step_maintenance_revision ;;
    switch-maintenance) step_switch_maintenance ;;
    wait-owner-released) step_wait_owner_released ;;
    job) step_job ;;
    release-revision) step_release_revision ;;
    check-candidate) step_check_candidate ;;
    switch-release) step_switch_release ;;
    *) die "不明な段階: $1" ;;
  esac
}

run_hop_from() {
  local start="$1" started=0
  for step in "${STEPS[@]}"; do
    if [ "$step" = "$start" ]; then started=1; fi
    if [ "$started" = 1 ]; then
      log "== $step"
      run_step "$step"
    fi
  done
  [ "$started" = 1 ] || die "不明な段階: ${start}（${STEPS[*]}）"
}

cmd_all() {
  require_release
  validate_job
  if [ -n "$from" ]; then
    summary "- 判定: \`hop\`（\`--from ${from}\` で再開）"
    run_hop_from "$from"
    return
  fi
  local decision
  decision="$(cmd_plan)"
  log "判定: $decision"
  # seed は DB へ書くので、image・infra に差分がなくても保守経由で Job を実行する。
  if [ "$job" = seed ] && [ "$decision" != hop ]; then
    log "seed を指定したので保守経由で実行する"
    decision=hop
  fi
  summary "- 判定: \`$decision\`"
  case "$decision" in
    none) log "変更なし" ;;
    apply) apply_stack false ;;
    hop) run_hop_from "${STEPS[0]}" ;;
    *) die "plan の判定が不正: $decision" ;;
  esac
}

case "$command" in
  resolve) cmd_resolve ;;
  build) cmd_build ;;
  current-image) cmd_current_image ;;
  plan) cmd_plan ;;
  all) cmd_all ;;
  *) run_step "$command" ;;
esac
