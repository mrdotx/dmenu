#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_shortcuts.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2025-05-27T05:31:10+0200

shortcuts_file="$HOME/.local/share/repos/dmenu/scripts/data/shortcuts"

get_column() {
    printf "%s" "$2" \
        | cut -d "|" -f "$1" \
        | sed -e 's/^ *//' -e 's/ *$//'
}

select=$(dmenu -b -bw 1 -l 15 -r -i -p "shortcut »" < "$shortcuts_file")

[ -n "$select" ] \
    && select=$(printf "%s\n%s\n%s\n" \
        "$(get_column 3 "$select")" \
        "$(get_column 2 "$select")" \
        "$(get_column 1 "$select")" \
            | dmenu -b -bw 1 -l 3 -r -i -p "shortcut »" \
            | sed -e "s/^ //" -e "s/\(\/\|\[\|\]\)/./g" \
    )

[ -n "$select" ] \
    && $TERMINAL -e "$EDITOR" "$shortcuts_file" -c "/$select"
