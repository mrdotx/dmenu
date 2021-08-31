#!/bin/sh

# path:   /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_display.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/dmenu
# date:   2021-08-31T20:42:46+0200

# config
saved_settings_file="$HOME/.local/share/repos/dmenu/scripts/data/screen-layouts"
scale_dimensions="1.0x1.0"
edit="$TERMINAL -e $EDITOR"

all_displays=$(xrandr \
    | grep "connected" \
)
connected_displays=$(printf "%s" "$all_displays" \
    | grep " connected" \
    | cut -d ' ' -f1 \
    | sort -k3 -r \
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

    select=$(printf "%s" "$(cat "$saved_settings_file")" \
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

    orientation=$(printf "above\nright\nbelow\nleft" \
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
            | sed -n "/^$1/,/\+/p" \
            | tail -n 1 \
            | awk '{print $1}'
    }

    resolution_x() {
        printf "%s" "$1" \
            | sed "s/x.*//"
    }

    resolution_y() {
        printf "%s" "$1" \
            | sed "s/.*x//"
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
        --output "$primary" --auto \
        --scale "$scale_dimensions" \
        --output "$secondary" --auto \
        --same-as "$primary" \
        --scale "$scale_x"x"$scale_y"
}

# menu
select=$(printf "%s\n" \
    "saved settings" \
    "refresh rate" \
    "rotate" \
    "extend" \
    "mirror" \
    "$connected_displays" \
    "== edit saved settings ==" \
    "audio toggle" \
    | dmenu -l 10 -c -bw 2 -r -i -p "display »"
    ) && \
    case "$select" in
        "saved settings")
            saved_settings
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
        "== edit saved settings ==")
            $edit "$saved_settings_file"
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
