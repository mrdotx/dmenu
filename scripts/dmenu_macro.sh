#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_macro.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2021-09-28T12:21:34+0200

type_chars() {
    # workaround for mismatched keyboard layouts
    setxkbmap -synch

    printf "%s" "$1" \
        | xdotool type \
            --delay 1 \
            --clearmodifiers \
            --file -
}

type_tmux() {
    i3_tmux.sh -o 1 'shell'
    i3-msg workspace 2

    # clear prompt
    xdotool key ctrl+c
    type_chars " clear; $1"
    xdotool key return
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
            "doas efistub.sh -b"
        ;;
    "ventoy")
        type_tmux \
            "lsblk; ventoy -h"
        type_chars \
            "doas ventoy -u /dev/sdb"
        ;;
    "terminal colors")
        type_tmux \
            "terminal_colors.sh"
        ;;
    "neofetch")
        type_tmux \
            "neofetch"
        ;;
    "starwars")
        type_tmux \
            "telnet towel.blinkenlights.nl"
        ;;
    "weather")
        type_tmux \
            "curl -s 'wttr.in/?AFq2&lang=de'"
        ;;
    "corona stats")
        type_tmux \
            "curl -s \
                'https://corona-stats.online?top=30&source=2&minimal=true' \
                | head -n32"
        ;;
esac
