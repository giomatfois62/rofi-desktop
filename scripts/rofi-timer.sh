#!/usr/bin/env bash

# https://gist.github.com/emmanuelrosa/1f913b267d03df9826c36202cf8b1c4e

# USAGE: rofi -show timer -modi timer:/path/to/rofi-timer.sh

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

# Sounds effects from soundbible.com
TIMER_START_SOUND="${TIMER_START_SOUND:-$SCRIPT_PATH/sounds/timer_start.wav}"
TIMER_STOP_SOUND="${TIMER_STOP_SOUND:-$SCRIPT_PATH/sounds/timer_end.wav}"
TIMER_NOTIFICATION_TIMEOUT=${TIMER_NOTIFICATION_TIMEOUT:-5000}

timer_help="To set a custom timer, type for example: 1h 23m 53s"
timers="30 seconds\n45 seconds\n1 minute\n2 minutes\n3 minutes\n4 minutes\n5 minutes\n10 minutes\n15 minutes\n20 minutes\n30 minutes\n45 minutes\n1 hour"

declare -A timer_seconds=(
    ["1 hour"]=3600
    ["45 minutes"]=2700
    ["30 minutes"]=1800
    ["20 minutes"]=1200
    ["15 minutes"]=900
    ["10 minutes"]=600
    ["5 minutes"]=300
    ["4 minutes"]=240
    ["3 minutes"]=180
    ["2 minutes"]=120
    ["1 minute"]=60
    ["45 seconds"]=45
    ["30 seconds"]=30
)

start_timer() {
    notify-send -t $TIMER_NOTIFICATION_TIMEOUT "$1 timer started" && coproc ( paplay $TIMER_START_SOUND )

    if command -v systemd-run &> /dev/null; then
		systemd-run --user --on-active=$2 --timer-property=AccuracySec=1000ms bash -c "coproc ( paplay $TIMER_STOP_SOUND ); notify-send -i 'clock' -u critical 'Time Out!';"
    elif command -v at &> /dev/null; then
		echo "sleep $2 ; coproc ( paplay $TIMER_STOP_SOUND ); notify-send -i 'clock' -u critical 'Time Out!'" | at now
    fi
}

custom_timer() {
	seconds=$(echo "$@" | grep -o '[^ ]*s[^ ]*')
	minutes=$(echo "$@" | grep -o '[^ ]*m[^ ]*')
	hours=$(echo "$@" | grep -o '[^ ]*h[^ ]*')

	seconds=${seconds/s/}
	minutes=${minutes/m/}
	hours=${hours/h/}

	total_time=0

	[[ ${#seconds} -gt 0 ]] && total_time=$(($total_time + $seconds))
	[[ ${#minutes} -gt 0 ]] && total_time=$(($total_time + 60*$minutes))
	[[ ${#hours} -gt 0 ]] && total_time=$(($total_time + 3600*$hours))

	start_timer "$@" $total_time
}

if [ "$@" ]
then
	if [[ -v timer_seconds["$@"] ]]; then
    	start_timer "$@" ${timer_seconds["$@"]}
    	exit 0
	else
		custom_timer "$@"
	fi
else
	echo -en "\0message\x1f$timer_help\n"
    echo -e "$timers"
fi

exit 1
