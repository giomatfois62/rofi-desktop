#! /usr/bin/env bash
#
# a simple calendar and agenda inside a rofi menu
# allows adding and displaying events and reminders stored locally in $EVENTS_FILE
#
# dependencies: rofi

###### Variables ######
DATEFTM="${DATEFTM:-+%a %d %b %Y}"
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
EVENTS_FILE="${EVENTS_FILE:-$HOME/.local/share/calendar_events}"

# get current date and set today header
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

  cal --color=always --$WEEK_START $mnt $yr \
    | sed -e 's/\x1b\[[7;]*m/\<b\>\<u\>/g' \
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
  # adjust header
  if (( delta == 0 )); then
    # today's month => show dd/mm/yyyy
    header=$(date "$DATEFTM")
  else
    # not today's month => show mm/yyyy
    header=$(cal $month $year | sed -n '1s/^ *\(.*[^ ]\) *$/\1/p')
  fi
}

create_event() {
  suggested_date="$year.$month.$day "
  event_text=$((echo) | rofi -dmenu -p "New Reminder" -filter "$suggested_date")
  if [ ${#event_text} ]; then
    echo "$event_text" >> "$EVENTS_FILE"
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
  grep "^$year.$month" "$EVENTS_FILE" | sort -n | xargs -I {} bash -c "format_event {}"
}

delete_event() {
  event_date=$(echo "$@" | cut -d ":" -f1)
  event_date=${event_date//:/}
  event_day=$(echo "$event_date" | cut -d " " -f2-)
  event_text="$(echo "$@" | cut -d ":" -f2- | cut -d " " -f2-)"

  line_to_delete="$year.$month.$event_day $event_text"
  echo "$line_to_delete"

  sed -i "/$line_to_delete/d" "$EVENTS_FILE"
}

###### Main body ######
get_current_date

# rofi pop up
IFS=
month_page=$(print_month $month $year)
header=$(date "$DATEFTM")

#lines:'"$(echo "$month_page" | wc -l)"';width:22;

while selected="$(echo "$month_page" | rofi -dmenu \
	-markup-rows \
	-theme-str 'entry{enabled:false;}inputbar{children:[prompt];}listview{ columns:7;}' \
	-hide-scrollbar \
	-p "$header")"; do
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
