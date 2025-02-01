#!/usr/bin/env bash
#
# this script scrape and show xkcd comics
#
# dependencies: rofi, jq, python3-lxml, python3-requests

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI="${ROFI:-rofi}"
ROFI_CACHE_DIR="${ROFI_CACHE_DIR:-$HOME/.cache}"
ROFI_ICONS="${ROFI_ICONS:-}"
XKCD_GRID="${XKCD_GRID:-}"
XKCD_GRID_ROWS=${XKCD_GRID_ROWS:-${ROFI_GRID_ROWS:-3}}
XKCD_GRID_COLS=${XKCD_GRID_COLS:-${ROFI_GRID_COLS:-4}}
XKCD_GRID_ICON_SIZE=${XKCD_GRID_ICON_SIZE:-${ROFI_GRID_ICON_SIZE:-10}}
XKCD_THUMBNAILS=${XKCD_THUMBNAILS:-}
XKCD_ICON_SIZE=${XKCD_ICON_SIZE:-25}

xkcd_refresh=86400 # refresh xkcd file every day
xkcd_cache="$ROFI_CACHE_DIR/xkcd"
xkcd_file="$xkcd_cache/list"
xkcd_preview=$SCRIPT_PATH'/download_xkcd_icon.sh "{input}" "{output}"'

rofi_theme_grid="element{orientation:vertical;}element-text{horizontal-align:0.5;}element-icon{size:$XKCD_GRID_ICON_SIZE.0em;}listview{lines:$XKCD_GRID_ROWS;columns:$XKCD_GRID_COLS;}"
rofi_theme_item="element{orientation:vertical;}element-text{horizontal-align:0.5;}element-icon{size:$XKCD_ICON_SIZE.0em;}listview{lines:1;columns:1;}entry{enabled:false;}mainbox{children:[message,listview];}"
rofi_flags="-markup-rows"

mkdir -p "$xkcd_cache"

get_comic_list() {
    curl -s "https://xkcd.com/archive/" -o "$xkcd_cache/archive"

    cat "$xkcd_cache/archive" | \
        xmllint --html --xpath '//div[@id="middleContainer"]//a/@href' - | \
        sed -n 's/.*href="\([^"]*\).*/\1/p' | \
        sed 's/\///g' > "$xkcd_cache/refs"
    cat "$xkcd_cache/archive" | \
        xmllint --html --xpath '//div[@id="middleContainer"]//a/text()' - > "$xkcd_cache/names"
    paste -d' ' "$xkcd_cache/refs" "$xkcd_cache/names" > "$xkcd_file"
}

if [ -f "$xkcd_file" ]; then
    # compute time delta between current date and news file date
	news_date=$(date -r "$xkcd_file" +%s)
	current_date=$(date +%s)

	delta=$((current_date - news_date))

	# refresh xkcd file if it's too old
	if [ $delta -gt $xkcd_refresh ]; then
		get_comic_list
	fi
else
	get_comic_list
fi

((ROFI_ICONS)) && rofi_flags="$rofi_flags -show-icons"
((ROFI_ICONS)) && ((XKCD_GRID)) && rofi_flags="$rofi_flags -theme-str $rofi_theme_grid"

while comic=$(echo -e "Random\x00icon\x1funknown\n$(cat ${xkcd_file})" |\
    awk '{print $N"\x00icon\x1fthumbnail://"$1}' |\
    $ROFI -dmenu -i -p "XKCD" $rofi_flags -preview-cmd "$xkcd_preview"); do

    if [ "$comic" = "Random" ]; then
        comic=$(shuf -n 1 "$xkcd_file")
    fi

    comic_id=$(echo "$comic" | cut -d' ' -f1)
    comic_title=$(echo "$comic" | cut -d' ' -f2-)
    comic_url="https://xkcd.com/$comic_id/info.0.json"
    comic_file="$xkcd_cache/$comic_id"

    if [ ! -f "$comic_file" ]; then
        curl --silent "$comic_url" -o "$comic_file"
        comic_image=$(jq -r '.img' "$comic_file")
        curl --silent "$comic_image" -o "$xkcd_cache/$comic_id.png"
    fi

    comic_alt=$(jq -r '.alt' "$comic_file")
    comic_date=$(jq -r '"\(.day)/\(.month)/\(.year)"' "$comic_file")
    comic_image="$xkcd_cache/$comic_id.png"

    echo -en "Open in Browser\x00icon\x1f$comic_image\n" | \
        $ROFI -dmenu -i -show-icons -theme-str "$rofi_theme_item" -mesg "<b>$comic_title</b> ($comic_date)&#x0a;$comic_alt"

    [ "$?" -eq 0 ] && xdg-open "https://xkcd.com/$comic_id" && exit 0
done

exit 1
