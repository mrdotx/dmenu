#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_windows.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2025-05-27T05:33:04+0200

desktops=$(mktemp -t dmenu_windows.XXXXXX)
windows=$(mktemp -t dmenu_windows.XXXXXX)

wmctrl -d | tr -s ' ' > "$desktops"
wmctrl -l | tr -s ' ' > "$windows"

# WORKAROUND: sticky windows (-1)
printf "%s\n" "-1 - DG: N/A VP: N/A WA: N/A -" >> "$desktops"

select=$(awk 'FNR==NR{a[$1]=$2" ["$9;next}{print a[$2]"]",$0}' \
    "$desktops" "$windows" \
        | cut -d ' ' -f1,2,6- \
        | nl -w 2 -n rz -s ' ' \
        | dmenu -c -bw 1 -l 15 -r -i -p 'window »' \
        | cut -d ' ' -f1 \
)

[ -n "$select" ] \
    && wmctrl -i -a "$( \
        sed -n "$select p" "$windows" \
            | cut -c -10 \
    )"

rm -f "$desktops" "$windows"
