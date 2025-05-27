#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_screenshot.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2025-05-27T05:30:43+0200

# source dmenu helper
. _dmenu_helper.sh

title="screenshot"

# config
screenshot_directory="$HOME/Downloads"
screenshot_file="$screenshot_directory/${title}_$(date +"%FT%T%z").png"
screenshot_command="maim --quiet --hidecursor $screenshot_file"
screenshot_preview="nsxiv --quiet --scale-mode w $screenshot_file"

execute() {
    # WORKAROUND: dmenu does not close fast enough
    sleep .1

    eval "$screenshot_command $* && $screenshot_preview &"
}

# menu
select=$(printf "%s\n" \
    "desktop" \
    "desktop --delay=5" \
    "window --capturebackground" \
    "window" \
    "selection" \
        | dmenu -c -bw 1 -l 5 -p "$title »" \
)

case $select in
    "desktop"*)
        execute "$select"
        ;;
    "window"*)
        execute "$select --window=$(xdotool getactivewindow)"
        ;;
    "selection"*)
        dmenu_notify 2500 \
            "$title" \
            "select a window or an area for the screenshot"
        execute "$select --select"
        ;;
    *)
        exit 0
        ;;
esac
