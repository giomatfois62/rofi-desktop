#!/usr/bin/env bash

# optional: fd

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"
ROFI_CMD="rofi -dmenu -i"
SHOW_HIDDEN_FILES=false
HISTORY_FILE="$HOME/.cache/rofi-search-history"
MAX_ENTRIES=100

declare -A commands=(
    ["All Files"]=search_all
    ["Recent Files"]=search_recent
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

# TODO: add more file extensions
# TODO: order results by date

search_menu() {
    entries="All Files\nRecent Files\nFile Contents\nBookmarks\nBooks\nDesktop\nDocuments\nDownloads\nMusic\nPictures\nVideos\nTNT Village"

    # remember last entry chosen
    local choice_row=0
    local choice_text

    while choice=$(echo -en "$entries" | $ROFI_CMD -matching fuzzy -selected-row ${choice_row} -format 'i s' -p "Search"); do
        if [ ${#choice} -gt 0 ]; then
            choice_row=$(echo "$choice" | awk '{print $1;}')
            choice_text=$(echo "$choice" | cut -d' ' -f2-)

            ${commands[$choice_text]};
        fi
    done

    exit 1
}

has_fd() {
    if command -v fd &> /dev/null; then
        echo "yes"
    fi
}

has_rg() {
    if command -v rg &> /dev/null; then
        echo "yes"
    fi
}

search_command() {
    local folder="$1" # Save first argument in a variable
    shift # Shift all arguments to the left
    local extensions=("$@") # Rebuild the array with rest of arguments

    local cmd
    local cmd_extensions

    if [ "$(has_fd)" == "yes" ]; then
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

    if [ "$(wc -l "$HISTORY_FILE" | awk '{ print $1 }')" -gt $MAX_ENTRIES ]; then
        tmp_file="$HISTORY_FILE"".tmp"
        tail -n +2 "$HISTORY_FILE" > "$tmp_file"
        mv "$tmp_file" "$HISTORY_FILE"
    fi
}

open_file() {
    add_to_history "$@"
    xdg-open "$@"
}

search_all() {
    local selected

    selected=$(eval "$(search_command "$HOME")" | $ROFI_CMD -p "All Files")

	if [ ${#selected} -gt 0 ]; then
        open_file "$HOME/$selected"
        exit 0
    fi
}

search_recent() {
	recently_used_file="$HOME/.local/share/recently-used.xbel"
	recently_used=$(grep -oP '(?<=href=").*?(?=")' "$recently_used_file" | sort -r)

    selected=$(tac "$HISTORY_FILE" | $ROFI_CMD -p "Recent Files")

	if [ ${#selected} -gt 0 ]; then
        open_file "$selected"
        exit 0
    fi
}

search_contents() {
	# use a while loop to keep searching
	while query=$(echo | $ROFI_CMD -p "String to Match"); do
		if [ ${#query} -gt 0 ]; then
			if command -v rg &> /dev/null; then
		    	selected=$(rg -i -l "${query}" "$HOME" | $ROFI_CMD -p "Matches")
			else
				# warning! it's slow and blocks opening file until search is finished
				selected=$(grep -ri --exclude-dir='.*' -m 1 -I -l "${query}" "$HOME" | $ROFI_CMD -p "Matches")
			fi
		    
			if [ ${#selected} -gt 0 ]; then
				open_file "$selected"
				exit 0
			fi
		fi
	done
}

search_books() {
    local selected
    local extensions=("djvu" "epub" "mobi")

    selected=$(eval "$(search_command "$HOME" "${extensions[@]}")" | $ROFI_CMD -p "Books")

    if [ ${#selected} -gt 0 ]; then
        open_file "$HOME/$selected"
        exit 0
    fi
}

search_bookmarks() {
    "$SCRIPT_PATH"/rofi-firefox.sh && exit 0
}

search_documents() {
    local selected
    local extensions=("pdf" "txt" "md" "xlsx" "doc" "docx")

    selected=$(eval "$(search_command "$HOME" "${extensions[@]}")" | $ROFI_CMD -p "Documents")

    if [ ${#selected} -gt 0 ]; then
        open_file "$HOME/$selected"
        exit 0
    fi
}

search_downloads() {
    local selected

    selected=$(eval "$(search_command "$HOME"/Downloads)" | $ROFI_CMD -p "Downloads")

	if [ ${#selected} -gt 0 ]; then
        open_file "$HOME/Downloads/$selected"
        exit 0
    fi
}

search_desktop() {
    local selected

    selected=$(eval "$(search_command "$HOME"/Desktop)" | $ROFI_CMD -p "Desktop")

	if [ ${#selected} -gt 0 ]; then
        open_file "$HOME/Desktop/$selected"
        exit 0
    fi
}

search_music() {
    local selected
    local extensions=("mp3" "wav" "m3u" "aac" "flac" "ogg")

    selected=$(eval "$(search_command "$HOME" "${extensions[@]}")" | $ROFI_CMD -p "Music")

    if [ ${#selected} -gt 0 ]; then
        open_file "$HOME/$selected"
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

    selected=$(eval "$(search_command "$HOME" "${extensions[@]}")" | while read A ; do echo -en "$A\x00icon\x1f$HOME/$A\n" ; done | $ROFI_CMD -show-icons -theme-str "$(build_theme 3 4 8)" -p "Pictures")

    if [ ${#selected} -gt 0 ]; then
        open_file "$HOME/$selected"
        exit 0
    fi
}

search_tnt() {
    "$SCRIPT_PATH"/rofi-tnt.sh && exit 0
}

search_videos() {
    local selected
    local extensions=("mkv" "mp4")

    selected=$(eval "$(search_command "$HOME" "${extensions[@]}")" | $ROFI_CMD -p "Videos")

    if [ ${#selected} -gt 0 ]; then
        open_file "$HOME/$selected"
        exit 0
    fi
}

search_menu
