#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_macro.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2021-09-29T20:05:46+0200

press_key() {
    i="$1"
    shift
    while [ "$i" -ge 1 ]; do
        xdotool key --delay 15 "$@"
        i=$((i-1))
    done
}

type_string() {
    # workaround for mismatched keyboard layouts
    setxkbmap -synch

    printf "%s" "$1" \
        | xdotool type \
            --delay 1 \
            --clearmodifiers \
            --file -
}

change_workspace() {
    i3-msg workspace "$1"
}

open_tmux() {
    i3_tmux.sh -o 1 'shell'
    change_workspace 2

    # increase font size
    [ "$2" = "true" ] \
        && press_key 8 ctrl+plus

    # clear prompt
    press_key 1 ctrl+c
    type_string " clear; $1"
    press_key 1 return
}

open_autostart() {
    change_workspace 1
    # start web browser
    firefox-developer-edition &

    # start ranger
    $TERMINAL -e "$SHELL"
    type_string " clear; ranger_cd"
    press_key 1 return

    # wait for web browser window
    while ! wmctrl -l | grep -q "Mozilla Firefox"; do
        sleep .1
    done
    sleep .3

    # start tmux
    open_tmux "cinfo" "true"

    change_workspace 1
    # change folder to repos in ranger
    press_key 1 apostrophe r
    change_workspace 2
}

open_macro_menu() {
    case $(printf "%s\n" \
        "weather" \
        "corona stats" \
        "boot next" \
        "ventoy" \
        "terminal colors" \
        "neofetch" \
        "starwars" \
        | dmenu -l 10 -c -bw 2 -r -i -p "macro »" \
        ) in
        "weather")
            open_tmux \
                "curl -s 'wttr.in/?AFq2&lang=de'"
            ;;
        "corona stats")
            open_tmux \
                "curl -s \
                    'https://corona-stats.online?top=30&source=2&minimal=true' \
                    | head -n32"
            ;;
        "boot next")
            open_tmux \
                "doas efistub.sh -b"
            ;;
        "ventoy")
            open_tmux \
                "lsblk; ventoy -h"
            type_string \
                "doas ventoy -u /dev/sdb"
            ;;
        "terminal colors")
            open_tmux \
                "terminal_colors.sh"
            ;;
        "neofetch")
            open_tmux \
                "neofetch"
            ;;
        "starwars")
            open_tmux \
                "telnet towel.blinkenlights.nl"
            ;;
    esac
}

case "$1" in
    --autostart)
        open_autostart
        ;;
    *)
        open_macro_menu
        ;;
esac
