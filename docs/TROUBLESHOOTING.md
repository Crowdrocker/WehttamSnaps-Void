# Void Linux + Niri + iNiR Troubleshooting Guide

## 1. Steam Fails to Open X11 Display (`Unable to open a connection to X`)
**Cause:** `iNiR` runs as a Turnstile user service (`~/.config/service/inir`) and needs `DISPLAY` exported from Niri so apps launched from iNiR's launcher can reach `xwayland-satellite`.
**Fix:**
1. Ensure `xwayland-satellite` is installed (`sudo xbps-install -S xwayland-satellite`). Do **not** manually add `spawn-at-startup "xwayland-satellite"` to Niri—Niri manages it natively.
2. Export `DISPLAY` to Turnstile in `~/.config/niri/conf.d/50-autostart.kdl`:
   ```kdl
   turnstile-update-runit-env PATH WAYLAND_DISPLAY DISPLAY XDG_RUNTIME_DIR DBUS_SESSION_BUS_ADDRESS NIRI_SOCKET
   ```
3. Immediate fix without rebooting:
   ```bash
   turnstile-update-runit-env DISPLAY
   sv restart ~/.config/service/inir
   ```
## 2. PipeWire Fails with `unable to open lockfile '/run/user/1000/pipewire-0.lock'`
**Cause:** `/run/user/1000` was not created prior to session start (or `elogind` / Turnstile had not initialized the runtime directory yet).
**Fix:**
1. Create the runtime directory with strict user-only permissions (`700`):
   ```bash
   sudo mkdir -p /run/user/1000 && sudo chown USER:USER /run/user/1000 && sudo chmod 700 /run/user/1000
   ```
2. In Niri (`50-autostart.kdl`), export the D-Bus session environment so Turnstile's supervised PipeWire services (`~/.config/service/pipewire`, `pipewire-pulse`, and `wireplumber`) connect cleanly—do **not** manually spawn duplicate `pipewire` or `wireplumber` processes:
   ```kdl
   spawn-at-startup "dbus-update-activation-environment" "--all"
   ```


## 3. Steam or Faugus Launcher Games Hang Silently in the Background
**Causes & Fixes:**
1. **32-bit Vulkan cache missing:** Void's XBPS hooks sometimes skip `ldconfig` after installing `mesa-vulkan-radeon-32bit`. Run:
   ```bash
   sudo ldconfig && ldconfig -p | grep libvulkan.so
   ```
   Both `/usr/lib/libvulkan.so.1` and `/usr/lib32/libvulkan.so.1` must appear.
2. **Low `vm.max_map_count`:** Set `vm.max_map_count = 2147483642` in `/etc/sysctl.d/80-gamecompatibility.conf`.
3. **Ryzen 9600X iGPU stealing DXVK:** Pin DXVK to the dedicated GPU via `DXVK_FILTER_DEVICE_NAME="AMD Radeon RX 7600"` in `/etc/environment` and Flatpak overrides.
4. **Ubisoft Connect (`upc.exe`) CEF hang:** Disable the Ubisoft Connect in-game overlay, install **Proton EasyAntiCheat Runtime** in Steam Tools, and use **Proton Experimental** or **GE-Proton 10/11**.
5. **Flatpak Faugus sandbox limits:** Grant `/mnt` and native Steam directory access via `sudo flatpak override io.github.Faugus.faugus-launcher --filesystem=/mnt --filesystem=~/.local/share/Steam --filesystem=~/.steam`.

## 4. SDDM Boots to TTY1 Instead of Graphical Greeter
**Cause:** SDDM defaults to X11 for its greeter on minimal installs.
**Fix:**
```bash
sudo xbps-install -S xorg-minimal
sudo sv restart sddm
```

## 5. PipeWire Shows Only `Dummy Output` (Duplicate WirePlumber Instances)
**Cause:** `iNiR`'s installer configures Turnstile user `runit` services (`~/.config/service/pipewire`, `pipewire-pulse`, and `wireplumber`). Spawning a second `wireplumber` process via `/etc/xdg/autostart/` or `50-autostart.kdl` causes two instances to fight over ALSA devices, leaving only `Dummy Output`.
**Fix:**
1. Remove any duplicate `/etc/xdg/autostart/pipewire*.desktop` symlinks and manual `pipewire` / `wireplumber` lines in `50-autostart.kdl`.
2. Restart Turnstile's supervised audio services cleanly:
   ```bash
   sv restart ~/.config/service/pipewire ~/.config/service/pipewire-pulse ~/.config/service/wireplumber
   ```
