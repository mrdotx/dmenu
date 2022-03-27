#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_calc.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2022-03-27T10:26:19+0200

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

select=$(printf "%s\n%s [%s...]\n%s\n%s\n" \
            "clear" \
            "calculate from clipboard" \
            "$(printf "%s" "$clipboard" | head -c10)" \
            "insert at cursor" \
            "copy to clipboard" \
    | dmenu -b -l 4 -w "$window_id" -p "${label-"calc »"}" \
)

case $select in
    "")
        ;;
    clear)
        "$0" &
        ;;
    "calculate from clipboard"*)
        "$0" "$clipboard" &
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
