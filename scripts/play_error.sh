#!/bin/bash

#echo "$@" >> $HOME/selection_log

#if [[ -n "$@" ]]; then
    #killall espeak
    #echo "$@" | sed -e 's/<span.*<\/span>//g' | espeak
    #killall piper
    #echo "$@" | $HOME/Programs/piper/piper --model /home/mat/Programs/piper-voices/en/en_US/lessac/high/en_US-lessac-high.onnx --output-raw | aplay -r 22050 -f S16_LE -t raw -
coproc aplay -q /home/mat/Programs/rofi-desktop/scripts/sounds/current/error.wav
#fi
