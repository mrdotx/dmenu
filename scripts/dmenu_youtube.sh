#!/bin/sh

# path:       /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_youtube.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/dmenu
# date:       2020-09-15T18:33:52+0200

script=$(basename "$0")
help="$script [-h/--help] -- script to open bookmarks from firefox with dmenu/rofi
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
        label="youtube »"
        menu="dmenu -l 10 -i"
        label_result="youtube »"
        menu_result="dmenu -l 10 -r -i"
        ;;
    rofi_*)
        label=""
        menu="rofi -m -1 -l 10 -theme klassiker-horizontal -dmenu -i"
        label_result=""
        menu_result="rofi -m -1 -l 10 -theme klassiker-center -dmenu -i"
        ;;
    *)
        printf "%s\n" "$help"
        exit 1
        ;;
esac

search_results=10
search=$(printf "== clipboard ==\n== primary ==" | $menu -p "$label")

case $search in
    "== clipboard ==")
        search=$(xsel -o -b | $menu -p "$label")
        ;;
    "== primary ==")
        search=$(xsel -o -p | $menu -p "$label")
        ;;
esac

[ -z "$search" ] \
    && exit 1

result=$(youtube-dl "ytsearch$search_results:$search" --get-id --get-title | \
    sed -E 'N;s|(.*)\n(.*)|\2\;\1|')

select=$(printf "%s\n" "$result" \
    | awk -F ';' '{print $2}' \
    | $menu_result -p "$label_result" \
)

[ -z "$select" ] \
    && exit 1

open=$(printf "%s" "$result" \
    | grep -F "$select" \
    | awk -F ';' '{print $1}' \
)

mpv ytdl://"$open"
