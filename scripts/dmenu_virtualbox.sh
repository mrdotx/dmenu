#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_virtualbox.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2022-06-21T20:35:38+0200

select=$(VBoxManage list vms \
    | cut -d '"' -f2 \
    | dmenu -l 5 -c -bw 1 -r -i -p "vm »" \
)

[ -n "$select" ] \
    && notify-send \
        -u low \
        "virtualbox" \
        "starting $select" \
    && VBoxManage startvm "$select" >/dev/null 2>&1
