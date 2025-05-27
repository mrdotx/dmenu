#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_link_handler.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2025-05-27T05:30:00+0200

# source dmenu helper
. _dmenu_helper.sh

title="link-handler"
remote_host="m625q"

# helper functions
clear_ytdl() {
    printf "%s" "$*" \
        | sed 's/ytdl:\/\///g'
}

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
        | dmenu -c -bw 1 -l 15 -i -p "$title »" \
)

[ -z "$select" ] \
    && dmenu_notify 1 "$title" \
    && exit 0

case "$select" in
    "download")
        select=$(printf "%s\n" \
            "select format" \
            "video (best)" \
            "video (ext)" \
            "audio" \
            "file" \
            "video (best) on $remote_host" \
            "video (ext) on $remote_host" \
            "audio on $remote_host" \
            "file on $remote_host" \
                | dmenu -c -bw 1 -l 15 -i -p "$select »" \
        )
        ;;
esac
dmenu_notify 1 "$title"

[ -z "$select" ] \
    && exit 0

case "$select" in
    "play video")
        case "$(printf "%s" "$urls" | tr '[:upper:]' '[:lower:]')" in
            *.m3u | *.m3u8)
                options="--terminal=no --script-opts=menu_playlist=1"
                ;;
            *)
                options="--terminal=no"
                ;;
        esac
        eval "mpv $options \"$urls\" >/dev/null 2>&1 &"
        ;;
    "play audio")
        $TERMINAL -e mpv --vid=no "$urls" &
        ;;
    "add video to taskspooler")
        tsp mpv --terminal=no "$urls" >/dev/null 2>&1
        ;;
    "add audio to taskspooler")
        tsp mpv --terminal=no --vid=no --force-window "$urls" >/dev/null 2>&1
        ;;
    "select format")
        $TERMINAL -e terminal_wrapper.sh \
            yt-dlp --format - "$(clear_ytdl "$urls")" &
        ;;
    "video (best)"*)
        download "yt-dlp \"$(clear_ytdl "$urls")\""
        ;;
    "video (ext)"*)
        download "yt-dlp --format-sort \"ext\" \"$(clear_ytdl "$urls")\""
        ;;
    "audio"*)
        download "yt-dlp \
            --extract-audio --audio-format mp3 --audio-quality 0 \
            --embed-thumbnail --embed-metadata \"$(clear_ytdl "$urls")\""
        ;;
    "file"*)
        download "aria2c.sh \"$urls\""
        ;;
esac
