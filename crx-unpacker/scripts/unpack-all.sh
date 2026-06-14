#!/usr/bin/env bash
# Full pipeline: download + strip + unpack Chrome extension
# Usage: ./unpack-all.sh <extension_id | chrome_web_store_url> [output_dir]
set -e

# Parse input — accepts either extension ID or full Chrome Web Store URL
INPUT="${1:?Usage: $0 <extension_id_or_url> [output_dir]}"
if [[ "$INPUT" =~ /detail/ ]]; then
  EXT_ID=$(echo "$INPUT" | grep -oP '/detail/[^/]+/\K[a-p]{32}')
else
  EXT_ID="$INPUT"
fi
[[ ${#EXT_ID} -eq 32 ]] || { echo "Invalid extension ID: $EXT_ID"; exit 1; }

OUT_DIR="${2:-./extension-unpacked}"
UNPACK_DIR="$OUT_DIR/unpacked"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Extension ID: $EXT_ID ==="
echo "=== Output: $OUT_DIR ==="

# Step 1: Download
mkdir -p "$OUT_DIR"
URL="https://clients2.google.com/service/update2/crx?response=redirect&prodversion=130.0&acceptformat=crx3&x=id%3D${EXT_ID}%26installsource%3Dondemand%26uc"
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36"
curl -L -A "$UA" -o "$OUT_DIR/extension.crx" "$URL"
SIZE=$(wc -c < "$OUT_DIR/extension.crx")
echo "[1/3] Downloaded: $SIZE bytes"
[ "$SIZE" -gt 100 ] || { echo "ERROR: download too small ($SIZE bytes) — network may be restricted"; exit 1; }

# Step 2: Strip CRX header
node "$SCRIPT_DIR/strip-crx.js" "$OUT_DIR/extension.crx" "$OUT_DIR/extension.zip"
echo "[2/3] CRX header stripped"

# Step 3: Unzip
mkdir -p "$UNPACK_DIR"
unzip -o "$OUT_DIR/extension.zip" -d "$UNPACK_DIR" > /dev/null

# Cleanup
rm "$OUT_DIR/extension.crx" "$OUT_DIR/extension.zip"

# Report
FILE_COUNT=$(find "$UNPACK_DIR" -type f | wc -l)
TOTAL_SIZE=$(du -sh "$UNPACK_DIR" | cut -f1)
echo "[3/4] Unpacked: $FILE_COUNT files, $TOTAL_SIZE"
echo ""

# Step 4: Deobfuscate with webcrack
DEC_DIR="$OUT_DIR/deobfuscated"
mkdir -p "$DEC_DIR"
JS_FILES=$(find "$UNPACK_DIR" -maxdepth 1 -name "*.js" ! -name "*.min.js" | wc -l)
echo "[4/4] Deobfuscating $JS_FILES JS files with webcrack..."
DECO_COUNT=0
for f in "$UNPACK_DIR"/*.js; do
  [ -f "$f" ] || continue
  name=$(basename "$f")
  npx webcrack "$f" -o "$DEC_DIR/$name" 2>/dev/null || true
  if [ -f "$DEC_DIR/$name/deobfuscated.js" ]; then
    cp "$DEC_DIR/$name/deobfuscated.js" "$DEC_DIR/${name%.js}.dec.js"
    rm -rf "$DEC_DIR/$name"
    DECO_COUNT=$((DECO_COUNT + 1))
  fi
done
echo "        Deobfuscated: $DECO_COUNT files → $DEC_DIR/*.dec.js"
echo ""

# Parse manifest
if [ -f "$UNPACK_DIR/manifest.json" ]; then
  node -e "
    const m = JSON.parse(require('fs').readFileSync('$UNPACK_DIR/manifest.json','utf8'));
    console.log('Name:   ', m.name || '(none)');
    console.log('Version:', m.version || '(none)');
    console.log('BG:     ', m.background?.service_worker || 'none');
    console.log('Popup:  ', m.action?.default_popup || 'none');
    console.log('Options:', m.options_ui?.page || 'none');
    console.log('CS:     ', (m.content_scripts||[]).length + ' scripts');
    console.log('Perms:  ', (m.permissions||[]).join(', '));
  "
fi
echo ""
echo "Done: $UNPACK_DIR"
