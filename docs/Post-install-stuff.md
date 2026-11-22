Void's installer is quick—while it wraps up, here is the clean copy-paste order of operations for your first boot.

Step 1: Update & Enable Multilib/Nonfree Repos

Once you reboot, unplug the USB, and log in at the TTY prompt, run:
bash
sudo xbps-install -Syu
sudo xbps-install -S void-repo-multilib void-repo-multilib-nonfree void-repo-nonfree
sudo xbps-install -Syu
Use code with caution.
(If xbps itself updates during the first command, run sudo xbps-install -Syu again before adding the repos).

Step 2: Install Minimal KDE, Audio, Network & Zram

bash
sudo xbps-install -S dbus elogind NetworkManager plasma-desktop sddm \
  konsole OctoXBPS dolphin xdg-desktop-portal-kde pipewire wireplumber \
  xorg-minimal ntfs-3g alsa-pipewire pavucontrol zramen git
  
  sudo xbps-install -S plasma-pa plasma-nm network-manager-applet sof-firmware

Use code with caution.

Step 3: Install RX 7600 (RDNA 3) Drivers, Steam & Flatpak

bash
sudo xbps-install -S linux linux-firmware-amd mesa-dri mesa-dri-32bit \
  vulkan-loader vulkan-loader-32bit mesa-vulkan-radeon mesa-vulkan-radeon-32bit \
  libgcc-32bit libstdc++-32bit libdrm-32bit libglvnd-32bit mesa-vaapi \
  steam flatpak xwayland-satellite xdg-desktop-portal-gtk
sudo ldconfig
Use code with caution.

Step 4: Enable Services & Reboot into KDE

Make sure dhcpcd and wpa_supplicant are removed so they don't conflict with NetworkManager:
bash
sudo rm -f /var/service/dhcpcd /var/service/wpa_supplicant
sudo ln -s /etc/sv/dbus /var/service/
sudo ln -s /etc/sv/NetworkManager /var/service/
sudo ln -s /etc/sv/zramen /var/service/
sudo ln -s /etc/sv/sddm /var/service/
sudo usermod -aG network $USER
sudo reboot
Use code with caution.
Once you log into your KDE desktop, let me know if Wi-Fi/Ethernet and audio come right up, or if you're ready for the Flatpak Faugus + Niri/iNiR steps.

+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Your secondary drives are all showing up cleanly—you just need to add them to /etc/fstab so they auto-mount at boot (especially GAMEDRIVE so Steam and Faugus Launcher can immediately find your existing game libraries without hanging).

1. Install ntfs-3g for Your NTFS Drives (512GB & WettamSnapsMain)

Void's base install does not include ntfs-3g by default, which is needed for read/write mounting on sdc1 and sde1:
bash
sudo xbps-install -S ntfs-3g
Use code with caution.

2. Create Your Mount Directories

bash
sudo mkdir -p /mnt/LINUXDRIVE /mnt/512GB /mnt/GAMEDRIVE /mnt/WettamSnapsMain /mnt/EXTRA1TB
Use code with caution.

3. Add All Drives to /etc/fstab by UUID

Run this block to append your drives safely using their exact UUIDs (nofail prevents boot hangs if a drive is ever disconnected):
bash
cat << 'EOF' | sudo tee -a /etc/fstab
UUID=2be94340-fe0c-464c-9afc-fde6ddc300cc  /mnt/LINUXDRIVE       ext4     defaults,noatime,nofail  0  2
UUID=47780A83503AF675                      /mnt/512GB            ntfs-3g  defaults,uid=1000,gid=1000,nofail  0  0
UUID=3f996c97-b699-4208-b9fc-1a64bc65b478  /mnt/GAMEDRIVE        ext4     defaults,noatime,nofail  0  2
UUID=2C66D88566D850E6                      /mnt/WettamSnapsMain  ntfs-3g  defaults,uid=1000,gid=1000,nofail  0  0
UUID=d3283959-c9d3-494a-b832-72f961ea7a92  /mnt/EXTRA1TB         ext4     defaults,noatime,nofail  0  2
EOF
Use code with caution.

4. Mount Everything & Grant Flatpak Faugus Access

Mount all drives immediately, ensure your user owns the ext4 mount folders, and give Flatpak Faugus access to /mnt so it can launch games stored on GAMEDRIVE:
bash
sudo systemctl daemon-reload 2>/dev/null || true
sudo mount -a
sudo chown -R $USER:$USER /mnt/LINUXDRIVE /mnt/GAMEDRIVE /mnt/EXTRA1TB
sudo flatpak override io.github.Faugus.faugus-launcher --filesystem=/mnt
Use code with caution.
(Note: If you run chown on large folders, use sudo chown $USER:$USER /mnt/LINUXDRIVE /mnt/GAMEDRIVE /mnt/EXTRA1TB without -R first so it finishes instantly while keeping your existing file permissions intact).
Once sudo mount -a finishes without errors, let me know if Steam and Faugus pick up your existing libraries on /mnt/GAMEDRIVE and launch cleanly!


On Void Linux, vulkaninfo is packaged as Vulkan-Tools (capitalized)—and your ldconfig output already confirms both 64-bit (/usr/lib/libvulkan.so.1) and 32-bit (/usr/lib32/libvulkan.so.1) Vulkan loaders are properly linked.
Run it with the capitalized package name to verify your RX 7600 is detected:
bash

sudo xbps-install -S Vulkan-Tools
vulkaninfo --summary | grep -E "deviceName|driverName"

Use code with caution.
(Also make sure you avoid accidentally pasting raw binary file data into the prompt—only your terminal text was needed here).
Once vulkaninfo confirms your RX 7600 and RADV driver, let me know if your drives mounted and if a test game in Steam or Faugus launches cleanly in KDE!


#### FLATPAK FIX
flatpak remote-delete --force flathub
REPO_URL="https://dl.flathub.org""/repo/flathub.flatpakrepo"
flatpak remote-add --if-not-exists flathub "$REPO_URL"


flatpak install -y flathub io.github.Faugus.faugus-launcher
sudo flatpak override io.github.Faugus.faugus-launcher \
  --filesystem=~/.local/share/Steam \
  --filesystem=~/.steam \
  --filesystem=/mnt \
  --talk-name=org.freedesktop.Flatpak


sudo mkdir -p /run/user/1000
sudo chown $USER:$USER /run/user/1000
sudo chmod 700 /run/user/1000

nohup pipewire >/dev/null 2>&1 &
sleep 1
nohup wireplumber >/dev/null 2>&1 &
sleep 1
wpctl status



