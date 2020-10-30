#!/bin/sh

# path:       /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_exit.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/dmenu
# date:       2020-10-30T22:58:27+0100

script=$(basename "$0")
help="$script [-h/--help] -- script to shutdown/reboot/logout/suspend/lock
                                the system
  Usage:
    depending on how the script is named,
    it will be executed either with dmenu or with rofi

  Examples:
    dmenu_exit.sh
    rofi_exit.sh"

if [ "$1" = "-h" ] \
    || [ "$1" = "--help" ]; then
        printf "%s\n" "$help"
        exit 0
fi

case $script in
    dmenu_*)
        label="exit »"
        menu="dmenu -m 0 -r -i"
        ;;
    rofi_*)
        label=""
        menu="rofi -m -1 -theme klassiker-horizontal -dmenu -i"
        ;;
    *)
        printf "%s\n" "$help"
        exit 1
        ;;
esac

select=$(printf "%s\n" \
    "lock simple" \
    "suspend simple" \
    "lock blur" \
    "suspend blur" \
    "suspend" \
    "logout" \
    "reboot" \
    "shutdown" \
    | $menu -p "$label" \
)

[ -z "$select" ] \
    && exit 1

notify-send \
    "exit" \
    "trying to $select"

eval "i3_knockout.sh -$select"
