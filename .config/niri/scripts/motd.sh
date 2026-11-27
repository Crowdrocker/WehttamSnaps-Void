#!/usr/bin/env bash

# ── COLOR DEFINITIONS (Cyberpunk Neon Palette) ──
C_CYAN="\e[1;36m"
C_MAGENTA="\e[1;35m"
C_GREEN="\e[1;32m"
C_DIM="\e[90m"
C_NC="\e[0m"

# Print Header Block (79 columns wide to match table)
echo -e "${C_CYAN}╭─────────────────────────────────────────────────────────────────────────────╮${C_NC}"
echo -e "${C_CYAN}│${C_NC}  ${C_MAGENTA}🪐 WEHTTAMSNAPS NIRI + iNiR SYSTEM CORE INTERFACE ACTIVATED${C_NC}                ${C_CYAN}│${C_NC}"
echo -e "${C_CYAN}╰─────────────────────────────────────────────────────────────────────────────╯${C_NC}"

# Section 1: Window Management & Display Navigation
printf "  ${C_CYAN}%-14s${C_NC} %-20s │ ${C_MAGENTA}%-18s${C_NC} %-20s\n" \
    "Mod+Return/T" "Ghostty Terminal" \
    "Mod+Alt+H"    "Focus Game Monitor" \
    "Mod+E"        "Yazi File Manager" \
    "Mod+Alt+L"    "Focus Stream Monitor" \
    "Mod+Q"        "Close Active Win" \
    "Mod+Alt+Shift+H/L" "Throw Window L/R" \
    "Mod+Shift+R"  "Reload Niri Config" \
    "Mod+Alt+G"    "Game Launcher Menu"

echo -e "  ${C_DIM}─────────────────────────────────────────────────────────────────────────────${C_NC}"

# Section 2: PipeWire Audio Matrix Profile Shifts & App Containers
printf "  ${C_CYAN}%-14s${C_NC} %-20s │ ${C_MAGENTA}%-18s${C_NC} %-20s\n" \
    "set-game"     "Mix Streaming Bal" \
    "Mod+Ctrl+T"   "Twitch Container" \
    "set-chill"    "Mix Ambient Mode" \
    "Mod+Ctrl+Y"   "YouTube Container" \
    "audio-reset"  "Flush Sound Pipes" \
    "Mod+Ctrl+D"   "Discord Container" \
    "audio-graph"  "Open qpwgraph Panel" \
    "Mod+Ctrl+S"   "Spotify Container"

echo -e "  ${C_DIM}─────────────────────────────────────────────────────────────────────────────${C_NC}"

# Section 3: Custom Shell & Void Linux Utilities
printf "  ${C_GREEN}%-12s${C_NC} %-22s │ ${C_GREEN}%-18s${C_NC} %-20s\n" \
    "y"          "Yazi + Auto-CD" \
    "update"     "XBPS Full Upgrade" \
    "nvm"        "Nano Current Dir" \
    "clean"      "Purge Cache/Kernels" \
    "snv"        "Sudo Nano Editor" \
    "niri-check" "Validate Niri + iNiR" \
    "sys"        "Btop System Monitor" \
    "inir restart" "Restart iNiR Shell"

echo ""
