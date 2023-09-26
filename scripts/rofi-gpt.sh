#!/bin/bash
#
# this script acts as a prompt to ChatGPT using shell_gpt and displays the answer using zenity dialogs.
# the $OPENAI_API_KEY variable needs to be declared for shell_gpt to work.
#
# dependencies: rofi, shell_gpt, zenity

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"

gpt_input=$($ROFI_CMD -p "ChatGPT")

if [[ -z $gpt_input ]]; then
    exit 1
fi

zenity --progress --text="Waiting for an answer" --pulsate &

if [[ $? -eq 1 ]]; then
    exit 1
fi

pid=$!

gpt_answer=$(~/.local/bin/sgpt "$gpt_input" --no-animation --no-spinner)
kill $pid
zenity --info --text="$gpt_answer"
