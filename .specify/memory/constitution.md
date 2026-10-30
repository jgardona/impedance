<!--
Sync Impact Report
==================
Version change: (unversioned template) → 1.0.0
Bump rationale: initial ratification; every placeholder replaced with concrete governance.

Modified principles (template slot → new title):
  - [PRINCIPLE_1_NAME] → I. SOLID Design
  - [PRINCIPLE_2_NAME] → II. Purposeful Design Patterns
  - [PRINCIPLE_3_NAME] → III. English as the Project Language
  - [PRINCIPLE_4_NAME] → IV. Human-Readable Documentation
  - [PRINCIPLE_5_NAME] → removed (user defined four principles)

Added sections:
  - Technical Constraints (was [SECTION_2_NAME])
  - Development Workflow & Quality Gates (was [SECTION_3_NAME])
  - Governance

Removed sections:
  - Fifth principle slot (not requested)

Templates: not modified by this command (they read the constitution at runtime).

Follow-up TODOs:
  - README.md is still written in Portuguese; it violates Principle III and must be
    migrated to English in a follow-up change.
-->

# Impedance.jl Constitution

## Core Principles

### I. SOLID Design

All source code MUST follow the SOLID principles, expressed in idiomatic Julia:

- **Single Responsibility**: each file, type, and function MUST have one clear reason to
  change. A source file groups one concern (e.g. `dividers.jl`, `resonance.jl`); a function
  computes one quantity.
- **Open/Closed**: behavior MUST be extended by adding new types and methods (multiple
  dispatch), not by editing existing functions with type checks (`isa` chains, `if typeof`).
  Optional integrations MUST live in package extensions (`ext/`), not in `src/`.
- **Liskov Substitution**: every subtype of an abstract type (e.g. `Element`) MUST honor the
  full contract of its supertype; any generic function accepting the supertype MUST work
  for every subtype without special-casing.
- **Interface Segregation**: abstract types and documented interfaces MUST stay minimal;
  callers MUST NOT be forced to implement methods they do not need.
- **Dependency Inversion**: generic code MUST depend on abstract types and documented
  interfaces, not on concrete structs. Method signatures SHOULD use the most abstract type
  that is correct (`Real`, `Number`, `AbstractVector`).

**Rationale**: Julia's multiple dispatch makes SOLID natural; enforcing it keeps the
numeric and symbolic layers composable and lets new components be added without risk to
existing ones.

### II. Purposeful Design Patterns

Design patterns MUST be applied when they solve a concrete, present problem, and MUST NOT be
introduced speculatively.

- Prefer patterns that fit Julia: Composite (networks of `Element`s), Strategy via dispatch,
  Factory functions / outer constructors, Holy traits, and callable objects (functors).
- Avoid patterns that fight the language (deep class-style hierarchies, getters/setters for
  plain fields, singletons holding mutable global state).
- When a pattern is applied, the relevant docstring or code comment MUST name it in one
  line when that is not obvious from the code.
- Any added abstraction MUST be justified in the plan or PR; if a simpler direct solution
  works, it MUST be used (YAGNI).

**Rationale**: patterns give a shared vocabulary and proven structure, but unneeded
abstraction makes a small numerical library harder to read and maintain.

### III. English as the Project Language

English is the single language of the project.

- Identifiers, docstrings, comments, error and warning messages, test descriptions,
  README and all other documentation, commit messages, and Spec Kit artifacts MUST be
  written in English.
- Domain terms MUST use standard English electrical-engineering vocabulary (impedance,
  admittance, reactance, quality factor, VSWR, return loss).
- New contributions in another language MUST NOT be merged; existing non-English content
  MUST be migrated when touched.

**Rationale**: a single, widely understood language makes the package usable by the
international Julia community and keeps code and documentation consistent.

### IV. Human-Readable Documentation

Documentation MUST be written for people first: clear, accurate, and example-driven.

- Every exported name (function, type, constant, macro) MUST have a docstring with: the
  call signature(s) and return type, a one-sentence summary, parameter units where
  physical (Hz, rad/s, Ω, H, F), and the governing formula when one applies.
- Docstrings SHOULD include a short `jldoctest` or usage example for non-trivial APIs.
- Errors MUST state what was wrong and what was expected (e.g. "resistance must be
  non-negative, got -5.0").
- The README MUST provide installation steps, a tutorial covering the main features, and
  be kept in sync with the public API in the same change that alters it.
- Prose MUST be plain and concise: short sentences, no unexplained jargon or acronyms, and
  no documentation that merely restates the function name.

**Rationale**: users of an engineering library need to trust units, formulas, and
behavior at a glance; readable docs are the primary interface to the code.

## Technical Constraints

- Language: Julia; minimum supported version is the one declared in `Project.toml`
  `[compat]` (currently 1.10).
- The core package MUST have no mandatory runtime dependencies beyond the Julia standard
  library; optional integrations (e.g. ComplexNumbers) MUST be weak dependencies loaded
  through package extensions.
- Public API changes MUST follow Semantic Versioning of the package version in
  `Project.toml`.
- Code MUST be type-stable in hot numeric paths and MUST NOT rely on mutable global state.

## Development Workflow & Quality Gates

- Every new or changed public behavior MUST be covered by tests in `test/`, and the full
  suite (`julia --project=. -e 'using Pkg; Pkg.test()'`) MUST pass before merge.
- Every change MUST be reviewed against the four Core Principles; reviewers MUST check
  SOLID compliance, justification of any design pattern, English-only content, and
  docstring completeness for exported names.
- Documentation updates (docstrings and README) MUST ship in the same change as the code
  they describe.
- Spec Kit plans MUST include a Constitution Check that confirms compliance or records a
  justified exception.

## Governance

This constitution supersedes all other development practices for Impedance.jl. When a
practice conflicts with it, the constitution wins.

- **Amendments**: proposed as a change to `.specify/memory/constitution.md` with a written
  rationale and an updated Sync Impact Report; they take effect when merged by the
  maintainer.
- **Versioning**: the constitution follows Semantic Versioning. MAJOR for removing or
  redefining a principle, MINOR for adding a principle or section or materially expanding
  guidance, PATCH for clarifications and wording fixes.
- **Compliance**: every pull request and review MUST verify compliance with this document.
  Exceptions MUST be documented with their justification in the plan or PR; unjustified
  complexity MUST be rejected.

**Version**: 1.0.0 | **Ratified**: 2026-10-30 | **Last Amended**: 2026-10-30
