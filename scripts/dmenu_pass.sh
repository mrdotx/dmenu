#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_pass.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2021-06-11T07:35:11+0200

password_store="${PASSWORD_STORE_DIR-~/.password-store}"
file_type=".gpg"

select=$( \
    find "$password_store" -iname "*$file_type" -printf "%P\n" \
        | sed "s/$file_type$//" \
        | sort \
        | dmenu -l 20 -c -bw 2 -r -i -p "password entry »" \
)

[ -n "$select" ] \
    || exit 0

get_entry() {
    entry=$(gpg --quiet --decrypt "$password_store/$select$file_type")

    username() {
        printf "%s\n" "$entry" \
            | grep "^username:" \
            | sed 's/^username://; s/^[ \t]*//; s/[ \t]*$//'
    }

    password() {
        printf "%s\n" "$entry" \
            | head -n 1
    }

    case "$1" in
        type)
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
    "1) type username and password" \
    "2) type username" \
    "3) type password" \
    "4) copy username" \
    "5) copy password" \
    | dmenu -l 5 -c -bw 2 -r -i -p "$select »" \
    ) in
    "1) type username and password")
        get_entry "type" "username"
        xdotool key Tab
        get_entry "type" "password"
        ;;
    "2) type username")
        get_entry "type" "username"
        ;;
    "3) type password")
        get_entry "type" "password"
        ;;
    "4) copy username")
        get_entry "copy" "username"
        ;;
    "5) copy password")
        get_entry "copy" "password"
        ;;
    *)
        exit 0
        ;;
esac
