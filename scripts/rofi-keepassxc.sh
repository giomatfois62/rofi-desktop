#!/bin/sh
#
# https://github.com/wzykubek/rofi-keepassxc
#
# this script manages a KeePassXC passwords database using keypassxc-cli
#
# dependencies: rofi, keepassxc-cli, xclip/wl-clipboard

ROFI="${ROFI:-rofi}"
ROFI_CACHE_DIR="${ROFI_CACHE_DIR:-$HOME/.cache}"

keypassxc_cache="$ROFI_CACHE_DIR/rofi-keepassxc/"

if ! command -v keypassxc-cli &> /dev/null; then
	$ROFI -e "Install keypassxc-cli to enable the keypassxc menu"
	exit 1
fi

m() { $ROFI -dmenu -i "$@" ;}

if [ -n "$WAYLAND_DISPLAY" ]; then
    clip_cmd="wl-copy"
elif [ -n "$DISPLAY" ]; then
    clip_cmd="xclip -sel clip -r"
else
    echo "Error: No Wayland or X11 display detected" >&2
    exit 1
fi

clip_username() {
  echo "$dbpass" | keepassxc-cli show "$db" "$entry" | grep 'UserName:' | \
    cut -b 11- | $clip_cmd
}
clip_password() { echo "$dbpass" | keepassxc-cli clip "$db" "$entry" "$timeout" ;}
clip_title() { echo "$element" | cut -b 8- | $clip_cmd ;}
clip_url() { echo "$element" | cut -b 6- | $clip_cmd ;}
clip_notes() { echo "$element" | cut -b 8- | $clip_cmd ;}

generate_password() {
  char_num=$(m -p "Number of password characters" -l 0)
  [ ! "$char_num" ] && exit

  numbers=$(printf "Yes\nNo" | m -p "Use numbers?" -l 2)

  case "$numbers" in
    Yes) numbers="-n";;
    No) numbers="";;
    *) exit;;
  esac

  special=$(printf "Yes\nNo" | m -p "Use special characters?" -l 2)

  case "$special" in
    Yes) special=" -s";;
    No) special="";;
    *) exit;;
  esac

  ext_ascii=$(printf "Yes\nNo" | m -p "Use extended ASCII?" -l 2)

  case "$ext_ascii" in
    Yes) ext_ascii=" -e";;
    No) ext_ascii="";;
    *) exit;;
  esac
}

clip_element() {
  if echo "$element" | grep -q 'Title: '; then
    clip_title
  elif echo "$element" | grep -q 'UserName: '; then
    clip_username
  elif echo "$element" | grep -q 'Password: '; then
    clip_password
  elif echo "$element" | grep -q 'URL: '; then
    clip_url
  elif echo "$element" | grep -q 'Notes: '; then
    clip_notes
  fi
}

edit_element() {
  if echo "$element" | grep 'Title: '
  then
    new_title=$(m -p "Enter new entry title" -l 0)
    echo "$dbpass" | keepassxc-cli edit -t "$new_title" "$db" "$entry"
  elif echo "$element" | grep 'UserName: '
  then
    new_username=$(m -p "Enter new entry username" -l 0)
    echo "$dbpass" | keepassxc-cli edit -u "$new_username" "$db" "$entry"
  elif echo "$element" | grep 'Password: '
  then
    action=$(printf "Enter password\nGenerate password" | m -p "Choose action" -l 2 width 350)

    case "$action" in
      "Enter password")
        new_password=$(m -p "Enter new entry password" -l 0 -password)
        printf "%s" "$dbpass\n$new_password" | keepassxc-cli edit -p "$db" "$entry"
        ;;
      "Generate password")
        generate_password
        echo "$dbpass" | keepassxc-cli edit -g -L "$(echo "$char_num $numbers$special$ext_ascii")" \
          --exclude-similar "$db" "$entry"
        ;;
    esac

  elif echo "$element" | grep 'URL: '
  then
    NEW_URL=$(m -p "Enter new entry URL" -l 0)
    echo "$dbpass" | keepassxc-cli edit --url "$NEW_URL" "$db" "$entry"
  elif echo "$element" | grep 'Notes: '
  then
    $ROFI -e "You cannot edit notes for entries now."
  fi
}

