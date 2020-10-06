#!/bin/sh

# path:       /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_vim.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/dmenu
# date:       2020-10-06T11:49:56+0200

script=$(basename "$0")
help="$script [-h/--help] -- script to start vim with a few shortcuts
                            for local/remote locations/files
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
    $TERMINAL -e vim "$1"://"$2"/ -c ":call ToggleNetrw()"
}

netrc() {
    gpg -o "$HOME/.netrc" "$HOME/.local/share/cloud/webde/Keys/netrc.gpg" \
        && chmod 600 "$HOME/.netrc" \
        && openssh "$1" "$2" \
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
        openssh "scp" "middlefinger"
        ;;
    "prinzipal-kreuzberg.com")
        openssh "scp" "prinzipal"
        ;;
    "klassiker.online.de")
        netrc "ftp" "klassiker.online.de"
        ;;
    "marcusreith.de")
        netrc "ftp" "marcusreith.de"
        ;;
    "pi")
        openssh "scp" "hermes"
        ;;
    "pi2")
        openssh "scp" "prometheus"
        ;;
esac
