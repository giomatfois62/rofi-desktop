#!/usr/bin/env sh

term=${TERMINAL-xterm}
default_action=${SYSTEMD_DEFAULT_ACTION-"list_actions"}
rofi_command=${ROFI-"rofi"}
truncate_length=${ROFI_SYSTEMD_TRUNCATE_LENGTH-60}
files_jquery_columns=${ROFI_SYSTEMD_FILES_JQ_COLUMNS-'(.[0] + " " + .[1])'}
running_jquery_columns=${ROFI_SYSTEMD_RUNNING_JQ_COLUMNS-'(.[0] + " " + .[3])'}
get_units_strategy=${ROFI_SYSTEMD_GET_UNITS_STRATEGY-files}

function truncate {
	awk '{print substr($0, length($0)-'$truncate_length')}'
}

function call_systemd_dbus {
	busctl call org.freedesktop.systemd1 /org/freedesktop/systemd1 \
		   org.freedesktop.systemd1.Manager "$@" --json=short
}

function unit_files {
	call_systemd_dbus ListUnitFiles "$1" | jq ".data[][] | $files_jquery_columns" -r | \
		awk -F'/' '{print $NF}'
}

function running_units {
	call_systemd_dbus ListUnits "$1" | jq ".data[][] | $running_jquery_columns" -r
}

function get_units {
	{ running_units "--$1";  } | sort -u -k1,1 | truncate |
		awk -v unit_type="$1" '{print $0 " " unit_type}'
}

function get_unit_files {
	{ unit_files "--$1";  } | sort -u -k1,1 | truncate |
		awk -v unit_type="$1" '{print $0 " " unit_type}'
}

function all_units {
	case "$get_units_strategy" in
		"files")
			{ get_unit_files user; get_unit_files system; } | column -tc 1
			;;
		"units")
			{ get_units user; get_units system; } | column -tc 1
			;;
		*)
			{ get_units user; get_units system; } | column -tc 1
			{ get_unit_files user; get_unit_files system; } | column -tc 1
			;;
	esac
}

enable="Alt+e"
disable="Alt+d"
stop="Alt+k"
restart="Alt+r"
tail="Alt+t"
boot_logs="Alt+l"

all_actions="enable
disable
stop
restart
tail
boot_logs
list_actions"

function select_service_and_act {
	result=$($rofi_command -dmenu -i -p "Unit" \
	              -kb-custom-1 "${enable}" \
	              -kb-custom-2 "${disable}" \
	              -kb-custom-3 "${stop}" \
	              -kb-custom-4 "${restart}" \
	              -kb-custom-5 "${tail}" \
				  -kb-custom-6 "${boot_logs}")

	rofi_exit="$?"

	case "$rofi_exit" in
		1)
			action="exit"
			exit 1
			;;
		10)
			action="enable"
			;;
		11)
			action="disable"
			;;
		12)
			action="stop"
			;;
		13)
			action="restart"
			;;
		14)
			action="tail"
			;;
		15)
			action="boot_logs"
			;;
		16)
			action="list_actions"
			;;
		*)
			action="$default_action"
			;;
	esac

	selection="$(echo $result | sed -n 's/ \+/ /gp')"
	service_name=$(echo "$selection" | awk '{ print $1 }' | tr -d ' ')
	is_user="$(echo $selection | awk '{ print $3 }' )"

	case "$is_user" in
		user*)
			user_arg="--user"
			command="systemctl $user_arg"
			;;
		system*)
			user_arg=""
			command="sudo systemctl"
			;;
		*)
			command="systemctl"
	esac

	to_run="$(get_command_with_args)"
	if [ ! -t 1 ] && [[ "$to_run" = *"journalctl"* ]]; then
		to_run="$term -e $to_run"
	else
		to_run="$to_run | less"
	fi
	echo "Running $to_run"
	eval "$to_run"
}

function get_command_with_args {
	case "$action" in
		"tail")
			echo "journalctl $user_arg -u '$service_name' -f"
			;;
		"boot_logs")
			echo "journalctl $user_arg -u '$service_name' --boot"
			;;
		"list_actions")
			action=$(echo "$all_actions" | $rofi_command -dmenu -i -p "Select action: ")
			get_command_with_args
			;;
		*)
			echo "$command $action '$service_name'"
			;;
	esac
}

all_units | select_service_and_act
