# ---------------------------------------------------------------------------
# Associação em série e em paralelo
# ---------------------------------------------------------------------------

const _ElementLike = Union{Element,ImpedanceValue}

_element(e::Element) = e
_element(Z::ImpedanceValue) = Fixed(Z)

# Achata associações do mesmo tipo: (a + b) + c vira Series([a, b, c]).
_flatten(::Type{T}, e::T) where {T<:Union{Series,Parallel}} = e.elements
_flatten(::Type, e::Element) = Element[e]

function _combine(::Type{T}, xs) where {T<:Union{Series,Parallel}}
    isempty(xs) && throw(ArgumentError("informe ao menos uma impedância"))
    length(xs) == 1 && return _element(only(xs))
    return T(reduce(vcat, (_flatten(T, _element(x)) for x in xs)))
end

"""
    series(Z1, Z2, ...)

Associação em série: `Z = Z1 + Z2 + ...`.

- Com `ImpedanceValue` (ou números), retorna o valor resultante.
- Com `Element`, retorna uma rede `Series`, avaliável em qualquer frequência.
  Valores misturados com elementos são tratados como impedâncias fixas.

Equivale ao operador `+`.
"""
series(xs::_ElementLike...) = _combine(Series, xs)
series(Zs::ImpedanceValue...) = sum(Zs)
series(xs::Number...) = sum(xs)
series() = throw(ArgumentError("informe ao menos uma impedância"))

"""
    parallel(Z1, Z2, ...)

Associação em paralelo: `1/Z = 1/Z1 + 1/Z2 + ...`.

- Com `ImpedanceValue` (ou números), retorna o valor resultante. Uma impedância
  nula (curto-circuito) resulta em zero; impedâncias infinitas (circuito aberto)
  são ignoradas.
- Com `Element`, retorna uma rede `Parallel`, avaliável em qualquer frequência.

Equivale ao operador `∥` (digite `\\parallel<tab>`).
"""
parallel(xs::_ElementLike...) = _combine(Parallel, xs)
parallel(Zs::ImpedanceValue...) = ImpedanceValue(_parallel(map(_c, Zs)))
parallel(xs::Number...) = _parallel(xs)
parallel() = throw(ArgumentError("informe ao menos uma impedância"))

function _parallel(zs)
    any(iszero, zs) && return zero(float(first(zs)))
    Y = sum(inv, zs)
    # Todas as impedâncias infinitas: circuito aberto.
    return iszero(Y) ? inv(zero(real(Y))) + zero(Y) : inv(Y)
end

+(a::Element, b::Element) = series(a, b)
+(a::Element, b::ImpedanceValue) = series(a, b)
+(a::ImpedanceValue, b::Element) = series(a, b)

"""
    a ∥ b

Associação em paralelo de impedâncias, elementos ou números (ver
[`parallel`](@ref)).

!!! warning "Precedência e encadeamento"
    Para o parser do Julia, `∥` é um operador de comparação:

    - tem precedência menor que `+`: `R + L ∥ C` é `(R + L) ∥ C`.
      Use parênteses: `R + (L ∥ C)`.
    - é encadeado como `<`: `R ∥ L ∥ C` vira `(R ∥ L) && (L ∥ C)` e gera erro.
      Use `parallel(R, L, C)` ou `(R ∥ L) ∥ C`.
    - também encadeia com `==`, `≈`, `<`...: escreva `(Z1 ∥ Z2) ≈ Z3`.
"""
∥(a, b) = parallel(a, b)
