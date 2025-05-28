#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_unicode_symbols.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2025-05-28T05:05:12+0200

# source dmenu helper
. _dmenu_helper.sh

title="unicode-symbols"

# config
data_dir="$HOME/.local/share/repos/dmenu/scripts/data"
unicode_symbols_file="$data_dir/$title"
unicode_files="$data_dir/unicode-files"

# data functions
get_emoji() {
    emoji_url="https://unicode.org/Public/emoji/latest/emoji-test.txt"

    emoji=$(curl -fsS "$emoji_url" \
        | grep "; fully-qualified" \
        | awk -F "; fully-qualified     # " '{print $2 "; " $1}' \
        | sed 's/[ \t]*$//' \
        | cut -d' ' -f2 --complement)

    printf "%s\n" "$emoji"
    printf "%s\n" "$emoji" | sort -u -k 2 > "$1"
}

get_nerdfont() {
    nerdfonts_url="https://www.nerdfonts.com/cheat-sheet"

    # print unicode symbol from hex value
    get_char() {
        env printf '%b' "$(printf "\U%0*d%s" "$((8-${#1}))" "0" "$1")"
    }

    data=$(curl -fsS "$nerdfonts_url" \
        | grep "^  \"nf" \
        | grep -v "nfold-" \
        | sed \
            -e 's/^  \"//g' \
            -e 's/\",$//g' \
            -e 's/\": \"/;/g' \
    )

    for line in $data; do
        class=$(printf "%s" "$line" | cut -d';' -f1)
        hex=$(printf "%s" "$line" | cut -d';' -f2)
        output=$(printf "%s %s; %s" "$(get_char "$hex")" "$class" "$hex")
        nerdfont=$(printf "%s\n%s\n" "$nerdfont" "$output")

        printf "%s\n" "$output"
    done

    printf "%s\n" "$nerdfont" | sort -u -k 2 >> "$1"
}

get_files() {
    for f in "$unicode_files"/*.txt; do
        output=$(sort -u -k 2 "$f")
        files=$(printf "%s\n%s\n" "$files" "$output")

        printf "%s\n" "$output"
    done

    printf "%s\n" "$files" | sort -u -k 2 >> "$1"
}

select_symbols() {
    # get active window id
    window_id=$(xdotool getactivewindow)

    select=$(dmenu -b -l 15 -r -i -p "$title »" -w "$window_id" \
        < "$unicode_symbols_file" \
    )

    [ -z "$select" ] \
        && exit 0

    symbol=$(printf "%s\n" "$select" \
        | sed 's/ .*//' \
        | tr -d '\n' \
    )

    # type at cursor
    xdotool type "$symbol"
    # copy symbol to clipboard
    printf "%s" "$symbol" \
        | xsel -i -b

    dmenu_notify 2500 \
        "$title" \
        "$symbol copied to clipboard"
}

case "$1" in
    --update)
            get_emoji "$unicode_symbols_file"
            get_nerdfont "$unicode_symbols_file"
            get_files "$unicode_symbols_file"

            sed -i '/^$/d' "$unicode_symbols_file"
        ;;
    *)
        select_symbols
        ;;
esac
