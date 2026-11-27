# <- desktop-umbriel.txt + session/umbriel.desktop
# Umbriel (noctalia-dev) is NOT confirmed to be in nixpkgs. Provide the package
# via a flake input/overlay/derivation, then set wehttam.umbriel.package.
{ config, lib, pkgs, ... }:
let
  cfg = config.wehttam.umbriel;
  session = pkgs.runCommand "umbriel-session"
    { passthru.providedSessions = [ "umbriel" ]; }
    ''
      install -Dm644 ${../../session/umbriel.desktop} \
        $out/share/wayland-sessions/umbriel.desktop
    '';
in
{
  options.wehttam.umbriel.package = lib.mkOption {
    type = lib.types.package;
    default = pkgs.umbriel or (throw "umbriel is not in nixpkgs: set wehttam.umbriel.package (flake input, overlay or custom derivation)");
    defaultText = "pkgs.umbriel";
    description = "The Umbriel compositor package.";
  };

  config = {
    environment.systemPackages = [ cfg.package ];
    services.displayManager.sessionPackages = [ session ];
  };
}
