---
name: crx-unpacker
description: >-
  Download and unpack Chrome extensions (CRX files) from the Chrome Web Store.
  Use this skill whenever the user wants to download a Chrome extension, analyze
  extension source code, unpack a CRX file, extract extension code, or examine
  a Chrome extension's internals. Triggers on: CRX, Chrome extension download,
  Chrome Web Store URL, extension ID, 解包, 拆包, 浏览器插件/扩展分析.
---

# CRX Unpacker

Download and unpack any Chrome extension to readable source code.

## Quick Start — One Command

```bash
bash scripts/unpack-all.sh <extension_id_or_url> [output_dir]
```

Accepts either a 32-char extension ID or a full Chrome Web Store URL.
Outputs to `./extension-unpacked/unpacked/` by default.

**Example:**
```bash
bash scripts/unpack-all.sh fhdmbhgpabjkadpaafomaabbdckofphm ./my-extension
```

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/unpack-all.sh` | **All-in-one**: download → strip CRX → unzip → deobfuscate → report |
| `scripts/download-crx.sh <id> [dir]` | Download only |
| `scripts/strip-crx.js <input.crx> [output.zip]` | Strip CRX3 header to plain ZIP |
| `scripts/deobfuscate.sh <dir> [out]` | Run webcrack on all JS files |

## Manual Steps (if scripts fail)

**Download:**
```bash
curl -L -A "Mozilla/5.0 ... Chrome/130.0.0.0 Safari/537.36" \
  -o extension.crx \
  "https://clients2.google.com/service/update2/crx?response=redirect&prodversion=130.0&acceptformat=crx3&x=id%3D<ID>%26installsource%3Dondemand%26uc"
```

**Strip header + unzip:**
```bash
node scripts/strip-crx.js extension.crx extension.zip
unzip extension.zip -d unpacked/
```

## Pipeline Output

After running `unpack-all.sh`, the output directory contains:

```
output_dir/
├── unpacked/              # Raw extension files (minified)
└── deobfuscated/          # webcrack-deobfuscated *.dec.js
    ├── background.js.dec.js
    ├── content-script.js.dec.js
    └── ...
```

## Deobfuscation Notes

webcrack can partially reverse minification:
- **Can**: Expand variable names, unwrap ternaries, format code
- **Cannot**: Recover original names, comments, or file structure (these are permanently lost in minification)

To run deobfuscation separately:
```bash
bash scripts/deobfuscate.sh unpacked/ output_dir/
```

## After Unpacking — Report

Always report to the user:
- Extension name and version (from manifest.json)
- Entry points: service worker, content scripts, popup, options, side panel
- Permissions list
- File count and total size
