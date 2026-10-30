# Contract: Images

## Preview image (`assets/social-preview.svg` / `.png`)

- Size 1280 × 640; colors, circuit diagram, fonts and positions unchanged.
- Tagline (two `<text>` lines at y = 200 and y = 234):
  - "Complex impedances in Julia: series, parallel,"
  - "frequency response and resonance."
- Code panel lines:
  - `julia> network = R + (L ∥ C)` → `R(100 Ω) + (L(10 mH) ∥ C(1 µF))`
  - `julia> network(1e3)` → `100.0 + 103.817j Ω`
  - `julia> resonantfrequency(L, C)` → `1591.5494309189535`
- All XML comments in English.
- PNG is rendered from the SVG and shows identical text.

## Bode figure (`assets/bode-rc-lowpass.svg`)

- Produced only by `scripts/bode.jl`; never hand-edited.
- Data: `R, C = Resistor(1e3), Capacitor(1e-6)`, `fs = logfreqs(10, 1e5, 200)`,
  `H = frequencyresponse(R, C, fs)`, `fc = cutofffrequency(R, C)`.
- Layout: two rows sharing a log10 x-axis labelled "Frequency (Hz)".
  - Top: `db.(H)`, y-label "Magnitude (dB)".
  - Bottom: `phase.(H; degrees=true)`, y-label "Phase (°)".
  - Both: dashed vertical line at `fc`, legend entry "fc ≈ 159 Hz".
- Title: "Bode plot — RC low-pass (R = 1 kΩ, C = 1 µF)".
- Opaque white background; all text in English.

## `scripts/bode.jl`

- Run as `julia --project=scripts scripts/bode.jl` from the repository root.
- Writes `assets/bode-rc-lowpass.svg` and prints its path; no other side effects.
- Header comment states purpose, how to run, and the Julia 1.10 fallback.
