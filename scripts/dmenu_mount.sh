#!/bin/sh

# path:       /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_mount.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/dmenu
# date:       2020-05-23T19:28:14+0200

# auth can be something like sudo -A, doas -- or
# nothing, depending on configuration requirements
auth="doas --"

# unmount
unmnt() {
    sel=$(awk '/\/tmp\/media\/.*/ {print $2}' /proc/self/mounts \
        | grep -v "/tmp/media/disk1" \
        | sort \
        | dmenu -l 5 -c -bw 2 -r -i -p "unmount:" \
    )

    [ -z "$sel" ] && exit

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
        | dmenu -l 20 -c -bw 2 -r -i -p "mount:" \
    )

    [ -z "$sel" ] && exit

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
        | dmenu -l 5 -c -bw 2 -r -i -p "mount:" \
        | awk '{print $1}')"

    [ -z "$sel" ] && exit

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
        | dmenu -l 5 -c -bw 2 -r -i -p "mount:" \
    )

    [ -z "$sel" ] && exit

    mnt_point="/tmp/media/$sel"

    [ ! -d "$mnt_point" ] && mkdir "$mnt_point" \
        && $auth mount -o loop "/tmp/media/disk1/downloads/$sel.iso" "$mnt_point" \
        && notify-send "iso mount" "$sel mounted to $mnt_point"
}

# android mount
adr_mnt() {
    sel=$(simple-mtpfs -l 2>/dev/null \
        | dmenu -l 5 -c -bw 2 -r -i -p "mount:" \
        | cut -d : -f 1 \
    )

    [ -z "$sel" ] && exit

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

    [ -z "$mounts" ] && exit

    sel=$(printf "%s\n" "$mounts" \
        | dmenu -l 5 -c -bw 2 -r -i -p "eject:" \
        | awk '{print $1}' \
    )

    [ -z "$sel" ] && exit

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
    | dmenu -l 9 -c -bw 2 -r -i -p "un-/mount:" \
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
