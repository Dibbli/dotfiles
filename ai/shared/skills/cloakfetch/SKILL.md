---
name: cloakfetch
description: Use when WebFetch or curl returns 403 Forbidden, a Cloudflare "Just a moment..." / "Additional Verification Required" page, Akamai "Access Denied", or another bot wall, and the page content is still needed.
---

# cloakfetch

## Overview
`cloakfetch URL` loads the page in CloakBrowser (a stealth Chromium) and prints the visible text. It gets past bot walls that block WebFetch. Run it with Bash. It prints the text on stdout and `status: <code>  final: <url>` on stderr.

## Quick Reference
| Situation | Command |
|---|---|
| First retry after a WebFetch 403 | `cloakfetch URL` |
| Cloudflare challenge or a 403 again | `cloakfetch --headed --wait 10000 URL` |
| Need markup, links, attributes | add `--html` |
| Must exit through the VPN | add `--vpn` |

- `--headed` runs normal (non-headless) Chrome inside a private headless Weston compositor. No window opens on the desktop.
- When IVPN is connected, the script runs itself through `ivpn exclude` so it uses the home IP. Datacenter VPN exits get 403 on most bot walls, whatever the browser.

## Reading the result
- `status: 200` means the stdout text is the page. Use it.
- `status: 403` with a page saying "Additional Verification", "Just a moment" or "Access Denied" means still blocked. Escalate to `--headed --wait 10000` once.
- Still 403 after `--headed`: stop and tell the user the site blocks it. Some sites (g2.com) block every mode.
- `cannot open shared object file`: the nix-ld library list is missing. See Setup.

## Common Mistakes
- Giving up after the WebFetch 403 without trying cloakfetch.
- Looping `--headed` with longer waits. One escalation is enough. Each run takes 10-20 s.
- Passing an unquoted URL that contains `?` or `&`. zsh globs it, so quote the URL.
- Treating the "Incomplete Windows font set" stderr warning as an error. It is advice only.

## Setup
Done on the NixOS desktop: a venv in `~/.local/share/cloakbrowser/.venv`, Chromium in `~/.cloakbrowser/`, and `~/.local/bin/cloakfetch` linked to `cloakfetch.py`. `cannot open shared object file` means `programs.nix-ld.libraries` in the flake lacks a library. `--headed` needs `weston`.
