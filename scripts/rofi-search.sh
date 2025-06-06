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
ROFI_ICONS=${ROFI_ICONS:-}
ROFI_GRID_ROWS=${ROFI_GRID_ROWS:-4}
ROFI_GRID_COLS=${ROFI_GRID_COLS:-5}
ROFI_GRID_ICON_SIZE=${ROFI_GRID_ICON_SIZE:-4}
ROFI_LIST_ICON_SIZE=${ROFI_LIST_ICON_SIZE:-3}

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
rofi_prompt="Search"
rofi_mesg="<b>Enter</b> open file | <b>Alt+C</b> copy to clipboard"
rofi_shortcuts="-kb-custom-1 Alt+c"
rofi_flags=""
rofi_search_flags=""
rofi_theme=""

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

if ((ROFI_ICONS)); then
    rofi_theme="$rofi_theme_list"
    rofi_mesg="$rofi_mesg | <b>Alt+Q</b> list-view | <b>Alt+W</b> icons-view | <b>Alt+E</b> list+preview"
    rofi_shortcuts="$rofi_shortcuts -kb-custom-2 Alt+q -kb-custom-3 Alt+w -kb-custom-4 Alt+e"
    rofi_flags="-show-icons"
    rofi_search_flags="-show-icons -eh 2 -sep | -markup-rows"
fi

format_filename() {
    while read -r path; do
        if [ -f "$path" ]; then
            if [[ -n "$ROFI_ICONS" || $search_type = "Pictures" ]]; then
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
            $rofi_search_flags \
            $rofi_shortcuts \
            -theme-str "$rofi_theme" \
            -p "$rofi_prompt" \
            -mesg "$rofi_mesg")
            
        exit_code="$?"

        [[ -n "$ROFI_ICONS" || "$search_type" = "Pictures" ]] && selected=$(compose_filename "$selected")

        [ "$exit_code" -eq 0 ] && xdg-open "$selected" && exit 0
        [ "$exit_code" -eq 1 ] && break
        [ "$exit_code" -eq 10 ] && copy_to_clip "$selected" && exit 0
        [ "$exit_code" -eq 11 ] && rofi_theme="$rofi_theme_list"
        [ "$exit_code" -eq 12 ] && rofi_theme="$rofi_theme_grid"
        [ "$exit_code" -eq 13 ] && rofi_theme="$rofi_theme_preview"
    done
}

menu_recent() {
    while true; do
        selected=$(search_recent | \
            $ROFI -dmenu -i \
            $rofi_search_flags \
            $rofi_shortcuts \
            -theme-str "$rofi_theme" \
            -p "$rofi_prompt" \
            -mesg "$rofi_mesg")
            
        exit_code="$?"

        [ -n "$ROFI_ICONS" ] && selected=$(compose_filename "$selected")

        [ "$exit_code" -eq 0 ] && xdg-open "$selected" && exit 0
        [ "$exit_code" -eq 1 ] && break
        [ "$exit_code" -eq 10 ] && copy_to_clip "$selected" && exit 0
        [ "$exit_code" -eq 11 ] && rofi_theme="$rofi_theme_list"
        [ "$exit_code" -eq 12 ] && rofi_theme="$rofi_theme_grid"
        [ "$exit_code" -eq 13 ] && rofi_theme="$rofi_theme_preview"
    done
}

menu_content() {
    local folder="$1"
    local query="$2"
    
    while true; do
        selected=$(search_content "$folder" "$query" | \
            $ROFI -dmenu -i \
            $rofi_search_flags \
            $rofi_shortcuts \
            -theme-str "$rofi_theme" \
            -p "$rofi_prompt" \
            -mesg "$rofi_mesg")
            
        exit_code="$?"

        [ -n "$ROFI_ICONS" ] && selected=$(compose_filename "$selected")

        [ "$exit_code" -eq 0 ] && xdg-open "$selected" && exit 0
        [ "$exit_code" -eq 1 ] && break
        [ "$exit_code" -eq 10 ] && copy_to_clip "$selected"
        [ "$exit_code" -eq 11 ] && rofi_theme="$rofi_theme_list"
        [ "$exit_code" -eq 12 ] && rofi_theme="$rofi_theme_grid"
        [ "$exit_code" -eq 13 ] && rofi_theme="$rofi_theme_preview"
    done
}

copy_to_clip() {
    if [ -n "$WAYLAND_DISPLAY" ]; then
        wl-copy "$@"
    elif [ -n "$DISPLAY" ]; then
        echo "$@" | xclip -selection clipboard -r
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
                rofi_search_flags="-show-icons -eh 2 -sep | -markup-rows"
                rofi_theme="$rofi_theme_grid"
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
    local search_entries="All\x00icon\x1fcomputer
Recent\x00icon\x1ffolder-recent
Content\x00icon\x1ftext-x-generic
Books\x00icon\x1fapplication-x-mobipocket-ebook
Desktop\x00icon\x1fuser-desktop
Documents\x00icon\x1ffolder-documents
Downloads\x00icon\x1ffolder-download
Music\x00icon\x1ffolder-music
Pictures\x00icon\x1ffolder-pictures
Videos\x00icon\x1ffolder-videos"
    
    # remember last entry chosen
    local selected_row=0
    
    while choice=$(echo -en "$search_entries" | \
        $ROFI -dmenu -i \
            $rofi_flags \
            -selected-row ${selected_row} \
            -format 'i s' \
            -p "$rofi_prompt"); do

        # reset
        recent_files=""
        file_contents=""
        path="$initial_path"
        regex="$initial_regex"

        [ -z "$ROFI_ICONS" ] && rofi_theme=""
        [ -z "$ROFI_ICONS" ] && rofi_search_flags=""
        
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
