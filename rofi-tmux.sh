#! /usr/bin/env bash

TERMINAL="xterm"

function tmux_sessions() {
    tmux list-session -F '#S'
}

TMUX_SESSION=$( (echo new; tmux_sessions) | rofi -dmenu -p "Session")

if [[ x"new" = x"${TMUX_SESSION}" ]]; then
    $TERMINAL -e tmux new-session &
	exit 0
elif [[ -z "${TMUX_SESSION}" ]]; then
    exit 1
else
    $TERMINAL -e tmux attach -t "${TMUX_SESSION}" &
	exit 0
fi