show_entry_info() {
  element=$(echo "$dbpass" | keepassxc-cli show "$db" "$entry" | grep -Ev 'Enter|?*/' | m -p "Info" -l 7)

  [ "$element" ] && action=$(printf "Clip\nEdit" | m -p "Choose action" -l 2)

  case "$action" in
    Clip) clip_element ;;
    Edit) edit_element ;;
  esac
}

delete_entry() {
  echo "$dbpass" | keepassxc-cli rm "$db" "$entry"
  $ROFI -e "Deleted \"$entry\" entry"
}

add_entry() {
  if [ "$entry" ]; then
    action=$(printf "Yes\nNo" | m -p "Add \"$entry\" entry?" -l 2)

    case "$action" in
      Yes)
        username=$(m -p "Enter entry username" -l 0)
        [ ! "$username" ] && exit

        action=$(printf "Enter password\nGenerate password" | m -p "Choose action" -l 2)
        [ ! "$action" ] && exit
        ;;
      *) exit 1;;
    esac

  else exit 1; fi

  case "$action" in
    "Enter password")
      password=$(m -p "Enter new entry password" -l 0 -password)
      printf "%s" "$dbpass\n$password" | keepassxc-cli add "$db" "$entry" -u "$username" -p
      ;;
    "Generate password")
      generate_password
      echo "$dbpass" | keepassxc-cli add "$db" "$entry" -u "$username" -g -L \
        "$(echo "$char_num $numbers$special$ext_ascii")"
      $ROFI -e "Successfully added \"$entry\" entry"
      ;;
    *) exit 1
  esac

}

choose_action() {
  [ "$entry" ] && action="$(printf "Clip username\nClip password\nShow info\nDelete" | \
    m -p "Choose action for \"$entry\" entry" -l 4)"

  case "$action" in
    "Clip username") clip_username ;;
    "Clip password") clip_password ;;
    "Show info") show_entry_info ;;
    Delete) delete_entry ;;
  esac
}

print_help() {
  printf "usage: rofi-keepassxc [-h] [-d]

  arguments:
  -h, --help                show this help message and exit
  -d, --database [file]     specify keepass database file path
  -t, --timeout [value]      specify a timout in second for clipped password; default to 15 seconds\n\n"
}

[ ! "$1" ] && { print_help; exit ;}
while [ "$1" ]; do
  case "$1" in
    -h | --help) print_help; exit;;
    -d | --database) db="$2"; shift; shift;;
    -t | --timeout) timeout="$2"; shift; shift;;
    *) echo "[E] Invalid argument."; exit 1;;
  esac
done

[ ! "$timeout" ] && timeout=15

mkdir -p "$keypassxc_cache"

dbpass=$(m -p "Enter your database password" -l 0 -password)
[ ! "$dbpass" ] && exit 1

error_pass='Error while reading the database'
check_pass=$(echo "$dbpass" | keepassxc-cli open "$db" >"$keypassxc_cache/tmp" 2>&1 && grep -oh "$error_pass" "$keypassxc_cache/tmp")
error_db='Failed to open database file'
check_db=$(echo "$dbpass" | keepassxc-cli open "$db" >"$keypassxc_cache/tmp" 2>&1 && grep -oh "$error_db" "$keypassxc_cache/tmp")

if [ "$check_pass" = "$error_pass" ]; then
  $ROFI -e "$error_pass password"
elif [ "$check_db" = "$error_db" ]; then
  $ROFI -e "$error_db"
else
  echo "$dbpass" | keepassxc-cli ls "$db" | grep -Ev 'Enter|?*/' | sort >"$keypassxc_cache/tmp"
  elements_num=$([ "$(wc -l < "$keypassxc_cache/tmp")" -gt 20 ] && echo 20)

  entry=$(m -p "Entry list" -l "$elements_num" < "$keypassxc_cache/tmp")

  if ! grep -q "$entry" "$keypassxc_cache/tmp"; then
    add_entry || exit 1
  else
    choose_action || exit 1
  fi
fi

rm -r "$keypassxc_cache/tmp"

ecit 1
