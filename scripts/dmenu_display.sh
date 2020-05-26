#!/bin/sh

# path:       /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_display.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/dmenu
# date:       2020-05-26T12:28:53+0200

script=$(basename "$0")
help="$script [-h/--help] -- script to manage displays with arandr/xrandr
  Usage:
    depending on how the script is named,
    it will be executed either with dmenu or with rofi

  Examples:
    dmenu_display.sh
    rofi_display.sh"

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    printf "%s\n" "$help"
    exit 0
fi

case $script in
    dmenu_*)
        label="display:"
        menu="dmenu -l 8 -c -bw 2 -r -i"
        label_mir="mirroring?"
        menu_mir="dmenu -l 2 -c -bw 2 -r -i"
        label_ext="resolution from:"
        menu_ext="dmenu -l 4 -c -bw 2 -r -i"
        label_prim="primary:"
        menu_prim="dmenu -l 4 -c -bw 2 -r -i"
        label_ori="side of"
        menu_ori="dmenu -l 2 -c -bw 2 -r -i"
        label_sav_set="display:"
        menu_sav_set="dmenu -l 10 -c -bw 2 -r -i"
        ;;
    rofi_*)
        label=""
        menu="rofi -m -1 -l 3 -columns 2 -theme klassiker-center -dmenu -i"
        label_mir="mirroring?"
        menu_mir="rofi -m -1 -l 1 -columns 2 -theme klassiker-center -dmenu -i"
        label_ext="resolution from:"
        menu_ext="rofi -m -1 -l 2 -columns 2 -theme klassiker-center -dmenu -i"
        label_prim="primary:"
        menu_prim="rofi -m -1 -l 2 -columns 2 -theme klassiker-center -dmenu -i"
        label_ori="side of"
        menu_ori="rofi -m -1 -l 1 -columns 2 -theme klassiker-center -dmenu -i"
        label_sav_set=""
        menu_sav_set="rofi -m -1 -l 3 -columns 2 -theme klassiker-center -dmenu -i"
        ;;
    *)
        printf "%s\n" "$help"
        exit 1
        ;;
esac

# second display
sec_disp(){
    mir=$(printf "no\\nyes" \
        | $menu_mir -p "$label_mir" \
    )
    if [ "$mir" = "yes" ]; then
        ext=$(printf "%s" "$disp" \
            | $menu_ext -p "$label_ext" \
        )
        int=$(printf "%s" "$disp" \
            | grep -v "$ext" \
        )

        res_ext=$(xrandr --query \
            | sed -n "/^$ext/,/\+/p" \
            | tail -n 1 \
            | awk '{print $1}' \
        )
        res_int=$(xrandr --query \
            | sed -n "/^$int/,/\+/p" \
            | tail -n 1 \
            | awk '{print $1}' \
        )

        res_ext_x=$(printf "%s" "$res_ext" \
            | sed 's/x.*//' \
        )
        res_ext_y=$(printf "%s" "$res_ext" \
            | sed 's/.*x//' \
        )
        res_int_x=$(printf "%s" "$res_int" \
            | sed 's/x.*//' \
        )
        res_int_y=$(printf "%s" "$res_int" \
            | sed 's/.*x//' \
        )

        sc_x=$(printf "%s\n" "$res_ext_x / $res_int_x" \
            | bc -l \
        )
        sc_y=$(printf "%s\n" "$res_ext_y / $res_int_y" \
            | bc -l \
        )

        xrandr --output "$ext" --auto --scale 1.0x1.0 --output "$int" --auto --same-as "$ext" --scale "$sc_x"x"$sc_y"
    else
        prim=$(printf "%s" "$disp" \
            | $menu_prim -p "$label_prim" \
        )
        sec=$(printf "%s" "$disp" \
            | grep -v "$prim" \
        )
        ori=$(printf "right\\nleft" \
            | $menu_ori -p "$label_ori $sec?" \
        )
        xrandr --output "$prim" --auto --scale 1.0x1.0 --output "$sec" --"$ori"-of "$prim" --auto --scale 1.0x1.0
    fi
}

# saved settings
sav_set(){
    sel=$(find "$HOME/.local/share/repos/shell/screenlayout/" -iname "*.sh" \
        | cut -d / -f 9 \
        | sed "s/.sh//g" \
        | sort \
        | $menu_sav_set -p "$label_sav_set" \
    )
    "$HOME/.local/share/repos/shell/screenlayout/$sel.sh"
}

# get disp
all=$(xrandr -q \
    | grep "connected" \
)
disp=$(printf "%s" "$all" \
    | grep " connected" \
    | awk '{print $1}' \
)

# menu
sel=$(printf "saved settings\\nsecond display\\n%s\\nmanual selection\\naudio toggle" "$disp" \
    | $menu -p "$label"
    ) && \
    case "$sel" in
        saved?settings)
            sav_set
        ;;
        second?display)
            sec_disp
        ;;
        manual?selection)
            arandr
        ;;
        audio?toggle)
            audio.sh -tog
        ;;
    *)
        eval xrandr --output "$sel" --auto --scale 1.0x1.0 \
            "$(printf "%s" "$all" \
                | grep -v "$sel" \
                | awk '{print "--output", $1, "--off"}' \
                | tr '\n' ' ' \
            )"
        ;;
    esac

# maintenance after setup displays
if [ -n "$sel" ] && [ ! "$sel" = "audio toggle" ]; then
    systemctl --user start xwallpaper.service
    systemctl --user restart polybar.service
fi
