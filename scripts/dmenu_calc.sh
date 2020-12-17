#!/bin/sh

# path:       /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_calc.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/dmenu
# date:       2020-12-17T22:33:32+0100

# get active window id
win_id=$(xprop -root \
    | awk '/_NET_ACTIVE_WINDOW\(WINDOW\)/{print $NF}' \
)

# use bc for calculations
result=$(printf "%s\n" "$@" \
    | bc -l \
    | sed '/\./ s/\.\{0,1\}0\{1,\}$//' \
)
select=$(printf "%s\n" \
            "clear" \
            "copy to clipboard" \
    | dmenu -b -l 3 -w "$win_id" -p "= $result" \
)
case $select in
    "")
        ;;
    clear)
        "$0"
        ;;
    "copy to clipboard")
        printf "%s\n" "$result" \
            | xsel -i -b \
            && notify-send \
                "Clipboard" \
                "Result copied: $result"
        ;;
    *)
        "$0" "$result $select"
        ;;
esac
