#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_youtube.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2021-07-15T13:01:30+0200

history_file="$HOME/.local/share/repos/dmenu/scripts/data/youtube"

[ "$(command -v "xsel")" ] \
    && clipboard="$(xsel -n -o -b)"

if [ -n "$clipboard" ]; then \
    search=$(printf "== clear clipboard ==\n%s\n== clear clipboard ==\n%s" "$clipboard" "$(cat "$history_file")")
else
    search=$(printf "%s" "$(cat "$history_file")")
fi

search=$(printf "%s" "$search" \
    | dmenu -l 20 -c -bw 2 -i -p "youtube »" \
)

[ -z "$search" ] \
    && exit 0

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
        sed -i "1s/^/$search\n/" "$history_file"
        printf "%s\n" "$(awk '! seen[$0]++' "$history_file")" > "$history_file"

        search_string=$(printf "%s\n" \
                "relevance 10" \
                "date 10" \
                "relevance all" \
                "date all" \
                "== [relevance/date] [quantity/all] ==" \
            | dmenu -l 20 -c -bw 2 -r -i -p "youtube »" \
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
                -u low \
                -t "$1" \
                "$2" \
                "search: $search\nresult: $search_string" \
                -h string:x-canonical-private-synchronous:"$message_id"
        }

        # this loop is a workaround, because often youtube-dl returns no results
        attempts=30
        message_id="$(date +%s)"
        while [ $attempts -ge 1 ] \
            && [ -z "$result" ]; do
                notification 0 "youtube-dl - please wait...$attempts"
                result=$(youtube-dl "$search_result:$search" -e --get-id)
                attempts=$((attempts-1))
        done
        notification 1000 "youtube-dl - finished"

        select=$(printf "%s" "$result" \
            | sed -n '1~2p' \
            | dmenu -l 20 -c -bw 2 -r -i -p "youtube »" \
        )

        [ -z "$select" ] \
            && exit 0

        open=$(printf "%s" "$result" \
            | sed -n "/$select/{n;p}"
        )
        ;;
esac

search=$(printf "%s\n" \
    "1) play video" \
    "2) play audio" \
    "3) add video to taskspooler" \
    "4) add audio to taskspooler" \
    "5) download video" \
    "6) download audio" \
    | dmenu -l 20 -c -bw 2 -r -i -p "youtube »" \
)

[ -z "$search" ] \
    && exit 0

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
        $TERMINAL -e terminal_wrapper.sh youtube-dl -ciw "$open" &
        ;;
    "6) download audio")
        $TERMINAL -e terminal_wrapper.sh youtube-dl -ciw -x --audio-format mp3 --audio-quality 0 "$open" &
        ;;
esac
