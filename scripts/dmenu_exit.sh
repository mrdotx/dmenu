#!/bin/sh

# path:       /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_exit.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/dmenu
# date:       2020-05-23T19:30:08+0200

sel=$(printf "%s\n" \
    "lock simple" \
    "suspend simple" \
    "lock blur" \
    "suspend blur" \
    "suspend" \
    "logout" \
    "reboot" \
    "shutdown" \
    | dmenu -m 0 -l 8 -c -bw 2 -r -i -p "exit:" \
)

[ -n "$sel" ] || exit

notify-send "exit" "trying to $sel"

eval "i3_knockout.sh -$sel"
