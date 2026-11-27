{ inputs, pkgs, ... }:

{
  imports = [
    ../../modules/base.nix
    ../../modules/amd-graphics.nix
    ../../modules/audio.nix
    ../../modules/networking.nix

    inputs.umbriel.nixosModules.default
  ];

  networking.hostName = "ws-desktop";

  time.timeZone = "America/Chicago";

  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  # UEFI boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  users.users.wehttamsnaps = {
    isNormalUser = true;
    description = "WehttamSnaps";
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "render"
    ];
    shell = pkgs.fish;
  };

  programs.fish.enable = true;

  # Umbriel compositor and login session
  programs.umbriel.enable = true;

  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.defaultSession = "umbriel";

  # Umbriel binary cache
  nix.settings = {
    extra-substituters = [
      "https://umbriel.cachix.org"
    ];

    extra-trusted-public-keys = [
      "umbriel.cachix.org-1:JfNq/2yg2S6D6z4Z2dVSZrZlDPQTKtexB6GAVLD98nw="
    ];
  };

  nixpkgs.config.allowUnfree = true;

  # Keep this equal to the release used for the initial NixOS install.
  system.stateVersion = "26.05";
}
