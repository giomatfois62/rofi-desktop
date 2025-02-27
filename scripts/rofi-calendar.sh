#! /usr/bin/env bash
#
# a simple calendar and agenda inside a rofi menu
# allows adding and displaying events and reminders stored locally in $events_file
#
# dependencies: rofi

###### Variables ######
SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

ROFI="${ROFI:-rofi}"
ROFI_DATA_DIR="${ROFI_DATA_DIR:-$SCRIPT_PATH/data}"
DATEFTM="${DATEFTM:-+%a %d %b %Y}"
TIMEFMT="${TIMEFMT:-+%H:%M}"
SHORTFMT="${SHORTFMT:-+%d/%m/%Y}"
EVENTFMT="${EVENTFMT:-+%Y.%m.%d}"
DATELABEL="${DATELABEL:- }"
DATEFONT="${DATEFONT:-Monospace 10}"
LEFTCLICK_PREV_MONTH=${LEFTCLICK_PREV_MONTH:-false}
PREV_MONTH_TEXT="${PREV_MONTH_TEXT:-« previous month «}"
NEXT_MONTH_TEXT="${NEXT_MONTH_TEXT:-» next month »}"
CREATE_EVENT_TEXT="${CREATE_EVENT_TEXT:-! add reminder !}"
ROFI_CONFIG_FILE="${ROFI_CONFIG_FILE:-/dev/null}"
BAR_POSITION="${BAR_POSITION:-bottom}"
WEEK_START="${WEEK_START:-monday}"

events_file="$ROFI_DATA_DIR/events"

rofi_theme="entry{enabled:false;}\
inputbar{children:[prompt];}\
listview{ columns:7;}"

# get current date and set today rofi_prompt
get_current_date() {
  year=$(date '+%Y')
  month=$(date '+%m')
  day=$(date '+%d')
}

# print the selected month
print_month() {
  mnt=$1
  yr=$2

  echo "$PREV_MONTH_TEXT"$'\n'"$NEXT_MONTH_TEXT"$'\n'"$CREATE_EVENT_TEXT"
  echo ""

  # in slackware, closing escape sequence is \e[0m, in fedora is \e[27m
  cal --color=always --$WEEK_START $mnt $yr \
    | sed -e 's/\x1b\[[7;]*m/\<b\>\<u\>/g' \
          -e 's/\x1b\[[27;]*m/\<\/u\>\<\/b\>/g' \
          -e 's/\x1b\[[0;]*m/\<\/u\>\<\/b\>/g' \
          -e '/^ *$/d' \
    | tail -n +2

  echo ""
  echo $(show_events)
}

# increment year and/or month appropriately based on month increment
increment_month() {
  # pick increment and define/update delta
  incr=$1
  (( delta += incr ))
  # for non-current month
  if (( incr != 0 )); then
    # add the increment
    month=$(( 10#$month + incr ))
    # normalize month and compute year
    if (( month > 0 )); then
      (( month -= 1 ))
      (( year += month/12 ))
      (( month %= 12 ))
      (( month += 1 ))
    else
      (( year += month/12 - 1 ))
      (( month %= 12 ))
      (( month += 12 ))
    fi
  fi
  # adjust rofi_prompt
  if (( delta == 0 )); then
    # today's month => show dd/mm/yyyy
    rofi_prompt=$(date "$DATEFTM")
  else
    # not today's month => show mm/yyyy
    rofi_prompt=$(cal $month $year | sed -n '1s/^ *\(.*[^ ]\) *$/\1/p')
  fi
}

create_event() {
  suggested_date="$year.$month.$day "
  event_text=$($ROFI -dmenu -p "New Reminder" -filter "$suggested_date")
  if [ ${#event_text} ]; then
    echo "$event_text" >> "$events_file"
  fi
}

format_event() {
  event_date="$(echo "$@" | cut -d " " -f1)"
  event_date=${event_date//./-}
  event_date=$(date -d"$event_date" +"%a %d")
  event_text="$(echo "$@" | cut -d " " -f2-)"
  echo "$event_date: $event_text"
}

export -f format_event

show_events() {
  grep "^$year.$month" "$events_file" | sort -n | xargs -I {} bash -c "format_event {}"
}

delete_event() {
  event_date=$(echo "$@" | cut -d ":" -f1)
  event_date=${event_date//:/}
  event_day=$(echo "$event_date" | cut -d " " -f2-)
  event_text="$(echo "$@" | cut -d ":" -f2- | cut -d " " -f2-)"

  line_to_delete="$year.$month.$event_day $event_text"
  echo "$line_to_delete"

  sed -i "/$line_to_delete/d" "$events_file"
}

###### Main body ######
get_current_date

# rofi pop up
IFS=
month_page=$(print_month $month $year)
rofi_prompt=$(date "$DATEFTM")", "$(date "$TIMEFMT")

while selected="$(echo "$month_page" |\
	$ROFI -dmenu -i -markup-rows -hide-scrollbar -theme-str "$rofi_theme" -p "$rofi_prompt")"; do
  if [ $(echo "$selected" | grep "$NEXT_MONTH_TEXT") ]; then
    increment_month 1
    month_page=$(print_month $month $year)
  elif [ $(echo "$selected" | grep "$PREV_MONTH_TEXT") ]; then
    increment_month -1
    month_page=$(print_month $month $year)
  elif [ $(echo "$selected" | grep "$CREATE_EVENT_TEXT") ]; then
    create_event
    month_page=$(print_month $month $year)
  else
    delete_event "$selected"
    month_page=$(print_month $month $year)
  fi
done
