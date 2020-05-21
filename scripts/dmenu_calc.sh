#!/bin/sh

# path:       /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_calc.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/dmenu
# date:       2020-05-21T10:25:15+0200

# get active window id
win_id=$(xprop -root | awk '/_NET_ACTIVE_WINDOW\(WINDOW\)/{print $NF}')

# use bc for calculations
menu="dmenu -b -l 3 -w $win_id"
res=$(printf "%s\n" "$@" | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//')
sel=$(printf "Copy to clipboard\nClear\nClose" | $menu -p "= $res")
case $sel in
    Copy?to?clipboard)
        printf "%s\n" "$res" | xsel -b \
            && notify-send "Clipboard" "Result copied: $res"
        ;;
    Clear)
        $0
        ;;
    Close)
        ;;
    "")
        ;;
    *) $0 "$res $sel" ;;
esac
