# Steam, Proton & Flatpak Fixes on Void Linux

## 32-Bit AMD Vulkan (RADV) & Kernel Tuning
Void's XBPS package hooks can occasionally skip refreshing the shared library cache after installing 32-bit Vulkan drivers, causing Proton and `umu-launcher` to hang silently in the background.
```bash
sudo ldconfig
ldconfig -p | grep libvulkan.so
# Confirm both /usr/lib/libvulkan.so.1 and /usr/lib32/libvulkan.so.1 are listed
```

Apply high memory-map and file-descriptor limits for modern DX12 games, and pin DXVK to the dedicated RX 7600 (preventing the Ryzen 5 9600X iGPU from stealing device 0):
```bash
echo "vm.max_map_count = 2147483642" | sudo tee /etc/sysctl.d/80-gamecompatibility.conf
sudo sysctl --system
echo 'DXVK_FILTER_DEVICE_NAME="AMD Radeon RX 7600"' | sudo tee -a /etc/environment
```

## Flatpak Faugus Launcher & Font Overrides
Flatpak apps require standard TrueType fonts on the host and filesystem overrides to read user fonts, native Steam prefixes, and `/mnt` game drives:
```bash
sudo xbps-install -Sy noto-fonts-ttf dejavu-fonts-ttf liberation-fonts-ttf fontconfig
sudo fc-cache -fv && fc-cache -fv
rm -rf ~/.var/app/*/cache/fontconfig ~/.cache/fontconfig

sudo flatpak override io.github.Faugus.faugus-launcher \
  --filesystem=~/.local/share/Steam \
  --filesystem=~/.steam \
  --filesystem=/mnt \
  --talk-name=org.freedesktop.Flatpak \
  --env=DXVK_FILTER_DEVICE_NAME="AMD Radeon RX 7600"
```

## Ubisoft Connect / The Division 2
- Install **Proton EasyAntiCheat Runtime** and **Steam Linux Runtime 3.0 (sniper)** under **Steam Library -> Tools**.
- Disable the **Ubisoft Connect in-game overlay** in Ubisoft Connect settings to prevent swapchain stutters and hangs.
- Use **Proton Experimental** or **GE-Proton 10/11** (uncheck `GameMode` in Faugus unless `gamemode` + `libgamemode-32bit` are installed).
