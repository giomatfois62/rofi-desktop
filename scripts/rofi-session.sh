#!/usr/bin/env bash
#
# this script manages the user session using loginctl and an optional screen locker
#
# dependencies: rofi, systemd/elogind
# optional: i3lock

ROFI="${ROFI:-rofi}"
ROFI_ICONS="${ROFI_ICONS:-}"
USE_LOCKER="${USE_LOCKER:-false}"
LOCKER="${LOCKER:-i3lock}"

rofi_flags=""

((ROFI_ICONS)) && rofi_flags="-show-icons"

entries="Lock Screen\x00icon\x1fsystem-lock-screen
Log Out\x00icon\x1fsystem-log-out
Reboot\x00icon\x1fsystem-reboot
Shutdown\x00icon\x1fsystem-shutdown
Suspend\x00icon\x1fsystem-suspend
Hibernate\x00icon\x1fsystem-suspend-hibernate"

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
        $ROFI -p "Are you sure?" -dmenu -i -a 0 -u 1 -selected-row 1)

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

while choice=$(echo -en "$entries" | $ROFI $rofi_flags -dmenu -i -p "Session"); do
    ${commands[$choice]};

    exit 0
done

exit 1
