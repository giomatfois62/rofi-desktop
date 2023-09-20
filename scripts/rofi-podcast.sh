#!/usr/bin/env bash
#
# this script fetches and opens podcasts from rss.com
#
# dependencies: rofi, curl, jq, mpv

# TODO: fix default path to podcasts folder using script path or data path

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"
PODCAST_FOLDER=${PODCAST_FOLDER:-"$SCRIPT_PATH/../data/podcasts"}
PODCAST_CACHE=${PODCAST_CACHE:-"$HOME/.cache/podcasts"}
PODCAST_HISTORY=${PODCAST_HISTORY:-"$PODCAST_CACHE/recents"}
PODCAST_EXPIRATION_TIME=${PODCAST_EXPIRATION_TIME:-3600} # refresh episodes files every hour
PODCAST_PLAYER=${PODCAST_PLAYER:-mpv --no-resume-playback --force-window=immediate}

mkdir -p $PODCAST_CACHE

show_episodes() {
    local title="$1"
    local podcast_file="$2"

    get_desc=".[] | select(.title==\"$title\") | .description"
    desc=$(jq -r "$get_desc" "$podcast_file" | sed -e 's/<[^>]*>//g')

    get_slug=".[] | select(.title==\"$title\") | .slug"
    slug=$(jq -r "$get_slug" "$podcast_file")

    get_author=".[] | select(.title==\"$title\") | .author_name"
    author=$(jq -r "$get_author" "$podcast_file")

    episodes_file="$PODCAST_CACHE/$slug"

    counter=1
    series_url="https://apollo.rss.com/podcasts/$slug/episodes?limit=10&page="$counter

    if [ -f "$episodes_file" ]; then
        # compute time delta between current date and file date
        news_date=$(date -r "$episodes_file" +%s)
        current_date=$(date +%s)

        delta=$((current_date - news_date))

        # refresh file if it's too old
        if [ $delta -gt $PODCAST_EXPIRATION_TIME ]; then
            curl --silent "$series_url" -o "$episodes_file"
        fi
    else
        curl --silent "$series_url" -o "$episodes_file"
    fi

    episodes=$(jq -r ".episodes | .[] | .title" "$episodes_file")
    header="<b>$title</b> ($author)""&#x0a;""&#x0a;""$desc"
    episodes_count=$(echo "$episodes" | wc -l)

    if [ $episodes_count -gt 9 ]; then
        episodes="$episodes\nMore..."
    fi


    while episode=$(echo -en "$episodes" | rofi -dmenu -i -mesg "$header" -p "Episode"); do
        if [ "$episode" = "More..." ]; then
            counter=$((counter+1))
            series_url="https://apollo.rss.com/podcasts/$slug/episodes?limit=10&page="$counter

            curl "$series_url" -o "$episodes_file"$counter
            new_episodes=$(jq -n '{ episodes: [ inputs.episodes ] | add }' "$episodes_file" "$episodes_file"$counter)
            echo "$new_episodes" > "$episodes_file"
            rm "$episodes_file"$counter

            episodes=$(jq -r ".episodes | .[] | .title" "$episodes_file")
        else
            episode_link=$(jq -r ".episodes | .[] | select(.title==\"$episode\") | .episode_asset" "$episodes_file")
            episode_url="https://media.rss.com/$slug/$episode_link"

            history_entry="$category/$title"
            touch "$PODCAST_HISTORY"

            # https://unix.stackexchange.com/questions/389482/unix-search-and-remove-variable-contains-slash-from-a-file
            grep -Fv -f <(echo "$history_entry") "$PODCAST_HISTORY" > "$PODCAST_HISTORY".tmp
            mv "$PODCAST_HISTORY".tmp "$PODCAST_HISTORY"

            #https://stackoverflow.com/questions/10587615/unix-command-to-prepend-text-to-a-file
            printf '%s\n%s\n' "$history_entry" "$(cat "$PODCAST_HISTORY")" > "$PODCAST_HISTORY"

            $PODCAST_PLAYER "$episode_url"

            exit 0
        fi
    done
}

categories=$(cd "$PODCAST_FOLDER" && find * -type f -name "*.json" | sed -e 's/\.json$//')

while category=$(echo -en "Recently Played\n$categories" | $ROFI_CMD -p "Category"); do
    if [ "$category" = "Recently Played" ]; then
        while entry=$(cat "$PODCAST_HISTORY" | $ROFI_CMD -p "Podcast"); do
            IFS='/' read -r category title <<< "$entry"

            podcast_file="$PODCAST_FOLDER/$category.json"

            show_episodes "$title" "$podcast_file"
        done
    else
        podcast_file="$PODCAST_FOLDER/$category.json"

        while podcast=$(jq '.[] | "\(.title) {\(.author_name)} {\(.language)}"' "$podcast_file" | tr -d '"' | $ROFI_CMD -p "Podcast"); do
            title=$(echo "$podcast" | cut -d"{" -f1 | sed 's/ *$//g')

            show_episodes "$title" "$podcast_file"
        done
    fi
done

exit 1
