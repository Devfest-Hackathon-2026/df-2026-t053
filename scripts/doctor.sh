#!/usr/bin/env bash
# 開発環境の整合を検査する。
#  1. api/Dockerfile の ARG DART_VERSION と、mise が使う Dart の版が一致するか
#     （api は api/mise.toml の dart、app は app/mise.toml の Flutter 同梱 dart）
#  2. 各 config root で、PATH 上の dart / flutter が mise のものか
#     （別の dart が PATH の前にあると、タスクが意図しない版で動く）
# 版の確認は `mise which` で得た実体を直接実行するので、PATH の順序に左右されない。
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
docker_version="$(sed -n 's/^ARG DART_VERSION=//p' "$root/api/Dockerfile" | head -n1)"
[[ -n "$docker_version" ]] || { echo "api/Dockerfile に ARG DART_VERSION がない" >&2; exit 1; }

status=0
ok() { echo "ok   $*"; }
ng() { echo "NG   $*" >&2; status=1; }

# mise が選ぶ実体のパス。未導入なら空。
mise_path() { (cd "$root/$1" && mise which "$2" 2>/dev/null) || true; }

# `dart --version` の版だけを取り出す。
version_of() { "$1" --version 2>&1 | sed -n 's/^Dart SDK version: \([0-9][0-9.]*\).*/\1/p'; }

# PATH 上の $2 が mise のものか。mise の shims 経由は、版を mise が解決するので許す。
check_path() {
  local dir="$1" tool="$2" want got
  want="$(mise_path "$dir" "$tool")"
  [[ -n "$want" ]] || { ng "$dir: mise に $tool がない（mise install を実行する）"; return; }
  got="$(cd "$root/$dir" && command -v "$tool" || true)"
  if [[ "$got" == "$want" || "$got" == */mise/shims/"$tool" ]]; then
    ok "$dir の $tool は mise のもの: $got"
  else
    ng "$dir の $tool が mise のものではない: ${got:-（なし）}
     期待: $want
     直し方: ~/.zshrc（bash は ~/.bashrc）で、PATH を変更する行をすべて書いたあとに
             eval \"\$(mise activate zsh)\" を置き、シェルを開き直す。"
  fi
}

check_version() {
  local label="$1" dart_bin="$2" actual
  actual="$(version_of "$dart_bin")"
  if [[ "$actual" == "$docker_version" ]]; then
    ok "$label: $actual"
  else
    ng "$label: ${actual:-不明}（api/Dockerfile の ARG DART_VERSION は $docker_version）"
  fi
}

api_dart="$(mise_path api dart)"
app_flutter="$(mise_path app flutter)"

[[ -n "$api_dart" ]] && check_version "api の dart（api/mise.toml）" "$api_dart" \
  || ng "api: mise に dart がない（mise install を実行する）"
[[ -n "$app_flutter" ]] && check_version "app の Flutter 同梱 dart（app/mise.toml）" "$(dirname "$app_flutter")/dart" \
  || ng "app: mise に flutter がない（mise install を実行する）"

check_path api dart
check_path app flutter
check_path app dart

exit "$status"
