"""
    Impedance

AC circuit analysis with complex impedances.

Works on two levels:

- **Numeric** — [`ImpedanceValue`](@ref): an impedance evaluated at a given
  frequency (`resistive`, `inductive`, `capacitive`).
- **Symbolic** — [`Element`](@ref): components (`Resistor`, `Inductor`,
  `Capacitor`) combined in series (`+`) and parallel (`∥`), evaluated at any
  frequency with `impedance(network, f)` or `network(f)`.

Includes voltage/current dividers, frequency response, resonance, quality
factor, power factor and reflection coefficient.
"""
module Impedance

import Base: +, -, *, /, ==, show, real, imag, abs, angle, conj, inv, isapprox,
             iszero, isinf, isfinite

# Numeric type and accessors
export ImpedanceValue, impedance, resistive, inductive, capacitive
export resistance, reactance, admittance, voltage, current, phase

# Symbolic elements and combinations
export Element, Resistor, Inductor, Capacitor, Fixed, Series, Parallel
export series, parallel, ∥

# Dividers
export voltagedivider, currentdivider

# Frequency response
export frequencyresponse, transfer, db, logfreqs, cutofffrequency

# Resonance and factors
export resonantfrequency, resonantfrequencies, qfactor, bandwidth, powerfactor, pfnature

# Transmission lines
export reflectioncoefficient, vswr, returnloss

include("values.jl")
include("elements.jl")
include("operators.jl")
include("dividers.jl")
include("frequency.jl")
include("resonance.jl")
include("reflection.jl")

end # module
