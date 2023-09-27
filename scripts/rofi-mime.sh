#!/bin/bash
#
# this script manages mime-type associations of files, editing "mimeapps.list"
# it allows to choose default applications to open audiu/video/text files and more
#
# dependencies: rofi, xdg-mime

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"
MIMETYPES_DIR=${MIMETYPES_DIR:-"$SCRIPT_PATH/../data/mimetypes"}

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
    categories="Web Browser\nFile Manager\nText Editor\nPDF Reader\nImage Viewer\nAudio Player\nVideo Player\nChoose File Type"

    while choice=$(echo -en "$categories" | $ROFI_CMD -p "Default Applications"); do
        ${actions[$choice]};
    done
}

seach_applications() {
    grep "$1" -H -l /usr/share/applications/* $HOME/.local/share/applications/* | xargs -I {} basename {} .desktop
}

set_application() {
    xdg-mime default $2".desktop" $1

    # hacky!!! modify mimeapps file manually
    #MIME_FILE="$HOME/.config/mimeapps.list"
    #line_exists=$(grep -F "$1" "$MIME_FILE")

    # delete previous mimetype association
    #if [ -n "$line_exists" ]; then
    #    tmp_file="$HOME/.cache/mimeapps"
    #    escaped_mimetype=$(echo "$1" | sed 's/\//\\\//g')

    #    sed "/^$escaped_mimetype=/d" "$MIME_FILE" > "$tmp_file"
    #    mv "$tmp_file" "$MIME_FILE"
    #fi

    # add new mimetype association
    #echo "$1=$2"".desktop" >> "$MIME_FILE"
}

set_browser() {
    selected=$(seach_applications "WebBrowser" | $ROFI_CMD -p "Web Browser")

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
    selected=$(seach_applications 'FileManager' | $ROFI_CMD -p "File Manager")

    if [ -n "$selected" ]; then
        set_application "inode/directory" "$selected";
    fi
}

set_txt() {
    selected=$(seach_applications 'TextEditor;' | $ROFI_CMD -p "Text Editor")

    if [ -n "$selected" ]; then
        set_application "text/plain" "$selected";
        set_application "text/markdown" "$selected";
    fi
}

set_pdf() {
    selected=$(seach_applications 'PDF' | $ROFI_CMD -p "PDF Reader")

    if [ -n "$selected" ]; then
        set_application "application/pdf" "$selected";
    fi
}

set_image_viewer() {
    selected=$(seach_applications 'Image Viewer' | $ROFI_CMD -p "Image Viewer")

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
    selected=$(seach_applications 'Player;' | $ROFI_CMD -p "Audio Player")

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
    selected=$(seach_applications 'Player;' | $ROFI_CMD -p "Video Player")

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
    selected_type=$(cat "$MIMETYPES_DIR/"*.csv | sed '/Name,Template/d' | cut -d',' -f1-2 | rofi -dmenu -i | cut -d',' -f2)

    if [ -n "$selected_type" ]; then
        selected_app=$(seach_applications "" | $ROFI_CMD -p "Applications")

        if [ -n "$selected_type" ]; then
            set_application "$selected_type" "$selected_app";
        fi
    fi
}

mime_menu
