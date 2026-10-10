# ---------------------------------------------------------------------------
# Voltage and current dividers
# ---------------------------------------------------------------------------

const _ZLike = Union{ImpedanceValue,Number}

"""
    voltagedivider(V, Z1, Z2) -> Complex
    voltagedivider(V, e1::Element, e2::Element, f) -> Complex

Voltage across `Z2` in a divider with `Z1` and `Z2` in series, driven by `V`:

    V₂ = V · Z2 / (Z1 + Z2)
"""
voltagedivider(V::Number, Z1::_ZLike, Z2::_ZLike) = V * _c(Z2) / (_c(Z1) + _c(Z2))
voltagedivider(V::Number, e1::Element, e2::Element, f::Real) = voltagedivider(V, e1(f), e2(f))

"""
    voltagedivider(V, Zs::AbstractVector) -> Vector{Complex}
    voltagedivider(V, es::AbstractVector{<:Element}, f) -> Vector{Complex}

Voltage across each impedance in `Zs`, all in series under voltage `V`.
The voltages add up to `V`.
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

Current through `Z1` in a divider with `Z1` and `Z2` in parallel, driven by `I`:

    I₁ = I · Z2 / (Z1 + Z2)
"""
currentdivider(I::Number, Z1::_ZLike, Z2::_ZLike) = I * _c(Z2) / (_c(Z1) + _c(Z2))
currentdivider(I::Number, e1::Element, e2::Element, f::Real) = currentdivider(I, e1(f), e2(f))

"""
    currentdivider(I, Zs::AbstractVector) -> Vector{Complex}
    currentdivider(I, es::AbstractVector{<:Element}, f) -> Vector{Complex}

Current through each branch in `Zs`, all in parallel, driven by current `I`.
The currents add up to `I`.
"""
function currentdivider(I::Number, Zs::AbstractVector{<:_ZLike})
    ys = map(z -> inv(_c(z)), Zs)
    Yt = sum(ys)
    return [I * y / Yt for y in ys]
end
currentdivider(I::Number, es::AbstractVector{<:Element}, f::Real) = currentdivider(I, [e(f) for e in es])
