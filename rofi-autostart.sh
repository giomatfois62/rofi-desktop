#!/usr/bin/env bash

AUTOSTART_DIR="$HOME/.cache/autostart"
ROFI_CMD="rofi -dmenu -i -markup-rows"

# TODO: display a "new entry" field to create .desktop files
list_entries() {
    # handle empty XDG_CURRENT_DESKTOP env var
    current_desktop="$XDG_CURRENT_DESKTOP"
    if [ ${#current_desktop} -eq 0 ]; then
	    current_desktop="asdasdasd"
    fi

    all_files=$(find "$AUTOSTART_DIR" -type f -iname "*.desktop")
    only_show=$(grep "OnlyShowIn" "$AUTOSTART_DIR"/*.desktop | grep -v "$current_desktop" | cut -f1 -d":")
    not_show=$(grep -E -H -l "NotShowIn.*$current_desktop" "$AUTOSTART_DIR"/*.desktop)

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
    if [ ${#is_enabled} -gt 0 ]; then
	    echo "Disable"
    else
	    echo "Enable"
    fi

    filename=$(echo "$1" | cut -f1 -d" ")
    desktop_file="$AUTOSTART_DIR/$filename".desktop
    cmd=$(grep "Exec=" $desktop_file | cut -f2 -d"=" | head -n 1)

    if [ $(pgrep -f "$cmd") ]; then
	    echo "Stop"
    else
	    echo "Start"
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
    entry_name=$((echo) | rofi -dmenu -p "Entry Name")

    if [ ${#entry_name} -gt 0 ]; then
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
    echo "+New Entry"
    echo "$(list_entries | xargs -I {} bash -c "print_entry {}" | column -t)"
}

# sort by Enabled(Disabled) state
# sort -k2 (-r)

mkdir -p "$AUTOSTART_DIR"
cp -r /etc/xdg/autostart/*.desktop "$AUTOSTART_DIR"
cp -r "$HOME"/.config/autostart/*.desktop "$AUTOSTART_DIR"
export -f print_entry

# remember last selected entry
selected_row=0

while selected=$(gen_menu | $ROFI_CMD -p "Autostart" -selected-row ${selected_row} -format 'i s'); do
    selected_row=$(echo "$selected" | awk '{print $1;}')
    selected_text=$(echo "$selected" | cut -d' ' -f2-)
    selected_entry=$(echo $selected_text | cut -f1 -d" ")

    if [ "$selected_text" == "+New Entry" ]; then
	add_entry
    else
	action=$(gen_entry_menu "$selected_text" | $ROFI_CMD -p "$selected_entry")

	if [ ${#action} -gt 0 ]; then
	    ${actions[$action]} "$selected_entry";
	fi
    fi
done

rm -rf "$AUTOSTART_DIR"
exit 1
