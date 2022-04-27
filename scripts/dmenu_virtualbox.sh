#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_virtualbox.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2022-04-27T09:46:48+0200

select=$(VBoxManage list vms \
    | cut -d '"' -f2 \
    | dmenu -l 5 -c -bw 1 -r -i -p "vm »" \
)

[ -n "$select" ] \
    && notify-send \
        "virtualbox" \
        "starting $select" \
    && VBoxManage startvm "$select" >/dev/null 2>&1
