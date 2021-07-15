#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_windows.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2021-07-15T12:45:04+0200

desktops=$(mktemp -t dmenu_windows.XXXXXX)
windows=$(mktemp -t dmenu_windows.XXXXXX)

wmctrl -d > "$desktops"
wmctrl -l > "$windows"

select=$(awk 'FNR==NR{a[$1]=$2" ["$9 ;next}{ print a[$2]"] » ", $0 }' "$desktops" "$windows" \
    | cut -d " " -f1-2,9- \
    | nl -w 2 -n rz \
    | sed -r 's/^([ 0-9]+)[\t]*(.*)$/\1 \2/' \
    | dmenu -l 15 -c -bw 2 -r -i -p "window »" \
    | cut -d '-' -f-1 \
)

if [ -n "$select" ]; then
    wmctrl -i -a "$( \
        sed -n "$select p" "$windows" \
        | cut -c -10 \
    )"
    rm -f "$desktops" "$windows"
else
    rm -f "$desktops" "$windows"
fi
