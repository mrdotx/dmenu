#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_iwd.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2022-06-06T10:53:03+0200

notification() {
    notify-send \
        -t "${3:-5000}" \
        -u low  \
        "iNet wireless daemon$1" \
        "$2" \
        -h string:x-canonical-private-synchronous:"$message_id"
}

remove_escape_sequences() {
    tail -n +5 \
        | sed -r 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g;/^\s*$/d'
}

toggle_device_power() {
    interface=$(iwctl device list \
        | remove_escape_sequences \
        | awk '{print $1" ==> ["$3"] == "$2""}' \
        | dmenu -l 3 -c -bw 1 -r -i -p "interface »"
    )

    device=$(printf "%s" "$interface" | cut -d ' ' -f1)
    power=$(printf "%s" "$interface" | cut -d ' ' -f3)

    case $power in
        \[on\])
            iwctl device "$device" set-property Powered off
            ;;
        \[off\])
            iwctl device "$device" set-property Powered on
            ;;
    esac

    get_interface
}

get_interface() {
    interface=$(iwctl device list \
        | remove_escape_sequences \
        | awk '{print $1" == "$2" == ["$3"]\n== toggle device power =="}' \
        | dmenu -l 3 -c -bw 1 -r -i -p "interface »"
    )

    power=$(printf "%s" "$interface" | cut -d ' ' -f5)
    interface=$(printf "%s" "$interface" | cut -d ' ' -f1)

    [ "$interface" = "==" ] \
        || [ "$power" = "[off]" ] \
        && toggle_device_power

    [ -n "$interface" ] \
        || exit 1
}

scan_ssid() {
    timer=3
    message_id="$(date +%s)"
    iwctl station "$interface" scan \
        &&  while [ $timer -ge 1 ]; do
                notification \
                    " - please wait...$timer" \
                    "interface: $interface" \
                    0
                sleep 1
                timer=$((timer-1))
            done \
        && notification \
            " - finished" \
            "interface: $interface" \
            1000

    scan_result=$(iwctl station "$interface" get-networks \
        | remove_escape_sequences \
        | sed 's/ psk / ; [psk ] ; /;s/ open / ; [open] ; /;s/\s\+/ /g' \
        | awk -F " ; " '{print $2" =="$1}' \
    )
}

get_ssid() {
    select=$(printf "[scan] == rescan?\n%s" "$scan_result" \
        | dmenu -l 10 -c -bw 1 -r -i -p "ssid »" \
    )
    ssid=$(printf "%s" "$select" \
        | awk -F " == " '{print $2}' \
    )
    printf "%s" "$ssid" | grep -q "^> " \
        && ssid=$(printf "%s" "$ssid" | sed 's/^> //') \
        && iwctl station "$interface" disconnect "$ssid"
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
        | dmenu -l 1 -c -bw 1 -i -p "passphrase »" \
    )
}

connect_iwd() {
    if [ -z "$open" ]; then
        get_psk
        iwctl station "$interface" connect "$ssid" -P "$psk"
    else
        iwctl station "$interface" connect "$ssid"
    fi
    notification \
        "" \
        "connected to \"$ssid\""
}

get_interface \
    && scan_ssid \
    && get_ssid \
    && connect_iwd
