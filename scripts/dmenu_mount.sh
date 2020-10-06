#!/bin/sh

# path:       /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_mount.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/dmenu
# date:       2020-10-06T11:51:47+0200

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
        label="un-/mount »"
        menu="dmenu -l 9 -c -bw 2 -r -i"
        label_unmount="unmount »"
        menu_unmount="dmenu -l 5 -c -bw 2 -r -i"
        label_mount_remote="mount »"
        menu_mount_remote="dmenu -l 20 -c -bw 2 -r -i"
        label_mount_usb="mount »"
        menu_mount_usb="dmenu -l 5 -c -bw 2 -r -i"
        label_mount_image="mount »"
        menu_mount_image="dmenu -l 5 -c -bw 2 -r -i"
        label_mount_android="mount »"
        menu_mount_android="dmenu -l 5 -c -bw 2 -r -i"
        label_dvd_eject="eject »"
        menu_dvd_eject="dmenu -l 5 -c -bw 2 -r -i"
        ;;
    rofi_*)
        label=""
        menu="rofi -m -1 -l 3 -columns 3 -theme klassiker-center -dmenu -i"
        label_unmount="⏏️"
        menu_unmount="rofi -m -1 -l 2 -columns 3 -theme klassiker-center -dmenu -i"
        label_mount_remote=""
        menu_mount_remote="rofi -m -1 -l 4 -columns 4 -theme klassiker-center -dmenu -i"
        label_mount_usb=""
        menu_mount_usb="rofi -m -1 -l 2 -columns 3 -theme klassiker-center -dmenu -i"
        label_mount_image=""
        menu_mount_image="rofi -m -1 -l 2 -columns 3 -theme klassiker-center -dmenu -i"
        label_mount_android=""
        menu_mount_android="rofi -m -1 -l 2 -columns 3 -theme klassiker-center -dmenu -i"
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
unmount() {
    select=$(awk '/\/mnt\/.*/ {print $2}' /proc/self/mounts \
        | sort \
        | $menu_unmount -p "$label_unmount" \
    )

    [ -z "$select" ] \
        && exit 1

    $auth umount "$select" \
        && notify-send "unmount" "$select unmounted" \
        && rm -d "$select"
}

# remote mount
mount_remote() {
    remote_config="
        # devices
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
        | $menu_mount_remote -p "$label_mount_remote" \
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
        & notify-send "remote mount" "$select mounted to $mount_point"
}

# mount usb
mount_usb() {
    select="$(lsblk -rpo "name,type,size,mountpoint" \
        | awk '{ if ($2=="part"&&$4=="" || $2=="rom"&&$4=="" || $3=="1,4M"&&$4=="") printf "%s (%s)\n",$1,$3}' \
        | $menu_mount_usb -p "$label_mount_usb" \
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
                && notify-send "usb mount $partition_type" "$select mounted to $mount_point"
                ;;
            *)
                $auth mount "$select" "$mount_point" \
                && notify-send "usb mount $partition_type" "$select mounted to $mount_point"

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
        | $menu_mount_image -p "$label_mount_image" \
    )

    [ -z "$select" ] \
        && exit 1

    mount_point="/mnt/$select"

    [ ! -d "$mount_point" ] \
        && mkdir "$mount_point" \
        && $auth mount -o loop "$search/$select" "$mount_point" \
        && notify-send "image mount" "$select mounted to $mount_point"
}

# mount android
mount_android() {
    select=$(simple-mtpfs -l 2>/dev/null \
        | $menu_mount_android -p "$label_mount_android" \
        | cut -d : -f 1 \
    )

    [ -z "$select" ] \
        && exit 1

    mount_point="/mnt/$select"

    [ ! -d "$mount_point" ] \
        && mkdir "$mount_point" \
        && simple-mtpfs --device "$select" "$mount_point" \
        && notify-send "android mount" "$select mounted to $mount_point"
}

# dvd eject
dvd_eject() {
    mounts=$(lsblk -nrpo "name,type,size,mountpoint" \
        | awk '$2=="rom"{printf "%s (%s)\n",$1,$3}' \
    )

    select=$(printf "%s\n" "$mounts" \
        | $menu_dvd_eject -p "$label_dvd_eject" \
        | awk '{print $1}' \
    )

    [ -z "$select" ] \
        && exit 1

    $auth eject "$select" \
        && notify-send "dvd eject" "$select ejected"
}

# menu
case $(printf "%s\n" \
    "unmount" \
    "mount remote" \
    "mount usb" \
    "mount image" \
    "mount android" \
    "eject dvd" \
    | $menu -p "$label" \
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
