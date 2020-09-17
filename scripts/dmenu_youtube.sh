#!/bin/sh

# path:       /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_youtube.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/dmenu
# date:       2020-09-17T19:38:00+0200

script=$(basename "$0")
help="$script [-h/--help] -- script to search youtube with youtube-dl and play
                                video/audio with mpv or download them
  Usage:
    depending on how the script is named,
    it will be executed either with dmenu or with rofi
    $script [-r] [quantity]

  Settings:
    [-r]       = results to query from youtube
    [quantity] = integer (default 5)

  Examples:
    $script
    $script -r 10"

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

[ -n "$(xsel -o -b)" ] \
    && search=$(printf "%s\n== clear clipboard ==" "$(xsel -o -b)")

search=$(printf "%s" "$search" \
    | $menu -p "$label")

[ -z "$search" ] \
    && exit 1

case "$search" in
    "== clear clipboard ==")
        xsel -c -b
        "$0"
        exit 0
        ;;
    *'youtube.com/watch'* \
        | *'youtube.com/playlist'* \
        | *'youtu.be'* \
        | https://* \
        | http://*)
            open="$search"
            ;;
    *)
        if [ "$1" = "-r" ]; then
            search_results=$2
        else
            search_results=5
        fi

        result=$(youtube-dl "ytsearch$search_results:$search" -e --get-id | \
            sed -E 'N;s|(.*)\n(.*)|\2\;\1|')

        select=$(printf "%s" "$result" \
            | awk -F ';' '{print $2}' \
            | $menu_result -p "$label_result" \
        )

        [ -z "$select" ] \
            && exit 1

        open=$(printf "%s" "$result" \
            | grep -F "$select" \
            | awk -F ';' '{print $1}' \
        )
        ;;
esac

search=$(printf "1) play video\n2) play audio\n3) add video to taskspooler\n4) add audio to taskspooler\n5) download video\n6) download audio" \
    | $menu_result -p "$label_result")

[ -z "$search" ] \
    && exit 1

case "$search" in
    "1) play video")
        mpv --really-quiet ytdl://"$open" >/dev/null 2>&1 &
        ;;
    "2) play audio")
        $TERMINAL -e mpv --no-video ytdl://"$open" &
        ;;
    "3) add video to taskspooler")
        tsp mpv --really-quiet ytdl://"$open" >/dev/null 2>&1
        ;;
    "4) add audio to taskspooler")
        tsp "$TERMINAL" -e mpv --no-video ytdl://"$open"
        ;;
    "5) download video")
        $TERMINAL -e youtube-dl -ciw "$open" &
        ;;
    "6) download audio")
        $TERMINAL -e youtube-dl -ciw -x --audio-format mp3 --audio-quality 0 "$open" &
        ;;
esac