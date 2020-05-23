#!/bin/sh

# path:       /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_unicode_symbols.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/dmenu
# date:       2020-05-23T19:39:25+0200

# get active window id
win_id=$(xprop -root \
    | awk '/_NET_ACTIVE_WINDOW\(WINDOW\)/{print $NF}' \
)

sel=$(< "$HOME/.local/share/repos/dmenu/scripts/data/symbols-unicode" dmenu -b -l 15 -r -i -p "symbol:" -w "$win_id")

[ -n "$sel" ] || exit

sym=$(printf "%s\n" "$sel" \
    | sed "s/ .*//" \
)
code=$(printf "%s\n" "$sel" \
    | cut -d ';' -f2 \
)

# insert to cursor in active window
xdotool type "$sym"
# copy symbol to clipboard
printf "%s\n" "$sym" \
    | tr -d '\n' \
    | xsel -b
# copy code to primary
printf "%s\n" "$code" \
    | tr -d '\n' \
    | xsel

notify-send "copied to clipboard" "clipboard: $sym\nprimary: $code"
