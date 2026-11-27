# <- pkglist/wayland-desktop.txt (not provided: fill the package list below from that file)
{ pkgs, ... }:
{
  services.displayManager.sddm = { enable = true; wayland.enable = true; };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  fonts.packages = with pkgs; [ noto-fonts noto-fonts-color-emoji nerd-fonts.jetbrains-mono ];

  environment.systemPackages = with pkgs; [
    wl-clipboard
    xwayland-satellite
    # TODO: contents of wayland-desktop.txt (bar, launcher, notifications, screenshots, ...)
  ];
}
