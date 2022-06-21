#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_screenshot.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2022-06-21T20:34:41+0200

# config
screenshot_directory="$HOME/Desktop"
screenshot_file="$screenshot_directory/screenshot-$(date +"%FT%T%z").png"
screenshot_command="maim -Buq $screenshot_file"
screenshot_preview="nsxiv $screenshot_file"

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
                | dmenu -l 5 -c -bw 1 -p "screenshot »" \
)

case $select in
    "desktop"*)
        execute "$select"
        ;;
    "window"*)
        execute "$select -i $(xdotool getactivewindow)"
        ;;
    "selection"*)
        notify-send \
            -u low \
            "maim" \
            "select an area or a window for the screenshot"
        execute "$select -so"
        ;;
    *)
        exit 0
        ;;
esac
