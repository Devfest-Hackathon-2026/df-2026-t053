#!/usr/bin/env bash
# Cloud Run が index と異なる manifest digest を返す場合の回帰テスト。
# 外部コマンドを差し替え、実際の deploy.sh の入口を通す。資格情報・ネットワークは使わない。
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="$(mktemp -d)"
trap 'rm -rf "$TEST_DIR"' EXIT
export TEST_DIR
mkdir "$TEST_DIR/bin"
export TEST_RELEASE
TEST_RELEASE="$(git -C "$SCRIPT_DIR" rev-parse HEAD)"
export PATH="$TEST_DIR/bin:$PATH"
unset API_IMAGE RELEASE_ID GITHUB_STEP_SUMMARY

cat >"$TEST_DIR/bin/dart" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if [ "$*" != 'run bin/describe.dart' ]; then exit 90; fi
cat <<'VALUES'
GCP_PROJECT_ID=test-project
GCP_REGION=test-region
API_SERVICE=test-api
MIGRATE_JOB=test-migrate
SEED_JOB=test-seed
DB_BUCKET=test-db
DB_WRITER_OWNER_OBJECT=owner/writer.json
IMAGE_REPOSITORY=test-region-docker.pkg.dev/test-project/test
VALUES
EOF

cat >"$TEST_DIR/bin/gcloud" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$*" >>"$TEST_DIR/calls"
case "$*" in
  *'run services describe '*) cat "$TEST_DIR/service.json" ;;
  *'run revisions list '*'metadata.labels.mode=normal'*) cat "$TEST_DIR/normal.json" ;;
  *'run revisions list '*'metadata.labels.mode=maintenance'*) cat "$TEST_DIR/maintenance.json" ;;
  *'run revisions list '*) cat "$TEST_DIR/revisions.json" ;;
  *'run revisions delete '*) ;;
  *'storage objects describe '*)
    if [ -f "$TEST_DIR/owner-present" ]; then
      echo 99
      exit 0
    fi
    echo 'No URLs matched' >&2
    exit 1
    ;;
  *'run services update-traffic '*) ;;
  *) echo "想定外の gcloud: $*" >&2; exit 91 ;;
esac
EOF

cat >"$TEST_DIR/bin/curl" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$*" >"$TEST_DIR/curl-call"
EOF
chmod +x "$TEST_DIR/bin/dart" "$TEST_DIR/bin/gcloud" "$TEST_DIR/bin/curl"

jq -n --arg release "$TEST_RELEASE" '{
  spec: {template: {spec: {containers: [{
    image: "test/api@sha256:index",
    env: [{name: "RELEASE_ID", value: $release}]
  }]}}},
  status: {traffic: [
    {revisionName: "serving-old", percent: 100},
    {revisionName: "normal-new", tag: "candidate", url: "https://candidate.invalid"}
  ]}
}' >"$TEST_DIR/service.json"

# API の列挙順には頼らず、対象 release の最新を選ぶ。より新しい別 release は除外する。
cat >"$TEST_DIR/normal.json" <<'EOF'
[
  {"metadata":{"name":"normal-new","creationTimestamp":"2026-11-09T12:00:00Z"},"spec":{"containers":[{"image":"test/api@sha256:manifest","env":[{"name":"RELEASE_ID","value":"target"}]}]}},
  {"metadata":{"name":"other-release","creationTimestamp":"2026-11-09T13:00:00Z"},"spec":{"containers":[{"image":"test/api@sha256:manifest","env":[{"name":"RELEASE_ID","value":"other"}]}]}},
  {"metadata":{"name":"normal-old","creationTimestamp":"2026-11-09T11:00:00Z"},"spec":{"containers":[{"image":"test/api@sha256:manifest","env":[{"name":"RELEASE_ID","value":"target"}]}]}},
  {"metadata":{"name":"without-release","creationTimestamp":"2026-11-09T14:00:00Z"},"spec":{"containers":[{"image":"test/api@sha256:manifest"}]}}
]
EOF
sed 's/normal-/maintenance-/g' "$TEST_DIR/normal.json" >"$TEST_DIR/maintenance.json"

assert_eq() {
  if [ "$1" != "$2" ]; then
    printf '期待値: %s\n実際: %s\n' "$1" "$2" >&2
    exit 1
  fi
}

assert_call() { grep -F -- "$1" "$TEST_DIR/calls" >/dev/null; }

assert_eq 'test/api@sha256:index' "$(bash "$SCRIPT_DIR/deploy.sh" current-image)"
echo 'ok: current-image は template の index digest を返す'

assert_eq "API_IMAGE=test/api@sha256:index
RELEASE_ID=$TEST_RELEASE
NEED_BUILD=0" "$(bash "$SCRIPT_DIR/deploy.sh" resolve)"
echo 'ok: resolve は template の image と release を再利用する'

: >"$TEST_DIR/calls"
bash "$SCRIPT_DIR/deploy.sh" --image test/api@sha256:index --release target check-candidate
assert_call '--update-tags=candidate=normal-new'
grep -F 'https://candidate.invalid/health/ping' "$TEST_DIR/curl-call" >/dev/null
if grep -F -- '--to-revisions=' "$TEST_DIR/calls" >/dev/null; then exit 1; fi
echo 'ok: check-candidate は対象のリビジョンをタグ URL で確認し、トラフィックは移さない'

: >"$TEST_DIR/calls"
bash "$SCRIPT_DIR/deploy.sh" --image test/api@sha256:index --release target switch-release
assert_call 'metadata.labels.mode=normal'
assert_call '--to-revisions=normal-new=100'
assert_call '--update-tags=r-target=normal-new'
echo 'ok: 通常リビジョンは digest が異なっても release が一致する最新を選ぶ'

