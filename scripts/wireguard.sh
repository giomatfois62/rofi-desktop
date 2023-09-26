#!/usr/bin/env bash

# nmcli WireGuard abstraction layer for use with my waybar module and rofi custom menu script
#
# requires nmcli on your path
# install to the same directory as wireguard-rofi.sh
#
# usage: ./wireguard.sh [short|menu|toggle NAME]
# no argument:   print current connections
# short:         print current connections in short format
# menu:          print all connections
# toggle NAME:   toggle connection NAME

if ! command -v nmcli >/dev/null 2>&1; then
	echo "ERROR: 'nmcli' not found"
	echo "This tool is a 'nmcli' frontend, hence you should install NetworkManager before trying to use it."
	exit 1
fi

nargs=$#
get="no"
showmenu="no"
short="no"
dotoggle="no"
if [[ $nargs == 0 ]]
then
	get="yes"
elif [[ $nargs == 1 ]]
then
	if [[ $1 == "menu" ]]
	then
		showmenu="yes"
	elif [[ $1 == "short" ]]
	then
		if ! command -v sed >/dev/null 2>&1; then
			echo "ERROR: 'sed' not found"
			echo "Please install 'sed' to enable the 'short' option."
			exit 1
		fi
		get="yes"
		short="short"
	fi
elif [[ $nargs == 2 ]]
then
	if [[ $1 == "toggle" ]]
	then
		dotoggle="yes"
		conn="$2"
	fi
fi

nmclicmd="nmcli connection"
wgconns="$nmclicmd show"
wgactive="$wgconns --active"

connected=()
available=()

function get_conns {
	while read -r name uuid type device
	do
		if [[ $type != "wireguard" ]]
		then
			continue
		fi

		if [[ $device != "--" ]]
		then
			while read -r key value
			do
				if [[ $key != "ipv4.addresses:" ]]
				then
					continue
				fi
				connected+=("$name: $value")
			done < <($wgconns $name)
		else
			available+=("$name")
		fi
	done < <($1)
}

function print_conns {
	local first="yes"
	local array_print="$1[@]"
	local array_print=("${!array_print}")
	local text=""
	local tooltip=""
	if [ "${#array_print[@]}" -le 0 ]
	then
		return
	fi
	if [[ "$2" == "list" ]]
	then
		for c in "${array_print[@]}"
		do
			echo "$1: $c"
		done
	else
		for c in "${array_print[@]}"
		do
			if [[ "$first" != "yes" ]]
			then
					text="$text | "
					tooltip="$tooltip\n"
			fi
			if [[ "$2" == "short" ]]
			then
				text="$text$(echo -n $c | sed -E 's/^(.+): ([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\/[0-9]+)$/\1/')"
			else
				text="$text$c"
			fi
			tooltip="$tooltip$c"
			first="no"
		done
		echo "{\"text\": \"$text\", \"tooltip\": \"$tooltip\"}"
	fi
}

function array_contains {
	local array_has="$1[@]"
	local array_has=("${!array_has}")
	local element="$2"
	for e in "${array_has[@]}"
	do
		if [[ "$e" == *"$element"* ]]
		then
			echo "yes"
			return
		fi
	done
	echo "no"
}

if [[ $get == "yes" ]]
then
	get_conns "$wgactive"
	print_conns connected "$short"

elif [[ $showmenu == "yes" ]]
then
	get_conns "$wgconns"
	print_conns connected "list"
	print_conns available "list"


elif [[ $dotoggle == "yes" ]]
then
	get_conns "$wgconns"

	if [[ "$(array_contains connected $conn)" == "yes" ]]
	then
		$nmclicmd down "$conn"
	elif [[ "$(array_contains available $conn)" == "yes" ]]
	then
		$nmclicmd up "$conn"
	else
		echo "err: connection not found"
		exit 1
	fi

else
	echo "err: wrong args"
	exit 1
fi
