#!/bin/sh

# path:       /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_iwd.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/dmenu
# date:       2020-05-27T12:11:41+0200

script=$(basename "$0")
help="$script [-h/--help] -- script to connect to wlan with iwd
  Usage:
    depending on how the script is named,
    it will be executed either with dmenu or with rofi

  Examples:
    dmenu_iwd.sh
    rofi_iwd.sh"

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    printf "%s\n" "$help"
    exit 0
fi

case $script in
    dmenu_*)
        label_ifc="interface:"
        menu_ifc="dmenu -l 3 -c -bw 2 -r -i"
        label_ssid="ssid:"
        menu_ssid="dmenu -l 10 -c -bw 2 -r -i"
        label_psk="passphrase:"
        menu_psk="dmenu -l 1 -c -bw 2 -i"
        ;;
    rofi_*)
        label_ifc=""
        menu_ifc="rofi -m -1 -l 3 -theme klassiker-center -dmenu -i"
        label_ssid=""
        menu_ssid="rofi -m -1 -l 10 -theme klassiker-center -dmenu -i"
        label_psk=""
        menu_psk="rofi -m -1 -l 1 -theme klassiker-center -dmenu -i"
        ;;
    *)
        printf "%s\n" "$help"
        exit 1
        ;;
esac

cln_iwctl(){
    tail -n +5 \
        | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g;/^\s*$/d"
}

get_ifc(){
    ifc=$(iwctl device list \
        | cln_iwctl \
        | awk '{print $1" == ["$2"] == ["$3"]"}' \
        | $menu_ifc -p "$label_ifc" \
        | awk '{print $1}'
    )
}

scan_ssid(){
    iwctl station "$ifc" scan && sleep 1
    scan_res=$(iwctl station "$ifc" get-networks \
        | cln_iwctl \
        | sed 's/ psk / ; [psk ] ; /;s/ open / ; [open] ; /;s/\s\+/ /g' \
        | awk -F " ; " '{print $2" =="$1}' \
    )
}

get_ssid(){
    [ -n "$ifc" ] \
        || exit 1
    sel=$(printf "[scan] == rescan?\n%s" "$scan_res" \
        | $menu_ssid -p "$label_ssid" \
    )
    ssid=$(printf "%s" "$sel" \
        | awk -F" == " '{print $2}' \
        | sed 's/> //' \
    )
    [ "$(printf "%s" "$sel" \
        | awk -F" == " '{print $1}')" = "[open]" ] \
        && open=1
    [ "$sel" = "[scan] == rescan?" ] && {
        scan_ssid && sleep 2
        get_ssid
    }
    [ -n "$sel" ] \
        || exit 1
}

get_psk(){
    psk=$(printf 'press esc or enter if you had already insert a passphrase before!\n' \
        | $menu_psk -p "$label_psk" \
    )
}

get_ifc \
    && scan_ssid \
    && get_ssid
if [ -z "$open" ]; then
    get_psk
    iwctl station "$ifc" connect "$ssid" -P "$psk" \
    && notify-send "connected to $ssid"
else
    iwctl station "$ifc" connect "$ssid" \
    && notify-send "connected to $ssid"
fi
