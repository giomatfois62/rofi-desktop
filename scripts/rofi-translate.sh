#!/usr/bin/env bash
#
# this script translates text written in the prompt using translate-shell
#
# dependencies: rofi, translate-shell

ROFI="${ROFI:-rofi}"
TRANSLATE_PLACEHOLDER="Type something and press \"Enter\" to translate"

if ! command -v trans &> /dev/null; then
	$ROFI -e "Install translate-shell to enable the translation menu"
	exit 1
fi

# <span font-size='small'>
MESG="Type or paste the text to translate and press \"Enter\".&#x0a;Specify a language by prefixing the query with \":lang\" (default is english), for example&#x0a;\":fr Hello World\""

while text=$((echo) | $ROFI -dmenu -i -p "Translate" -theme-str "entry{placeholder:\"$TRANSLATE_PLACEHOLDER\";"} -mesg "$MESG"); do
	lang=""

	if [[ $text == :* ]]; then
		lang=$(echo "$text" | cut -d " " -f1)
		text=$(echo "$text" | cut -d' ' -f2-)
	fi

	msg=$(trans $lang "$text" -no-ansi -show-original n -show-translation n) && $ROFI -e "$msg" -markup
done

