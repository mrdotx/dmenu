#!/bin/sh

# path:       /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_iwd.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/dmenu
# date:       2020-05-25T20:56:18+0200

cln_iwctl() {
    tail -n +5 \
        | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g" \
        | grep -v -e "^\s*$"
}

get_ifc() {
    ifc=$(iwctl device list \
        | cln_iwctl \
        | awk '{print $1}' \
        | dmenu -l 10 -c -bw 2 -r -i -p "interface:"
    )
}

scan_ssid() {
    iwctl station "$ifc" scan && sleep 1
    scan_res=$(iwctl station "$ifc" get-networks \
        | cln_iwctl \
        | sed 's/ psk / ; [psk] ; /;s/ open / ; [open] ; /;s/\s\+/ /g' \
        | awk -F " ; " '{print $2" -;-"$1}' \
    )
}

get_ssid() {
    sel=$(printf "%s\nrescan" "$scan_res" \
        | dmenu -l 10 -c -bw 2 -r -i -p "ssid:" \
    )
    ssid=$(printf "%s" "$sel" \
        | awk -F" -;- " '{print $2}' \
        | sed 's/>//;s/^\s//g' \
    )
    [ "$(printf "%s" "$sel" \
        | awk -F" -;- " '{print $1}')" = "[psk]" ] \
        && psk=1
    [ "$sel" = "rescan" ] && {
        scan_ssid && sleep 2
        get_ssid
    }
    [ -n "$sel" ] || exit
}

get_psk() {
    psk=$(printf 'press esc or enter if you had already insert a passphrase before!\n' \
        | dmenu -l 10 -c -bw 2 -i -p "passphrase:" \
    )
}

get_ifc \
    && scan_ssid \
    && get_ssid
if [ "$psk" = 1 ]; then
    get_psk \
        || exit
    iwctl station "$ifc" connect "$ssid" -P "$psk" \
    && notify-send "connected to $ssid"
else
    iwctl station "$ifc" connect "$ssid" \
    && notify-send "connected to $ssid"
fi
