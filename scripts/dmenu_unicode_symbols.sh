#!/bin/bash
# WORKAROUND: the dash shell encodes files in latin1 rather than utf-8

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_unicode_symbols.sh
# author: klassiker [mrdotx]
# url:    https://github.com/mrdotx/dmenu
# date:   2026-07-11T03:53:25+0200

# use C.UTF-8 locale to avoid locale-specific issues and ensure consistent performance
export LC_ALL=C.UTF-8 LANG=C.UTF-8

# source dmenu helper
. _dmenu_helper.sh

title="unicode-symbols"

# config
data_dir="$HOME/.local/share/repos/dmenu/scripts/data"
unicode_symbols_file="$data_dir/$title"
unicode_files="$data_dir/unicode-files"

# data functions
get_emoji() {
    emoji=$(curl -fsS "https://unicode.org/Public/emoji/latest/emoji-test.txt" \
        | grep "; fully-qualified" \
        | awk -F "; fully-qualified     # " '{print $2 "; " $1}' \
        | sed 's/[ \t]*$//' \
        | cut -d' ' -f2 --complement)

    printf "%s\n" "$emoji" \
        | sort -u -d -f -k 2 \
        | tee "$1"
}

get_nerdfont() {
    data=$(curl -fsS "https://www.nerdfonts.com/cheat-sheet" \
        | grep "^  \"nf" \
        | grep -v "nfold-" \
        | sed \
            -e 's/^  \"//g' \
            -e 's/\",$//g' \
            -e 's/\": \"/;/g' \
    )

    # print unicode symbol from hex value
    get_char() {
        printf '%b' "$(printf "\\\U%0*d%s" "$((8-${#1}))" "0" "$1")"
    }

    for line in $data; do
        class=$(printf "%s" "$line" | cut -d';' -f1)
        hex=$(printf "%s" "$line" | cut -d';' -f2)
        symbol=$(printf "%s" "$(get_char "$hex")")

        printf "%b %s; %s\n" "$symbol" "$class" "$hex" \
            | sort -u -d -f -k 2 \
            | tee -a "$1"
    done
}

get_files() {
    for f in "$unicode_files"/*.txt; do
        sort -u -d -f -k 2 "$f" \
            | tee -a "$1"
    done
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
    dmenu_xdotool type "$symbol"
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
