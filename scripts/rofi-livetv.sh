#!/bin/bash
#
# this script scrape and show the list of upcoming sport events streamed on livetv.sx
#
# dependencies: rofi, jq, curl

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI="${ROFI:-rofi}"
ROFI_CACHE_DIR="${ROFI_CACHE_DIR:-$HOME/.cache}"

livetv_url="https://webmaster.livetv.club/list.php?id=21&sport=&sp=&r=_ru"
livetv_refresh=3600 # refresh livetv file every hour
livetv_file="$ROFI_CACHE_DIR/livetv"
livetv_preview="$SCRIPT_PATH/download_icon.sh {input} {output} {size}"

fix_link() {
    local link="$1"

    if [[ "$link" = "//"* ]]; then
        echo "https://$link"
    else
        echo "$link"
    fi
}

if [ -f "$livetv_file" ]; then
    # compute time delta between current date and news file date
	news_date=$(date -r "$livetv_file" +%s)
	current_date=$(date +%s)

	delta=$((current_date - news_date))

	# refresh livetv file if it's too old
	if [ $delta -gt $livetv_refresh ]; then
		curl -s "$livetv_url" -o "$livetv_file"
	fi
else
	curl -s "$livetv_url" -o "$livetv_file"
fi

matches=$(cat "$livetv_file" | grep -o -P '(?<=ev_arr = ).*(?=;)')
channels=$(cat "$livetv_file" | grep -o -P '(?<=chan_arr = ).*(?=;)')

while match=$(echo "$matches" |\
    jq -r '.[] | "\(.date | sub(":00"; "")) [\(.sport)]\(.match)<ICON>\(.country)"' |\
    sed -e "s/<ICON>/\\x00icon\\x1fthumbnail:\/\/https:\/\/livetv.club\/img\/countries\//g" |\
    $ROFI -show-icons -dmenu -i -p "Events" -preview-cmd "$livetv_preview"); do
    match_name=$(echo "$match" | cut -d']' -f2-)
    match_id=$(echo "$matches" | jq ".[] | select(.match==\"$match_name\") | .id")
    match_links=$(echo "$channels" | jq -r ".[$match_id]" | jq -r ".[] | select(.type==\"Flash\") | .link")

    if [ -n "$match_links" ]; then
        link=$(echo "$match_links" | $ROFI -dmenu -i -p "$match_name Links")
        
        [[ -n "$link" ]] && xdg-open $(fix_link "$link") && exit 0
    else
        rofi -e "No stream links available for "$match", retry later."
    fi
done

exit 1
