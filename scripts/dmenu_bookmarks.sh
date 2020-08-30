#!/bin/sh

# path:       /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_bookmarks.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/dmenu
# date:       2020-08-30T16:12:13+0200

script=$(basename "$0")
help="$script [-h/--help] -- script to open bookmarks with dmenu/rofi
  Usage:
    depending on how the script is named,
    it will be executed either with dmenu or with rofi

  Examples:
    dmenu_bookmarks.sh
    rofi_bookmarks.sh"

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    printf "%s\n" "$help"
    exit 0
fi

case $script in
    dmenu_*)
        label="bookmark »"
        menu="dmenu -l 20 -c -bw 2 -i"
        ;;
    rofi_*)
        label=""
        menu="rofi -m -1 -l 15 -theme klassiker-center -dmenu -i"
        ;;
    *)
        printf "%s\n" "$help"
        exit 1
        ;;
esac

bookmarks_file="$HOME/.local/share/repos/dmenu/scripts/data/bookmarks"
w3m_file="$HOME/.w3m/bookmark.html"
surf_file="$HOME/.config/surf/bookmarks"
qutebrowser_file="$HOME/.config/qutebrowser/bookmarks/urls"

menu_sync="== Sync Bookmarks ==;bookmarks_sync"
menu_bookmarks=$(cat "$bookmarks_file")
bookmarks=$(printf "%s\n%s" "$menu_sync" "$menu_bookmarks")

# select bookmark or enter a url manually
title=$(printf "%s\n" "$bookmarks" \
    | awk -F ';' '{print $1}' \
)
select=$(printf "%s" "$title" \
    | $menu -p "$label" \
)
[ -n "$select" ] \
    || exit 1

open=$(printf "%s" "$bookmarks" \
        | grep -F "$select" \
        | awk -F ';' '{print $2}') \
    || open="$select"

# open bookmark
case "$open" in
    bookmarks_sync)
        firefox_close() {
            killall -q /usr/lib/firefox-developer-edition/firefox \
                && firefox=1 \
                && sleep 0.1
        }

        create_bookmarks() {
            printf 'select mp.url, mb.title from moz_bookmarks mb, moz_places mp where mp.id=mb.fk;\n' \
                | sqlite3 ~/.mozilla/firefox/*dev-edition-default/places.sqlite \
                | awk -F '|' '{print $2"\;"$1}' \
                | sort > "$bookmarks_file"
         }

        bookmarks_to_surf() {
            awk -F ';' '{print $2}' < "$bookmarks_file" \
                | sed '/^$/d' \
                | sort > "$surf_file"
        }

        bookmarks_to_qutebrowser() {
            awk -F ';' '{print $2}' < "$bookmarks_file" \
                | sort > "$qutebrowser_file"
        }

        bookmarks_to_w3m() {
            header="<html><head><title>Bookmarks</title></head>
<body>
<h1>Bookmarks</h1>
<h2>Firefox</h2>
<ul>"
            footer="<!--End of section (do not delete this comment)-->
</ul>
</body>
</html>
"
            printf "%s\n" "$header" > "$w3m_file"
            awk -F ';' '{print "<li><a href=\""$2"\">"$1"</a>"}' < "$bookmarks_file" \
                | sort >> "$w3m_file"
            printf "%s" "$footer" >> "$w3m_file"
        }

        firefox_close
        create_bookmarks
        bookmarks_to_surf
        bookmarks_to_qutebrowser
        bookmarks_to_w3m
        [ $firefox = 1 ] \
            && firefox-developer-edition &

        notify-send "bookmarks" "synchronized"
        dmenu_bookmarks.sh
        ;;
    *)
        link_handler.sh "$open"
        ;;
esac
