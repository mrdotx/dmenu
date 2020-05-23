#!/bin/sh

# path:       /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_windows.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/dmenu
# date:       2020-05-23T20:56:07+0200

num=$(wmctrl -l \
    | sed 's/  / /' \
    | cut -d " " -f4- \
    | nl -w 3 -n rn \
    | sed -r 's/^([ 0-9]+)[ \t]*(.*)$/\1 - \2/' \
    | dmenu -l 10 -c -bw 2 -i -p "window:" \
    | cut -d '-' -f-1\
)

[ -n "$num" ] || exit

wmctrl -l \
    | sed -n "$num p" \
    | cut -c -10 \
    | xargs wmctrl -i -a
