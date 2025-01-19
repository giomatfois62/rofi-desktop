#!/usr/bin/bash
#
# this script search books from annas-archive.org and open pages with download links
#
# dependencies: rofi, python3-requests

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI="${ROFI:-rofi}"
ROFI_CACHE_DIR="${ROFI_CACHE_DIR:-$HOME/.cache}"
BOOK_ICONS="${BOOK_ICONS:-}"
GRID_ROWS=${GRID_ROWS:-4}
GRID_COLS=${GRID_COLS:-5}
GRID_ICON_SIZE=${GRID_ICON_SIZE:-4}
LIST_ICON_SIZE=${LIST_ICON_SIZE:-3}

book_cache="$ROFI_CACHE_DIR/books"
preview_cmd="$SCRIPT_PATH/download_icon.sh {input} {output} {size}"
rofi_shortcuts="-kb-custom-1 Alt+q -kb-custom-2 Alt+w -kb-custom-3 Alt+e"
rofi_mesg="<b>Enter</b> download book | <b>Alt+Q</b> list-view | <b>Alt+W</b> icons-view | <b>Alt+E</b> list+preview"
rofi_flags="-eh 2 -sep | -markup-rows"
rofi_theme_list="element-icon{size:$LIST_ICON_SIZE.0em;}element-text{vertical-align:0.5;}listview{lines:7;}"
rofi_theme_grid="element{orientation:vertical;}element-text{horizontal-align:0.5;}element-icon{size:$GRID_ICON_SIZE.0em;}listview{lines:$GRID_ROWS;columns:$GRID_COLS;}"
rofi_theme_preview="mainbox{children:[wrap,listview-split];}wrap{expand:false;orientation:vertical;children:[inputbar,message];}icon-current-entry{expand:true;size:30%;}element-icon{size:3em;}element-text{vertical-align:0.5;}listview-split{orientation:horizontal;children:[listview,icon-current-entry];}listview{lines:7;}"
rofi_theme="$rofi_theme_list"

mkdir -p "$ROFI_CACHE_DIR"

if [ -n "$BOOK_ICONS" ]; then
    rofi_flags="$rofi_flags -show-icons"
fi

if [ -z $1 ]; then
    query=$(echo "" | $ROFI -dmenu -i -p "Search Books")
else
    query=$1
fi

if [ -z "$query" ]; then
    exit 1
fi

while [ -n "$query" ]; do
    # search first results page
    counter=1
    selected_row=1

    "$SCRIPT_PATH/scrape_books.py" "$query" "$counter" > "$book_cache"
    result_count=$(cat "$book_cache" | wc -l)

    if [ "$result_count" -lt 1 ]; then
        $ROFI -e "No results found, try again."
        exit 1
    fi

    books=$(cat "$book_cache" | cut -d' ' -f2- | sed -z 's/\n/|/g' | sed 's/||/\n/g')
    books="$books""More..."

    # display menu
    while true; do
        selection=$(echo -en "$books" | \
            $ROFI -dmenu -i \
            $rofi_shortcuts \
            $rofi_flags \
            -p "Book" \
            -format 'i s' \
            -selected-row ${selected_row} \
            -theme-str "$rofi_theme" \
            -mesg "$rofi_mesg" \
            -preview-cmd "$preview_cmd")
        exit_code="$?"
        
        row=$(($(echo "$selection" | cut -d' ' -f1) + 1))
        book=$(echo "$selection" | cut -d' ' -f2-)

        [ "$exit_code" -eq 1 ] && break
        [ "$exit_code" -eq 10 ] && rofi_theme="$rofi_theme_list"
        [ "$exit_code" -eq 11 ] && rofi_theme="$rofi_theme_grid"
        [ "$exit_code" -eq 12 ] && rofi_theme="$rofi_theme_preview"
        
        if [ "$book" = "More..." ]; then
            # increment page counter and search again
            counter=$((counter+1))
            selected_row=$row

            "$SCRIPT_PATH/scrape_books.py" "$query" "$counter" >> "$book_cache"

            books=$(cat "$book_cache" | cut -d' ' -f2- | sed -z 's/\n/|/g' | sed 's/||/\n/g')
            books="$books""More..."
        elif [ "$exit_code" -eq 0 ]; then
            # open selected url
            url=$(sed "${row}q;d" "$book_cache" | cut -d' ' -f1)

            xdg-open "$url"

            exit 0
        fi
    done

    query=$(echo "" | $ROFI -dmenu -i -p "Search Books")
done

exit 1
