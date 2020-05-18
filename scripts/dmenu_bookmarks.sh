#!/bin/sh

# path:       /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_bookmarks.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/dmenu
# date:       2020-05-18T19:22:52+0200

# bookmark files (format: {title; url} per row)
bookmarks=$(grep -v "$HOME/.local/share/repos/dmenu/data/bookmarks" -e "^#" -e "^\s*$")
browser=$(grep -v "$HOME/.config/qutebrowser/bookmarks/urls" -e "^#" -e "^\s*$" | awk '{print $0" [/b]; "$0}')
if [ -n "$browser" ]; then
    bookmarks="$bookmarks"+"$browser"
fi

# chose bookmark or enter manual a url
title=$(printf "%s\n" "$bookmarks" | awk -F '; ' '{print $1}')
chosen=$(printf "%s" "$title" | dmenu -l 20 -c -bw 2 -i -p "bookmark:")
[ -z "${chosen##*[/*]*}" ] \
    && open=$(printf "%s" "$bookmarks" | grep -F "$chosen" | awk -F '; ' '{print $2}') \
    || open="$chosen"

# open bookmark
case "$open" in
    *com/channel* | *com/user*)
        link_handler.sh "$(link_parser.py "$open" | grep watch | sed "q1")"
        ;;
    *)
        link_handler.sh "$open"
        ;;
esac
