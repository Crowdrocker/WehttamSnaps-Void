{ pkgs, ... }:

{
  home.username = "wehttamsnaps";
  home.homeDirectory = "/home/wehttamsnaps";

  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  programs.fish.enable = true;
  programs.starship.enable = true;
  programs.fastfetch.enable = true;
  programs.git.enable = true;

  home.packages = with pkgs; [
    neovim
    nano
    micro

    ghostty
    kitty
    alacritty

    yazi
  ];
}
