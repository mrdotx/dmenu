#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_display.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2021-08-30T20:43:27+0200

# config
screen_layouts_file="$HOME/.local/share/repos/dmenu/scripts/data/screen-layouts"
primary="HDMI2"
secondary="eDP1"
scale_dimensions="1.0x1.0"

all_displays=$(xrandr \
    | grep "connected" \
)
connected_displays=$(printf "%s" "$all_displays" \
    | grep " connected" \
    | cut -d ' ' -f1 \
)

default_settings() {
    select=$(printf "%s" "$(cat "$screen_layouts_file")" \
        | dmenu -l 10 -c -bw 2 -i -p "$select »" \
    )
    [ -n "$select" ] \
        && pri_mode=$(printf "%s" "$select" | cut -d ';' -f1) \
        && pri_pos=$(printf "%s" "$select" | cut -d ';' -f2) \
        && pri_rate=$(printf "%s" "$select" | cut -d ';' -f3) \
        && pri_rotate=$(printf "%s" "$select" | cut -d ';' -f4) \
        && sec_mode=$(printf "%s" "$select" | cut -d ';' -f5) \
        && sec_pos=$(printf "%s" "$select" | cut -d ';' -f6) \
        && sec_rate=$(printf "%s" "$select" | cut -d ';' -f7) \
        && sec_rotate=$(printf "%s" "$select" | cut -d ';' -f8) \
        && xrandr \
            --output "$primary" --auto --primary \
            --mode "${pri_mode:-1920x1080}" \
            --pos "${pri_pos:-0x0}" \
            --rate "${pri_rate:-60}" \
            --rotate "${pri_rotate:-normal}" \
            --scale "$scale_dimensions" \
            --output "$secondary" --auto \
            --mode "${sec_mode:-1920x1080}" \
            --pos "${sec_pos:-1920x0}" \
            --rate "${sec_rate:-60}" \
            --rotate "${sec_rotate:-normal}" \
            --scale "$scale_dimensions"
}

refresh_rate() {
    select=$(printf "%s\n" \
        "$connected_displays" \
        | dmenu -l 4 -c -bw 2 -r -i -p "$select »" \
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
        | dmenu -l 4 -c -bw 2 -r -i -p "$select »" \
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
        --scale "$scale_dimensions" \
        --output "$secondary" --"$orientation" "$primary" --auto \
        --scale "$scale_dimensions"
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
        --scale "$scale_dimensions" \
        --output "$internal" --auto \
        --same-as "$external" \
        --scale "$scale_x"x"$scale_y"
}

# menu
select=$(printf "%s\n" \
    "default settings" \
    "refresh rate" \
    "rotate" \
    "extend" \
    "mirror" \
    "$connected_displays" \
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
        "extend")
            extend
            ;;
        "mirror")
            mirror
            ;;
        "audio toggle")
            audio.sh -tog
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
    && [ "$select" != "audio toggle" ] \
    && systemctl --user restart wallpaper.service \
    && systemctl --user restart polybar.service \
    && polybar_rss.sh --update
