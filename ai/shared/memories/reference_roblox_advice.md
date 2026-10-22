---
name: reference_roblox_advice
description: Any Roblox game: read curated tips in ~/IdeaProjects/blos/game-references/advice/ (INDEX.txt first) and reuse its reference folders; drop new finds in its inbox/
metadata:
  type: reference
---

`~/IdeaProjects/blos/game-references/` holds what past Roblox games taught: `advice/` (generic, non-obvious tips, one `.txt` per topic, one line per tip, read `INDEX.txt` first and open only the topic needed) and reference code folders (lobby, server-list, netcode, economy, ui-kit, audio-feel, canvas-fx, playtest-bots, npc-clerk, lune-tools, dev-toolchain). The master `README.md` lists them.

**Why:** the owner wants future Roblox games to go smoothly without relearning engine gotchas or rebuilding systems. Agents used to keep finds only in code comments, so nothing new reached it for three weeks.

**How to apply:**
- Read: the user hook `ai/claude/hooks/roblox_advice_router.py` names topic files from prompt keywords (`--selftest`; add phrases to its TOPICS table for a new topic file). Check the matching file before building a Roblox system. A second user hook, `roblox_tip_router.py` (PostToolUse Write|Edit), shows a tip when written Luau uses an API that the tip names in backticks.
- Write during work: low bar. A generic gotcha or a copyable system goes in `game-references/inbox/<YYYY-MM-DD>-<repo>-<topic>.md` (format in `inbox/README.md`). The hook `roblox_inbox_nudge.py` reminds on `git commit` in a Roblox repo.
- Harvest: the `roblox-harvest` skill verifies inbox and repo finds and writes `advice/` (only tips confirmed by Roblox docs or running code; no game rules, no opinions). Advice lines are lean: no frontmatter, cite a file basename, no line numbers, no em-dashes.
- Whenever anything is added to `game-references/`, bump the `Last updated: <YYYY-MM-DD>, <repo> @ <sha>` line at the top of its `README.md`, so the next harvest knows where to start.

Related: [[project_arcade_seats_ledger]].
