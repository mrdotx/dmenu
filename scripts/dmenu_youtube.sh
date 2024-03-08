#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_youtube.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2024-03-08T18:00:48+0100

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

# notifications
message_id="$(date +%s)"
notification() {
    notify-send \
        -t "$1" \
        -u low \
        "$title" \
        "$message" \
        -h string:x-canonical-private-synchronous:"$message_id"
}

case "$search" in
    *'youtube.com/watch'* \
        | *'youtube.com/playlist'* \
        | *'youtu.be'* \
        | https://* \
        | http://*)
            title="yt-dlp - open/search from clipboard"
            message="$search"
            notification 0
            open="$search"
            ;;
    *)
        ! [ -f "$history_file" ] \
            && printf "%s\n" "$search" > "$history_file"

        sed -i "1s/^/$search\n/" "$history_file"
        history="$(awk '! seen[$0]++' "$history_file")"
        printf "%s\n" "$history" > "$history_file"

        search_string=$(printf "%s\n" \
                "relevance 5" \
                "date 5" \
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
            *)
                exit 0
                ;;
        esac

        # if yt-dlp returns no results try again 30 times
        max_attempts=30
        attempt=1
        message_body="search:  $search\nresult:  $search_string\nattempt:"
        while [ $attempt -le $max_attempts ] \
            && [ -z "$result" ]; do
                title="yt-dlp - please wait..."
                message="$message_body $attempt/$max_attempts"
                notification 0
                result=$(yt-dlp "$search_result:$search" -e --get-id)
                attempt=$((attempt + 1))
        done
        title="yt-dlp - finished"
        message="$message_body $((attempt - 1))/$max_attempts"
        notification 0

        select=$(printf "%s" "$result" \
            | sed -n '1~2p' \
            | dmenu -l 15 -c -bw 1 -r -i -p "youtube »" \
        )

        [ -z "$select" ] \
            && notification 1 \
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

notification 1

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
