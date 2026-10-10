# ---------------------------------------------------------------------------
# Resposta em frequência
# ---------------------------------------------------------------------------

"""
    frequencyresponse(e::Element, freqs) -> Vector{ImpedanceValue}

Impedância da rede `e` em cada frequência de `freqs` (Hz).
"""
frequencyresponse(e::Element, freqs) = [impedance(e, f) for f in freqs]

"""
    transfer(top::Element, bottom::Element, f) -> Complex

Função de transferência de tensão `H = Vout/Vin` de um divisor com `top` em
série e a saída tomada sobre `bottom`:

    H(f) = Zb / (Zt + Zb)

Ex.: filtro RC passa-baixas → `transfer(Resistor(R), Capacitor(C), f)`.
"""
function transfer(top::Element, bottom::Element, f::Real)
    zt, zb = _c(top(f)), _c(bottom(f))
    # Forma 1/(1 + Zt·Yb) evita Inf/Inf quando Zb é um circuito aberto.
    return inv(1 + zt * inv(zb))
end

"""
    frequencyresponse(top::Element, bottom::Element, freqs) -> Vector{Complex}

Função de transferência [`transfer`](@ref) avaliada em cada frequência de `freqs`.
"""
frequencyresponse(top::Element, bottom::Element, freqs) = [transfer(top, bottom, f) for f in freqs]

"""
    db(H) -> Real

Ganho em decibéis: `20·log10(|H|)`.
"""
db(H::Number) = 20 * log10(abs(H))

"""
    logfreqs(f1, f2, n) -> Vector{Float64}

`n` frequências espaçadas logaritmicamente entre `f1` e `f2` (ambas > 0),
úteis para diagramas de Bode.
"""
function logfreqs(f1::Real, f2::Real, n::Integer)
    (f1 > 0 && f2 > 0) || throw(ArgumentError("as frequências devem ser > 0"))
    return collect(exp10.(range(log10(f1), log10(f2); length=n)))
end

"""
    cutofffrequency(R::Resistor, C::Capacitor) -> Real
    cutofffrequency(R::Resistor, L::Inductor) -> Real

Frequência de corte (−3 dB), em Hz, de um circuito RC (`1/(2πRC)`) ou RL
(`R/(2πL)`). A ordem dos argumentos é indiferente.
"""
cutofffrequency(R::Resistor, C::Capacitor) = inv(2π * R.R * C.C)
cutofffrequency(R::Resistor, L::Inductor) = R.R / (2π * L.L)
cutofffrequency(C::Capacitor, R::Resistor) = cutofffrequency(R, C)
cutofffrequency(L::Inductor, R::Resistor) = cutofffrequency(R, L)
