#!/bin/sh

# path:       /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_iwd.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/dmenu
# date:       2021-01-09T17:17:13+0100

remove_escape_sequences() {
    tail -n +5 \
        | sed -r 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g;/^\s*$/d'
}

get_interface() {
    interface=$(iwctl device list \
        | remove_escape_sequences \
        | awk '{print $1" == ["$2"] == ["$3"]"}' \
        | dmenu -l 3 -c -bw 2 -r -i -p "interface »" \
        | awk '{print $1}'
    )
    [ -n "$interface" ] \
        || exit 1
}

scan_ssid() {
    timer=3
    message_id="$(date +%s)"
    iwctl station "$interface" scan \
        &&  while [ $timer -ge 1 ]; do
                notify-send \
                    -u low  \
                    -t 0 \
                    "iNet wireless daemon - please wait...$timer" \
                    "interface: $interface" \
                    -h string:x-canonical-private-synchronous:"$message_id"
                sleep 1
                timer=$((timer-1))
            done \
        && notify-send \
            -u low \
            -t 1000 \
            "iNet wireless daemon - finished" \
            "interface: $interface" \
            -h string:x-canonical-private-synchronous:"$message_id"

    scan_result=$(iwctl station "$interface" get-networks \
        | remove_escape_sequences \
        | sed 's/ psk / ; [psk ] ; /;s/ open / ; [open] ; /;s/\s\+/ /g' \
        | awk -F " ; " '{print $2" =="$1}' \
    )
}

get_ssid() {
    select=$(printf "[scan] == rescan?\n%s" "$scan_result" \
        | dmenu -l 10 -c -bw 2 -r -i -p "ssid »" \
    )
    ssid=$(printf "%s" "$select" \
        | awk -F " == " '{print $2}' \
    )
    if printf "%s" "$ssid" | grep -q "^> "; then
        notify-send "iNet wireless daemon" "already connected to \"$(printf "%s" "$ssid" \
            | sed 's/> //')\""
        exit 0
    fi
    [ "$(printf "%s" "$select" \
        | awk -F " == " '{print $1}')" = "[open]" ] \
        && open=1
    [ "$select" = "[scan] == rescan?" ] && {
        scan_ssid
        get_ssid
    }
    [ -n "$select" ] \
        || exit 1
}

get_psk() {
    psk=$(printf 'press esc or enter if you had already insert a passphrase before!\n' \
        | dmenu -l 1 -c -bw 2 -i -p "passphrase »" \
    )
}

connect_iwd() {
    if [ -z "$open" ]; then
        get_psk
        iwctl station "$interface" connect "$ssid" -P "$psk"
    else
        iwctl station "$interface" connect "$ssid"
    fi
    notify-send "iNet wireless daemon" "connected to \"$ssid\""
}

get_interface \
    && scan_ssid \
    && get_ssid \
    && connect_iwd
