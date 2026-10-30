---

description: "Task list for English README, Preview Images and Bode Plots"
---

# Tasks: English README, Preview Images and Bode Plots

**Input**: Design documents from `/specs/001-english-readme-assets/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md),
[data-model.md](data-model.md), [contracts/](contracts/), [quickstart.md](quickstart.md)

**Tests**: no automated test tasks (not requested). Verification follows
[quickstart.md](quickstart.md) in the Polish phase; the existing `Pkg.test()` suite is a gate.

**Organization**: tasks are grouped by user story so each story can be delivered and checked
on its own.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: can run in parallel (different files, no dependencies)
- **[Story]**: user story from spec.md (US1, US2, US3)
- All paths are relative to the repository root

## Shared rules for every translation task

- Use the glossary in [data-model.md](data-model.md#translation-glossary) for every domain term.
- Do NOT change function names, operators (`+`, `∥`), unit symbols (Ω, H, F, Hz, mH, µF),
  `julia>` inputs (except renaming `rede` → `network`) or any printed output.
- Keep Markdown structure (heading levels, tables, block quotes, code fences) identical.
- Write plain, short English sentences (Constitution Principle IV).

---

## Phase 1: Setup

**Purpose**: tools and files needed by later phases

- [ ] T001 (BLOCKED: needs sudo password; PNG rendered with the Noto Sans Mono fallback, see T018) Install the Fira Code font so the preview PNG renders with the original monospace face: run `sudo dnf install fira-code-fonts` and confirm with `fc-list | grep -i "fira code"` (research R6). If it cannot be installed, note the fallback font in the final report.
- [X] T002 [P] Append `scripts/Manifest.toml` to `.gitignore` (plan: Structure Decision)

---

## Phase 2: Foundational

**Purpose**: none. The three stories touch independent files, except that US1 and US3 both
edit README section 6 (see Dependencies). No blocking work is needed.

---

## Phase 3: User Story 1 - Read the README in English (Priority: P1) 🎯 MVP

**Goal**: every part of `README.md` is in English with unchanged structure and examples.

**Independent Test**: quickstart steps 1–3 pass for `README.md`; every `julia>` example
still prints the shown output.

All tasks edit `README.md`, so they run in order (no [P]).

- [X] T003 [US1] Translate the header block of README.md: keep the `<img src="assets/social-preview.svg" alt="Impedance.jl" …>` element unchanged; translate the one-line description ("Julia package for AC circuit analysis with complex impedances.") and the **Funcionalidades** list → **Features** (8 bullets, same order, same code spans)
- [X] T004 [US1] Translate `## Requisitos` → `## Requirements` ("Julia **1.10** or later") and `## Instalação` → `## Installation` in README.md: change `/caminho/para/impedance` to `/path/to/impedance` and "Para rodar os testes:" to "To run the tests:"
- [X] T005 [US1] Translate the `## Tutorial` intro and the two-level table in README.md (columns "Level | Type | Used for"; rows "Numeric … an impedance **at one frequency**", "Symbolic … a **circuit**, evaluable at any frequency")
- [X] T006 [US1] Translate sections `### 1. Impedances at a single frequency` and `### 2. Accessors` in README.md, including code comments (e.g. `# using ω (rad/s) instead of f (Hz)`, `# from a complex number`)
- [X] T007 [US1] Translate `### 3. Series and parallel` in README.md: prose about `+`, `∥` (`\parallel<tab>`), `series(...)`/`parallel(...)`, the `# also works with plain numbers` comment, and the full **precedence warning** block quote (all three bullets) keeping every code span unchanged
- [X] T008 [US1] Translate `### 4. Circuits (symbolic elements)` in README.md and rename the identifier `rede` → `network` in all three code lines and in the prose (`impedance(network, f)` / `network(f)`); translate "Numeric values can be mixed with elements (they become fixed impedances):"
- [X] T009 [US1] Translate `### 5. Voltage and current dividers` in README.md: code comments (`# voltage across Z2`, `# current through Z1`, `# n impedances in series`, `# with elements + frequency`) and the line "Ohm's law: `voltage(Z, I)` and `current(V, Z)` (or `V / Z`)."
- [X] T010 [US1] Translate `### 6. Frequency response` in README.md: code comments (`# RC low-pass: Vout across C`, `# log-spaced frequencies`, `# network impedance at each f`) and the closing sentence "For a Bode plot, plot `db.(H)` and `phase.(H; degrees=true)` against `fs`." (US3 later replaces/extends this sentence)
- [X] T011 [US1] Translate `### 7. Resonance and factors` in README.md: comments (`# numerical search on any network`, `# series: (1/R)√(L/C)`, `# cos φ and load nature`)
- [X] T012 [US1] Translate `### 8. Reflection coefficient` (`# element + frequency`) and `### 9. ComplexNumbers integration` (intro: "With both packages loaded, an extension converts between `ImpedanceValue` and `ComplexNumber`, giving access to the Cartesian and polar forms:") in README.md
- [X] T013 [US1] Translate `## Referência rápida` → `## Quick reference` in README.md: header "Category | Functions" and category names Constructors, Elements, Connection, Accessors, Ohm, Dividers, Frequency, Resonance, Power, Lines; function lists unchanged
- [X] T014 [US1] Verify US1: run quickstart step 1 grep on README.md (expect no output) and step 3 heading count (expect same as `git show main:README.md`); run the section 4 example with `network` in `julia --project=.` and confirm it prints `R(100 Ω) + (L(10 mH) ∥ C(1 µF))` and `100.0 + 103.81726746840584j Ω`

