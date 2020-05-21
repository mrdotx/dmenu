#!/bin/sh

# path:       /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_virtualbox.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/dmenu
# date:       2020-05-21T11:22:10+0200

sel=$(VBoxManage list vms | cut -d ' ' -f1 | sed 's/\"//g' | dmenu -l 10 -c -bw 2 -r -i -p "vm:")

[ -n "$sel" ] || exit

notify-send "virtualbox" "starting $sel"

VBoxManage startvm "$sel" >/dev/null 2>&1
