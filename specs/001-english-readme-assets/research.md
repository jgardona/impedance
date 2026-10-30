# Research: English README, Preview Images and Bode Plots

All Technical Context unknowns are resolved below.

## R1. Plotting package for the Bode figure

- **Decision**: Plots.jl with its default GR backend.
- **Rationale**: the most widely used Julia plotting API, so the README snippet is familiar
  to most readers; `xscale=:log10`, `layout=(2, 1)` and `vline!` cover a Bode plot in a
  few lines; already installed in the maintainer's global environment; GR exports SVG
  and PNG directly.
- **Alternatives considered**:
  - CairoMakie: high-quality output, but a much heavier install and longer first-plot
    time for a README snippet.
  - Hand-written SVG: no dependency, but not reproducible by users and duplicates what a
    plotting library does (rejected by Principle II, YAGNI).

## R2. Where the plotting dependency lives

- **Decision**: a separate environment in `scripts/` (`scripts/Project.toml`) that depends
  on Plots and on Impedance through a `[sources]` path entry pointing to the repository
  root.
- **Rationale**: keeps `Project.toml` of the package free of plotting dependencies
  (FR-013, Constitution Technical Constraints); `[sources]` makes
  `julia --project=scripts` work without a manual `Pkg.develop`.
- **Alternatives considered**:
  - Package extension (`ext/`) for Plots: adds public API, which the spec puts out of
    scope.
  - `test` target or `[extras]`: mixes documentation tooling with tests.
- **Note**: `[sources]` needs Julia ≥ 1.11. This only affects the maintainer tool, not the
  package (which still supports 1.10). The script's header documents the fallback
  (`Pkg.develop(path="..")`) for Julia 1.10.

## R3. Bode figure format and theming

- **Decision**: SVG at `assets/bode-rc-lowpass.svg`, about 800 × 600 px, with an opaque
  white background, two stacked panels (magnitude dB, phase °), shared log-frequency axis,
  dashed vertical line and annotation at fc ≈ 159.15 Hz.
- **Rationale**: SVG stays sharp at any zoom and is small; GitHub renders SVG in
  `<img>`/Markdown images. An opaque background keeps dark text readable in GitHub's dark
  theme (spec edge case).
- **Alternatives considered**: PNG (blurry on high-DPI screens, larger file); transparent
  background (unreadable axis labels in dark mode); two separate images (allowed by the
  spec, but one figure keeps the shared axis aligned).

## R4. Single source of truth for snippet and script

- **Decision**: the script `scripts/bode.jl` contains exactly the README snippet followed by
  a `savefig` call. The README snippet is copied from the script, not the other way round.
- **Rationale**: FR-012 / FR-015 require that the snippet reproduces the image; keeping one
  code body avoids drift.

## R5. Phase wrapping

- **Decision**: plot `phase.(H; degrees=true)` directly, no unwrapping.
- **Rationale**: verified for R = 1 kΩ, C = 1 µF, f ∈ [10 Hz, 100 kHz]: phase ranges from
  −3.6° to −89.9°, inside (−180°, 180°], so no wrap can occur. At fc the package returns
  exactly −3.0103 dB and −45.0° (README example), satisfying SC-006.

## R6. Rasterizing the preview image

- **Decision**: render `assets/social-preview.png` from the SVG with
  `rsvg-convert -w 1280 -h 640`, after installing the Fira Code font
  (`sudo dnf install fira-code-fonts`); Inter is already installed.
- **Rationale**: `rsvg-convert` is installed, deterministic and honors the SVG's
  `font-family`. The existing PNG uses Fira Code for code text; without it the code panel
  would fall back to a different monospace font (accepted by the spec as a fallback, but
  installing it keeps the look identical).
- **Alternatives considered**: Inkscape CLI (also installed; heavier, same result);
  ImageMagick (inconsistent SVG text rendering).

## R7. Translation of identifiers and copy

- **Decision**: `rede` → `network` everywhere (README section 4 and preview image).
  Tagline: "Complex impedances in Julia: series, parallel, / frequency response and
  resonance." Terminology follows the glossary in [data-model.md](data-model.md).
- **Rationale**: verified in a Julia session that the renamed example prints
  `R(100 Ω) + (L(10 mH) ∥ C(1 µF))` and `100.0 + 103.81726746840584j Ω`; the image keeps
  its shortened `100.0 + 103.817j Ω` as an abbreviation of that output. At 20 px Fira
  Code, `julia> network = R + (L ∥ C)` is ≈ 31 characters (≈ 375 px), well inside the
  560 px code panel; the English tagline lines are shorter than the Portuguese ones.
