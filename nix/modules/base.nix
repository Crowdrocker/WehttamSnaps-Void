# <- pkglist/base.txt
{ pkgs, userName, hostName, ... }:
{
  networking.hostName = hostName;
  networking.networkmanager.enable = true;          # NetworkManager (dhcpcd/wpa_supplicant not needed)

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;                # steam, discord, signal, etc.

  boot.loader.systemd-boot.enable = true;           # replaces grub-x86_64-efi; adjust if you want GRUB
  boot.loader.efi.canTouchEfiVariables = true;

  zramSwap.enable = true;                           # zramen
  security.rtkit.enable = true;                     # rtkit
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;
  services.power-profiles-daemon.enable = true;
  services.locate = { enable = true; package = pkgs.plocate; localuser = null; };
  services.udisks2.enable = true;

  programs.fish.enable = true;
  users.users.${userName} = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [ "wheel" "networkmanager" "video" "render" "audio" ];
  };

  boot.supportedFilesystems = [ "ntfs" "nfs" "jfs" ];
  services.lvm.enable = true;

  environment.systemPackages = with pkgs; [
    # build tools (base-devel)
    gcc gnumake binutils cmake meson ninja just pkg-config
    kdePackages.extra-cmake-modules
    go pnpm yarn
    (python3.withPackages (ps: [ ps.tkinter ps.pip ps.tenacity ]))

    # CLI
    git gh stow curl wget rsync rclone jq yq-go ripgrep bat eza zoxide
    btop htop fastfetch ncdu pv socat bc figlet jp2a gum tldr trash-cli
    nano micro vim neovim starship

    # terminals / files
    ghostty kitty alacritty yazi xarchiver
    gnome-disk-utility ntfs3g nfs-utils lvm2 jfsutils

    # session helpers
    networkmanagerapplet polkit_gnome
  ];
  # Dropped (no NixOS equivalent / built in): octoxbps, turnstile, elogind (systemd-logind),
  # dbus (always on), base-system, portaudio-devel/glib-devel/cairo-devel (see devShell).
}
