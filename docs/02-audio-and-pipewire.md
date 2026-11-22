# PipeWire & Dual-PC Audio Routing on Void Linux

## Preventing Duplicate WirePlumber Instances
`iNiR` configures Turnstile user `runit` services (`~/.config/service/pipewire`, `pipewire-pulse`, and `wireplumber`). To prevent two `WirePlumber` instances from fighting over USB/ALSA audio devices and leaving only `Dummy Output`:
- Do **not** symlink `10-wireplumber.conf` or `20-pipewire-pulse.conf` into `/etc/pipewire/pipewire.conf.d/`.
- Do **not** add duplicate `.desktop` files in `/etc/xdg/autostart/` or `~/.config/autostart/`.
- Do **not** manually spawn `pipewire` or `wireplumber` in `~/.config/niri/conf.d/50-autostart.kdl`—only export `dbus-update-activation-environment --all`.
- To reset audio cleanly anytime:
  ```bash
  sv restart ~/.config/service/pipewire ~/.config/service/pipewire-pulse ~/.config/service/wireplumber
  ```

## Dual-PC Capture Card Split
Stow the `pipewire` package (`stow -v pipewire`) to load `~/.config/pipewire/pipewire.conf.d/99-stream-split.conf`, creating the **Headphones + HDMI Capture Split** sink for simultaneous HyperX headset and HDMI capture card output.
