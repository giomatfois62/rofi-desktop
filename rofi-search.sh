#!/usr/bin/env bash

# optional: fd

SCRIPT_PATH="$HOME/Downloads/rofi-desktop"
ROFI_CMD="rofi -dmenu -i"
SHOW_HIDDEN_FILES=false

entries=("All Files\nBookmarks\nBooks\nDesktop\nDocuments\nDownloads\nMusic\nPictures\nVideos\nTNT Village")

declare -A commands=(
    ["All Files"]=search_all
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

has_fd() {
    if command -v fd &> /dev/null; then
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
            cmd="cd $folder && fd -H --ignore --type f $cmd_extensions"
        else
            cmd="cd $folder && fd --ignore --type f $cmd_extensions"
        fi
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
    fi

    echo "$cmd | cut -c 3-"
}

search_all() {
    local selected

    selected=`eval "$(search_command $HOME)" | $ROFI_CMD -p "All Files"`

	if [ ${#selected} -gt 0 ]; then
        xdg-open "$HOME/$selected"
        exit 0
    fi
}

search_books() {
    local selected
    local extensions=("djvu" "epub" "mobi")

    selected=`eval "$(search_command $HOME "${extensions[@]}")" | $ROFI_CMD -p "Books"`

    if [ ${#selected} -gt 0 ]; then
        xdg-open "$HOME/$selected"
        exit 0
    fi
}

search_bookmarks() {
	$SCRIPT_PATH/rofi-firefox.sh && exit 0
}

search_documents() {
    local selected
    local extensions=("pdf" "txt" "md" "xlsx" "doc" "docx")

    selected=`eval "$(search_command $HOME "${extensions[@]}")" | $ROFI_CMD -p "Documents"`

    if [ ${#selected} -gt 0 ]; then
        xdg-open "$HOME/$selected"
        exit 0
    fi
}

search_downloads() {
    local selected

    selected=`eval "$(search_command $HOME/Downloads)" | $ROFI_CMD -p "Downloads"`

	if [ ${#selected} -gt 0 ]; then
        xdg-open "$HOME/Downloads/$selected"
        exit 0
    fi
}

search_desktop() {
    local selected

    selected=`eval "$(search_command $HOME/Desktop)" | $ROFI_CMD -p "Desktop"`

	if [ ${#selected} -gt 0 ]; then
        xdg-open "$HOME/Desktop/$selected"
        exit 0
    fi
}

search_music() {
    local selected
    local extensions=("mp3" "wav" "m3u" "aac" "flac" "ogg")

    selected=`eval "$(search_command $HOME "${extensions[@]}")" | $ROFI_CMD -p "Music"`

    if [ ${#selected} -gt 0 ]; then
        xdg-open "$HOME/$selected"
        exit 0
    fi
}

build_theme() {
    rows=$1
    cols=$2
    icon_size=$3

    echo "element{orientation:vertical;}element-text{horizontal-align:0.5;}element-icon{size:$icon_size.0000em;}listview{lines:$rows;columns:$2;}"
}

search_pics() {
    # TODO: change theme with keybind
    local selected
    local extensions=("jpg" "jpeg" "png" "tif" "tiff" "nef" "raw" "dng" "webp")

    selected=`eval "$(search_command $HOME "${extensions[@]}")" | while read A ; do echo -en "$A\x00icon\x1f$HOME/$A\n" ; done | $ROFI_CMD -show-icons -theme-str $(build_theme 3 4 10) -p "Pictures"`

    if [ ${#selected} -gt 0 ]; then
        xdg-open "$HOME/$selected"
        exit 0
    fi
}

search_tnt() {
	$SCRIPT_PATH/rofi-tnt.sh && exit 0
}

search_videos() {
    local selected
    local extensions=("mkv" "mp4")

    selected=`eval "$(search_command $HOME "${extensions[@]}")" | $ROFI_CMD -p "Videos"`

    if [ ${#selected} -gt 0 ]; then
        xdg-open "$HOME/$selected"
        exit 0
    fi
}

while choice=`echo -en $entries | $ROFI_CMD -matching fuzzy -p Search`; do
    if [ ${#choice} -gt 0 ]; then
        ${commands[$choice]};
    fi
done

exit 1
