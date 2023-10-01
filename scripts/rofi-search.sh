#!/usr/bin/env bash
#
# this script contains many searching functions for files in the computer
# it remembers recently used files and diplays images in a grid of thumbnails
#
# dependencies: rofi, find, grep
# optional: fd, ripgrep

# TODO: add more file extensions
# TODO: order results by date

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"
SHOW_HIDDEN_FILES=${SHOW_HIDDEN_FILES:-false}
HISTORY_FILE="${HISTORY_FILE:-$HOME/.cache/rofi-search-history}"
MAX_HISTORY_ENTRIES=${MAX_HISTORY_ENTRIES:-100}
SHOW_CONTEXT=${SHOW_CONTEXT:-}
GRID_ROWS=${GRID_ROWS:-3}
GRID_COLS=${GRID_COLS:-5}
ICON_SIZE=${ICON_SIZE:-6}

SEARCH_SHORTCUTS_HELP="Press \"Enter\" to open selected file&#x0a;Press \"Alt+C\" to copy selected file to clipboard&#x0a;Press \"Alt+D\" to remove selected file"

search_shortcuts="-kb-custom-1 "Alt+c" -kb-custom-2 "Alt+d""

declare -A commands=(
    ["All Files"]=search_all
    ["Recently Used"]=search_recent
    ["File Contents"]=search_contents
    ["Bookmarks"]=search_bookmarks
    ["Books"]=search_books
    ["Documents"]=search_documents
    ["Desktop"]=search_desktop
    ["Downloads"]=search_downloads
    ["Music"]=search_music
    ["Pictures"]=search_pics
    ["TNT Village"]=search_tnt
    ["Videos"]=search_videos
)

search_entries="All Files\nRecently Used\nFile Contents\nBookmarks\nBooks\nDesktop\nDocuments\nDownloads\nMusic\nPictures\nVideos\nTNT Village"

search_menu() {
    if [ -n "$1" ]; then
         ${commands["$1"]}
    else
        # remember last entry chosen
        local selected_text=0
        local selected_text

        while choice=$(echo -en "$search_entries" | $ROFI_CMD -matching fuzzy -selected-row ${selected_text} -format 'i s' -p "Search"); do
            selected_text=$(echo "$choice" | awk '{print $1;}')
            selected_text=$(echo "$choice" | cut -d' ' -f2-)

            ${commands[$selected_text]};
        done
    fi
}

search_command() {
    local folder="$1" # Save first argument in a variable
    shift # Shift all arguments to the left
    local extensions=("$@") # Rebuild the array with rest of arguments

    local cmd
    local cmd_extensions

    if command -v fd &> /dev/null; then
        for i in "${extensions[@]}"; do
            cmd_extensions=$cmd_extensions" -e $i"
        done

        # sort by mtime is very slow with many files
        #sort_cmd="--exec stat --printf=\"%Y\\t%n\\n\" | sort -nr | cut -f2"

        if [ "$SHOW_HIDDEN_FILES" = true ]; then
            cmd="cd $folder && fd -H --type f $cmd_extensions"
        else
            cmd="cd $folder && fd --type f $cmd_extensions"
        fi

		echo "$cmd"
    else
        count=0
        for i in "${extensions[@]}"; do
            if [ $count -eq 0 ]; then
                cmd_extensions=$cmd_extensions" -iname *.$i"
            else
                cmd_extensions=$cmd_extensions" -o -iname *.$i"
            fi
            count=$((count+1))
        done

        if [ "$SHOW_HIDDEN_FILES" = true ]; then
            cmd="cd $folder && find . -type f $cmd_extensions"
        else
            cmd="cd $folder && find . -not -path '*/.*' -type f $cmd_extensions"
        fi

		echo "$cmd | cut -c 3-"
    fi
}

add_to_history() {
    touch "$HISTORY_FILE"
    grep -Fxq "$1" "$HISTORY_FILE" || echo "$1" >> "$HISTORY_FILE"

    if [ "$(wc -l "$HISTORY_FILE" | awk '{ print $1 }')" -gt $MAX_HISTORY_ENTRIES ]; then
        tmp_file="$HISTORY_FILE"".tmp"
        tail -n +2 "$HISTORY_FILE" > "$tmp_file"
        mv "$tmp_file" "$HISTORY_FILE"
    fi
}

copy_cmd() {
    if [ -n "$WAYLAND_DISPLAY" ]; then
        wl-copy "$1"
    elif [ -n "$DISPLAY" ]; then
        echo "$1" | xclip -selection clipboard
    fi
}

trash_cmd() {
    if command -v kioclient5 &> /dev/null; then
        kioclient5 move "$1" trash:/
    elif command -v gio &> /dev/null; then
        gio trash "$1"
    fi
}

open_file() {
    exit_code="$1"
    filename="$2"

    add_to_history "$filename"

    [ "$exit_code" -eq 0 ] && xdg-open "$filename"
    [ "$exit_code" -eq 10 ] && copy_cmd "$filename"
    [ "$exit_code" -eq 11 ] && trash_cmd "$filename"
}

search_all() {
    local selected

    selected=$(eval "$(search_command "$HOME")" | $ROFI_CMD $search_shortcuts -mesg "$SEARCH_SHORTCUTS_HELP" -p "All Files")
    exit_code="$?"

	if [ -n "$selected" ]; then
        open_file "$exit_code" "$HOME/$selected"
        exit 0
    fi
}

