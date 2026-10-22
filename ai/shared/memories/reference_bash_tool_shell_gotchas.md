---
name: reference_bash_tool_shell_gotchas
description: "Bash tool on this desktop: ls is eza, grep is ugrep, zsh -lc hangs; use direct paths and find -printf in scripts"
metadata:
  type: reference
---

- `ls` is an alias for `eza --icons`. `-L` means tree depth, and links print as `name -> target`. In scripts use `find -printf '%f\n'` or `/run/current-system/sw/bin/ls`.
- `grep` is ugrep (via the shell snapshot). For GNU grep flags and output, call `/usr/bin/env grep`.
- `zsh -lc` hangs. Call tools by direct path; do not start login shells.

Related: [[project_nixos_config]].
