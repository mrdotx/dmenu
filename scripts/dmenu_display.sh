#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_display.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2022-04-03T18:05:02+0200

# config
saved_settings_file="$HOME/.local/share/repos/dmenu/scripts/data/screen-layouts"
scale_dimensions="1.0x1.0"
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
        | dmenu -l 4 -c -bw 2 -r -i -p "$1" \
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

    get_value() {
        value=$(printf "%s" "$select" \
            | cut -d ';' -f"$1")
        printf "%s" "${value:-"$2"}"
    }

    select=$(printf "%s" "$(cat "$saved_settings_file")" \
        | dmenu -l 10 -c -bw 2 -i -p "$select »" \
    )
    [ -n "$select" ] \
        && xrandr \
            --output "$primary" --auto --primary \
            --mode "$(get_value 1 "1920x1080")" \
            --pos "$(get_value 2 "0x0")" \
            --rate "$(get_value 3 "60")" \
            --rotate "$(get_value 4 "normal")" \
            --scale "$scale_dimensions" \
            --output "$secondary" --auto \
            --mode "$(get_value 5 "1920x1080")" \
            --pos "$(get_value 6 "1920x0")" \
            --rate "$(get_value 7 "60")" \
            --rotate "$(get_value 8 "normal")" \
            --scale "$scale_dimensions"
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
        | dmenu -l 10 -c -bw 2 -r -i -p "rate »" \
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
        | dmenu -l 4 -c -bw 2 -i -p "direction »" \
    )
    [ -z "$direction" ] \
        && exit 0

    xrandr \
        --output "$primary" \
        --rotate "$direction"
}

extend() {
    display "primary »"

    orientation=$(printf "%s\n" \
        "above" \
        "right" \
        "below" \
        "left" \
        | dmenu -l 4 -c -bw 2 -r -i -p "position of $secondary »" \
        | sed "s/left/left-of/;s/right/right-of/" \
    )
    [ -z "$orientation" ] \
        && exit 0

    xrandr \
        --output "$primary" --auto --primary \
        --scale "$scale_dimensions" \
        --output "$secondary" --"$orientation" "$primary" --auto \
        --scale "$scale_dimensions"
}

mirror() {
    display "resolution from »"

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
        --scale "$scale_dimensions" \
        --output "$secondary" --auto \
        --same-as "$primary" \
        --scale "$scale_x"x"$scale_y"
}

# menu
select=$(printf "%s\n" \
    "saved settings" \
    "== edit saved settings ==" \
    "refresh rate" \
    "rotate" \
    "extend" \
    "mirror" \
    "$connected_displays" \
    | dmenu -l 10 -c -bw 2 -r -i -p "display »"
    ) && \
    case "$select" in
        "saved settings")
            saved_settings
            ;;
        "== edit saved settings ==")
            $edit "$saved_settings_file"
            ;;
        "refresh rate")
            refresh_rate
            ;;
        "rotate")
            rotate
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
            --scale "$scale_dimensions" \
            "$(printf "%s" "$all_displays" \
                | grep -v "$select" \
                | awk '{print "--output", $1, "--off"}' \
                | tr '\n' ' ' \
            )"
        ;;
    esac

# maintenance after setup displays
[ -n "$select" ] \
    && systemctl --user restart wallpaper.service
