#!/usr/bin/env bash
# Download CRX from Chrome Web Store
# Usage: ./download-crx.sh <extension_id> [output_dir]
set -e
EXT_ID="${1:?Usage: $0 <extension_id> [output_dir]}"
OUT_DIR="${2:-./crx-download}"
mkdir -p "$OUT_DIR"
URL="https://clients2.google.com/service/update2/crx?response=redirect&prodversion=130.0&acceptformat=crx3&x=id%3D${EXT_ID}%26installsource%3Dondemand%26uc"
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36"
echo "Downloading $EXT_ID..."
curl -L -A "$UA" -o "$OUT_DIR/extension.crx" "$URL"
SIZE=$(wc -c < "$OUT_DIR/extension.crx")
echo "Downloaded: $OUT_DIR/extension.crx ($SIZE bytes)"
[ "$SIZE" -gt 0 ] || { echo "ERROR: empty download"; exit 1; }
