#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_calc.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2023-01-31T13:43:25+0100

# get active window id
window_id=$(xdotool getactivewindow)

# get clipboard
clipboard=$(xsel -n -o -b)

# use bc for calculations
result=$(printf "%s\n" "$@" \
    | bc -l
)

# format result and label
[ -n "$result" ] \
    && result=$(printf "%.4f\n" "$result") \
    && label="$* = $result »"

menu() {
    [ -n "$*" ] \
        && printf "%s\n" \
            "$*" \
            "clear" \
            "insert at cursor" \
            "copy to clipboard"
    printf "%s\n" \
        "power costs" \
        "clear clipboard" \
        "$clipboard"
}

select=$(printf "%s\n" "$(menu "$*")" \
    | dmenu -b -l 6 -bw 1 -w "$window_id" -p "${label-"calc »"}" \
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
    "power costs")
        "$0" "24*7*52/1000*0.40" &
        ;;
    [-+/*]*)
        "$0" "$result$select" &
        ;;
    *)
        "$0" "$select" &
        ;;
esac
