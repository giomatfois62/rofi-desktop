#!/bin/bash

# https://github.com/luiscrjunior/rofi-json

ROFI_CACHE_DIR="${ROFI_CACHE_DIR:-$HOME/.cache}"
CACHE="$ROFI_CACHE_DIR/rofi-json"

user_file="$(eval echo ${1})"

if [[ "$user_file" = /* ]]
then
  config_file="$user_file"
else
  cwd=$(dirname $0)
  config_file="${cwd}/${user_file}"
fi

json=$(cat "$config_file")

rm "$CACHE"
touch "$CACHE"

if [ $# -eq 1 ]; then
  echo "$json" | jq -cr '.[] | "\(.name)|\(.command)|\(.icon)"' |
  while IFS="|" read -r name command icon
  do
    if [[ $name == "null" ]]; then
      continue
    fi        
    if [[ $icon == "null" ]]; then
      icon="system-run"
    fi      
    echo -en "${name}\0icon\x1f${icon}\n"
  done
fi

if [ $# -eq 2 ]; then
  selected=$2
  task=$(echo $json | jq ".[] | select(.name == \"$selected\")")

  if [[ $task == "" ]]; then
    exit 1
  fi

  command=$(echo $task | jq -j ".command")

  if [[ $command == "null" ]]; then
    command=$(echo $task | jq -j ".name")
  fi

  echo "$2" > "$CACHE"

  coproc bash -c "$command"
  exit 0
fi

exit 1
