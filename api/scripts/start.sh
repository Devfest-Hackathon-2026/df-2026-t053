#!/usr/bin/env bash
# コンテナの supervisor。docs/specs.md「writer所有権と起動順序」「停止と再起動」に従う。
#
# 起動: 所有権取得 → GCS から新しい領域へ復元 → DB 検証 → Litestream → Serverpod
# 終了: Serverpod 停止（受付停止・DB 接続を閉じる）→ Litestream 停止 → 所有権解放
#
# コンテナ内では mise に依存しない。
set -uo pipefail

APP=/app
DB_PATH=/data/db.sqlite
RESTORE_DIR=/data/restore
OWNER_FILE=/tmp/writer-owner.json
LITESTREAM_CONFIG="${LITESTREAM_CONFIG:-$APP/config/litestream.yml}"
# 既定値は仕様書「設定値」のとおり。Litestream の設定と Serverpod にも同じ値を渡す。
export LITESTREAM_SOCKET_PATH="${LITESTREAM_SOCKET_PATH:-/var/run/litestream.sock}"
SOCKET="$LITESTREAM_SOCKET_PATH"
RESTORE_TIMEOUT="${RESTORE_TIMEOUT_SECONDS:-120}"
SYNC_READY_TIMEOUT="${SYNC_READY_TIMEOUT_SECONDS:-30}"
# Cloud Run の終了猶予は 10 秒。Serverpod と Litestream の停止待ちの合計をそれより短くする。
SERVER_STOP_TIMEOUT="${SERVER_STOP_TIMEOUT_SECONDS:-3}"
LITESTREAM_STOP_TIMEOUT="${LITESTREAM_STOP_TIMEOUT_SECONDS:-5}"

OPS="$APP/ops/bin/ops"
SERVER="$APP/main/bin/main"

litestream_pid=""
litestream_stuck=0
server_pid=""
restore_pid=""

log() { echo "start.sh: $*"; }

# Litestream を止める。猶予内に止まらなければ、アップロードが残っている可能性があるので
# 所有権を解放せずに終わる（TTL や時刻で奪わない。運用者が旧プロセスの停止を確認して解除する）。
stop_litestream() {
  if [ -n "$litestream_pid" ] && kill -0 "$litestream_pid" 2>/dev/null; then
    log "Litestream を停止する（アップロードの終了を待つ）"
    kill -TERM "$litestream_pid" 2>/dev/null
    local waited=0
    while kill -0 "$litestream_pid" 2>/dev/null; do
      if [ "$waited" -ge $((LITESTREAM_STOP_TIMEOUT * 2)) ]; then
        log "Litestream が猶予内に止まらなかった。所有権は解放しない"
        litestream_stuck=1
        return
      fi
      sleep 0.5
      waited=$((waited + 1))
    done
    wait "$litestream_pid" 2>/dev/null
  fi
  litestream_pid=""
}

release_owner() {
  if [ "$litestream_stuck" = 1 ]; then
    log "所有権が残る。旧プロセスの停止を確認してから手動で解除する"
    return
  fi
  # 所有権の有無は、取得に成功したときだけ書かれる OWNER_FILE で判断する。
  # 取得中に SIGTERM を受けても（トラップは取得の完了後に動く）、取れていれば解放できる。
  if [ -f "$OWNER_FILE" ]; then
    if "$OPS" owner release --file "$OWNER_FILE"; then
      rm -f "$OWNER_FILE"
    else
      # 自動で奪い返さない。運用者が旧プロセスの停止を確認して解除する（#34 の runbook）。
      log "所有権を解放できなかった。残ったままになる"
    fi
  fi
}

# 終了処理。子プロセスを止めてから、最後に所有権を解放する。
cleanup() {
  if [ -n "$restore_pid" ] && kill -0 "$restore_pid" 2>/dev/null; then
    kill -TERM "$restore_pid" 2>/dev/null
    wait "$restore_pid" 2>/dev/null
  fi
  if [ -n "$server_pid" ] && kill -0 "$server_pid" 2>/dev/null; then
    kill -TERM "$server_pid" 2>/dev/null
    local waited=0
    while kill -0 "$server_pid" 2>/dev/null; do
      if [ "$waited" -ge $((SERVER_STOP_TIMEOUT * 2)) ]; then
        # 応答前の要求は成功扱いにならない。commit 済みの WAL は Litestream が続けて複製する。
        log "Serverpod が猶予内に止まらないため強制終了する"
        kill -KILL "$server_pid" 2>/dev/null
        break
      fi
      sleep 0.5
      waited=$((waited + 1))
    done
    wait "$server_pid" 2>/dev/null
  fi
  stop_litestream
  release_owner
}

on_term() {
  log "SIGTERM を受けた"
  cleanup
  exit 143
}
trap on_term TERM INT

