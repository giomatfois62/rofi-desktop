#! /usr/bin/env bash
#
# this script displays a list of all subreddits
# selecting an entry will open a search dialog to search posts in the subreddit
#
# dependencies: rofi, curl, jq

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"
BASE_URL="https://www.reddit.com"
SUB_FILE="$SCRIPT_PATH/../data/subreddits"

search_subreddit() {
    subreddit_name="$1"
    search_query="$2"

    search_url="https://www.reddit.com/r/${subreddit_name}/search/.json?q=${search_query}&restrict_sr=1"
    search_results=$(curl -H "User-Agent: 'your bot 0.1'" "$search_url")

    no_link="$(echo "$search_results" | grep -c permalink)"

    if [ -n "$search_results" ] && [ "$no_link" -ne 0 ]; then
        permalink=$(jq '.data.children[] | .data["title", "permalink"]' <<< "$search_results" |\
            paste -d "|" - - | $ROFI_CMD -p "Results" | cut -d'|' -f 2 | xargs)

        if [ -n "$permalink" ]; then
            xdg-open "$BASE_URL$permalink"
            exit 0
        fi
    else
        rofi -e "No results found"
    fi
}

# remember last selected sub
selected_row=0
selected_subreddit=""

while subreddit=$(cat "$SUB_FILE" | $ROFI_CMD -selected-row ${selected_row} -format 'i s' -p "Subreddit"); do
    if [ ${#subreddit} = 0 ]; then
        continue
    fi

    selected_row=$(echo "$subreddit" | awk '{print $1;}')
    selected_subreddit=$(echo "$subreddit" | cut -d' ' -f2-)

    # remove spaces
    subreddit=$(echo "$subreddit" | sed "s/ //g")

    action=$(echo -e "Open in Browser\nSearch Posts" | $ROFI_CMD -p "Action")

    if [ ${#action} = 0 ]; then
        continue
    fi

    if [ "$action" = "Open in Browser" ]; then
        xdg-open $BASE_URL"/r/""$selected_subreddit"
        exit 0
    fi

    # search in selected subreddit
    while search_term=$(echo | $ROFI_CMD -p "Search"); do
        if [ ${#search_term} -gt 0 ]; then
            search_term=$(echo "$search_term" | sed "s/ /%20/g")
            search_subreddit "$selected_subreddit" "$search_term"
        fi
    done
done

exit 1

