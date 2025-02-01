#!/usr/bin/bash
#
# this script search books from annas-archive.org and open pages with download links
#
# dependencies: rofi, python3-requests

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI="${ROFI:-rofi}"
ROFI_CACHE_DIR="${ROFI_CACHE_DIR:-$HOME/.cache}"
ROFI_ICONS="${ROFI_ICONS:-}"
ROFI_GRID_ROWS=${ROFI_GRID_ROWS:-3}
ROFI_GRID_COLS=${ROFI_GRID_COLS:-4}
ROFI_GRID_ICON_SIZE=${ROFI_GRID_ICON_SIZE:-8}
ROFI_LIST_ICON_SIZE=${ROFI_LIST_ICON_SIZE:-3}

book_query="$@"
book_cache="$ROFI_CACHE_DIR/books"
book_preview="$SCRIPT_PATH/download_icon.sh {input} {output} {size}"

rofi_shortcuts="-kb-custom-1 Alt+q -kb-custom-2 Alt+w -kb-custom-3 Alt+e"
rofi_mesg="<b>Enter</b> open download page"
rofi_flags="-eh 2 -sep | -markup-rows"

rofi_theme_list="element-icon{size:$ROFI_LIST_ICON_SIZE.0em;}\
element-text{vertical-align:0.5;}\
listview{lines:7;}"

rofi_theme_grid="element{orientation:vertical;}\
element-text{horizontal-align:0.5;}\
element-icon{size:$ROFI_GRID_ICON_SIZE.0em;}\
listview{lines:$ROFI_GRID_ROWS;columns:$ROFI_GRID_COLS;}"

rofi_theme_preview="mainbox{children:[wrap,listview-split];}\
wrap{expand:false;orientation:vertical;children:[inputbar,message];}\
icon-current-entry{expand:true;size:30%;}\
element-icon{size:$ROFI_LIST_ICON_SIZE.0em;}\
element-text{vertical-align:0.5;}\
listview-split{orientation:horizontal;children:[listview,icon-current-entry];}\
listview{lines:7;}"

# default theme
rofi_theme="$rofi_theme_list"

((ROFI_ICONS)) && rofi_flags="$rofi_flags -show-icons"
((ROFI_ICONS)) && rofi_mesg="$rofi_mesg | <b>Alt+Q</b> list-view | <b>Alt+W</b> icons-view | <b>Alt+E</b> list+preview"

[ -z "$book_query" ] && book_query=$($ROFI -dmenu -i -p "Search Books")
[ -z "$book_query" ] && exit 1

while [ -n "$book_query" ]; do
    # search first results page
    page=1
    row=1

    "$SCRIPT_PATH/scrape_books.py" "$book_query" "$page" > "$book_cache"

    books_count=$(cat "$book_cache" | wc -l)

    if [ "$books_count" -lt 1 ]; then
        $ROFI -e "No books found, try again."
        exit 1
    fi

    books=$(cat "$book_cache" | cut -d' ' -f2- | sed -z 's/\n/|/g' | sed 's/||/\n/g')
    books="$books""More...\x00icon\x1flist-add"

    # display menu
    while true; do
        selection=$(echo -en "$books" | \
            $ROFI -dmenu -i -p "Book" $rofi_shortcuts $rofi_flags \
            -format 'i s' -selected-row ${row} -theme-str "$rofi_theme" \
            -mesg "$rofi_mesg" -preview-cmd "$book_preview")

        exit_code="$?"
        
        row=$(($(echo "$selection" | cut -d' ' -f1) + 1))
        book=$(echo "$selection" | cut -d' ' -f2-)

        [ "$exit_code" -eq 1 ]  && break
        [ "$exit_code" -eq 10 ] && rofi_theme="$rofi_theme_list"
        [ "$exit_code" -eq 11 ] && rofi_theme="$rofi_theme_grid"
        [ "$exit_code" -eq 12 ] && rofi_theme="$rofi_theme_preview"
        
        if [ "$book" = "More..." ]; then
            # increment page page and search again
            page=$((page+1))
            row=$row

            "$SCRIPT_PATH/scrape_books.py" "$book_query" "$page" >> "$book_cache"

            books=$(cat "$book_cache" | cut -d' ' -f2- | sed -z 's/\n/|/g' | sed 's/||/\n/g')
            books="$books""More...\x00icon\x1flist-add"
        elif [ "$exit_code" -eq 0 ]; then
            # open selected url
            url=$(sed "${row}q;d" "$book_cache" | cut -d' ' -f1)

            xdg-open "$url"

            exit 0
        fi
    done

    book_query=$($ROFI -dmenu -i -p "Search Books")
done

exit 1
