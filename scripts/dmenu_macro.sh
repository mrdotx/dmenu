#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_macro.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2021-08-25T10:24:05+0200

type_tmux() {
    i3_tmux.sh -o 1 'shell'
    i3-msg workspace 2

    # clear prompt
    [ "$2" != false ] \
        && xdotool key Control_L+c

    # workaround for mismatched keyboard layouts
    setxkbmap -synch

    printf "%s" "$1" \
        | xdotool type \
            --delay 1 \
            --clearmodifiers \
            --file -

    [ "$2" != false ] \
        && xdotool key Return
}

case $(printf "%s\n" \
    "boot next" \
    "ventoy" \
    "terminal colors" \
    "neofetch" \
    "starwars" \
    "weather" \
    "corona stats" \
    | dmenu -l 10 -c -bw 2 -r -i -p "macro »" \
    ) in
    "boot next")
        type_tmux \
            " clear; doas efistub.sh -b"
        ;;
    "ventoy")
        type_tmux \
            " clear; lsblk; ventoy -h"
        type_tmux \
            "doas ventoy -u /dev/sdb" \
            false
        ;;
    "terminal colors")
        type_tmux \
            " clear; terminal_colors.sh"
        ;;
    "neofetch")
        type_tmux \
            " clear; neofetch"
        ;;
    "starwars")
        type_tmux \
            " clear; telnet towel.blinkenlights.nl"
        ;;
    "weather")
        type_tmux \
            " clear; curl -s 'wttr.in/?AFq2&lang=de'"
        ;;
    "corona stats")
        type_tmux \
            " clear; curl -s 'https://corona-stats.online?top=30&source=2&minimal=true' | head -n32"
        ;;
esac
