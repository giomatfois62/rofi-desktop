#!/usr/bin/env bash

CURRENT_LOCALE=$(locale | head -n1)
ROFI_CMD="rofi -dmenu -i -no-custom"

selected_locale=$(locale -a | $ROFI_CMD -p "Language")

if [ ${#selected_locale} -gt 0 ]; then
	echo "LANG=\"$selected_locale\"" > $HOME/.i18n
	echo "LC_ALL=\"$selected_locale\"" >> $HOME/.i18n
	rofi -markup -e "Language set to <b>$selected_locale</b>. Logout to apply changes"
fi

