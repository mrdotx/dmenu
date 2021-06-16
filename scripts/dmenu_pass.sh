#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_pass.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2021-06-16T17:35:18+0200

password_store="${PASSWORD_STORE_DIR-~/.password-store}"
file_type=".gpg"

# get active window id
window_id=$(xprop -root \
    | awk '/_NET_ACTIVE_WINDOW\(WINDOW\)/{print $NF}' \
)

select=$( \
    find "$password_store" -iname "*$file_type" -printf "%P\n" \
        | sed "s/$file_type$//" \
        | sort \
        | dmenu -b -l 15 -r -i -w "$window_id" -p "pass »" \
)

[ -n "$select" ] \
    || exit 0

get_entry() {
    entry=$(gpg --quiet --decrypt "$password_store/$select$file_type")

    username() {
        printf "%s" "$entry" \
            | grep "^username:" \
            | sed 's/^username://; s/^[ \t]*//; s/[ \t]*$//'
    }

    password() {
        printf "%s" "$entry" \
            | head -n 1
    }

    case "$1" in
        type)
            # workaround for mismatched keyboard layouts
            setxkbmap -synch

            eval "$2" \
                | xdotool type --clearmodifiers --file -
            ;;
        copy)
            eval "$2" \
                | xsel --input --selectionTimeout 45000 --clipboard
            ;;
    esac
}

case $(printf "%s\n" \
    "1) type username, tab, password" \
    "2) type username, 2xtab, password" \
    "3) type username" \
    "4) type password" \
    "5) copy username" \
    "6) copy password" \
    | dmenu -b -l 6 -r -i -w "$window_id" -p "$select »" \
    ) in
    "1) type username, tab, password")
        get_entry "type" "username"
        xdotool key Tab
        get_entry "type" "password"
        ;;
    "2) type username, 2xtab, password")
        get_entry "type" "username"
        xdotool key Tab Tab
        get_entry "type" "password"
        ;;
    "3) type username")
        get_entry "type" "username"
        ;;
    "4) type password")
        get_entry "type" "password"
        ;;
    "5) copy username")
        get_entry "copy" "username"
        ;;
    "6) copy password")
        get_entry "copy" "password"
        ;;
    *)
        exit 0
        ;;
esac