**Checkpoint**: README fully in English → MVP deliverable.

---

## Phase 4: User Story 2 - See an English preview image (Priority: P2)

**Goal**: preview image text (SVG and PNG) is in English with unchanged design.

**Independent Test**: quickstart steps 1 (on the SVG) and 4 pass.

- [X] T015 [P] [US2] Translate XML comments in assets/social-preview.svg: "Circuit: the three Julia dots are the nodes; R, L and C are the branches. Each component is drawn along the local x axis (nodes at ±173.2) and placed on its branch with translate + rotate.", "Inductor: red → green branch", "Capacitor: green → purple branch", "Resistor: red → purple branch", "The three Julia dots as circuit nodes", "Impedance of each branch", "Title and text", "Code snippet"
- [X] T016 [US2] Replace the tagline in assets/social-preview.svg: `<text … y="200">` → "Complex impedances in Julia: series, parallel," and `<text … y="234">` → "frequency response and resonance." (contracts/images.md); keep all attributes
- [X] T017 [US2] Rename `rede` → `network` in the two code `<tspan>`s of assets/social-preview.svg (`network = R + (L ∥ C)` and `network(1e3)`); keep the shown outputs unchanged
- [X] T018 [US2] Render the PNG: `rsvg-convert -w 1280 -h 640 assets/social-preview.svg -o assets/social-preview.png` (depends on T001, T015–T017). Done with the fallback font; re-run after T001 for the original Fira Code face
- [X] T019 [US2] Verify US2: open assets/social-preview.png and confirm the English tagline does not touch the code panel (starts y = 282) or the circuit (x ≥ 740), the code lines fit inside the panel (x < 632), and `file assets/social-preview.png` reports 1280 x 640

**Checkpoint**: preview image in English.

---

## Phase 5: User Story 3 - See the Bode plot for the frequency-response example (Priority: P3)

**Goal**: README section 6 shows a Bode plot of the RC low-pass example and a snippet that
reproduces it; the package gains no dependency.

**Independent Test**: quickstart steps 5 and 6 pass; section 6 shows the figure.

