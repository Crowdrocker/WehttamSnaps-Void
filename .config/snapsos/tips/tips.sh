#!/usr/bin/env bash

STATE_FILE="$HOME/.config/tips.state"
TIPS_FILE="$HOME/.config/snapsos/tips/tips.list"

[[ ! -e "$STATE_FILE" ]] && echo "standard" > "$STATE_FILE"
[[ ! -f "$TIPS_FILE" ]] && exit 0

SETTING=$(cat "$STATE_FILE")
INPUT="${1:-}"

print_tip() {
    local tip
    tip=$(shuf -n 1 "$TIPS_FILE")
    if [[ "$SETTING" == "cow" ]] && command -v cowsay >/dev/null 2>&1; then
        if command -v lolcat >/dev/null 2>&1; then
            cowsay -r "$tip" | lolcat
        else
            cowsay -r "$tip"
        fi
    else
        echo -e "\e[1;36m💡 $tip\e[0m"
    fi
}

case "$INPUT" in
    ""|"random")
        print_tip
        ;;
    "startup-mini")
        echo -e "\e[90m💡 $(shuf -n 1 "$TIPS_FILE")\e[0m"
        ;;
    "list")
        if command -v fzf >/dev/null 2>&1; then
            fzf --prompt="SNAPS-OS Tips > " --height=60% --layout=reverse --border < "$TIPS_FILE"
        else
            cat "$TIPS_FILE"
        fi
        ;;
    "toggle")
        if [[ "$SETTING" == "standard" ]]; then
            echo "cow" > "$STATE_FILE"
            echo "Tips mode set to: cow"
        else
            echo "standard" > "$STATE_FILE"
            echo "Tips mode set to: standard"
        fi
        ;;
    "standard"|"cow")
        echo "$INPUT" > "$STATE_FILE"
        print_tip
        ;;
    *)
        echo "Usage: tips.sh [random|startup-mini|list|toggle|standard|cow]"
        ;;
esac

