#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_mount.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2022-07-13T09:18:33+0200

# auth can be something like sudo -A, doas -- or nothing,
# depending on configuration requirements
auth="${EXEC_AS_USER:-sudo}"

#config
mount_dir="/tmp"

unmount() {
    select=$(grep "/mnt\|$mount_dir/" /proc/self/mounts \
        | cut -d " " -f2 \
        | sort \
        | dmenu -l 5 -c -bw 1 -r -i -p "unmount »" \
    )

    [ -n "$select" ] \
        && $auth umount "$select" \
        && notify-send \
            -u low \
            "unmount" \
            "$select unmounted" \
        && rm -d "$select"
}

mount_remote() {
    remote_config="
        # cloud storage
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
        | dmenu -l 20 -c -bw 1 -r -i -p "mount »" \
    )

    [ -z "$select" ] \
        && exit 0

    remote_directory=$(printf "%s" "$remote_config" \
        | grep "$select;" \
        | cut -d ";" -f2 \
        | tr -d ' ' \
    )

    mount_point="$mount_dir/$select"

    [ ! -d "$mount_point" ] \
        && mkdir "$mount_point" \
        && sleep 1 \
        && rclone mount "$select:$remote_directory" "$mount_point" \
        & notify-send \
            -u low \
            "remote mount" \
            "$select mounted to $mount_point"
}

mount_usb() {
    select="$(lsblk -rpo "name,type,size,mountpoint" \
        | awk '{ if ($2=="part"&&$4=="" || $2=="rom"&&$4=="" || $3=="1,4M"&&$4=="") printf "%s (%s)\n",$1,$3}' \
        | dmenu -l 5 -c -bw 1 -r -i -p "mount »" \
        | cut -d " " -f1)"

    [ -z "$select" ] \
        && exit 0

    mount_point="$mount_dir/$(basename "$select")"
    partition_type="$(lsblk -no "fstype" "$select")"

    [ ! -d "$mount_point" ] \
        && mkdir "$mount_point" \
        && case "$partition_type" in
            vfat)
                $auth mount -t "$partition_type" "$select" "$mount_point" -o rw,umask=0000 \
                ;;
            exfat)
                $auth mount "$select" "$mount_point" -o rw,umask=0000 \
                ;;
            *)
                $auth mount "$select" "$mount_point"
                user="$(whoami)"
                user_group="$(groups | cut -d " " -f1)"
                $auth chown "$user":"$user_group" 741 "$mount_point"
                ;;
            esac \
        && notify-send \
            -u low \
            "usb mount $partition_type" \
            "$select mounted to $mount_point"
}

mount_image() {
    search="$HOME/Downloads"
    select=$(find "$search" -type f \
            -iname "*.iso" -o \
            -iname "*.img" -o \
            -iname "*.bin" -o \
            -iname "*.mdf" -o \
            -iname "*.nrg" \
        | cut -d / -f 5 \
        | dmenu -l 5 -c -bw 1 -r -i -p "mount »" \
    )

    [ -z "$select" ] \
        && exit 0

    mount_point="$mount_dir/$select"

    [ ! -d "$mount_point" ] \
        && mkdir "$mount_point" \
        && $auth mount -o loop "$search/$select" "$mount_point" \
        && notify-send \
            -u low \
            "image mount" \
            "$select mounted to $mount_point"
}

mount_android() {
    select=$(simple-mtpfs -l 2>/dev/null \
        | dmenu -l 5 -c -bw 1 -r -i -p "mount »" \
        | cut -d ":" -f1 \
    )

    [ -z "$select" ] \
        && exit 0

    mount_point="$mount_dir/$select"

    [ ! -d "$mount_point" ] \
        && mkdir "$mount_point" \
        && simple-mtpfs --device "$select" "$mount_point" \
        && notify-send \
            -u low \
            "android mount" \
            "$select mounted to $mount_point"
}

dvd_eject() {
    mounts=$(lsblk -nrpo "name,type,size,mountpoint" \
        | awk '$2=="rom"{printf "%s (%s)\n",$1,$3}' \
    )

    select=$(printf "%s\n" "$mounts" \
        | dmenu -l 5 -c -bw 1 -r -i -p "eject »" \
        | cut -d " " -f1 \
    )

    [ -z "$select" ] \
        && $auth eject "$select" \
        && notify-send \
            -u low \
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
    | dmenu -l 9 -c -bw 1 -r -i -p "un-/mount »" \
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
