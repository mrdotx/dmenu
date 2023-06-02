#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_unicode_symbols.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2023-06-01T20:02:52+0200

# config
data_dir="$HOME/.local/share/repos/dmenu/scripts/data"
unicode_symbols_file="$data_dir/unicode-symbols"
unicode_files="$data_dir/unicode-files"

# data functions
get_emoji() {
    emoji_url="https://unicode.org/Public/emoji/latest/emoji-test.txt"

    curl -fsS "$emoji_url" \
        | grep "; fully-qualified" \
        | awk -F "; fully-qualified     # " '{print $2 "; " $1}' \
        | sed 's/[ \t]*$//' \
        | cut -d' ' -f2 --complement
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
        printf "%s %s; %s\n" "$(get_char "$hex")" "$class" "$hex"
    done
}

select_symbols() {
    # get active window id
    window_id=$(xdotool getactivewindow)

    select=$(dmenu -b -l 15 -bw 1 -r -i -w "$window_id" -p "symbol »" \
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

    notify-send \
        -u low \
        "copied $symbol to clipboard" \
        "$select"
}

case "$1" in
    --update)
        {
            # emoji
            get_emoji | sort -u -k 2;

            # nerd font
            get_nerdfont | sort -u -k 2;

            # files
            for f in "$unicode_files"/*.txt; do
                sort -u -k 2 "$f"
            done
        } > "$unicode_symbols_file"
        ;;
    *)
        select_symbols
        ;;
esac
