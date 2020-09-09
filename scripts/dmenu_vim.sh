#!/bin/sh

# path:       /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_vim.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/dmenu
# date:       2020-09-09T11:46:28+0200

script=$(basename "$0")
help="$script [-h/--help] -- script to start vim with a few shortcuts
  Usage:
    depending on how the script is named,
    it will be executed either with dmenu or with rofi

  Examples:
    dmenu_vim.sh
    rofi_vim.sh"

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    printf "%s\n" "$help"
    exit 0
fi

case $script in
    dmenu_*)
        label="vim »"
        menu="dmenu -l 11 -c -bw 2 -r -i"
        ;;
    rofi_*)
        label=""
        menu="rofi -m -1 -l 6 -columns 2 -theme klassiker-center -dmenu -i"
        ;;
    *)
        printf "%s\n" "$help"
        exit 1
        ;;
esac

openssh() {
    $TERMINAL -e vim scp://"$1"/ -c ":call ToggleNetrw()"
}

netrc() {
    remote=$1
    gpg -o "$HOME/.netrc" "$HOME/.local/share/cloud/webde/Keys/netrc.gpg" \
        && chmod 600 "$HOME/.netrc" \
        && $TERMINAL -e vim "$remote" -c ":call ToggleNetrw()" \
        && rm -f "$HOME/.netrc"
}

# menu for vim shortcuts
case $(printf "%s\n" \
    "== ideas ==" \
    "== notes ==" \
    "==  new  ==" \
    "middlefinger-streetwear.com" \
    "prinzipal-kreuzberg.com" \
    "klassiker.online.de" \
    "marcusreith.de" \
    "pi" \
    "pi2" \
    "p9" \
    "m3" \
    | $menu -p "$label" \
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
    "middlefinger-streetwear.com")
        openssh "middlefinger"
        ;;
    "prinzipal-kreuzberg.com")
        openssh "prinzipal"
        ;;
    "klassiker.online.de")
        netrc "ftp://klassiker.online.de/"
        ;;
    "marcusreith.de")
        netrc "ftp://marcusreith.de/"
        ;;
    "pi")
        openssh "hermes"
        ;;
    "pi2")
        openssh "prometheus"
        ;;
    "p9")
        openssh "p9"
        ;;
    "m3")
        openssh "m3"
        ;;
esac
