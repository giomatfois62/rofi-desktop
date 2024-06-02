#!/usr/bin/env bash

# https://github.com/xcdkz/YT-Feeder

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI_DATA_DIR="${ROFI_DATA_DIR:-$SCRIPT_PATH/data}"
CONFIG="$ROFI_DATA_DIR/yt-feeds"
CACHE="${HOME}/.cache/yt-feeds"
CACHE_RSS="${HOME}/.cache/yt-feeds/RSS"
CACHE_WATCHED="${HOME}/.cache/yt-feeds/watched"

f_download () {
    if [[ $# == 2 ]]
    then
        coproc player ( nohup yt-dlp -f "$1" -o "~/Videos/%(title)s.%(ext)s" "$2" > /dev/null 2>&1 ) &&
        cd .
    elif [[ $# == 3 ]]
    then
        CHECK=$( echo "$2" | cut -d '|' -f2 )
        REVERSE=$( echo "$CHECK" | rev )
        if [[ ${REVERSE:0:1} == "/" ]]
        then
            coproc player ( nohup yt-dlp -f $1 -o "$CHECK%(title)s.%(ext)s" "$3" > /dev/null 2>&1 ) &&
            cd .
        else
            coproc player ( nohup yt-dlp -f $1 -o "$CHECK/%(title)s.%(ext)s" "$3" > /dev/null 2>&1 ) &&
            cd .
        fi
    else
        echo "ERROR: Wrong number of arguments passed to the f_download () function"
        exit 1
    fi
}

f_custom () {
    if [[ $# == 1 ]]
    then
        LINK=$( cat "$CACHE/link" )
        coproc player ( nohup $( echo $1 | cut -d '|' -f2 ) "$LINK" > /dev/null 2>&1 ) &&
        cd .
    else
        echo "ERROR: Wrong number of arguments passed to the f_custom () function"
        exit 1
    fi
}

f_check_pid () {
    if [ -f "$CACHE/pid" ]
    then
        if [[ $# == 0 ]]
        then
            PID_n=$( cat "$CACHE/pid" )
            kill $PID_n
        elif [[ $# == 1 ]]
        then
            PID_n=$( cat "$CACHE/pid" )
            if kill -0 $PID_n ;
            then
                echo "$1";
            else
                rm "$CACHE/pid";
            fi
        else
            echo "ERROR: Wrong number of arguments passed to the f_check_pid () function"
            exit 1
        fi
    fi
}

if [ $# -eq 0 ]
then
    [[ ! -f "$CONFIG" ]] && touch "$CONFIG"
    [[ ! -d "$CACHE_RSS" ]] && mkdir -p "$CACHE_RSS"
    [[ ! -d "$CACHE_WATCHED" ]] && mkdir -p "$CACHE_WATCHED"
fi

if [ $# -eq 0 ]
then
    f_check_pid "stop"
    echo "Refresh (it may take a while)"
    ls -1 "$CACHE_RSS" | sed "s/^/\|-> /"
else
    if [ x"$@" = x"Refresh (it may take a while)" ]
    then
        if [ -f $CONFIG ]
        then
            rm "$CACHE_RSS"/*
            while read p; do
                if [ -z "$p" ]
                then
                    continue
                fi
                FEED=$( echo $p )
                if [[ ! "${FEED:0:19}" == "https://www.youtube" && ! "${p:0:8}" == "DOWNLOAD" && ! "${p:0:7}" == "COMMAND" && ! "${FEED:0:2}" == "//" ]]
                then
                    FEED=$( echo "https://www.youtube.com/feeds/videos.xml?channel_id=$FEED" )
                fi
                if [[ ! "${p:0:8}" == "DOWNLOAD" && ! "${p:0:7}" == "COMMAND" && ! "${FEED:0:2}" == "//" ]]
                then
                    wget $FEED -O "$CACHE_RSS/TMP" &&
                    NAME=$( grep "<title>" "$CACHE_RSS/TMP" | sed -e :a -e 's/<[^>]*>//g;/</N;//ba' | head -n 1 | sed 's/^ *//' )
                    mv "$CACHE_RSS/TMP" "$CACHE_RSS/$NAME"
                fi
            done < $CONFIG
        fi
        f_check_pid "stop"
        ls -1 "$CACHE_RSS" > "$CACHE/tmp" &&
        while read p; do
            if [ ! -f "$CACHE_WATCHED/$p" ]
            then
                touch "$CACHE_WATCHED/$p"
            fi
            CHECK="$p"
            grep "<title>" "$CACHE_RSS/${CHECK}" | sed -e :a -e 's/<[^>]*>//g;/</N;//ba' | tail -n +2 > "$CACHE/tmp_titles"
            COUNTER=0
            while read q; do
                if [[ $( grep -F -c "$q" "$CACHE_WATCHED/$p" ) == 0 ]]
                then
                   ((COUNTER++))
                   echo "$q" >> "$CACHE_WATCHED/$p"
                fi
            done < "$CACHE/tmp_titles"
            if [[ $( wc -l < "$CACHE_WATCHED/$p" ) -gt 15 ]]
            then
                COUNT=$( wc -l < "$CACHE_WATCHED/$p" )
                RES=$(($COUNT-14))
                head -n "$RES" "$CACHE_WATCHED/$p" > "tmp_$p"
                rm "$CACHE_WATCHED/$p"
                mv "tmp_$p" "$CACHE_WATCHED/$p"
            fi
            echo "($COUNTER new videos)|-> $p"
        done < "$CACHE/tmp"
    elif [ x"$@" = x"Stop" ]
    then
        f_check_pid
    elif [ x"$@" = x"Watch (Best Quality)" ]
    then
        LINK=$( cat "$CACHE/link" )
        coproc player ( nohup mpv --ytdl-format=bv+ba "$LINK" > /dev/null 2>&1 ) &&
        rm "$CACHE/link"
    elif [ x"$@" = x"Watch (Worst Quality)" ]
    then
        LINK=$( cat "$CACHE/link" )
        coproc player ( nohup mpv --ytdl-format=worst "$LINK" > /dev/null 2>&1 ) &&
        rm "$CACHE/link"
    elif [ x"$@" = x"Download" ]
    then
        LINK=$( cat "$CACHE/link" )
        while read p; do
            if [[ "${p:0:8}" == "DOWNLOAD" ]]
            then
                f_download "best" "${p:9}" "$LINK"
                exit 0
            fi
        done < "$CONFIG"
        f_download "best" "$LINK"
    elif [ x"$@" = x"Download Audio" ]
    then
        LINK=$( cat "$CACHE/link" )
        tail -n 3 "$CONFIG" > "$CACHE/TMP"
        while read p; do
            if [[ "${p:0:14}" == "DOWNLOAD_AUDIO" ]]
            then
                f_download "bestaudio" "${p:15}" "$LINK"
                exit 0
            fi
        done < "$CONFIG"
        f_download "bestaudio" "~/Music" "$LINK"
    elif [ x"$@" = x"Play in the Background" ]
    then
        f_check_pid
        LINK=$( cat "$CACHE/link" )
        coproc player ( nohup mpv --no-video "$LINK" > /dev/null 2>&1 ) &&
        rm "$CACHE/link"
        echo ${player_PID} > "$CACHE/pid"
    elif [ x"$@" = x"Open in Browser" ]
    then
        LINK=$( cat "$CACHE/link" )
        coproc player ( nohup xdg-open $LINK > /dev/null 2>&1 ) &&
        cd .
    elif [ x"$@" = x"Custom Command" ]
    then
        tail -n 3 "$CONFIG" > "$CACHE/TMP"
        while read p; do
            if [[ "${p:0:7}" == "COMMAND" ]]
            then
                f_custom "$p"
                break
            fi
        done < "$CONFIG"
    else
        CHECK=$@
        if [[ $( echo "$CHECK" | grep -F -c "|-> " ) == 1 ]]
        then
            TAG="media:title"
            if [[ "${CHECK:0:4}" == "|-> " ]]
            then
                CHECK=$( echo "${CHECK:4}" )
            else
                CHECK=$( echo "$CHECK" | awk -F '|-> ' '{print $2}' )
            fi
            echo "$CHECK" > "$CACHE/last"
            grep "<title>" "$CACHE_RSS/$CHECK" | sed -e :a -e 's/<[^>]*>//g;/</N;//ba' | tail -n +2 | sed 's/\&quot;/\"/g' | sed 's/\&amp;/\&/g' | sed 's/^  //'
        else
            TITLE=$( cat "$CACHE/last" )
            VIDEO=$( echo "$@" | sed 's/\"/quot;/g' | sed 's/\&/\&amp;/g' | sed 's/quot;/\&quot;/g' )
            LINK=$( grep -F -A 1 "<title>$VIDEO" "$CACHE_RSS/$TITLE" | tail -n1 | sed -r 's/^.+href="([^"]+)".+$/\1/' )
            echo $LINK > "$CACHE/link"
            echo "Watch (Best Quality)"
            echo "Watch (Worst Quality)"
            echo "Play in the Background"
            echo "Open in Browser"
            echo "Download"
            echo "Download Audio"
            echo "Custom Command"
        fi
    fi
fi
