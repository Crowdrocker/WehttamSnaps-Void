# Void Linux post-install setup

These steps begin after the official Void Linux installer has finished and the
new system has booted. The repository installer expects a **glibc** Void
installation, a regular user with `sudo` access, and a working network
connection. It does not partition or format disks.

## 1. Get the repository

Log in as your regular user. The script requires working `sudo` access. If the
installer did not configure it, switch to root and enable it for your user
(replace `your-user` with the login name):

```bash
su -
xbps-install -S sudo
usermod -aG wheel your-user
visudo
```

In `visudo`, enable the `%wheel ALL=(ALL:ALL) ALL` rule if it is commented out,
save, then log out and back in. If Git is missing, install it after `sudo` works:

```bash
sudo xbps-install -S git
```

Clone this repository and enter it:

```bash
mkdir -p ~/Documents/GitHub
git clone https://github.com/Crowdrocker/WehttamSnaps-Void.git \
  ~/Documents/GitHub/WehttamSnaps-Void
cd ~/Documents/GitHub/WehttamSnaps-Void
```

## 2. Choose and run a desktop profile

The script updates Void, enables nonfree and multilib repositories, installs
the shared workstation packages and the selected desktop packages, enables
available runit services, installs the Flatpak applications, and links the
matching desktop config plus Fastfetch. Existing `~/.config/niri`,
`~/.config/umbriel`, and `~/.config/fastfetch` paths are moved to a timestamped
`~/.config-backup-*` directory before linking.

Run one of these:

```bash
./install.sh --profile niri
./install.sh --profile umbriel
```

Without `--profile`, the script asks which one to use. It displays the selected
profile and requires confirmation before changing the system. `--yes` skips
that confirmation; review the package lists first if using it:

```bash
./install.sh --profile niri --yes
```

The old `pkglist/install.sh` entry point remains available and defaults to the
Niri profile.

## 3. Reboot and log in

When the script finishes, reboot so service and group changes take effect:

```bash
sudo reboot
```

At SDDM, select the installed Niri or Umbriel session. For Umbriel, the script
adds this repository's `start-umbriel` session entry only if the package did
not provide one. If Niri is not listed, confirm its package installed and
inspect `/usr/share/wayland-sessions`.

## What the script changes

- Enables `void-repo-nonfree`, `void-repo-multilib`, and
  `void-repo-multilib-nonfree`, then performs a full XBPS update.
- Installs packages from `pkglist/*.txt`, with only the chosen compositor
  selected from `pkglist/desktop-niri.txt` or
  `pkglist/desktop-umbriel.txt`.
- Enables available `dbus`, `NetworkManager`, `sddm`, `zramen`, and
  `bluetoothd` runit services. `elogind` is installed and activated through
  D-Bus, not linked into `/var/service`. If `dhcpcd` or `wpa_supplicant` is enabled, it
  removes that service symlink because NetworkManager is configured.
- Adds the user to the available `video`, `render`, `audio`, and `network`
  groups; there is no `seatd` group requirement.
- Adds the Flathub user remote and installs the application IDs listed in
  `pkglist/flatpak.txt`.
- Backs up existing profile/Fastfetch configs and links the repository versions.

The script does **not** configure firmware/BIOS, disks or `/etc/fstab`, GPU-
specific environment variables, or optional iNiR/J.A.R.V.I.S. downloads. Those
steps depend on the machine and should be handled separately.

## Verify services and graphics

```bash
sudo sv status /var/service/*
id
vulkaninfo --summary
```

New group membership applies after logging out completely (or rebooting). For
details about audio, gaming, and the optional voice setup, see the other guides
in `docs/`.
