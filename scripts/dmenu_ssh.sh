#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_ssh.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2021-07-17T18:08:20+0200

# config
ssh_config="$HOME/.ssh/config"
edit="$TERMINAL -e $EDITOR"

select=$(printf "%s\n" \
    "== edit config ==" \
    "$(grep "^Host " "$ssh_config" \
        | cut -d ' ' -f2)" \
    | dmenu -p "ssh »")

case "$select" in
    "== edit config ==")
        $edit "$ssh_config"
        ;;
    *)
        for host in $select; do
            $TERMINAL -T "ssh $host" -e ssh "$host" &
        done
        ;;
esac
