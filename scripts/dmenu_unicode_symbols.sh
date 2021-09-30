#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_unicode_symbols.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2021-09-30T18:45:00+0200

# get active window id
window_id=$(xdotool getactivewindow)

select=$(< "$HOME/.local/share/repos/dmenu/scripts/data/unicode-symbols" \
    dmenu -b -l 15 -r -i -w "$window_id" -p "symbol »" \
)

[ -z "$select" ] \
    && exit 0

symbol=$(printf "%s\n" "$select" \
    | sed 's/ .*//' \
)

# type at cursor in active window
xdotool type --window "$window_id" "$symbol"
# copy symbol to clipboard
printf "%s" "$symbol" \
    | xsel -i -b

notify-send \
    "copied $symbol to clipboard" \
    "$select"
