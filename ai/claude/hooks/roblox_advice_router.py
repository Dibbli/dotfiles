#!/usr/bin/env python3
"""UserPromptSubmit hook: in a Roblox repo, point the agent at the matching advice topic files.

Emits paths only, never file bodies, and each path once per session. Run with --selftest to check.
"""

import json
import os
import re
import sys
import tempfile
from pathlib import Path

ADVICE = Path.home() / "IdeaProjects/blos/game-references/advice"

# Word-ish phrases match on a leading word boundary, so stems and plurals match.
TOPICS = {
    "tooling": ["definitions", "rojo", "lune", "luau-lsp", "typecheck", "selene", "stylua", "rokit", "syncback", "sourcemap",
                "preloadasync", "playermodule", "replicatedfirst", "project.json"],
    "luau": ["require", "@self", "luau-lsp", "yield", "task.spawn", "strict"],
    "networking": ["remote", "replicat", "snapshot", "unreliable", "bandwidth", "latency", "ping", "predict",
                   "interpolat", "rate limit", "fireallclients", "fireclient", "onserverevent", "netcode"],
    "teleport": ["jobid", "serverinstanceid", "server list", "teleport", "reserveserver", "reserved server", "privateserver", "teleportdata"],
    "data": ["profilestore", "datastore", "profile", "save", "migration", "schema", "memorystore",
             "incrementasync", "trade", "trading"],
    "monetization": ["robux", "receipt", "developer product", "dev product", "gamepass", "game pass",
                     "price level", "policyservice", "analytics", "badge", "monetiz", "purchase", "store"],
    "ui": ["clipsdescendants", "fontweight", "canvasgroup", "ui", "gui", "screengui", "surfacegui", "billboard", "textscaled", "uiscale", "inset", "topbar",
           "scrollingframe", "automaticsize", "uistroke", "menu", "button", "hud", "nameplate"],
    "input-mobile": ["input", "touch", "mobile", "phone", "gamepad", "controller", "thumbstick", "keyboard",
                     "mouse", "haptic", "contextaction", "keybind"],
    "audio": ["audio", "sound", "music", "sfx", "audioplayer", "analyzer", "spectrum"],
    "rendering": ["spotlight", "pointlight", "viewport", "editablemesh", "meshpart", "meshid", "neon", "bloom", "lighting", "camera",
                  "render", "preview"],
    "performance": ["performance", "lag", "fps", "frame budget", "memory", "streaming", "heartbeat",
                    "microprofiler", "pool", "optimi", "low-end"],
    "physics": ["animat", "motor6d", "physics", "anchor", "seat", "proximityprompt", "proximity prompt", "collision", "overlapparams",
                "touched", "characterautoloads", "humanoid", "zone", "npc", "avatar"],
    "other": ["filter", "textservice", "referral", "invite", "admin"],
}

HARNESS_EVENT = re.compile(r"<task-notification>|<agent-message\b|^\s*Another Claude session sent a message", re.M)


def matches(lower: str, phrase: str) -> bool:
    if re.fullmatch(r"[a-z0-9]+", phrase):
        return re.search(rf"\b{re.escape(phrase)}", lower) is not None
    return phrase in lower


def topics_for(prompt: str) -> list[str]:
    lower = prompt.lower()
    return [t for t, phrases in TOPICS.items() if any(matches(lower, p) for p in phrases)]


def is_roblox_repo(root: Path) -> bool:
    return (root / "rokit.toml").exists() or any(root.glob("*.project.json"))


def unseen(session_id: str, topics: list[str]) -> list[str]:
    seen_file = Path(tempfile.gettempdir()) / "roblox-advice-router" / f"{session_id}.json"
    try:
        seen = set(json.loads(seen_file.read_text()))
    except (OSError, ValueError):
        seen = set()
    fresh = [t for t in topics if t not in seen]
    if fresh:
        seen_file.parent.mkdir(parents=True, exist_ok=True)
        seen_file.write_text(json.dumps(sorted(seen | set(fresh))))
    return fresh


def main() -> None:
    try:
        data = json.load(sys.stdin)
    except ValueError:
        return
    prompt = data.get("prompt")
    if not isinstance(prompt, str) or prompt.strip().startswith("/") or HARNESS_EVENT.search(prompt):
        return
    root = Path(os.environ.get("CLAUDE_PROJECT_DIR") or data.get("cwd") or ".")
    if not is_roblox_repo(root):
        return
    fresh = unseen(str(data.get("session_id", "nosession")), topics_for(prompt))
    if not fresh:
        return
    lines = "\n".join(f"- {ADVICE / f'{t}.txt'}" for t in fresh)
    print(f"<roblox-advice>\nRoblox pro tips for this task (one line per tip, read before building):\n{lines}\n</roblox-advice>")


def selftest() -> None:
    for t in TOPICS:
        assert (ADVICE / f"{t}.txt").exists(), f"missing advice file: {t}.txt"
    assert "teleport" in topics_for("TeleportAsync keeps failing")
    assert "data" in topics_for("profiles not saving")
    assert "ui" not in topics_for("rebuild it"), "`ui` must not match inside `rebuild`"
    assert "physics" in topics_for("Motor6D pose fights the Animator")
    assert topics_for("what time is it") == []
    sid = f"selftest-{os.getpid()}"
    assert unseen(sid, ["audio"]) == ["audio"] and unseen(sid, ["audio"]) == [], "dedup per session"
    print("roblox_advice_router self-check OK")


if __name__ == "__main__":
    selftest() if "--selftest" in sys.argv else main()
