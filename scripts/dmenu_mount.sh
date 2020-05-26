#!/bin/sh

# path:       /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_mount.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/dmenu
# date:       2020-05-26T01:31:09+0200

script=$(basename "$0")
help="$script [-h/--help] -- script to un-/mount remote, usb and android
                                locations/devices
  Usage:
    depending on how the script is named,
    it will be executed either with dmenu or with rofi

  Examples:
    dmenu_mount.sh
    rofi_mount.sh"

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    printf "%s\n" "$help"
    exit 0
fi

case $script in
    dmenu_*)
        label="un-/mount:"
        menu="dmenu -l 9 -c -bw 2 -r -i"
        label_unmnt="unmount:"
        menu_unmnt="dmenu -l 5 -c -bw 2 -r -i"
        label_rmt_mnt="mount:"
        menu_rmt_mnt="dmenu -l 20 -c -bw 2 -r -i"
        label_usb_mnt="mount:"
        menu_usb_mnt="dmenu -l 5 -c -bw 2 -r -i"
        label_iso_mnt="mount:"
        menu_iso_mnt="dmenu -l 5 -c -bw 2 -r -i"
        label_adr_mnt="mount:"
        menu_adr_mnt="dmenu -l 5 -c -bw 2 -r -i"
        label_dvd_eject="eject:"
        menu_dvd_eject="dmenu -l 5 -c -bw 2 -r -i"
        ;;
    rofi_*)
        label=""
        menu="rofi -m -1 -l 3 -columns 3 -theme klassiker-center -dmenu -i"
        label_unmnt="⏏️"
        menu_unmnt="rofi -m -1 -l 2 -columns 3 -theme klassiker-center -dmenu -i"
        label_rmt_mnt=""
        menu_rmt_mnt="rofi -m -1 -l 4 -columns 4 -theme klassiker-center -dmenu -i"
        label_usb_mnt=""
        menu_usb_mnt="rofi -m -1 -l 2 -columns 3 -theme klassiker-center -dmenu -i"
        label_iso_mnt=""
        menu_iso_mnt="rofi -m -1 -l 2 -columns 3 -theme klassiker-center -dmenu -i"
        label_adr_mnt=""
        menu_adr_mnt="rofi -m -1 -l 2 -columns 3 -theme klassiker-center -dmenu -i"
        label_dvd_eject="⏏️"
        menu_dvd_eject="rofi -m -1 -l 2 -columns 3 -theme klassiker-center -dmenu -i"
        ;;
    *)
        printf "%s\n" "$help"
        exit 1
        ;;
esac

# auth can be something like sudo -A, doas -- or
# nothing, depending on configuration requirements
auth="doas --"

# unmount
unmnt() {
    sel=$(awk '/\/tmp\/media\/.*/ {print $2}' /proc/self/mounts \
        | grep -v "/tmp/media/disk1" \
        | sort \
        | $menu_unmnt -p "$label_unmnt" \
    )

    [ -z "$sel" ] && exit 1

    $auth umount "$sel" \
        && notify-send "unmount" "$sel unmounted" \
        && rm -d "$sel"
}

# remote mount
rmt_mnt() {
    rmt_cfg="
        # devices
        pi;             /home/alarm
        pi2;            /home/alarm
        firetv;         /storage/emulated/0
        firetv4k;       /storage/emulated/0
        p9;             /storage/1B0C-F276
        m3;             /storage/7EB3-34D3

        # websites
        middlefinger;   /
        prinzipal;      /
        klassiker;      /
        marcus;         /

        # storage
        webde;          /
        dropbox;        /
        gmx;            /
        googledrive;    /
        onedrive;       /
    "

    sel=$(printf "%s" "$rmt_cfg" \
        | grep -v -e "#" -e "^\s*$" \
        | cut -d ";" -f1 \
        | tr -d ' ' \
        | $menu_rmt_mnt -p "$label_rmt_mnt" \
    )

    [ -z "$sel" ] && exit 1

    rmt_dir=$(printf "%s" "$rmt_cfg" \
        | grep "$sel;" \
        | cut -d ";" -f2 \
        | tr -d ' ' \
    )

    rcl_mnt=/tmp/media/$sel

    [ ! -d "$rcl_mnt" ] && mkdir "$rcl_mnt" \
        && sleep 1 && rclone mount "$sel:$rmt_dir" "$rcl_mnt" \
        & notify-send "remote mount" "$sel mounted to $rcl_mnt"
}

