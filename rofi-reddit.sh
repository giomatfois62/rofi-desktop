#! /usr/bin/env bash

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
ROFI_CMD="rofi -dmenu -i"
BASE_URL="https://www.reddit.com"
SUB_REDDITS="$SCRIPT_PATH/data/subreddits"

# TODO: get subreddit suggestions or list to filter
subreddit=$(cat $SUB_REDDITS | $ROFI_CMD -p "Subreddit" | sed "s/ //g")

# search in selected subreddit
if [ -n "$subreddit" ]; then
	action=$(echo -e "Open\nSearch Posts" | $ROFI_CMD -p Subreddit)

	# TODO: return to subreddits menu
	if [ ${#action} -eq 0 ]; then
		exit 1
	fi	

	if [ "$action" = "Open" ]; then
		xdg-open $BASE_URL"/r/"$subreddit
		exit 0
    fi

	search_term=$(echo | $ROFI_CMD -p "Search" | sed "s/ /%20/g")
	
	if [ -n "$search_term" ]; then
		search_url="https://www.reddit.com/r/${subreddit}/search/.json?q=${search_term}&restrict_sr=1"
		search_results=$(curl -H "User-Agent: 'your bot 0.1'" "$search_url")

		no_link="$(echo $search_results | grep -c permalink)"

		if [ -n "$search_results" ] && [ "$no_link" -ne 0 ]; then
			permalink=$(jq '.data.children[] | .data["title", "permalink"]' <<< "$search_results" |\
				paste -d "|" - - | $ROFI_CMD -p Results | cut -d'|' -f 2 | xargs)

			if [ -n "$permalink" ]; then
				xdg-open "$BASE_URL$permalink"
				exit 0
			fi
		else
			rofi -e "No results found"
		fi
	fi
fi

exit 1

