#!/usr/bin/env bash

# depends: inxi

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"
ROFI_CMD="rofi -dmenu -i -matching fuzzy"
SYSTEM_INFO="inxi -c0 -v2 | $ROFI_CMD -p Info"
 
declare -A commands=(
    ["🖌 Appearance"]=appearance_menu
    ["🖧 Network"]=network
    ["🖧 Bluetooth"]=bluetooth
    ["🖵 Display"]=display
    ["🔊 Volume"]=volume
    ["🌣 Brightness"]=brightness
    ["🖮 Keyboard Layout"]=kb_layout
    ["💿 Default Applications"]=default_apps
    ["💿 Autostart Applications"]=autostart_apps
    ["🗊 Menu Configuration"]=menu_config
    ["🛈 System Info"]=sys_info
    ["🖌 Qt5 Appearance"]=qt5_app
    ["🖌 GTK Appearance"]=gtk_app
    ["🖌 Rofi Style"]=rofi_app
    ["🖼 Set Wallpaper"]=wallpaper
    ["🖮 Rofi Shortcuts"]=shortcuts
    ["🗣 Language"]=set_lang
    ["🗘 Updates"]=update_sys
)

settings_menu() {
    entries="🖌 Appearance\n🖧 Network\n🖧 Bluetooth\n🖵 Display\n🔊 Volume\n🌣 Brightness\n🖮 Keyboard Layout\n🖮 Rofi Shortcuts\n💿 Default Applications\n💿 Autostart Applications\n🗊 Menu Configuration\n🗣 Language\n🗘 Updates\n🛈 System Info"

    # remember last entry chosen
    local choice_row=0
    local choice_text

    while choice=$(echo -en "$entries" | $ROFI_CMD -selected-row ${choice_row} -format 'i s' -p "Settings"); do
        choice_row=$(echo "$choice" | awk '{print $1;}')
        choice_text=$(echo "$choice" | cut -d' ' -f2-)

        ${commands[$choice_text]};
    done

    exit 1
}

appearance_menu() {
    appearance_entries="🖌 Qt5 Appearance\n🖌 GTK Appearance\n🖌 Rofi Style\n🖼 Set Wallpaper"

    # remember last entry chosen
    local selected_row=0
    local selected_text

    while selected=$(echo -en "$appearance_entries" | $ROFI_CMD -selected-row ${selected_row} -format 'i s' -p "Appearance"); do
        selected_row=$(echo "$selected" | awk '{print $1;}')
        selected_text=$(echo "$selected" | cut -d' ' -f2-)

        ${commands[$selected_text]};
    done
}

shortcuts() {
    rofi -show keys
}

network() {
    "$SCRIPT_PATH"/networkmanager_dmenu
}

bluetooth() {
    "$SCRIPT_PATH"/rofi-bluetooth.sh
}

display() {
    "$SCRIPT_PATH"/rofi-monitor-layout.sh
}

volume() {
    "$SCRIPT_PATH"/rofi-volume.sh
}

menu_config() {
    selected=$(find "$SCRIPT_PATH" -iname '*.sh' -maxdepth 1 -type f | sort | $ROFI_CMD -p "Open File")

    if [ ${#selected} -gt 0 ]; then
        xdg-open "$selected" && exit 0
    fi
}

set_lang() {
    "$SCRIPT_PATH"/rofi-locale.sh
}

sys_info() {
    eval "$SYSTEM_INFO"
}

default_apps() {
    "$SCRIPT_PATH"/rofi-mime.sh
}

autostart_apps() {
	"$SCRIPT_PATH"/rofi-autostart.sh && exit
}

brightness() {
    "$SCRIPT_PATH"/rofi-brightness.sh
}

kb_layout() {
    "$SCRIPT_PATH"/rofi-keyboard-layout.sh
}

qt5_app() {
    qt5ct;
}

gtk_app() {
    lxappearance;
}

rofi_app() {
    rofi-theme-selector;
}

wallpaper() {
    "$SCRIPT_PATH"/rofi-wallpaper.sh;
}

update_sys() {
    "$SCRIPT_PATH"/update-system.sh;
}

settings_menu

