#!/bin/sh

# path:       /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_unicode_symbols.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/dmenu
# date:       2020-05-18T19:29:12+0200

# symbols file
# chosen=$(< "$HOME/.local/share/repos/dmenu/unicode-symbols" dmenu -l 15 -r -i -p "symbol:")
chosen=$(cut -d ';' -f1 "$HOME/.local/share/repos/dmenu/data/unicode-symbols" | dmenu -l 15 -r -i -p "symbol:")
[ -n "$chosen" ] || exit

# copy symbol to clipboard
clip=$(printf "%s\n" "$chosen" | sed "s/ .*//")
printf "%s\n" "$clip" | tr -d '\n' | xsel -b
# copy code to primary
pri=$(printf "%s\n" "$chosen" | sed "s/.*; //" | awk '{print $1}')
printf "%s\n" "$pri" | tr -d '\n' | xsel

notify-send "clipboard" "Copied to clipboard\t: $clip\nCopied to primary\t: $pri"
