#!/usr/bin/env -S ${HOME}/.local/share/cloakbrowser/.venv/bin/python
"""cloakfetch URL [--html] [--headed] [--wait MS] — fetch a page through CloakBrowser, print its text."""
import argparse
import os
import re
import shutil
import subprocess
import sys
import time

from cloakbrowser import launch

ap = argparse.ArgumentParser()
ap.add_argument("url")
ap.add_argument("--html", action="store_true", help="print rendered HTML instead of visible text")
ap.add_argument("--headed", action="store_true", help="non-headless Chrome on a hidden headless-weston display; some sites detect headless")
ap.add_argument("--wait", type=int, default=2000, help="ms to wait after load for JS/challenges")
ap.add_argument("--vpn", action="store_true", help="stay inside IVPN instead of auto-excluding")
a = ap.parse_args()

# Bot walls 403 the IVPN datacenter exit outright, so run outside the tunnel when it's up.
if not a.vpn and not os.environ.get("CLOAKFETCH_EXCLUDED") and shutil.which("ivpn"):
    st = subprocess.run(["ivpn", "status"], capture_output=True, text=True).stdout
    if re.search(r"^VPN\s*:\s*CONNECTED", st, re.M):
        os.environ["CLOAKFETCH_EXCLUDED"] = "1"
        p = subprocess.Popen(["ivpn", "exclude", *sys.argv], stdout=subprocess.PIPE, text=True)
        for line in p.stdout:
            if not line.startswith("Running command in Split Tunneling"):
                sys.stdout.write(line)
        sys.exit(p.wait())

comp = None
if a.headed:
    # A real window on the desktop would steal focus / mark its workspace urgent.
    sock = f"cloakfetch-{os.getpid()}"
    comp = subprocess.Popen(["weston", "--backend=headless", "--renderer=pixman", f"--socket={sock}",
                             "--width=1920", "--height=1080"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    path = os.path.join(os.environ["XDG_RUNTIME_DIR"], sock)
    for _ in range(100):
        if os.path.exists(path) or comp.poll() is not None:
            break
        time.sleep(0.05)
    if not os.path.exists(path):
        sys.exit("cloakfetch: headless weston did not start")
    os.environ["WAYLAND_DISPLAY"] = sock
    os.environ.pop("DISPLAY", None)

try:
    browser = launch(headless=not a.headed, args=["--ozone-platform=wayland"] if a.headed else [])
    try:
        page = browser.new_page()
        resp = page.goto(a.url, wait_until="domcontentloaded", timeout=60000)
        page.wait_for_timeout(a.wait)
        print(f"status: {resp.status if resp else '?'}  final: {page.url}", file=sys.stderr)
        print(page.content() if a.html else page.inner_text("body"))
    finally:
        browser.close()
finally:
    if comp:
        comp.terminate()
