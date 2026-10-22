---
name: project_nix_shell_tools
description: "On the NixOS desktop, get a missing CLI tool or Python lib with nix-shell -p (no sudo) before asking the user to install it"
metadata:
  type: project
---

`nix-shell -p sox csound "python3.withPackages (p: [p.numpy p.scipy])" --run "..."` works without sudo (tested 2026-09-24). Run it unsandboxed.

**Why:** the user prefers getting a tool over working around its absence ("we can download more"), and system installs go through the flake.

**How to apply:** when a tool is missing, try `nix-shell -p <pkg>` first. For a tool needed every day, suggest adding it to the flake instead. Related: [[project_nixos_config]].
