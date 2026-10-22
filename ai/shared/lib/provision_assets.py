#!/usr/bin/env python3
"""Provision dotfiles-managed AI assets. Claude follows symlinks; Codex needs real files."""

import glob
import os
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "../.."))
sys.path.insert(0, os.path.dirname(__file__))
from memory_provisioner import copy_file, link_file  # noqa: E402

HOME = os.path.expanduser("~")


def skill_files(kind):
    """(skill name, path inside the skill, source) for every file of every skill: scripts and
    templates beside SKILL.md must reach the runtime too."""
    for skill in sorted(glob.glob(os.path.join(ROOT, kind, "skills", "*", "SKILL.md"))):
        base = os.path.dirname(skill)
        for source in sorted(glob.glob(os.path.join(base, "**", "*"), recursive=True)):
            if os.path.isfile(source) and "__pycache__" not in source:
                yield os.path.basename(base), os.path.relpath(source, base), source


def provision():
    rules = os.path.join(ROOT, "shared", "AGENTS.md")
    linked = link_file(rules, os.path.join(HOME, ".claude", "CLAUDE.md"))
    linked += copy_file(rules, os.path.join(HOME, ".codex", "AGENTS.md"))
    for kind in ("agents", "workflows"):
        for source in glob.glob(os.path.join(ROOT, "claude", kind, "*")):
            if os.path.isfile(source):
                linked += link_file(source, os.path.join(HOME, ".claude", kind, os.path.basename(source)))
    for name, rel, source in skill_files("claude"):
        linked += link_file(source, os.path.join(HOME, ".claude", "skills", name, rel))
    for name, rel, source in skill_files("shared"):
        linked += link_file(source, os.path.join(HOME, ".claude", "skills", name, rel))
        linked += link_file(source, os.path.join(HOME, ".agents", "skills", name, rel))
        linked += copy_file(source, os.path.join(HOME, ".codex", "skills", name, rel))
    # Codex auto-discovers only $CODEX_HOME/skills and $CODEX_HOME/agents, and its scanner
    # skips symlinks, so these must be copied as real files, not linked.
    for name, rel, source in skill_files("codex"):
        linked += copy_file(source, os.path.join(HOME, ".codex", "skills", name, rel))
    for source in glob.glob(os.path.join(ROOT, "codex", "agents", "*.toml")):
        linked += copy_file(source, os.path.join(HOME, ".codex", "agents", os.path.basename(source)))
    return linked


if __name__ == "__main__":
    linked = provision()
    if linked:
        print("provisioned %d AI asset link(s)" % linked)
