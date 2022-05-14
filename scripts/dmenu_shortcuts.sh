#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_shortcuts.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2022-05-14T07:51:26+0200

shortcuts_file="$HOME/.local/share/repos/dmenu/scripts/data/shortcuts"

get_column() {
    printf "%s" "$select" \
        | cut -d "|" -f "$1" \
        | sed -e 's/^ *//' -e 's/ *$//'
}

select=$(dmenu -b -l 15 -bw 1 -r -i -p "shortcut »" < "$shortcuts_file")

[ -n "$select" ] \
    && select=$( \
        printf "%s\n%s\n%s\n" \
                "$(get_column 3)" \
                "$(get_column 2)" \
                "$(get_column 1)" \
            | dmenu -b -l 3 -bw 1 -r -i -p "shortcut »" \
            | sed -e "s/^ //" -e "s/\(\/\|\[\|\]\)/./g" \
    )

[ -n "$select" ] \
    && $TERMINAL -e "$EDITOR" "$shortcuts_file" -c "/$select"
