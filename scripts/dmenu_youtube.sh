#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_youtube.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2024-01-12T16:46:10+0100

history_file="$HOME/.local/share/repos/dmenu/scripts/data/youtube"

case "$1" in
    --clipboard)
        [ "$(command -v "xsel")" ] \
            && search="$(xsel -n -o -b)"
        ;;
    *)
        search=$(printf "%s" "$(cat "$history_file")" \
            | dmenu -l 15 -c -bw 1 -i -p "youtube »" \
        )
        ;;
esac

[ -z "$search" ] \
    && exit 0

case "$search" in
    *'youtube.com/watch'* \
        | *'youtube.com/playlist'* \
        | *'youtu.be'* \
        | https://* \
        | http://*)
            notify-send \
                -u low \
                "yt-dlp - open/search from clipboard" \
                "$search"
            open="$search"
            ;;
    *)
        ! [ -f "$history_file" ] \
            && printf "%s\n" "$search" > "$history_file"

        sed -i "1s/^/$search\n/" "$history_file"
        history="$(awk '! seen[$0]++' "$history_file")"
        printf "%s\n" "$history" > "$history_file"

        search_string=$(printf "%s\n" \
                "relevance 10" \
                "date 10" \
                "relevance all" \
                "date all" \
            | dmenu -l 15 -c -bw 1 -i -p "youtube »" \
        )

        case "$search_string" in
            relevance*)
                search_result="$( \
                    printf "%s" "$search_string" \
                    | sed 's/relevance /ytsearch/g' \
                )"
                ;;
            date*)
                search_result="$( \
                    printf "%s" "$search_string" \
                    | sed 's/date /ytsearchdate/g' \
                )"
                ;;
            "== [relevance/date] [quantity/all] ==")
                exit 0
                ;;
            "")
                exit 0
                ;;
        esac

        notification() {
            notify-send \
                -t "$1" \
                -u low \
                "$2" \
                "search:  $search\nresult:  $search_string\nattempt: $3" \
                -h string:x-canonical-private-synchronous:"$message_id"
        }

        # if yt-dlp returns no results try again 30 times
        max_attempts=30
        attempt=1
        message_id="$(date +%s)"
        while [ $attempt -le $max_attempts ] \
            && [ -z "$result" ]; do
                notification 0 "yt-dlp - please wait..." "$attempt/$max_attempts"
                result=$(yt-dlp "$search_result:$search" -e --get-id)
                attempt=$((attempt + 1))
        done
        notification 1000 "yt-dlp - finished" "$((attempt - 1))/$max_attempts"

        select=$(printf "%s" "$result" \
            | sed -n '1~2p' \
            | dmenu -l 15 -c -bw 1 -r -i -p "youtube »" \
        )

        [ -z "$select" ] \
            && exit 0

        open=$(printf "%s" "$result" \
            | sed -n "/$select/{n;p}"
        )
        ;;
esac

search=$(printf "%s\n" \
    "play video" \
    "play audio" \
    "add video to taskspooler" \
    "add audio to taskspooler" \
    "download video" \
    "download audio" \
    | dmenu -l 15 -c -bw 1 -r -i -p "youtube »" \
)

[ -z "$search" ] \
    && exit 0

case "$search" in
    "play video")
        mpv --no-terminal ytdl://"$open" >/dev/null 2>&1 &
        ;;
    "play audio")
        $TERMINAL -e mpv --no-video ytdl://"$open" &
        ;;
    "add video to taskspooler")
        tsp mpv --no-terminal ytdl://"$open" >/dev/null 2>&1
        ;;
    "add audio to taskspooler")
        tsp mpv --no-terminal --no-video --force-window ytdl://"$open" >/dev/null 2>&1
        ;;
    "download video")
        $TERMINAL -e terminal_wrapper.sh yt-dlp -ciw "$open" &
        ;;
    "download audio")
        $TERMINAL -e terminal_wrapper.sh yt-dlp -ciw -x --audio-format mp3 --audio-quality 0 "$open" &
        ;;
esac
