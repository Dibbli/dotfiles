#!/usr/bin/env python3
"""Provision system-wide Claude assets from dotfiles via symlinks.

Skills, agents, and workflows are system-wide (~/.claude/{skills,agents,workflows}),
unlike memories which are per-project (see provision_shared_memories.py). This script
symlinks the copies committed under ~/Documents/dotfiles/.claude into ~/.claude so the
dotfiles repo is their source of truth: edit once in the repo, every project sees it,
and a fresh clone provisions them.

File-level symlinks only — a skill directory is created real and only its SKILL.md is
linked, so this never removes a directory and is safe on a machine that already has
real files there. Idempotent. cwd-independent (the assets are global, not per-project),
so it is safe as a SessionStart hook or a one-shot install step.

ponytail: pure-stdlib, shells out to nothing.
"""
import os, glob, sys

HOME = os.path.expanduser("~")
DOTCLAUDE = os.path.join(HOME, "Documents/dotfiles/.claude")  # canonical source
GLOBAL_CLAUDE = os.path.join(HOME, ".claude")                 # where Claude Code reads


def link_file(target, dst):
    """Symlink dst -> target (file-level), replacing a real file or stale link.
    Creates dst's parent dir. No-op if already correct. Never touches a directory."""
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    if os.path.islink(dst):
        if os.path.realpath(dst) == os.path.realpath(target):
            return False
        os.unlink(dst)
    elif os.path.exists(dst):
        os.remove(dst)
    os.symlink(target, dst)
    return True


def provision():
    linked = 0
    # agents/*.md and workflows/* -> mirror each file into ~/.claude/<kind>/
    for kind in ("agents", "workflows"):
        src = os.path.join(DOTCLAUDE, kind)
        if not os.path.isdir(src):
            continue
        for p in glob.glob(os.path.join(src, "*")):
            if os.path.isfile(p):
                linked += link_file(os.path.abspath(p),
                                    os.path.join(GLOBAL_CLAUDE, kind, os.path.basename(p)))
    # skills/<name>/SKILL.md -> ~/.claude/skills/<name>/SKILL.md (dir stays real)
    for sk in glob.glob(os.path.join(DOTCLAUDE, "skills", "*", "SKILL.md")):
        name = os.path.basename(os.path.dirname(sk))
        linked += link_file(os.path.abspath(sk),
                            os.path.join(GLOBAL_CLAUDE, "skills", name, "SKILL.md"))
    return linked


if __name__ == "__main__":
    n = provision()
    print("provision_global_assets: %d new link(s)" % n)
    sys.exit(0)
