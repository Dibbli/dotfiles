#!/usr/bin/env python3
"""PreToolUse hook on Bash: pop a "YubiKey touch needed" notification when the command runs a
signed git commit or push. Settings `if` patterns fire on any $() or $VAR, so the check is here.
"""

import json
import shlex
import subprocess
import sys

SEPARATORS = {";", "&&", "||", "|", "&", "(", ")"}
# git options that take a separate value: `git -C dir commit`, `git -c k=v push`.
VALUE_OPTIONS = {"-C", "-c", "--git-dir", "--work-tree", "--namespace"}


def signing_actions(command):
    # Newlines separate commands too; inside quotes the swap is harmless.
    lexer = shlex.shlex(command.replace("\n", " ; "), posix=True, punctuation_chars=";&|()")
    lexer.whitespace_split = True
    try:
        tokens = list(lexer)
    except ValueError:
        return []
    found, start = [], True
    for i, token in enumerate(tokens):
        if token in SEPARATORS:
            start = True
            continue
        if start and token == "git":
            j = i + 1
            while j < len(tokens) and tokens[j].startswith("-"):
                j += 2 if tokens[j] in VALUE_OPTIONS else 1
            if j < len(tokens) and tokens[j] in ("commit", "push") and tokens[j] not in found:
                found.append(tokens[j])
        start = "=" in token and start
    return found


def selftest():
    assert signing_actions('git commit -m "x"') == ["commit"]
    assert signing_actions("git add . && git commit -m x && git push") == ["commit", "push"]
    assert signing_actions("git -C ~/repo push origin main") == ["push"]
    assert signing_actions("FOO=1 git commit") == ["commit"]
    assert signing_actions('grep -n "git commit" notes.md') == []
    assert signing_actions("for f in $(ls); do echo $f; done") == []
    assert signing_actions("git log --oneline -1") == []
    assert signing_actions("cd repo\ngit push") == ["push"]
    assert signing_actions('git commit -m "a\nb"') == ["commit"]
    print("ok")


if __name__ == "__main__":
    if sys.argv[1:] == ["--selftest"]:
        selftest()
        sys.exit(0)
    command = json.load(sys.stdin).get("tool_input", {}).get("command", "")
    for action in signing_actions(command):
        subprocess.run(["notify-send", "YubiKey touch needed", "git " + action], check=False)
