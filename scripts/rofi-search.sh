#!/bin/bash
#
# this script contains many searching functions for files in the computer
# it remembers recently used files and diplays images in a grid of thumbnails
#
# dependencies: rofi, find, grep
# optional: ripgrep, xclip/wl-clipboard

# TODO: add more file extensions
# TODO: order results by date
# TODO: trash cmd & shortcut

ROFI="${ROFI:-rofi}"
SEARCH_ICONS=${SEARCH_ICONS:-}
GRID_ROWS=${GRID_ROWS:-3}
GRID_COLS=${GRID_COLS:-5}
ICON_SIZE=${ICON_SIZE:-6}

# search params
initial_path="/home/mat"
path="$initial_path"
initial_regex=".*"
regex="$initial_regex" #".*\.\(jpg\|png\|zip\)"
query=""
recent_files=""
file_contents=""
search_type=""
show_menu=""
paste_clip=""
skip_hidden=""

# rofi params
prompt="Search"
message="<b>Enter</b> open file | <b>Alt+C</b> copy to clipboard"
shortcuts="-kb-custom-1 Alt+c"
theme=""
theme_icons="element{orientation:vertical;}element-text{horizontal-align:0.5;}element-icon{size:$ICON_SIZE.0em;}listview{lines:$GRID_ROWS;columns:$GRID_COLS;}"
theme_list="element-icon{size:3em;}element-text{vertical-align:0.5;}listview{lines:7;}"
theme_preview="mainbox{children:[wrap,listview-split];}wrap{expand:false;orientation:vertical;children:[inputbar,message];}icon-current-entry{expand:true;size:40%;}element-icon{size:3em;}element-text{vertical-align:0.5;}listview-split{orientation:horizontal;children:[listview,icon-current-entry];}listview{lines:7;}"

if [ -n "$SEARCH_ICONS" ]; then
    theme="$theme_list"
    message="$message | <b>Alt+Q</b> list-view | <b>Alt+W</b> icons-view | <b>Alt+E</b> list+preview"
    shortcuts="$shortcuts -kb-custom-2 Alt+q -kb-custom-3 Alt+w -kb-custom-4 Alt+e"
    flags="-show-icons -eh 2 -sep | -markup-rows"
fi

format_filename() {
    while read -r path; do
        if [ -f "$path" ]; then
            if [[ -n "$SEARCH_ICONS" || $search_type = "Pictures" ]]; then
                local name=$(basename "$path")
                local dir=$(dirname "$path")
                printf "<b>%s</b>\n<i>%s</i><ICON>%s|" "$name" "$dir" "$path"
            else
                echo "$path"
            fi
        fi
    done
}

compose_filename() {
    echo "$@" \
        | awk 'BEGIN{ RS = "" ; FS = "\n" }{print $2"/"$1}' \
        | sed "s/'\/'/\//" \
        | sed "s/<b>//g;s/<\/b>//g;s/<i>//g;s/<\/i>//g"
}

search_folder() {
    local folder="$1"
    local regex="$2"
    
    #fd -a \
    #    -t f \
    #    --full-path "$@" "$@" | \
    #    format_filename | \
    #    sed -e "s/<ICON>/\x00icon\x1fthumbnail:\/\//g"

    find "$folder" \
        -path "*/.*" -prune -o \
        -type f \
        -regex "$regex" -print | \
        format_filename | \
        sed -e "s/<ICON>/\x00icon\x1fthumbnail:\/\//g"
        
        #-printf "<b>%f</b>\n<i>%h</i><ICON>$folder/%P|" | \
        #sed -e "s/<ICON>/\x00icon\x1fthumbnail:\/\//g"
}

search_recent() {
    grep -oP '(?<=href=").*?(?=")' "$HOME/.local/share/recently-used.xbel" | \
        sort -r | \
        sed 's/file:\/\///' | \
        format_filename | \
        sed -e "s/<ICON>/\x00icon\x1fthumbnail:\/\//g"
}

