# Feature Specification: English README, Preview Images and Bode Plots

**Feature Branch**: `001-english-readme-assets`

**Created**: 2026-10-30

**Status**: Draft

**Input**: User description: "adapt the readme and the thumbnails images for english language."
Follow-up: "We also need to add bode plots for the bode example."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Read the README in English (Priority: P1)

An English-speaking Julia user visits the package repository and reads the README to decide
whether the package fits their needs, install it, and follow the tutorial. Today every
heading, explanation, table, note, and code comment in the README is in Portuguese, so the
user cannot follow it without a translator.

**Why this priority**: the README is the main entry point and the only user guide. It is
also the documented violation of Constitution Principle III (English as the Project
Language). Translating it alone delivers most of the value.

**Independent Test**: open the README and confirm that all prose, headings, table
contents, callouts, and code comments are in English, and that every tutorial example
still produces the shown output when run.

**Acceptance Scenarios**:

1. **Given** the current Portuguese README, **When** the feature is delivered, **Then**
   every section (feature list, requirements, installation, tutorial sections 1–9, quick
   reference) exists in English with the same order and the same technical content.
2. **Given** a tutorial example in the README, **When** a user copies it into a Julia
   session with the package loaded, **Then** it runs and produces the output shown.
3. **Given** a code example that uses a Portuguese variable name (e.g. `rede`), **When**
   the feature is delivered, **Then** the name is replaced by an English equivalent
   (e.g. `network`) consistently across every example that uses it.
4. **Given** the installation instructions, **When** a user reads them, **Then**
   placeholder paths and comments are in English (e.g. `/path/to/impedance`).

---

### User Story 2 - See an English preview image (Priority: P2)

A visitor sees the package's preview image at the top of the README and when the
repository link is shared on social media or chat tools. The tagline and the sample code in
the image are currently in Portuguese.

**Why this priority**: the image is the first visual impression of the package, but it
carries only a tagline and a short code sample, so it matters less than the full README.

**Independent Test**: view the vector and raster preview images and confirm that all
visible text is in English and the layout and styling are unchanged.

**Acceptance Scenarios**:

1. **Given** the preview image, **When** the feature is delivered, **Then** the tagline
   reads in English with the same meaning (complex impedances in Julia: series, parallel,
   frequency response and resonance).
2. **Given** the sample code in the image, **When** the feature is delivered, **Then** it
   uses the same English variable name as the README (e.g. `network`) and the shown output
   matches what the package actually prints.
3. **Given** the vector and raster versions of the image, **When** they are compared,
   **Then** both show identical English content at the same dimensions (1280 × 640).
4. **Given** the image source, **When** a contributor opens it, **Then** its internal
   comments are in English.

---

### User Story 3 - See the Bode plot for the frequency-response example (Priority: P3)

A user reading tutorial section 6 (frequency response) is told they can draw a Bode diagram
from the RC low-pass example, but the README only describes it in one sentence. The user
wants to see what the resulting magnitude and phase curves look like and how to reproduce
them.

**Why this priority**: it improves the tutorial but adds new content rather than fixing the
language violation, so it ranks below the two translation stories.

**Independent Test**: open section 6 of the README and confirm it shows a Bode plot of the
RC low-pass example and a code snippet that, when run, produces an equivalent plot.

**Acceptance Scenarios**:

1. **Given** the RC low-pass example in section 6 (R = 1 kΩ, C = 1 µF, 200 log-spaced
   frequencies from 10 Hz to 100 kHz), **When** the feature is delivered, **Then** the
   README shows a Bode plot with a magnitude panel (dB) and a phase panel (degrees) sharing
   a logarithmic frequency axis (Hz).
2. **Given** the Bode plot, **When** a user reads it, **Then** the cutoff frequency
   (≈ 159.15 Hz) is marked, and the curves show about −3 dB and −45° at that frequency,
   about 0 dB / 0° well below it, and a −20 dB/decade slope approaching −90° well above it.
3. **Given** the README text next to the plot, **When** a user copies the plotting snippet
   into a session with a plotting package installed, **Then** it produces an equivalent
   plot from the same data.
4. **Given** the plot image, **When** it is viewed, **Then** all titles, axis labels,
   legends, and annotations are in English.

---

### Edge Cases

- Translated tagline is longer than the original: it MUST still fit within the left text
  area without overlapping the code panel or the circuit diagram.
- Translated variable name is longer than the original: the code lines in the image MUST
  still fit inside the code panel.
- Mathematical notation, unit symbols (Ω, H, F, Hz), operators (`∥`), and function names
  are language-neutral and MUST remain unchanged.
