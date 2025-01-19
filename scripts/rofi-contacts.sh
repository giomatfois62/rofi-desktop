#!/usr/bin/env bash
#
# this script scrapes a list of contacts from a .vcf file and shows it in rofi
# selecting a contact opens a menu to copy numbers/mails to clipboard or send an email
#
# dependencies: rofi, jq
# optional: xclip/wl-clipboard

# TODO: implement remove contact from vcf file
# TODO: if multiple email addresses, ask user the one to send the mail

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI="${ROFI:-rofi}"
ROFI_DATA_DIR="${ROFI_DATA_DIR:-$SCRIPT_PATH/data}"
ROFI_CACHE_DIR="${ROFI_CACHE_DIR:-$HOME/.cache}"
CONTACTS_FILE="$ROFI_DATA_DIR/contacts.vcf"
CONTACTS_CACHE="$ROFI_CACHE_DIR/contacts.json"

# refresh contacts cache
rm "$CONTACTS_CACHE"

"$SCRIPT_PATH/scrape_vcf.py" "$CONTACTS_FILE" "$CONTACTS_CACHE"

if [ ! -f "$CONTACTS_CACHE" ]; then
    $ROFI -e "Failed to scrape contacts list, make sure $CONTACTS_FILE exists and is valid"
    exit 1
fi

# set clipboard commad to use
if [ -n "$WAYLAND_DISPLAY" ]; then
    clip_cmd="wl-copy"
elif [ -n "$DISPLAY" ]; then
    clip_cmd="xclip -sel clip"
else
    $ROFI -e "Error: No Wayland or X11 display detected. Clipboard actions will not work"
fi

# show menu
selected_row=0

while contact=$(jq '.[] | "\(.name)"' "$CONTACTS_CACHE" |\
        tr -d '",\\' |\
        sort --ignore-case |\
        $ROFI -dmenu -i -format 'i s' -selected-row "$selected_row" -p Contacts); do

    selected_row=$(echo "$contact" | cut -d' ' -f1)
    contact=$(echo "$contact" | cut -d' ' -f2-)

    numbers=$(jq --compact-output ".[] | select(.name==\"$contact\") | .num" "$CONTACTS_CACHE" | tr -d '",[,]')
    mails=$(jq --compact-output ".[] | select(.name==\"$contact\") | .mail" "$CONTACTS_CACHE" | tr -d '",[,]')

    mesg="<b>$contact</b>&#x0a;Numbers: $numbers&#x0a;Email: $mails"

    all_actions="Copy Numbers\nCopy Emails\nWrite Email\nRemove Contact"

    [ -z "$numbers" ] && all_actions=$(echo "$all_actions" | sed 's/Copy Numbers\\n//')
    [ -z "$mails" ] && all_actions=$(echo "$all_actions" | sed 's/Copy Emails\\nWrite Email\\n//')

    while action=$(echo -en "$all_actions" | $ROFI -dmenu -i -p Action -mesg "$mesg"); do
        if [ "$action" = "Copy Numbers" ]; then
            echo "$numbers" | $clip_cmd
        elif [ "$action" = "Copy Emails" ]; then
            echo "$mails" | $clip_cmd
        elif [ "$action" = "Write Email" ]; then
            xdg-email mailto:$mails
        elif [ "$action" = "Remove Contact" ]; then
            echo "remove $contact"
        fi

        exit 0
    done
done

exit 1
