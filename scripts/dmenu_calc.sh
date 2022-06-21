#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_calc.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2022-06-21T20:28:06+0200

# get active window id
window_id=$(xdotool getactivewindow)

# get clipboard
clipboard=$(xsel -n -o -b)

# use bc for calculations
result=$(printf "%s\n" "$@" \
    | bc -l \
    | sed '/\./ s/\.\{0,1\}0\{1,\}$//' \
)

# set result to label
[ -n "$result" ] \
    && label="$* = $result »"

menu=$(printf "%s\n" \
            "clear" \
            "insert at cursor" \
            "copy to clipboard" \
            "clear clipboard" \
            "$clipboard")

select=$(printf "%s\n" "$menu" \
    | dmenu -b -l 5 -bw 1 -w "$window_id" -p "${label-"calc »"}" \
)

case $select in
    "")
        ;;
    clear)
        "$0" &
        ;;
    "insert at cursor")
        printf "%s" "$result" \
            | xdotool type \
                --clearmodifiers \
                --file -
        ;;
    "copy to clipboard")
        printf "%s\n" "$result" \
            | xsel -i -b \
            && notify-send \
                -u low \
                "Clipboard" \
                "Result copied: $result"
        ;;
    "clear clipboard")
        xsel -c -b \
            && notify-send \
                -u low \
                "Clipboard" \
                "cleared..." \
            && "$0" &
        ;;
    [-+/*]*)
        "$0" "$result$select" &
        ;;
    *)
        "$0" "$select" &
        ;;
esac
