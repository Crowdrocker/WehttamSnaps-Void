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
- **Core Services:** Enable `dbus`, `NetworkManager`, `sddm`, and `zramen`.
- **Important:** Do **not** enable `/etc/sv/elogind` as a separate service—`dbus` launches `elogind` on demand. Enabling both causes an `elogind is already running` console loop.
- **Networking:** Remove `dhcpcd` and `wpa_supplicant` symlinks from `/var/service/` before enabling `NetworkManager`.
