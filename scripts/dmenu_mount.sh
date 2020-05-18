#!/bin/sh

# path:       /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_mount.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/dmenu
# date:       2020-05-18T20:17:23+0200

# auth can be something like sudo -A, doas -- or
# nothing, depending on configuration requirements
auth="doas --"

# remote mount
remote_mnt() {
    rcl() {
        rcl_host=$1
        rcl_mnt=/tmp/media/$rcl_host
        rmt_dir=$2
        [ ! -d "$rcl_mnt" ] && mkdir "$rcl_mnt" \
            && sleep 1 && rclone mount "$rcl_host:$rmt_dir" "$rcl_mnt" \
            & notify-send "Remote Mount" "$rcl_host mounted to $rcl_mnt"
        }

    case $(printf "%s\n" \
        "dropbox" \
        "firetv" \
        "firetv4k" \
        "gmx" \
        "googledrive" \
        "klassiker" \
        "m3" \
        "marcus" \
        "middlefinger" \
        "p9" \
        "pi" \
        "pi2" \
        "prinzipal" \
        "web.de" | dmenu -l 14 -c -bw 2 -r -i -p "mount:") in
        dropbox)
            rcl "dropbox" "/"
            ;;
        firetv)
            rcl "firetv" "/storage/emulated/0"
            ;;
        firetv4k)
            rcl "firetv4k" "/storage/emulated/0"
            ;;
        gmx)
            rcl "gmx" "/"
            ;;
        googledrive)
            rcl "googledrive" "/"
            ;;
        klassiker)
            rcl "klassiker" "/"
            ;;
        m3)
            rcl "m3" "/storage/7EB3-34D3"
            ;;
        marcus)
            rcl "marcus" "/"
            ;;
        middlefinger)
            rcl "middlefinger" "/"
            ;;
        p9)
            rcl "p9" "/storage/1B0C-F276"
            ;;
        pi)
            rcl "pi" "/home/alarm"
            ;;
        pi2)
            rcl "pi2" "/home/alarm"
            ;;
        prinzipal)
            rcl "prinzipal" "/"
            ;;
        web.de)
            rcl "webde" "/"
            ;;
    esac
}

# remote unmount
remote_unmnt() {
    if grep -E "/tmp/media/.*fuse" /etc/mtab; then
        chosen=$(awk '/\/tmp\/media\/.*fuse/ {print $2}' /etc/mtab | sort | dmenu -l 5 -c -bw 2 -r -i -p "unmount:")
        [ -z "$chosen" ] && exit
        fusermount -u "$chosen" \
            && notify-send "Remote Unmount" "$chosen unmounted"
    else
        exit
    fi
}

# usb mount
usb_mnt() {
    chosen="$(lsblk -rpo "name,type,size,mountpoint" | awk '{ if ($2=="part"&&$4=="" || $2=="rom"&&$4=="" || $3=="1,4M"&&$4=="") printf "%s (%s)\n",$1,$3}' | dmenu -l 5 -c -bw 2 -r -i -p "mount:" | awk '{print $1}')"
    [ -z "$chosen" ] && exit
    mnt_point="/tmp/media/$(basename "$chosen")"
    part_typ="$(lsblk -no "fstype" "$chosen")"
    [ ! -d "$mnt_point" ] && mkdir "$mnt_point" && case "$part_typ" in
    "vfat") $auth mount -t vfat "$chosen" "$mnt_point" -o rw,umask=0000 \
        && notify-send "USB Mount $part_typ" "$chosen mounted to $mnt_point" ;;
    *)
        $auth mount "$chosen" "$mnt_point" \
            && notify-send "USB Mount $part_typ" "$chosen mounted to $mnt_point"
        user="$(whoami)"
        ug="$(groups | awk '{print $1}')"
        $auth chown "$user":"$ug" 741 "$mnt_point"
        ;;
    esac
}

