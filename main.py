from PySide6.QtCore import QObject, Signal, Slot, QUrl, QTimer
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtWidgets import QApplication
import sys
import numpy as np
import sounddevice as sd
import pythonmonkey as pm

d3 = pm.require('./d3.js')

note_frequency = {
    "C": 32.70319566257482,
    "C#": 34.64782887210901,
    "D": 36.70809598967594,
    "D#": 38.89087296526011,
    "E": 41.20344461410874,
    "F": 43.65352892912548,
    "F#": 46.24930283895429,
    "G": 48.99942949771866,
    "G#": 51.91308719749314,
    "A": 55.0,
    "A#": 58.27047018976123,
    "B": 61.73541265701551,
}

# note_frequency = {
#     "C": 0,
#     "C#": 1,
#     "D": 2,
#     "D#": 3,
#     "E": 4,
#     "F": 5,
#     "F#": 6,
#     "G": 7,
#     "G#": 8,
#     "A": 9,
#     "A#": 10,
#     "B": 11,
# }

def string_to_note(value: str) -> tuple[int, str]:
    """Convert string like 'A4' to (4, 'A')."""
    octave = int(value[-1])
    note = value[:-1]
    return (octave, note)

def get_frequency(value: str) -> float:
    """Return frequency of note given octave and note name."""
    (octave, note) = string_to_note(value)
    return note_frequency[note] * (2 ** (octave - 1))
    #midi_note = note_frequency[note] + 12 * (octave + 1)
    #return 440.0 * 2 ** ((midi_note - 69) / 12)


def note_to_string(octave: int, note: str) -> str:
    """Return note name as string (e.g., A4)."""
    return f"{note}{octave}"
  
class MidiHandler(QObject):
    frequencyDataReady = Signal(list)

    def __init__(self):
        super().__init__()
        self.sample_rate = 48000
        self.fft_size = 4096
        self.chunk_size = 4096
        self.buffer_length = self.fft_size // 2
        self.volume = 0.5
        self.phase = 0
        self.current_notes = set()
        self.stream = None

        self.freq_per_item = (self.sample_rate / 2) / self.buffer_length

        # Initialize audio stream
        self._init_audio_stream()

    def _init_audio_stream(self):
        self.stream = sd.OutputStream(
            samplerate=self.sample_rate,
            blocksize=self.chunk_size,
            channels=1,
            dtype='float32',
            callback=self.audio_callback
        )
        self.stream.start()

    def audio_callback(self, outdata, frames, time, status):
        # === Sound Generation ===
        t = (np.arange(frames) + self.phase) / self.sample_rate
        samples = np.zeros(frames, dtype=np.float32)

        for note in self.current_notes:
            freq = get_frequency(note)  # MIDI note to frequency
            samples += np.sin(2 * np.pi * freq * t)

        if len(self.current_notes) > 0:
            samples /= len(self.current_notes)  # Prevent clipping

        samples *= self.volume
        self.phase += frames
        outdata[:] = samples.reshape(-1, 1)

        # === Real-Time FFT Analysis ===
        fft_result = np.fft.rfft(samples, n=self.fft_size)
        magnitude = np.abs(fft_result)[:self.buffer_length]

        if np.max(magnitude) > 0:
            normalized = (magnitude / np.max(magnitude)) * 255
        else:
            normalized = magnitude

        byte_frequency_data = np.clip(normalized, 0, 255).astype(np.uint8)

        self.frequencyDataReady.emit(byte_frequency_data.tolist())
        # You can do more here: emit signals to QML, log, visualize, etc.
        # print(f"[FFT] Byte frequency data (length {len(byte_frequency_data)}): {byte_frequency_data}")
        # print(f"[FFT] Frequency per bin: {self.freq_per_item:.2f} Hz")
    
    def __del__(self):
        print("Cleaning up MidiHandler...")
        if self.stream:
            self.stream.stop()
            self.stream.close()

    @Slot(str)
    def noteon(self, note):
        print(f"Note on: {note}")
        self.current_notes.add(note)

    @Slot(str)
    def noteoff(self, note):
        print(f"Note off: {note}")
        QTimer.singleShot(500, lambda note=note: self.current_notes.discard(note))

    @Slot(int, int, result=float)
    def scaleLog(self, x, width):
        return d3.scaleLog(x, self.sample_rate, width)

app = QApplication(sys.argv)
engine = QQmlApplicationEngine()
midi_handler = MidiHandler()
engine.rootContext().setContextProperty("midiHandler", midi_handler)
engine.load(QUrl("main.qml"))
if not engine.rootObjects():
    sys.exit(-1)
sys.exit(app.exec())