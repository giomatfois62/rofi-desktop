#!/usr/bin/bash
#
# this script search books from annas-archive.org and open pages with download links
#
# dependencies: rofi, python3-requests

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"
ROFI_CACHE_DIR="${ROFI_CACHE_DIR:-$HOME/.cache}"
BOOKS_PLACEHOLDER="Type something and press \"Enter\" to search books"
BOOKS_CACHE="$ROFI_CACHE_DIR/books"
BOOK_ICONS="${BOOK_ICONS:-}"
PREVIEW_CMD="$SCRIPT_PATH/download_icon.sh {input} {output} {size}"
SHOW_PREVIEW=false
SHORTCUTS="-kb-custom-1 "Alt+p""
MESG="<b>Alt+P</b> toggle preview"

mkdir -p "$ROFI_CACHE_DIR"

if [ -n "$BOOK_ICONS" ]; then
    flags="-show-icons"
fi

if [ -z $1 ]; then
    query=$(echo "" | $ROFI_CMD -theme-str "entry{placeholder:\"$BOOKS_PLACEHOLDER\";"} -p "Search Books")
else
    query=$1
fi

if [ -z "$query" ]; then
    exit 1
fi

toggle_preview() {
    if [ "$SHOW_PREVIEW" = false ]; then
        SHOW_PREVIEW=true
        theme_str="mainbox{children:[wrap,listview-split];}wrap{expand:false;orientation:vertical;children:[inputbar,message];}icon-current-entry{expand:true;size:40%;}element-icon{size:3em;}element-text{vertical-align:0.5;}listview-split{orientation:horizontal;children:[listview,icon-current-entry];}listview{lines:8;}"
    else
        SHOW_PREVIEW=false
        theme_str="element-icon{size:3em;}element-text{vertical-align:0.5;}listview{lines:8;}"
    fi
}

toggle_preview
toggle_preview

while [ -n "$query" ]; do
    # search first results page
    counter=1
    selected_row=1

    "$SCRIPT_PATH/scrape_books.py" "$query" "$counter" > "$BOOKS_CACHE"
    result_count=$(cat "$BOOKS_CACHE" | wc -l)

    if [ "$result_count" -lt 1 ]; then
        rofi -e "No results found, try again."
        exit 1
    fi

    books=$(cat "$BOOKS_CACHE" | cut -d' ' -f2- | sed -z 's/\n/|/g' | sed 's/||/\n/g')
    books="$books""More..."

    # display menu
    while true; do
        selection=$(echo -en "$books" | $ROFI_CMD -p "Book" -format 'i s' -sep "|" -eh 2 -selected-row ${selected_row} $SHORTCUTS -theme-str "$theme_str" $flags -mesg "$MESG" -preview-cmd "$PREVIEW_CMD")
        exit_code="$?"
        
        row=$(($(echo "$selection" | cut -d' ' -f1) + 1))
        book=$(echo "$selection" | cut -d' ' -f2-)

        if [ "$exit_code" -eq 10 ]; then
            toggle_preview
        elif [ -z "$book" ]; then
            break
        elif [ "$book" = "More..." ]; then
            # increment page counter and search again
            counter=$((counter+1))
            selected_row=$row

            "$SCRIPT_PATH/scrape_books.py" "$query" "$counter" >> "$BOOKS_CACHE"

            books=$(cat "$BOOKS_CACHE" | cut -d' ' -f2- | sed -z 's/\n/|/g' | sed 's/||/\n/g')
            books="$books""More..."
        else
            # open selected url
            url=$(sed "${row}q;d" "$BOOKS_CACHE" | cut -d' ' -f1)

            xdg-open "$url"

            exit 0
        fi
    done

    query=$(echo "" | $ROFI_CMD -theme-str "entry{placeholder:\"$BOOKS_PLACEHOLDER\";"} -p "Search Books")
done

exit 1
