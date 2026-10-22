#!/usr/bin/env python3
"""PostToolUse Write|Edit hook: when Luau code in a Roblox repo uses an API an advice tip names, show that tip.

Keys come from the backticked API names in each tip line, so a new tip routes with no table to edit.
Never blocks; each tip shows once per session. Run with --selftest to check.
"""

import json
import os
import re
import sys
from pathlib import Path

from roblox_advice_router import ADVICE, is_roblox_repo, unseen

MAX_TIPS = 3
# Names too common in Roblox code to say anything about the tip.
STOP = {"GuiObject", "GuiService", "LocalPlayer", "ModuleScript", "WaitForChild", "TextSize", "AbsoluteSize",
        "CanCollide", "TouchEnabled", "PlayerScripts", "TextBounds", "FromName", "MaxDistance"}
API = re.compile(r"[A-Z][a-z]+[A-Z]\w*|[A-Z]\w*Async")


def tips() -> dict[str, list[tuple[str, str]]]:
    """API name -> [(topic file, tip line)]."""
    keyed: dict[str, list[tuple[str, str]]] = {}
    for path in sorted(ADVICE.glob("*.txt")):
        if path.name == "INDEX.txt":
            continue
        for line in path.read_text().splitlines():
            if not line.startswith("- "):
                continue
            names = {re.split(r"[.:]", n)[-1] for tok in re.findall(r"`([^`]+)`", line)
                     for n in re.findall(r"\w+(?:[.:]\w+)*", tok)}
            for name in names:
                if len(name) >= 7 and name not in STOP and API.fullmatch(name):
                    keyed.setdefault(name, []).append((path.name, line[2:]))
    return keyed


def hits(code: str) -> list[tuple[str, str, str]]:
    """(API name, topic file, tip line) for each tip whose API the code uses, first use first."""
    found, seen_lines = [], set()
    for name, entries in tips().items():
        m = re.search(rf"\b{name}\b", code)
        if m:
            for topic, line in entries:
                if line not in seen_lines:
                    seen_lines.add(line)
                    found.append((m.start(), name, topic, line))
    return [(n, t, l) for _, n, t, l in sorted(found)]


def main() -> None:
    try:
        data = json.load(sys.stdin)
    except ValueError:
        return
    tool_input = data.get("tool_input") or {}
    if not str(tool_input.get("file_path", "")).endswith((".luau", ".lua")):
        return
    code = tool_input.get("content") or tool_input.get("new_string")
    if not isinstance(code, str):
        return
    if not is_roblox_repo(Path(data.get("cwd") or os.environ.get("CLAUDE_PROJECT_DIR") or ".")):
        return
    found = hits(code)
    fresh = set(unseen(str(data.get("session_id", "nosession")), [f"tip:{l}" for _, _, l in found]))
    lines = [f"- You used {n}. Tip ({t}): {l}" for n, t, l in found if f"tip:{l}" in fresh][:MAX_TIPS]
    if lines:
        text = "<roblox-tip>\n" + "\n".join(lines) + "\n</roblox-tip>"
        print(json.dumps({"hookSpecificOutput": {"hookEventName": "PostToolUse", "additionalContext": text}}))


def selftest() -> None:
    assert any(n == "FilterStringAsync" for n, _, _ in hits("local ok = TextService:FilterStringAsync(s, id)"))
    assert hits("local g: GuiObject = x:WaitForChild('A')") == [], "stoplisted names must not route"
    assert hits("local filterStringAsync = 1") == [], "case-sensitive word match"
    assert len(tips()) > 50, "keys extracted from advice/"
    sid = f"selftest-tip-{os.getpid()}"
    assert unseen(sid, ["tip:x"]) == ["tip:x"] and unseen(sid, ["tip:x"]) == [], "dedup per session"
    print("roblox_tip_router self-check OK")


if __name__ == "__main__":
    selftest() if "--selftest" in sys.argv else main()
