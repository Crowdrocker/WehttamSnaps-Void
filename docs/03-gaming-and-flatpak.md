# Steam, Proton & Flatpak Fixes on Void Linux

## Flatpak Font Rendering & Drive Access
Flatpak apps require standard TrueType fonts on the host and filesystem overrides to read user fonts and `/mnt` game drives:
```bash
sudo xbps-install -Sy noto-fonts-ttf dejavu-fonts-ttf liberation-fonts-ttf fontconfig
sudo fc-cache -fv && fc-cache -fv
rm -rf ~/.var/app/*/cache/fontconfig ~/.cache/fontconfig
flatpak override --user --filesystem=~/.local/share/fonts:ro --filesystem=~/.config/fontconfig:ro
flatpak override --user --filesystem=/mnt com.valvesoftware.Steam
```

## Ubisoft Connect / The Division 2
To prevent transparent CEF windows and patcher freezes in Proton/Wine:
- Disable `libglesv2` (`WINEDLLOVERRIDES="libglesv2=d" %command%`)
- Use `PROTON_NO_FSYNC=1 PROTON_NO_ESYNC=1` during initial Ubisoft Connect patching
