#!/usr/bin/env bash
#
# this script controls the music player daemon (mpd) using mpc commands
#
# dependencies: rofi, mpd, mpc

ROFI="${ROFI:-rofi}"

mpd_shortcuts_help="<b>Alt+Q</b> add to queue | <b>Alt+P</b> play/pause | <b>Alt+J</b> previous song | <b>Alt+K</b> next song"
mpd_shortcuts="-kb-custom-1 "Alt+q" -kb-custom-2 "Alt+p" -kb-custom-3 "Alt+k" -kb-custom-4 "Alt+j""

player_mesg() {
  # escape song name string
  # https://stackoverflow.com/questions/12873682/short-way-to-escape-html-in-bash
  player_status=$(mpc status | head -n -1 | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g')
  if [ -n "$player_status" ]; then
    echo "$player_status&#x0a;&#x0a;$mpd_shortcuts_help"
  else
    echo "$mpd_shortcuts_help"
  fi
}

toggle_player() {
  is_playing=$(mpc status | grep playing)

  [ -n "$is_playing" ] && mpc pause
  [ -z "$is_playing" ] && mpc play
}

check_shortcuts() {
  [ "$1" -eq 11 ] && toggle_player
  [ "$1" -eq 12 ] && mpc next
  [ "$1" -eq 13 ] && mpc prev
}

search_music() {
  case "$1" in
    "File") mpc listall ;;
    "Album") mpc list album ;;
    "Song") mpc list title ;;
  esac
}

add_entry() {
  entry_type="$1"
  entry="$2"

  case "$entry_type" in
    "File") mpc add "$entry" ;;
    "Album") mpc find album "$album" | mpc add ;;
    "Song") mpc search "(title==\"$entry\")" | mpc add ;;
  esac
}

select_entry() {
  entry_type="$1"
  row=0

  while :
  do
    entry_chosen=$(search_music "$entry_type" | sort -f |\
        $ROFI -dmenu -i $mpd_shortcuts -format 'i s' -selected-row $row -mesg "$(player_mesg)" -p "$entry_type")

    exit_code=$?
    check_shortcuts $exit_code

    row=$(echo "$entry_chosen" | cut -d' ' -f1)
    entry_chosen=$(echo "$entry_chosen" | cut -d' ' -f2-)

    if [ ! "$entry_chosen" ]; then
      break
    elif [ "$exit_code" -eq 10 ]; then
      add_entry "$1" "$entry_chosen"
    elif [ "$exit_code" -eq 0 ]; then
      mpc clear
      add_entry "$1" "$entry_chosen"
      mpc play >/dev/null
    fi
  done
}

search_library() {
  selected_artist=0

  while :
  do
    artist=$(mpc list artist | sort -f |\
        $ROFI -dmenu -i $mpd_shortcuts -format 'i s' -selected-row $selected_artist -mesg "$(player_mesg)" -p "Artist")

    exit_code=$?
    check_shortcuts $exit_code

    selected_artist=$(echo "$artist" | cut -d' ' -f1)
    artist=$(echo "$artist" | cut -d' ' -f2-)

    [ ! "$artist" ] && break

    row=0

    while :
    do
      album=$(mpc list album artist "$artist" | sort -f |\
          $ROFI -dmenu -i $mpd_shortcuts -format 'i s' -selected-row $row -mesg "$(player_mesg)" -p "Album")

      exit_code=$?
      check_shortcuts $exit_code

      row=$(echo "$album" | cut -d' ' -f1)
      album=$(echo "$album" | cut -d' ' -f2-)

      if [ ! "$album" ]; then
        break
      elif [ "$exit_code" -eq 10 ]; then
        mpc find artist "$artist" album "$album" | mpc add
      elif [ "$exit_code" -eq 0 ]; then
        mpc clear
        mpc find artist "$artist" album "$album" | mpc add
        mpc play >/dev/null
      fi
    done
  done
}

search_albums() {
  select_entry "Album"
}

search_songs() {
  select_entry "Song"
}

search_files() {
  select_entry "File"
}

select_mode() {
  row=0

  while :
  do
    entry_chosen=$(printf "Library\nAlbum\nSong\nFiles" |\
        $ROFI -dmenu -i $mpd_shortcuts -format 'i s' -selected-row $row -mesg "$(player_mesg)" -p "Music")

    exit_code=$?
    check_shortcuts $exit_code

    row=$(echo "$entry_chosen" | cut -d' ' -f1)
    entry_chosen=$(echo "$entry_chosen" | cut -d' ' -f2-)

    if [ ! "$entry_chosen" ]; then
      break
    elif [ "$exit_code" -eq 0 ]; then
      case "$entry_chosen" in
        "Files") search_files ;;
        "Album") search_albums ;;
        "Song") search_songs ;;
        "Library") search_library ;;
      esac
    fi
  done
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

main() {
  case "$1" in
    -l | --library) search_library ;;
    -A | --album) search_albums ;;
    -s | --song) search_songs ;;
    -f | --files) search_files ;;
    -a | --ask) select_mode ;;
    -h | --help) print_help && exit ;;
  esac
}

if ! command -v mpc &> /dev/null; then
	$ROFI -e "Install mpd and mpc to enable the music player menu"
	exit 1
fi

# check mpd is running
if [ -z "$(pidof mpd)" ]; then
    $ROFI -e "MPD is not running."
    exit 1
fi

main "$1"

exit 1
