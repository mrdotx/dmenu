#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_alsa.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2022-03-09T14:17:59+0100

# speed up script by not using unicode
LC_ALL=C
LANG=C

# config
config_path="$HOME/.config/alsa"
config_file="asoundrc"
analog_filter="analog"
message_title="Volume"

script=$(basename "$0")
help="$script [-h/--help] -- script to change alsa audio output
  Usage:
    $script [-inc/-dec/-abs/-mute] [percent]

  Settings:
    [-inc]    = increase in percent (0-100)
    [-dec]    = decrease in percent (0-100)
    [-abs]    = absolute volume in percent (0-100)
    [percent] = how much percent to increase/decrease the volume
    [-mute]   = mute volume

  Examples:
    $script -inc 5
    $script -dec 5
    $script -abs 36
    $script -mute"

get_analog() {
    card=$(grep -m1 "card" "$config_path/$config_file" \
        | sed 's/^    //' \
    )

    if aplay -l \
        | grep -m1 -i -e "^$card.*$analog_filter" > /dev/null 2>&1; then
        device_mixer="Master"
        device_mute="Master"
    else
        device_mixer="PCM"
        device_mute="IEC958"
    fi
}

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

set_volume() {
    if [ "$#" -eq 2 ] \
        && [ "$2" -ge 0 ] > /dev/null 2>&1 \
        && [ "$2" -le 100 ] > /dev/null 2>&1; then
            amixer -q set $device_mixer "$2%$1"
            notification "$device_mixer" "$device_mute" "$2"
    else
        printf "%s\n" "$help"
        exit 1
    fi
}

notification() {
    volume="$(amixer get "$1" \
        | tail -1 \
        | cut -d'[' -f2 \
        | sed 's/%]*//' \
    )"

    amixer get "$2" | tail -1 | grep "\[off\]" >/dev/null \
        && volume=0

    [ "$volume" -gt 0 ] \
        && volume=$((volume /= ${3:-1})) \
        && volume=$((volume *= ${3:-1}))

    notify-send \
        -u low  \
        -t 2000 \
        -i "dialog-information" \
        "$message_title" \
        -h string:x-canonical-private-synchronous:"$message_title" \
        -h int:value:"$volume"
}

case "$1" in
    -h | --help)
        printf "%s\n" "$help"
        ;;
    -inc)
        get_analog
        set_volume "+" "$2"
        ;;
    -dec)
        get_analog
        set_volume "-" "$2"
        ;;
    -abs)
        get_analog
        set_volume "" "$2"
        ;;
    -mute)
        get_analog
        amixer -q set $device_mute toggle
        notification "$device_mixer" "$device_mute"
        ;;
    *)
        select=$(aplay -l \
            | grep '^card' \
            | dmenu -l 10 -c -bw 2 -r -i -p "device »" \
        )

        [ -n "$select" ] \
            && set_asoundrc "$select"
        ;;
esac
