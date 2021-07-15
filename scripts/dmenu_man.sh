#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_man.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2021-07-15T12:42:44+0200

select=$(apropos -l '' \
    | sort \
    | dmenu -b -l 15 -r -i -p "man »" \
    | cut -d ' ' -f1,2 \
    | tr -d ' ')

[ -n "$select" ] \
    && $TERMINAL -T "man floating" -e man "$select" &
