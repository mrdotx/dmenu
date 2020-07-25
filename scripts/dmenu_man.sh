#!/bin/sh

# path:       /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_man.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/dmenu
# date:       2020-07-25T10:07:53+0200

script=$(basename "$0")
help="$script [-h/--help] -- script to search man pages
  Usage:
    depending on how the script is named,
    it will be executed either with dmenu or with rofi

  Examples:
    dmenu_man.sh
    rofi_man.sh"

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    printf "%s\n" "$help"
    exit 0
fi

case $script in
    dmenu_*)
        label="man »"
        win_id=$(xprop -root \
            | awk '/_NET_ACTIVE_WINDOW\(WINDOW\)/{print $NF}' \
        )
        menu="dmenu -b -l 15 -r -i -w $win_id"
        ;;
    rofi_*)
        label=""
        menu="rofi -m -2 -l 15 -theme klassiker-vertical -dmenu -i"
        ;;
    *)
        printf "%s\n" "$help"
        exit 1
        ;;
esac

select=$(apropos -l '' \
    | sort \
    | $menu -p "$label" \
    | awk '{print $1, $2}' \
    | tr -d ' ')

if [ -n "$select" ]; then
    $TERMINAL -T "man floating" -e man "$select" &
fi
