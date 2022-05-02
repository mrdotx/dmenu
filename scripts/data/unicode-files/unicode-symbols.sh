#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/data/unicode-files/unicode-symbols.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2022-05-02T09:54:57+0200

output_file="../unicode-symbols"

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

get_fontawesome() {
    # font awesome copied from
    # https://fontawesome.com/v5/cheatsheet
    fa_files=$(find . -iname "fa-*")

    for file in $fa_files; do
        sed '/^$/d' "$file" \
            | awk 'ORS=NR%3?FS:RS' \
            | awk -F "     " '{print $1 " fa-" $2 "; " $3}'
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

    # others
    sort -u -k 2 "others.txt" > "$output_file"

# write symbols to file
{
    # nerd font
    get_nerdfont | sort -u -k 2;

    # font awesome
    get_fontawesome | sort -u -k 2;

    # emoji
    get_emoji | sort -u -k 2
} >> "$output_file"
