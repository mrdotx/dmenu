#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_password.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2021-06-08T17:39:55+0200

password_store="${PASSWORD_STORE_DIR-~/.password-store}"
file_type=".gpg"

select=$( \
    find "$password_store" -iname "*$file_type" -printf "%P\n" \
        | sed "s/$file_type$//" \
        | sort \
        | dmenu -l 20 -c -bw 2 -r -i -p "password entry »" \
)

[ -n "$select" ] || exit 0

entry=$(gpg --quiet --decrypt "$password_store/$select$file_type")

get_username() {
    printf "%s\n" "$entry" \
        | grep "^username:" \
        | sed 's/^username://; s/^[ \t]*//; s/[ \t]*$//'
}

get_password() {
    printf "%s\n" "$entry" \
        | head -n 1
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
        get_username \
            | xdotool type --clearmodifiers --file -
        xdotool key Tab
        get_password \
            | xdotool type --clearmodifiers --file -
        ;;
    "2) type username")
        get_username \
            | xdotool type --clearmodifiers --file -
        ;;
    "3) type password")
        get_password \
            | xdotool type --clearmodifiers --file -
        ;;
    "4) copy username")
        get_username \
            | xsel --input --selectionTimeout 60000 --clipboard
        ;;
    "5) copy password")
        get_password \
            | xsel --input --selectionTimeout 45000 --clipboard
        ;;
    *)
        exit 0
        ;;
esac
