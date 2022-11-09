#!/usr/bin/env bash

CURRENT_LOCALE=$(locale | head -n1)
ROFI_CMD="rofi -dmenu -i -no-custom"

selected_locale=$(locale -a | $ROFI_CMD -p "Language")

if [ ${#selected_locale} -gt 0 ]; then
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