search_content() {
    local folder="$1"
    local query="$2"

    if command -v rg &> /dev/null; then
        # with ripgrep, filename only
        rg -il "$query" "$folder" | \
            format_filename | \
            sed -e "s/<ICON>/\x00icon\x1fthumbnail:\/\//g"
    else
        # with grep, context and line (-n)
        #grep -riIn --exclude-dir='.*' -E -o ".{0,30}"$query".{0,30}" $folder

        # with grep, filename only
        grep -riIl --exclude-dir='.*' "$query" "$folder" | \
            format_filename | \
            sed -e "s/<ICON>/\x00icon\x1fthumbnail:\/\//g"
    fi
}

menu_folder() {
    local folder="$1"
    local regex="$2"
    
    while true; do
        selected=$(search_folder "$folder" "$regex" | \
            $ROFI -dmenu -i \
            $flags \
            $shortcuts \
            -theme-str "$theme" \
            -p "$prompt" \
            -mesg "$message")
            
        exit_code="$?"

        [[ -n "$SEARCH_ICONS" || "$search_type" = "Pictures" ]] && selected=$(compose_filename "$selected")

        [ "$exit_code" -eq 0 ] && xdg-open "$selected" && exit 0
        [ "$exit_code" -eq 1 ] && break
        [ "$exit_code" -eq 10 ] && copy_to_clip "$selected" && exit 0
        [ "$exit_code" -eq 11 ] && theme="$theme_list"
        [ "$exit_code" -eq 12 ] && theme="$theme_icons"
        [ "$exit_code" -eq 13 ] && theme="$theme_preview"
    done
}

menu_recent() {
    while true; do
        selected=$(search_recent | \
            $ROFI -dmenu -i \
            $flags \
            $shortcuts \
            -theme-str "$theme" \
            -p "$prompt" \
            -mesg "$message")
            
        exit_code="$?"

        [ -n "$SEARCH_ICONS" ] && selected=$(compose_filename "$selected")

        [ "$exit_code" -eq 0 ] && xdg-open "$selected" && exit 0
        [ "$exit_code" -eq 1 ] && break
        [ "$exit_code" -eq 10 ] && copy_to_clip "$selected" && exit 0
        [ "$exit_code" -eq 11 ] && theme="$theme_list"
        [ "$exit_code" -eq 12 ] && theme="$theme_icons"
        [ "$exit_code" -eq 13 ] && theme="$theme_preview"
    done
}

menu_content() {
    local folder="$1"
    local query="$2"
    
    while true; do
        selected=$(search_content "$folder" "$query" | \
            $ROFI -dmenu -i \
            $flags \
            $shortcuts \
            -theme-str "$theme" \
            -p "$prompt" \
            -mesg "$message")
            
        exit_code="$?"

        [ -n "$SEARCH_ICONS" ] && selected=$(compose_filename "$selected")

        [ "$exit_code" -eq 0 ] && xdg-open "$selected" && exit 0
        [ "$exit_code" -eq 1 ] && break
        [ "$exit_code" -eq 10 ] && copy_to_clip "$selected"
        [ "$exit_code" -eq 11 ] && theme="$theme_list"
        [ "$exit_code" -eq 12 ] && theme="$theme_icons"
        [ "$exit_code" -eq 13 ] && theme="$theme_preview"
    done
}

copy_to_clip() {
    if [ -n "$WAYLAND_DISPLAY" ]; then
        wl-copy "$@"
    elif [ -n "$DISPLAY" ]; then
        echo "$@" | xclip -selection clipboard
        [ -n "$paste_clip" ] && coproc ( sleep 0.5; xdotool key "ctrl+v" )
    fi
    
    exit 0
}

