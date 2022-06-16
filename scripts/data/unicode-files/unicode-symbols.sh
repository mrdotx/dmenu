#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/data/unicode-files/unicode-symbols.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2022-06-16T10:27:47+0200

# config
output_file="../unicode-symbols"

# data functions
get_nerdfont() {
    nerdfonts_url="https://www.nerdfonts.com/cheat-sheet"

    get_char() {
        hex="\u$1"
        env printf '%b' "$hex"
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
    emoji_url="https://unicode.org/Public/emoji/14.0/emoji-test.txt"

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