- [X] T020 [P] [US3] Create scripts/Project.toml with `[deps]` Impedance (uuid `d90c7a4f-4336-4037-9d82-5d2137f2324b`) and Plots (uuid `91a5bcdd-55d7-5caf-9e0b-520d859cae80`), and `[sources] Impedance = {path = ".."}`; then run `julia --project=scripts -e 'using Pkg; Pkg.instantiate()'` (research R2)
- [X] T021 [US3] Create scripts/bode.jl (contracts/images.md): header comment (purpose; run with `julia --project=scripts scripts/bode.jl` from the repo root; Julia 1.10 fallback `Pkg.develop(path="..")`); body = `using Impedance, Plots`; `R, C = Resistor(1e3), Capacitor(1e-6)`; `fs = logfreqs(10, 1e5, 200)`; `H = frequencyresponse(R, C, fs)`; `fc = cutofffrequency(R, C)`; magnitude subplot `db.(H)` (y-label "Magnitude (dB)") and phase subplot `phase.(H; degrees=true)` (y-label "Phase (°)", x-label "Frequency (Hz)"), both `xscale=:log10`, dashed `vline!` at `fc` labelled "fc ≈ 159 Hz"; combined with `layout=(2, 1)`, title "Bode plot — RC low-pass (R = 1 kΩ, C = 1 µF)", `background_color=:white`, `size=(800, 600)`; then `savefig` to `joinpath(@__DIR__, "..", "assets", "bode-rc-lowpass.svg")` and print the path. Keep the plotting body short enough to paste into the README unchanged (research R4)
- [X] T022 [US3] Generate assets/bode-rc-lowpass.svg by running `julia --project=scripts scripts/bode.jl`; open it and confirm −3 dB and −45° at the dashed line, −20 dB/decade slope above fc, phase approaching −90° with no jump, white background, all text English
- [X] T023 [US3] Add the Bode plot content to `### 6. Frequency response` in README.md (after T010) per contracts/readme-structure.md: a `#### Bode plot` sub-heading; one sentence saying it needs Plots.jl (`using Pkg; Pkg.add("Plots")`); the plotting body of scripts/bode.jl as a ```julia block (without `savefig`); and `![Bode plot of the RC low-pass filter: magnitude falls 20 dB/decade and phase goes from 0° to −90° past the 159 Hz cutoff](assets/bode-rc-lowpass.svg)`. Replace the old one-line "For a Bode plot…" sentence so it is not duplicated
- [X] T024 [US3] Verify US3: quickstart step 6 (`grep -n Plots Project.toml` → no output) and confirm the README snippet is identical to the plotting body of scripts/bode.jl

**Checkpoint**: all three stories done.

---

## Phase 6: Polish & Cross-Cutting Concerns

- [X] T025 Run the package test suite `julia --project=. -e 'using Pkg; Pkg.test()'` and confirm it passes
- [X] T026 Run every quickstart.md step (1–6) from specs/001-english-readme-assets/quickstart.md and record any deviation
- [X] T027 Paste each `julia>` block of README.md into `julia --project=.` (with `using Impedance`) and confirm the outputs match (SC-002); fix only text that no longer matches
- [X] T028 [P] Remove the Sync Impact Report HTML comment at the top of .specify/memory/constitution.md before committing (it is review scratch material; its README TODO is resolved by this feature)

---

## Dependencies & Execution Order

### Phase dependencies

- **Setup (Phase 1)**: start immediately. T001 blocks only T018.
- **Foundational (Phase 2)**: empty.
- **US1 (Phase 3)**: independent; T003–T014 run in order (same file).
- **US2 (Phase 4)**: independent of US1; T015–T017 → T018 → T019.
- **US3 (Phase 5)**: T020 → T021 → T022. T023 edits README section 6 and MUST run after T010
  to avoid conflicting edits. T024 after T023.
- **Polish (Phase 6)**: after all stories.

### Story completion order

```text
Setup ──► US1 (README) ──────────────┐
      ├─► US2 (preview image) ───────┼──► Polish
      └─► US3 scripts/figure ─► T023 ┘   (T023 waits for T010)
```

## Parallel Example

```text
# After Setup, three independent tracks:
Track A (US1): T003 … T014            # README.md
Track B (US2): T015 … T019            # assets/social-preview.*
Track C (US3): T020 → T021 → T022     # scripts/, assets/bode-rc-lowpass.svg
# Then T023 (needs T010), T024, Polish.
```

## Implementation Strategy

### MVP first (US1 only)

1. Phase 1 → Phase 3 (US1).
2. Validate with T014. The README is English and the constitution violation is resolved.

### Incremental delivery

1. US1 → README in English (MVP).
2. US2 → English preview image.
3. US3 → Bode figure and snippet.
4. Polish → full validation, then commit.
