#!/bin/sh

# path:       /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_calc.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/dmenu
# date:       2020-05-19T19:04:12+0200

# use bc for calculations
menu="dmenu -l 3"
result=$(printf "%s\n" "$@" | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//')
chosen=$(printf "Copy to clipboard\nClear\nClose" | $menu -p "= $result")
case $chosen in
    Copy?to?clipboard)
        printf "%s\n" "$result" | xsel -b \
            && notify-send "Clipboard" "Result copied: $result"
        ;;
    Clear)
        $0
        ;;
    Close)
        ;;
    "")
        ;;
    *) $0 "$result $chosen" ;;
esac
