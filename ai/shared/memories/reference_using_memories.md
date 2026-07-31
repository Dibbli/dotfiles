---
name: reference_using_memories
description: How this machine's shared AI memory system is laid out, read when adding, editing, or locating a memory.
metadata:
  type: reference
---
Memories have two scopes: project-local and shared.

**Canonical sources:**
- Public: `~/Documents/dotfiles/ai/shared/memories/`. This repository is public, so never store identifying or sensitive details here.
- Private: `~/.claude/memory-shared-private/`. This remains local and uncommitted.

**Claude Code:** `ai/claude/hooks/session_start.py` symlinks public memories into the current `~/.claude/projects/<project>/memory/`, deduplicates private memories only where a project already had them, and reconciles `MEMORY.md`. Claude loads that project memory directory natively.

**Codex:** `ai/codex/hooks/session_start.py` creates the same symlink projection under `~/.local/share/ai-memory/codex/<project>/` and injects only its `MEMORY.md` index. Codex reads a linked full memory on demand. Its generated `~/.codex/memories/` store is unrelated and must not be hand-managed by these scripts.

Editing a projected symlink edits its canonical file and therefore changes the shared rule everywhere. Use one fact per file with `name`, retrieval-oriented `description`, and `metadata.type` frontmatter. Link related memories as `[[name]]`.
