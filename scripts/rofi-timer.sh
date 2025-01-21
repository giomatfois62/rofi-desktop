#!/usr/bin/env bash

# https://gist.github.com/emmanuelrosa/1f913b267d03df9826c36202cf8b1c4e

# USAGE: rofi -show timer -modi timer:/path/to/rofi-timer.sh

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

# Sounds effects from soundbible.com
TIMER_START_SOUND="${TIMER_START_SOUND:-$SCRIPT_PATH/sounds/timer_start.wav}"
TIMER_STOP_SOUND="${TIMER_STOP_SOUND:-$SCRIPT_PATH/sounds/timer_end.wav}"
TIMER_NOTIFICATION_TIMEOUT=${TIMER_NOTIFICATION_TIMEOUT:-5000}

timer_placeholder="Type <hours>h <minutes>m <seconds>s to set a custom timer"

TIMERS="1 hour\n45 minutes\n30 minutes\n20 minutes\n15 minutes\n10 minutes\n5 minutes\n4 minutes\n3 minutes\n2 minutes\n1 minute\n45 seconds\n30 seconds"

declare -A SECONDS=(
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

startTimer() {
    notify-send -t $TIMER_NOTIFICATION_TIMEOUT "$1 timer started" && paplay $TIMER_START_SOUND

    if command -v systemd-run &> /dev/null; then
		systemd-run --user --on-active=$2 --timer-property=AccuracySec=1000ms bash -c 'notify-send "Time Out!" ; paplay '$TIMER_STOP_SOUND
    elif command -v at &> /dev/null; then
		echo "sleep $2 ; notify-send 'Time Out!' ; paplay $TIMER_STOP_SOUND" | at now
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

	startTimer "$@" $total_time
}

if [ "$@" ]
then
	if [[ -v SECONDS["$@"] ]]; then
    	startTimer "$@" ${SECONDS["$@"]}
    	exit 0
	else
		custom_timer "$@"
	fi
else
	#
	echo -en "\0theme\x1fentry{placeholder:\"$timer_placeholder\";}\n"
    echo -e "$TIMERS"
fi

exit 1
