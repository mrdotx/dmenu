#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_macro.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2021-07-24T19:24:58+0200

type_in="i3_tmux.sh -o 1 'shell'"

type_string() {
    $1
    i3-msg workspace 3

    # workaround for mismatched keyboard layouts
    setxkbmap -synch

    printf "%s" "$2" \
        | xdotool type \
            --delay 1 \
            --clearmodifiers \
            --file -

    [ "$3" != false ] \
        && xdotool key Return
}

case $(printf "%s\n" \
    "keyboard setup" \
    "boot next" \
    "ventoy" \
    "terminal colors" \
    "neofetch" \
    "weather" \
    "covid stats" \
    | dmenu -l 10 -c -bw 2 -r -i -p "macro »" \
    ) in
    "keyboard setup")
        setxkbmap \
            -model pc105 \
            -layout us,de \
            -option grp:caps_switch
        xset r rate 200 50
        ;;
    "boot next")
        type_string \
            "$type_in" \
            " clear; doas efistub.sh -b"
        ;;
    "ventoy")
        type_string \
            "$type_in" \
            " clear; lsblk; ventoy -h"
        type_string \
            "$type_in" \
            "doas ventoy -u /dev/sdb" \
            false
        ;;
    "terminal colors")
        type_string \
            "$type_in" \
            " clear; terminal_colors.sh"
        ;;
    "neofetch")
        type_string \
            "$type_in" \
            " clear; neofetch"
        ;;
    "weather")
        type_string \
            "$type_in" \
            " clear; curl -s 'wttr.in/?AFq2&lang=de'"
        ;;
    "covid stats")
        type_string \
            "$type_in" \
            " clear; curl -s 'https://corona-stats.online?top=30&source=2&minimal=true' | head -n32"
        ;;
esac
