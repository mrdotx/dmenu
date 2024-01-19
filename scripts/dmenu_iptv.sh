#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_iptv.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2024-01-19T12:35:21+0100

# config
m3us="
$HOME/.local/share/repos/epg/playlists/xitylight.m3u
"
radio="$TERMINAL -e mpv"
tv="mpv --no-terminal"

m3us=$(printf "%s" "$m3us" | sed "/^$/d")

case "$(printf "%s" "$m3us" | wc -w)" in
    1)
        m3u="$m3us"
        ;;
    *)
        m3u=$(printf "%s" "$m3us" \
            | dmenu -l 15 -c -bw 1 -r -i -p "m3u »"
        )
        ;;
esac

[ -z "$m3u" ] \
    && exit 0

channels=$(grep -v "#EXTM3U\|\#EXTVLCOPT\|^[[:space:]]*$" "$m3u" \
    | sed \
        -e 's/#EXTINF:-1 //g' \
        -e 's/tvg-name="[^"]*"//g' \
        -e 's/tvg-logo="[^"]*"//g' \
        -e 's/tvg-id="[^"]*"//g' \
        -e 's/[ ]*group-title="//g' \
        -e 's/"[ ]*,/\t/g' \
    | sed 'N;s/\n/\t/' \
    | sort -u \
)

select=$(printf "%s" "$channels" \
    | awk -F "\t" '{print $1 " - " $2}' \
    | dmenu -l 15 -c -bw 1 -r -i -p "channel »" \
    | sed 's/ - /\t/'
)

[ -z "$select" ] \
    && exit 0

channel=$(printf "%s" "$channels" \
    | grep "^$select	" \
    | cut -d'	' -f3 \
)

case $select in
    *"(Radio)	"*)
        $radio "$channel"
        ;;
    *)
        $tv "$channel"
        ;;
esac
