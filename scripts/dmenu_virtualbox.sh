#!/bin/sh

# path:       /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_virtualbox.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/dmenu
# date:       2020-12-17T22:25:35+0100

select=$(VBoxManage list vms \
    | cut -d '"' -f2 \
    | dmenu -l 5 -c -bw 2 -r -i -p "vm »" \
)

[ -z "$select" ] \
    && exit 1

notify-send \
    "virtualbox" \
    "starting $select"

VBoxManage startvm "$select" >/dev/null 2>&1
