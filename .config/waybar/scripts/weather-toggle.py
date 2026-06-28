#!/usr/bin/env python3
# Flip the weather location, then poke the running weather.py (SIGRTMIN+9) to re-fetch.
import os, subprocess
STATE = os.path.expanduser("~/.cache/waybar-weather-loc")
try:
    i = int(open(STATE).read().strip())
except Exception:
    i = 0
tmp = STATE + ".tmp"
with open(tmp, "w") as f:
    f.write(str((i + 1) % 2))
os.replace(tmp, STATE)  # atomic: a reader never sees a truncated file
subprocess.run(["pkill", "-RTMIN+9", "-f", r"scripts/weather\.py$"])
