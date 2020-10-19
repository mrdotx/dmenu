#!/bin/sh

# path:       /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_display.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/dmenu
# date:       2020-10-19T19:52:41+0200

script=$(basename "$0")
help="$script [-h/--help] -- script to manage displays with arandr/xrandr
  Usage:
    depending on how the script is named,
    it will be executed either with dmenu or with rofi

  Examples:
    dmenu_display.sh
    rofi_display.sh"

if [ "$1" = "-h" ] \
    || [ "$1" = "--help" ]; then
        printf "%s\n" "$help"
        exit 0
fi

case $script in
    dmenu_*)
        label="display »"
        menu="dmenu -l 5 -c -bw 2 -r -i"
        label_mirroring="mirroring »"
        menu_mirroring="dmenu -l 2 -c -bw 2 -r -i"
        label_external="resolution from »"
        menu_external="dmenu -l 4 -c -bw 2 -r -i"
        label_primary="primary »"
        menu_primary="dmenu -l 4 -c -bw 2 -r -i"
        label_orientation="position of"
        menu_orientation="dmenu -l 4 -c -bw 2 -r -i"
        label_saved_settings="display »"
        menu_saved_settings="dmenu -l 10 -c -bw 2 -r -i"
        ;;
    rofi_*)
        label=""
        menu="rofi -m -1 -l 3 -columns 2 -theme klassiker-center -dmenu -i"
        label_mirroring="mirroring »"
        menu_mirroring="rofi -m -1 -l 1 -columns 2 -theme klassiker-center -dmenu -i"
        label_external="resolution from »"
        menu_external="rofi -m -1 -l 2 -columns 2 -theme klassiker-center -dmenu -i"
        label_primary="primary »"
        menu_primary="rofi -m -1 -l 2 -columns 2 -theme klassiker-center -dmenu -i"
        label_orientation="position of"
        menu_orientation="rofi -m -1 -l 2 -columns 2 -theme klassiker-center -dmenu -i"
        label_saved_settings=""
        menu_saved_settings="rofi -m -1 -l 3 -columns 2 -theme klassiker-center -dmenu -i"
        ;;
    *)
        printf "%s\n" "$help"
        exit 1
        ;;
esac

# saved settings
saved_settings() {
    select=$(find "$HOME/.local/share/repos/shell/screenlayout/" -iname "*.sh" \
        | cut -d / -f 9 \
        | sed 's/.sh//g' \
        | sort \
        | $menu_saved_settings -p "$label_saved_settings" \
    )
    "$HOME/.local/share/repos/shell/screenlayout/$select.sh"
}

# second display
secondary_display() {
    mirroring=$(printf "no\nyes" \
        | $menu_mirroring -p "$label_mirroring" \
    )
    if [ "$mirroring" = "yes" ]; then
        external=$(printf "%s" "$get_display" \
            | $menu_external -p "$label_external" \
        )
        internal=$(printf "%s" "$get_display" \
            | grep -v "$external" \
        )

        resolution_external=$(xrandr --query \
            | sed -n "/^$external/,/\+/p" \
            | tail -n 1 \
            | awk '{print $1}' \
        )
        resolution_internal=$(xrandr --query \
            | sed -n "/^$internal/,/\+/p" \
            | tail -n 1 \
            | awk '{print $1}' \
        )

        resolution_external_x=$(printf "%s" "$resolution_external" \
            | sed 's/x.*//' \
        )
        resolution_external_y=$(printf "%s" "$resolution_external" \
            | sed 's/.*x//' \
        )
        resolution_internal_x=$(printf "%s" "$resolution_internal" \
            | sed 's/x.*//' \
        )
        resolution_internal_y=$(printf "%s" "$resolution_internal" \
            | sed 's/.*x//' \
        )

        scale_x=$(printf "%s\n" "$resolution_external_x / $resolution_internal_x" \
            | bc -l \
        )
        scale_y=$(printf "%s\n" "$resolution_external_y / $resolution_internal_y" \
            | bc -l \
        )

        xrandr --output "$external" --auto --scale 1.0x1.0 --output "$internal" --auto --same-as "$external" --scale "$scale_x"x"$scale_y"
    else
        primary=$(printf "%s" "$get_display" \
            | $menu_primary -p "$label_primary" \
        )
        secondary=$(printf "%s" "$get_display" \
            | grep -v "$primary" \
            | sed q1 \
        )
        orientation=$(printf "above\nright\nbelow\nleft" \
            | $menu_orientation -p "$label_orientation $secondary »" \
            | sed 's/left/left-of/;s/right/right-of/' \
        )
        xrandr --output "$primary" --auto --scale 1.0x1.0 --output "$secondary" --"$orientation" "$primary" --auto --scale 1.0x1.0
    fi
}

# menu
display_all=$(xrandr -q \
    | grep "connected" \
)
get_display=$(printf "%s" "$display_all" \
    | grep " connected" \
    | cut -d ' ' -f1 \
)
select=$(printf "saved settings\nsecond display\n%s\naudio toggle" "$get_display" \
    | $menu -p "$label"
    ) && \
    case "$select" in
        "saved settings")
            saved_settings
        ;;
        "second display")
            secondary_display
        ;;
        "audio toggle")
            audio.sh -tog
        ;;
    *)
        eval xrandr --output "$select" --auto --scale 1.0x1.0 \
            "$(printf "%s" "$display_all" \
                | grep -v "$select" \
                | awk '{print "--output", $1, "--off"}' \
                | tr '\n' ' ' \
            )"
        ;;
    esac

# maintenance after setup displays
[ -n "$select" ] \
    && [ ! "$select" = "audio toggle" ] \
    && systemctl --user restart xwallpaper.service \
    && systemctl --user restart polybar.service
