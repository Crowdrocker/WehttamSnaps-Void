#!/usr/bin/env bash
target=${1:-area}
state_file="$HOME/.config/screenshot.state"

if [ ! -f "$state_file" ]; then
    mkdir -p "$(dirname "$state_file")"
    cat > "$state_file" <<- EOF
mode=clipboard
save_dir=$HOME/Pictures/Screenshots
editor=satty --filename
EOF
fi

mode=$(awk -F= '/^mode=/ {print $2}' "$state_file")
save_dir=$(awk -F= '/^save_dir=/ {print $2}' "$state_file")
editor=$(awk -F= '/^editor=/ {print $2}' "$state_file")
timestamp=$(date +%s)

play_shutter() {
    if [ -x /usr/bin/sound-system ]; then
        /usr/bin/sound-system screenshot
    fi
}

is_umbriel() {
    [[ -n "${UMBRIEL_SOCKET:-}" ]] || pgrep -x umbriel >/dev/null 2>&1
}

spawn_editor() {
    local target_file="$1"
    if is_umbriel; then
        umbriel msg spawn "$editor \"$target_file\"" >/dev/null 2>&1 &
    else
        niri msg action spawn -- $editor "$target_file"
    fi
}

case $target in
    output)
        if is_umbriel; then
            monitor=$(umbriel outputs --json 2>/dev/null | python3 -c "
import json,sys
outs=json.load(sys.stdin)
focused=[o['name'] for o in outs if o.get('focused')]
print(focused[0] if focused else outs[0]['name'])
" 2>/dev/null)
            if [ -n "$monitor" ]; then
                grim_args=(-o "$monitor")
                label="$(echo "$monitor" | sed 's/[-_.]/ /g')"
            else
                geom=$(slurp -o -f "%x,%y %wx%h") || exit 0
                grim_args=(-g "$geom")
                label="monitor"
            fi
        else
            monitor=$(niri msg -j focused-output | python3 -c "import json,sys; print(json.load(sys.stdin)['name'])")
            grim_args=(-o "$monitor")
            label="$(echo "$monitor" | sed 's/[-_.]/ /g')"
        fi
        ;;
    area)
        geom=$(slurp) || exit 0
        grim_args=(-g "$geom")
        label="selected area"
        ;;
    screen)
        grim_args=()
        label="all monitors"
        ;;
    active)
        if ! is_umbriel && niri msg action screenshot-window --help >/dev/null 2>&1 && [ "$mode" != "editor" ]; then
            niri msg action screenshot-window
            play_shutter
            exit 0
        fi
        geom=$(slurp) || exit 0
        grim_args=(-g "$geom")
        label="window"
        ;;
esac

case $mode in
    disk)
        mkdir -p "$save_dir"
        file="$save_dir/screenshot-$timestamp.png"
        grim "${grim_args[@]}" "$file" && play_shutter
        editor_name=$(echo "$editor" | awk '{print $1}' | sed 's|.*/||')
        action=$(notify-send \
            -a "Screenshot" \
            -i "$file" \
            -h "string:image-path:$file" \
            -t 10000 \
            -A "open=Open in $editor_name" \
            "Screenshot saved" \
            "$(basename "$file")")
        if [ "$action" = "open" ]; then
            spawn_editor "$file"
        fi
        ;;
    clipboard)
        file=$(mktemp /tmp/screenshot-XXXXXX.png)
        grim "${grim_args[@]}" "$file" && play_shutter
        wl-copy < "$file"
        notify-send \
            -a "Screenshot" \
            -i "$file" \
            -h "string:image-path:$file" \
            -t 3000 \
            "Screenshot copied" \
            "$label captured to clipboard"
        rm -f "$file"
        ;;
    editor)
        mkdir -p "$save_dir"
        file="$save_dir/screenshot-$timestamp.png"
        grim "${grim_args[@]}" "$file" && play_shutter
        spawn_editor "$file"
        notify-send \
            -a "Screenshot" \
            -i "$file" \
            -h "string:image-path:$file" \
            -t 3000 \
            "Opening in editor" \
            "$(basename "$file")"
        ;;
esac
