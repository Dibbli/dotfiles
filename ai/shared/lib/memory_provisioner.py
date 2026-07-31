#!/usr/bin/env python3
"""Shared symlink/index engine for Claude Code and Codex memories."""

import glob
import io
import os
import re


SUPERSEDED = {
    "feedback_commit_message_style.md",
    "feedback_opus_for_logic.md",
    "feedback_no_em_dashes.md",
    "feedback_nav_tier_no_excuses.md",
    "feedback_never_run_git.md",
    "feedback_planning_tasks_discuss_first.md",
}


def canon_map(directory):
    if not os.path.isdir(directory):
        return {}
    return {
        os.path.basename(path): os.path.abspath(path)
        for path in glob.glob(os.path.join(directory, "*.md"))
        if os.path.basename(path) != "MEMORY.md"
    }


def project_key(cwd):
    return re.sub(r"[/.]", "-", os.path.abspath(cwd))


def _frontmatter(path):
    name, description = os.path.basename(path)[:-3], ""
    try:
        with io.open(path, encoding="utf-8") as handle:
            text = handle.read()
    except OSError:
        return name, description
    match = re.search(r"^---\n(.*?)\n---", text, re.S)
    for line in (match.group(1) if match else text).splitlines():
        if line.startswith("name:"):
            name = line.split(":", 1)[1].strip().strip("\"'")
        elif line.startswith("description:"):
            description = line.split(":", 1)[1].strip().strip("\"'")
    return name, description


def _link(target, destination):
    os.makedirs(os.path.dirname(destination), exist_ok=True)
    if os.path.islink(destination):
        if os.path.realpath(destination) == os.path.realpath(target):
            return False
        os.unlink(destination)
    elif os.path.exists(destination):
        os.remove(destination)
    os.symlink(os.path.abspath(target), destination)
    return True


def _copy(target, destination):
    # Codex's skill/agent scanner skips symlinks, so its assets must be real files.
    os.makedirs(os.path.dirname(destination), exist_ok=True)
    with open(target, "rb") as handle:
        content = handle.read()
    if os.path.islink(destination):
        os.unlink(destination)
    elif os.path.isfile(destination):
        with open(destination, "rb") as handle:
            if handle.read() == content:
                return False
    with open(destination, "wb") as handle:
        handle.write(content)
    return True


def _reconcile_index(memory_dir):
    files = sorted(
        name for name in os.listdir(memory_dir)
        if name.endswith(".md") and name != "MEMORY.md"
    )
    index_path = os.path.join(memory_dir, "MEMORY.md")
    lines = []
    if os.path.exists(index_path):
        with io.open(index_path, encoding="utf-8") as handle:
            lines = handle.read().splitlines()
    kept, covered = [], set()
    for line in lines:
        match = re.search(r"\]\(([^)]+\.md)\)", line)
        if match:
            filename = match.group(1)
            if filename in files:
                kept.append(line)
                covered.add(filename)
        elif line.strip():
            kept.append(line)
    for filename in files:
        if filename in covered:
            continue
        name, description = _frontmatter(os.path.join(memory_dir, filename))
        line = "- [%s](%s)" % (name, filename)
        if description:
            line += " — " + description
        kept.append(line)
    with io.open(index_path, "w", encoding="utf-8") as handle:
        handle.write("\n".join(kept) + "\n")


def provision_memory_dir(destination, public_dir, private_dir, private_eligibility_dir=None):
    os.makedirs(destination, exist_ok=True)
    public = canon_map(public_dir)
    public_root = os.path.abspath(public_dir)
    for path in glob.glob(os.path.join(destination, "*.md")):
        if not os.path.islink(path):
            continue
        target = os.readlink(path)
        target = os.path.abspath(os.path.join(os.path.dirname(path), target))
        if os.path.dirname(target) == public_root and os.path.basename(path) not in public:
            os.unlink(path)
    for name in SUPERSEDED:
        path = os.path.join(destination, name)
        if os.path.lexists(path):
            os.unlink(path) if os.path.islink(path) else os.remove(path)
    for name, target in public.items():
        _link(target, os.path.join(destination, name))
    eligibility = private_eligibility_dir or destination
    for name, target in canon_map(private_dir).items():
        if os.path.lexists(os.path.join(eligibility, name)):
            _link(target, os.path.join(destination, name))
    _reconcile_index(destination)
    return destination


def render_index_context(memory_dir):
    with io.open(os.path.join(memory_dir, "MEMORY.md"), encoding="utf-8") as handle:
        index = handle.read().rstrip()
    return (
        "Shared memory index for this workspace. Full memories live in %s. "
        "Read a linked file only when its description is relevant.\n\n%s"
        % (os.path.abspath(memory_dir), index)
    )


def link_file(target, destination):
    return _link(target, destination)


def copy_file(target, destination):
    return _copy(target, destination)
