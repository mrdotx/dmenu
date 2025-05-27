#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_bookmarks.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2025-05-27T05:28:25+0200

# source dmenu helper
. _dmenu_helper.sh

title="bookmarks"

# config
bookmarks_file="$HOME/.local/share/repos/dmenu/scripts/data/$title"
search_url="https://lite.duckduckgo.com/lite/?q="
open_in_browser="link_handler.sh"

select_bookmark() {
    bookmarks=$(cat "$bookmarks_file")
    select=$(printf "%s\n" "$bookmarks" \
        | cut -d ';' -f1 \
        | dmenu -c -bw 1 -l 15 -i -p "$title »" \
    )

    [ -z "$select" ] \
        && exit 0

    open=$(printf "%s" "$bookmarks" \
        | grep -F "$select" \
        | cut -d ';' -f2 \
    )

    # select bookmark or search with duckduckgo
    [ -z "$open" ] \
        && open=$(printf "%s" "$search_url$select" \
            | sed 's/ /\%20/g' \
        )
}

close_firefox() {
    killall -q "/usr/lib/firefox/firefox" \
        && firefox=1 \
        && sleep .5
}

# data functions
create_bookmarks() {
    firefox_file=$(find "$HOME"/.mozilla/firefox/*default* -iname "places.sqlite")
    printf 'select mb.title, mp.url from moz_bookmarks mb, moz_places mp where mp.id=mb.fk;\n' \
        | sqlite3 -readonly -separator ';' "$firefox_file" \
        | sed 's/\/$//g' \
        | sort > "$bookmarks_file"
}

export_to_w3m() {
    w3m_file="$HOME/.local/state/w3m/bookmark.html"
    printf "%s\n" \
        "<html><head><title>Bookmarks</title></head>" \
        "<body>" \
        "<h1>Bookmarks</h1>" \
        "<h2>Firefox</h2>" \
        "<ul>" > "$w3m_file"
    awk -F ';' '{print "<li><a href=\""$2"\">"$1"</a>"}' "$bookmarks_file" >> "$w3m_file"
    printf "%s\n" \
        "<!--End of section (do not delete this comment)-->" \
        "</ul>" \
        "</body>" \
        "</html>" >> "$w3m_file"
}

export_to_surf() {
    surf_file="$HOME/.config/surf/bookmarks"
    cut -d ';' -f2 "$bookmarks_file" \
        | sed '/^$/d' > "$surf_file"
}

export_to_qutebrowser() {
    qutebrowser_file="$HOME/.config/qutebrowser/bookmarks/urls"
    cut -d ';' -f2 "$bookmarks_file" > "$qutebrowser_file"
}

# sync/open bookmark
case "$1" in
    --sync)
        close_firefox
        create_bookmarks
        export_to_w3m
        export_to_surf
        export_to_qutebrowser
        [ "$firefox" = 1 ] \
            && firefox &
        dmenu_notify 2500 \
            "$title" \
            "synchronized"
        ;;
    *)
        select_bookmark
        for url in $open; do
            $open_in_browser "$url"
        done
        ;;
esac
