# <- pkglist/audio.txt
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
  hardware.bluetooth = { enable = true; powerOnBoot = true; };
  services.blueman.enable = true;

  environment.systemPackages = with pkgs; [
    pavucontrol qpwgraph helvum qjackctl easyeffects
    calf carla lsp-plugins lmms
    mpd ncmpcpp spotify-player songrec espeak-ng
  ];
}
