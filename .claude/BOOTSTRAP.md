# Shared Claude memory + assets — new machine setup

This repo carries two kinds of shared Claude config and the provisioners that install them:
- **Per-project memories** (`.claude/memory-shared/`) via `provision_shared_memories.py` — symlinked into each `~/.claude/projects/<proj>/memory/`.
- **System-wide assets** — skills (`.claude/skills/`), agents (`.claude/agents/`), workflows (`.claude/workflows/`) — via `provision_global_assets.py`, symlinked into `~/.claude/{skills,agents,workflows}/`.

To bring a fresh machine up to speed:

## 1. Clone dotfiles to the expected path
Both provisioners expect this repo at `~/Documents/dotfiles`. If you keep it elsewhere,
edit the path constants near the top of each script.

## 2. Register the SessionStart hooks
Add this to `~/.claude/settings.json` (merge into an existing `hooks` block if present):

```json
"hooks": {
  "SessionStart": [
    { "hooks": [
      { "type": "command",
        "command": "python3 \"$HOME/Documents/dotfiles/.claude/hooks/provision_shared_memories.py\"",
        "timeout": 30, "statusMessage": "Provisioning shared memories" },
      { "type": "command",
        "command": "python3 \"$HOME/Documents/dotfiles/.claude/hooks/provision_global_assets.py\"",
        "timeout": 30, "statusMessage": "Provisioning skills, agents, workflows" }
    ] }
  ]
}
```
Then open `/hooks` once (or restart) so the config reloads. The assets provisioner is
cwd-independent and idempotent, so it can also be run once by hand:
```bash
python3 ~/Documents/dotfiles/.claude/hooks/provision_global_assets.py
```

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
The symlinks under `~/.claude/projects/*/memory/` and the asset symlinks under
`~/.claude/{skills,agents,workflows}/` are not synced; the provisioners recreate them
from the canonical dirs on each machine. Only the canonical dirs + the two scripts +
the hook entries need to be present.
