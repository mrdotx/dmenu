#!/bin/sh

# path:       /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_unicode_symbols.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/dmenu
# date:       2020-05-19T20:39:40+0200

# get active window id
win_id=$(xprop -root | awk '/_NET_ACTIVE_WINDOW\(WINDOW\)/{print $NF}')

# symbols file
# chosen=$(< "$HOME/.local/share/repos/dmenu/scripts/data/symbols-unicode" dmenu -l 15 -r -i -p "symbol:" -w "$win_id")
chosen=$(< "$HOME/.local/share/repos/dmenu/scripts/data/symbols" dmenu -b -l 15 -r -i -p "symbol:" -w "$win_id")
[ -n "$chosen" ] || exit

# copy symbol to clipboard
clip=$(printf "%s\n" "$chosen" | sed "s/ .*//")
printf "%s\n" "$clip" | tr -d '\n' | xsel -b
# copy code to primary
pri=$(printf "%s\n" "$chosen" | sed "s/.*; //" | awk '{print $1}')
printf "%s\n" "$pri" | tr -d '\n' | xsel

notify-send "clipboard" "Copied to clipboard\t: $clip\nCopied to primary\t: $pri"
