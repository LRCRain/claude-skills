# Claude Code Skills Collection

Personal skills repository for Claude Code. Each skill lives in its own subdirectory with `SKILL.md` and bundled scripts.

## Skills

### [crx-unpacker](./crx-unpacker/)
一键下载、解包、反混淆 Chrome 浏览器扩展。接受扩展 ID 或 Chrome Web Store URL，全自动完成：
- 下载 CRX
- 剥离 CRX3 头部
- 解压到 `unpacked/`
- webcrack 反混淆到 `deobfuscated/*.dec.js`

```bash
bash crx-unpacker/scripts/unpack-all.sh <extension_id_or_url> [output_dir]
```

## Install

Clone into your Claude Code skills directory:

```bash
git clone https://github.com/LRCRain/claude-skills.git ~/.claude/skills/claude-skills
```

Or install a single skill by symlinking:

```bash
ln -s "$(pwd)/crx-unpacker" ~/.claude/skills/crx-unpacker
```

## Skill Format

Each skill follows the standard Claude Code skill structure:

```
skill-name/
├── SKILL.md          # YAML frontmatter + instructions
└── scripts/          # Executable helpers
```
