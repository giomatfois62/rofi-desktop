#!/bin/bash
NAME="rofi-color-picker"
VERSION="0.001"
AUTHOR="windwp"
CONTACT='longtrieu.ls@live.com'
CREATED="2020-06-01"
UPDATED="2020-06-01"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

main(){
  while getopts :vhf:o:p: option; do
    case "${option}" in
      f) LISTFILE="${OPTARG}" ;;
      o) ROFI_OPTIONS="${OPTARG}" ;;
      p) ROFI_PROMPT="${OPTARG}" ;;
      v) printf '%s\n' \
           "$NAME - version: $VERSION" \
           "updated: $UPDATED by $AUTHOR"
         exit ;;
      h|*) printinfo && exit ;;
    esac
  done

  COLORS_FILE="$DIR/../data/colors-name.txt"

  LISTFILE="${LISTFILE:-$COLORS_FILE}"
  ROFI_PROMPT="${ROFI_PROMPT:-""}"
  [[ ! -f "$LISTFILE" ]] \
    && echo "$LISTFILE not found" \
    && exit 1

  (($#>1)) && shift $((--OPTIND))

  ROFI_MAGIC='-dmenu -i -markup-rows'

  output=${1:-icon}

  selected="$(cat "$LISTFILE" \
    | rofi ${ROFI_MAGIC} ${ROFI_OPTIONS} -p Colors "${ROFI_PROMPT}")"

  # Exit if nothing is selected
  [[ -z $selected ]] && exit 1

  # echo "$selected"

  # get first xml tag
  echo -n "$(echo "$selected" \
    | cut -d\' -f2)" \
    | xclip -selection clipboard

}

printinfo(){
  case "$1" in
    m ) printf '%s' "${about}" ;;

    f )
      printf '%s' "${bouthead}"
      printf '%s' "${about}"
      printf '%s' "${boutfoot}"
    ;;

    ''|* )
      printf '%s' "${about}" | awk '
         BEGIN{ind=0}
         $0~/^```/{
           if(ind!="1"){ind="1"}
           else{ind="0"}
           print ""
         }
         $0!~/^```/{
           gsub("[`*]","",$0)
           if(ind=="1"){$0="   " $0}
           print $0
         }
       '
    ;;
  esac
}

bouthead="
${NAME^^} 1 ${CREATED} Linux \"User Manuals\"
=======================================

NAME
----
"

boutfoot="
AUTHOR
------

${AUTHOR} <${CONTACT}>

SEE ALSO
--------

rofi(1), xclip(1)
<https://raw.githubusercontent.com/wstam88/rofi-fontawesome/>,
<http://fontawesome.io>
"

about='
`rofi-color-picker` - Display all FontAwesome icons in a rofi menu

SYNOPSIS
--------

`rofi-color-picker` [`-v`|`-h`] [-f *LISTFILE*] [-p PROMPT] [OUTPUT]

DESCRIPTION
-----------

If `rofi-color-picker` is executed without options
or arguments, a list of all FontAwesome 5 Free
icons is displayed in a rofi menu. The selected icon
will be put into the clipboard.

OPTIONS
-------

`-v`
  Show version and exit.

`-h`
  Show help and exit.

`-f` *LISTFILE*
  File containing objects to display in the menu.

`-p` PROMPT
  PROMPT to display in the menu. Defaults to nothing.

`-o` *ROFI-OPTIONS*
  Additional options to pass to `rofi`. Put the all options
  in one quoted string. Example:
  `fontawesome-menu -o '"'"'-i -columns 6 -width 100 -lines 20 -bw 2 -yoffset -2 -location 1'"'"'`


EXAMPLES
--------

``` text
$ rofi-color-picker \
    -o "-columns 6 -width 100 -location 1 -lines 20 -i" \
    -p "Select icon: " \

```

DEPENDENCIES
------------

rofi
fontawesome
xclip
'


if [ "$1" = "md" ]; then
  printinfo m
  exit
elif [ "$1" = "man" ]; then
  printinfo f
  exit
else
  main "${@}"
fi
