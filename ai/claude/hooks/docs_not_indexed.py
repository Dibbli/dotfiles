#!/usr/bin/env python3
"""PostToolUseFailure hook on mcp__docs__search_docs: when the library is not indexed, state how
it gets indexed instead of leaving the agent to give up.
"""

import json
import sys

event = json.load(sys.stdin)
error = str(event.get("error", ""))
# Covers both a missing library and a missing version of an indexed one.
if "not found in store" not in error:
    sys.exit(0)

library = event.get("tool_input", {}).get("library", "<library>")
context = (
    f"Local docs index: {error.strip()} A 'Did you mean' name may be the same library. "
    f"Indexing a new library or version: `docs add {library} <url> [-v N]`, then `docs wait {library}`, "
    "steps and source order in /mnt/HDD/docs-mcp/README.md. A Sonnet agent can run it in the background. "
    "mcp__docs__scrape_docs indexes 0 pages from GitHub URLs. mcp__docs__fetch_url reads one docs page now."
)
print(json.dumps({"hookSpecificOutput": {"hookEventName": "PostToolUseFailure", "additionalContext": context}}))
