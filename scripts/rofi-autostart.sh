#!/usr/bin/env bash

# this script manages autostart ".desktop" files in /etc/xdg/autostart/ and $HOME/.config/autostart
# it presents a list of all the files it finds, and an option to create a new autostart file
# selecting an entry will open a submenu to start/stop the program, enable/disable the entry and edit the corresponding file
#
# dependencies: rofi

ROFI="${ROFI:-rofi}"
ROFI_CACHE_DIR="${ROFI_CACHE_DIR:-$HOME/.cache}"

autostart_dir="$ROFI_CACHE_DIR/autostart"

list_entries() {
    # handle empty XDG_CURRENT_DESKTOP env var
    desktop="$XDG_CURRENT_DESKTOP"

    if [ -z "$desktop" ]; then
	    desktop="unknown"
    fi

    all_files=$(find "$autostart_dir" -type f -iname "*.desktop")
    only_show=$(grep -r "OnlyShowIn" "$autostart_dir" | grep -v "$desktop" | cut -f1 -d":")
    not_show=$(grep -r -E -H -l "NotShowIn.*$desktop" "$autostart_dir")

    # filter out entries that should not be shown in current environment
    common=$(comm -13 <(echo "$not_show" | sort) <(echo "$all_files" | sort))

    # filter out entries that should be shown only in other environments
    common=$(comm -13 <(echo "$only_show" | sort) <(echo "$common" | sort))

    echo "$common"
}

print_entry() {
    app_icon=$(grep -i "Icon=" "$1" | cut -d'=' -f2-)
    [[ -z "$app_icon" ]] && app_icon="application-x-executable"

    if [ $(grep -i "hidden=true" "$1") ]; then
        echo $(basename "$1" .desktop)" Disabled\x00icon\x1f$app_icon"
    else
        echo $(basename "$1" .desktop)" <b>Enabled</b>\x00icon\x1f$app_icon"
    fi
}

gen_entry_menu() {
    is_enabled=$(echo "$@" | grep "Enabled")

    if [ -n "$is_enabled" ]; then
	    echo "Disable"
    else
	    echo "Enable"
    fi

    file_name=$(echo "$1" | cut -f1 -d" ")
    file_path="$autostart_dir/$file_name".desktop
    proc_name=$(grep "Exec=" $file_path | cut -f2- -d"=" | head -n 1)
    proc_running=$(pgrep -f "$proc_name")

    if [ -n "$proc_running" ]; then
	    echo "Stop" " " "$proc_name"
    else
	    echo "Start" " " "$proc_name"
    fi

    echo "Edit"
}

declare -A actions=(
    ["Enable"]=enable_app
    ["Disable"]=disable_app
    ["Start"]=start_app
    ["Stop"]=stop_app
    ["Edit"]=edit_app
)

enable_app() {
    original_file="$autostart_dir/$1".desktop
    dst_file="$HOME/.config/autostart/$1".desktop

    # remove line with "Hidden=true"
    sed -i "/Hidden=/d" "$original_file"
    cp "$original_file" "$dst_file"
}

disable_app() {
    original_file="$autostart_dir/$1".desktop
    dst_file="$HOME/.config/autostart/$1".desktop

    # append line with "Hidden=true"
    echo "Hidden=true" >> "$original_file"
    cp "$original_file" "$dst_file"
}

start_app() {
    desktop_file="$autostart_dir/$1".desktop
    cmd=$(grep "Exec=" $desktop_file | cut -f2- -d"=" | head -n 1)

    $cmd &
}

stop_app() {
    desktop_file="$autostart_dir/$1".desktop
    cmd=$(grep "Exec=" $desktop_file | cut -f2- -d"=" | head -n 1)

    pkill -f $cmd
}

edit_app() {
    text_editor=$(xdg-mime query default text/plain)

    original_file="$autostart_dir/$1".desktop
    dst_file="$HOME/.config/autostart/$1".desktop

    cp "$original_file" "$dst_file"
    gtk-launch $text_editor $dst_file

    rm -rf "$autostart_dir"

    exit 0
}

desktop-entry() {
cat <<EOF
[Desktop Entry]
Name=$1
Exec=$1
Terminal=false
Type=Application
EOF
}

add_entry() {
    entry_name=$((echo) | $ROFI -dmenu -i -p "Entry Name")

    if [ -n "$entry_name" ]; then
        dst_file="$HOME/.config/autostart/$entry_name".desktop

        if [ ! -f "$dst_file" ]; then
            desktop-entry "$entry_name" > "$dst_file"
        fi

        xdg-open "$dst_file"
        rm -rf "$autostart_dir"

        exit 0
    fi
}

gen_menu() {
    echo -e "Add Entry\x00icon\x1flist-add"
    echo -e "$(list_entries | xargs -I {} bash -c "print_entry {}" | column -t)"
}

# sort by Enabled(Disabled) state
# sort -k2 (-r)

mkdir -p "$autostart_dir"
cp "$HOME"/.config/autostart/*.desktop /etc/xdg/autostart/*.desktop "$autostart_dir/"
export -f print_entry

# remember last selected entry
row=0

while selected=$(gen_menu | \
    $ROFI -dmenu -i -show-icons -markup-rows -p "Autostart" -selected-row ${row} -format 'i s'); do
    
    row=$(echo "$selected" | awk '{print $1;}')
    selected_text=$(echo "$selected" | cut -d' ' -f2-)
    selected_entry=$(echo $selected_text | cut -f1 -d" ")

    if [ "$selected_text" == "Add Entry" ]; then
        add_entry
    else
        action=$(gen_entry_menu "$selected_text" | $ROFI -dmenu -i -p "$selected_entry")

        [ -n "$action" ] && ${actions[$action]} "$selected_entry"
    fi
done

rm -rf "$autostart_dir"

exit 1
