# <- pkglist/gaming.txt
{ pkgs, ... }:
{
  # Replaces mesa-dri(-32bit), mesa-vaapi, mesa-vulkan-radeon(-32bit), vulkan-loader-32bit,
  # libglvnd/libdrm/libgcc/libstdc++-32bit
  hardware.graphics = { enable = true; enable32Bit = true; };
  services.xserver.videoDrivers = [ "amdgpu" ];

  programs.steam.enable = true;
  programs.gamemode.enable = true;   # gamemode + libgamemode(-32bit)
  programs.corectrl.enable = true;
  services.lact.enable = true;       # redundant with corectrl; keep whichever you use

  environment.systemPackages = with pkgs; [
    vulkan-tools mangohud vkbasalt
    lutris wineWowPackages.stable winetricks
  ];
}
