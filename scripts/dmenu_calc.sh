#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_calc.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2025-05-28T05:04:57+0200

# source dmenu helper
. _dmenu_helper.sh

title="calc"

# get active window id
window_id=$(xdotool getactivewindow)

# get clipboard
clipboard=$(xsel -n -o -b)

# use bc for calculations
result=$(printf "%s\n" "$@" \
    | sed 's/,/./g' \
    | bc -l
)

# format result and label
[ -n "$result" ] \
    && result=$(printf "%.4f\n" "$result" \
        | sed 's/\./,/g' \
    ) \
    && label="$result ="

menu() {
    [ -n "$*" ] \
        && printf "%s\n" \
            "$*" \
            "clear calculation" \
            "insert result at cursor" \
            "copy result to clipboard"
    printf "%s\n" \
        "» electricity costs: price * (hours * days * months / 1000 * W)kWh" \
        "» charging costs: price * efficiency * (V / 1000000 * mAh)kWh" \
        "clear clipboard" \
        "$clipboard"
}

select=$(printf "%s\n" "$(menu "$*")" \
    | dmenu -b -l 7 -p "${label-"$title »"}" -w "$window_id" \
)

case $select in
    "")
        ;;
    "clear calculation")
        "$0" &
        ;;
    "insert result at cursor")
        printf "%s" "$result" \
            | xdotool type \
                --clearmodifiers \
                --file -
        ;;
    "copy result to clipboard")
        printf "%s\n" "$result" \
            | xsel -i -b \
            && dmenu_notify 2500 \
                "$title" \
                "$result copied to clipboard"
        ;;
    "clear clipboard")
        xsel -c -b \
            && dmenu_notify 2500 \
                "$title" \
                "Clipboard cleared..." \
            && "$0" &
        ;;
    "» electricity costs: price * (hours * days * months / 1000 * W)kWh")
        "$0" "0,40*(24*7*52/1000*1)" &
        ;;
    "» charging costs: price * efficiency * (V / 1000000 * mAh)kWh")
        "$0" "0,40*1,30*(3,85/1000000*5100)" &
        ;;
    [-+/*]*)
        "$0" "$result$select" &
        ;;
    *)
        "$0" "$select" &
        ;;
esac
