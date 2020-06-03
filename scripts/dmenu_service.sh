#!/bin/sh

# path:       /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_service.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/dmenu
# date:       2020-06-03T22:10:04+0200

script=$(basename "$0")
help="$script [-h/--help] -- script to start and stop services
  Usage:
    depending on how the script is named,
    it will be executed either with dmenu or with rofi

  Examples:
    dmenu_service.sh
    rofi_service.sh"

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    printf "%s\n" "$help"
    exit 0
fi

case $script in
    dmenu_*)
        label="service »"
        menu="dmenu -l 9 -c -bw 2 -r -i"
        up="up"
        down="down"
        ;;
    rofi_*)
        label=""
        menu="rofi -m -1 -l 3 -columns 3 -theme klassiker-center -dmenu -i"
        up=""
        down=""
        ;;
    *)
        printf "%s\n" "$help"
        exit 1
        ;;
esac

# auth can be something like sudo -A, doas -- or
# nothing, depending on configuration requirements
auth="doas --"
vpn_name="hades"

# app status
app_stat(){
    [ "$(pgrep -f "$1")" ] \
        && printf "%s" "$up" \
        || printf "%s" "$down"
}

# systemd user status
sys_user_stat(){
    [ "$(systemctl --user is-active "$1")" = "active" ] \
        && printf "%s" "$up" \
        || printf "%s" "$down"
}

# systemd status
sys_stat(){
    [ "$(systemctl is-active "$1")" = "active" ] \
        && printf "%s" "$up" \
        || printf "%s" "$down"
}

# status
stat_polkit=$(sys_user_stat authentication.service)
stat_printer=$(sys_stat org.cups.cupsd.service)
stat_avahi=$(sys_stat avahi-daemon.service)
stat_bluetooth=$(sys_stat bluetooth.service)
stat_gestures=$(sys_user_stat gestures.service)
stat_firewall=$(sys_stat ufw.service)
stat_vpn=$(sys_stat vpnc@$vpn_name.service)
stat_resolver=$(sys_stat systemd-resolved.service)
stat_conky=$(app_stat conky)

# systemd user service
usvc(){
    if [ "$(systemctl --user is-active "$1")" != "active"  ]; then
        systemctl --user enable "$1" --now \
            && notify-send "Service started!" "$1"
    else
        systemctl --user disable "$1" --now \
            && notify-send "Service stopped!" "$1"
    fi
}

# systemd service
svc(){
    if [ "$(systemctl is-active "$1")" != "active"  ]; then
        $auth systemctl enable "$1" --now \
            && notify-send "Service started!" "$1"
    else
        $auth systemctl enable stop "$1" --now \
            && notify-send "Service stopped!" "$1"
    fi
}

# menu
case $(printf "%s\n" \
    "[$stat_polkit] Polkit" \
    "[$stat_printer] Printer" \
    "[$stat_avahi] Avahi" \
    "[$stat_bluetooth] Bluetooth" \
    "[$stat_gestures] Gestures" \
    "[$stat_firewall] Firewall" \
    "[$stat_vpn] VPN $vpn_name" \
    "[$stat_resolver] Resolver" \
    "[$stat_conky] Conky" \
    | $menu -p "$label"\
    ) in
    *Polkit)
        usvc "authentication.service"
        ;;
    *Printer)
        svc "org.cups.cupsd.service"
        ;;
    *Avahi)
        if [ "$stat_avahi" != "$up" ]; then
            svc "avahi-daemon.service"
        else
            svc "avahi-daemon.service" >/dev/null 2>&1
            svc "avahi-daemon.socket"
        fi
        ;;
    *Bluetooth)
        svc "bluetooth.service"
        ;;
    *Gestures)
        usvc "gestures.service"
        ;;
    *Firewall)
        svc "ufw.service"
        ;;
    *VPN*)
        svc "vpnc@$vpn_name.service"
        ;;
    *Resolver)
        svc "systemd-resolved.service"
        ;;
    *Conky)
        conky.sh
        ;;
esac
