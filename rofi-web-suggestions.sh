#!/bin/bash

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit ; pwd -P )"

refreshrate=2 # refresh suggestions every n characters hit 

logfile="$HOME/.cache/suggestions.tmp"

[ ! -f "$logfile" ] && echo "run the wrapper script instead" && exit 1

API=$(cat "$logfile")
rm "$logfile"

get_suggestions="$SCRIPT_PATH/suggestions/$API"
allowExcess=true

suggestions=""
default_custom_format="{{name_enum}}:{{value}}"
custom_format="${format:-$default_custom_format}"

convertJson(){
    echo "$1" | sed -e 's/\\/\\\\/g' -e 's/\"/\\"/g' -e 's/.*/"&"/' | paste -sd "," -
}

removeIllegal(){
    ##### https://github.com/fogine/rofi-blocks/commit/9f45da637baf0f0d342c2e2957535564aa622164
    ##### if you care about special characters, the patch above
    ##### fixes the issue in which they break rofi
    ##### once installed you can omit this function
    echo "$1" | tr -dc '[:alnum:][:space:]-\n\r'
}

fill_menu(){

    JSON_LINES="$(convertJson "$suggestions")"

    TEXT=$(cat <<EOF | tr -d "\n" | tr -d "\t"
{
    "event format":"${custom_format}",
    "lines":[
    ${JSON_LINES}
    ]
}
EOF
)
    printf '%s\n' "$TEXT"
}

echo '{"input action":"send"}'

unset length i
while IFS= read -r line; do
    ((i++))

    [[ "$line" = 'SELECT'* ]] && selected=$(echo "$line" | cut -d':' -f2-) && break;

    print=$(echo "$line" | cut -d':' -f2-)

    #custom algorithm to reduce Api calls
    [[ "${#print}" < $length ]] && length="${#print}" && continue;

    length="${#print}"

    if (( i%refreshrate == 0 )) || [ ! -z $allowExcess ]; then suggestions="$(removeIllegal "$(bash $get_suggestions $print)")"

	    [[ "${line:0:1}" != '{' ]] && suggestions="${print}"$'\n'"$suggestions"

	    fill_menu "$print"
    fi
done

selected="$(tr '[:lower:]' '[:upper:]' <<< ${selected:0:1})${selected:1}"

[ -z "$selected" ] && rm $logfile || printf "$selected" >"$logfile"

exit 0
