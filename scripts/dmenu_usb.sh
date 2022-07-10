#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_usb.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2022-07-10T18:32:53+0200

# auth can be something like sudo -A, doas -- or nothing,
# depending on configuration requirements
auth="${EXEC_AS_USER:-sudo}"

logical_device() {
    path_devices="/sys/bus/usb/devices"
    path_drivers="/sys/bus/usb/drivers/usb"

    ports=$(find "$path_devices" -type l \
        | sort \
        | cut -d '/' -f6 \
    )

    device() {
        for port in $ports; do
            get_info() {
                [ -e "$path_devices/$port/$1" ] \
                    && cat "$path_devices/$port/$1"
            }

            printf "Bus %03d Device %03d:%s\n" \
                "$(get_info "busnum")" \
                "$(get_info "devnum")" \
                "$port" \
                    | awk '{$1=$1;print}'
        done \
            | grep -m1 "$1" \
            | cut -d':' -f2
    }

    $auth sh -c "printf '%s' \"$(device "$1")\" \
        > \"$path_drivers/$2\"" 2>/dev/null
}

usb() {
    [ -n "$2" ] \
        && select=$(lsusb \
            | grep -m1 "$2" \
            | cut -d ':' -f1 \
        )

    case "$1" in
        rebind)
            logical_device "$select" "unbind"
            sleep 1
            logical_device "$select" "bind"
            ;;
        *bind)
            logical_device "$select" "$1"
            ;;
        *)
            exit 1
            ;;
    esac
}

select_usb() {
    select=$(lsusb \
        | sort -k 2,4 \
        | dmenu -l 15 -c -bw 1 -r -i -p "usb »" \
        | cut -d ':' -f1 \
    )

    [ -n "$select" ] \
        && bind=$(printf "bind\nunbind\nrebind" \
            | dmenu -l 3 -c -bw 1 -r -i -p "$select »" \
        )

    [ -n "$bind" ] \
        && usb "$bind"
}

# command line options bind/unbind/rebind
# e.g. dmenu_usb.sh --unbind "Bus 003 Device 001"
case "$1" in
    --*)
        usb "${1##*--}" "$2"
        ;;
    *)
        select_usb
        ;;
esac
