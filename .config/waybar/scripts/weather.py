#!/usr/bin/env python3
# Waybar weather via wttr.in (no API key). Continuous script: prints a JSON line per
# update. Spins a braille spinner while fetching, then the glyph + temp. Wakes early on
# SIGRTMIN+9 (sent by weather-toggle.py) to re-fetch the swapped location.
import json, os, signal, sys, threading, urllib.parse, urllib.request
from datetime import datetime

LOCATIONS = ["Hamburg", "Budapest"]
STATE = os.path.expanduser("~/.cache/waybar-weather-loc")
REFRESH_SECS = 900
ERROR_SECS = 60  # short retry when wttr.in is down/slow/malformed
FRAMES = "⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"

# WWO weather code -> Material Design Nerd Font glyph. CSS colors it (no multicolor emoji).
# ponytail: day-only icons, no night variant. Add astronomy lookup if night matters.
SUN, PARTLY, CLOUD, FOG = "\U000F0599", "\U000F0595", "\U000F0590", "\U000F0591"
RAIN, POUR, SNOW, STORM = "\U000F0597", "\U000F0596", "\U000F0598", "\U000F0593"
ICONS = {
    "113": SUN, "116": PARTLY, "119": CLOUD, "122": CLOUD,
    "143": FOG, "248": FOG, "260": FOG,
    "176": RAIN, "263": RAIN, "266": RAIN, "293": RAIN, "296": RAIN, "353": RAIN,
    "299": POUR, "302": POUR, "305": POUR, "308": POUR, "356": POUR, "359": POUR,
    "179": SNOW, "182": SNOW, "185": SNOW, "227": SNOW, "230": SNOW, "281": SNOW,
    "284": SNOW, "311": SNOW, "314": SNOW, "317": SNOW, "320": SNOW, "323": SNOW,
    "326": SNOW, "329": SNOW, "332": SNOW, "335": SNOW, "338": SNOW, "350": SNOW,
    "362": SNOW, "365": SNOW, "368": SNOW, "371": SNOW, "374": SNOW, "377": SNOW,
    "395": SNOW,
    "200": STORM, "386": STORM, "389": STORM, "392": STORM,
}


def emit(text, tooltip=""):
    sys.stdout.write(json.dumps({"text": text, "tooltip": tooltip}) + "\n")
    sys.stdout.flush()


def current_loc():
    try:
        return LOCATIONS[int(open(STATE).read().strip()) % len(LOCATIONS)]
    except Exception:
        return LOCATIONS[0]


def fetch(loc):
    url = "https://wttr.in/%s?format=j1" % urllib.parse.quote(loc)
    req = urllib.request.Request(url, headers={"User-Agent": "curl/8"})
    with urllib.request.urlopen(req, timeout=10) as r:
        return json.load(r)


def build(d, loc):
    c = d["current_condition"][0]
    icon = ICONS.get(c["weatherCode"], CLOUD)
    text = "%s %s°C" % (icon, c["temp_C"])
    lines = ["<b>%s now</b>" % loc,
             "%s  %s°C (feels %s°C)" % (
                 c["weatherDesc"][0]["value"], c["temp_C"], c["FeelsLikeC"]),
             "UV %s   %s hPa   humidity %s%%   wind %s km/h" % (
                 c["uvIndex"], c["pressure"], c["humidity"], c["windspeedKmph"]),
             "", "<b>Forecast</b>"]
    for day in d["weather"][:3]:
        wd = datetime.strptime(day["date"], "%Y-%m-%d").strftime("%a")
        noon = day["hourly"][len(day["hourly"]) // 2]
        di = ICONS.get(noon["weatherCode"], CLOUD)
        lines.append("%s %s  %s–%s°C   UV %s   %s hPa" % (
            di, wd, day["mintempC"], day["maxtempC"], day["uvIndex"], noon["pressure"]))
    return text, "\n".join(lines)


def update():
    loc = current_loc()
    done = threading.Event()

    def spin():
        i = 0
        while not done.wait(0.12):
            emit("%s %s" % (FRAMES[i % len(FRAMES)], loc))
            i += 1

    t = threading.Thread(target=spin)
    t.start()
    ok = True
    try:
        text, tip = build(fetch(loc), loc)
    except Exception as e:
        text, tip, ok = "\U000F0F38", "weather: %s" % e, False
    done.set()
    t.join()
    emit(text, tip)
    return ok


def main():
    wake = threading.Event()
    signal.signal(signal.SIGRTMIN + 9, lambda *_: wake.set())
    while True:
        wake.clear()  # clear before fetch so a toggle during the fetch isn't lost
        ok = update()
        wake.wait(REFRESH_SECS if ok else ERROR_SECS)


if __name__ == "__main__":
    main()
