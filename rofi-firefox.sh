#!/bin/bash
#
# https://github.com/lamarios/dotfiles/blob/master/scripts/rofi-firefox
#
# this script displays firefox bookmarks
#
# dependencies: rofi, firefox, sqlite

ROFI_CMD="${ROFI_CMD:-rofi -dmenu -i}"

# TODO: fix this query to return all bookmarks
SQL="SELECT b.title || \" | \" ||  p.url  FROM moz_bookmarks b JOIN moz_places p ON b.fk = p.id WHERE b.fk is not null AND b.title <> '' AND url <> '' AND url NOT LIKE 'place:%'"

# https://askubuntu.com/questions/239543/get-the-default-firefox-profile-directory-from-bash
FIREFOX_PROFILE=$(grep "Default=.*\.default-release*" "$HOME/.mozilla/firefox/profiles.ini" | cut -d"=" -f2)

if [ -z "${FIREFOX_PROFILE+x}" ]; then
	echo "FIREFOX_PROFILE not set"
	exit 1
fi

PROFILE_DB=~/.mozilla/firefox/${FIREFOX_PROFILE}/places.sqlite
TMP_PLACES=$HOME/.cache/firefox-places

#avoiding db lock
cp -f ${PROFILE_DB} ${TMP_PLACES}
ENTRIES=$(sqlite3 ${TMP_PLACES} "${SQL}" | $ROFI_CMD -p "Firefox")

IFS=' | ' 
read -ra ADDR <<< "$ENTRIES"
for i in "${ADDR[@]}"; do
  URL=$i
done

if [[ $URL == http* ]]; then
	echo "URL: '$URL'"
else
	WORDS=$(echo ${ENTRIES} | wc -w)

	# we exit at empty string
	if [ $WORDS -eq 0 ]; then
		 rm ${TMP_PLACES}
		 exit 1
	 fi

	echo "${URL} is not url, using google search instead"
	URL="https://www.google.com/search?client=firefox-b-d&q=${ENTRIES}"
fi

DEV_EDITION=$(ps aux | grep '[f]irefox-developer-edition' | wc -l)
if [ ${DEV_EDITION} -eq 0 ]; then
	firefox "$URL"
else
	firefox-developer-edition "$URL"
fi

rm ${TMP_PLACES}
