#!/usr/bin/bash
#
# this script search github repositories, offering to open results in browser or clone them locally
#
# dependencies: rofi, curl, jq

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"
GITHUB_CACHE=${GITHUB_CACHE:-"$HOME/.cache/github.json"}
GITHUB_PLACEHOLDER=${GITHUB_PLACEHOLDER:-"Type something and press \"Enter\" to search"}
CLONE_FOLDER=${CLONE_FOLDER:-"$HOME/Downloads/"}

if [ -z $1 ]; then
  query=$(echo "" | $ROFI_CMD -theme-str "entry{placeholder:\"$GITHUB_PLACEHOLDER\";"} -p "Search GitHub")
else
  query=$1
fi

if [ -z "$query" ]; then
  exit 1
fi

# url_encode query
urlencode() {
	echo ${1// /"%20"}
}

counter=1
per_page=100
search_url="https://api.github.com/search/repositories?q=$(urlencode "$query")&per_page=$per_page&page=$counter"

curl "$search_url" -o "$GITHUB_CACHE"

repos_count=$(jq '.total_count' "$GITHUB_CACHE")

repos=$(jq '.items | .[] | "🟊\(.stargazers_count) \(.full_name) (\(.description))"' "$GITHUB_CACHE")

if [ "$repos_count" -gt $per_page ]; then
    repos="$repos\nMore..."
fi

selected_row=0

while repo=$(echo -en "$repos" | tr -d '"' |  $ROFI_CMD -format 'i s' -selected-row "$selected_row" -p "Repository"); do
    selected_row=$(echo "$repo" | cut -d' ' -f1)
    repo=$(echo "$repo" | cut -d' ' -f2-)

    if [ "$repo" = "More..." ]; then
        counter=$((counter+1))
        search_url="https://api.github.com/search/repositories?q=$(urlencode "$query")&per_page=$per_page&page=$counter"

        curl "$search_url" -o "$GITHUB_CACHE"$counter

        new_repos=$(jq -n '{ items: [ inputs.items ] | add }' "$GITHUB_CACHE" "$GITHUB_CACHE"$counter)
        echo "$new_repos" > "$GITHUB_CACHE"
        rm "$GITHUB_CACHE"$counter

        repos=$(jq '.items | .[] | "🟊\(.stargazers_count) \(.full_name) (\(.description))"' "$GITHUB_CACHE")
        new_count=$(jq '.items | length' "$GITHUB_CACHE")

        if [ "$new_count" -lt $repos_count ]; then
            repos="$repos\nMore..."
        fi
    else
        repo_name=$(echo "$repo" | cut -d' ' -f2)

        action=$(echo -en "Open in Browser\nClone" | $ROFI_CMD -p "Action")

        if [ "$action" = "Open in Browser" ]; then
            repo_url=$(jq ".items | .[] | select(.full_name==\"$repo_name\") | .html_url" "$GITHUB_CACHE" | tr -d '"')

            xdg-open "$repo_url"
            exit 0
        elif [ "$action" = "Clone" ]; then
            repo_folder=$(jq ".items | .[] | select(.full_name==\"$repo_name\") | .name" "$GITHUB_CACHE" | tr -d '"')
            clone_url=$(jq ".items | .[] | select(.full_name==\"$repo_name\") | .clone_url" "$GITHUB_CACHE" | tr -d '"')

            cd "$CLONE_FOLDER" && git clone "$clone_url" && xdg-open "$CLONE_FOLDER/$repo_folder"
            exit 0
        fi
    fi
done

exit 1
