#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/_dmenu_helper.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2024-12-16T08:01:04+0100

dmenu_notify() {
    # WORKAROUND: notifications are sometimes not displayed
    sleep .1

    dmenu_notify_timer="$1"
    dmenu_notify_title="$2 [dmenu]"
    dmenu_notify_message="$3"

    notify-send \
        -t "$dmenu_notify_timer" \
        -u low \
        "$dmenu_notify_title" \
        "$dmenu_notify_message" \
        -h string:x-canonical-private-synchronous:"$dmenu_notify_title"
}
