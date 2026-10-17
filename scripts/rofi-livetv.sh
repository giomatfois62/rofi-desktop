#!/bin/bash
#
# this script scrape and show the list of upcoming sport events streamed on livetv.sx
#
# dependencies: rofi, curl, xmllint

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI="${ROFI:-rofi}"
ROFI_CACHE_DIR="${ROFI_CACHE_DIR:-$HOME/.cache}"
ROFI_ICONS="${ROFI_ICONS:-}"

livetv_base="https://livetv905.me"
livetv_url=$livetv_base"/enx/allupcomingsports/"
# refresh livetv file every hour
livetv_refresh=3600
livetv_file="$ROFI_CACHE_DIR/livetv"
livetv_preview="$SCRIPT_PATH/download_icon.sh {input} {output} {size}"

rofi_flags=""

((ROFI_ICONS)) && rofi_flags="-show-icons"

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
	file_date=$(date -r "$livetv_file" +%s)
	current_date=$(date +%s)

	delta=$((current_date - file_date))

	# refresh livetv file if it's too old
	if [ $delta -gt $livetv_refresh ]; then
		curl --insecure -s "$livetv_url" -o "$livetv_file"
	fi
else
	curl --insecure -s "$livetv_url" -o "$livetv_file"
fi

# remove newlinesfrom event title and description
events=$(cat "$livetv_file" | sed 's/<br>/ /g')

# extract events data
names_xpath='//table[@align="center"]//tr/td/a[@class="live"]/text()'
links_xpath='//table[@align="center"]//tr/td/a[@class="live"]/@href'
desc_xpath='//table[@align="center"]//tr/td/span[@class="evdesc"]/text()'
icons_xpath='//table[@align="center"]//tr/td[@align="center"]/img/@src'
names=$(echo $events | xmllint --html --xpath $names_xpath -)
links=$(echo $events | xmllint --html --xpath $links_xpath -)
descs=$(echo $events | xmllint --html --xpath $desc_xpath -)
icons=$(echo $events | xmllint --html --xpath $icons_xpath - | sed -e 's/^[^"]*"//' -e 's/"$//' | sed 's/^/https:/g')

# format rofi entries
names=$(paste -d'|' <(echo "$names" | awk '{$1=$1;print}') <(echo "$icons" | awk '{$1=$1;print}') | sed 's/|/<ICON>/g')
entries=$(paste -d'|' <(echo "$descs" | awk '{$1=$1;print}' | awk 'length > 45{$0=substr($0,0,46)"..."}1') <(echo "$names" | awk '{$1=$1;print}') <(echo "$links" | awk '{$1=$1;print}'))

while match=$(echo -en "$entries" |\
    sort | cut -d'|' -f1-2 | column -s "|" -t | sed -e "s/<ICON>/\\x00icon\\x1fthumbnail:\/\//g" |\
    $ROFI $rofi_flags -preview-cmd "$livetv_preview" -dmenu -i -p "Events" -format 'i s'); do
    match_index=$(echo "$match" | cut -d' ' -f1)
    match_index=$((match_index+1))
	match_link=$(echo "$entries" |\
       sort | sed -n "$match_index p" |\
       cut -d'|' -f3 |\
       sed -e 's/^[^"]*"//' -e 's/"$//')

    xdg-open "$livetv_base$match_link"
    exit 0
done

exit 1
