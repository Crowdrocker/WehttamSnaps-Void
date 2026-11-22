# J.A.R.V.I.S. Local Voice Control on Void Linux

## Runit Ollama Service
Ensure `/etc/sv/ollama/run` exports `PATH="/usr/local/bin:/usr/bin:/bin"` and `OLLAMA_MODELS="/home/wehttamsnaps/.ollama/models"` so `runit` finds `/usr/local/bin/ollama`.

## PipeWire Microphone Sampling (`stt.py`)
PortAudio defaults to motherboard analog inputs (`hw:2,0`) at 44.1 kHz if queried blindly. `stt.py` prioritizes `"pipewire"` and `"hyperx"` devices at their native sample rate and resamples cleanly to 16 kHz for `faster-whisper`.

