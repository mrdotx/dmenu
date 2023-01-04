#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_virtualbox.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2023-01-04T13:13:58+0100

select=$(vboxmanage list vms \
    | cut -d '"' -f2 \
    | dmenu -l 10 -c -bw 1 -r -i -p "vm »" \
)

[ -n "$select" ] \
    && notify-send \
        -u low \
        "virtualbox" \
        "starting $select" \
    && vboxmanage startvm "$select" >/dev/null 2>&1
