#!/bin/bash

# 1. Fetch available/paired devices
# Splits the devicelist into names and IDs
devices=$(kdeconnect-cli -a --id-only)
device_names=$(kdeconnect-cli -a --name-only)

if [ -z "$devices" ]; then
    rofi -e "No KDE Connect devices found or paired."
    exit 1
fi

# 2. Select a device via Rofi if multiple exist
if [ $(echo "$devices" | wc -l) -gt 1 ]; then
    chosen_name=$(echo "$device_names" | rofi -dmenu -p "Select Device:")
    [ -z "$chosen_name" ] && exit 0

    # Match name back to ID
    device_id=$(kdeconnect-cli -a --refresh | grep "$chosen_name" | awk '{print $NF}' | tr -d '():')
else
    device_id=$devices
    chosen_name=$device_names
fi

# 3. Define actions for the selected device
OPTIONS="🔔 Ping Device
📱 Ring Phone
🔋 Battery Status
📁 Mount Storage
💬 Send SMS"

# 4. Display action menu
chosen_action=$(echo "$OPTIONS" | rofi -dmenu -p "$chosen_name:")

case "$chosen_action" in
    "🔔 Ping Device")
        kdeconnect-cli -d "$device_id" --ping
        ;;
    "📱 Ring Phone")
        kdeconnect-cli -d "$device_id" --ring
        ;;
    "🔋 Battery Status")
        battery=$(kdeconnect-cli -d "$device_id" --battery)
        rofi -e "$chosen_name: $battery"
        ;;
    "📁 Mount Storage")
        kdeconnect-cli -d "$device_id" --mount
        rofi -e "Storage mounted (check your file manager under Media/Shared)."
        ;;
    "💬 Send SMS")
        # Prompt for target phone number
        phone_num=$(rofi -dmenu -p "Enter phone number:")
        [ -z "$phone_num" ] && exit 0
        # Prompt for the text message
        message=$(rofi -dmenu -p "Message:")
        [ -z "$message" ] && exit 0

        kdeconnect-cli -d "$device_id" --send-sms "$message" --destination "$phone_num"
        ;;
    *)
        exit 0
        ;;
esac
