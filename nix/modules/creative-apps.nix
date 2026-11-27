# <- pkglist/creative-apps.txt
{ pkgs, ... }:
{
  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    darktable rawtherapee gimp krita inkscape blender kdePackages.kdenlive
    imagemagick ffmpeg vlc gpu-screen-recorder wf-recorder
    (mpv.override { scripts = [ mpvScripts.mpris ]; })
    thunderbird signal-desktop qbittorrent nautilus yt-dlp translate-shell
    (tesseract.override {
      enableLanguages = [ "eng" "spa" "jpn" "rus" "chi_sim" "chi_tra" ];
    })
  ];
}
