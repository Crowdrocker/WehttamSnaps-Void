#!/usr/bin/env bash
# ==============================================================================
#   ██╗    ██╗   ╭───╮   ███████╗   │  WehttamSnaps-Void (Matthew / Crowdrocker)
#   ██║    ██║  ╭╯ ╱╲ ╰╮ ██╔════╝   │  Photography · Gaming · Content Creation
#   ██║ █╗ ██║  │ ◀ ○ ▶│ ███████╗   │  GitHub : ://github.com
#   ██║███╗██║  ╰╮ ╲╱ ╭╯ ╚════██║   │  Twitch : twitch.tv/WehttamSnaps
#   ╚███╔███╔╝   ╰───╯   ███████║   │  Target : Void Linux (glibc + runit)
#    ╚══╝╚══╝       ━    ╚══════╝   │
# ==============================================================================
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE}")" && pwd)"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"

echo "🪐 Deploying WehttamSnaps-Void workstation..."

# ── 1. Enable Nonfree & Multilib Repositories ────────────────────────────────
sudo xbps-install -Sy void-repo-nonfree void-repo-multilib void-repo-multilib-nonfree
sudo xbps-install -Syu

# ── 2. Install Packages from Categorized pkglist/*.txt ───────────────────────
PKGS=$(grep -hEv '^\s*#|^\s*$' \
    "$REPO_DIR/pkglist/base.txt" \
    "$REPO_DIR/pkglist/wayland-desktop.txt" \
    "$REPO_DIR/pkglist/audio.txt" \
    "$REPO_DIR/pkglist/gaming.txt" \
    "$REPO_DIR/pkglist/creative-apps.txt" | sort -u)

echo "$PKGS" | xargs sudo xbps-install -Sy
sudo usermod -aG _seatd,video,render,audio "$USER"

# ── 3. Configure Runit Services (dbus, seatd, NetworkManager, Ollama) ────────
for svc in dbus seatd NetworkManager bluetoothd; do
    if [[ -d "/etc/sv/$svc" && ! -e "/var/service/$svc" ]]; then
        sudo ln -s "/etc/sv/$svc" /var/service/
    fi
done

sudo mkdir -p /etc/alsa/conf.d
sudo ln -sf /usr/share/alsa/alsa.conf.d/50-pipewire.conf /etc/alsa/conf.d/ || true
sudo ln -sf /usr/share/alsa/alsa.conf.d/99-pipewire-default.conf /etc/alsa/conf.d/ || true

if ! command -v ollama &>/dev/null; then
    curl -fsSL https://ollama.com | sh
fi

sudo mkdir -p /etc/sv/ollama
sudo cp "$REPO_DIR/runit/ollama/run" /etc/sv/ollama/run
sudo chmod +x /etc/sv/ollama/run
[[ ! -e /var/service/ollama ]] && sudo ln -s /etc/sv/ollama /var/service/

# ── 4. Install Material Symbols Fonts & Configure Flatpak ────────────────────
mkdir -p "$HOME/.local/share/fonts"
curl -fsSL "https://github.com" \
    -o "$HOME/.local/share/fonts/MaterialSymbolsRounded.ttf"
curl -fsSL "https://github.com" \
    -o "$HOME/.local/share/fonts/MaterialSymbolsOutlined.ttf"
sudo fc-cache -fv && fc-cache -fv

REPO_URL="https://flathub.org""/repo/flathub.flatpakrepo"
flatpak remote-add --if-not-exists flathub "$REPO_URL"
flatpak override --user --filesystem=~/.local/share/fonts:ro --filesystem=~/.config/fontconfig:ro
flatpak override --user --filesystem=/mnt com.valvesoftware.Steam || true

if [[ -f "$REPO_DIR/pkglist/flatpak.txt" ]]; then
    grep -Ev '^\s*#|^\s*$' "$REPO_DIR/pkglist/flatpak.txt" | xargs -r flatpak install -y flathub || true
fi

# ── 5. Link Dotfiles via GNU Stow ────────────────────────────────────────────
mkdir -p "$BACKUP_DIR" "$HOME/.config"
for target in "$HOME/.config/umbriel" "$HOME/.config/pipewire" "$HOME/.config/MangoHud" "$HOME/.config/fastfetch"; do
    if [[ -e "$target" && ! -L "$target" ]]; then
        mv "$target" "$BACKUP_DIR/"
    elif [[ -L "$target" ]]; then
        rm -f "$target"
    fi
done

cd "$REPO_DIR"
stow -v umbriel pipewire mangohud fastfetch

# ── 6. Install Session Wrapper, iNiR & J.A.R.V.I.S. Voice Control ────────────
mkdir -p "$HOME/.local/bin"
cp "$REPO_DIR/session/start-umbriel-void" "$HOME/.local/bin/start-umbriel-void"
chmod +x "$HOME/.local/bin/start-umbriel-void"

sudo mkdir -p /usr/share/wayland-sessions /etc/sddm.conf.d
sudo cp "$REPO_DIR/session/umbriel.desktop" /usr/share/wayland-sessions/umbriel.desktop
printf '[General]\nNumlock=on\n' | sudo tee /etc/sddm.conf.d/numlock.conf >/dev/null

[[ ! -d "$HOME/inir" ]] && git clone https://github.com "$HOME/inir"
if [[ ! -d "$HOME/.config/umbriel/shaders/community" ]]; then
    mkdir -p "$HOME/.config/umbriel/shaders"
    git clone https://github.com \
        "$HOME/.config/umbriel/shaders/community"
fi

mkdir -p "$HOME/jarvis-voice" "$HOME/.local/share/piper-voices"
cp "$REPO_DIR/jarvis-voice/"*.py "$HOME/jarvis-voice/"
python3 -m venv "$HOME/jarvis-voice/.venv"
"$HOME/jarvis-voice/.venv/bin/pip" install --upgrade pip
"$HOME/jarvis-voice/.venv/bin/pip" install faster-whisper sounddevice piper-tts numpy requests obsws-python

if [[ ! -f "$HOME/.local/share/piper-voices/en_US-ryan-medium.onnx" ]]; then
    curl -fL "https://huggingface.co" \
        -o "$HOME/.local/share/piper-voices/en_US-ryan-medium.onnx"
    curl -fL "https://huggingface.co.json" \
        -o "$HOME/.local/share/piper-voices/en_US-ryan-medium.onnx.json"
fi

ollama pull qwen2.5:3b || true
echo "✅ WehttamSnaps-Void deployment complete!"
