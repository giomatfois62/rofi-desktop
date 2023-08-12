#!/usr/bin/env bash
#
# this script translates text written in the prompt using translate-cli
#
# dependencies: rofi, translate-cli

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"

if ! command -v trans &> /dev/null; then
	rofi -e "Install translate-cli to enable the translation menu"
fi

MESG="<span font-size='small'>Type or paste the text to translate and press \"Enter\".&#x0a;Specify a language by prefixing the query with \":lang\" (default is english), for example \":fr Hello World\"</span>"

while text=$((echo) | $ROFI_CMD -p "Translate" -mesg "$MESG"); do
	lang=""

	if [[ $text == :* ]]; then
		lang=$(echo "$text" | cut -d " " -f1)
		text=$(echo "$text" | cut -d' ' -f2-)
	fi

	msg=$(trans $lang "$text" -no-ansi -show-original n -show-translation n) && rofi -e "$msg" -markup
done

