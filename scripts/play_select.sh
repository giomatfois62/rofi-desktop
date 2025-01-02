#!/bin/bash

#echo "$1" >> $HOME/selection_log

#if [[ -n "$@" ]]; then 
    #killall espeak
    #echo "selected: $@" | sed -e 's/<span.*<\/span>//g' | espeak
    #coproc aplay -q /home/mat/Music/metal_gear_select.wav
coproc aplay -q /home/mat/Programs/rofi-desktop/scripts/sounds/current/select.wav
#fi
