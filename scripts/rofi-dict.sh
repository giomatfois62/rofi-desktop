#!/bin/bash 
#
# https://gitlab.com/-/snippets/1986400
#
# this script looks up word definitions in a dictionary using sdcv (stardict command line interface)
#
# dependencies: rofi, links, sdcv

ROFI="${ROFI:-rofi}"

if ! command -v sdcv &> /dev/null; then
	$ROFI -e "Install sdcv and links to enable the dictionary menu"
	exit 1
fi

pag() {                                                 \
    sed -e 1d                                           \
        -e 's; _\([A-Z]\); \1;p'                        \
        -e '/^$/d' -e '/^-->/d'                         \
    | eval "$ROFI" -dmenu -i -p "Result"
}

while phrase="$(echo $src | $ROFI -dmenu -i -markup -p 'Word to search')"; do
    {
        sdcv -n --utf8-input --utf8-output "$phrase"
        printf "Urban\n"
        links -dump "https://www.urbandictionary.com/define.php?term=$phrase" \
            | sed -e '1,75d'| head -n -24 | sed '/^   Flag/d' | sed '/^   Get the /d'
    } | pag
done

exit 1
