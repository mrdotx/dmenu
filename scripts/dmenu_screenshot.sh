#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_screenshot.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2021-10-05T22:17:40+0200

# config
screenshot_directory="$HOME/Desktop"
screenshot_file="$screenshot_directory/screenshot-$(date +"%FT%T%z").png"
screenshot_command="maim -B -u -q $screenshot_file"
screenshot_preview="sxiv $screenshot_file"

# get active window id
window_id=$(xdotool getactivewindow)

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
    | dmenu -b -l 5 -w "$window_id" -p "screenshot »"
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
