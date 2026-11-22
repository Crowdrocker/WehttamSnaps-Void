
# PipeWire & Dual-PC Audio Routing on Void Linux

## Preventing Duplicate WirePlumber Instances
If user-level `runsv` supervises `pipewire`, `pipewire-pulse`, and `wireplumber`, do **not** symlink `10-wireplumber.conf` or `20-pipewire-pulse.conf` into `/etc/pipewire/pipewire.conf.d/`, and do not add duplicate `.desktop` files in `~/.config/autostart/`. Running two `WirePlumber` instances locks USB audio devices.

## Dual-PC Capture Card Split
Stow the `pipewire` package (`stow -v pipewire`) to load `~/.config/pipewire/pipewire.conf.d/99-stream-split.conf`, creating the **Headphones + HDMI Capture Split** sink for simultaneous HyperX headset and HDMI capture card output.
