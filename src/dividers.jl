# ---------------------------------------------------------------------------
# Divisores de tensão e de corrente
# ---------------------------------------------------------------------------

const _ZLike = Union{ImpedanceValue,Number}

"""
    voltagedivider(V, Z1, Z2) -> Complex
    voltagedivider(V, e1::Element, e2::Element, f) -> Complex

Tensão sobre `Z2` num divisor com `Z1` e `Z2` em série, alimentado por `V`:

    V₂ = V · Z2 / (Z1 + Z2)
"""
voltagedivider(V::Number, Z1::_ZLike, Z2::_ZLike) = V * _c(Z2) / (_c(Z1) + _c(Z2))
voltagedivider(V::Number, e1::Element, e2::Element, f::Real) = voltagedivider(V, e1(f), e2(f))

"""
    voltagedivider(V, Zs::AbstractVector) -> Vector{Complex}
    voltagedivider(V, es::AbstractVector{<:Element}, f) -> Vector{Complex}

Tensão sobre cada impedância de `Zs`, todas em série sob a tensão `V`.
A soma das tensões é igual a `V`.
"""
function voltagedivider(V::Number, Zs::AbstractVector{<:_ZLike})
    zs = map(_c, Zs)
    Zt = sum(zs)
    return [V * z / Zt for z in zs]
end
voltagedivider(V::Number, es::AbstractVector{<:Element}, f::Real) = voltagedivider(V, [e(f) for e in es])

"""
    currentdivider(I, Z1, Z2) -> Complex
    currentdivider(I, e1::Element, e2::Element, f) -> Complex

Corrente em `Z1` num divisor com `Z1` e `Z2` em paralelo, alimentado por `I`:

    I₁ = I · Z2 / (Z1 + Z2)
"""
currentdivider(I::Number, Z1::_ZLike, Z2::_ZLike) = I * _c(Z2) / (_c(Z1) + _c(Z2))
currentdivider(I::Number, e1::Element, e2::Element, f::Real) = currentdivider(I, e1(f), e2(f))

"""
    currentdivider(I, Zs::AbstractVector) -> Vector{Complex}
    currentdivider(I, es::AbstractVector{<:Element}, f) -> Vector{Complex}

Corrente em cada ramo de `Zs`, todos em paralelo, alimentados pela corrente `I`.
A soma das correntes é igual a `I`.
"""
function currentdivider(I::Number, Zs::AbstractVector{<:_ZLike})
    ys = map(z -> inv(_c(z)), Zs)
    Yt = sum(ys)
    return [I * y / Yt for y in ys]
end
currentdivider(I::Number, es::AbstractVector{<:Element}, f::Real) = currentdivider(I, [e(f) for e in es])
