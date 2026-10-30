# Quickstart: Validate the English README, Preview Images and Bode Plot

Run all commands from the repository root.

## Prerequisites

- Julia ≥ 1.11 for the scripts environment (package itself still supports 1.10)
- `rsvg-convert` (librsvg) and the Fira Code font: `sudo dnf install fira-code-fonts`

## 1. No Portuguese left (SC-001)

```bash
grep -nEi 'ção|ções|ência|ância|são|não|também|para |numa|série|rede|caminho|acessores|referência' \
  README.md assets/social-preview.svg
```

Expected: no output (function names such as `series` do not match).

## 2. README examples still work (SC-002)

```bash
julia --project=. -e 'using Pkg; Pkg.test()'
```

Then paste each `julia>` block from the README into `julia --project=.` with
`using Impedance` and compare against the shown output.

## 3. Structure preserved (SC-003)

```bash
git show main:README.md | grep -c '^###'   # before
grep -c '^###' README.md                    # after: before + 1 (the Bode plot sub-heading)
```

## 4. Preview image (SC-004)

```bash
rsvg-convert -w 1280 -h 640 assets/social-preview.svg -o assets/social-preview.png
```

Open both files: same English text, nothing overflowing the code panel or overlapping the
circuit. The PNG is 1280 × 640 (`file assets/social-preview.png`).

## 5. Bode figure (SC-006, SC-007)

```bash
julia --project=scripts -e 'using Pkg; Pkg.instantiate()'
julia --project=scripts scripts/bode.jl
```

Expected: `assets/bode-rc-lowpass.svg` is (re)written. At the dashed fc line the magnitude
reads −3 dB and the phase −45°; magnitude falls 20 dB per decade above fc; phase tends to
−90° without jumps. Check readability by viewing the README on GitHub in both light and
dark themes.

## 6. Package stays plot-free (FR-013)

```bash
grep -n Plots Project.toml
```

Expected: no output.
