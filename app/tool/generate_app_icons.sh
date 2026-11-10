#!/usr/bin/env bash
# 承認済み原本から、既存の Android／iOS アイコンをサイズごとに生成する。
set -euo pipefail

app_dir="$(cd "$(dirname "$0")/.." && pwd)"
source_image="$app_dir/../design/branding/app-icon.png"

if ! command -v sips >/dev/null 2>&1; then
  echo "アイコン生成には macOS の sips が必要です。" >&2
  exit 1
fi
if [[ ! -f "$source_image" ]]; then
  echo "アイコン原本がありません: $source_image" >&2
  exit 1
fi

while read -r density pixels; do
  sips -z "$pixels" "$pixels" "$source_image" \
    --out "$app_dir/android/app/src/main/res/mipmap-$density/ic_launcher.png" >/dev/null
done <<'SIZES'
mdpi 48
hdpi 72
xhdpi 96
xxhdpi 144
xxxhdpi 192
SIZES

for icon in "$app_dir"/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-*.png; do
  filename="${icon##*/}"
  points="${filename#Icon-App-}"
  points="${points%%x*}"
  scale="${filename##*@}"
  scale="${scale%x.png}"
  pixels="$(awk -v points="$points" -v scale="$scale" 'BEGIN { printf "%d", points * scale }')"
  sips -z "$pixels" "$pixels" "$source_image" --out "$icon" >/dev/null
done

echo "Android／iOS のアイコンを生成しました。"