: >"$TEST_DIR/calls"
bash "$SCRIPT_DIR/deploy.sh" --image test/api@sha256:index --release target switch-maintenance
assert_call 'metadata.labels.mode=maintenance'
assert_call '--to-revisions=maintenance-new=100'
echo 'ok: 保守リビジョンも release が一致する最新を選ぶ'

: >"$TEST_DIR/calls"
if bash "$SCRIPT_DIR/deploy.sh" --image test/api@sha256:index --release missing switch-release >"$TEST_DIR/result" 2>&1; then
  echo '一致する release がないのに成功した' >&2
  exit 1
fi
grep -F 'RELEASE_ID missing の通常リビジョンがない' "$TEST_DIR/result" >/dev/null
if grep -F 'update-traffic' "$TEST_DIR/calls" >/dev/null; then exit 1; fi
echo 'ok: 通常リビジョンが一致しない場合はトラフィックを変更しない'

: >"$TEST_DIR/calls"
if bash "$SCRIPT_DIR/deploy.sh" --image test/api@sha256:index --release missing switch-maintenance >"$TEST_DIR/result" 2>&1; then
  echo '一致する保守 release がないのに成功した' >&2
  exit 1
fi
grep -F 'RELEASE_ID missing の保守リビジョンがない' "$TEST_DIR/result" >/dev/null
if grep -F 'update-traffic' "$TEST_DIR/calls" >/dev/null; then exit 1; fi
echo 'ok: 保守リビジョンが一致しない場合はトラフィックを変更しない'

echo '[]' >"$TEST_DIR/normal.json"
if bash "$SCRIPT_DIR/deploy.sh" --image test/api@sha256:index --release target switch-release >"$TEST_DIR/result" 2>&1; then exit 1; fi
echo 'ok: リビジョン一覧が空なら失敗する'

echo '{}' >"$TEST_DIR/service.json"
if bash "$SCRIPT_DIR/deploy.sh" current-image >"$TEST_DIR/result" 2>&1; then exit 1; fi
grep -F 'サービスの設定に image がない' "$TEST_DIR/result" >/dev/null
echo 'ok: template に image がない場合は失敗する'

jq -n '{
  spec: {traffic: [
    {revisionName: "maintenance-serving", percent: 100, tag: "keep"},
    {revisionName: "old-normal", percent: 0, tag: "r-old"}
  ]},
  status: {traffic: [
    {revisionName: "maintenance-serving", percent: 100, tag: "keep"},
    {revisionName: "old-normal", percent: 0, tag: "r-old"}
  ]}
}' >"$TEST_DIR/service.json"
jq -n '[
  {metadata: {name: "maintenance-serving"}},
  {metadata: {name: "old-normal"}},
  {metadata: {name: "ancient"}}
]' >"$TEST_DIR/revisions.json"
: >"$TEST_DIR/calls"
rm -f "$TEST_DIR/owner-present"
bash "$SCRIPT_DIR/deploy.sh" wait-owner-released >"$TEST_DIR/result" 2>&1
assert_call '--to-revisions=maintenance-serving=100'
assert_call '--remove-tags=r-old'
assert_call 'revisions delete old-normal'
assert_call 'revisions delete ancient'
if grep -F 'revisions delete maintenance-serving' "$TEST_DIR/calls" >/dev/null; then
  echo 'トラフィックを受けているリビジョンを削除した' >&2
  exit 1
fi
if grep -F 'remove-tags=keep' "$TEST_DIR/calls" >/dev/null || grep -F 'keep,r-old' "$TEST_DIR/calls" >/dev/null; then
  echo '受けているリビジョンのタグを外した' >&2
  exit 1
fi
remove_line="$(grep -n -F 'remove-tags=r-old' "$TEST_DIR/calls" | head -1 | cut -d: -f1)"
delete_line="$(grep -n -F 'revisions delete old-normal' "$TEST_DIR/calls" | head -1 | cut -d: -f1)"
if [ "$remove_line" -ge "$delete_line" ]; then
  echo 'タグを外す前にリビジョンを削除した' >&2
  exit 1
fi
grep -F '所有権は解放されている' "$TEST_DIR/result" >/dev/null
echo 'ok: トラフィックのないリビジョンだけを、タグを外してから削除する'

: >"$TEST_DIR/calls"
touch "$TEST_DIR/owner-present"
if OWNER_WAIT_SECONDS=0 bash "$SCRIPT_DIR/deploy.sh" wait-owner-released >"$TEST_DIR/result" 2>&1; then
  echo '所有権が残っているのに成功した' >&2
  exit 1
fi
grep -F 'generation 99' "$TEST_DIR/result" >/dev/null
grep -F 'トラフィックのないリビジョンは削除済み' "$TEST_DIR/result" >/dev/null
assert_call 'revisions delete old-normal'
rm -f "$TEST_DIR/owner-present"
echo 'ok: 削除後も所有権が残る場合は手動解除を案内して失敗する'

jq -n '{spec: {traffic: [{revisionName: "idle", percent: 0}]}, status: {traffic: []}}' >"$TEST_DIR/service.json"
: >"$TEST_DIR/calls"
if bash "$SCRIPT_DIR/deploy.sh" wait-owner-released >"$TEST_DIR/result" 2>&1; then
  echo '受けているリビジョンがないのに成功した' >&2
  exit 1
fi
grep -F 'トラフィックを受けているリビジョンが特定できない' "$TEST_DIR/result" >/dev/null
if grep -F 'revisions delete' "$TEST_DIR/calls" >/dev/null; then
  echo '受けているリビジョンが特定できないのに削除した' >&2
  exit 1
fi
echo 'ok: 受けているリビジョンが特定できないときは削除しない'
