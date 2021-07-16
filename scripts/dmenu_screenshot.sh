#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_screenshot.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2021-07-16T19:50:54+0200

# config
screenshot_directory="$HOME/Desktop"
screenshot_file="$screenshot_directory/screenshot-$(date +"%FT%T%z").png"
screenshot_command="maim -B -u -q $screenshot_file"
screenshot_preview="sxiv $screenshot_file"

execute() {
    screenshot_command="$screenshot_command $*"
    $screenshot_command \
        && $screenshot_preview &
}

# menu
select=$(printf "%s\n" \
    "desktop" \
    "window" \
    "selection" \
    "desktop --delay 5" \
    "window --delay 5" \
    | dmenu -l 5 -c -bw 2 -p "screenshot »"
)

case $select in
    "desktop"*)
        execute "$select"
        ;;
    "window"*)
        execute "$select --window $(xdotool getactivewindow)"
        ;;
    "selection"*)
        notify-send \
            "maim" \
            "select an area or a window for the screenshot"
        execute "$select --select"
        ;;
    *)
        exit 0
        ;;
esac
