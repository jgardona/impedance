# ---------------------------------------------------------------------------
# Series and parallel combinations
# ---------------------------------------------------------------------------

const _ElementLike = Union{Element,ImpedanceValue}

_element(e::Element) = e
_element(Z::ImpedanceValue) = Fixed(Z)

# Flatten combinations of the same kind: (a + b) + c becomes Series([a, b, c]).
_flatten(::Type{T}, e::T) where {T<:Union{Series,Parallel}} = e.elements
_flatten(::Type, e::Element) = Element[e]

function _combine(::Type{T}, xs) where {T<:Union{Series,Parallel}}
    isempty(xs) && throw(ArgumentError("informe ao menos uma impedância"))
    length(xs) == 1 && return _element(only(xs))
    return T(reduce(vcat, (_flatten(T, _element(x)) for x in xs)))
end

"""
    series(Z1, Z2, ...)

Series combination: `Z = Z1 + Z2 + ...`.

- With `ImpedanceValue`s (or numbers), returns the resulting value.
- With `Element`s, returns a `Series` network that can be evaluated at any
  frequency. Values mixed with elements are treated as fixed impedances.

Equivalent to the `+` operator.
"""
series(xs::_ElementLike...) = _combine(Series, xs)
series(Zs::ImpedanceValue...) = sum(Zs)
series(xs::Number...) = sum(xs)
series() = throw(ArgumentError("informe ao menos uma impedância"))

"""
    parallel(Z1, Z2, ...)

Parallel combination: `1/Z = 1/Z1 + 1/Z2 + ...`.

- With `ImpedanceValue`s (or numbers), returns the resulting value. A zero
  impedance (short circuit) yields zero; infinite impedances (open circuit)
  are ignored.
- With `Element`s, returns a `Parallel` network that can be evaluated at any
  frequency.

Equivalent to the `∥` operator (type `\\parallel<tab>`).
"""
parallel(xs::_ElementLike...) = _combine(Parallel, xs)
parallel(Zs::ImpedanceValue...) = ImpedanceValue(_parallel(map(_c, Zs)))
parallel(xs::Number...) = _parallel(xs)
parallel() = throw(ArgumentError("informe ao menos uma impedância"))

function _parallel(zs)
    any(iszero, zs) && return zero(float(first(zs)))
    Y = sum(inv, zs)
    # All impedances infinite: open circuit.
    return iszero(Y) ? inv(zero(real(Y))) + zero(Y) : inv(Y)
end

+(a::Element, b::Element) = series(a, b)
+(a::Element, b::ImpedanceValue) = series(a, b)
+(a::ImpedanceValue, b::Element) = series(a, b)

"""
    a ∥ b

Parallel combination of impedances, elements or numbers (see
[`parallel`](@ref)).

!!! warning "Precedence and chaining"
    Julia's parser treats `∥` as a comparison operator:

    - it has lower precedence than `+`: `R + L ∥ C` is `(R + L) ∥ C`.
      Use parentheses: `R + (L ∥ C)`.
    - it chains like `<`: `R ∥ L ∥ C` becomes `(R ∥ L) && (L ∥ C)` and errors.
      Use `parallel(R, L, C)` or `(R ∥ L) ∥ C`.
    - it also chains with `==`, `≈`, `<`...: write `(Z1 ∥ Z2) ≈ Z3`.
"""
∥(a, b) = parallel(a, b)
