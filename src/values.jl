# ---------------------------------------------------------------------------
# Tipo numérico
# ---------------------------------------------------------------------------

"""
    ImpedanceValue(z::Number)
    ImpedanceValue(re, im)

Impedância complexa `Z = R + jX` (em ohms) avaliada numa frequência.

Use os construtores [`resistive`](@ref), [`inductive`](@ref) e
[`capacitive`](@ref), ou [`impedance`](@ref), em vez de chamar o tipo
diretamente.
"""
struct ImpedanceValue{T<:Real}
    z::Complex{T}
end

ImpedanceValue(z::Real) = ImpedanceValue(complex(z))
ImpedanceValue(re::Real, im::Real) = ImpedanceValue(complex(re, im))
ImpedanceValue(Z::ImpedanceValue) = Z

"""
    impedance(z::Number) -> ImpedanceValue

Cria uma impedância a partir de um número real ou complexo (em ohms).
"""
impedance(z::Number) = ImpedanceValue(z)
impedance(Z::ImpedanceValue) = Z

# Valor complexo de algo que represente uma impedância (ImpedanceValue ou número).
_c(Z::ImpedanceValue) = Z.z
_c(x::Number) = x

# Resolve a frequência angular a partir de `f` (Hz) ou de `ω` (rad/s).
function _omega(f, ω)
    if f === nothing && ω === nothing
        throw(ArgumentError("informe a frequência `f` (Hz) ou a palavra-chave `ω` (rad/s)"))
    elseif f !== nothing && ω !== nothing
        throw(ArgumentError("informe apenas `f` ou `ω`, não ambos"))
    end
    w = ω === nothing ? 2π * f : float(ω)
    w >= 0 || throw(ArgumentError("a frequência deve ser ≥ 0, recebido $w rad/s"))
    return w
end

_nonneg(x, what) = x >= 0 ? x : throw(ArgumentError("$what deve ser ≥ 0, recebido $x"))

# ---------------------------------------------------------------------------
# Construtores
# ---------------------------------------------------------------------------

"""
    resistive(R) -> ImpedanceValue

Impedância resistiva `Z = R` (independe da frequência).
"""
resistive(R::Real) = ImpedanceValue(float(_nonneg(R, "a resistência")))

"""
    inductive(L, f)
    inductive(L; ω)

Impedância indutiva `Z = jωL`, com `ω = 2πf`. `L` em henries, `f` em Hz
(ou `ω` em rad/s).
"""
inductive(L::Real, f=nothing; ω=nothing) =
    ImpedanceValue(complex(0.0, _omega(f, ω) * _nonneg(L, "a indutância")))

"""
    capacitive(C, f)
    capacitive(C; ω)

Impedância capacitiva `Z = 1/(jωC) = -j/(ωC)`, com `ω = 2πf`. `C` em farads,
`f` em Hz (ou `ω` em rad/s). Em `f = 0` a reatância é infinita (circuito aberto).
"""
capacitive(C::Real, f=nothing; ω=nothing) =
    ImpedanceValue(complex(0.0, -inv(_omega(f, ω) * _nonneg(C, "a capacitância"))))

# ---------------------------------------------------------------------------
# Acessores
# ---------------------------------------------------------------------------

real(Z::ImpedanceValue) = real(Z.z)
imag(Z::ImpedanceValue) = imag(Z.z)
abs(Z::ImpedanceValue) = abs(Z.z)
conj(Z::ImpedanceValue) = ImpedanceValue(conj(Z.z))
Base.Complex(Z::ImpedanceValue) = Z.z
Base.complex(Z::ImpedanceValue) = Z.z

"""
    angle(Z; degrees=false)
    phase(Z; degrees=false)

Ângulo de fase da impedância (ou de um número complexo, como uma função de
transferência), em radianos ou graus.
"""
angle(Z::ImpedanceValue; degrees::Bool=false) = phase(Z; degrees=degrees)
phase(Z::ImpedanceValue; degrees::Bool=false) = phase(Z.z; degrees=degrees)
phase(z::Number; degrees::Bool=false) = degrees ? rad2deg(angle(z)) : angle(z)

"""
    resistance(Z) -> Real

Parte resistiva de `Z` (o mesmo que `real(Z)`).
"""
resistance(Z::ImpedanceValue) = real(Z)

"""
    reactance(Z) -> Real

Parte reativa de `Z` (o mesmo que `imag(Z)`): positiva para cargas indutivas e
negativa para capacitivas.
"""
reactance(Z::ImpedanceValue) = imag(Z)

"""
    admittance(Z) -> Complex

Admitância `Y = 1/Z`, em siemens.
"""
admittance(Z::ImpedanceValue) = inv(Z.z)
inv(Z::ImpedanceValue) = admittance(Z)

iszero(Z::ImpedanceValue) = iszero(Z.z)
isinf(Z::ImpedanceValue) = isinf(Z.z)
isfinite(Z::ImpedanceValue) = isfinite(Z.z)

==(a::ImpedanceValue, b::ImpedanceValue) = a.z == b.z
isapprox(a::ImpedanceValue, b::ImpedanceValue; kwargs...) = isapprox(a.z, b.z; kwargs...)
isapprox(a::ImpedanceValue, b::Number; kwargs...) = isapprox(a.z, b; kwargs...)
isapprox(a::Number, b::ImpedanceValue; kwargs...) = isapprox(a, b.z; kwargs...)

# ---------------------------------------------------------------------------
# Aritmética
# ---------------------------------------------------------------------------

+(a::ImpedanceValue, b::ImpedanceValue) = ImpedanceValue(a.z + b.z)
+(a::ImpedanceValue, x::Number) = ImpedanceValue(a.z + x)
+(x::Number, a::ImpedanceValue) = a + x
-(a::ImpedanceValue, b::ImpedanceValue) = ImpedanceValue(a.z - b.z)
-(a::ImpedanceValue, x::Number) = ImpedanceValue(a.z - x)
-(x::Number, a::ImpedanceValue) = ImpedanceValue(x - a.z)
-(a::ImpedanceValue) = ImpedanceValue(-a.z)

# Escalonamento por número mantém a unidade (Ω).
*(a::ImpedanceValue, x::Number) = ImpedanceValue(a.z * x)
*(x::Number, a::ImpedanceValue) = a * x
/(a::ImpedanceValue, x::Number) = ImpedanceValue(a.z / x)

# Produto (Ω²), razão (adimensional) e número/Z (ex.: V/Z = corrente)
# retornam números complexos.
*(a::ImpedanceValue, b::ImpedanceValue) = a.z * b.z
/(a::ImpedanceValue, b::ImpedanceValue) = a.z / b.z
/(x::Number, a::ImpedanceValue) = x / a.z

# ---------------------------------------------------------------------------
# Lei de Ohm
# ---------------------------------------------------------------------------

"""
    voltage(Z, I) -> Complex

Tensão `V = Z·I` sobre a impedância `Z` percorrida pela corrente fasorial `I`.
"""
voltage(Z::ImpedanceValue, I::Number) = Z.z * I

"""
    current(V, Z) -> Complex

Corrente `I = V/Z` na impedância `Z` sob a tensão fasorial `V`.
"""
current(V::Number, Z::ImpedanceValue) = V / Z.z

# ---------------------------------------------------------------------------
# Exibição
# ---------------------------------------------------------------------------

function show(io::IO, Z::ImpedanceValue)
    re, im = real(Z), imag(Z)
    sign = signbit(im) ? "-" : "+"
    print(io, re, " ", sign, " ", abs(im), "j Ω")
end
