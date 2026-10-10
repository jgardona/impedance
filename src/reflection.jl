# ---------------------------------------------------------------------------
# Coeficiente de reflexão
# ---------------------------------------------------------------------------

"""
    reflectioncoefficient(ZL, Z0=50) -> Complex
    reflectioncoefficient(e::Element, f, Z0=50) -> Complex

Coeficiente de reflexão de uma carga `ZL` numa linha de impedância
característica `Z0`:

    Γ = (ZL − Z0) / (ZL + Z0)

`Γ = 0` para carga casada, `−1` para curto-circuito e `1` para circuito aberto.
"""
function reflectioncoefficient(ZL::_ZLike, Z0::_ZLike=50)
    zl, z0 = _c(ZL), _c(Z0)
    isinf(zl) && return complex(1.0)
    return complex((zl - z0) / (zl + z0))
end
reflectioncoefficient(e::Element, f::Real, Z0::_ZLike=50) = reflectioncoefficient(e(f), Z0)

"""
    vswr(Γ) -> Real

Relação de onda estacionária de tensão: `VSWR = (1 + |Γ|)/(1 − |Γ|)`.
"""
vswr(Γ::Number) = (1 + abs(Γ)) / (1 - abs(Γ))

"""
    returnloss(Γ) -> Real

Perda de retorno em dB: `RL = −20·log10(|Γ|)`.
"""
returnloss(Γ::Number) = -20 * log10(abs(Γ))
