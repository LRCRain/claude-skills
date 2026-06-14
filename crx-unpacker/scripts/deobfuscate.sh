#!/usr/bin/env bash
# Deobfuscate all JS files in a directory using webcrack
# Usage: ./deobfuscate.sh <unpacked_dir> [output_dir]
set -e
SRC="${1:?Usage: $0 <unpacked_dir> [output_dir]}"
OUT="${2:-$SRC/deobfuscated}"
mkdir -p "$OUT"

echo "=== Deobfuscating JS files in $SRC ==="
COUNT=0
for f in "$SRC"/*.js; do
  name=$(basename "$f")
  echo "  $name ..."
  npx webcrack "$f" -o "$OUT/$name" 2>&1 | grep "finished with" || true
  # Flatten: webcrack outputs to dir/deobfuscated.js, copy to flat .dec.js
  if [ -f "$OUT/$name/deobfuscated.js" ]; then
    cp "$OUT/$name/deobfuscated.js" "$OUT/${name%.js}.dec.js"
    rm -rf "$OUT/$name"
  fi
  COUNT=$((COUNT + 1))
done
echo "=== Done: $COUNT files → $OUT/*.dec.js ==="
ls -lh "$OUT"/*.dec.js 2>/dev/null || echo "(no JS files found)"
