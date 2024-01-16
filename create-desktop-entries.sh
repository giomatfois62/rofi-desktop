#!/bin/bash

desktop-entry() {
cat <<EOF
[Desktop Entry]
Name=$1
Comment=
Exec=$2
Icon=applications-accessories
Terminal=false
Type=Application
Categories=Rofi;Desktop;
EOF
}

for f in scripts/*.sh; do
    filename="${f/scripts\//}"
    basename="${filename/.sh/}"
    desktopname="$basename.desktop"

    #echo $filename $basename $desktopname
    desktop-entry "$basename" "$filename" > "applications/$desktopname"
done
