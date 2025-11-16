#!/usr/bin/env bash
set -euo pipefail

# Generate proper Android launcher icon sizes from a single 512x512 PNG (assets/logo.png)
# Requires ImageMagick's `convert` command.

project_root="$(cd "$(dirname "$0")/.." && pwd)"
logo_path="${project_root}/assets/logo.png"
res_dir="${project_root}/android/app/src/main/res"

if ! command -v convert > /dev/null; then
  echo "ImageMagick 'convert' not found. Please install ImageMagick to use this script."
  exit 2
fi

if [ ! -f "${logo_path}" ]; then
  echo "ERROR: ${logo_path} not found. Add your 512x512 logo to ${logo_path}"
  exit 2
fi

declare -A sizes=(
  [mdpi]=48
  [hdpi]=72
  [xhdpi]=96
  [xxhdpi]=144
  [xxxhdpi]=192
)

for density in "${!sizes[@]}"; do
  size=${sizes[$density]}
  mipmap_dir="${res_dir}/mipmap-${density}"
  mkdir -p "${mipmap_dir}"
  # Convert and write both normal and round icon
  convert "${logo_path}" -resize ${size}x${size} "${mipmap_dir}/ic_launcher.png"
  convert "${logo_path}" -resize ${size}x${size} "${mipmap_dir}/ic_launcher_round.png"
  # Also generate a foreground image used by adaptive icons
  convert "${logo_path}" -resize ${size}x${size} "${mipmap_dir}/ic_launcher_foreground.png"
done

echo "Generated launcher icons from ${logo_path}. Run flutter clean & rebuild the app."
