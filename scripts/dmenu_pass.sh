#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_pass.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2025-05-30T05:27:29+0200

# config
password_store="${PASSWORD_STORE_DIR:-$HOME/.password-store}"
file_type=".gpg"
edit="$TERMINAL -e ranger"
clipboard_timeout=45

# get active window id
window_id=$(xdotool getactivewindow)

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
    while true; do
        password=$(printf "%s" \
            "$(tr -dc "[:alnum:]$2" < /dev/urandom \
                | head -c"$1")" \
        )

        check_password "$password" "$2" \
            && printf "%s\n" "$password" \
            && break
    done
}

get_gpg_entry() {
    entry=$(gpg --quiet --decrypt "$password_store/$select$file_type")

    case "$1" in
        --username)
            printf "%s" "$entry" \
                | grep "^username:" \
                | sed "s/^username://; s/^[ \t]*//; s/[ \t]*$//" \
                | tr -d "\n"
            ;;
        --password)
            printf "%s" "$entry" \
                | head -n 1 \
                | tr -d "\n"
            ;;
    esac
}

# main
select=$(printf "» generate password\n%s" \
    "$(find "$password_store" -iname "*$file_type" -printf "%P\n" \
        | sed "s/$file_type$//" \
        | sort)" \
        | dmenu -b -l 15 -r -i -p "pass »" -w "$window_id" \
)

[ -z "$select" ] \
    && exit 0

case "$select" in
    "» generate password")
        case $(printf "%s\n" \
            "copy [password] to clipboard ($clipboard_timeout sec)" \
            "type [password]" \
            | dmenu -b -l 2 -r -i -p "generate password »" -w "$window_id" \
            ) in
            "copy [password] to clipboard"*)
                copy_string "$(generate_password 16 "!@#")"
                ;;
            "type [password]")
                type_string "$(generate_password 16 "!@#")"
                ;;
            *)
                exit 0
                ;;
        esac
        ;;
    *)
        while true; do
            case $(printf "%s\n" \
                "» edit saved settings" \
                "type [username] TAB [password] ENTER" \
                "type [username]" \
                "type [password]" \
                | dmenu -b -l 4 -r -i -p "$select »" -w "$window_id" \
                ) in
                "» edit saved settings")
                    $edit "$password_store/$select$file_type"
                    break
                    ;;
                "type [username] TAB [password] ENTER")
                    type_string "$(get_gpg_entry --username)" \
                        && xdotool key Tab \
                        && type_string "$(get_gpg_entry --password)" \
                        && xdotool key Return
                    break
                    ;;
                "type [username]")
                    type_string "$(get_gpg_entry --username)"
                    ;;
                "type [password]")
                    type_string "$(get_gpg_entry --password)"
                    ;;
                *)
                    break
                    ;;
            esac
        done
        ;;
esac
