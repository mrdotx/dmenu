#!/bin/sh

# path:       /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_service.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/dmenu
# date:       2020-05-18T19:23:27+0200

# auth can be something like sudo -A, doas -- or
# nothing, depending on configuration requirements
auth="doas --"
polkit="/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1"
gestures="/usr/bin/libinput-gestures"
vpn_name="hades"

# app status
app_status() {
    [ "$(pgrep -f "$1")" ] \
        && printf "%s" " up " \
        || printf "%s" "down"
}

# systemd status
status() {
    [ "$(systemctl is-active "$1")" = "active" ] \
        && printf "%s" " up " \
        || printf "%s" "down"
}

# status
stat_polkit=$(app_status $polkit)
stat_printer=$(status org.cups.cupsd.service)
stat_avahi=$(status avahi-daemon.service)
stat_bluetooth=$(status bluetooth.service)
stat_gestures=$(app_status $gestures)
stat_firewall=$(status ufw.service)
stat_vpn=$(app_status "vpnc $vpn_name")
stat_resolver=$(status systemd-resolved.service)
stat_conky=$(app_status conky)

# systemd service
service() {
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
    "[$stat_conky] Conky" | dmenu -l 9 -c -bw 2 -r -i -p "service:") in
    *Polkit)
    if [ "$stat_polkit" != " up " ]; then
            $polkit >/dev/null 2>&1 &
            notify-send "Application started!" "$polkit"
        else
            killall $polkit >/dev/null 2>&1 \
                && notify-send "Application stopped!" "$polkit"
        fi
        ;;
    *Printer)
        service "org.cups.cupsd.service"
        ;;
    *Avahi)
        if [ "$stat_avahi" != " up " ]; then
            service "avahi-daemon.service"
        else
            service "avahi-daemon.service" >/dev/null 2>&1
            service "avahi-daemon.socket"
        fi
        ;;
    *Bluetooth)
        service "bluetooth.service"
        ;;
    *Gestures)
        if [ "$stat_gestures" != " up " ]; then
            libinput-gestures-setup start >/dev/null 2>&1 \
                && notify-send "Application started!" "$gestures"
        else
            libinput-gestures-setup stop >/dev/null 2>&1 \
                && notify-send "Application stopped!" "$gestures"
        fi
        ;;
    *Firewall)
        service "ufw.service"
        ;;
    *VPN*)
        if [ "$stat_vpn" != " up " ]; then
            $auth vpnc $vpn_name >/dev/null 2>&1 \
                && notify-send "VPN connected!" "$vpn_name"
        else
            $auth vpnc-disconnect >/dev/null 2>&1 \
                && notify-send "VPN disconnected!" "$vpn_name"
        fi
        ;;
    *Resolver)
        service "systemd-resolved.service"
        ;;
    *Conky)
        conky.sh
        ;;
esac
