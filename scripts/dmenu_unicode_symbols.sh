#!/bin/sh

# path:       /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_unicode_symbols.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/dmenu
# date:       2020-05-25T23:57:19+0200

script=$(basename "$0")
help="$script [-h/--help] -- script to copy unicode symbols with dmenu/rofi
  Usage:
    depending on how the script is named,
    it will be executed either with dmenu or with rofi

  Examples:
    dmenu_symbols.sh
    rofi_symbols.sh"

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
        label="symbol:"
        menu="dmenu -b -l 15 -r -i -w $win_id"
        ;;
    rofi_*)
        label=""
        menu="rofi -m -2 -l 10 -columns 3 -theme klassiker-vertical -dmenu -i"
        ;;
    *)
        printf "%s\n" "$help"
        exit 1
        ;;
esac

sel=$(< "$HOME/.local/share/repos/dmenu/scripts/data/symbols-unicode" $menu -p "$label")

[ -n "$sel" ] || exit 1

sym=$(printf "%s\n" "$sel" \
    | sed "s/ .*//" \
)
code=$(printf "%s\n" "$sel" \
    | cut -d ';' -f2 \
)

# insert to cursor in active window
xdotool type "$sym"
# copy symbol to clipboard
printf "%s\n" "$sym" \
    | tr -d '\n' \
    | xsel -b
# copy code to primary
printf "%s\n" "$code" \
    | tr -d '\n' \
    | xsel

notify-send "copied to clipboard" "clipboard: $sym\nprimary: $code"
