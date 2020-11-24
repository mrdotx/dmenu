#!/bin/sh

# path:       /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_vim.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/dmenu
# date:       2020-11-24T14:12:16+0100

script=$(basename "$0")
help="$script [-h/--help] -- script to start vim with a few shortcuts
                            for local/remote locations/files
  Usage:
    depending on how the script is named,
    it will be executed either with dmenu or with rofi

  Examples:
    dmenu_vim.sh
    rofi_vim.sh"

if [ "$1" = "-h" ] \
    || [ "$1" = "--help" ]; then
        printf "%s\n" "$help"
        exit 0
fi

case $script in
    dmenu_*)
        label="vim »"
        menu="dmenu -l 9 -c -bw 2 -r -i"
        ;;
    rofi_*)
        label=""
        menu="rofi -m -1 -l 5 -columns 2 -theme klassiker-center -dmenu -i"
        ;;
    *)
        printf "%s\n" "$help"
        exit 1
        ;;
esac

open() {
    $TERMINAL -e vim "$1"://"$2"/ -c ":call NetrwToggle()"
}

netrc() {
    gpg -d -o "$HOME/.netrc" "$HOME/.local/share/cloud/webde/.keys/netrc.gpg" \
        && chmod 600 "$HOME/.netrc" \
        && open "$1" "$2" \
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
