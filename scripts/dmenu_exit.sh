#!/bin/sh

# path:       /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_exit.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/dmenu
# date:       2020-05-19T12:45:56+0200

# menu for knockout script
case $(printf "%s\n" \
    "lock [simple]" \
    "suspend [simple]" \
    "lock [blur]" \
    "suspend [blur]" \
    "suspend" \
    "logout" \
    "reboot" \
    "shutdown" | dmenu -m 0 -l 8 -c -bw 2 -r -i -p "exit:") in
    lock?\[simple\])
        i3_knockout.sh -lock simple
        ;;
    suspend?\[simple\])
        i3_knockout.sh -suspend simple
        ;;
    lock?\[blur\])
        i3_knockout.sh -lock blur
        ;;
    suspend?\[blur\])
        i3_knockout.sh -suspend blur
        ;;
    suspend)
        i3_knockout.sh -suspend
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
