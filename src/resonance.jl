# ---------------------------------------------------------------------------
# Ressonância
# ---------------------------------------------------------------------------

"""
    resonantfrequency(L, C) -> Real

Frequência de ressonância de um circuito LC, em Hz: `f₀ = 1/(2π√(LC))`.
Aceita valores numéricos ou `Inductor`/`Capacitor` (em qualquer ordem).
"""
resonantfrequency(L::Real, C::Real) = inv(2π * sqrt(L * C))
resonantfrequency(L::Inductor, C::Capacitor) = resonantfrequency(L.L, C.C)
resonantfrequency(C::Capacitor, L::Inductor) = resonantfrequency(L, C)

"""
    resonantfrequencies(e::Element; fmin=1.0, fmax=1e9, n=2000) -> Vector{Float64}

Busca numérica das frequências, entre `fmin` e `fmax`, em que a reatância da
rede `e` troca de sinal (`imag(Z) = 0`). A faixa é varrida em `n` pontos
logarítmicos e cada troca de sinal é refinada por bisseção.

Encontra tanto ressonâncias do tipo série (zero de reatância) quanto do tipo
paralelo (polo de reatância, onde `|Z|` é máximo).
"""
function resonantfrequencies(e::Element; fmin::Real=1.0, fmax::Real=1e9, n::Integer=2000)
    freqs = logfreqs(fmin, fmax, n)
    x(f) = imag(impedance(e, f))
    roots = Float64[]
    xprev = x(freqs[1])
    iszero(xprev) && push!(roots, freqs[1])
    for i in 2:length(freqs)
        xi = x(freqs[i])
        if iszero(xi)
            push!(roots, freqs[i])
        elseif !iszero(xprev) && signbit(xprev) != signbit(xi)
            push!(roots, _bisect(x, freqs[i-1], freqs[i]))
        end
        xprev = xi
    end
    return roots
end

# Bisseção em escala logarítmica.
function _bisect(x, a, b; iters=100)
    sa = signbit(x(a))
    for _ in 1:iters
        m = sqrt(a * b)
        sm = signbit(x(m))
        sm == sa ? (a = m) : (b = m)
        b / a - 1 < 1e-14 && break
    end
    return sqrt(a * b)
end

# ---------------------------------------------------------------------------
# Fator de qualidade e largura de banda
# ---------------------------------------------------------------------------

"""
    qfactor(R, L, C; topology=:series) -> Real

Fator de qualidade de um circuito RLC:

- `topology=:series`   → `Q = (1/R)·√(L/C)`
- `topology=:parallel` → `Q = R·√(C/L)`

Aceita valores numéricos ou `Resistor`, `Inductor` e `Capacitor`.
"""
function qfactor(R::Real, L::Real, C::Real; topology::Symbol=:series)
    if topology === :series
        return sqrt(L / C) / R
    elseif topology === :parallel
        return R * sqrt(C / L)
    else
        throw(ArgumentError("topologia inválida: $(repr(topology)); use :series ou :parallel"))
    end
end
qfactor(R::Resistor, L::Inductor, C::Capacitor; topology::Symbol=:series) =
    qfactor(R.R, L.L, C.C; topology=topology)

"""
    bandwidth(f0, Q) -> Real
    bandwidth(R, L, C; topology=:series) -> Real

Largura de banda (−3 dB), em Hz: `BW = f₀/Q`.
"""
bandwidth(f0::Real, Q::Real) = f0 / Q
bandwidth(R, L, C; topology::Symbol=:series) =
    bandwidth(resonantfrequency(L, C), qfactor(R, L, C; topology=topology))

# ---------------------------------------------------------------------------
# Fator de potência
# ---------------------------------------------------------------------------

"""
    powerfactor(Z) -> Real

Fator de potência de uma carga de impedância `Z`: `cos φ`, onde `φ = angle(Z)`.
"""
powerfactor(Z::ImpedanceValue) = cos(angle(Z))
powerfactor(z::Number) = cos(angle(z))

"""
    pfnature(Z; atol=0) -> Symbol

Natureza do fator de potência da carga `Z`:

- `:lagging` — indutiva (corrente atrasada em relação à tensão)
- `:leading` — capacitiva (corrente adiantada)
- `:unity`   — puramente resistiva (`|X| ≤ atol`)
"""
function pfnature(Z::_ZLike; atol::Real=0)
    X = imag(_c(Z))
    abs(X) <= atol && return :unity
    return X > 0 ? :lagging : :leading
end
