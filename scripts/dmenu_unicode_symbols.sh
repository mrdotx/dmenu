#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_unicode_symbols.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2022-07-16T09:26:39+0200

# get active window id
window_id=$(xdotool getactivewindow)

select=$(dmenu -b -l 15 -bw 1 -r -i -w "$window_id" -p "symbol »" \
    < "$HOME/.local/share/repos/dmenu/scripts/data/unicode-symbols" \
)

[ -z "$select" ] \
    && exit 0

symbol=$(printf "%s\n" "$select" \
    | sed 's/ .*//' \
    | tr -d '\n' \
)

# type at cursor
xdotool type "$symbol"
# copy symbol to clipboard
printf "%s" "$symbol" \
    | xsel -i -b

notify-send \
    -u low \
    "copied $symbol to clipboard" \
    "$select"
