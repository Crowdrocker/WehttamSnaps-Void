{
  description = "WehttamSnaps NixOS Desktop";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Keep Umbriel's own nixpkgs input pinned for its binary cache.
    umbriel.url = "github:noctalia-dev/umbriel/cachix";
  };

  outputs = { self, nixpkgs, home-manager, umbriel, ... }@inputs: {
    nixosConfigurations.ws-desktop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      specialArgs = {
        inherit inputs;
      };

      modules = [
        ./hosts/ws-desktop/default.nix

        home-manager.nixosModules.home-manager

        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";

          home-manager.extraSpecialArgs = {
            inherit inputs;
          };

          home-manager.users.wehttamsnaps = import ./home;
        }
      ];
    };
  };
}
