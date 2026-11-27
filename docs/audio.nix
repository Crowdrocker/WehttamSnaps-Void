# <- pkglist/audio.txt + 02-audio-and-pipewire.md + TROUBLESHOOTING.md §2, §5
# On NixOS the system manages pipewire/pipewire-pulse/wireplumber as systemd user
# services, so the duplicate-WirePlumber and /run/user/1000 lockfile problems from the
# Void/Turnstile setup don't apply. Do NOT start them again from niri or iNiR.
{ pkgs, ... }:
{
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };
  security.rtkit.enable = true;
  hardware.bluetooth = { enable = true; powerOnBoot = true; };
  services.blueman.enable = true;

  environment.systemPackages = with pkgs; [
    pavucontrol qpwgraph helvum qjackctl easyeffects
    calf carla lsp-plugins lmms
    mpd ncmpcpp spotify-player songrec espeak-ng
  ];
}
