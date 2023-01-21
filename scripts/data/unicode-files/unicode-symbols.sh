#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/data/unicode-files/unicode-symbols.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2023-01-21T14:16:53+0100

# config
output_file="../unicode-symbols"

# data functions
get_nerdfont() {
    nerdfonts_url="https://www.nerdfonts.com/cheat-sheet"

    get_char() {
        env printf '%b' "$(printf "\U%0*d%s\n" "$((8-${#1}))" "0" "$1")"
    }

    data=$(curl -fsS "$nerdfonts_url" \
        | grep "class-name" \
        | sed \
            -e 's/    <div class="class-name">/;/g' \
            -e 's/<div class="codepoint">/;/g' \
            -e 's/<\/div>//g' \
    )

    for line in $data; do
        class=$(printf "%s" "$line" | cut -d';' -f2)
        hex=$(printf "%s" "$line" | cut -d';' -f3)
        printf "%s %s; %s\n" "$(get_char "$hex")" "$class" "$hex"
    done
}

get_emoji() {
    emoji_url="https://unicode.org/Public/emoji/15.0/emoji-test.txt"

    curl -fsS "$emoji_url" \
        | grep "; fully-qualified" \
        | awk -F "; fully-qualified     # " '{print $2 "; " $1}' \
        | sed 's/[ \t]*$//' \
        | cut -d' ' -f2 --complement
}

# write symbols to file
{
    # emoji
    get_emoji | sort -u -k 2;

    # nerd font
    get_nerdfont | sort -u -k 2;

    # currency
    sort -u -k 2 "currency.txt"
} > "$output_file"
