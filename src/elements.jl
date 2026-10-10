# ---------------------------------------------------------------------------
# Elementos simbólicos
# ---------------------------------------------------------------------------

"""
    Element

Supertipo dos componentes e redes de impedância. Um `Element` guarda os valores
dos componentes (R, L, C) e pode ser avaliado em qualquer frequência:

    impedance(e, f)     # f em Hz
    impedance(e; ω)     # ω em rad/s
    e(f)                # atalho
"""
abstract type Element end

"""
    Resistor(R)

Resistor de `R` ohms.
"""
struct Resistor{T<:Real} <: Element
    R::T
    Resistor(R::T) where {T<:Real} = new{T}(_nonneg(R, "a resistência"))
end

"""
    Inductor(L)

Indutor de `L` henries.
"""
struct Inductor{T<:Real} <: Element
    L::T
    Inductor(L::T) where {T<:Real} = new{T}(_nonneg(L, "a indutância"))
end

"""
    Capacitor(C)

Capacitor de `C` farads.
"""
struct Capacitor{T<:Real} <: Element
    C::T
    Capacitor(C::T) where {T<:Real} = new{T}(_nonneg(C, "a capacitância"))
end

"""
    Fixed(Z)

Impedância constante, independente da frequência. Criada automaticamente ao
combinar um `ImpedanceValue` com um `Element`.
"""
struct Fixed{T<:Real} <: Element
    Z::ImpedanceValue{T}
end

Fixed(z::Number) = Fixed(ImpedanceValue(z))

"""
    Series(elements)

Associação em série. Normalmente criada com `a + b` ou `series(a, b, ...)`.
"""
struct Series <: Element
    elements::Vector{Element}
end

"""
    Parallel(elements)

Associação em paralelo. Normalmente criada com `a ∥ b` ou `parallel(a, b, ...)`.
"""
struct Parallel <: Element
    elements::Vector{Element}
end

# ---------------------------------------------------------------------------
# Avaliação
# ---------------------------------------------------------------------------

_z(e::Resistor, ω) = resistive(e.R)
_z(e::Inductor, ω) = inductive(e.L; ω=ω)
_z(e::Capacitor, ω) = capacitive(e.C; ω=ω)
_z(e::Fixed, ω) = e.Z
_z(e::Series, ω) = series((_z(x, ω) for x in e.elements)...)
_z(e::Parallel, ω) = parallel((_z(x, ω) for x in e.elements)...)

"""
    impedance(e::Element, f) -> ImpedanceValue
    impedance(e::Element; ω) -> ImpedanceValue

Avalia a impedância do elemento ou rede `e` na frequência `f` (Hz) ou `ω` (rad/s).
"""
impedance(e::Element, f=nothing; ω=nothing) = _z(e, _omega(f, ω))

(e::Element)(f::Real) = impedance(e, f)

# ---------------------------------------------------------------------------
# Exibição
# ---------------------------------------------------------------------------

const _SI_PREFIXES = ((1e12, "T"), (1e9, "G"), (1e6, "M"), (1e3, "k"), (1.0, ""),
                      (1e-3, "m"), (1e-6, "µ"), (1e-9, "n"), (1e-12, "p"))

# Formata um valor com prefixo SI: 0.01 H → "10 mH".
function _si(x::Real, unit::String)
    iszero(x) && return "0 $unit"
    scale, prefix = last(_SI_PREFIXES)
    for (s, p) in _SI_PREFIXES
        if abs(x) >= s
            scale, prefix = s, p
            break
        end
    end
    v = round(x / scale; sigdigits=4)
    v = isinteger(v) ? Int(v) : v
    return "$v $prefix$unit"
end

show(io::IO, e::Resistor) = print(io, "R(", _si(e.R, "Ω"), ")")
show(io::IO, e::Inductor) = print(io, "L(", _si(e.L, "H"), ")")
show(io::IO, e::Capacitor) = print(io, "C(", _si(e.C, "F"), ")")
show(io::IO, e::Fixed) = print(io, "Z(", e.Z, ")")

# Redes internas são sempre exibidas entre parênteses.
_showchild(io::IO, e::Element) = show(io, e)
_showchild(io::IO, e::Union{Series,Parallel}) = (print(io, "("); show(io, e); print(io, ")"))

function _showjoin(io::IO, elements, sep)
    for (i, x) in enumerate(elements)
        i > 1 && print(io, sep)
        _showchild(io, x)
    end
end

show(io::IO, e::Series) = _showjoin(io, e.elements, " + ")
show(io::IO, e::Parallel) = _showjoin(io, e.elements, " ∥ ")
