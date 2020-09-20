#!/bin/sh

# path:       /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_youtube.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/dmenu
# date:       2020-09-20T21:48:11+0200

clipboard="$(xsel -o -b)"
clipboard_clear="$(xsel -c -b)"
history_file="$HOME/.local/share/repos/dmenu/scripts/data/youtube"

script=$(basename "$0")
help="$script [-h/--help] -- script to search youtube with youtube-dl and play
                                video/audio with mpv or download them
  Usage:
    depending on how the script is named,
    it will be executed either with dmenu or with rofi
    $script [-r] [quantity]

  Settings:
    [-r]       = results to query from youtube
    [quantity] = integer (default 10) or all (takes a long time)

  Examples:
    $script
    $script -r 5
    $script -r all"

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    printf "%s\n" "$help"
    exit 0
fi

case $script in
    dmenu_*)
        # get active window id
        window_id=$(xprop -root \
            | awk '/_NET_ACTIVE_WINDOW\(WINDOW\)/{print $NF}' \
        )
        label="youtube »"
        menu="dmenu -b -l 10 -i -w $window_id"
        label_result="youtube »"
        menu_result="dmenu -b -l 10 -r -i -w $window_id"
        ;;
    rofi_*)
        label=""
        menu="rofi -m -2 -l 10 -theme klassiker-vertical -dmenu -i"
        label_result=""
        menu_result="rofi -m -2 -l 10 -theme klassiker-vertical -dmenu -i"
        ;;
    *)
        printf "%s\n" "$help"
        exit 1
        ;;
esac

if [ -n "$clipboard" ]; then \
    search=$(printf "%s\n== clear clipboard ==\n%s" "$clipboard" "$(tac "$history_file")")
else
    search=$(printf "%s" "$(tac "$history_file")")
fi

search=$(printf "%s" "$search" \
    | $menu -p "$label")

[ -z "$search" ] \
    && exit 1

case "$search" in
    "== clear clipboard ==")
        "$clipboard_clear"
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
        printf "%s\n" "$search" >> "$history_file"
        printf "%s\n" "$(tac "$history_file" \
            | awk '! seen[$0]++' \
            | tac \
        )" > "$history_file"

        if [ "$1" = "-r" ]; then
            search_results=$2
        else
            search_results=10
        fi

        printf "" | $menu -p "please wait..." &
        result=$(youtube-dl "ytsearch$search_results:$search" -e --get-id)
        kill "$(pgrep -f "$menu -p please wait...")"

        select=$(printf "%s" "$result" \
            | sed -n '1~2p' \
            | $menu_result -p "$label_result" \
        )

        [ -z "$select" ] \
            && exit 1

        open=$(printf "%s" "$result" \
            | sed -n "/$select/{n;p}"
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
