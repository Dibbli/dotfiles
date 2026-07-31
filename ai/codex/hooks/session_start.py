#!/usr/bin/env python3
"""Codex SessionStart adapter that injects only the shared-memory index."""

import json
import os
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "../.."))
sys.path.insert(0, os.path.join(ROOT, "shared/lib"))
from memory_provisioner import project_key, provision_memory_dir, render_index_context  # noqa: E402

HOME = os.path.expanduser("~")
PUBLIC = os.path.join(ROOT, "shared/memories")
PRIVATE = os.path.join(HOME, ".claude/memory-shared-private")
CLAUDE_PROJECTS = os.path.join(HOME, ".claude/projects")
CODEX_PROJECTS = os.path.join(HOME, ".local/share/ai-memory/codex")


def main():
    try:
        cwd = json.load(sys.stdin).get("cwd") or os.getcwd()
    except Exception:
        cwd = os.getcwd()
    key = project_key(cwd)
    destination = os.path.join(CODEX_PROJECTS, key)
    eligibility = os.path.join(CLAUDE_PROJECTS, key, "memory")
    provision_memory_dir(destination, PUBLIC, PRIVATE, eligibility)
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "SessionStart",
            "additionalContext": render_index_context(destination),
        }
    }))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
