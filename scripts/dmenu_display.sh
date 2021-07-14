#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_display.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2021-07-14T19:50:37+0200

# config
spacer="----------------"

all_displays=$(xrandr \
    | grep "connected" \
)
connected_displays=$(printf "%s" "$all_displays" \
    | grep " connected" \
    | cut -d ' ' -f1 \
)

# settings
default_settings() {
    select=$(screenlayout.sh --defaults \
        | dmenu -l 10 -c -bw 2 -i -p "default »" \
    )
    [ -z "$select" ] \
        && exit 1

    screenlayout.sh "$select"
}

refresh_rate() {
    select=$(printf "%s\n" \
        "$connected_displays" \
        | dmenu -l 10 -c -bw 2 -r -i -p "display »" \
    )
    [ -z "$select" ] \
        && exit 0

    mode=$(xrandr \
        | grep "$select" \
        | cut -d '+' -f1 \
        | cut -d ' ' -f4 \
    )

    rate=$(printf "%s\n" \
        "240.00" \
        "144.00" \
        "120.00" \
        "75.00" \
        "60.00" \
        "50.00" \
        | dmenu -l 10 -c -bw 2 -i -p "rate »" \
    )
    [ -z "$rate" ] \
        && exit 0

    xrandr \
        --output "$select" \
        --mode "$mode" \
        --rate "$rate"
}

rotate() {
    select=$(printf "%s\n" \
        "$connected_displays" \
        | dmenu -l 10 -c -bw 2 -r -i -p "rotate »" \
    )
    [ -z "$select" ] \
        && exit 0

    direction=$(printf "%s\n" \
        "normal" \
        "left" \
        "right" \
        "inverted" \
        | dmenu -l 4 -c -bw 2 -i -p "direction »" \
    )

    [ -z "$direction" ] \
        && exit 0

    xrandr \
        --output "$select" \
        --rotate "$direction"
}

mirror() {
    external=$(printf "%s" "$connected_displays" \
        | dmenu -l 4 -c -bw 2 -r -i -p "resolution from »" \
    )
    [ -z "$external" ] \
        && exit 0
    internal=$(printf "%s" "$connected_displays" \
        | grep -v "$external" \
    )

    resolution_external=$(xrandr \
        | sed -n "/^$external/,/\+/p" \
        | tail -n 1 \
        | awk '{print $1}' \
    )
    resolution_internal=$(xrandr \
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

    xrandr \
        --output "$external" --auto \
        --scale 1.0x1.0 \
        --output "$internal" --auto \
        --same-as "$external" \
        --scale "$scale_x"x"$scale_y"
}


extend() {
    primary=$(printf "%s" "$connected_displays" \
        | dmenu -l 4 -c -bw 2 -r -i -p "primary »" \
    )
    [ -z "$primary" ] \
        && exit 0
    secondary=$(printf "%s" "$connected_displays" \
        | grep -v "$primary" \
        | head -n1 \
    )

    orientation=$(printf "above\nright\nbelow\nleft" \
        | dmenu -l 4 -c -bw 2 -r -i -p "position of $secondary »" \
        | sed 's/left/left-of/;s/right/right-of/' \
    )
    [ -z "$orientation" ] \
        && exit 0

    xrandr \
        --output "$primary" --auto --primary \
        --scale 1.0x1.0 \
        --output "$secondary" --"$orientation" "$primary" --auto \
        --scale 1.0x1.0
}

# menu
select=$(printf "%s\n" \
    "default settings" \
    "refresh rate" \
    "rotate" \
    "second display" \
    "$spacer" \
    "$connected_displays" \
    "$spacer" \
    "audio toggle" \
    | dmenu -l 10 -c -bw 2 -r -i -p "display »"
    ) && \
    case "$select" in
        "default settings")
            default_settings
        ;;
        "refresh rate")
            refresh_rate
        ;;
        "rotate")
            rotate
        ;;
        "second display")
            mirroring=$(printf "no\nyes" \
                | dmenu -l 2 -c -bw 2 -r -i -p "mirroring »" \
            )
            case $mirroring in
                "yes")
                    mirror
                    ;;
                "no")
                    extend
                    ;;
                *)
                    exit 0
                    ;;
            esac
        ;;
        "audio toggle")
            audio.sh -tog
        ;;
        "$spacer")
            "$0" &
        ;;
    *)
        eval xrandr \
            --output "$select" --auto --primary \
            --scale 1.0x1.0 \
            "$(printf "%s" "$all_displays" \
                | grep -v "$select" \
                | awk '{print "--output", $1, "--off"}' \
                | tr '\n' ' ' \
            )"
        ;;
    esac

# maintenance after setup displays
[ -n "$select" ] \
    && [ "$select" != "audio toggle" ] \
    && [ "$select" != "$spacer" ] \
    && wallpaper.sh \
    && systemctl --user restart polybar.service
