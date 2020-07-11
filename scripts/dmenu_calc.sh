#!/bin/sh

# path:       /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_calc.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/dmenu
# date:       2020-07-11T20:32:01+0200

script=$(basename "$0")
help="$script [-h/--help] -- script to calculate with dmenu/rofi
  Usage:
    depending on how the script is named,
    it will be executed either with dmenu or with rofi

  Examples:
    dmenu_calc.sh
    rofi_calc.sh"

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    printf "%s\n" "$help"
    exit 0
fi

case $script in
    dmenu_*)
        # get active window id
        win_id=$(xprop -root \
            | awk '/_NET_ACTIVE_WINDOW\(WINDOW\)/{print $NF}' \
        )
        menu="dmenu -b -l 3 -w $win_id"
        ;;
    rofi_*)
        menu="rofi -m -2 -l 1 -columns 3 -theme klassiker-vertical -dmenu"
        ;;
    *)
        printf "%s\n" "$help"
        exit 1
        ;;
esac

# use bc for calculations
result=$(printf "%s\n" "$@" \
    | bc -l \
    | sed '/\./ s/\.\{0,1\}0\{1,\}$//' \
)
select=$(printf "copy to clipboard\nclear\nclose" \
    | $menu -p "= $result" \
)
case $select in
    copy?to?clipboard)
        printf "%s\n" "$result" \
            | xsel -b \
            && notify-send "Clipboard" "Result copied: $result"
        ;;
    clear)
        $0
        ;;
    close)
        ;;
    "")
        ;;
    *)
        $0 "$result $select"
        ;;
esac
