#!/bin/bash

# DEFAULT VALUES
ICON="xclock"
NAME="Simple Pomodoro"

FOCUS=1500
BREAK=300
LONG_BREAK=1200
ROUNDS=4
CYCLES=1

FOCUS_SCRIPT=""
BREAK_SCRIPT=""
LBREAK_SCRIPT=""
PAUSE_SCRIPT=""
RESUME_SCRIPT=""

HELP="Simple Pomodoro Timer!
Options:
\t-f <focus time in sec>
\t-b <break time in sec>
\t-l <long break in sec>
\t-r <number of sessions before long break>
\t-c <number of cycles>
\t-F <command to run when focus time starts>
\t-B <command to run when short break starts>
\t-L <command to run when long break starts>
\t-P <command to run when paused>
\t-R <command to run when resumed>"


# PARSE OPTIONS
while getopts "f:b:r:c:l:F:B:L:P:R:h" opt; do
	case $opt in
		f)
			FOCUS=$OPTARG ;;
		b)
			BREAK=$OPTARG ;;
		r)
			ROUNDS=$OPTARG ;;
		c)
			CYCLES=$OPTARG ;;
		l)
			LONG_BREAK=$OPTARG ;;
		F)
			FOCUS_SCRIPT=$OPTARG ;;
		B)
			BREAK_SCRIPT=$OPTARG ;;
		L)
			LBREAK_SCRIPT=$OPTARG ;;
		P)
			PAUSE_SCRIPT=$OPTARG ;;
		R)
			RESUME_SCRIPT=$OPTARG ;;
		h|\?)
			printf "$HELP\n"
			exit 1 ;;
	esac
done
		

formatTime() {
	if [[ $2 -eq 1 ]]; then
		printf '%02d' $(expr $1)
	else
		printf '%02d' $(expr $1 - 1)
	fi
}

timer() {
	MIN=$(expr $1 / 60)
	SEC=$(expr $1 - $MIN \* 60)

	for (( min=$MIN; min>=0; min-- ))
	do
		for (( sec=$SEC; sec>0; sec-- ))
		do
			BODY="Time Remaining: $(formatTime $min 1):$(formatTime $sec) seconds"
			OUTPUT=$(timeout 1 notify-send "$2" "$BODY" -r $3 -u low -a "$NAME" -i "$ICON" -A "Pause" -A "Stop" -A "Skip" & sleep 1)
			case $OUTPUT in
				0)	
					sh -c "$PAUSE_SCRIPT"
					while [ 1 ]; do
						OUT=$(timeout 1 notify-send "Paused!" "$BODY" -r $3 -u critical -a "$NAME" -i "$ICON" -A "Resume" & sleep 1)
						if [[ $OUT = 0 ]]; then
							break
						fi
					done
					sh -c "$RESUME_SCRIPT"
					;;
				1)
					quit ;;
				2)
					return ;;
			esac
		done
		SEC=60
	done
}

start() {
	NOTI=$(notify-send "Pomodoro Session Started!" -p)
	sh -c "$FOCUS_SCRIPT"
	timer $FOCUS "Cycle $1 • Session $2 • Focus Time!" $NOTI

	if [[ $3 -eq 1 ]]; then
		notify-send "LONG BREAK TIME!" -r $NOTI
		sh -c "$LBREAK_SCRIPT"
		timer $LONG_BREAK "Long Break!" $NOTI

	elif [[ $3 -eq 2 ]]; then
		return;

	else
		notify-send "BREAK TIME!" -r $NOTI
		sh -c "$BREAK_SCRIPT"
		timer $BREAK "Short Break!" $NOTI
	fi
		
}

quit() {
	sh -c "$EXIT_SCRIPT"
	exit 0
}

trap quit SIGINT

for (( i=0; i<$CYCLES; i++ ))
do
	for (( j=1; j<=$ROUNDS; j++ ))
	do
		k=$(expr $i + 1)
		if [[ j -eq $ROUNDS ]] && [[ i -ne $(expr $CYCLES - 1) ]]; then
			start $k $j 1
		elif [[ j -eq $ROUNDS ]] && [[ i -eq $(expr $CYCLES - 1) ]]; then
			start $k $j 2
		else
			start $k $j
		fi
	done
done
quit
