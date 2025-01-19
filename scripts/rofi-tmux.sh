#! /usr/bin/env bash
#
# this script manages tmux sessions
#
# dependencies: rofi, tmux

ROFI="${ROFI:-rofi}"
TERMINAL="${TERMINAL:-xterm}"

if ! command -v tmux &> /dev/null; then
	$ROFI -e "Install tmux to enable the tmux sessions menu"
	exit 1
fi

function tmux_sessions() {
    tmux list-session -F '#S'
}

TMUX_SESSION=$( (echo "New session"; tmux_sessions) | $ROFI -dmenu -i -p "Session")

if [[ x"New session" = x"${TMUX_SESSION}" ]]; then
    $TERMINAL -e tmux new-session &
	exit 0
elif [[ -z "${TMUX_SESSION}" ]]; then
    exit 1
else
    $TERMINAL -e tmux attach -t "${TMUX_SESSION}" &
	exit 0
fi
