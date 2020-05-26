#!/bin/sh

# path:       /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_bookmarks.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/dmenu
# date:       2020-05-25T23:56:05+0200

script=$(basename "$0")
help="$script [-h/--help] -- script to open bookmarks with dmenu/rofi
  Usage:
    depending on how the script is named,
    it will be executed either with dmenu or with rofi

  Examples:
    dmenu_bookmarks.sh
    rofi_bookmarks.sh"

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    printf "%s\n" "$help"
    exit 0
fi

case $script in
    dmenu_*)
        label="bookmark:"
        menu="dmenu -l 20 -c -bw 2 -i"
        ;;
    rofi_*)
        label=""
        menu="rofi -m -1 -l 15 -columns 3 -theme klassiker-center -dmenu -i"
        ;;
    *)
        printf "%s\n" "$help"
        exit 1
        ;;
esac

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
    | $menu -p "$label" \
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
