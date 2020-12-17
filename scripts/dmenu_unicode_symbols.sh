#!/bin/sh

# path:       /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_unicode_symbols.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/dmenu
# date:       2020-12-17T22:29:34+0100

# get active window id
window_id=$(xprop -root \
    | awk '/_NET_ACTIVE_WINDOW\(WINDOW\)/{print $NF}' \
)

select=$(< "$HOME/.local/share/repos/dmenu/scripts/data/unicode-symbols" \
    dmenu -b -l 15 -r -i -w "$window_id" -p "symbol »" \
)

[ -z "$select" ] \
    && exit 1

symbol=$(printf "%s\n" "$select" \
    | sed 's/ .*//' \
)

# insert to cursor in active window
xdotool type "$symbol"
# copy symbol to clipboard
printf "%s" "$symbol" \
    | xsel -i -b

notify-send \
    "copied $symbol to clipboard" \
    "$select"
