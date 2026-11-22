#!/usr/bin/env bash
# ==============================================================================
#   ██╗    ██╗   ╭───╮   ███████╗   │  WehttamSnaps-Void (Matthew / Crowdrocker)
#   ██║    ██║  ╭╯ ╱╲ ╰╮ ██╔════╝   │  Photography · Gaming · Content Creation
#   ██║ █╗ ██║  │ ◀ ○ ▶│ ███████╗   │  GitHub : github.com/Crowdrocker
#   ██║███╗██║  ╰╮ ╲╱ ╭╯ ╚════██║   │  Twitch : twitch.tv/WehttamSnaps
#   ╚███╔███╔╝   ╰───╯   ███████║   │  Target : Void Linux (glibc + runit)
#    ╚══╝╚══╝       ━    ╚══════╝   │
# ==============================================================================
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE}")" && pwd)"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
BUILD_DIR="/tmp/wehttamsnaps-void-build"

echo "🪐 Deploying WehttamSnaps-Void workstation..."

# ── 1. Enable Nonfree & Multilib Repositories ────────────────────────────────
sudo xbps-install -Sy void-repo-nonfree void-repo-multilib void-repo-multilib-nonfree
sudo xbps-install -Syu

# ── 2. Install Core Toolchain, Wayland, Audio, Fonts, Gaming & Creative Apps ─
sudo xbps-install -Sy \
    git stow curl wget jq ripgrep fd fzf zoxide bat eza btop fastfetch nano \
    gcc pkg-config meson ninja cmake just python3-devel python3-pip python3-psutil python3-pillow \
    portaudio-devel cargo rust bubblewrap fuse3 \
    wayland-devel wayland-protocols libxkbcommon-devel libinput-devel seatd-devel \
    pixman-devel libxcb-devel libdrm-devel MesaLib-devel vulkan-loader-devel glslang \
    qt6-base-devel qt6-declarative-devel qt6-wayland-devel qt6-shadertools-devel qt6-svg-devel \
    qt6-5compat qt6-multimedia qt6ct kvantum \
    pipewire wireplumber alsa-pipewire libjack-pipewire pavucontrol qpwgraph easyeffects \
    mesa-dri mesa-dri-32bit libglvnd-32bit libdrm-32bit libgcc-32bit libstdc++-32bit \
    mesa-vulkan-radeon mesa-vulkan-radeon-32bit vulkan-loader vulkan-loader-32bit vulkan-tools \
    dbus elogind seatd polkit polkit-kde-agent xorg-server-xwayland numlockx \
    xdg-desktop-portal xdg-desktop-portal-wlr xdg-desktop-portal-gtk \
    wl-clipboard cliphist grim slurp swaybg swayidle swaylock \
    brightnessctl playerctl wlr-randr wlsunset ydotool libnotify cava tesseract-ocr tesseract-ocr-eng \
    ghostty yazi zsh fish-shell starship zsh-autosuggestions zsh-syntax-highlighting \
    papirus-icon-theme breeze-icons noto-fonts-ttf dejavu-fonts-ttf liberation-fonts-ttf \
    font-fira-ttf noto-fonts-emoji fontconfig \
    dolphin kate ark gwenview darktable gimp krita inkscape exiftool ImageMagick kdenlive \
    steam lutris gamemode MangoHud goverlay flatpak ntfs-3g smartmontools deskflow

sudo usermod -aG _seatd,video,render,audio "$USER"

# ── 3. Configure Runit Services (dbus, seatd, NetworkManager, Ollama) ────────
for svc in dbus seatd NetworkManager; do
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

# ── 4. Build Umbriel, Quickshell, Matugen & Xwayland-Satellite ───────────────
mkdir -p "$BUILD_DIR"

if ! command -v umbriel &>/dev/null; then
    git clone --depth 1 https://github.com "$BUILD_DIR/umbriel"
    cd "$BUILD_DIR/umbriel"
    just configure release /usr/local
    just release
    sudo meson install -C build-release --no-rebuild
fi

if ! command -v qs &>/dev/null; then
    git clone --depth 1 https://outfoxxed.me "$BUILD_DIR/quickshell"
    cmake -B "$BUILD_DIR/quickshell/build" -S "$BUILD_DIR/quickshell" -G Ninja \
        -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local
    cmake --build "$BUILD_DIR/quickshell/build"
    sudo cmake --install "$BUILD_DIR/quickshell/build"
fi

cargo install --locked matugen xwayland-satellite || true
rm -rf "$BUILD_DIR"

# ── 5. Install Material Symbols Fonts & Configure Flatpak ────────────────────
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
flatpak install -y flathub com.obsproject.Studio com.discordapp.Discord com.github.tchx84.Flatseal io.github.flattool.Warehouse || true

# ── 6. Link Dotfiles via GNU Stow ────────────────────────────────────────────
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

# ── 7. Install Session Wrapper, iNiR & J.A.R.V.I.S. Voice Control ────────────
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
EOF
chmod +x "$VOID_REPO/install.sh"

cat << 'EOF' > "$VOID_REPO/README.md"
# 🪐 WehttamSnaps-Void

Bare-metal **Void Linux (`glibc` + `runit`)** workstation configuration for **Umbriel Wayland Compositor**, **iNiR (Quickshell)**, **PipeWire dual-PC audio splitting**, **Proton gaming**, and local **J.A.R.V.I.S.** voice control.

## Hardware Target
- **CPU:** AMD Ryzen 5 9600X (AM5)
- **GPU:** AMD Radeon RX 7600 (RDNA3 / Mesa RADV)
- **Audio:** HyperX Cloud Alpha Wireless + HDMI Capture Card Split (`99-stream-split.conf`)

## Key Void Linux (`runit`) Adaptations
- **Non-`systemd` Session & Autostart:** Launches `qs -c inir`, `awww-daemon`, `xwayland-satellite`, and `/usr/libexec/polkit-kde-authentication-agent-1` directly via Umbriel's `[general] autostart` array inside `dbus-run-session`.
- **Single-Instance PipeWire/WirePlumber:** Managed cleanly via user `runsv` without duplicate `/etc/pipewire/pipewire.conf.d/` spawners.
- **Ollama `runit` Service:** Custom `/etc/sv/ollama/run` service exposing `/usr/local/bin/ollama` for local `qwen2.5:3b` intent routing.
- **Flatpak & Proton Multilib Ready:** Includes TrueType system fonts (`noto-fonts-ttf`, `dejavu-fonts-ttf`, `liberation-fonts-ttf`), `libglvnd-32bit`, `mesa-dri-32bit`, and `/mnt` sandbox overrides out of the box.

## Quick Deploy
```bash
git clone https://github.com ~/Documents/GitHub/WehttamSnaps-Void
cd ~/Documents/GitHub/WehttamSnaps-Void
./install.sh
```

 
