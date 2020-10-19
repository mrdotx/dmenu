#!/bin/sh

# path:       /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_virtualbox.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/dmenu
# date:       2020-10-19T19:55:07+0200

script=$(basename "$0")
help="$script [-h/--help] -- script to start a virtual machine without
                                   virtualbox frontend
  Usage:
    depending on how the script is named,
    it will be executed either with dmenu or with rofi

  Examples:
    dmenu_virtualbox.sh
    rofi_virtualbox.sh"

if [ "$1" = "-h" ] \
    || [ "$1" = "--help" ]; then
        printf "%s\n" "$help"
        exit 0
fi

case $script in
    dmenu_*)
        label="vm »"
        menu="dmenu -l 5 -c -bw 2 -r -i"
        ;;
    rofi_*)
        label=""
        menu="rofi -m -1 -l 5 -theme klassiker-center -dmenu -i"
        ;;
    *)
        printf "%s\n" "$help"
        exit 1
        ;;
esac

select=$(VBoxManage list vms \
    | cut -d '"' -f2 \
    | $menu -p "$label" \
)

[ -z "$select" ] \
    && exit 1

notify-send "virtualbox" "starting $select"

VBoxManage startvm "$select" >/dev/null 2>&1
