#!/usr/bin/env python3
"""PreToolUse Bash hook: on `git commit` in a Roblox repo, remind the agent to drop reusable finds in the
game-references inbox. Never blocks. Run with --selftest to check.
"""

import json
import os
import re
import sys
from pathlib import Path

from roblox_advice_router import is_roblox_repo

INBOX = Path.home() / "IdeaProjects/blos/game-references/inbox"
GIT_COMMIT = re.compile(r"\bgit\b[^;&|]*\bcommit\b")


def nudge(command: str, root: Path) -> str | None:
    if not GIT_COMMIT.search(command) or not is_roblox_repo(root):
        return None
    return (f"Before this commit: did this work find a Roblox gotcha that is not game-specific, or build a system "
            f"another game could copy? If so, add a note in {INBOX}/ (format in its README.md). If not, carry on.")


def main() -> None:
    try:
        data = json.load(sys.stdin)
    except ValueError:
        return
    command = (data.get("tool_input") or {}).get("command")
    if not isinstance(command, str):
        return
    text = nudge(command, Path(data.get("cwd") or os.environ.get("CLAUDE_PROJECT_DIR") or "."))
    if text:
        print(json.dumps({"hookSpecificOutput": {"hookEventName": "PreToolUse", "additionalContext": text}}))


def selftest() -> None:
    roblox = Path.home() / "IdeaProjects/blos/buckler"
    assert nudge('git commit -m "x"', roblox)
    assert nudge("git add -A && git -C . commit", roblox)
    assert nudge("git status", roblox) is None
    assert nudge("git commit", Path("/")) is None, "only in Roblox repos"
    assert INBOX.is_dir(), f"missing {INBOX}"
    print("roblox_inbox_nudge self-check OK")


if __name__ == "__main__":
    selftest() if "--selftest" in sys.argv else main()