- Numeric outputs in examples MUST NOT change as a side effect of renaming variables.
- The Bode plot MUST stay readable on both light and dark README backgrounds (no
  transparent background with dark-only or light-only text).
- Phase values near −90° at high frequency MUST NOT wrap or jump to +270°.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The README MUST contain no Portuguese text (prose, headings, table cells,
  callouts, code comments, alt text, or placeholder paths).
- **FR-002**: The README MUST keep its current structure: the same sections in the same
  order, the same examples, and the same technical claims; the only addition is the Bode
  plot content in section 6 (FR-010 to FR-014).
- **FR-003**: Domain terminology MUST use standard English electrical-engineering terms
  (e.g. impedance, admittance, reactance, voltage divider, current divider, frequency
  response, cutoff frequency, resonance, quality factor, bandwidth, power factor,
  reflection coefficient, VSWR, return loss).
- **FR-004**: Portuguese identifiers used in examples MUST be replaced with English names,
  applied consistently between the README and the preview image.
- **FR-005**: Every code example in the README MUST still produce its displayed output with
  the current package.
- **FR-006**: The vector preview image MUST show the tagline and code sample in English and
  keep its existing visual design (colors, layout, circuit diagram, dimensions).
- **FR-007**: The raster preview image MUST be regenerated from the updated vector image so
  both versions match.
- **FR-008**: Comments inside the image source MUST be in English.
- **FR-009**: The README's reference to the preview image MUST continue to resolve and
  display the image.
- **FR-010**: Section 6 of the README MUST display a Bode plot of the RC low-pass example,
  with magnitude in dB and phase in degrees against frequency on a logarithmic Hz axis.
- **FR-011**: The Bode plot MUST mark the cutoff frequency and MUST be computed from the
  package's own frequency-response results, so it matches the numbers in the example.
- **FR-012**: The README MUST include a short, runnable snippet that reproduces the Bode
  plot, and MUST state which external plotting package it needs.
- **FR-013**: The package itself MUST NOT gain a mandatory dependency on a plotting
  package; plotting stays the user's choice (Constitution: Technical Constraints).
- **FR-014**: The Bode plot image MUST be stored in the project's `assets` folder and its
  text MUST be in English.
- **FR-015**: The procedure or script used to produce the Bode plot image MUST be kept in
  the repository so the image can be regenerated when the example changes.

### Key Entities

- **README**: the package's user guide; contains overview, installation, a nine-part
  tutorial, and a quick reference.
- **Preview image (vector)**: the source illustration shown at the top of the README.
- **Preview image (raster)**: a 1280 × 640 copy of the vector image, used where vector
  images are not supported (e.g. repository social preview).
- **Bode plot image**: a two-panel figure (magnitude in dB, phase in degrees) of the RC
  low-pass example from tutorial section 6, with the cutoff frequency marked.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of README text and preview-image text is in English; a review finds zero
  Portuguese words outside proper names.
- **SC-002**: 100% of README tutorial examples run and produce the shown output.
- **SC-003**: The README has the same number of sections and examples as before (no content
  lost).
- **SC-004**: The vector and raster preview images show identical text, and none of the
  text overflows or overlaps other elements.
- **SC-005**: An English-speaking user can install the package and run the first tutorial
  example using only the README, in under 5 minutes.
- **SC-006**: In the Bode plot, the values read at the marked cutoff frequency are within
  0.5 dB of −3 dB and within 2° of −45°.
- **SC-007**: A user can reproduce the Bode plot from the README snippet in under
  5 minutes, assuming the plotting package is installed.

## Assumptions

- "Thumbnails images" refers to the package preview image in both its vector and raster
  versions in the `assets` folder; there are no other images in the project.
- "Bode plots for the bode example" means a static image plus a reproduction snippet in the
  README for the existing RC low-pass example in section 6. Adding a plotting function or
  plotting extension to the package is out of scope.
- One combined figure (magnitude above, phase below) satisfies "Bode plots"; separate
  images for magnitude and phase are acceptable if they convey the same content.
- Apart from the Bode plot content, the translation is faithful: no new sections,
  features, or examples are added and none are removed. Fixing an example whose shown
  output is wrong is in scope only to satisfy FR-005.
- The Portuguese README is replaced, not kept alongside an English version; no
  multi-language documentation is required.
- Source code docstrings and error messages are already in English (previous commits) and
  are out of scope.
- The raster image can be regenerated from the vector source with the same fonts used
  originally; if a font is unavailable, a visually equivalent fallback is acceptable.
