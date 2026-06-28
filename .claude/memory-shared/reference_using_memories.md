---
name: reference_using_memories
description: How this machine's shared Claude memory system is laid out — read when adding, editing, or wondering where a memory lives.
metadata:
  type: reference
---

Memories on this machine come in two scopes: per-project (local to one repo's memory dir) and SHARED (symlinked into every project from a canonical source).

**Two canonical sources for shared memories:**
- Public: `~/Documents/dotfiles/.claude/memory-shared/` — generic behaviors, committed to a PUBLIC dotfiles repo. NEVER put anything identifying or personal here (names, employers, client/repo names, emails, paths, hostnames, IPs, locale, or personal circumstances).
- Private: `~/.claude/memory-shared-private/` — shared but identifying/sensitive (kept local, never committed).

**How sharing works:** each project's `memory/<name>.md` is a symlink to the canonical file. The loader follows symlinks (reads and writes pass through), so editing a symlinked memory edits the canonical and changes it for EVERY project. That is the intended behavior, not a bug. To change a rule everywhere, edit the file in the canonical dir.

**Provisioning:** `~/Documents/dotfiles/.claude/hooks/provision_shared_memories.py` symlinks the public set into a project and reconciles its `MEMORY.md`. It runs on `SessionStart` (registered in `~/.claude/settings.json`) for new projects, and can be run manually: `--all` (backfill every project) or `--dir <memdir>` (one). Public memories spread to every project; private ones are only deduped where a copy already exists. Files retired by merges/renames are listed in the script's `SUPERSEDED` set and removed on every run. New-machine setup steps are in `~/Documents/dotfiles/.claude/BOOTSTRAP.md`.

**Format (one fact per file):** frontmatter `name` (= filename without `.md`), `description` (a retrieval trigger: "when would I need this", not a restatement), `metadata.type` (user|feedback|project|reference). Body is one atomic fact; feedback/project add `**Why:**` and `**How to apply:**`. No em-dashes, no airy blank lines, no provenance dates or anecdotes. Link related memories with `[[name]]`.

**Only `MEMORY.md` auto-loads** (its index); topic files load on demand, so a shared memory must have a `MEMORY.md` line to be discoverable. The provisioner maintains those lines.
