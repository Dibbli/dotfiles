---
name: feedback_docs_mcp_for_libs
description: Look up library/framework docs in the local docs MCP (search_docs, version-pinned) before guessing or asking the user
metadata:
  type: feedback
---

When stuck on library, framework or tool API behavior (Mantine, Next.js, Prisma, React Query, Tailwind, Hyprland, Roblox), query the local `docs` MCP server before guessing or asking the user. It replaces context7.

**Why:** The index holds the docs of every library used in ~/IdeaProjects, pinned to the project versions, so answers match the installed API. One official lookup beat two failed workarounds. The user interrupted a minute-long filesystem grep for an API with "use the docs instead".

**How to apply:**
- `mcp__docs__search_docs` with `library`, and `version` when the project pins one. Unknown name: `mcp__docs__list_libraries` for exact names and versions.
- Library not indexed: a hook says so and points to the indexing steps in /mnt/HDD/docs-mcp/README.md. Indexing goes to a background Sonnet agent. Meanwhile read the docs page with `mcp__docs__fetch_url` to answer now.
- Roblox engine and Creator docs: use the index (`roblox-creator-docs`), never web search or WebFetch. Subagent briefs must say so.
- Never `find /` or recursive-grep the filesystem to discover an API.

Setup: [[project_shared_mcp_config]]. Config in ~/nix-config/modules/shared/docs-mcp.nix, CLI source ~/nix-config/scripts/docs.py. Endpoint http://localhost:6280/mcp (`docs-mcp` container).