# usb unmount
usb_unmnt() {
    mounts=$(lsblk -nrpo "name,type,size,mountpoint" | awk '{if ($2=="part"&&$4!~/\/boot|\/tmp\/media\/disk1|\/home$|SWAP/&&length($4)>1 || $2=="rom"&&length($4)>1 || $3=="1,4M"&&length($4)>1) printf "%s (%s)\n",$4,$3}')
    [ -z "$mounts" ] && exit
    chosen=$(printf "%s\n" "$mounts" | dmenu -l 5 -c -bw 2 -r -i -p "unmount:" | awk '{print $1}')
    [ -z "$chosen" ] && exit
    $auth umount "$chosen" \
        && notify-send "USB Unmount" "$chosen unmounted"
}

# iso mount
iso_mnt() {
    chosen=$(find /tmp/media/disk1/downloads -type f -iname "*.iso" | cut -d / -f 6 | sed "s/.iso//g" | sort | dmenu -l 5 -c -bw 2 -r -i -p "mount:")
    [ -z "$chosen" ] && exit
    mnt_point="/tmp/media/$chosen"
    [ ! -d "$mnt_point" ] && mkdir "$mnt_point" \
        && $auth mount -o loop "/tmp/media/disk1/downloads/$chosen.iso" "$mnt_point" \
        && notify-send "ISO Mount" "$chosen mounted to $mnt_point"
}

# iso unmount
iso_unmnt() {
    mounts=$(lsblk -npo "name,type,size,mountpoint" | awk '{if ($2=="loop") printf "%s (%s)\n",$4,$3}')
    [ -z "$mounts" ] && exit
    chosen=$(printf "%s\n" "$mounts" | dmenu -l 5 -c -bw 2 -r -i -p "unmount:" | awk '{print $1}')
    [ -z "$chosen" ] && exit
    $auth umount "$chosen" \
        && notify-send "ISO Unmount" "$chosen unmounted"
}

# android mount
android_mnt() {
    chosen=$(simple-mtpfs -l 2>/dev/null | dmenu -l 5 -c -bw 2 -r -i -p "mount:" | cut -d : -f 1)
    [ -z "$chosen" ] && exit
    mnt_point="/tmp/media/$chosen"
    [ ! -d "$mnt_point" ] && mkdir "$mnt_point" \
        && simple-mtpfs --device "$chosen" "$mnt_point" \
        && notify-send "Android Mount" "$chosen mounted to $mnt_point"
}

# android unmount
android_unmnt() {
    if grep simple-mtpfs /etc/mtab; then
        chosen=$(awk '/simple-mtpfs/ {print $2}' /etc/mtab | sort | dmenu -l 5 -c -bw 2 -r -i -p "unmount:")
        [ -z "$chosen" ] && exit
        fusermount -u "$chosen" \
            && notify-send "Android Unmount" "$chosen unmounted"
    else
        exit
    fi
}

# dvd eject
dvd_eject() {
    mounts=$(lsblk -nrpo "name,type,size,mountpoint" | awk '$2=="rom"{printf "%s (%s)\n",$1,$3}')
    [ -z "$mounts" ] && exit
    chosen=$(printf "%s\n" "$mounts" | dmenu -l 5 -c -bw 2 -r -i -p "eject:" | awk '{print $1}')
    [ -z "$chosen" ] && exit
    $auth eject "$chosen" \
        && notify-send "DVD Eject" "$chosen ejected"
}

# menu
case $(printf "%s\n" \
    "Remote Mount" \
    "Remote Unmount" \
    "USB Mount" \
    "USB Unmount" \
    "ISO Mount" \
    "ISO Unmount" \
    "Android Mount" \
    "Android Unmount" \
    "DVD Eject" | dmenu -l 9 -c -bw 2 -r -i -p "un-/mount:") in
    Remote?Mount)
        remote_mnt
        ;;
    Remote?Unmount)
        remote_unmnt
        ;;
    USB?Mount)
        usb_mnt
        ;;
    USB?Unmount)
        usb_unmnt
        ;;
    ISO?Mount)
        iso_mnt
        ;;
    ISO?Unmount)
        iso_unmnt
        ;;
    Android?Mount)
        android_mnt
        ;;
    Android?Unmount)
        android_unmnt
        ;;
    DVD?Eject)
        dvd_eject
        ;;
esac
