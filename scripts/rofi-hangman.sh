#!/bin/bash
#
# a simple hangman game in rofi
# place custom word files in the data directory
#
# dependencies: rofi

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI="${ROFI:-rofi}"
ROFI_DATA_DIR="${ROFI_DATA_DIR:-$SCRIPT_PATH/data}"
WORDS_DIR="$ROFI_DATA_DIR/hangman"

hangman0=" ____
|    |
|    
|   
|
|       "

hangman1=" ____
|    |
|    O
|   
|
|       "

hangman2=" ____
|    |
|    O
|    |
|
|       "

hangman3=" ____
|    |
|    O
|    |\\
|
|       "

hangman4=" ____
|    |
|    O
|   /|\\
|
|       "

hangman5=" ____
|    |
|    O
|   /|\\
|     \\
|       "

hangman6=" ____
|    |
|    O
|   /|\\
|   / \\
|       "

while category=$(ls "$WORDS_DIR" | $ROFI -dmenu -i -p "Category"); do
    while true; do
        letters="A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|T|U|V|W|X|Y|Z"
        used=""
        errors=0

        word=$(shuf -n1 "$WORDS_DIR/$category" | tr a-z A-Z)
        word_len=${#word}
        word_array=()
        guess=()

        for ((i=0;i<$word_len;i++)); do
            word_array[$i]=${word:i:1}

            if [[ ${word_array[$i]} == " " ]]; then
                guess[$i]=" "
            elif [[ ${word_array[$i]} == "'" ]]; then
                guess[$i]="'"
            elif [[ ${word_array[$i]} == "'" ]]; then
                guess[$i]="."
            elif [[ ${word_array[$i]} == "&" ]]; then
                guess[$i]="&"
            elif [[ ${word_array[$i]} == ":" ]]; then
                guess[$i]=":"
            elif [[ ${word_array[$i]} == "-" ]]; then
                guess[$i]="-"
            elif [[ ${word_array[$i]} == "!" ]]; then
                guess[$i]="!"
            elif [[ ${word_array[$i]} == "?" ]]; then
                guess[$i]="?"
            elif [[ ${word_array[$i]} == "$" ]]; then
                guess[$i]="$"
            elif [[ ${word_array[$i]} == "%" ]]; then
                guess[$i]="%"
            elif [[ ${word_array[$i]} == "*" ]]; then
                guess[$i]="*"
            elif [[ ${word_array[$i]} == ?(-)+([0-9]) ]]; then
                guess[$i]=${word_array[$i]}
            else
                guess[$i]="_"
            fi
        done

        while true; do
            name="hangman$errors"
            mesg="${!name}"${guess[@]}

            choice=$(echo $letters | $ROFI -dmenu -i -sep "|" -mesg "$mesg" -p "$category" -theme-str "listview{columns:7;flow:horizontal;}")

            if [ -z "$choice" ]; then
                exit
            else
                letters=$(echo $letters | sed -e "s/$choice//")
                used=$used"|$choice"

                found=0
                win=1
                
                for ((i=0;i<$word_len;i++)); do
                    if [[ ${word_array[$i]} == "$choice" ]]; then
                        guess[$i]=$choice
                        found=1
                    fi
                    
                    if [[ ${guess[$i]} == "_" ]]; then
                        win=0
                    fi
                done

                if [[ found -eq 0 ]]; then
                    errors=$((errors+1))
                fi
                
                name="hangman$errors"
                mesg="${!name}"${guess[@]}

                if [[ errors -gt 5 ]]; then
                    mesg="$mesg   You Lose"
                    break
                fi

                if [[ win -eq 1 ]]; then
                    mesg="$mesg   You Win"
                    break
                fi
            fi
        done
        
        retry=$(echo -en "Play Again\nExit" | $ROFI -dmenu -i -mesg "$mesg" -p "$category")
        
        if [ -z "$retry" ]; then
            break
        fi

        if [ "$retry" == "Exit" ]; then
            exit
        fi
    done
done
