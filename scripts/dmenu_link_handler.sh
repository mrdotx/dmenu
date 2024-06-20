#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_link_handler.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2024-06-19T18:44:53+0200

# i3 helper
. dmenu_helper.sh

title="link-handler"

# helper functions
download() {
    host=$(printf "%s" "$select" | awk -F "on " '{print $2}')

    case "$host" in
        '')
            $TERMINAL -e terminal_wrapper.sh eval "$*" &
            ;;
        *)
            ssh -q "$host" "$* >/dev/null 2>&1 &"
            ;;
    esac
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
    "download" \
    "play video" \
    "play audio" \
    "add video to taskspooler" \
    "add audio to taskspooler" \
        | dmenu -l 15 -c -bw 1 -i -p "$title »" \
)

[ -z "$select" ] \
    && dmenu_notify 1 "$title" \
    && exit 0

[ "$select" = "download" ] \
    && select=$(printf "%s\n" \
        "select format" \
        "video (best)" \
        "video (ext)" \
        "audio" \
        "file" \
        "video (best) on m625q" \
        "video (ext) on m625q" \
        "audio on m625q" \
        "file on m625q" \
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
    "select format")
        $TERMINAL -e terminal_wrapper.sh \
            yt-dlp \
                --format - "$urls" &
        ;;
    "video (best)"*)
        download "yt-dlp \
            \"$urls\""
        ;;
    "video (ext)"*)
        download "yt-dlp \
            --format-sort \"ext\" \"$urls\""
        ;;
    "audio"*)
        download "yt-dlp \
            --extract-audio --audio-format mp3 --audio-quality 0 \
            --embed-thumbnail --embed-metadata \"$urls\""
        ;;
    "file"*)
        download "aria2c.sh \"$urls\""
        ;;
esac
