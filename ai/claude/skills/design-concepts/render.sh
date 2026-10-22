#!/usr/bin/env bash
# Usage: render.sh [-v VIEW]... [-q QUERY] <page.html[?query]>...
#   VIEW   WxH[@scale][:suffix][?query], e.g. 1920x1080 or 844x390@2:mobile?view=phone
#          (default 1920x1080). Each view writes <name>[-suffix].webp.
#   QUERY  extra query string for every view, e.g. "art=file://$PWD/art/"
# Pages live in <set>/src/; shots land in <set>/ as WebP q85 (a fifth of the PNG, so pushes stay small). A page's own query (strip.html?c=2) adds
# "-c2" to the name. Fails, with no shot left behind, on a missing page, an empty shot or a JS error.
# Headless with no session bus and a throwaway profile: chromium on the user's bus once broke the
# desktop document portal.
set -euo pipefail
views=() query=""
while getopts "v:q:" o; do
	case $o in
	v) views+=("$OPTARG") ;;
	q) query=$OPTARG ;;
	*) exit 2 ;;
	esac
done
shift $((OPTIND - 1))
[[ ${#views[@]} -eq 0 ]] && views=(1920x1080)
flags=(--headless --disable-gpu --hide-scrollbars --allow-file-access-from-files --virtual-time-budget=8000
	--enable-logging=stderr --v=0)
for page in "$@"; do
	pq=${page#*\?}; [[ $pq == "$page" ]] && pq=""
	abs=$(realpath -e "${page%%\?*}")
	name=$(basename "$abs" .html)${pq:+-$(tr -c 'A-Za-z0-9' '-' <<<"${pq//=/}" | sed 's/-*$//')}
	out=$(dirname "$(dirname "$abs")")
	seen=" "
	for v in "${views[@]}"; do
		vq=${v#*\?}; [[ $vq == "$v" ]] && vq=""
		v=${v%%\?*}
		suffix=${v#*:}; [[ $suffix == "$v" ]] && suffix="" || suffix="-$suffix"
		v=${v%%:*}
		scale=${v#*@}; [[ $scale == "$v" ]] && scale=1
		size=${v%%@*}
		qs=$(printf '%s&%s&%s' "$pq" "$vq" "$query" | sed 's/&&*/\&/g; s/^&//; s/&$//')
		png="$out/$name$suffix.png" img="$out/$name$suffix.webp" log="$out/$name$suffix.log"
		[[ $seen == *" $img "* ]] && { echo "render.sh: two views write $img; give one a :suffix" >&2; exit 1; }
		seen+="$img "
		rm -f "$png" "$img"
		profile=$(mktemp -d)
		DBUS_SESSION_BUS_ADDRESS=disabled: chromium "${flags[@]}" --user-data-dir="$profile" \
			--window-size="${size/x/,}" --force-device-scale-factor="$scale" \
			--screenshot="$png" "file://$abs${qs:+?$qs}" 2>"$log" || true
		rm -rf "$profile"
		[[ -s $png ]] || { echo "render.sh: no PNG for $page ($log)" >&2; exit 1; }
		if grep -q 'Uncaught' "$log"; then
			rm -f "$png"
			echo "render.sh: JS error in $page:" >&2
			grep 'Uncaught' "$log" >&2
			exit 1
		fi
		rm -f "$log"
		magick "$png" -quality 85 "$img"
		rm -f "$png"
		echo "$img"
	done
done
