---
name: roblox-harvest
description: Use when the owner asks to harvest, update or sweep ~/IdeaProjects/blos/game-references (Roblox tips in advice/, reference code folders, the inbox/ drop zone). Writes and deletes in game-references, so it runs only through /roblox-harvest.
disable-model-invocation: true
---

# Roblox harvest

Move what a Roblox repo learned since the last harvest into `~/IdeaProjects/blos/game-references/`.
Sonnet agents gather; the main session decides and writes. Agents never run tests or checks.

## 1. Start point
- Read the `Last updated: <date>, <repo> @ <sha>` line at the top of `game-references/README.md`.
- `git log --oneline <sha>..HEAD` plus `git status` in the repo. List `inbox/`.

## 2. Gather (parallel Sonnet agents, each writes one scratchpad file)
- Commit slices: one agent per ~10 commits (diff + comments added). Each lists candidate tips:
  `topic | tip | path:line | why not obvious`. Brief them with the bar in step 3 and the topic list in
  `advice/INDEX.txt`, and tell them to grep `advice/` first and mark duplicates.
- Transcript miner: session files since the start date in `~/.claude*/projects/<repo-slug>/` (main and
  `subagents/`). Look for "turns out", "Roblox does", "gotcha", reverts, comments citing docs.
- Inbox: one agent per few `inbox/` files; each turns notes into the same candidate format.
- Extraction survey: one agent compares each reference folder to the repo (drift, files gone) and
  lists new systems another game could copy (coupling, tests, Studio status). Verdicts: REFRESH,
  EXTRACT, SKIP, ADVICE-ONLY.

## 3. Verify, then write
- One verifier agent checks every candidate against Roblox docs (docs MCP, create.roblox.com) and the
  cited code: CONFIRMED, CONTRADICTED, UNVERIFIABLE, DUPLICATE.
- Write only CONFIRMED tips, or UNVERIFIABLE ones that running code plainly proves. The bar: generic to
  any Roblox game, not obvious, confirmed. Never game rules, opinions, or untested Studio guesses.
- Ask the owner (AskUserQuestion) which EXTRACT and REFRESH verdicts to act on, then one Sonnet
  agent per folder copies files verbatim and updates that folder's README (source line
  `<repo> <sha> + working tree <date>`, what it is, deps not copied, untested parts).

## 4. Advice file format (keep it lean, every routed read costs tokens)
- `advice/<topic>.txt`: no frontmatter, one line per tip, no em-dashes.
- Line: `- <what Roblox does>. <the fix>. (<File.luau>)`, the cite is a basename to grep in the source
  repo (`<repo>:<File>` when it is not buckler); no line numbers, they drift.
- Put each Roblox API name in backticks (`FilterStringAsync`): the hook `roblox_tip_router.py` shows a
  tip when written Luau uses an API it names. Run it with `--selftest`.
- A new topic file needs an `INDEX.txt` line and phrases in the `TOPICS` table of
  `~/Documents/dotfiles/ai/claude/hooks/roblox_advice_router.py`; run it with `--selftest`.
- Merge into an existing line before adding a new one. Cut a tip that newer engine docs contradict.

## 5. Close
- Update `game-references/README.md` rows, and bump `Last updated` to today and the repo HEAD sha.
- Delete the processed `inbox/` files.
- Report to the owner: tips added and rejected (with why), folders refreshed and extracted, anything
  that needs an owner check in Studio.
