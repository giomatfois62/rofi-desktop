#!/usr/bin/env bash
#
# this script shows current timezone and a list of available timezones to set the system time and date
#
# dependencies: rofi
# optional: timedatectl

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"

# TODO: to set local time without timedatectl
# TODO: copy selected timezone file to /etc/localtime using 'pkexec sh -c "command"' to prompt for root password

#https://stackoverflow.com/questions/12521114/getting-the-canonical-time-zone-name-in-shell-script
current_timezone="Current time zone: "$(readlink /etc/localtime | sed "s/\/usr\/share\/zoneinfo\///" | sed "s/\..//g")
current_time=$(date "+%H:%M, %a %d %b %Y")
msg="$current_timezone&#x0a;$current_time"

while timezone=$(cd /usr/share/zoneinfo/posix && find * -type f -or -type l |\
    sort | xargs -I{} sh -c "echo -n {}': ' && TZ={} date \"+%H:%M, %a %d %b %Y\"" |\
    $ROFI_CMD -p "Time Zone" -mesg "$msg"); do
    timezone_text=$(echo "$timezone" | cut -d':' -f1)

    choice=$(echo -e "Yes\nNo" | $ROFI_CMD -p "Set time zone to $timezone_text?")

    if [ "$choice" = "Yes" ]; then
        if command -v timedatectl &> /dev/null; then
            timedatectl set-timezone "$timezone_text"
            exit 0
        else
            rofi -e "Not supported yet"
        fi
    fi
done

exit 1
