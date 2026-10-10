"""
    Impedance

Pacote para análise de circuitos em corrente alternada usando impedâncias
complexas.

Trabalha em dois níveis:

- **Numérico** — [`ImpedanceValue`](@ref): uma impedância avaliada numa
  frequência (`resistive`, `inductive`, `capacitive`).
- **Simbólico** — [`Element`](@ref): componentes (`Resistor`, `Inductor`,
  `Capacitor`) combinados em série (`+`) e paralelo (`∥`), avaliados em
  qualquer frequência com `impedance(rede, f)` ou `rede(f)`.

Inclui divisores de tensão/corrente, resposta em frequência, ressonância,
fator de qualidade, fator de potência e coeficiente de reflexão.
"""
module Impedance

import Base: +, -, *, /, ==, show, real, imag, abs, angle, conj, inv, isapprox,
             iszero, isinf, isfinite

# Tipo numérico e acessores
export ImpedanceValue, impedance, resistive, inductive, capacitive
export resistance, reactance, admittance, voltage, current, phase

# Elementos simbólicos e associações
export Element, Resistor, Inductor, Capacitor, Fixed, Series, Parallel
export series, parallel, ∥

# Divisores
export voltagedivider, currentdivider

# Resposta em frequência
export frequencyresponse, transfer, db, logfreqs, cutofffrequency

# Ressonância e fatores
export resonantfrequency, resonantfrequencies, qfactor, bandwidth, powerfactor, pfnature

# Linhas de transmissão
export reflectioncoefficient, vswr, returnloss

include("values.jl")
include("elements.jl")
include("operators.jl")
include("dividers.jl")
include("frequency.jl")
include("resonance.jl")
include("reflection.jl")

end # module
