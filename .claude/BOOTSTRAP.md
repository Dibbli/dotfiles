# Shared Claude memory — new machine setup

This repo carries the **public shared memories** (`.claude/memory-shared/`) and the
**provisioner** (`.claude/hooks/provision_shared_memories.py`). To bring a fresh machine
up to speed:

## 1. Clone dotfiles to the expected path
The provisioner expects this repo at `~/Documents/dotfiles`. If you keep it elsewhere,
edit the `PUBLIC` path near the top of `provision_shared_memories.py`.

## 2. Register the SessionStart hook
Add this to `~/.claude/settings.json` (merge into an existing `hooks` block if present):

```json
"hooks": {
  "SessionStart": [
    { "hooks": [ { "type": "command",
      "command": "python3 \"$HOME/Documents/dotfiles/.claude/hooks/provision_shared_memories.py\"",
      "timeout": 30, "statusMessage": "Provisioning shared memories" } ] }
  ]
}
```
Then open `/hooks` once (or restart) so the config reloads.

## 3. Backfill existing projects (optional)
New projects get provisioned automatically on first session. To wire up projects that
already have memory dirs, run once:
```bash
python3 ~/Documents/dotfiles/.claude/hooks/provision_shared_memories.py --all
```

## Private memories (NOT in this repo)
The private set lives at `~/.claude/memory-shared-private/` and is deliberately never
committed. It does not travel with this public repo. On a personal machine, copy that
directory over by hand (or sync it via a separate private repo). On a shared or
employer-owned machine, leave it off — the provisioner only deduplicates private
memories where a copy already exists, so absence is safe.

## What is machine-local and regenerated
The per-project symlinks under `~/.claude/projects/*/memory/` are not synced; the
provisioner recreates them from the canonical dirs on each machine. Only the canonical
dirs + this script + the hook entry need to be present.
