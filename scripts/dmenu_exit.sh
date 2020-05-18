#!/bin/sh

# path:       /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_exit.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/dmenu
# date:       2020-05-18T19:23:14+0200

# menu for knockout script
case $(printf "%s\n" \
    "lock blur" \
    "lock simple" \
    "suspend" \
    "suspend blur" \
    "suspend simple" \
    "logout" \
    "reboot" \
    "shutdown" | dmenu -m 0 -l 8 -c -bw 2 -r -i -p "exit:") in
    lock?blur)
        i3_knockout.sh -lock blur
        ;;
    lock?simple)
        i3_knockout.sh -lock simple
        ;;
    suspend)
        i3_knockout.sh -suspend
        ;;
    suspend?blur)
        i3_knockout.sh -suspend blur
        ;;
    suspend?simple)
        i3_knockout.sh -suspend simple
        ;;
    logout)
        i3_knockout.sh -logout
        ;;
    reboot)
        i3_knockout.sh -reboot
        ;;
    shutdown)
        i3_knockout.sh -shutdown
        ;;
esac
