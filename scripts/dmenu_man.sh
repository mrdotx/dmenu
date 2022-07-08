#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_man.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2022-07-08T19:14:52+0200

select=$(man -k -l '' \
    | sort \
    | dmenu -b -l 15 -bw 1 -r -i -p "man »" \
    | cut -d ' ' -f1,2 \
    | tr -d ' ' \
)

[ -n "$select" ] \
    && $TERMINAL -T "man floating" -e man "$select"
