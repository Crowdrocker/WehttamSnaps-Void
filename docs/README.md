# NixOS port

Copy `flake.nix` and `nix/` into the repo root (beside `install.sh`).

1. Install NixOS, boot, clone the repo.
2. `sudo nixos-generate-config --show-hardware-config > nix/hardware-configuration.nix`
3. Edit `userName` / `hostName` in `flake.nix`.
4. `git add -A` (flakes ignore untracked files)
5. `sudo nixos-rebuild switch --flake .#niri` (or `.#umbriel`)

Test first with `nixos-rebuild build-vm --flake .#niri`.
This has not been evaluated; expect to fix a few attribute names.

## Void-only fixes that no longer apply
- Turnstile/runit env (`turnstile-update-runit-env ...` in `50-autostart.kdl`): REMOVE that line on NixOS; the command doesn't exist.
- `/run/user/1000` lockfile, duplicate WirePlumber, `ldconfig` after 32-bit Vulkan, SDDM needing `xorg-minimal`.
- iNiR's Turnstile services (`~/.config/service/*`) have no equivalent: it needs rewriting as `systemd.user.services`.
