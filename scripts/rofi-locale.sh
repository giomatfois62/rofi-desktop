#!/usr/bin/env bash
#
# this script manages the current system language, writing the corresponding
# entry either in "$HOME/.profile" (for slackware) or in "$HOME/.i18n"
#
# dependencies: rofi

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"
CURRENT_LOCALE=$(locale | head -n1)

selected_locale=$(locale -a | $ROFI_CMD -no-custom -p "Language")

if [ -n "$selected_locale" ]; then
    distro=$(grep "^NAME=" /etc/os-release | sed 's/NAME=//')

    if [ $(echo $distro | grep -i "slackware") ]; then
        # workaround for slackware
        sed -i "/LANG=/d" "$HOME/.profile"
        echo "LANG=$selected_locale" >> "$HOME/.profile"
    else
        echo "LANG=\"$selected_locale\"" > $HOME/.i18n
        echo "LC_ALL=\"$selected_locale\"" >> $HOME/.i18n
    fi

    rofi -markup -e "Language set to <b>$selected_locale</b>. Logout to apply changes"
fi
