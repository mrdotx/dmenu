#!/bin/sh

# path:       /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_windows.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/dmenu
# date:       2020-05-24T09:39:17+0200

desk=$(mktemp "/tmp/dmenu_windows.XXXXXX")
win=$(mktemp "/tmp/dmenu_windows.XXXXXX")

wmctrl -d > "$desk"
wmctrl -l > "$win"

idx=$(awk 'FNR==NR{a[$1]=$9 ;next}{ print "\["a[$2]"\] - ", $0 }' "$desk" "$win" 2>/dev/null \
    | cut -d " " -f1-2,8- \
    | nl -w 3 -n rn \
    | sed -r 's/^([ 0-9]+)[ \t]*(.*)$/\1 - \2/' \
    | dmenu -l 10 -c -bw 2 -r -i -p "window:" \
    | cut -d '-' -f-1 \
)

[ -z "$idx" ] \
    && rm -f "$desk" "$win" \
    && exit

wmctrl -l \
    | sed -n "$idx p" \
    | cut -c -10 \
    | xargs wmctrl -i -a

rm -f "$desk" "$win"
