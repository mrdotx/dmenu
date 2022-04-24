#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_alsa.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2022-04-24T08:08:59+0200

# use standard c to identify the playback device
LC_ALL=C
LANG=C

# config
config_path="$HOME/.config/alsa"
config_file="asoundrc"

set_asoundrc() {
    mkdir -p "$config_path"

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
        "    card $card" \
        "}" > "$config_path/$config_file"
}

select=$(aplay -l \
    | grep '^card' \
    | dmenu -l 10 -c -bw 2 -r -i -p "device »" \
)

[ -n "$select" ] \
    && set_asoundrc "$select"