export SERVERPOD_API_SERVER_PORT="${PORT:-8080}"

start_maintenance() {
  # 保守応答だけを返す。所有権・復元・複製は行わず、業務 DB も開かない。
  local reason="$1"
  log "保守モードで起動する reason=$reason"
  export MAINTENANCE_MODE=true MAINTENANCE_REASON="$reason"
  export SERVERPOD_DATABASE_FILE_PATH=/tmp/maintenance.sqlite
  "$SERVER" --mode=production --role=serverless &
  server_pid=$!
  wait "$server_pid"
  exit $?
}

if [ "${MAINTENANCE_MODE:-}" = "true" ]; then
  start_maintenance "${MAINTENANCE_REASON:-MAINTENANCE}"
fi

# 1. 設定を検証し、writer 所有権を取得する。取れなければ DB を開かずに終了する。
for required in DB_REPLICA_BUCKET DB_REPLICA_PREFIX DB_WRITER_OWNER_OBJECT RELEASE_ID; do
  if [ -z "${!required:-}" ]; then
    log "必須の設定がない: $required"
    exit 2
  fi
done
mkdir -p /data "$(dirname "$SOCKET")"

# 同じコンテナの再起動では /tmp が残る。前回の所有権ファイルで他人の所有権を触らない。
rm -f "$OWNER_FILE"
if ! "$OPS" owner acquire --out "$OWNER_FILE"; then
  log "writer 所有権を取得できないため起動しない"
  exit 20
fi

# 2. 新しい領域へ復元する。失敗しても同梱 DB や空 DB へ置き換えない。
# Litestream のメタデータは /data/.db.sqlite-litestream（先頭にドット）。前回の位置情報を
# 残したまま復元した DB を複製しないよう、一緒に消す。
rm -rf "$RESTORE_DIR" "$DB_PATH" "$DB_PATH-wal" "$DB_PATH-shm" \
  "$(dirname "$DB_PATH")/.$(basename "$DB_PATH")-litestream"
mkdir -p "$RESTORE_DIR"
log "GCS から復元する"
# 前面で実行すると、bash は終わるまで SIGTERM のトラップを遅らせる。復元が長引いたときに
# 所有権を解放できないので、背景で実行して wait する（wait はシグナルで中断される）。
timeout "$RESTORE_TIMEOUT" litestream restore -config "$LITESTREAM_CONFIG" \
  -o "$RESTORE_DIR/db.sqlite" "$DB_PATH" &
restore_pid=$!
wait "$restore_pid"
restore_status=$?
restore_pid=""
if [ "$restore_status" != 0 ]; then
  log "復元に失敗した（認証・権限・通信・レプリカ破損のいずれか）"
  rm -rf "$RESTORE_DIR"
  release_owner
  exit 30
fi

# 3. 整合性・外部キー・スキーマ版を照合する。初回 DB の作成はここでは行わない。
"$OPS" verify-db --db "$RESTORE_DIR/db.sqlite" --migrations "$APP/migrations"
verify=$?
case "$verify" in
  0) ;;
  10 | 11)
    # 書き込み・複製を始めず、所有権を解放して保守扱いにする。
    rm -rf "$RESTORE_DIR"
    release_owner
    if [ "$verify" = 10 ]; then start_maintenance MAINTENANCE; else start_maintenance SCHEMA_TOO_NEW; fi
    ;;
  *)
    log "復元した DB を使えない"
    rm -rf "$RESTORE_DIR"
    release_owner
    exit 31
    ;;
esac
mv "$RESTORE_DIR/db.sqlite" "$DB_PATH"
rm -rf "$RESTORE_DIR"

# 4. Litestream を起動し、IPC socket と DB の同期機能が使えるまで待つ。
log "Litestream を起動する"
litestream replicate -config "$LITESTREAM_CONFIG" &
litestream_pid=$!

ready=0
for _ in $(seq 1 "$SYNC_READY_TIMEOUT"); do
  if ! kill -0 "$litestream_pid" 2>/dev/null; then break; fi
  if [ -S "$SOCKET" ] && "$OPS" sync --socket "$SOCKET" --db "$DB_PATH" --timeout 5 2>/dev/null; then
    ready=1
    break
  fi
  sleep 1
done
if [ "$ready" != 1 ]; then
  log "Litestream の同期機能が使えない"
  cleanup
  exit 32
fi

# 5. Serverpod を起動する。ここから業務要求を受け付ける。
log "Serverpod を起動する"
"$SERVER" --mode=production --role=serverless &
server_pid=$!

# どちらかが終了したら、もう片方を止めて後片付けする。
wait -n "$server_pid" "$litestream_pid"
status=$?
if kill -0 "$server_pid" 2>/dev/null; then
  log "Litestream が止まったため Serverpod を止める"
  status=33
fi
cleanup
exit "$status"
