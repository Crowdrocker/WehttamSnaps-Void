# <- pkglist/gaming.txt + 03-gaming-and-flatpak.md + TROUBLESHOOTING.md §3
{ lib, pkgs, ... }:
{
  # 32-bit Vulkan/Mesa: the Void "ldconfig after xbps" problem doesn't exist here;
  # the 32-bit driver path is wired up by enable32Bit.
  hardware.graphics = { enable = true; enable32Bit = true; };
  services.xserver.videoDrivers = [ "amdgpu" ];   # RX 7600 (RADV comes with Mesa)

  # /etc/sysctl.d/80-gamecompatibility.conf
  boot.kernel.sysctl."vm.max_map_count" = 2147483642;

  # Pin DXVK to the dedicated GPU so the Ryzen 9600X iGPU isn't device 0
  # (replaces the line appended to /etc/environment)
  environment.sessionVariables.DXVK_FILTER_DEVICE_NAME = "AMD Radeon RX 7600";

  programs.steam = {
    enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];  # GE-Proton in Steam's compat list
  };
  programs.gamemode.enable = true;   # gamemode + libgamemode(-32bit): GameMode works in Faugus
  programs.corectrl.enable = true;
  services.lact.enable = true;       # redundant with corectrl; keep whichever you use

  environment.systemPackages = with pkgs; [
    vulkan-tools mangohud vkbasalt
    lutris wineWowPackages.stable winetricks umu-launcher
  ]
  # Faugus natively (no Flatpak sandbox overrides needed). Only added if nixpkgs has it.
  ++ lib.optional (pkgs ? faugus-launcher) pkgs.faugus-launcher;

  # Fonts the Flatpak/Proton apps looked for (noto/dejavu/liberation + fontconfig)
  fonts.packages = with pkgs; [ noto-fonts dejavu_fonts liberation_ttf ];
  fonts.fontDir.enable = true;       # exposes system fonts to Flatpak apps
}
