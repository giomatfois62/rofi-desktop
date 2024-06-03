#!/bin/bash

toLinesJson(){
	echo "$1" | sed -e 's/\\/\\\\/g' -e 's/\"/\\"/g' -e 's/.*/"&"/' | paste -sd "," -
}

toStringJson(){
	echo "$1" | sed -e 's/\\/\\\\/g' -e 's/\"/\\"/g' -e '$!s/.*/&\\n/' | paste -sd "" -
}

execTop(){
	echo '{"prompt": "search"}'; 
	top -c -b -d 1 | while IFS= read -r line; do
		TOP="$line"
		while true; do
			IFS= read -t 0.01 -r line;
			VAR=$?
			if ((VAR == 0)); then # read another line successfully
				TOP="$TOP"$'\n'"$line"
			elif (( VAR > 128 )); then # timeout happened
				break;
			else # any other reason
				exit
			fi
		done
		TOP="$(sed '/./,$!d' <<< "$TOP")"
		TOP_INFO="$(sed -n '1,/^\s*PID/p' <<< "$TOP")"
		TOP_PIDLIST="$(sed '1,/^\s*PID/d' <<< "$TOP")"
		JSON_LINES="$(toLinesJson "$TOP_PIDLIST")"
		JSON_MESSAGE="$(toStringJson "$TOP_INFO")"
		printf '{"message": "%s","lines":[%s]}\n' "$JSON_MESSAGE" "$JSON_LINES"
	done
}

execTop | rofi -kb-screenshot Control+Shift+space -modi blocks -show blocks "$@"
