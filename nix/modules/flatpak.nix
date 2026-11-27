# <- pkglist/flatpak.txt
# Everything on your Flatpak list is also in nixpkgs, so installing natively is
# more declarative. Flatpak itself stays enabled for anything else.
# (Verify attribute names on search.nixos.org if one fails to evaluate.)
{ pkgs, ... }:
{
  services.flatpak.enable = true;

  environment.systemPackages = with pkgs; [
    obs-studio   # com.obsproject.Studio
    discord      # com.discordapp.Discord
    flatseal     # com.github.tchx84.Flatseal (only useful for remaining Flatpaks)
    warehouse    # io.github.flattool.Warehouse
    protonplus   # com.vysp3r.ProtonPlus
  ];

  # Optional: add Flathub system-wide on first boot
  systemd.services.flathub-remote = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    path = [ pkgs.flatpak ];
    script = "flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo";
    serviceConfig.Type = "oneshot";
  };
}
