#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_vim.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2021-06-07T08:06:42+0200

open() {
    $TERMINAL -e vim "$1"://"$2"/ -c ":call NetrwToggle()"
}

netrc() {
    gpg -d -o "$HOME/.netrc" "$HOME/.local/share/cloud/webde/.keys/netrc.asc" \
        && chmod 600 "$HOME/.netrc" \
        && open "$1" "$2" \
        && sleep 2 \
        && rm -f "$HOME/.netrc"
}

# menu for vim shortcuts
case $(printf "%s\n" \
    "== ideas ==" \
    "== notes ==" \
    "==  new  ==" \
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
    "==  new  ==")
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
        netrc "ftp" "klassiker.online.de"
        ;;
    "marcus")
        netrc "ftp" "marcusreith.de"
        ;;
esac
