#!/usr/bin/env python3
"""Claude Code SessionStart adapter for shared memories."""

import glob
import json
import os
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "../.."))
sys.path.insert(0, os.path.join(ROOT, "shared/lib"))
from memory_provisioner import canon_map, project_key, provision_memory_dir  # noqa: E402

HOME = os.path.expanduser("~")
PUBLIC = os.path.join(ROOT, "shared/memories")
PRIVATE = os.path.join(HOME, ".claude/memory-shared-private")
PROJECTS = os.path.join(HOME, ".claude/projects")


def memory_dir(cwd):
    return os.path.join(PROJECTS, project_key(cwd), "memory")


def main():
    if not canon_map(PUBLIC):
        return 0
    if sys.argv[1:] == ["--all"]:
        for destination in sorted(glob.glob(os.path.join(PROJECTS, "*/memory"))):
            provision_memory_dir(destination, PUBLIC, PRIVATE)
        return 0
    if sys.argv[1:2] == ["--dir"] and len(sys.argv) == 3:
        provision_memory_dir(sys.argv[2], PUBLIC, PRIVATE)
        return 0
    try:
        cwd = json.load(sys.stdin).get("cwd") or os.getcwd()
    except Exception:
        cwd = os.getcwd()
    provision_memory_dir(memory_dir(cwd), PUBLIC, PRIVATE)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
