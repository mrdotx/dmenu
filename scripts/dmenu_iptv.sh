#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_iptv.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2024-01-17T08:59:34+0100

# config
m3u="$HOME/.local/share/repos/epg/xitylight.m3u"
radio="$TERMINAL -e mpv"
tv="mpv --no-terminal"

channels=$(grep -v "#EXTM3U\|\#EXTVLCOPT\|^[[:space:]]*$" "$m3u" \
    | sed \
        -e 's/#EXTINF:.* tvg-/tvg-/g' \
        -e 's/tvg\-.*=".*" //g' \
        -e 's/group-title="//g' \
        -e 's/",/#/g' \
    | sed 'N;s/\n/#/' \
    | sort -u \
)

select=$(printf "%s" "$channels" \
    | awk -F "#" '{print $1 " - " $2}' \
    | dmenu -l 15 -c -bw 1 -r -i -p "channel »" \
    | sed 's/ - /#/'
)

[ -z "$select" ] \
    && exit 0

channel=$(printf "%s" "$channels" \
    | grep "^$select#" \
    | cut -d'#' -f3 \
)

case $select in
    *"(Radio)#"*)
        $radio "$channel"
        ;;
    *)
        $tv "$channel"
        ;;
esac
