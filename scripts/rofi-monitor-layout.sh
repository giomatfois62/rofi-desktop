#!/bin/bash
#
# https://github.com/davatorium/rofi-scripts/blob/master/monitor_layout.sh
#
# this controls the monitor layout using xrand
#
# dependencies: rofi, xrandr

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"
ROFI_CONFIG_DIR="${ROFI_CONFIG_DIR:-$SCRIPT_PATH/config}"

MONITORS_CACHE="$ROFI_CONFIG_DIR/monitor-layout"

XRANDR=$(which xrandr)

MONITORS=( $( ${XRANDR} | awk '( $2 == "connected" ){ print $1 }' ) )

NUM_MONITORS=${#MONITORS[@]}

TITLES=()
COMMANDS=()

function gen_xrandr_only()
{
    selected=$1

    cmd="xrandr --output ${MONITORS[$selected]} --auto "

    for entry in $(seq 0 $((${NUM_MONITORS}-1)))
    do
        if [ $selected != $entry ]
        then
            cmd="$cmd --output ${MONITORS[$entry]} --off"
        fi
    done

    echo $cmd
}

declare -i index=0
TILES[$index]="Cancel"
COMMANDS[$index]="true"
index+=1

for entry in $(seq 0 $((${NUM_MONITORS}-1)))
do
    TILES[$index]="Only ${MONITORS[$entry]}"
    COMMANDS[$index]=$(gen_xrandr_only $entry)
    index+=1
done

##
# Dual screen options
##
for entry_a in $(seq 0 $((${NUM_MONITORS}-1)))
do
    for entry_b in $(seq 0 $((${NUM_MONITORS}-1)))
    do
        if [ $entry_a != $entry_b ]
        then
            TILES[$index]="Dual Screen ${MONITORS[$entry_a]} -> ${MONITORS[$entry_b]}"
            COMMANDS[$index]="xrandr --output ${MONITORS[$entry_a]} --auto \
                              --output ${MONITORS[$entry_b]} --auto --left-of ${MONITORS[$entry_a]}"

            index+=1
        fi
    done
done

##
# Clone monitors
##
for entry_a in $(seq 0 $((${NUM_MONITORS}-1)))
do
    for entry_b in $(seq 0 $((${NUM_MONITORS}-1)))
    do
        if [ $entry_a != $entry_b ]
        then
            TILES[$index]="Clone Screen ${MONITORS[$entry_a]} -> ${MONITORS[$entry_b]}"
            COMMANDS[$index]="xrandr --output ${MONITORS[$entry_a]} --auto \
                              --output ${MONITORS[$entry_b]} --auto --same-as ${MONITORS[$entry_a]}"

            index+=1
        fi
    done
done

##
#  Generate entries, where first is key.
##
function gen_entries()
{
    for a in $(seq 0 $(( ${#TILES[@]} -1 )))
    do
        echo $a ${TILES[a]}
    done
}

# Call menu
SEL=$( gen_entries | $ROFI_CMD -p "Monitor Setup" | awk '{print $1}' )

# Call xrandr
if [ "${COMMANDS[$SEL]}" != "true" ]; then
    $( ${COMMANDS[$SEL]} )

    # Save command to cache
    echo "${COMMANDS[$SEL]}" > "$MONITORS_CACHE"
else
    echo "Cancel"
fi
