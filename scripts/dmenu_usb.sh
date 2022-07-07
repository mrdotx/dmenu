#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_usb.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2022-07-07T12:04:49+0200

# auth can be something like sudo -A, doas -- or nothing,
# depending on configuration requirements
auth="${EXEC_AS_USER:-sudo}"

usb_bind() {
    $auth sh -c "printf '%s' \"$1\" \
        > \"/sys/bus/usb/drivers/usb/$2\"" 2>/dev/null
}

usb_bus() {
    [ -n "$2" ] \
        && select=$(lsusb \
            | grep -m1 "$2" \
            | sed -e 's/Bus 00/usb/g' \
                -e 's/Bus 0/usb/g' \
            | cut -d ' ' -f1 \
        )

    case $1 in
        rebind)
            usb_bind "$select" "unbind"
            sleep 1
            usb_bind "$select" "bind"
            ;;
        *bind)
            usb_bind "$select" "$1"
            ;;
        *)
            exit 1
            ;;
    esac
}

select_usb() {
    select=$(lsusb \
        | sort -k 2,4 \
        | sed -e 's/Bus 00/usb/g' \
            -e 's/Bus 0/usb/g' \
            -e 's/ Device [0-9][0-9][0-9]//g' \
            -e 's/ ID ....:....//g' \
        | dmenu -l 15 -c -bw 1 -r -i -p "usb »" \
        | cut -d ':' -f1 \
    )

    [ -n "$select" ] \
        && bind=$(printf "%s\n" \
                "bind" \
                "unbind" \
                "rebind" \
                    | dmenu -l 3 -c -bw 1 -r -i -p "usb »" \
        )

    [ -n "$bind" ] \
        && usb_bus "$bind"
}

# command line options bind/unbind/rebind
# e.g. dmenu_usb.sh --unbind "Wacom Co., Ltd CTH-480"
case "$1" in
    --*)
        usb_bus "${1##*--}" "$2"
        ;;
    *)
        select_usb
        ;;
esac
