#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_pass.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2021-06-26T09:18:35+0200

# config
password_store="${PASSWORD_STORE_DIR-~/.password-store}"
file_type=".gpg"
generate_password_chars=14

# get active window id
window_id=$(xprop -root \
    | awk '/_NET_ACTIVE_WINDOW\(WINDOW\)/{print $NF}' \
)

select=$(printf "== Generate Password ==\n%s" \
    "$(find "$password_store" -iname "*$file_type" -printf "%P\n" \
        | sed "s/$file_type$//" \
        | sort)" \
        | dmenu -b -l 15 -r -i -w "$window_id" -p "pass »" \
)

[ -z "$select" ] \
    && exit 1

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

    generate_password() {
        printf "%s" "$(< /dev/urandom tr -dc A-Za-z0-9 \
            | head -c"$generate_password_chars")"
    }

    case "$1" in
        type)
            # workaround for mismatched keyboard layouts
            setxkbmap -synch

            eval "$2" \
                | xdotool type --clearmodifiers --file -
            ;;
        copy)
            case "$2" in
                generate_password)
                    timeout=120000
                    ;;
                *)
                    timeout=45000
                    ;;
            esac

            eval "$2" \
                | xsel --input --selectionTimeout "$timeout" --clipboard
            ;;
    esac
}

case "$select" in
    "== Generate Password ==")
        case $(printf "%s\n" \
            "1) type password" \
            "2) copy password" \
            | dmenu -b -l 2 -r -i -w "$window_id" -p "$select »" \
            ) in
            "1) type password")
                get_entry "type" "generate_password"
                ;;
            "2) copy password")
                get_entry "copy" "generate_password"
                ;;
            *)
                exit 0
                ;;
        esac
        ;;
    *)
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
        ;;
esac
