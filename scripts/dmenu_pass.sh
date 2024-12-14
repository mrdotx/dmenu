#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_pass.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2024-12-14T08:16:25+0100

# config
password_store="${PASSWORD_STORE_DIR:-$HOME/.password-store}"
file_type=".gpg"
edit="$TERMINAL -e ranger"
clipboard_timeout=45

select=$(printf "» generate password\n%s" \
    "$(find "$password_store" -iname "*$file_type" -printf "%P\n" \
        | sed "s/$file_type$//" \
        | sort)" \
        | dmenu -l 15 -c -bw 1 -r -i -p "pass »" \
)

[ -z "$select" ] \
    && exit 0

# helper functions
type_string() {
    printf "%s" "$1" \
        | xdotool type \
            --clearmodifiers \
            --file -
}

copy_string() {
    printf "%s" "$1" \
        | xsel \
            --input \
            --selectionTimeout "$((clipboard_timeout * 1000))" \
            --clipboard
}

check_password() {
    # check if at least 1 of each char type is available
    for char in [$2] [0-9] [A-Z] [a-z]; do
        printf "%s" "$1" \
            | grep -q "$char" \
                || return 1
    done
}

# data functions
generate_password() {
    chars=16
    symbols='!@#'

    while true; do
        password=$(printf "%s" \
            "$(tr -dc "[:alnum:]$symbols" < /dev/urandom \
                | head -c"$chars")" \
        )

        check_password "$password" "$symbols" \
            && printf "%s" "$password" \
            && break
    done
}

get_gpg_entry() {
    entry=$(gpg --quiet --decrypt "$password_store/$select$file_type")

    case "$1" in
        username)
            printf "%s" "$entry" \
                | grep "^username:" \
                | sed "s/^username://; s/^[ \t]*//; s/[ \t]*$//" \
                | tr -d "\n"
            ;;
        password)
            printf "%s" "$entry" \
                | head -n 1 \
                | tr -d "\n"
            ;;
    esac
}

# menu
case "$select" in
    "» generate password")
        case $(printf "%s\n" \
            "copy password ($clipboard_timeout sec)" \
            "type password" \
            | dmenu -l 2 -c -bw 1 -r -i -p "generate password »" \
            ) in
            "copy password"*)
                copy_string "$(generate_password)"
                ;;
            "type password"*)
                type_string "$(generate_password)"
                ;;
            *)
                exit 0
                ;;
        esac
        ;;
    *)
        case $(printf "%s\n" \
            "» edit saved settings" \
            "type [username] tab [password] enter" \
            "type [username] 2xtab [password] enter" \
            "type [username] enter [password] enter" \
            "type [username]" \
            "type [password]" \
            "copy [username] to clipboard ($clipboard_timeout sec)" \
            "copy [password] to clipboard ($clipboard_timeout sec)" \
            | dmenu -l 8 -c -bw 1 -r -i -p "$select »" \
            ) in
            "» edit saved settings")
                $edit "$password_store/$select$file_type"
                ;;
            "type [username] tab [password] enter"*)
                type_string "$(get_gpg_entry "username")" \
                    && xdotool key Tab \
                    && type_string "$(get_gpg_entry "password")" \
                    && xdotool key Return
                ;;
            "type [username] 2xtab [password] enter"*)
                type_string "$(get_gpg_entry "username")" \
                    && xdotool key Tab Tab \
                    && type_string "$(get_gpg_entry "password")" \
                    && xdotool key Return
                ;;
            "type [username] enter [password] enter"*)
                type_string "$(get_gpg_entry "username")" \
                    && xdotool key Return \
                    && sleep 1 \
                    && type_string "$(get_gpg_entry "password")" \
                    && xdotool key Return
                ;;
            "type [username]"*)
                type_string "$(get_gpg_entry "username")"
                ;;
            "type [password]"*)
                type_string "$(get_gpg_entry "password")"
                ;;
            "copy [username] to clipboard"*)
                copy_string "$(get_gpg_entry "username")"
                ;;
            "copy [password] to clipboard"*)
                copy_string "$(get_gpg_entry "password")"
                ;;
            *)
                exit 0
                ;;
        esac
        ;;
esac
