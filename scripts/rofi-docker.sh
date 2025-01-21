#!/usr/bin/bash
#
# https://github.com/denpolischuk/rofi-docker
#
# rofi script to control docker containers
#
# dependencies: rofi, docker

ROFI="${ROFI:-rofi}"
TERMINAL="${TERMINAL:-xterm}"

function execInTerminal {
    $TERMINAL -e $SHELL -c "$1"
}

selected_container=$(docker ps --format "table {{.ID}}:\t[{{.Image}}]\t{{.Names}}" | sed '1d' | $ROFI -dmenu -i -p "Running Containers")
container_attach="Attach"
container_stop="Stop"
container_logs="Logs"
container_restart="Restart"

if [[ ! -z $selected_container ]]; then
    container_id=$(echo $selected_container | cut -d':' -f 1)
    container_name=$(echo $selected_container | cut -d ' ' -f 3)
    selected_action=$(echo -e "$container_attach\n$container_logs\n$container_restart\n$container_stop" | $ROFI -dmenu -i -p "Action")
    case $selected_action in 
        $container_attach)
            execInTerminal "docker exec -it ${container_id} /bin/sh" 
            exit 0;;
        $container_restart)
            msg=$(docker restart $container_id)
            $ROFI -e "Message from docker: $msg" ;;
        $container_logs)
            execInTerminal "docker logs -f ${container_id}" ;;
        $container_stop)
            msg=$(docker stop $container_id)
            $ROFI -e "Message from docker: $msg" ;;
	esac
fi

exit 1
