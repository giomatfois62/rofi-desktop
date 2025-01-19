#!/bin/bash
#
# a simple quiz game in rofi using opentdb api
#
# dependencies: rofi, curl, jq

ROFI="${ROFI:-rofi}"

url="https://opentdb.com/api.php?amount=1"
points=0

remove_quotes() {
    local str=${*:-$(</dev/stdin)}
    echo "${str:1:${#str}-2}"
}

while [ True ]; do
    quiz=$(curl -s "$url" | jq ".results[0]")

    if [ "$quiz" = "null" ] || [ -z "$quiz" ]; then
        $ROFI -e "Error downloading quiz."
        exit 1
    fi

    category=$(echo "$quiz" | jq '.category' | remove_quotes)
    difficulty=$(echo "$quiz" | jq '.difficulty' | remove_quotes)
    question=$(echo "$quiz" | jq '.question' | remove_quotes)
    correct_answer=$(echo "$quiz" | jq '.correct_answer' | remove_quotes)
    incorrect_answers=$(echo "$quiz" | jq '.incorrect_answers | join("\n")' | remove_quotes)

    mesg="<b>$category</b>&#x0a;&#x0a;$question"

    choice=$(echo -e "$correct_answer\n$incorrect_answers" | \
        shuf | \
        $ROFI -dmenu -i -markup -markup-rows -p "Answer" -mesg "$mesg")

    [ -z "$choice" ] && break
        
    if [ "$choice" = "$correct_answer" ]; then
        case "$difficulty" in
            "easy")   win=1 ;;
            "medium") win=3 ;;
            "hard")   win=5 ;;
        esac
        
        points=$((points+win))
        mesg="$mesg&#x0a;&#x0a;<b>$choice</b>&#x0a;Correct! +$win Points ($points total)"
    else
        mesg="$mesg&#x0a;&#x0a;<b>$choice</b>&#x0a;Wrong! Correct Answer: <b>$correct_answer</b>"
    fi

    choice=$(echo -e "Play Again\nExit" | \
        $ROFI -dmenu -i -markup -p "Answer" -mesg "$mesg")

    if [ -z "$choice" ] || [ "$choice" = "Exit" ]; then
        break
    fi
done
