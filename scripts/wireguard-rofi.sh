#!/usr/bin/env bash

# WireGuard custom menu script to manage NetworkManager WireGuard connections using rofi
# install to the same directory as wireguard.sh
# example usage with rofi: rofi -modi 'WireGuard:~/.config/rofi/wireguard-rofi.sh' -show WireGuard

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

if [[ $# != 0 ]]
then
	if [[ "$@" == "Quit" ]]
	then
		exit 0
	elif [[ "$1" != "Reload" ]]
	then
		connection=$(echo $1 | cut -d: -f1)
		message="$($SCRIPT_DIR/wireguard.sh toggle $connection)"
		if command -v notify-send >/dev/null 2>&1; then
			notify-send "wireguard" "$message"
		fi
		exit 0
	fi
fi

active=-1
urgent=-1

while read -r state connection IP
do
	if [[ "$state" == "connected:" ]]
	then
		active=$(($active+1))
	elif [[ "$state" == "available:" ]]
	then
		urgent=$(($urgent+1))
	fi
	if [[ "$IP" != "" ]]
	then
		connection="$connection [$IP]"
	fi
	echo -en "$connection\0icon\x1fwireguard\n"
done < <($SCRIPT_DIR/wireguard.sh menu)

if [[ $active -ge 0 ]]
then
	echo -en "\0active\x1f0-$active\n"
fi
if [[ $urgent -ge 0 ]]
then
	echo -en "\0urgent\x1f$(($active+1))-$(($active+1+$urgent))\n"
fi

echo "Reload"
echo "Quit"
