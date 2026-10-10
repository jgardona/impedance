# ---------------------------------------------------------------------------
# Frequency response
# ---------------------------------------------------------------------------

"""
    frequencyresponse(e::Element, freqs) -> Vector{ImpedanceValue}

Impedance of network `e` at each frequency in `freqs` (Hz).
"""
frequencyresponse(e::Element, freqs) = [impedance(e, f) for f in freqs]

"""
    transfer(top::Element, bottom::Element, f) -> Complex

Voltage transfer function `H = Vout/Vin` of a divider with `top` in series
and the output taken across `bottom`:

    H(f) = Zb / (Zt + Zb)

E.g. RC low-pass filter → `transfer(Resistor(R), Capacitor(C), f)`.
"""
function transfer(top::Element, bottom::Element, f::Real)
    zt, zb = _c(top(f)), _c(bottom(f))
    # The 1/(1 + Zt·Yb) form avoids Inf/Inf when Zb is an open circuit.
    return inv(1 + zt * inv(zb))
end

"""
    frequencyresponse(top::Element, bottom::Element, freqs) -> Vector{Complex}

Transfer function [`transfer`](@ref) evaluated at each frequency in `freqs`.
"""
frequencyresponse(top::Element, bottom::Element, freqs) = [transfer(top, bottom, f) for f in freqs]

"""
    db(H) -> Real

Gain in decibels: `20·log10(|H|)`.
"""
db(H::Number) = 20 * log10(abs(H))

"""
    logfreqs(f1, f2, n) -> Vector{Float64}

`n` logarithmically spaced frequencies between `f1` and `f2` (both > 0),
useful for Bode plots.
"""
function logfreqs(f1::Real, f2::Real, n::Integer)
    (f1 > 0 && f2 > 0) || throw(ArgumentError("frequencies must be > 0"))
    return collect(exp10.(range(log10(f1), log10(f2); length=n)))
end

"""
    cutofffrequency(R::Resistor, C::Capacitor) -> Real
    cutofffrequency(R::Resistor, L::Inductor) -> Real

Cutoff (−3 dB) frequency, in Hz, of an RC (`1/(2πRC)`) or RL (`R/(2πL)`)
circuit. Argument order does not matter.
"""
cutofffrequency(R::Resistor, C::Capacitor) = inv(2π * R.R * C.C)
cutofffrequency(R::Resistor, L::Inductor) = R.R / (2π * L.L)
cutofffrequency(C::Capacitor, R::Resistor) = cutofffrequency(R, C)
cutofffrequency(L::Inductor, R::Resistor) = cutofffrequency(R, L)
