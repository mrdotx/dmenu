#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_link_handler.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2024-03-23T08:05:55+0100

# i3 helper
. dmenu_helper.sh

title="link-handler"

# helper functions
download() {
    host=$(printf "%s" "$2" | awk -F "$1" '{print $2}')
    shift 2

    [ -z "$host" ] \
        && $TERMINAL -e terminal_wrapper.sh eval "$*" &

    [ -n "$host" ] \
        && ssh -q "$host" "$* >/dev/null 2>&1 &"
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
    "download audio/video file" \
    "download file" \
    "download file on m625q" \
    "record video stream" \
    "record video stream on m625q" \
    "record audio stream" \
    "record audio stream on m625q" \
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
    "download audio/video file")
        $TERMINAL -e terminal_wrapper.sh \
            yt-dlp --continue --ignore-errors --no-overwrites \
                --format - "$urls" &
        ;;
    "download file"*)
        download "on " "$select" "aria2c.sh \"$urls\""
        ;;
    "record video stream"*)
        download "on " "$select" "yt-dlp \
            --continue --ignore-errors --no-overwrites \
            --embed-thumbnail --embed-metadata \"$urls\""
        ;;
    "record audio stream"*)
        download "on " "$select" "yt-dlp \
            --continue --ignore-errors --no-overwrites \
            --extract-audio --audio-format mp3 --audio-quality 0 \
            --embed-thumbnail --embed-metadata \"$urls\""
        ;;
esac
