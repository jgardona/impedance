# ---------------------------------------------------------------------------
# Reflection coefficient
# ---------------------------------------------------------------------------

"""
    reflectioncoefficient(ZL, Z0=50) -> Complex
    reflectioncoefficient(e::Element, f, Z0=50) -> Complex

Reflection coefficient of a load `ZL` on a line with characteristic
impedance `Z0`:

    Γ = (ZL − Z0) / (ZL + Z0)

`Γ = 0` for a matched load, `−1` for a short circuit and `1` for an open circuit.
"""
function reflectioncoefficient(ZL::_ZLike, Z0::_ZLike=50)
    zl, z0 = _c(ZL), _c(Z0)
    isinf(zl) && return complex(1.0)
    return complex((zl - z0) / (zl + z0))
end
reflectioncoefficient(e::Element, f::Real, Z0::_ZLike=50) = reflectioncoefficient(e(f), Z0)

"""
    vswr(Γ) -> Real

Voltage standing wave ratio: `VSWR = (1 + |Γ|)/(1 − |Γ|)`.
"""
vswr(Γ::Number) = (1 + abs(Γ)) / (1 - abs(Γ))

"""
    returnloss(Γ) -> Real

Return loss in dB: `RL = −20·log10(|Γ|)`.
"""
returnloss(Γ::Number) = -20 * log10(abs(Γ))
