#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/_dmenu_helper.sh
# author: klassiker [mrdotx]
# url:    https://github.com/mrdotx/dmenu
# date:   2026-02-18T05:48:02+0100

dmenu_xdotool() {
    case "$1" in
        type)
            # WORKAROUND: xdotool mismatched keyboard layouts
            setxkbmap -synch

            shift
            xdotool type --delay 0 --clearmodifiers "$@"
            ;;
        key)
            shift
            xdotool key --delay 15 --clearmodifiers "$@"
            ;;
    esac
}

dmenu_notify() {
    # WORKAROUND: notifications are sometimes not displayed
    sleep .1

    [ "$1" -eq 0 ] \
        && dmenu_notify_timer=2147483647 \
        || dmenu_notify_timer="$1"
    dmenu_notify_title="$2 [dmenu]"
    dmenu_notify_message="$3"

    notify-send \
        -t "$dmenu_notify_timer" \
        -u low \
        "$dmenu_notify_title" \
        "$dmenu_notify_message" \
        -h string:x-canonical-private-synchronous:"$dmenu_notify_title"
}
