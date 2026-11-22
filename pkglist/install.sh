#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USER_NAME="${SUDO_USER:-$USER}"
USER_HOME="$(getent passwd "$USER_NAME" | cut -d: -f6)"
USER_UID="$(id -u "$USER_NAME")"
USER_GID="$(id -g "$USER_NAME")"

echo "==> [1/8] Enabling Void nonfree & multilib repositories..."
sudo xbps-install -Syu
sudo xbps-install -Sy void-repo-multilib void-repo-multilib-nonfree void-repo-nonfree
sudo xbps-install -Syu

echo "==> [2/8] Installing XBPS packages from pkglist/void-packages.txt..."
grep -vE '^\s*#|^\s*$' "$REPO_DIR/pkglist/void-packages.txt" | xargs sudo xbps-install -Sy
sudo ldconfig

echo "==> [3/8] Configuring runit services, user groups & NumLock..."
sudo rm -f /var/service/dhcpcd /var/service/wpa_supplicant
for svc in dbus NetworkManager sddm zramen; do
  [ -L "/var/service/$svc" ] || sudo ln -s "/etc/sv/$svc" /var/service/
done

sudo usermod -aG wheel,audio,video,network,kvm,users "$USER_NAME"

# Enable NumLock on SDDM login screen
sudo mkdir -p /etc/sddm.conf.d
printf "[General]\nNumlock=on\n" | sudo tee /etc/sddm.conf.d/numlock.conf >/dev/null

# Ensure /run/user/<UID> and TTY NumLock persist across boots
if ! grep -q "/run/user/$USER_UID" /etc/rc.local 2>/dev/null; then
  cat << EOF | sudo tee -a /etc/rc.local >/dev/null
mkdir -p /run/user/$USER_UID
chown $USER_NAME:$USER_NAME /run/user/$USER_UID
chmod 700 /run/user/$USER_UID
for tty in /dev/tty[1-6]; do /usr/bin/setleds -D +num < "\$tty" >/dev/null 2>&1; done
EOF
fi

# XDG Autostart symlinks for PipeWire
sudo mkdir -p /etc/xdg/autostart
sudo ln -sf /usr/share/applications/pipewire.desktop /etc/xdg/autostart/
sudo ln -sf /usr/share/applications/pipewire-pulse.desktop /etc/xdg/autostart/
sudo ln -sf /usr/share/applications/wireplumber.desktop /etc/xdg/autostart/

echo "==> [4/8] Applying kernel gaming limits & RX 7600 DXVK pin..."
echo "vm.max_map_count = 2147483642" | sudo tee /etc/sysctl.d/80-gamecompatibility.conf >/dev/null
sudo sysctl --system

if ! grep -q "nofile 524288" /etc/security/limits.conf; then
  printf "* hard nofile 524288\n* soft nofile 524288\n" | sudo tee -a /etc/security/limits.conf >/dev/null
fi

if ! grep -q "DXVK_FILTER_DEVICE_NAME" /etc/environment 2>/dev/null; then
  echo 'DXVK_FILTER_DEVICE_NAME="AMD Radeon RX 7600"' | sudo tee -a /etc/environment >/dev/null
fi

mount_secondary_drives() {
  echo "==> [5/8] Auto-mounting secondary drives by label in /etc/fstab..."
  local drives=(
    "LINUXDRIVE:ext4:defaults,noatime,nofail:2"
    "GAMEDRIVE:ext4:defaults,noatime,nofail:2"
    "EXTRA1TB:ext4:defaults,noatime,nofail:2"
    "512GB:ntfs-3g:defaults,uid=$USER_UID,gid=$USER_GID,nofail:0"
    "WettamSnapsMain:ntfs-3g:defaults,uid=$USER_UID,gid=$USER_GID,nofail:0"
  )

  for entry in "${drives[@]}"; do
    IFS=':' read -r label fstype opts pass <<< "$entry"
    local uuid
    uuid=$(blkid -L "$label" 2>/dev/null | xargs -r blkid -s UUID -o value 2>/dev/null || true)

    if [ -n "$uuid" ]; then
      sudo mkdir -p "/mnt/$label"
      if ! grep -q "$uuid" /etc/fstab; then
        echo "UUID=$uuid  /mnt/$label  $fstype  $opts  0  $pass" | sudo tee -a /etc/fstab >/dev/null
        echo "  + Added $label ($uuid) -> /mnt/$label"
      else
        echo "  = $label already present in /etc/fstab"
      fi
    fi
  done

  sudo mount -a
  for ext_label in LINUXDRIVE GAMEDRIVE EXTRA1TB; do
    [ -d "/mnt/$ext_label" ] && sudo chown "$USER_NAME:$USER_NAME" "/mnt/$ext_label"
  done
}
mount_secondary_drives

echo "==> [6/8] Setting up Flathub & Faugus Launcher with Steam/drive overrides..."
flatpak remote-delete --force flathub 2>/dev/null || true
flatpak remote-add --if-not-exists flathub "https://flathub.org"
flatpak install -y flathub io.github.Faugus.faugus-launcher

sudo flatpak override io.github.Faugus.faugus-launcher \
  --filesystem=~/.local/share/Steam \
  --filesystem=~/.steam \
  --filesystem=/mnt \
  --talk-name=org.freedesktop.Flatpak \
  --env=DXVK_FILTER_DEVICE_NAME="AMD Radeon RX 7600"

echo "==> [7/8] Installing iNiR Quickshell desktop..."
if [ ! -d "$USER_HOME/iNiR" ]; then
  git clone https://github.com "$USER_HOME/iNiR"
fi
(cd "$USER_HOME/iNiR" && ./setup install)

echo "==> [8/8] Stowing personal Niri, Fastfetch & Starship configs..."
mkdir -p "$USER_HOME/.config"
stow -d "$REPO_DIR" -t "$USER_HOME" niri fastfetch starship 2>/dev/null || true

echo "==> Done! Reboot, pick 'Niri' in SDDM, and run 'inir doctor' to verify."
