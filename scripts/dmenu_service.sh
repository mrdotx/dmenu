#!/bin/sh

# path:       /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_service.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/dmenu
# date:       2020-05-23T19:20:40+0200

# auth can be something like sudo -A, doas -- or
# nothing, depending on configuration requirements
auth="doas --"
polkit="/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1"
gestures="/usr/bin/libinput-gestures"
vpn_name="hades"
up="up"
down="down"

# app status
app_stat() {
    [ "$(pgrep -f "$1")" ] \
        && printf "%s" "$up" \
        || printf "%s" "$down"
}

# systemd status
sys_stat() {
    [ "$(systemctl is-active "$1")" = "active" ] \
        && printf "%s" "$up" \
        || printf "%s" "$down"
}

# status
stat_polkit=$(app_stat $polkit)
stat_printer=$(sys_stat org.cups.cupsd.service)
stat_avahi=$(sys_stat avahi-daemon.service)
stat_bluetooth=$(sys_stat bluetooth.service)
stat_gestures=$(app_stat $gestures)
stat_firewall=$(sys_stat ufw.service)
stat_vpn=$(app_stat "vpnc $vpn_name")
stat_resolver=$(sys_stat systemd-resolved.service)
stat_conky=$(app_stat conky)

# systemd service
svc() {
    if [ "$(systemctl is-active "$1")" != "active"  ]; then
        $auth systemctl start "$1" \
            && notify-send "Service started!" "$1"
    else
        $auth systemctl stop "$1" \
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
    | dmenu -l 9 -c -bw 2 -r -i -p "service:"\
    ) in
    *Polkit)
    if [ "$stat_polkit" != "$up" ]; then
            $polkit >/dev/null 2>&1 &
            notify-send "Application started!" "$polkit"
        else
            killall $polkit >/dev/null 2>&1 \
                && notify-send "Application stopped!" "$polkit"
        fi
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
        if [ "$stat_gestures" != "$up" ]; then
            libinput-gestures-setup start >/dev/null 2>&1 \
                && notify-send "Application started!" "$gestures"
        else
            libinput-gestures-setup stop >/dev/null 2>&1 \
                && notify-send "Application stopped!" "$gestures"
        fi
        ;;
    *Firewall)
        svc "ufw.service"
        ;;
    *VPN*)
        if [ "$stat_vpn" != "$up" ]; then
            $auth vpnc $vpn_name >/dev/null 2>&1 \
                && notify-send "VPN connected!" "$vpn_name"
        else
            $auth vpnc-disconnect >/dev/null 2>&1 \
                && notify-send "VPN disconnected!" "$vpn_name"
        fi
        ;;
    *Resolver)
        svc "systemd-resolved.service"
        ;;
    *Conky)
        conky.sh
        ;;
esac
