#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_usb.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2022-07-09T20:11:59+0200

# auth can be something like sudo -A, doas -- or nothing,
# depending on configuration requirements
auth="${EXEC_AS_USER:-sudo}"
path="/sys/bus/usb/drivers/usb"

get_devices() {
    logical_devices() {
        ports=$(find "$path" -type l -name '[0-9]*-[0-9]*' \
            | sort \
            | cut -d '/' -f7 \
        )

        for port in $ports; do
            get_info() {
                [ -e "$path/$port/$1" ] \
                    && cat "$path/$port/$1"
            }

            printf "%s: %s %s\n" \
                "$port" \
                "$(get_info "manufacturer")" \
                "$(get_info "product")" \
                    | awk '{$1=$1;print}'
        done
    }

    root_hubs() {
        lsusb \
            | grep "Device 001" \
            | sort -k 2,4 \
            | sed -e 's/Bus 00/usb/g' \
                -e 's/Bus 0/usb/g' \
                -e 's/ Device [0-9][0-9][0-9]//g' \
                -e 's/ ID ....:....//g'
    }

    printf "%s\n" \
        "$(logical_devices)" \
        "$(root_hubs)"
}

usb_bus() {
    usb_bind() {
        $auth sh -c "printf '%s' \"$1\" > \"$path/$2\"" 2>/dev/null
    }

    [ -n "$2" ] \
        && select=$(get_devices \
            | grep -m1 "$2" \
            | cut -d ':' -f1 \
        )

    case "$1" in
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
    select=$(get_devices \
        | dmenu -l 15 -c -bw 1 -r -i -p "usb »" \
        | cut -d ':' -f1 \
    )

    [ -n "$select" ] \
        && bind=$(printf "bind\nunbind\nrebind" \
            | dmenu -l 3 -c -bw 1 -r -i -p "$select »" \
        )

    [ -n "$bind" ] \
        && usb_bus "$bind"
}

# command line options bind/unbind/rebind
# e.g. dmenu_usb.sh --unbind "^usb3:"
case "$1" in
    --*)
        usb_bus "${1##*--}" "$2"
        ;;
    *)
        select_usb
        ;;
esac
