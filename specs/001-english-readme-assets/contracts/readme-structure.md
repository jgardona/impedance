# Contract: README Structure

The package's public API is unchanged by this feature. The user-facing interface that
changes is the README, so its structure is the contract.

## Required outline (in this order)

1. Header image: `assets/social-preview.svg`, `alt="Impedance.jl"`
2. One-line description + **Features** list
3. `## Requirements`
4. `## Installation` (placeholder path `/path/to/impedance`)
5. `## Tutorial` with the numeric/symbolic levels table, then:
   1. `### 1. Impedances at a single frequency`
   2. `### 2. Accessors`
   3. `### 3. Series and parallel` (incl. the `∥` precedence warning)
   4. `### 4. Circuits (symbolic elements)` (uses `network`)
   5. `### 5. Voltage and current dividers` (incl. Ohm's law line)
   6. `### 6. Frequency response`, followed by:
      - `#### Bode plot` sub-heading
      - one sentence naming the required package (Plots.jl) and how to install it
      - the plotting snippet (identical to the body of `scripts/bode.jl`)
      - image `assets/bode-rc-lowpass.svg` with descriptive English alt text
   7. `### 7. Resonance and factors`
   8. `### 8. Reflection coefficient`
   9. `### 9. ComplexNumbers integration`
6. `## Quick reference` table (same rows, English category names)

## Invariants

- Every `julia>` example keeps its input and output text, except renamed identifiers.
- Function names, operators, units and numeric outputs are not translated.
- No Portuguese words remain (checked by the grep in [quickstart](../quickstart.md)).
