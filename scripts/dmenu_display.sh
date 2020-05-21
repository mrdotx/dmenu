#!/bin/sh

# path:       /home/klassiker/.local/share/repos/dmenu/scripts/dmenu_display.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/dmenu
# date:       2020-05-21T10:56:54+0200

# second display
sec_disp() {
    mir=$(printf "no\\nyes" | dmenu -l 2 -c -bw 2 -r -i -p "mirroring?")
    if [ "$mir" = "yes" ]; then
        ext=$(printf "%s" "$disp" | dmenu -l 4 -c -bw 2 -r -i -p "resolution from:")
        int=$(printf "%s" "$disp" | grep -v "$ext")

        res_ext=$(xrandr --query | sed -n "/^$ext/,/\+/p" | tail -n 1 | awk '{print $1}')
        res_int=$(xrandr --query | sed -n "/^$int/,/\+/p" | tail -n 1 | awk '{print $1}')

        res_ext_x=$(printf "%s" "$res_ext" | sed 's/x.*//')
        res_ext_y=$(printf "%s" "$res_ext" | sed 's/.*x//')
        res_int_x=$(printf "%s" "$res_int" | sed 's/x.*//')
        res_int_y=$(printf "%s" "$res_int" | sed 's/.*x//')

        sc_x=$(printf "%s\n" "$res_ext_x / $res_int_x" | bc -l)
        sc_y=$(printf "%s\n" "$res_ext_y / $res_int_y" | bc -l)

        xrandr --output "$ext" --auto --scale 1.0x1.0 --output "$int" --auto --same-as "$ext" --scale "$sc_x"x"$sc_y"
    else
        prim=$(printf "%s" "$disp" | dmenu -l 4 -c -bw 2 -i -p "primary:")
        sec=$(printf "%s" "$disp" | grep -v "$prim")
        ori=$(printf "right\\nleft" | dmenu -l 2 -c -bw 2 -r -i -p "side of $sec?")
        xrandr --output "$prim" --auto --scale 1.0x1.0 --output "$sec" --"$ori"-of "$prim" --auto --scale 1.0x1.0
    fi
}

# saved settings
sav_set() {
    sel=$(find "$HOME/.local/share/repos/shell/screenlayout/" -iname "*.sh" | cut -d / -f 9 | sed "s/.sh//g" | sort | dmenu -l 10 -c -bw 2 -r -i -p "display:")
    "$HOME/.local/share/repos/shell/screenlayout/$sel.sh"
}

# get disp
all=$(xrandr -q | grep "connected")
disp=$(printf "%s" "$all" | grep " connected" | awk '{print $1}')

# menu
sel=$(printf "saved settings\\nsecond display\\n%s\\nmanual selection\\naudio toggle" "$disp" | dmenu -l 8 -c -bw 2 -r -i -p "display:") && \
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
            "$(printf "%s" "$all" | grep -v "$sel" | awk '{print "--output", $1, "--off"}' | tr '\n' ' ')"
        ;;
    esac

# maintenance after setup displays
if [ -n "$sel" ] && [ ! "$sel" = "audio toggle" ]; then
    systemctl --user start xwallpaper.service
    systemctl --user restart polybar.service
fi
