#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_mount.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2021-01-15T13:32:50+0100

# auth can be something like sudo -A, doas -- or
# nothing, depending on configuration requirements
auth="doas"

# unmount
unmount() {
    select=$(awk '/\/mnt\/.*/ {print $2}' /proc/self/mounts \
        | sort \
        | dmenu -l 5 -c -bw 2 -r -i -p "unmount »" \
    )

    [ -z "$select" ] \
        && exit 1

    $auth umount "$select" \
        && notify-send \
            "unmount" \
            "$select unmounted" \
        && rm -d "$select"
}

# remote mount
mount_remote() {
    remote_config="
        # device        directory
        pi;             /home/alarm
        pi2;            /home/alarm
        p9;             /storage/1B0C-F276
        m3;             /storage/7EB3-34D3
        firetv;         /storage/emulated/0
        firetv4k;       /storage/emulated/0

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

    select=$(printf "%s" "$remote_config" \
        | grep -v -e "#" -e "^\s*$" \
        | cut -d ";" -f1 \
        | tr -d ' ' \
        | dmenu -l 20 -c -bw 2 -r -i -p "mount »" \
    )

    [ -z "$select" ] \
        && exit 1

    remote_directory=$(printf "%s" "$remote_config" \
        | grep "$select;" \
        | cut -d ";" -f2 \
        | tr -d ' ' \
    )

    mount_point=/mnt/$select

    [ ! -d "$mount_point" ] \
        && mkdir "$mount_point" \
        && sleep 1 && rclone mount "$select:$remote_directory" "$mount_point" \
        & notify-send \
            "remote mount" \
            "$select mounted to $mount_point"
}

# mount usb
mount_usb() {
    select="$(lsblk -rpo "name,type,size,mountpoint" \
        | awk '{ if ($2=="part"&&$4=="" || $2=="rom"&&$4=="" || $3=="1,4M"&&$4=="") printf "%s (%s)\n",$1,$3}' \
        | dmenu -l 5 -c -bw 2 -r -i -p "mount »" \
        | awk '{print $1}')"

    [ -z "$select" ] \
        && exit 1

    mount_point="/mnt/$(basename "$select")"
    partition_type="$(lsblk -no "fstype" "$select")"

    [ ! -d "$mount_point" ] \
        && mkdir "$mount_point" \
        && case "$partition_type" in
            "vfat")
                $auth mount -t vfat "$select" "$mount_point" -o rw,umask=0000 \
                && notify-send \
                    "usb mount $partition_type" \
                    "$select mounted to $mount_point"
                ;;
            *)
                $auth mount "$select" "$mount_point" \
                && notify-send \
                    "usb mount $partition_type" \
                    "$select mounted to $mount_point"

                user="$(whoami)"
                user_group="$(groups | awk '{print $1}')"
                $auth chown "$user":"$user_group" 741 "$mount_point"
                ;;
    esac
}

# mount image
mount_image() {
    search="$HOME/Downloads"
    select=$(find "$search" -type f \
            -iname "*.iso" -o \
            -iname "*.img" -o \
            -iname "*.bin" -o \
            -iname "*.mdf" -o \
            -iname "*.nrg" \
        | cut -d / -f 5 \
        | dmenu -l 5 -c -bw 2 -r -i -p "mount »" \
    )

    [ -z "$select" ] \
        && exit 1

    mount_point="/mnt/$select"

    [ ! -d "$mount_point" ] \
        && mkdir "$mount_point" \
        && $auth mount -o loop "$search/$select" "$mount_point" \
        && notify-send \
            "image mount" \
            "$select mounted to $mount_point"
}

# mount android
mount_android() {
    select=$(simple-mtpfs -l 2>/dev/null \
        | dmenu -l 5 -c -bw 2 -r -i -p "mount »" \
        | cut -d : -f 1 \
    )

    [ -z "$select" ] \
        && exit 1

    mount_point="/mnt/$select"

    [ ! -d "$mount_point" ] \
        && mkdir "$mount_point" \
        && simple-mtpfs --device "$select" "$mount_point" \
        && notify-send \
            "android mount" \
            "$select mounted to $mount_point"
}

# dvd eject
dvd_eject() {
    mounts=$(lsblk -nrpo "name,type,size,mountpoint" \
        | awk '$2=="rom"{printf "%s (%s)\n",$1,$3}' \
    )

    select=$(printf "%s\n" "$mounts" \
        | dmenu -l 5 -c -bw 2 -r -i -p "eject »" \
        | awk '{print $1}' \
    )

    [ -z "$select" ] \
        && exit 1

    $auth eject "$select" \
        && notify-send \
            "dvd eject" \
            "$select ejected"
}

# menu
case $(printf "%s\n" \
    "unmount" \
    "mount remote" \
    "mount usb" \
    "mount image" \
    "mount android" \
    "eject dvd" \
    | dmenu -l 9 -c -bw 2 -r -i -p "un-/mount »" \
    ) in
    "unmount")
        unmount
        ;;
    "mount remote")
        mount_remote
        ;;
    "mount usb")
        mount_usb
        ;;
    "mount image")
        mount_image
        ;;
    "mount android")
        mount_android
        ;;
    "eject dvd")
        dvd_eject
        ;;
esac
