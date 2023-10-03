#!/usr/bin/env bash
#
# this script scrape and show xkcd comics
#
# dependencies: rofi, jq, python3-lxml, python3-requests

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"
CONTACTS_FILE=${CONTACTS_FILE:-"all_contacts.json"}

if [ ! -f "$CONTACTS_FILE" ]; then
    echo "no contacts file found"
fi

selected_row=0

while contact=$(jq '.[] | "\(.name)"' "$CONTACTS_FILE" |\
        tr -d '",\\' |\
        sort --ignore-case |\
        $ROFI_CMD -format 'i s' -selected-row "$selected_row" -p Contacts); do

    selected_row=$(echo "$contact" | cut -d' ' -f1)
    contact=$(echo "$contact" | cut -d' ' -f2-)

    numbers=$(jq --compact-output ".[] | select(.name==\"$contact\") | .num" "$CONTACTS_FILE" | tr -d '",[,]')
    mails=$(jq --compact-output ".[] | select(.name==\"$contact\") | .mail" "$CONTACTS_FILE" | tr -d '",[,]')

    mesg="<b>$contact</b>&#x0a;Numbers: $numbers&#x0a;Email: $mails"

    all_actions="Copy Numbers\nCopy Emails\nWrite Email\nRemove Contact"

    [ -z "$numbers" ] && all_actions=$(echo "$all_actions" | sed 's/Copy Numbers\\n//')
    [ -z "$mails" ] && all_actions=$(echo "$all_actions" | sed 's/Copy Emails\\nWrite Email\\n//')

    while action=$(echo -en "$all_actions" | $ROFI_CMD -p Action -mesg "$mesg"); do
        if [ "$action" = "Copy Numbers" ]; then
            echo "$numbers"
        elif [ "$action" = "Copy Emails" ]; then
            echo "$mails"
        elif [ "$action" = "Write Email" ]; then
            echo "mail to $mails"
        elif [ "$action" = "Remove Contact" ]; then
            echo "remove $contact"
        fi

        exit 0
    done
done

exit 1
