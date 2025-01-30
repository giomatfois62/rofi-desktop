#!/bin/bash
#
# script to browse icons from installed themes using rofi
#
# dependencies: rofi

ROFI="${ROFI:-rofi}"
ROFI_GRID_ROWS=${ROFI_GRID_ROWS:-4}
ROFI_GRID_COLS=${ROFI_GRID_COLS:-5}
ROFI_GRID_ICON_SIZE=${ROFI_GRID_ICON_SIZE:-4}
ROFI_LIST_ICON_SIZE=${ROFI_LIST_ICON_SIZE:-3}

rofi_mesg="<b>Enter</b> open file | <b>Alt+C</b> copy to clipboard&#x0a;<b>Alt+Q</b> list-view | <b>Alt+W</b> icons-view | <b>Alt+E</b> list+preview"
rofi_shortcuts="-kb-custom-1 Alt+c -kb-custom-2 Alt+q -kb-custom-3 Alt+w -kb-custom-4 Alt+e"
rofi_flags="-show-icons -eh 2 -sep | -markup-rows"

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

# icon themes
system_themes=$(ls /usr/share/icons | xargs -I{} echo "(system) {}")
user_themes=$(ls "$HOME/.local/share/icons" | xargs -I{} echo "(user) {}")

copy_to_clip() {
    if [ -n "$WAYLAND_DISPLAY" ]; then
        wl-copy "$@"
    elif [ -n "$DISPLAY" ]; then
        echo "$@" | xclip -selection clipboard
        [ -n "$paste_clip" ] && coproc ( sleep 0.5; xdotool key "ctrl+v" )
    fi

    exit 0
}

compose_filename() {
    echo "$@" \
        | awk 'BEGIN{ RS = "" ; FS = "\n" }{print $2"/"$1}' \
        | sed "s/'\/'/\//" \
        | sed "s/<b>//g;s/<\/b>//g;s/<i>//g;s/<\/i>//g"
}

row=0

while selected=$(echo -e "All Icons\n$system_themes\n$user_themes" | \
    $ROFI -dmenu -i -p "Icon Themes" -format 'i s' -selected-row $row); do
    
    row=$(echo "$selected" | cut -d' ' -f1)
    loc=$(echo "$selected" | cut -d' ' -f2)
    theme=$(echo "$selected" | cut -d' ' -f3-)

    [[ "$loc" = "(user)" ]] && folder="$HOME/.local/share/icons/$theme"
    [[ "$loc" = "(system)" ]] && folder="/usr/share/icons/$theme"
    [[ "$loc" = "All" ]] && folder="/usr/share/icons $HOME/.local/share/icons"

    while true; do
        icon=$(find $folder -type f -regex ".*\.\(jpg\|png\|svg\)" \
            -printf "%f\n<i>%h</i><ICON>%p|" | \
            sed -e "s/<ICON>/\x00icon\x1f/g" | \
            $ROFI -dmenu -i $rofi_shortcuts $rofi_flags -theme-str "$rofi_theme" -mesg "$rofi_mesg" -p "$theme")

        exit_code="$?"

        icon_name=$(echo -e "$icon" | head -n 1)
        icon_name="${icon_name%.*}"

        [ "$exit_code" -eq 0 ] && xdg-open "$(compose_filename "$icon")" && exit 0
        [ "$exit_code" -eq 1 ] && break
        [ "$exit_code" -eq 10 ] && copy_to_clip $icon_name && exit 0
        [ "$exit_code" -eq 11 ] && rofi_theme="$rofi_theme_list"
        [ "$exit_code" -eq 12 ] && rofi_theme="$rofi_theme_grid"
        [ "$exit_code" -eq 13 ] && rofi_theme="$rofi_theme_preview"
    done
done

exit 1
