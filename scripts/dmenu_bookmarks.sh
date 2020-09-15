#!/bin/sh

# path:       /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_bookmarks.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/dmenu
# date:       2020-09-15T15:53:36+0200

script=$(basename "$0")
help="$script [-h/--help] -- script to open bookmarks from firefox with dmenu/rofi
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
bookmarks=$(printf "== Sync Bookmarks ==;sync_bookmarks\n%s" "$(cat "$bookmarks_file")")

# select bookmark or search with duckduckgo
select=$(printf "%s\n" "$bookmarks" \
    | awk -F ';' '{print $1}' \
    | $menu -p "$label" \
)

[ -n "$select" ] \
    || exit 1

open=$(printf "%s" "$bookmarks" \
    | grep -F "$select" \
    | awk -F ';' '{print $2}' \
)

[ -n "$open" ] \
    || open=$(printf "%s" "https://lite.duckduckgo.com/lite/?q=$select" \
        | sed 's/ /\%20/g' \
    )

# data functions
close_firefox() {
    killall -q "/usr/lib/firefox-developer-edition/firefox" \
        && firefox=1 \
        && sleep 0.1
}

create_bookmarks() {
    firefox_file=$(find "$HOME"/.mozilla/firefox/*default* -iname "places.sqlite")
    printf 'select mb.title, mp.url from moz_bookmarks mb, moz_places mp where mp.id=mb.fk;\n' \
        | sqlite3 -separator ';' "$firefox_file" \
        | sort > "$bookmarks_file"
}

copy_to_w3m() {
    w3m_file="$HOME/.w3m/bookmark.html"
    header="<html><head><title>Bookmarks</title></head>
<body>
<h1>Bookmarks</h1>
<h2>Firefox</h2>
<ul>"
    footer="<!--End of section (do not delete this comment)-->
</ul>
</body>
</html>"

    printf "%s\n" "$header" > "$w3m_file"
    awk -F ';' '{print "<li><a href=\""$2"\">"$1"</a>"}' < "$bookmarks_file" >> "$w3m_file"
    printf "%s" "$footer" >> "$w3m_file"
}

copy_to_surf() {
    surf_file="$HOME/.config/surf/bookmarks"
    awk -F ';' '{print $2}' < "$bookmarks_file" \
        | awk -F '//' '{print $2}' \
        | sed '/^$/d' > "$surf_file"
}

copy_to_qutebrowser() {
    qutebrowser_file="$HOME/.config/qutebrowser/bookmarks/urls"
    awk -F ';' '{print $2}' < "$bookmarks_file" > "$qutebrowser_file"
}

# sync/open bookmark
case "$open" in
    sync_bookmarks)
        close_firefox
        create_bookmarks
        copy_to_w3m
        copy_to_surf
        copy_to_qutebrowser
        [ $firefox = 1 ] \
            && firefox-developer-edition &
        notify-send "bookmarks" "synchronized"
        dmenu_bookmarks.sh
        ;;
    *)
        link_handler.sh "$open"
        ;;
esac
