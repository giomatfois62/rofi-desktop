#!/bin/bash 
#
# https://gitlab.com/-/snippets/1986400
#
# this script looks up word definitions in a dictionary using sdcv (stardict command line interface)
#
# dependencies: rofi, links, sdcv

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"

pag() {                                                 \
    sed -e 1d                                           \
        -e 's; _\([A-Z]\); \1;p'                        \
        -e '/^$/d' -e '/^-->/d'                         \
    | eval "$ROFI_CMD" -p 'Done'
}

while phrase="$(echo $src | eval "$ROFI_CMD" -markup -p 'Lookup: ')"; do
    {
        sdcv -n --utf8-input --utf8-output "$phrase"
        printf "Urban\n"
        links -dump "https://www.urbandictionary.com/define.php?term=$phrase" \
            | sed -e '1,75d'| head -n -24 | sed '/^   Flag/d' | sed '/^   Get the /d'
    } | pag
done

exit 1
