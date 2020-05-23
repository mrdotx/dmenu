#!/bin/sh

# path:       /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_bookmarks.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/dmenu
# date:       2020-05-23T19:58:50+0200

# bookmark files (format: {title; url} per row)
bms=$(grep -v "$HOME/.local/share/repos/dmenu/scripts/data/bookmarks" -e "^#" -e "^\s*$")
bws=$(awk '{print $0" [/b]; "$0}' "$HOME/.config/qutebrowser/bookmarks/urls")
if [ -n "$bws" ]; then
    bms=$(printf "%s\n%s" "$bms" "$bws")
fi

# select bookmark or enter a url manually
ti=$(printf "%s\n" "$bms" \
    | awk -F '; ' '{print $1}' \
)
sel=$(printf "%s" "$ti" \
    | dmenu -l 20 -c -bw 2 -i -p "bookmark:" \
)
[ -z "${sel##*[/*]*}" ] \
    && open=$(printf "%s" "$bms" \
        | grep -F "$sel" \
        | awk -F '; ' '{print $2}') \
    || open="$sel"

# open bookmark
case "$open" in
    *com/channel* | *com/user*)
        link_handler.sh "$(link_parser.py "$open" \
            | grep watch \
            | sed "q1" \
            )"
        ;;
    *)
        link_handler.sh "$open"
        ;;
esac
