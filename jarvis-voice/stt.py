import numpy as np
import sounddevice as sd
from faster_whisper import WhisperModel

model = WhisperModel("base.en", device="cpu", compute_type="int8")

def _find_pipewire_input():
    devices = sd.query_devices()
    for priority in ("pipewire", "hyperx", "pulse", "default"):
        for idx, dev in enumerate(devices):
            if dev["max_input_channels"] > 0 and priority in dev["name"].lower():
                return idx, int(dev["default_samplerate"])
    default_in = sd.default.device
    if default_in is not None and default_in >= 0:
        return default_in, int(devices[default_in]["default_samplerate"])
    return None, 48000

def listen_and_transcribe(seconds: int = 4, target_rate: int = 16000) -> str:
    dev_idx, native_rate = _find_pipewire_input()
    audio = sd.rec(
        int(seconds * native_rate),
        samplerate=native_rate,
        channels=1,
        dtype="float32",
        device=dev_idx,
    )
    sd.wait()

    samples = audio.flatten()
    if native_rate != target_rate:
        duration = len(samples) / native_rate
        new_length = int(round(duration * target_rate))
        samples = np.interp(
            np.linspace(0.0, len(samples) - 1, new_length),
            np.arange(len(samples)),
            samples,
        ).astype(np.float32)

    segments, _ = model.transcribe(
        samples,
        beam_size=1,
        vad_filter=False,
        initial_prompt="Switch OBS to Live, BRB, Starting Soon. Mute Discord, GameAudio, mic. Open Darktable, Steam, GIMP. Activate gaming mode, work mode.",
    )
    return " ".join(seg.text.strip() for seg in segments).strip()
