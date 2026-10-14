#!/usr/bin/env bash
# Usage: sbs.sh <reference.png> <render.png> <out.png> [round label]
# Reference left, render right, both scaled to the same height and labelled with their true size,
# so the critic judges one image. Refuses a render that is the reference file or has another aspect
# (other framing). Same size: also writes <out>-diff.png (changed pixels in red) and prints the count.
set -euo pipefail
ref=$1 build=$2 out=$3 label=${4:-BUILD}
cmp -s "$ref" "$build" && { echo "sbs.sh: the render is the reference file" >&2; exit 1; }
read -r rw rh < <(magick identify -format '%w %h\n' "$ref" | head -1)
read -r bw bh < <(magick identify -format '%w %h\n' "$build" | head -1)
python3 -c 'import sys; a, b, c, d = map(int, sys.argv[1:]); sys.exit(abs(a / b - c / d) > 0.02 * a / b)' \
	"$rw" "$rh" "$bw" "$bh" || { echo "sbs.sh: framing differs: ${rw}x$rh vs ${bw}x$bh" >&2; exit 1; }
h=$(( rh > 1440 ? 1440 : rh ))
tag() { magick "$1" -resize "x$h" -gravity north -background '#141113' -splice 0x44 \
	-fill '#e8e2df' -font DejaVu-Sans-Bold -pointsize 28 -annotate +0+6 "$2" miff:-; }
magick <(tag "$ref" "REFERENCE ${rw}x$rh") \
	\( <(tag "$build" "$label ${bw}x$bh") -background '#d9452b' -gravity west -splice 8x0 \) +append +repage "$out"
echo "$out"
if [[ ${rw}x$rh == "${bw}x$bh" ]]; then
	set +e
	err=$(magick compare -metric AE -fuzz 4% "$ref" "$build" -compose src -highlight-color '#ff3020' \
		"${out%.png}-diff.png" 2>&1)
	(( $? == 2 )) && { echo "sbs.sh: compare failed: $err" >&2; exit 1; }
	set -e
	# compare's AE prints a weighted figure, not a pixel count: count pixels off by more than 4% here.
	px=$(magick "$ref" "$build" -compose difference -composite -separate -evaluate-sequence max \
		-threshold 4% -format '%[fx:round(mean*w*h)]' info:)
	echo "${out%.png}-diff.png: $px px differ"
fi
