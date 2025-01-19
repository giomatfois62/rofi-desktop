#!/usr/bin/env bash

ROFI="${ROFI:-rofi}"
TERMINAL="${TERMINAL:-xterm}"

distro=$(grep "^NAME=" /etc/os-release | sed 's/NAME=//')
update_cmd=""
update_flatpak="flatpak update"

if [ $(echo $distro | grep -i "ubuntu") ]; then
    update_cmd="apt update && apt upgrade"
    echo $update_cmd
elif [ $(echo $distro | grep -i "debian") ]; then
    update_cmd="apt update && apt upgrade"
    echo $update_cmd
elif [ $(echo $distro | grep -i "arch") ]; then
    update_cmd="pacman -Syu"
    echo $update_cmd
elif [ $(echo $distro | grep -i "gentoo") ]; then
    update_cmd="emerge -uDNav world"
    echo $update_cmd
elif [ $(echo $distro | grep -i "fedora") ]; then
    update_cmd="dnf update"
    echo $update_cmd
elif [ $(echo $distro | grep -i "slackware") ]; then
    update_cmd="slackpkg update && slackpkg install-new; slackpkg upgrade-all"
    echo "$update_cmd"
else
    $ROFI -e "$distro is not supported by the update-system script"
    exit 1
fi

$TERMINAL -e "su -c '$update_cmd && $update_flatpak'; read -n1"
