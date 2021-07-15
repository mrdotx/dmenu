#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_vim.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2021-07-15T17:57:14+0200

open() {
    $TERMINAL -e vim "$1://$2/" -c ":call NetrwToggle()"
}

# menu for vim shortcuts
case $(printf "%s\n" \
    "== ideas ==" \
    "== notes ==" \
    "== new ==" \
    "pi" \
    "pi2" \
    "middlefinger" \
    "prinzipal" \
    "klassiker" \
    "marcus" \
    | dmenu -l 9 -c -bw 2 -r -i -p "vim »" \
    ) in
    "== ideas ==")
        $TERMINAL -e vim -c ":VimwikiIndex" -c ":VimwikiGoto ideas"
        ;;
    "== notes ==")
        $TERMINAL -e vim -c ":VimwikiIndex"
        ;;
    "== new ==")
        $TERMINAL -e vim
        ;;
    "pi")
        open "scp" "hermes"
        ;;
    "pi2")
        open "scp" "prometheus"
        ;;
    "middlefinger")
        open "scp" "middlefinger"
        ;;
    "prinzipal")
        open "scp" "prinzipal"
        ;;
    "klassiker")
        open "ftp" "klassiker.online.de"
        ;;
    "marcus")
        open "ftp" "marcusreith.de"
        ;;
esac
