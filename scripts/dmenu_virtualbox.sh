#!/bin/sh

# path:       /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_virtualbox.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/dmenu
# date:       2020-05-19T22:44:30+0200

chosen=$(VBoxManage list vms | cut -d ' ' -f1 | sed 's/\"//g' | dmenu -l 10 -c -bw 2 -r -i -p "vm:")
[ -n "$chosen" ] || exit

notify-send "virtualbox" "starting $chosen"

VBoxManage startvm "$chosen" >/dev/null 2>&1
