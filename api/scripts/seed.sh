#!/usr/bin/env bash
# 出題の seed（#26）を、API と同じ writer 所有権の規則で実行する。
# 本番の Cloud Run Job としての実行方法・runbook は #34 で整える。
# 所有権・復元・Litestream の扱いは start.sh と同じ規則にする（共通化は #34 で検討する）。
#
#   1. writer 所有権を取得する（稼働中の API があれば取れずに終了する）
#   2. レプリカから新しい領域へ復元し、整合性とスキーマ版を検証する
#   3. Litestream を起動する
#   4. seed CLI（bin/seed.dart）で書き込む
#   5. 書き込みの複製完了を POST /sync で確認する
#   6. Litestream を止め、所有権を解放する
#
# 複製を確認できないまま終わるとき（失敗・SIGTERM）は、所有権を解放しない。次の api が
# seed の書き込みを含まないレプリカから復元しないよう、運用者が確認してから解除する
# （`ops owner show` / `ops owner clear --generation N`）。
#
# 使い方: seed.sh <seed CLI のコマンドと引数>（--db は付けない。/data/db.sqlite を渡す）
#   seed.sh load --dir /content/seeds/uk-pavilion/r5 --publish true
#   seed.sh publish --slug uk-pavilion --revision 5
# verify は DB を開かないので、所有権を取らずにそのまま実行する。
set -uo pipefail

APP=/app
DB_PATH=/data/db.sqlite
RESTORE_DIR=/data/restore
OWNER_FILE=/tmp/writer-owner.json
LITESTREAM_CONFIG="${LITESTREAM_CONFIG:-$APP/config/litestream.yml}"
export LITESTREAM_SOCKET_PATH="${LITESTREAM_SOCKET_PATH:-/var/run/litestream.sock}"
SOCKET="$LITESTREAM_SOCKET_PATH"
RESTORE_TIMEOUT="${RESTORE_TIMEOUT_SECONDS:-120}"
# 停止の猶予（compose・Cloud Run は 10 秒）に、終了時の同期と Litestream の停止待ちを収める。
FINAL_SYNC_TIMEOUT="${FINAL_SYNC_TIMEOUT_SECONDS:-3}"
LITESTREAM_STOP_TIMEOUT="${LITESTREAM_STOP_TIMEOUT_SECONDS:-5}"
OPS="$APP/ops/bin/ops"
SEED="$APP/seed/bin/seed"

litestream_pid=""
child_pid=""
# seed CLI を動かした後、複製をまだ確認できていない（コミット済みの書き込みがあり得る）。
unconfirmed=0
keep_owner=0

log() { echo "seed.sh: $*"; }

if [ "$#" -lt 1 ]; then
  log "seed CLI のコマンドを指定する（例: load --dir DIR --publish true）"
  exit 1
fi
if [ "$1" = "verify" ]; then
  exec "$SEED" "$@"
fi

# 子プロセスを背景で動かして待つ。前面で実行すると、bash は終わるまで SIGTERM の
# トラップを遅らせ、停止の猶予内に後片付けできない（wait はシグナルで中断される）。
run_child() {
  "$@" &
  child_pid=$!
  wait "$child_pid"
  local status=$?
  child_pid=""
  return "$status"
}

stop_child() {
  if [ -n "$child_pid" ] && kill -0 "$child_pid" 2>/dev/null; then
    # seed CLI が書き込み中なら、コミットしていないトランザクションは取り消される。
    kill -TERM "$child_pid" 2>/dev/null
    wait "$child_pid" 2>/dev/null
  fi
  child_pid=""
}

# 後片付け（トラップの中）から呼ぶ同期の確認。
sync_once() {
  "$OPS" sync --socket "$SOCKET" --db "$DB_PATH" --timeout "$1"
}

# 本体の流れから呼ぶ同期の確認。SIGTERM で中断できるよう背景で実行する。
sync_wait() {
  run_child "$OPS" sync --socket "$SOCKET" --db "$DB_PATH" --timeout "$1"
}

