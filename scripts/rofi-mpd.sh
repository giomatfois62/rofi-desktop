#!/usr/bin/env bash
#
# this script controls the music player daemon (mpd) using mpc commands
#
# dependencies: rofi, mpd, mpc

# TODO: remember last row

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"

MPD_SHORTCUTS_HELP=${MPD_SHORTCUTS_HELP:-"Press \"Alt+Q\" to add the entry to the queue&#x0a;Press \"Alt+P\" to play/pause player&#x0a;Press \"Alt+J\" to play previous entry in queue&#x0a;Press \"Alt+K\" to play next entry in queue"}

call_rofi() {
  # escape song name string
  # https://stackoverflow.com/questions/12873682/short-way-to-escape-html-in-bash
  player_status=$(mpc status | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g')

  $ROFI_CMD -kb-custom-1 "Alt+q" -kb-custom-2 "Alt+p" -kb-custom-3 "Alt+k" -kb-custom-4 "Alt+j" -mesg "$player_status&#x0a;&#x0a;$MPD_SHORTCUTS_HELP" "$@" ;
}

artist() {
  mpc list artist | sort -f | call_rofi -p "Artists"
}

a_album() {
  mpc list album artist "$1" | sort -f | call_rofi -p "Albums"
}

album() {
  mpc list album | sort -f | call_rofi -p "Album"
}

song() {
  mpc list title | sort -f | call_rofi -p "Song"
}

files() {
  mpc listall | sort -f | call_rofi -p "File"
}

toggle_player() {
  is_playing=$(mpc status | grep playing)

  [ -n "$is_playing" ] && mpc pause
  [ -z "$is_playing" ] && mpc play
}

check_exit_code() {
  [ "$1" -eq 11 ] && toggle_player
  [ "$1" -eq 12 ] && mpc next
  [ "$1" -eq 13 ] && mpc prev
}

print_help() {
   echo "
    usage: rofi-mpd [-h] [-l] [-s] [-a]

    arguments:
    -h, --help        show this message and exit
    -l, --library     library mode (artist -> album)
    -A, --album       album mode
    -s, --song        song mode (select one song)
    -a, --ask         ask for mode

    bindings:
    enter             play song/album now
    Alt+q             add song/album to queue
    Alt+p             play/pause player
    Alt+j             previous entry in queue
    Alt+k             next entry in queue
      "
}

get_mode() {
  case "$1" in
    -l | --library) mode=Library ;;
    -A | --album) mode=Album ;;
    -s | --song) mode=Song ;;
    -f | --files) mode=Files ;;
    -a | --ask)
      MODE=$(printf "Library\nAlbum\nSong\nFiles" | call_rofi -p "Choose Mode")
      cod=$?
      check_exit_code $cod
      if [ "$cod" -eq 0 ]; then
        mode=$MODE
      elif [ "$cod" -eq 1 ]; then
        mode=""
      fi
      ;;
    -h | --help)
      print_help
      exit
      ;;
    *)
      print_help
      exit
      ;;
  esac
}

# check mpd is running
if [ -z "$(pidof mpd)" ]; then
    rofi -e "MPD is not running."
    exit 1
fi

while :
do
  get_mode "$1"

  case "$mode" in
    Library)
      while :
      do
        artist=$(artist)
        cod=$?
        check_exit_code $cod
        [ ! "$artist" ] && break

        while :
        do
          album=$(a_album "$artist")
          cod=$?
          check_exit_code $cod
          [ ! "$album" ] && break

          [ "$cod" -eq 10 ] && mpc find artist "$artist" album "$album" | mpc add

          if [ "$cod" -eq 0 ]; then
              mpc clear
              mpc find artist "$artist" album "$album" | mpc add
              mpc play >/dev/null
          fi
        done
      done
      ;;
    Song)
      while :
      do
        song=$(song)
        cod=$?
        check_exit_code $cod
        [ ! "$song" ] && break

        [ "$cod" -eq 10 ] && mpc search "(title==\"$song\")" | mpc add

        if [ "$cod" -eq 0 ]; then
            mpc clear
            mpc search "(title==\"$song\")" | mpc add
            mpc play >/dev/null
        fi
      done
      ;;
    Album)
      while :
      do
        album=$(album)
        cod=$?
        check_exit_code $cod
        [ ! "$album" ] && break

        [ "$cod" -eq 10 ] && mpc find album "$album" | mpc add

        if [ "$cod" -eq 0 ]; then
          mpc clear
          mpc find album "$album" | mpc add
          mpc play >/dev/null
        fi
      done
      ;;
    Files)
      while :
      do
        file=$(files)
        cod=$?
        check_exit_code $cod
        [ ! "$file" ] && break

        [ "$cod" -eq 10 ] && mpc add "$file"

        if [ "$cod" -eq 0 ]; then
          mpc clear
          mpc add "$file"
          mpc play >/dev/null
        fi
      done
      ;;
    *)
      exit 1
      ;;
  esac
done

exit 1
