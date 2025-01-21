#!/usr/bin/bash
#
# this script search github repositories, opens repositories in browser or clone them locally
#
# dependencies: rofi, curl, jq

ROFI="${ROFI:-rofi}"
ROFI_CACHE_DIR="${ROFI_CACHE_DIR:-$HOME/.cache}"
CLONE_FOLDER=${CLONE_FOLDER:-"$HOME/Downloads/"}

github_cache="$ROFI_CACHE_DIR/github.json"

if [ -z $1 ]; then
  query=$(echo "" | $ROFI -dmenu -i -p "Search GitHub")
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
per_page=50
search_url="https://api.github.com/search/repositories?q=$(urlencode "$query")&per_page=$per_page&page=$counter"

curl "$search_url" -o "$github_cache"

repos_count=$(jq '.total_count' "$github_cache")
repos=$(jq '.items | .[] | "🟊\(.stargazers_count) \(.full_name) [\(.language)](\(.description))"' "$github_cache")

if [ "$repos_count" -gt $per_page ]; then
    repos="$repos\nMore..."
fi

selected_row=0

while repo=$(echo -en "$repos" | tr -d '"' |  $ROFI -dmenu -i -format 'i s' -selected-row "$selected_row" -p "Repository"); do
    selected_row=$(echo "$repo" | cut -d' ' -f1)
    repo=$(echo "$repo" | cut -d' ' -f2-)

    if [ "$repo" = "More..." ]; then
        counter=$((counter+1))
        search_url="https://api.github.com/search/repositories?q=$(urlencode "$query")&per_page=$per_page&page=$counter"

        curl "$search_url" -o "$github_cache"$counter

        new_repos=$(jq -n '{ items: [ inputs.items ] | add }' "$github_cache" "$github_cache"$counter)
        echo "$new_repos" > "$github_cache"
        rm "$github_cache"$counter

        repos=$(jq '.items | .[] | "🟊\(.stargazers_count) \(.full_name) [\(.language)](\(.description))"' "$github_cache")
        new_count=$(jq '.items | length' "$github_cache")

        if [ "$new_count" -lt $repos_count ]; then
            repos="$repos\nMore..."
        fi
    else
        repo_name=$(echo "$repo" | cut -d' ' -f2)

        action=$(echo -en "Open in Browser\nClone" | $ROFI -dmenu -i -p "Action")

        if [ "$action" = "Open in Browser" ]; then
            repo_url=$(jq ".items | .[] | select(.full_name==\"$repo_name\") | .html_url" "$github_cache" | tr -d '"')

            xdg-open "$repo_url"
            exit 0
        elif [ "$action" = "Clone" ]; then
            repo_folder=$(jq ".items | .[] | select(.full_name==\"$repo_name\") | .name" "$github_cache" | tr -d '"')
            clone_url=$(jq ".items | .[] | select(.full_name==\"$repo_name\") | .clone_url" "$github_cache" | tr -d '"')

            cd "$CLONE_FOLDER" && git clone "$clone_url" && xdg-open "$CLONE_FOLDER/$repo_folder"
            exit 0
        fi
    fi
done

exit 1
