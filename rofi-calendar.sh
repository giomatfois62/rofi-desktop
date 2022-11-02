#! /usr/bin/env bash

###### Variables ######
DATEFTM="${DATEFTM:-+%a %d %b %Y}"
SHORTFMT="${SHORTFMT:-+%d/%m/%Y}"
LABEL="${LABEL:- }"
FONT="${FONT:-Monospace 10}"
LEFTCLICK_PREV_MONTH=${LEFTCLICK_PREV_MONTH:-false}
PREV_MONTH_TEXT="${PREV_MONTH_TEXT:-« previous month «}"
NEXT_MONTH_TEXT="${NEXT_MONTH_TEXT:-» next month »}"
ROFI_CONFIG_FILE="${ROFI_CONFIG_FILE:-/dev/null}"
BAR_POSITION="${BAR_POSITION:-bottom}"
WEEK_START="${WEEK_START:-monday}"

# get current date and set today header
get_current_date() {
  year=$(date '+%Y')
  month=$(date '+%m')
  #day=$(date '+%d')
}

# print the selected month
print_month() {
  mnt=$1
  yr=$2
  cal --color=always --$WEEK_START $mnt $yr \
    | sed -e 's/\x1b\[[7;]*m/\<b\>\<u\>/g' \
          -e 's/\x1b\[[27;]*m/\<\/u\>\<\/b\>/g' \
          -e '/^ *$/d' \
    | tail -n +2
  echo "$PREV_MONTH_TEXT"$'\n'"$NEXT_MONTH_TEXT"
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

###### Main body ######
get_current_date

# rofi pop up
IFS=
month_page=$(print_month $month $year)
header=$(date "$DATEFTM")

#lines:'"$(echo "$month_page" | wc -l)"';width:22;

while selected="$(echo "$month_page" \
| rofi \
	-dmenu \
	-markup-rows \
	-theme-str 'entry{enabled:false;}inputbar{children:[prompt];}listview{ columns:7;}' \
	-hide-scrollbar \
	-p "$header")"; do
  if [ $(echo "$selected" | grep "next") ]; then
    increment_month 1
    month_page=$(print_month $month $year)
  elif [ $(echo "$selected" | grep "previous") ]; then
    increment_month -1
    month_page=$(print_month $month $year)
  fi
done
