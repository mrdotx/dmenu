#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_alsa.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2022-03-05T08:23:14+0100

# speed up script by not using unicode
LC_ALL=C
LANG=C

select=$(aplay -l \
    | grep '^card' \
    | dmenu -l 10 -c -bw 2 -r -i -p "device »" \
)

set_asoundrc() {
    config="$HOME/.config/alsa/asoundrc"

    mkdir -p "$HOME/.config/alsa"

    card=$(printf "%s" "$1" \
        | cut -d':' -f1 \
        | sed 's/card //' \
    )

    device=$(printf "%s" "$1" \
        | cut -d':' -f2 \
        | cut -d',' -f2 \
        | sed 's/ device //' \
    )

    printf "%s\n" \
        "defaults.pcm {" \
        "    type hw" \
        "    card $card" \
        "    device $device" \
        "}" \
        "defaults.ctl {" \
        "    type hw" \
        "    card $card" \
        "    device $device" \
        "}" > "$config"
}

[ -n "$select" ] \
    && set_asoundrc "$select"
