#!/usr/bin/env bash

# this script manages autostart ".desktop" files in /etc/xdg/autostart/ and $HOME/.config/autostart
# it presents a list of all the files it finds, and an option to create a new autostart file
# selecting an entry will open a submenu to start/stop the program, enable/disable the entry and edit the corresponding file
#
# dependencies: rofi

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"
AUTOSTART_DIR="${AUTOSTART_DIR:-$HOME/.cache/autostart}"

list_entries() {
    # handle empty XDG_CURRENT_DESKTOP env var
    desktop="$XDG_CURRENT_DESKTOP"

    if [ -z "$desktop" ]; then
	    desktop="unknown"
    fi

    all_files=$(find "$AUTOSTART_DIR" -type f -iname "*.desktop")
    only_show=$(grep -r "OnlyShowIn" "$AUTOSTART_DIR" | grep -v "$desktop" | cut -f1 -d":")
    not_show=$(grep -r -E -H -l "NotShowIn.*$desktop" "$AUTOSTART_DIR")

    # filter out entries that should not be shown in current environment
    common_files=$(comm -13 <(echo "$not_show" | sort) <(echo "$all_files" | sort))

    # filter out entries that should be shown only in other environments
    common_files=$(comm -13 <(echo "$only_show" | sort) <(echo "$common_files" | sort))

    echo "$common_files"
}

print_entry() {
    if [ $(grep -i "hidden=true" "$1") ]; then
        echo $(basename "$1" .desktop) " " "Disabled"
    else
        echo $(basename "$1" .desktop) " " "<b>Enabled</b>"
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
    file_path="$AUTOSTART_DIR/$file_name".desktop
    proc_name=$(grep "Exec=" $file_path | cut -f2 -d"=" | head -n 1)
    proc_running=$(pgrep -f "$proc_name")

    if [ -n "$proc_running" ]; then
	    echo "Stop" " " "$proc_name"
    else
	    echo "Start" " " "($proc_name)"
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
    original_file="$AUTOSTART_DIR/$1".desktop
    dst_file="$HOME/.config/autostart/$1".desktop

    # remove line with "Hidden=true"
    sed -i "/Hidden=/d" "$original_file"
    cp "$original_file" "$dst_file"
}

disable_app() {
    original_file="$AUTOSTART_DIR/$1".desktop
    dst_file="$HOME/.config/autostart/$1".desktop

    # append line with "Hidden=true"
    echo "Hidden=true" >> "$original_file"
    cp "$original_file" "$dst_file"
}

start_app() {
    desktop_file="$AUTOSTART_DIR/$1".desktop
    cmd=$(grep "Exec=" $desktop_file | cut -f2 -d"=" | head -n 1)

    $cmd &
}

stop_app() {
    desktop_file="$AUTOSTART_DIR/$1".desktop
    cmd=$(grep "Exec=" $desktop_file | cut -f2 -d"=" | head -n 1)

    pkill -f $cmd
}

edit_app() {
    original_file="$AUTOSTART_DIR/$1".desktop
    dst_file="$HOME/.config/autostart/$1".desktop

    cp "$original_file" "$dst_file"
    xdg-open $dst_file

    rm -rf "$AUTOSTART_DIR"

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
    entry_name=$((echo) | $ROFI_CMD -p "Entry Name")

    if [ -n "$entry_name" ]; then
        dst_file="$HOME/.config/autostart/$entry_name".desktop

        if [ ! -f "$dst_file" ]; then
            desktop-entry "$entry_name" > "$dst_file"
        fi

        xdg-open "$dst_file"
        rm -rf "$AUTOSTART_DIR"

        exit 0
    fi
}

gen_menu() {
    echo "Add Entry"
    echo "$(list_entries | xargs -I {} bash -c "print_entry {}" | column -t)"
}

# sort by Enabled(Disabled) state
# sort -k2 (-r)

mkdir -p "$AUTOSTART_DIR"
cp /etc/xdg/autostart/*.desktop "$AUTOSTART_DIR/"
cp "$HOME"/.config/autostart/*.desktop "$AUTOSTART_DIR/"
export -f print_entry

# remember last selected entry
selected_row=0

while selected=$(gen_menu | $ROFI_CMD -markup-rows -p "Autostart" -selected-row ${selected_row} -format 'i s'); do
    selected_row=$(echo "$selected" | awk '{print $1;}')
    selected_text=$(echo "$selected" | cut -d' ' -f2-)
    selected_entry=$(echo $selected_text | cut -f1 -d" ")

    if [ "$selected_text" == "Add Entry" ]; then
        add_entry
    else
        action=$(gen_entry_menu "$selected_text" | $ROFI_CMD -p "$selected_entry")

        if [ -n "$action" ]; then
            ${actions[$action]} "$selected_entry";
        fi
    fi
done

rm -rf "$AUTOSTART_DIR"

exit 1
