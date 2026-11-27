# <- 04-jarvis-voice.md   (the package list for stt.py is a GUESS: adjust to its imports)
{ pkgs, ... }:
{
  # Replaces the /etc/sv/ollama runit service and its PATH/OLLAMA_MODELS exports.
  # Runs as the `ollama` user, so models default to /var/lib/ollama/models
  # (copy ~/.ollama/models there, or set services.ollama.models).
  services.ollama.enable = true;
  # services.ollama.acceleration = "rocm";  # RX 7600 (gfx1102) may need an HSA override

  environment.systemPackages = [
    pkgs.portaudio
    (pkgs.python3.withPackages (ps: [ ps.faster-whisper ps.sounddevice ps.numpy ]))
  ];
}
