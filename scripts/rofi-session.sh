#!/usr/bin/env bash
#
# this script manages the user session using loginctl and an optional screen locker
#
# dependencies: rofi
# optional: i3lock

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"
USE_LOCKER="${USE_LOCKER:-false}"
LOCKER="${LOCKER:-i3lock}"

entries="Lock Screen\nLog Out\nReboot\nShutdown\nSuspend\nHibernate"

declare -A commands=(
    ["Lock Screen"]=lock_screen
    ["Log Out"]=logout_user
    ["Reboot"]=reboot_sys
    ["Shutdown"]=shutdown_sys
    ["Suspend"]=suspend_sys
    ["Hibernate"]=hibernate_sys
)

confirm_action() {
    local choice

    choice=$(echo -e "Yes\nNo" |\
        rofi -p "Are you sure?" -dmenu -a 0 -u 1 -selected-row 1)

    if [ "$choice" == "Yes" ]; then
        echo "$choice"
    fi
}

lock_screen() { loginctl lock-session "${XDG_SESSION_ID-}"; }
logout_user() { loginctl terminate-session "${XDG_SESSION_ID-}"; }
reboot_sys() { [ "$(confirm_action)" = "Yes" ] && loginctl reboot; }
shutdown_sys() { [ "$(confirm_action)" = "Yes" ] && loginctl poweroff; }
suspend_sys() { $($USE_LOCKER) && "$LOCKER"; loginctl suspend; }
hibernate_sys() { $($USE_LOCKER) && "$LOCKER"; loginctl hibernate; }

while choice=$(echo -en "$entries" | $ROFI_CMD -p "Session"); do
    ${commands[$choice]};

    exit 0
done

exit 1
