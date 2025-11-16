#!/usr/bin/env bash
set -euo pipefail

# Copy single logo asset (assets/logo.png) to Android mipmap resources so the app uses the same logo
# for launcher, round icon and for the splash screen. Script expects the logo file to be provided by the developer.

project_root="$(cd "$(dirname "$0")/.." && pwd)"
logo_path="${project_root}/assets/logo.png"
res_dir="${project_root}/android/app/src/main/res"

if [ ! -f "${logo_path}" ]; then
  echo "WARN: ${logo_path} not found. Trying to fall back to existing mipmap-xxxhdpi/ic_launcher.png"
  if [ -f "${res_dir}/mipmap-xxxhdpi/ic_launcher.png" ]; then
    mkdir -p "${project_root}/assets"
    cp -v "${res_dir}/mipmap-xxxhdpi/ic_launcher.png" "${logo_path}"
    echo "Created ${logo_path} from existing mipmap-xxxhdpi/ic_launcher.png"
  else
    echo "ERROR: ${logo_path} and fallback mipmap-xxxhdpi/ic_launcher.png not found. Please provide a logo at ${logo_path}."
    exit 2
  fi
fi

for density in mdpi hdpi xhdpi xxhdpi xxxhdpi; do
  mipmap_dir="${res_dir}/mipmap-${density}"
  if [ -d "${mipmap_dir}" ]; then
    # Backup existing icons
    if [ -f "${mipmap_dir}/ic_launcher.png" ] && [ ! -f "${mipmap_dir}/ic_launcher_backup.png" ]; then
      cp -v "${mipmap_dir}/ic_launcher.png" "${mipmap_dir}/ic_launcher_backup.png"
    fi
    if [ -f "${mipmap_dir}/ic_launcher_round.png" ] && [ ! -f "${mipmap_dir}/ic_launcher_round_backup.png" ]; then
      cp -v "${mipmap_dir}/ic_launcher_round.png" "${mipmap_dir}/ic_launcher_round_backup.png" || true
    fi

    # Copy current logo as launcher icons
    cp -v "${logo_path}" "${mipmap_dir}/ic_launcher.png"
    cp -v "${logo_path}" "${mipmap_dir}/ic_launcher_round.png"
    # also copy foreground named file used by adaptive icons
    cp -v "${logo_path}" "${mipmap_dir}/ic_launcher_foreground.png"
  fi
done

echo "Updated launcher icons using ${logo_path}.\nRun 'flutter clean' and rebuild the app to pick up new icons."
