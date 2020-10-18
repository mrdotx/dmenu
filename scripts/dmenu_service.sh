#!/bin/sh

# path:       /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_service.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/dmenu
# date:       2020-10-18T11:14:13+0200

# auth can be something like sudo -A, doas -- or
# nothing, depending on configuration requirements
auth="doas"
vpn_name="hades"

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

# app status
app_status() {
    [ "$(pgrep -f "$1")" ] \
        && printf "%s" "$up" \
        || printf "%s" "$down"
}

# systemd user status
systemd_user_status() {
    [ "$(systemctl --user is-active "$1")" = "active" ] \
        && printf "%s" "$up" \
        || printf "%s" "$down"
}

# systemd status
systemd_status() {
    [ "$(systemctl is-active "$1")" = "active" ] \
        && printf "%s" "$up" \
        || printf "%s" "$down"
}

# status
status_polkit=$(systemd_user_status authentication.service)
status_printer=$(systemd_status org.cups.cupsd.service)
status_avahi=$(systemd_status avahi-daemon.service)
status_bluetooth=$(systemd_status bluetooth.service)
status_gestures=$(systemd_user_status gestures.service)
status_firewall=$(systemd_status ufw.service)
status_vpn=$(systemd_status vpnc@$vpn_name.service)
status_resolver=$(systemd_status systemd-resolved.service)
status_conky=$(app_status conky)

# toggle systemd user service
toggle_user_service() {
    if [ "$(systemctl --user is-active "$1")" != "active"  ]; then
        systemctl --user enable "$1" --now \
            && notify-send "Service started!" "$1"
    else
        systemctl --user disable "$1" --now \
            && notify-send "Service stopped!" "$1"
    fi
}

# toggle systemd service
toggle_service() {
    if [ "$(systemctl is-active "$1")" != "active"  ]; then
        $auth systemctl enable "$1" --now \
            && notify-send "Service started!" "$1"
    else
        $auth systemctl disable "$1" --now \
            && notify-send "Service stopped!" "$1"
    fi
}

# menu
case $(printf "%s\n" \
    "[$status_polkit] Polkit" \
    "[$status_printer] Printer" \
    "[$status_avahi] Avahi" \
    "[$status_bluetooth] Bluetooth" \
    "[$status_gestures] Gestures" \
    "[$status_firewall] Firewall" \
    "[$status_vpn] VPN $vpn_name" \
    "[$status_resolver] Resolver" \
    "[$status_conky] Conky" \
    | $menu -p "$label"\
    ) in
    *Polkit)
        toggle_user_service "authentication.service"
        ;;
    *Printer)
        toggle_service "org.cups.cupsd.service"
        ;;
    *Avahi)
        if [ "$status_avahi" != "$up" ]; then
            toggle_service "avahi-daemon.service"
        else
            toggle_service "avahi-daemon.service" >/dev/null 2>&1
            toggle_service "avahi-daemon.socket"
        fi
        ;;
    *Bluetooth)
        toggle_service "bluetooth.service"
        ;;
    *Gestures)
        toggle_user_service "gestures.service"
        ;;
    *Firewall)
        toggle_service "ufw.service"
        ;;
    *VPN*)
        toggle_service "vpnc@$vpn_name.service"
        ;;
    *Resolver)
        toggle_service "systemd-resolved.service"
        ;;
    *Conky)
        conky.sh
        ;;
esac
