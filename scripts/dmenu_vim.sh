#!/bin/sh

# path:       /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_vim.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/dmenu
# date:       2020-05-18T19:23:58+0200

openssh() {
    $TERMINAL -e vim scp://"$1"/ -c ":call ToggleNetrw()"
}

netrc() {
    rmt_name=$1
    gpg -o "$HOME/.netrc" "$HOME/.local/share/cloud/webde/Keys/netrc.gpg" \
        && chmod 600 "$HOME/.netrc" \
        && $TERMINAL -e vim "$rmt_name" -c ":call ToggleNetrw()" \
        && rm -f "$HOME/.netrc"
}

# menu for vim shortcuts
case $(printf "%s\n" \
    "new" \
    "notes" \
    "middlefinger-streetwear.com" \
    "prinzipal-kreuzberg.com" \
    "klassiker.online.de" \
    "marcusreith.de" \
    "pi" \
    "pi2" \
    "p9" \
    "m3" | dmenu -r -i -p "vim:") in
    new)
        $TERMINAL -e vim
        ;;
    notes)
        $TERMINAL -e vim -c ":VimwikiIndex"
        ;;
    middlefinger-streetwear.com)
        openssh "middlefinger"
        ;;
    prinzipal-kreuzberg.com)
        openssh "prinzipal"
        ;;
    klassiker.online.de)
        netrc "ftp://klassiker.online.de/"
        ;;
    marcusreith.de)
        netrc "ftp://marcusreith.de/"
        ;;
    pi)
        openssh "hermes"
        ;;
    pi2)
        openssh "prometheus"
        ;;
    p9)
        openssh "p9"
        ;;
    m3)
        openssh "m3"
        ;;
esac
