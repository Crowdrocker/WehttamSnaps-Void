# Void Linux Post-Install & Runit Guide

## Repositories
Enable nonfree and multilib repositories before installing packages:
```bash
sudo xbps-install -Sy void-repo-nonfree void-repo-multilib void-repo-multilib-nonfree
sudo xbps-install -Syu
```

## Runit Services
- **Enable:** `sudo ln -s /etc/sv/<service> /var/service/`
- **Disable:** `sudo rm -f /var/service/<service>`
- **Important:** Do **not** enable `/etc/sv/elogind` as a separate service—`dbus` launches `elogind` on demand. Enabling both causes an `elogind is already running` console loop.
- **Networking:** Remove `dhcpcd` and `wpa_supplicant` symlinks from `/var/service/` before enabling `NetworkManager`.
EOF

cat << 'EOF' > "$VOID_REPO/docs/02-audio-and-pipewire.md"
# PipeWire & Dual-PC Audio Routing on Void Linux

## Preventing Duplicate WirePlumber Instances
If user-level `runsv` supervises `pipewire`, `pipewire-pulse`, and `wireplumber`, do **not** symlink `10-wireplumber.conf` or `20-pipewire-pulse.conf` into `/etc/pipewire/pipewire.conf.d/`, and do not add duplicate `.desktop` files in `~/.config/autostart/`. Running two `WirePlumber` instances locks USB audio devices.

## Dual-PC Capture Card Split
Stow the `pipewire` package (`stow -v pipewire`) to load `~/.config/pipewire/pipewire.conf.d/99-stream-split.conf`, creating the **Headphones + HDMI Capture Split** sink for simultaneous HyperX headset and HDMI capture card output.
