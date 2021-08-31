#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_ssh.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2021-08-31T18:45:27+0200

# config
ssh_config="$HOME/.ssh/config"
edit="$TERMINAL -e $EDITOR"

select=$(printf "%s\n" \
    "$(grep "^Host " "$ssh_config" \
        | cut -d ' ' -f2)" \
    "== edit config ==" \
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
