#!/usr/bin/env bash
#
# this script scrapes a list of contacts from a .vcf file and shows it in rofi
# selecting a contact opens a menu to copy numbers/mails to clipboard or send an email
#
# dependencies: rofi
# optional: xclip/wl-clipboard

# TODO: remove duplicate mails/numbers
# TODO: implement edit contact
# TODO: implement add contact
# TODO: implement remove contact

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI="${ROFI:-rofi}"
ROFI_DATA_DIR="${ROFI_DATA_DIR:-$SCRIPT_PATH/data}"

contacts_file="$ROFI_DATA_DIR/Contacts.vcf"

# set clipboard commad to use
if [ -n "$WAYLAND_DISPLAY" ]; then
    clip_cmd="wl-copy"
elif [ -n "$DISPLAY" ]; then
    clip_cmd="xclip -sel clip"
else
    echo "Error: No Wayland or X11 display detected" >&2
    exit 1
fi

# show menu
row=0

while contact=$(echo -e "New Contact\n$(grep "FN:" "$contacts_file" | sort)" | cut -d: -f2 | \
    $ROFI -dmenu -i -format 'i s' -selected-row "$row" -p "Contacts"); do

    row=$(echo "$contact" | cut -d' ' -f1)
    contact_name=$(echo "$contact" | cut -d' ' -f2-)
    contact_info=$(sed -n "/FN:$contact_name$/,/END:VCARD/p" "$contacts_file")

    numbers=$(echo -e "$contact_info" | grep TEL | cut -d: -f2 | uniq)
    mails=$(echo -e "$contact_info"| grep EMAIL | cut -d: -f2 | uniq)

    rofi_mesg="<b>$contact_name</b>&#x0a;Numbers: $numbers&#x0a;Emails: $mails"
    actions="Edit Contact\nCopy Number\nCopy Email\nWrite Email\nRemove Contact"

    [ -z "$numbers" ] && actions=$(echo "$actions" | sed 's/Copy Number\\n//')
    [ -z "$mails" ] && actions=$(echo "$actions" | sed 's/Copy Email\\nWrite Email\\n//')

    action=$(echo -en "$actions" | $ROFI -dmenu -i -p Action -rofi_mesg "$rofi_mesg")

    if [ "$action" = "Copy Number" ]; then
        [ $(echo -e "$numbers" | wc -l) -gt 1 ] && \
            numbers=$(echo -e "$numbers" | $ROFI -dmenu -i -p "$contact_name Number")
        [ -n "$numbers" ] && echo "$numbers" | $clip_cmd && exit 0
    elif [ "$action" = "Copy Email" ]; then
        [ $(echo -e "$mails" | wc -l) -gt 1 ] && \
            mails=$(echo -e "$mails" | $ROFI -dmenu -i -p "$contact_name Email")
        [ -n "$mails" ] && echo "$mails" | $clip_cmd && exit 0
    elif [ "$action" = "Write Email" ]; then
        [ $(echo -e "$mails" | wc -l) -gt 1 ] && \
            mails=$(echo -e "$mails" | $ROFI -dmenu -i -p "$contact_name Email")
        [ -n "$mails" ] && xdg-email mailto:$mails && exit 0
    elif [ "$action" = "Remove Contact" ]; then
        echo "remove $contact_name"
    elif [ "$action" = "Edit Contact" ]; then
        echo "edit $contact_name"
    fi
done

exit 1
