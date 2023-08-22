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
    | eval "$ROFI_CMD" -l 20 -p 'Done'
}

# TODO: fix urbandictionary scraping
while phrase="$(echo $src | eval "$ROFI_CMD" -markup -p 'Lookup: ')"; do
    {
        sdcv -n --utf8-input --utf8-output "$phrase"
        printf "Urban\n"
        links -dump "https://www.urbandictionary.com/define.php?term=$phrase" \
            | sed -n '1,/Top def/d;/Get the $phrase mug/q;p'
    } | pag
done

exit 1
