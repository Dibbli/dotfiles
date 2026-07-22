# AI coding configuration

This directory is the canonical source for personal configuration shared by Claude Code and Codex.

```text
ai/
  shared/   memories and portable support code
  claude/   Claude Code agents, skills, workflows, and hook adapter
  codex/    Codex hook adapter and future Codex-only assets
```

## Memory behavior

Public memories live in `ai/shared/memories/`. Private memories remain local in `~/.claude/memory-shared-private/`.

Claude Code keeps its native behavior: the SessionStart hook symlinks public memories into each `~/.claude/projects/<project>/memory/`, deduplicates only private memories already present there, and maintains `MEMORY.md`.

Codex receives an equivalent symlink projection under `~/.local/share/ai-memory/codex/<project>/`. Its SessionStart hook injects only the index and projected directory path, leaving full memory files to be read on demand. Codex's generated `~/.codex/memories/` store is separate and untouched.

## Hook setup

Claude Code command for `~/.claude/settings.json`:

```json
"command": "python3 \"$HOME/Documents/dotfiles/ai/claude/hooks/session_start.py\""
```

Codex command for `~/.codex/hooks.json`:

```json
"command": "python3 '/home/dibbli/Documents/dotfiles/ai/codex/hooks/session_start.py'"
```

Backfill Claude projects and repair managed asset links:

```sh
python3 ~/Documents/dotfiles/ai/claude/hooks/session_start.py --all
python3 ~/Documents/dotfiles/ai/shared/lib/provision_assets.py
```

The provisioners are idempotent and use file-level symlinks. Plugin-managed Ponytail and Superpowers files are not copied or modified here.
