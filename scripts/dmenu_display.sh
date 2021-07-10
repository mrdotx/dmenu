#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_display.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2021-07-10T10:17:28+0200

all_displays=$(xrandr \
    | grep "connected" \
)
connected_displays=$(printf "%s" "$all_displays" \
    | grep " connected" \
    | cut -d ' ' -f1 \
)

default_settings() {
    select=$(screenlayout.sh --defaults \
        | dmenu -l 10 -c -bw 2 -i -p "display »" \
    )
    screenlayout.sh "$select"
}

second_display() {
    mirroring=$(printf "no\nyes" \
        | dmenu -l 2 -c -bw 2 -r -i -p "mirroring »" \
    )
    if [ "$mirroring" = "yes" ]; then
        external=$(printf "%s" "$connected_displays" \
            | dmenu -l 4 -c -bw 2 -r -i -p "resolution from »" \
        )
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
    else
        primary=$(printf "%s" "$connected_displays" \
            | dmenu -l 4 -c -bw 2 -r -i -p "primary »" \
        )
        secondary=$(printf "%s" "$connected_displays" \
            | grep -v "$primary" \
            | head -n1 \
        )

        orientation=$(printf "above\nright\nbelow\nleft" \
            | dmenu -l 4 -c -bw 2 -r -i -p "position of $secondary »" \
            | sed 's/left/left-of/;s/right/right-of/' \
        )

        xrandr \
            --output "$primary" --auto \
            --scale 1.0x1.0 \
            --output "$secondary" --"$orientation" "$primary" --auto \
            --scale 1.0x1.0
    fi
}

refresh_rate() {
    select=$(printf "%s\n" \
        "$connected_displays" \
        | dmenu -l 10 -c -bw 2 -r -i -p "display »" \
    )

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

    xrandr \
        --output "$select" \
        --mode "$mode" \
        --rate "$rate"
}

# menu
select=$(printf "%s\n" \
    "second display" \
    "$connected_displays" \
    "audio toggle" \
    "refresh rate" \
    "default settings" \
    | dmenu -l 10 -c -bw 2 -r -i -p "display »"
    ) && \
    case "$select" in
        "second display")
            second_display
        ;;
        "audio toggle")
            audio.sh -tog
        ;;
        "refresh rate")
            refresh_rate
        ;;
        "default settings")
            default_settings
        ;;
    *)
        eval xrandr \
            --output "$select" --auto \
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
    && wallpaper.sh \
    && systemctl --user restart polybar.service
