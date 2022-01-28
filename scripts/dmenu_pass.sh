#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_pass.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2022-01-28T21:44:18+0100

# config
password_store="${PASSWORD_STORE_DIR-~/.password-store}"
file_type=".gpg"
clipboard_timeout=45
generate_password_chars=16

select=$(printf "== Generate Password ==\n%s" \
    "$(find "$password_store" -iname "*$file_type" -printf "%P\n" \
        | sed "s/$file_type$//" \
        | sort)" \
        | dmenu -l 15 -c -bw 2 -r -i -p "pass »" \
)

[ -z "$select" ] \
    && exit 0

get_entry() {
    entry=$(gpg --quiet --decrypt "$password_store/$select$file_type")

    username() {
        printf "%s" "$entry" \
            | grep "^username:" \
            | sed "s/^username://; s/^[ \t]*//; s/[ \t]*$//" \
            | tr -d "\n"
    }

    password() {
        printf "%s" "$entry" \
            | head -n 1 \
            | tr -d "\n"
    }

    generate_password() {
        printf "%s" "$(tr -dc A-Za-z0-9 < /dev/urandom \
            | head -c"$generate_password_chars")"
    }

    case "$1" in
        type)
            # workaround for mismatched keyboard layouts
            setxkbmap -synch

            eval "$2" \
                | xdotool type \
                    --clearmodifiers \
                    --file -
            ;;
        copy)
            eval "$2" \
                | xsel \
                    --input \
                    --selectionTimeout "$((clipboard_timeout * 1000))" \
                    --clipboard
            ;;
    esac
}

case "$select" in
    "== Generate Password ==")
        case $(printf "%s\n" \
            "1) copy password ($clipboard_timeout sec)" \
            "2) type password" \
            | dmenu -l 2 -c -bw 2 -r -i -p "Generate Password »" \
            ) in
            "1) copy password ($clipboard_timeout sec)")
                get_entry "copy" "generate_password"
                ;;
            "2) type password")
                get_entry "type" "generate_password"
                ;;
            *)
                exit 0
                ;;
        esac
        ;;
    *)
        case $(printf "%s\n" \
            "1) copy username ($clipboard_timeout sec)" \
            "2) copy password ($clipboard_timeout sec)" \
            "3) type username, tab, password" \
            "4) type username, 2xtab, password" \
            "5) type username" \
            "6) type password" \
            | dmenu -l 6 -c -bw 2 -r -i -p "$select »" \
            ) in
            "1) copy username ($clipboard_timeout sec)")
                get_entry "copy" "username"
                ;;
            "2) copy password ($clipboard_timeout sec)")
                get_entry "copy" "password"
                ;;
            "3) type username, tab, password")
                get_entry "type" "username"
                xdotool key Tab
                get_entry "type" "password"
                ;;
            "4) type username, 2xtab, password")
                get_entry "type" "username"
                xdotool key Tab Tab
                get_entry "type" "password"
                ;;
            "5) type username")
                get_entry "type" "username"
                ;;
            "6) type password")
                get_entry "type" "password"
                ;;
            *)
                exit 0
                ;;
        esac
        ;;
esac
