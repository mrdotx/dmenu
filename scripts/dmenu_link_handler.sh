#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_link_handler.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2024-03-14T07:53:03+0100

# i3 helper
. dmenu_helper.sh

title="link-handler"

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
    "download video" \
    "download audio" \
    "download file" \
    | dmenu -l 15 -c -bw 1 -r -i -p "$title »" \
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
    "download video")
        $TERMINAL -e terminal_wrapper.sh \
            yt-dlp -ciw "$urls" &
        ;;
    "download audio")
        $TERMINAL -e terminal_wrapper.sh \
            yt-dlp -ciw -x --audio-format mp3 --audio-quality 0 "$urls" &
        ;;
    "download file")
        $TERMINAL -e terminal_wrapper.sh \
            aria2c.sh "$urls" &
        ;;
esac
