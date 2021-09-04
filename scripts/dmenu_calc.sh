#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_calc.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2021-09-04T17:19:09+0200

# get active window id
window_id=$(xprop -root \
    | awk '/_NET_ACTIVE_WINDOW\(WINDOW\)/{print $NF}' \
)

# use bc for calculations
result=$(printf "%s\n" "$@" \
    | bc -l \
    | sed '/\./ s/\.\{0,1\}0\{1,\}$//' \
)

# set result to label
[ -n "$result" ] \
    && label="$* = $result »"

select=$(printf "%s\n" \
            "clear" \
            "copy to clipboard" \
    | dmenu -b -l 3 -w "$window_id" -p "${label-"calc »"}" \
)

case $select in
    "")
        ;;
    clear)
        "$0" &
        ;;
    "copy to clipboard")
        printf "%s\n" "$result" \
            | xsel -i -b \
            && notify-send \
                "Clipboard" \
                "Result copied: $result"
        ;;
    [1-9]*)
        "$0" "$select" &
        ;;
    *)
        "$0" "$result$select" &
        ;;
esac
