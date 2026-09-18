# Order alert sound

`order_bell.wav` is an **original synthesized chime**, generated
programmatically for this project (not recorded, not sourced from a
sample library or stock-audio site). It is a triple ascending bell
arpeggio (C5 → E5 → G5, ~2.3s, 44.1kHz mono 16-bit PCM), each note built
from a fundamental sine plus decaying 2nd/3rd harmonics to give a
bell-like timbre, peak-normalized to avoid clipping.

Because it is wholly generated (no third-party sample, loop, or
instrument recording was used), there is no license to attribute — it is
owned outright by this project, same as any other first-party asset.

The generator script used to produce it is not part of the app bundle;
it lived at the time of generation as a throwaway build tool
(`gen_order_bell.dart`, sine/harmonic synthesis + WAV encoding). Re-running
it with the same parameters reproduces an identical file.
