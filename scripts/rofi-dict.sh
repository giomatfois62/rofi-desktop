#!/bin/bash 
#
# https://gitlab.com/-/snippets/1986400
#
# this script looks up word definitions in a dictionary using sdcv (stardict command line interface)
#
# dependencies: rofi, links, sdcv

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"

DICT_PLACEHOLDER=${DICT_PLACEHOLDER:-"Type a word and press \"Enter\" to lookup in dictionary"}

if ! command -v sdcv &> /dev/null; then
	rofi -e "Install sdcv and links to enable the dictionary menu"
	exit 1
fi

pag() {                                                 \
    sed -e 1d                                           \
        -e 's; _\([A-Z]\); \1;p'                        \
        -e '/^$/d' -e '/^-->/d'                         \
    | eval "$ROFI_CMD" -p 'Done'
}

while phrase="$(echo $src | $ROFI_CMD -theme-str "entry{placeholder:\"$DICT_PLACEHOLDER\";}" -markup -p 'Lookup')"; do
    {
        sdcv -n --utf8-input --utf8-output "$phrase"
        printf "Urban\n"
        links -dump "https://www.urbandictionary.com/define.php?term=$phrase" \
            | sed -e '1,75d'| head -n -24 | sed '/^   Flag/d' | sed '/^   Get the /d'
    } | pag
done

exit 1
