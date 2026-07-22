#!/usr/bin/env python3
"""Provision dotfiles-managed AI assets using file-level symlinks."""

import glob
import os
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "../.."))
sys.path.insert(0, os.path.dirname(__file__))
from memory_provisioner import link_file  # noqa: E402

HOME = os.path.expanduser("~")


def provision():
    linked = 0
    for kind in ("agents", "workflows"):
        for source in glob.glob(os.path.join(ROOT, "claude", kind, "*")):
            if os.path.isfile(source):
                linked += link_file(source, os.path.join(HOME, ".claude", kind, os.path.basename(source)))
    for source in glob.glob(os.path.join(ROOT, "claude", "skills", "*", "SKILL.md")):
        name = os.path.basename(os.path.dirname(source))
        linked += link_file(source, os.path.join(HOME, ".claude", "skills", name, "SKILL.md"))
    for source in glob.glob(os.path.join(ROOT, "shared", "skills", "*", "SKILL.md")):
        name = os.path.basename(os.path.dirname(source))
        linked += link_file(source, os.path.join(HOME, ".claude", "skills", name, "SKILL.md"))
        linked += link_file(source, os.path.join(HOME, ".agents", "skills", name, "SKILL.md"))
    for source in glob.glob(os.path.join(ROOT, "codex", "agents", "*.toml")):
        linked += link_file(source, os.path.join(HOME, ".codex", "agents", os.path.basename(source)))
    return linked


if __name__ == "__main__":
    print("provisioned %d AI asset link(s)" % provision())
