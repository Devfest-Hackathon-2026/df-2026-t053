#!/usr/bin/env bash
# terradart が使う OpenTofu が、各パッケージの pubspec.yaml の opentofu_version と同じ版か確かめる。
#
# terradart は PATH に tofu があれば、版を確かめずにそれを使う（opentofu_version はダウンロードする
# 版の指定）。別の版で plan・apply しないよう、実行前に止める。mise の engine-check と deploy.sh が使う。
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
for package in bootstrap stack; do
  want="$(sed -n 's/^  opentofu_version: *//p' "$ROOT/$package/pubspec.yaml")"
  engine="$(cd "$ROOT/$package" && PHOTOHUNT_SYNTH_PLACEHOLDER=1 dart run terradart_cli:terradart engine --json)"
  got="$(jq -r '.engine.version // empty' <<<"$engine")"
  path="$(jq -r '.engine.path // empty' <<<"$engine")"
  if [ -z "$want" ] || [ "$got" != "$want" ]; then
    echo "$package: OpenTofu ${got:-不明}（${path:-不明}）が使われる。pubspec.yaml の版は ${want:-未設定}。" >&2
    echo "PATH の tofu を外すか、版を $want に合わせてから実行する。" >&2
    exit 1
  fi
done
echo "ok: OpenTofu $want" >&2
