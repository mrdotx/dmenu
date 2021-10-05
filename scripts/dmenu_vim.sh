#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_vim.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2021-10-05T18:44:50+0200

open() {
    $TERMINAL -e "$EDITOR" "$1://$2/" -c ":call NetrwToggle()"
}

case "$1" in
    --editor)
        $TERMINAL -e "$EDITOR"
        ;;
    *)
        # menu for editor shortcuts
        case $(printf "%s\n" \
            "== ideas ==" \
            "== notes ==" \
            "pi" \
            "pi2" \
            "middlefinger" \
            "prinzipal" \
            "klassiker" \
            "marcus" \
            | dmenu -l 9 -c -bw 2 -r -i -p "vim »" \
            ) in
            "== ideas ==")
                $TERMINAL -e "$EDITOR" -c ":VimwikiIndex" -c ":VimwikiGoto ideas"
                ;;
            "== notes ==")
                $TERMINAL -e "$EDITOR" -c ":VimwikiIndex"
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
        ;;
esac
