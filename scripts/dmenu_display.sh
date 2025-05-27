#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_display.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2025-05-27T05:29:25+0200

# config
saved_settings_file="$HOME/.local/share/repos/dmenu/scripts/data/screen-layouts"
edit="$TERMINAL -e $EDITOR"

all_displays=$(xrandr \
    | grep "connected" \
)
connected_displays=$(printf "%s" "$all_displays" \
    | grep " connected" \
    | sort -k3 -r \
    | cut -d ' ' -f1 \
)

display() {
    primary=$(printf "%s" "$connected_displays" \
        | dmenu -c -bw 1 -l 4 -r -i -p "$1" \
    )
    [ -z "$primary" ] \
        && exit 0
    secondary=$(printf "%s" "$connected_displays" \
        | grep -v "$primary" \
        | head -n1 \
    )
}

saved_settings() {
    display "primary »"

    get_options() {
        printf "%s" "$options" \
            | cut -d ';' -f"$1"
    }

    select=$(awk -F ';' '{print $1}' "$saved_settings_file" \
        | dmenu -c -bw 1 -l 10 -i -p "$select »" \
    )
    [ -n "$select" ] \
        && options=$(grep "^$select;" "$saved_settings_file") \
        && eval xrandr \
            --output "$primary" --auto --primary \
            "$(get_options 2)" \
            --output "$secondary" --auto \
            "$(get_options 3)"
}

refresh_rate() {
    display "$select »"

    mode=$(xrandr \
        | grep -A1 "$primary" \
        | tail -n1 \
        | awk '{print $1}'
    )

    rate=$(xrandr \
        | grep -A1 "$primary" \
        | tail -n1 \
        | awk '{for (i=2;i<=NF;i++) print $i}' \
        | sed "s/\+//; /^$/d" \
        | dmenu -c -bw 1 -l 10 -r -i -p "rate »" \
        | sed "s/\*//" \
    )
    [ -z "$rate" ] \
        && exit 0

    xrandr \
        --output "$primary" \
        --mode "$mode" \
        --rate "$rate"
}

rotate() {
    display "$select »"

    direction=$(printf "%s\n" \
        "normal" \
        "left" \
        "right" \
        "inverted" \
        | dmenu -c -bw 1 -l 4 -i -p "direction »" \
    )
    [ -z "$direction" ] \
        && exit 0

    xrandr \
        --output "$primary" \
        --rotate "$direction"
}

scale_dimensions() {
    display "$select »"

    scale=$(printf "%s\n" \
        "1.0x1.0" \
        "0.7x0.7" \
        "0.5x0.5" \
        "0.3x0.3" \
        "0.1x0.1" \
        | dmenu -c -bw 1 -l 5 -i -p "scale »" \
    )
    [ -z "$scale" ] \
        && exit 0

    xrandr \
        --output "$primary" \
        --scale "$scale"
}

extend() {
    display "primary »"

    orientation=$(printf "%s\n" \
        "above" \
        "right" \
        "below" \
        "left" \
        | dmenu -c -bw 1 -l 4 -r -i -p "position of $secondary »" \
        | sed "s/left/left-of/;s/right/right-of/" \
    )
    [ -z "$orientation" ] \
        && exit 0

    xrandr \
        --output "$primary" --auto --primary \
        --output "$secondary" --"$orientation" "$primary" --auto
}

mirror() {
    display "primary »"

    resolution() {
        xrandr \
            | grep "^$1" \
            | grep -oE '[0-9]{1,4}x[0-9]{1,4}'
    }

    resolution_x() {
        printf "%d" "${1%%x*}"
    }

    resolution_y() {
        printf "%d" "${1##*x}"
    }

    scale() {
        printf "%s\n" "$1 / $2" \
            | bc -l
    }

    resolution_primary=$(resolution "$primary")
    resolution_secondary=$(resolution "$secondary")

    scale_x=$(scale \
        "$(resolution_x "$resolution_primary")" \
        "$(resolution_x "$resolution_secondary")" \
    )
    scale_y=$(scale \
        "$(resolution_y "$resolution_primary")" \
        "$(resolution_y "$resolution_secondary")" \
    )

    xrandr \
        --output "$primary" --auto --primary \
        --scale "1.0x1.0" \
        --output "$secondary" --auto \
        --same-as "$primary" \
        --scale "$scale_x"x"$scale_y"
}

# menu
select=$(printf "%s\n" \
    "saved settings" \
    "» edit saved settings" \
    "refresh rate" \
    "rotate" \
    "scale" \
    "extend" \
    "mirror" \
    "$connected_displays" \
    | dmenu -c -bw 1 -l 10 -r -i -p "display »"
    ) && \
    case "$select" in
        "saved settings")
            saved_settings
            ;;
        "» edit saved settings")
            $edit "$saved_settings_file"
            ;;
        "refresh rate")
            refresh_rate
            ;;
        "rotate")
            rotate
            ;;
        "scale")
            scale_dimensions
            ;;
        "extend")
            extend
            ;;
        "mirror")
            mirror
            ;;
    *)
        eval xrandr \
            --output "$select" --auto --primary \
            "$(printf "%s" "$all_displays" \
                | grep -v "$select" \
                | awk '{print "--output", $1, "--off"}' \
                | tr '\n' ' ' \
            )"
        ;;
    esac

# maintenance after setup displays
[ -n "$select" ] \
    && systemctl --user restart wallpaper.service \
    && systemctl --user restart polybar.service
