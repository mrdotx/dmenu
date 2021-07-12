#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_man.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2021-07-12T10:28:25+0200

select=$(apropos -l '' \
    | sort \
    | dmenu -b -l 15 -r -i -p "man »" \
    | cut -d ' ' -f1,2 \
    | tr -d ' ')

if [ -n "$select" ]; then
    $TERMINAL -T "man floating" -e man "$select" &
fi
