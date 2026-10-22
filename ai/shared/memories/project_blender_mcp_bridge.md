---
name: project_blender_mcp_bridge
description: "Blender 5.2 on the desktop is drivable from Claude Code through ~/nix-config/scripts/blender_bridge.py, a hand-written stdio MCP bridge to the official add-on's socket."
metadata:
  type: project
  modified: 2026-08-02T14:13:18.393Z
---

Blender 5.2.0 LTS is in `modules/shared/packages.nix` and can be driven from Claude Code. Set up 2026-08-02.

Two halves:
- **Official Blender add-on** (extension id `mcp`, `lab_blender_org` repo, needs Blender >= 5.1), installed at `~/.config/blender/5.2/extensions/lab_blender_org/mcp/`. Runs a TCP server on `localhost:9876` speaking null-delimited JSON, `{"type": "execute", "code": ..., "strict_json": bool}`. It executes Python in Blender and is **not** an MCP server itself.
- **`~/nix-config/scripts/blender_bridge.py`**, a stdio MCP server translating JSON-RPC to that socket. Registered with `claude mcp add -s user blender -- python3 /home/dibbli/nix-config/scripts/blender_bridge.py`. Exposes `blender_execute_python`. Has a `--selftest` that runs without Blender.

**Why hand-written:** Claude Desktop has an official one-click connector but no Claude Code equivalent is published, and the `uvx blender-mcp-server` command that guides recommend installs an unrelated third party's PyPI package, not Blender's. See [[feedback_cite_only_what_loads]].

**Registration:** user scope in the work, enti and veradux accounts' `.claude.json`, not in the main account and not in the shared `~/.claude/mcp.json`. See [[project_shared_mcp_config]].

**How to apply:** Blender must be running with the add-on server started (Edit > Preferences > Add-ons > MCP > Start MCP Server); otherwise the tool reports "Could not reach Blender on localhost:9876". Snippets return data by assigning into the predefined `result` dict, not by returning. It executes arbitrary Python in the live session, so save the .blend first if the scene matters.
