# Place this at the ROOT of the WehttamSnaps-Void repo (next to install.sh)
# so the shared dotfiles in ./.config and ./session are inside the flake.
# Files must be `git add`ed or the flake can't see them.
{
  description = "NixOS port of the WehttamSnaps Void post-install setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      userName = "wehttamsnaps";
      hostName = "wehttam";  # <-- change

      mkHost = profile: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit userName hostName profile; };
        modules = [
          ./nix/hardware-configuration.nix # from nixos-generate-config
          ./nix/modules/base.nix
          ./nix/modules/desktop-common.nix
          ./nix/modules/audio.nix
          ./nix/modules/gaming.nix
          ./nix/modules/creative-apps.nix
          ./nix/modules/flatpak.nix
          ./nix/modules/jarvis.nix
          ./nix/modules/desktop-${profile}.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "bak";
              extraSpecialArgs = { inherit profile; };
              users.${userName} = import ./nix/home/user.nix;
            };
          }
        ];
      };
    in
    {
      # Equivalent of ./install.sh --profile niri|umbriel
      #   sudo nixos-rebuild switch --flake .#niri
      #   sudo nixos-rebuild switch --flake .#umbriel
      nixosConfigurations = {
        niri = mkHost "niri";
        umbriel = mkHost "umbriel";
      };

      # Replaces the *-devel packages from base.txt
      devShells.${system}.default =
        let pkgs = nixpkgs.legacyPackages.${system}; in
        pkgs.mkShell {
          packages = with pkgs; [ pkg-config cmake meson ninja glib.dev cairo.dev portaudio ];
        };
    };
}
