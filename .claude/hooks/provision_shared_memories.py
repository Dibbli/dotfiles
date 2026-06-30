#!/usr/bin/env python3
"""Provision shared Claude memories into project memory dirs via symlinks.

Two canonical sources:
  PUBLIC  = ~/Documents/dotfiles/.claude/memory-shared      (committed to a public repo)
  PRIVATE = ~/.claude/memory-shared-private                 (local only, never committed)

Public memories are symlinked into EVERY project (universal behaviors).
Private memories are only DEDUPED: a project's existing real-file copy is replaced
with a symlink to canonical, but private memories are not spread to projects that
never had them (avoids leaking job-search/MR notes into unrelated projects).

Memories are per-project (~/.claude/projects/<proj>/memory). System-wide assets
(skills, agents, workflows) are NOT handled here — see provision_global_assets.py.

Modes:
  (no args)        hook mode: read SessionStart JSON on stdin, provision the cwd's project
  --dir <memdir>   provision one memory dir
  --all            provision every ~/.claude/projects/*/memory (backfill)

Idempotent. MEMORY.md is reconciled non-destructively (append missing lines, drop
lines for files that no longer exist; existing lines are left untouched).
ponytail: pure-stdlib, shells out to nothing.
"""
import os, sys, json, glob, re, io

HOME = os.path.expanduser("~")
PUBLIC  = os.path.join(HOME, "Documents/dotfiles/.claude/memory-shared")
PRIVATE = os.path.join(HOME, ".claude/memory-shared-private")
PROJECTS = os.path.join(HOME, ".claude/projects")

# files made obsolete by merges/renames/variants — removed if present as real files
SUPERSEDED = {
    "feedback_commit_message_style.md",   # merged into feedback_commit_style
    "feedback_opus_for_logic.md",          # merged into feedback_pick_models_for_subagents
    "feedback_no_em_dashes.md",            # variant of feedback_no_emdashes
    "feedback_nav_tier_no_excuses.md",     # renamed to feedback_production_tier_no_excuses
    "feedback_never_run_git.md",           # merged into feedback_commits_workflow
}


def canon_map(d):
    """basename -> absolute canonical path, for *.md in dir d (skip MEMORY.md)."""
    out = {}
    if os.path.isdir(d):
        for p in glob.glob(os.path.join(d, "*.md")):
            b = os.path.basename(p)
            if b != "MEMORY.md":
                out[b] = os.path.abspath(p)
    return out


def frontmatter(path):
    """Return (name, description) from a memory file's YAML frontmatter."""
    name = os.path.basename(path)[:-3]
    desc = ""
    try:
        with io.open(path, encoding="utf-8") as f:
            txt = f.read()
    except OSError:
        return name, desc
    m = re.search(r"^---\n(.*?)\n---", txt, re.S)
    block = m.group(1) if m else txt
    for line in block.splitlines():
        if line.startswith("name:"):
            name = line.split(":", 1)[1].strip().strip('"\'')
        elif line.startswith("description:"):
            desc = line.split(":", 1)[1].strip().strip('"\'')
    return name, desc


def link_in(memdir, name, target):
    """Symlink memdir/name -> target, replacing any real file or stale link."""
    p = os.path.join(memdir, name)
    if os.path.islink(p):
        if os.path.realpath(p) == os.path.realpath(target):
            return
        os.unlink(p)
    elif os.path.exists(p):
        os.remove(p)
    os.symlink(target, p)


def reconcile_memory_md(memdir):
    """Ensure MEMORY.md has exactly one line per current *.md (append missing,
    drop lines for vanished files). Existing lines kept verbatim."""
    files = sorted(b for b in (os.path.basename(p) for p in glob.glob(os.path.join(memdir, "*.md")))
                   if b != "MEMORY.md")
    mpath = os.path.join(memdir, "MEMORY.md")
    lines = []
    if os.path.exists(mpath):
        with io.open(mpath, encoding="utf-8") as f:
            lines = f.read().splitlines()
    # keep lines whose referenced file still exists; index which files are covered
    kept, covered = [], set()
    for ln in lines:
        m = re.search(r"\]\(([^)]+\.md)\)", ln)
        if m:
            fn = m.group(1)
            if fn in files:
                kept.append(ln); covered.add(fn)
            # else: file gone -> drop the line
        elif ln.strip():
            kept.append(ln)  # preserve non-entry prose (rare)
    # append a line for any file not yet covered
    for fn in files:
        if fn not in covered:
            nm, desc = frontmatter(os.path.join(memdir, fn))
            kept.append("- [%s](%s) — %s" % (nm, fn, desc) if desc else "- [%s](%s)" % (nm, fn))
    with io.open(mpath, "w", encoding="utf-8") as f:
        f.write("\n".join(kept) + "\n")


def process_dir(memdir, public, private):
    os.makedirs(memdir, exist_ok=True)
    # 1. remove superseded real files
    for name in SUPERSEDED:
        p = os.path.join(memdir, name)
        if os.path.islink(p) or os.path.exists(p):
            os.unlink(p) if os.path.islink(p) else os.remove(p)
    # 2. public: full provision
    for name, target in public.items():
        link_in(memdir, name, target)
    # 3. private: dedupe only (replace an existing real copy; don't spread)
    for name, target in private.items():
        p = os.path.join(memdir, name)
        if os.path.exists(p) or os.path.islink(p):
            link_in(memdir, name, target)
    # 4. reconcile index
    reconcile_memory_md(memdir)


def cwd_to_memdir(cwd):
    enc = re.sub(r"[/.]", "-", cwd)
    return os.path.join(PROJECTS, enc, "memory")


def main():
    public, private = canon_map(PUBLIC), canon_map(PRIVATE)
    if not public:
        sys.stderr.write("provision_shared_memories: no public canon at %s\n" % PUBLIC)
        return 0
    args = sys.argv[1:]
    if args and args[0] == "--all":
        dirs = [d for d in glob.glob(os.path.join(PROJECTS, "*/memory"))
                if "/memory.bak-" not in d]
        for d in sorted(dirs):
            process_dir(d, public, private)
            print("provisioned", d)
    elif args and args[0] == "--dir":
        process_dir(args[1], public, private)
        print("provisioned", args[1])
    else:
        # hook mode: SessionStart JSON on stdin
        try:
            data = json.load(sys.stdin)
            cwd = data.get("cwd") or os.getcwd()
        except Exception:
            cwd = os.getcwd()
        process_dir(cwd_to_memdir(cwd), public, private)
    return 0


if __name__ == "__main__":
    sys.exit(main())