init_search() {
    if [ -n "$search_type" ]; then
        case "$search_type" in
            "All")
                regex=".*" ;;
            "Books")
                regex=".*\.\(djvu\|epub\|mobi\|cbr\)" ;;
            "Content")
                file_contents="1" ;;
            "Desktop")
                path="$HOME/Desktop" ;;
            "Documents")
                regex=".*\.\(pdf\|txt\|md\|csv\|xlsx\|doc\|docx\)" ;;
            "Downloads")
                path="$HOME/Downloads" ;;
            "Music")
                regex=".*\.\(mp3\|wav\|m3u\|acc\|flac\|ogg\)" ;;
            "Pictures")
                # always show preview for images
                flags="-show-icons -eh 2 -sep | -markup-rows"
                theme="$theme_icons"
                regex=".*\.\(jpg\|jpeg\|png\|tif\|tiff\|nef\|raw\|dng\|webp\|bmp\|xcf\)" ;;
            "Recent")
                recent_files="1" ;;
            "Videos")
                regex=".*\.\(mkv\|avi\|mp4\|mov\|webm\|yuv\|mpg\|mpeg\|m4v\)" ;;
            *)
                echo "Invalid search type:" "$search_type"
                print_help && exit 1 ;;
        esac
    fi
}

do_search() {
    if [ -n "$recent_files" ]; then
        menu_recent
    elif [ -n "$file_contents" ]; then
        if [ -n "$query" ]; then
            menu_content "$path" "$query"
        else
            while query=$(echo | $ROFI -dmenu -i -p "String to Match"); do
                menu_content "$path" "$query"
            done
        fi
    else
        menu_folder "$path" "$regex"
    fi
}

search_menu() {
    local search_entries="All\nRecent\nContent\nBooks\nDesktop\nDocuments\nDownloads\nMusic\nPictures\nVideos"
    
    # remember last entry chosen
    local selected_row=0
    
    while choice=$(echo -en "$search_entries" | \
        $ROFI -dmenu -i \
            -selected-row ${selected_row} \
            -format 'i s' \
            -p "$prompt"); do

        # reset
        recent_files=""
        file_contents=""
        path="$initial_path"
        regex="$initial_regex"

        [ -z "$SEARCH_ICONS" ] && theme=""
        [ -z "$SEARCH_ICONS" ] && flags=""
        
        selected_row=$(echo "$choice" | awk '{print $1;}')
        search_type=$(echo "$choice" | cut -d' ' -f2-)
        
        init_search
        do_search
    done
    
    exit 1
}

print_help() {
    echo "Available options: [-h|H|p|q|r|R|t|v]"
    echo
    echo "-h     Print this help."
    echo "-H     Include hidden files."
    echo "-m     Show menu with all search types"
    echo "-p     Path to search."
    echo "-q     Query to search in file contents. Overrides all options except path."
    echo "-r     Regex to filter file extensions, eg. \".*\.\(jpg\|png\|zip\)\"."
    echo "-R     Search recently used files. Overrides all options."
    echo "-t     Search file type (All,Books,Desktop,Documents,Downloads,Content,Music,Pictures,Recent,Videos)."
    echo "-v     Paste clipboard when copy shortcut is pressed"
    echo "       Can override path or regex."
    echo
}

while getopts ":hHmRr:p:q:t:v" option; do
    case $option in
        h) # display help
            print_help && exit 1;;
        H) # include hidden files
            skip_hidden="" ;;
        m) # show menu with all search types
            show_menu="1" ;;
        p) # path to search
            initial_path="$OPTARG" 
            path="$initial_path" ;;
        q) # content to search
            file_contents="1"
            query="$OPTARG" ;;
        r) # regex to filter files
            initial_regex="$OPTARG" 
            regex="$initial_regex" ;;
        R) # search recent files
            recent_files="1" ;;
        t) # search file type
            search_type="$OPTARG" ;;
        v) # auto paste clipboard
            paste_clip="1" ;;
        \?) # display help and exit
            echo "Invalid option:" "$1"
            print_help && exit 1 ;;
    esac
done

if [ -n "$show_menu" ]; then
    search_menu
else
    init_search
    do_search
fi

exit 1
