#!/bin/sh

# path:       /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_bookmarks.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/dmenu
# date:       2020-08-30T09:47:15+0200

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

# bookmark files (format: {title; url} per row)
bookmarks=$(grep -v "$HOME/.local/share/repos/dmenu/scripts/data/bookmarks" -e "^#" -e "^\s*$")
browser=$(awk '{print $0" [/b]; "$0}' "$HOME/.config/qutebrowser/bookmarks/urls")
if [ -n "$browser" ]; then
    bookmarks=$(printf "%s\n%s" "$bookmarks" "$browser")
fi

# select bookmark or enter a url manually
title=$(printf "%s\n" "$bookmarks" \
    | awk -F '; ' '{print $1}' \
)
select=$(printf "%s" "$title" \
    | $menu -p "$label" \
)
[ -n "$select" ] \
    || exit 1

[ -z "${select##*[/*]*}" ] \
    && open=$(printf "%s" "$bookmarks" \
        | grep -F "$select" \
        | awk -F '; ' '{print $2}') \
    || open="$select"

# open bookmark
case "$open" in
    bookmarks_sync)
        brave_to_surf() {
            grep \"url\": ~/.config/BraveSoftware/Brave-Browser/Default/Bookmarks \
                | awk -F '"' '{print $4}' \
                | awk -F '//' '{print $2}' \
                | sort > ~/.config/surf/bookmarks
        }

        brave_to_qutebrowser() {
            grep \"url\": ~/.config/BraveSoftware/Brave-Browser/Default/Bookmarks \
                | awk -F '"' '{print $4}' \
                | sort > ~/.config/qutebrowser/bookmarks/urls
        }

        firefox_close() {
            killall -q /usr/lib/firefox-developer-edition/firefox \
                && firefox=1 \
                && sleep 0.1
        }

        firefox_to_surf() {
            printf 'select mp.url from moz_bookmarks mb, moz_places mp where mp.id=mb.fk;\n' \
                | sqlite3 ~/.mozilla/firefox/*dev-edition-default/places.sqlite \
                | awk -F '//' '{print $2}' \
                | sed '/^$/d' \
                | sort > ~/.config/surf/bookmarks
        }

        firefox_to_qutebrowser() {
            printf 'select mp.url from moz_bookmarks mb, moz_places mp where mp.id=mb.fk;\n' \
                | sqlite3 ~/.mozilla/firefox/*dev-edition-default/places.sqlite \
                | sort > ~/.config/qutebrowser/bookmarks/urls
        }

        firefox_to_w3m() {
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
            printf "%s" "$header" > ~/.w3m/bookmark.html
            printf 'select mp.url, mb.title from moz_bookmarks mb, moz_places mp where mp.id=mb.fk;\n' \
                | sqlite3 ~/.mozilla/firefox/*dev-edition-default/places.sqlite \
                | awk -F '|' '{print "<li><a href=\""$1"\">"$2"</a>"}' \
                | sort >> ~/.w3m/bookmark.html
            printf "%s" "$footer" >> ~/.w3m/bookmark.html
        }

        # firefox functions
        firefox_close
        firefox_to_surf
        firefox_to_qutebrowser
        firefox_to_w3m
        [ $firefox = 1 ] \
            && firefox-developer-edition &

        # brave functions
        # brave_to_surf
        # brave_to_qutebrowser

        notify-send "bookmarks" "synchronized"
        dmenu_bookmarks.sh
        ;;
    *)
        link_handler.sh "$open"
        ;;
esac
