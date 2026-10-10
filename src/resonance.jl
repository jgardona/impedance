# ---------------------------------------------------------------------------
# Resonance
# ---------------------------------------------------------------------------

"""
    resonantfrequency(L, C) -> Real

Resonant frequency of an LC circuit, in Hz: `f₀ = 1/(2π√(LC))`.
Accepts numbers or `Inductor`/`Capacitor` (in any order).
"""
resonantfrequency(L::Real, C::Real) = inv(2π * sqrt(L * C))
resonantfrequency(L::Inductor, C::Capacitor) = resonantfrequency(L.L, C.C)
resonantfrequency(C::Capacitor, L::Inductor) = resonantfrequency(L, C)

"""
    resonantfrequencies(e::Element; fmin=1.0, fmax=1e9, n=2000) -> Vector{Float64}

Numerically search, between `fmin` and `fmax`, for the frequencies where the
reactance of network `e` changes sign (`imag(Z) = 0`). The range is swept at
`n` logarithmic points and each sign change is refined by bisection.

Finds both series-type resonances (reactance zero) and parallel-type ones
(reactance pole, where `|Z|` peaks).
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

# Bisection on a logarithmic scale.
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
# Quality factor and bandwidth
# ---------------------------------------------------------------------------

"""
    qfactor(R, L, C; topology=:series) -> Real

Quality factor of an RLC circuit:

- `topology=:series`   → `Q = (1/R)·√(L/C)`
- `topology=:parallel` → `Q = R·√(C/L)`

Accepts numbers or `Resistor`, `Inductor` and `Capacitor`.
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

Bandwidth (−3 dB), in Hz: `BW = f₀/Q`.
"""
bandwidth(f0::Real, Q::Real) = f0 / Q
bandwidth(R, L, C; topology::Symbol=:series) =
    bandwidth(resonantfrequency(L, C), qfactor(R, L, C; topology=topology))

# ---------------------------------------------------------------------------
# Power factor
# ---------------------------------------------------------------------------

"""
    powerfactor(Z) -> Real

Power factor of a load with impedance `Z`: `cos φ`, where `φ = angle(Z)`.
"""
powerfactor(Z::ImpedanceValue) = cos(angle(Z))
powerfactor(z::Number) = cos(angle(z))

"""
    pfnature(Z; atol=0) -> Symbol

Nature of the power factor of load `Z`:

- `:lagging` — inductive (current lags the voltage)
- `:leading` — capacitive (current leads the voltage)
- `:unity`   — purely resistive (`|X| ≤ atol`)
"""
function pfnature(Z::_ZLike; atol::Real=0)
    X = imag(_c(Z))
    abs(X) <= atol && return :unity
    return X > 0 ? :lagging : :leading
end
