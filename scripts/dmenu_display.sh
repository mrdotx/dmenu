#!/bin/sh

# path:       /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_display.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/dmenu
# date:       2020-12-17T22:49:58+0100

# saved settings
saved_settings() {
    select=$(screenlayout.sh list \
        | dmenu -l 10 -c -bw 2 -r -i -p "display »" \
    )
    screenlayout.sh "$select"
}

# second display
secondary_display() {
    mirroring=$(printf "no\nyes" \
        | dmenu -l 2 -c -bw 2 -r -i -p "mirroring »" \
    )
    if [ "$mirroring" = "yes" ]; then
        external=$(printf "%s" "$get_display" \
            | dmenu -l 4 -c -bw 2 -r -i -p "resolution from »" \
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
            | dmenu -l 4 -c -bw 2 -r -i -p "primary »" \
        )
        secondary=$(printf "%s" "$get_display" \
            | grep -v "$primary" \
            | sed q1 \
        )
        orientation=$(printf "above\nright\nbelow\nleft" \
            | dmenu -l 4 -c -bw 2 -r -i -p "position of $secondary »" \
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
    | dmenu -l 5 -c -bw 2 -r -i -p "display »"
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