# usb mount
usb_mnt() {
    sel="$(lsblk -rpo "name,type,size,mountpoint" \
        | awk '{ if ($2=="part"&&$4=="" || $2=="rom"&&$4=="" || $3=="1,4M"&&$4=="") printf "%s (%s)\n",$1,$3}' \
        | $menu_usb_mnt -p "$label_usb_mnt" \
        | awk '{print $1}')"

    [ -z "$sel" ] && exit 1

    mnt_point="/tmp/media/$(basename "$sel")"
    part_typ="$(lsblk -no "fstype" "$sel")"

    [ ! -d "$mnt_point" ] && mkdir "$mnt_point" && case "$part_typ" in
    "vfat") $auth mount -t vfat "$sel" "$mnt_point" -o rw,umask=0000 \
        && notify-send "usb mount $part_typ" "$sel mounted to $mnt_point" ;;
    *)
        $auth mount "$sel" "$mnt_point" \
            && notify-send "usb mount $part_typ" "$sel mounted to $mnt_point"

        user="$(whoami)"
        ug="$(groups | awk '{print $1}')"
        $auth chown "$user":"$ug" 741 "$mnt_point"
        ;;
    esac
}

# iso mount
iso_mnt() {
    sel=$(find /tmp/media/disk1/downloads -type f -iname "*.iso" \
        | cut -d / -f 6 \
        | sed "s/.iso//g" \
        | sort \
        | $menu_iso_mnt -p "$label_iso_mnt" \
    )

    [ -z "$sel" ] && exit 1

    mnt_point="/tmp/media/$sel"

    [ ! -d "$mnt_point" ] && mkdir "$mnt_point" \
        && $auth mount -o loop "/tmp/media/disk1/downloads/$sel.iso" "$mnt_point" \
        && notify-send "iso mount" "$sel mounted to $mnt_point"
}

# android mount
adr_mnt() {
    sel=$(simple-mtpfs -l 2>/dev/null \
        | $menu_adr_mnt -p "$label_adr_mnt" \
        | cut -d : -f 1 \
    )

    [ -z "$sel" ] && exit 1

    mnt_point="/tmp/media/$sel"

    [ ! -d "$mnt_point" ] && mkdir "$mnt_point" \
        && simple-mtpfs --device "$sel" "$mnt_point" \
        && notify-send "android mount" "$sel mounted to $mnt_point"
}

# dvd eject
dvd_eject() {
    mounts=$(lsblk -nrpo "name,type,size,mountpoint" \
        | awk '$2=="rom"{printf "%s (%s)\n",$1,$3}' \
    )

    sel=$(printf "%s\n" "$mounts" \
        | $menu_dvd_eject -p "$label_dvd_eject" \
        | awk '{print $1}' \
    )

    [ -z "$sel" ] && exit 1

    $auth eject "$sel" \
        && notify-send "dvd eject" "$sel ejected"
}

# menu
case $(printf "%s\n" \
    "unmount" \
    "mount remote" \
    "mount usb" \
    "mount iso" \
    "mount android" \
    "eject dvd" \
    | $menu -p "$label" \
    ) in
    unmount)
        unmnt
        ;;
    mount?remote)
        rmt_mnt
        ;;
    mount?usb)
        usb_mnt
        ;;
    mount?iso)
        iso_mnt
        ;;
    mount?android)
        adr_mnt
        ;;
    eject?dvd)
        dvd_eject
        ;;
esac
