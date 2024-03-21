#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_link_handler.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2024-03-20T19:55:45+0100

# i3 helper
. dmenu_helper.sh

title="link-handler"

# helper functions
download() {
    host=$(printf "%s" "$2" | awk -F "$1" '{print $2}')
    shift 2

    [ -z "$host" ] \
        && $TERMINAL -e terminal_wrapper.sh eval "$@" &

    [ -n "$host" ] \
        && dmenu_notify 2500 "$title" "$urls\ndownload on host: $host" \
        && ssh -t "$host" "$@" &
}

case "$1" in
    --clipboard)
        [ "$(command -v "xsel")" ] \
            && urls="$(xsel -n -o -b)"
        ;;
    *)
        urls="$*"
        ;;
esac

[ -z "$urls" ] \
    && exit 0

dmenu_notify 0 "$title" "$urls"
select=$(printf "%s\n" \
    "play video" \
    "play audio" \
    "add video to taskspooler" \
    "add audio to taskspooler" \
    "select download format" \
    "download video" \
    "download audio" \
    "download file" \
    "download video on m625q" \
    "download audio on m625q" \
    "download file on m625q" \
    | dmenu -l 15 -c -bw 1 -i -p "$title »" \
)
dmenu_notify 1 "$title"

[ -z "$select" ] \
    && exit 0

case "$select" in
    "play video")
        mpv --no-terminal \
            ytdl://"$urls" >/dev/null 2>&1 &
        ;;
    "play audio")
        $TERMINAL -e mpv --no-video \
            ytdl://"$urls" &
        ;;
    "add video to taskspooler")
        tsp mpv --no-terminal \
            ytdl://"$urls" >/dev/null 2>&1
        ;;
    "add audio to taskspooler")
        tsp mpv --no-terminal --no-video --force-window \
            ytdl://"$urls" >/dev/null 2>&1
        ;;
    "select download format")
        $TERMINAL -e terminal_wrapper.sh \
            yt-dlp -ciwf - "$urls" &
        ;;
    "download video"*)
        download "on " "$select" "yt-dlp -ciw \"$urls\""
        ;;
    "download audio"*)
        download "on " "$select" "yt-dlp -ciw \
            -x --audio-format mp3 --audio-quality 0 \"$urls\""
        ;;
    "download file"*)
        download "on " "$select" "aria2c.sh \"$urls\""
        ;;
esac
