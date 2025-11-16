#!/usr/bin/env bash
set -euo pipefail

FONT_DIR="$(pwd)/assets/fonts"
mkdir -p "$FONT_DIR"

# Google fonts raw assets from the google/fonts repo
FILES=(
  "https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-Regular.ttf"
  "https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-Medium.ttf"
  "https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-SemiBold.ttf"
  "https://github.com/google/fonts/raw/main/ofl/orbitron/Orbitron-Regular.ttf"
  "https://github.com/google/fonts/raw/main/ofl/orbitron/Orbitron-Bold.ttf"
)

echo "Downloading fonts to $FONT_DIR..."

for url in "${FILES[@]}"; do
  filename=$(basename "$url")
  out="$FONT_DIR/$filename"
  if [ -f "$out" ]; then
    echo "Skipping existing $filename"
    continue
  fi
  echo "Downloading $filename..."
  curl -L -o "$out" "$url"
done

echo "Fonts downloaded. Run: flutter pub get && flutter analyze"