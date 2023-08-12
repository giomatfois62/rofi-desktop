#! /usr/bin/env bash
#
# this script manages tmux sessions
#
# dependencies: rofi, tmux

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"
TERMINAL="${TERMINAL:-xterm}"

function tmux_sessions() {
    tmux list-session -F '#S'
}

TMUX_SESSION=$( (echo new; tmux_sessions) | $ROFI_CMD -p "Session")

if [[ x"new" = x"${TMUX_SESSION}" ]]; then
    $TERMINAL -e tmux new-session &
	exit 0
elif [[ -z "${TMUX_SESSION}" ]]; then
    exit 1
else
    $TERMINAL -e tmux attach -t "${TMUX_SESSION}" &
	exit 0
fi
