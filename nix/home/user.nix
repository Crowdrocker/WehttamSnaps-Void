# Replaces link_config() in install.sh: the same repo configs, deployed by Home Manager.
{ profile, config, ... }:
{
  home.stateVersion = "25.11"; # set to the NixOS release you first install

  # Store copy (immutable, reproducible):
  xdg.configFile."${profile}".source = ../../.config/${profile};
  xdg.configFile."fastfetch".source = ../../.config/fastfetch;

  # Live-editable alternative (like the Void symlinks); point at your clone:
  # xdg.configFile."${profile}".source =
  #   config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/WehttamSnaps-Void/.config/${profile}";

  programs.home-manager.enable = true;
}
