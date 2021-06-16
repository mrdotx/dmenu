#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_man.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2021-06-16T17:39:10+0200

# get active window id
window_id=$(xprop -root \
    | awk '/_NET_ACTIVE_WINDOW\(WINDOW\)/{print $NF}' \
)

select=$(apropos -l '' \
    | sort \
    | dmenu -b -l 15 -r -i -w "$window_id" -p "man »" \
    | cut -d ' ' -f1,2 \
    | tr -d ' ')

if [ -n "$select" ]; then
    $TERMINAL -T "man floating" -e man "$select" &
fi
