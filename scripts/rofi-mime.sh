#!/bin/bash
#
# this script manages mime-type associations of files, editing "mimeapps.list"
# it allows to choose default applications to open audiu/video/text files and more
#
# dependencies: rofi, xdg-mime

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI="${ROFI:-rofi}"
ROFI_DATA_DIR="${ROFI_DATA_DIR:-$SCRIPT_PATH/data}"
ROFI_ICONS="${ROFI_ICONS:-}"

mimetypes="$ROFI_DATA_DIR/mimetypes"

rofi_flags=""

((ROFI_ICONS)) && rofi_flags="-show-icons"

declare -A actions=(
    ["Web Browser"]=set_browser
    ["File Manager"]=set_fm
    ["Text Editor"]=set_txt
    ["Image Viewer"]=set_image_viewer
    ["PDF Reader"]=set_pdf
    ["Audio Player"]=set_audio_player
    ["Video Player"]=set_video_player
    ["Choose File Type"]=set_mimetype
)

mime_menu() {
    categories="Web Browser\x00icon\x1fapplications-internet
File Manager\x00icon\x1ffolder
Text Editor\x00icon\x1faccessories-text-editor
PDF Reader\x00icon\x1fapplications-office
Image Viewer\x00icon\x1fapplications-graphics
Audio Player\x00icon\x1fapplications-multimedia
Video Player\x00icon\x1fapplications-multimedia
Choose File Type\x00icon\x1fpreferences-system"

    while choice=$(echo -en "$categories" | \
        $ROFI $rofi_flags -dmenu -i -p "Default Applications"); do
        ${actions[$choice]};
    done
}

search_applications() {
    local apps=$(grep -m 1 "$1" -H -l "$HOME/.local/share/applications/"*.desktop "/usr/share/applications/"*.desktop)

    while read -r app; do
        app_id=$(basename "$app" .desktop)
        app_name=$(grep -m 1 "^Name=" "$app" | cut -d= -f2)
        app_icon=$(grep -m 1 "^Icon=" "$app" | cut -d= -f2)
        echo -e "$app_id ($app_name)\x00icon\x1f$app_icon"
    done <<< "$apps"
}

set_application() {
    xdg-mime default $(echo "$2" | cut -d' ' -f1)".desktop" $1
}

get_mimetypes() {
    cat "$mimetypes/"*.csv | sed '/Name,Template/d' | cut -d',' -f1-2
}

get_mimetypes_with_icons() {
    local types=$(cat "$mimetypes/"*.csv | sed '/Name,Template/d' | cut -d',' -f1-2)

    for mime in $types; do
        mime_icon=$(echo $mime | cut -d',' -f2 | sed -e 's/\//-/g')
        echo -e "$mime\x00icon\x1f$mime_icon"
    done
}

set_browser() {
    selected=$(search_applications "WebBrowser" | $ROFI $rofi_flags -dmenu -i -p "Web Browser")

    if [ -n "$selected" ]; then
        set_application "application/x-extension-htm" "$selected";
        set_application "application/x-extension-html" "$selected";
        set_application "application/x-extension-shtml" "$selected";
        set_application "application/x-extension-xht" "$selected";
        set_application "application/x-extension-xhtml" "$selected";
        set_application "application/xhtml+xml" "$selected";
        set_application "text/html" "$selected";
    fi
}

set_fm() {
    selected=$(search_applications 'FileManager' | $ROFI $rofi_flags -dmenu -i -p "File Manager")

    if [ -n "$selected" ]; then
        set_application "inode/directory" "$selected";
    fi
}

set_txt() {
    selected=$(search_applications 'TextEditor;' | $ROFI $rofi_flags -dmenu -i -p "Text Editor")

    if [ -n "$selected" ]; then
        set_application "text/plain" "$selected";
        set_application "text/markdown" "$selected";
    fi
}

set_pdf() {
    selected=$(search_applications 'PDF' | $ROFI $rofi_flags -dmenu -i -p "PDF Reader")

    if [ -n "$selected" ]; then
        set_application "application/pdf" "$selected";
    fi
}

set_image_viewer() {
    selected=$(search_applications 'Image Viewer' | $ROFI $rofi_flags -dmenu -i -p "Image Viewer")

    if [ -n "$selected" ]; then
        set_application "image/bmp" "$selected";
        set_application "image/gif" "$selected";
        set_application "image/png" "$selected";
        set_application "image/tiff" "$selected";
        set_application "image/webp" "$selected";
        set_application "image/jpeg" "$selected";
    fi
}

set_audio_player() {
    selected=$(search_applications 'Player;' | $ROFI $rofi_flags -dmenu -i -p "Audio Player")

    if [ -n "$selected" ]; then
        set_application "audio/aac" "$selected";
        set_application "audio/mp4" "$selected";
        set_application "audio/mpeg" "$selected";
        set_application "audio/ogg" "$selected";
        set_application "audio/flac" "$selected";
        set_application "audio/x-mpegurl" "$selected";
        set_application "audio/x-wav" "$selected";
        set_application "audio/flac" "$selected";
    fi
}

set_video_player() {
    selected=$(search_applications 'Player;' | $ROFI $rofi_flags -dmenu -i -p "Video Player")

    if [ -n "$selected" ]; then
        set_application "video/webm" "$selected";
        set_application "video/x-matroska" "$selected";
        set_application "video/mp4" "$selected";
        set_application "video/mpeg" "$selected";
        set_application "video/ogg" "$selected";
        set_application "video/quicktime" "$selected";
        set_application "video/x-msvideo" "$selected";
    fi
}

set_mimetype() {
    selected_type=$(get_mimetypes | $ROFI -dmenu -i | cut -d',' -f2)

    if [ -n "$selected_type" ]; then
        selected_app=$(search_applications "" | $ROFI $rofi_flags -dmenu -i -p "Applications")

        if [ -n "$selected_app" ]; then
            set_application "$selected_type" "$selected_app";
        fi
    fi
}

mime_menu
