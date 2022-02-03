#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/data/unicode-files/unicode-symbols.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2022-02-03T18:40:03+0100

output_file="../unicode-symbols"

# emoji downloaded from
# https://unicode.org/Public/emoji/14.0/emoji-test.txt
emoji_file="emoji-test.txt"

# font awesome copied from
# https://fontawesome.com/v5/cheatsheet
fa_files=$(find . -iname "fa-*")

# others
others_file="others.txt"

# emoji
grep "; fully-qualified" "$emoji_file" \
    | awk -F "; fully-qualified     # " '{print $2 "; " $1}' \
    | sed 's/[ \t]*$//' \
    | cut -d' ' -f2 --complement \
    | sort -u -k 2 > "$output_file"

# font awesome
for file in $fa_files; do
    sed '/^$/d' "$file" \
        | awk 'ORS=NR%3?FS:RS' \
        | awk -F "     " '{print $1 " fa-" $2 "; " $3}'
done \
    | sort -u -k 2 >> "$output_file"

# others
    sort -u -k 2 "$others_file" >> "$output_file"
