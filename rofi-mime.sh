#!/bin/bash

SCRIPT_PATH="$HOME/Downloads/rofi-desktop"
ROFI_CMD="rofi -dmenu -i -matching fuzzy"
MIME_FILE="$HOME/.config/mimeapps.list"

categories="Web Browser\nFile Manager\nPDF Reader\nImage Viewer\nAudio Player\nVideo Player"

declare -A actions=(
    ["Web Browser"]=set_browser
    ["File Manager"]=set_fm
    ["Image Viewer"]=set_image_viewer
    ["PDF Reader"]=set_pdf
    ["Audio Player"]=set_audio_player
    ["Video Player"]=set_video_player
)

seach_applications() {
    grep $1 -H -l /usr/share/applications/* $HOME/.local/share/applications/* | xargs -I {} basename {}
}

set_application() {
    line_exists=$(fgrep "$1" $MIME_FILE)

    # delete previous mimetype association
    if [ ${#line_exists} -gt 0 ]; then
        tmp_file="$SCRIPT_PATH/mimeapps"
        escaped_mimetype=$(echo "$1" | sed 's/\//\\\//g')
        sed "/^$escaped_mimetype=/d" $MIME_FILE > $tmp_file
        mv $tmp_file $MIME_FILE
    fi

    # add new mimetype association
    #app="$(basename ${2})"
    echo "$1=$2" >> $MIME_FILE
}

set_browser() {
    selected=$(seach_applications "WebBrowser" | $ROFI_CMD -p "Web Browser")

    echo $selected
    # TODO: implement web browser selection
}

set_fm() {
    selected=$(seach_applications 'FileManager' | $ROFI_CMD -p "File Manager")

    if [ ${#selected} -gt 0 ]; then
        set_application "inode/directory" $selected;
    fi
}

set_pdf() {
    selected=$(seach_applications 'PDF' | $ROFI_CMD -p "PDF Reader")

    echo $selected
    # TODO: implement pdf viewer selection
}

set_image_viewer() {
    selected=$(seach_applications 'image/tif' | $ROFI_CMD -p "Image Viewer")

    if [ ${#selected} -gt 0 ]; then
        set_application "image/bmp" $selected;
        set_application "image/gif" $selected;
        set_application "image/png" $selected;
        set_application "image/tiff" $selected;
        set_application "image/webp" $selected;
        set_application "image/jpeg" $selected;
    fi
}

set_audio_player() {
    selected=$(seach_applications 'Audio;' | $ROFI_CMD -p "Audio Player")

    if [ ${#selected} -gt 0 ]; then
        set_application "audio/aac" $selected;
        set_application "audio/mp4" $selected;
        set_application "audio/mpeg" $selected;
        set_application "audio/ogg" $selected;
        set_application "audio/flac" $selected;
        set_application "audio/x-mpegurl" $selected;
        set_application "audio/x-wav" $selected;
        set_application "audio/flac" $selected;
    fi
}

set_video_player() {
    selected=$(seach_applications 'Video;' | $ROFI_CMD -p "Video Player")

    if [ ${#selected} -gt 0 ]; then
        set_application "video/webm" $selected;
        set_application "video/x-matroska" $selected;
        set_application "video/mp4" $selected;
        set_application "video/mpeg" $selected;
        set_application "video/ogg" $selected;
        set_application "video/quicktime" $selected;
        set_application "video/x-msvideo" $selected;
    fi
}

while choice=`echo -en $categories | $ROFI_CMD -p "Default Applications"`; do
    if [ ${#choice} -gt 0 ]; then
        ${actions[$choice]};
    fi
done
