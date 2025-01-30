#!/usr/bin/env bash
#
# this script translates text written in the prompt using translate-shell
#
# dependencies: rofi, translate-shell

ROFI="${ROFI:-rofi}"

# <span font-size='small'>
rofi_mesg="Type or paste the text to translate and press \"Enter\".&#x0a;Specify a language by prefixing the query with \":lang\" (default is english), for example&#x0a;\":fr Hello World\""

if ! command -v trans &> /dev/null; then
	$ROFI -e "Install translate-shell to enable the translation menu"
	exit 1
fi

while text=$((echo) | $ROFI -dmenu -i -p "Text to translate" -mesg "$rofi_mesg"); do
	lang=""

	if [[ $text == :* ]]; then
		lang=$(echo "$text" | cut -d' ' -f1)
		text=$(echo "$text" | cut -d' ' -f2-)
	fi

	translation=$(trans $lang "$text" -no-ansi -show-original n -show-translation n) && $ROFI -e "$translation" -markup
done

