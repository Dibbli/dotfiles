---
name: project_shared_mcp_config
description: Shared MCP servers for all Claude accounts live in ~/.claude/mcp.json, passed by the shell wrappers; never `claude mcp add` them per account
metadata:
  type: project
---

MCP servers every account needs (docs, 2026-10-17) go in `~/.claude/mcp.json`. The `claude`, `claude-enti`, `claude-veradux`, `claude-work` wrappers in ~/nix-config `home/shell.nix` append `--mcp-config=$HOME/.claude/mcp.json`.

**Why:** user-scope MCP lives in each account's `.claude.json` next to the login, so it cannot be symlinked like the rest of ~/.claude; per-account `claude mcp add` drifted (veradux missed `docs`).

**How to apply:** add shared servers to that file, not with `claude mcp add`. `--mcp-config` is variadic (eats a following prompt, even with `=`) and subcommands (`mcp`, `doctor`, ...) reject it, so it must stay last and skipped for subcommands; `claude mcp list` does not show these servers. Still per account (2026-10-22): `atlassian` and `blender` are user-scope servers in the work, enti and veradux `.claude.json` (not in the main account), and enti and veradux have a `dreamwork` server for ~/Documents/interview. context7 is removed from all accounts. Related: [[feedback_docs_mcp_for_libs]].
