#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_youtube.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2025-05-27T05:33:20+0200

# source dmenu helper
. _dmenu_helper.sh

title="youtube"

# config
history_file="$HOME/.local/share/repos/dmenu/scripts/data/$title"
link_handler="dmenu_link_handler.sh"

# search
search=$(printf "%s" "$(cat "$history_file")" \
    | dmenu -c -bw 1 -l 15 -i -p "$title »" \
)

[ -z "$search" ] \
    && exit 0

# history
! [ -f "$history_file" ] \
    && printf "%s\n" "$search" > "$history_file"

sed -i "1s/^/$search\n/" "$history_file"
history="$(awk '! seen[$0]++' "$history_file")"
printf "%s\n" "$history" > "$history_file"

# yt search conditions
search_string=$(printf "%s\n" \
        "relevance 10" \
        "date 10" \
        "relevance all" \
        "date all" \
    | dmenu -c -bw 1 -l 15 -i -p "$title »" \
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

# search
dmenu_notify 0 "$title" "$search\n$search_string"
result=$(yt-dlp "$search_result:$search" -e --get-id)

# search result
select=$(printf "%s" "$result" \
    | sed -n '1~2p' \
    | dmenu -c -bw 1 -l 15 -r -i -p "$title »" \
)

dmenu_notify 1 "$title"

[ -z "$select" ] \
    && exit 0

open=$(printf "%s" "$result" \
    | sed -n "/$select/{n;p}" \
    | head -n1 \
)

# link_handler
$link_handler "ytdl://$open" &