search_recent() {
    recently_used_file="$HOME/.local/share/recently-used.xbel"
    recently_used=$(grep -oP '(?<=href=").*?(?=")' "$recently_used_file" | sort -r | sed 's/file:\/\///')

    list_recent() {
        tac "$HISTORY_FILE"
        echo -e "$recently_used"
    }

    selected=$(list_recent | $ROFI_CMD $search_shortcuts -mesg "$SEARCH_SHORTCUTS_HELP"  -p "Recent Files")
    exit_code="$?"

    if [ -n "$selected" ]; then
        open_file "$exit_code" "$selected"
        exit 0
    fi
}

# show multiline context
# grep -ri -E -o ".{0,40}hello.{0,40}" | sed 's/$/|/' | sed 's/:/\n/' | sed '/|$/{N;s/\n//}' | rofi -dmenu -i -eh 2 -sep "|" | head -n 1

search_contents() {
	# use a while loop to keep searching
	while query=$(echo | $ROFI_CMD -p "String to Match"); do
        [ -z "$query" ] && break

        if command -v rg &> /dev/null; then
            if [ -n "$SHOW_CONTEXT" ]; then
                selected=$(cd "$HOME" && rg -i -e ".{0,30}${query}.{0,30}" | $ROFI_CMD -p "Matches" | cut -d':' -f1)
            else
                selected=$(cd "$HOME" && rg -i -l "${query}" | $ROFI_CMD -p "Matches")
            fi
        else
            if [ -n "$SHOW_CONTEXT" ]; then
                selected=$(cd "$HOME" && grep -ri --exclude-dir='.*' -E -o ".{0,30}${query}.{0,30}" | $ROFI_CMD -p "Matches" | cut -d':' -f1)
            else
                selected=$(cd "$HOME" && grep -ri --exclude-dir='.*' -m 1 -I -l "${query}" | $ROFI_CMD -p "Matches")
            fi
        fi

        exit_code="$?"

        if [ -n "$selected" ]; then
            open_file "$exit_code" "$HOME/$selected"
            exit 0
        fi
	done
}

search_books() {
    local selected
    local extensions=("djvu" "epub" "mobi")

    selected=$(eval "$(search_command "$HOME" "${extensions[@]}")" | $ROFI_CMD $search_shortcuts -mesg "$SEARCH_SHORTCUTS_HELP" -p "Books")
    exit_code="$?"

    if [ -n "$selected" ]; then
        open_file "$exit_code" "$HOME/$selected"
        exit 0
    fi
}

search_bookmarks() {
    "$SCRIPT_PATH"/rofi-firefox.sh && exit 0
}

search_documents() {
    local selected
    local extensions=("pdf" "txt" "md" "xlsx" "doc" "docx")

    selected=$(eval "$(search_command "$HOME" "${extensions[@]}")" | $ROFI_CMD $search_shortcuts -mesg "$SEARCH_SHORTCUTS_HELP" -p "Documents")

    if [ -n "$selected" ]; then
        open_file "$HOME/$selected"
        exit 0
    fi
}

search_downloads() {
    local selected

    selected=$(eval "$(search_command "$HOME"/Downloads)" | $ROFI_CMD $search_shortcuts -mesg "$SEARCH_SHORTCUTS_HELP" -p "Downloads")
    exit_code="$?"

	if [ -n "$selected" ]; then
        open_file "$exit_code"  "$HOME/Downloads/$selected"
        exit 0
    fi
}

search_desktop() {
    local selected

    selected=$(eval "$(search_command "$HOME"/Desktop)" | $ROFI_CMD $search_shortcuts -mesg "$SEARCH_SHORTCUTS_HELP" -p "Desktop")
    exit_code="$?"

	if [ -n "$selected" ]; then
        open_file "$exit_code" "$HOME/Desktop/$selected"
        exit 0
    fi
}

search_music() {
    local selected
    local extensions=("mp3" "wav" "m3u" "aac" "flac" "ogg")

    selected=$(eval "$(search_command "$HOME" "${extensions[@]}")" | $ROFI_CMD $search_shortcuts -mesg "$SEARCH_SHORTCUTS_HELP" -p "Music")
    exit_code="$?"

    if [ -n "$selected" ]; then
        open_file "$exit_code" "$HOME/$selected"
        exit 0
    fi
}

build_theme() {
    rows=$1
    cols=$2
    icon_size=$3

    echo "element{orientation:vertical;}element-text{horizontal-align:0.5;}element-icon{size:$icon_size.0000em;}listview{lines:$rows;columns:$cols;}"
}

search_pics() {
    # TODO: change theme with keybind
    local selected
    local extensions=("jpg" "jpeg" "png" "tif" "tiff" "nef" "raw" "dng" "webp")

    selected=$(eval "$(search_command "$HOME" "${extensions[@]}")" | while read A ; do echo -en "$A\x00icon\x1f$HOME/$A\n" ; done | $ROFI_CMD -show-icons -theme-str "$(build_theme $GRID_ROWS $GRID_COLS $ICON_SIZE)" $search_shortcuts -mesg "$SEARCH_SHORTCUTS_HELP" -p "Pictures")
    exit_code="$?"

    if [ -n "$selected" ]; then
        open_file "$exit_code" "$HOME/$selected"
        exit 0
    fi
}

search_tnt() {
    "$SCRIPT_PATH"/rofi-tnt.sh && exit 0
}

search_videos() {
    local selected
    local extensions=("mkv" "mp4")

    selected=$(eval "$(search_command "$HOME" "${extensions[@]}")" | $ROFI_CMD $search_shortcuts -mesg "$SEARCH_SHORTCUTS_HELP" -p "Videos")
    exit_code="$?"

    if [ -n "$selected" ]; then
        open_file "$exit_code" "$HOME/$selected"
        exit 0
    fi
}

search_menu "$1"

exit 1
