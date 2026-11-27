{ pkgs, ... }:

{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  services.dbus.enable = true;
  security.polkit.enable = true;

  programs.dconf.enable = true;

  services.gnome.gnome-keyring.enable = true;
  services.udisks2.enable = true;
  services.gvfs.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-emoji
  ];

  environment.systemPackages = with pkgs; [
    git
    gh
    curl
    wget
    rsync
    jq
    ripgrep
    fd
    fzf
    file
    unzip
    zip
    usbutils
    pciutils
  ];
}
