#!/bin/sh

# path:       /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_bookmarks.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/dmenu
# date:       2020-08-01T11:43:12+0200

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
            printf 'select url from moz_bookmarks, moz_places where moz_places.id=moz_bookmarks.fk;\n' \
                | sqlite3 ~/.mozilla/firefox/*dev-edition-default/places.sqlite \
                | awk -F '//' '{print $2}' \
                | sed '/^$/d' \
                | sort > ~/.config/surf/bookmarks
        }

        firefox_to_qutebrowser() {
            printf 'select url from moz_bookmarks, moz_places where moz_places.id=moz_bookmarks.fk;\n' \
                | sqlite3 ~/.mozilla/firefox/*dev-edition-default/places.sqlite \
                | sort > ~/.config/qutebrowser/bookmarks/urls
        }

        # firefox functions
        firefox_close
        firefox_to_surf
        firefox_to_qutebrowser
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