# Litestream を止める。猶予内に止まらなければ、アップロードが残っている可能性があるので
# 所有権を残す（start.sh と同じ）。
stop_litestream() {
  if [ -n "$litestream_pid" ] && kill -0 "$litestream_pid" 2>/dev/null; then
    kill -TERM "$litestream_pid" 2>/dev/null
    local waited=0
    while kill -0 "$litestream_pid" 2>/dev/null; do
      if [ "$waited" -ge $((LITESTREAM_STOP_TIMEOUT * 2)) ]; then
        log "Litestream が猶予内に止まらなかった"
        keep_owner=1
        return
      fi
      sleep 0.5
      waited=$((waited + 1))
    done
    wait "$litestream_pid" 2>/dev/null
  fi
  litestream_pid=""
}

cleanup() {
  # 後片付けの途中で届いたシグナルで、後片付けそのものを打ち切らない。
  trap '' TERM INT
  stop_child
  # 途中で終わる（SIGTERM など）ときも、コミット済みの書き込みの複製を一度だけ確かめる。
  if [ "$unconfirmed" = 1 ] && [ -n "$litestream_pid" ] && sync_once "$FINAL_SYNC_TIMEOUT"; then
    unconfirmed=0
  fi
  stop_litestream
  if [ "$unconfirmed" = 1 ] || [ "$keep_owner" = 1 ]; then
    log "複製を確認できていないため、所有権を残す。レプリカを確認してから解除する（ops owner show / ops owner clear --generation N）"
    return
  fi
  if [ -f "$OWNER_FILE" ]; then
    "$OPS" owner release --file "$OWNER_FILE" && rm -f "$OWNER_FILE"
  fi
}
trap cleanup EXIT
# EXIT のトラップが後片付けをする。PID 1 の bash はトラップのないシグナルを無視するので必須。
trap 'log "シグナルを受けた"; exit 143' TERM INT

mkdir -p /data "$(dirname "$SOCKET")"

rm -f "$OWNER_FILE"
if ! "$OPS" owner acquire --out "$OWNER_FILE"; then
  log "writer 所有権を取得できない。稼働中の api を止めてから実行する"
  exit 20
fi

rm -rf "$RESTORE_DIR" "$DB_PATH" "$DB_PATH-wal" "$DB_PATH-shm" \
  "$(dirname "$DB_PATH")/.$(basename "$DB_PATH")-litestream"
mkdir -p "$RESTORE_DIR"
log "レプリカから復元する"
if ! run_child timeout "$RESTORE_TIMEOUT" litestream restore -config "$LITESTREAM_CONFIG" \
  -o "$RESTORE_DIR/db.sqlite" "$DB_PATH"; then
  log "復元に失敗した（DB が未作成なら先に migrate を実行する）"
  exit 30
fi
if ! "$OPS" verify-db --db "$RESTORE_DIR/db.sqlite" --migrations "$APP/migrations"; then
  log "復元した DB を使えない（スキーマ版が合わなければ migrate を先に実行する）"
  exit 31
fi
mv "$RESTORE_DIR/db.sqlite" "$DB_PATH"
rm -rf "$RESTORE_DIR"

log "Litestream を起動する"
litestream replicate -config "$LITESTREAM_CONFIG" &
litestream_pid=$!
ready=0
for _ in $(seq 1 30); do
  if [ -S "$SOCKET" ] && sync_wait 5 2>/dev/null; then
    ready=1
    break
  fi
  sleep 1
done
if [ "$ready" != 1 ]; then
  log "Litestream の同期機能が使えない"
  exit 32
fi

unconfirmed=1
run_child "$SEED" "$@" --db "$DB_PATH"
status=$?

# 成否にかかわらず、コミット済みの書き込みが GCS（ローカルは volume）に複製されたことを
# 確かめてから終える。失敗した操作はトランザクションごと取り消されるが、素材の配置のように
# 失敗の前に済んだ書き込みや、その前に成功した操作があり得るため、失敗でも確認を省かない。
for _ in $(seq 1 10); do
  if sync_wait 10; then
    unconfirmed=0
    log "複製を確認した"
    exit "$status"
  fi
  sleep 1
done
log "複製を確認できなかった"
exit 43
