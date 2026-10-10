# ---------------------------------------------------------------------------
# Numeric type
# ---------------------------------------------------------------------------

"""
    ImpedanceValue(z::Number)
    ImpedanceValue(re, im)

Complex impedance `Z = R + jX` (in ohms) evaluated at a given frequency.

Prefer the constructors [`resistive`](@ref), [`inductive`](@ref),
[`capacitive`](@ref) or [`impedance`](@ref) over calling the type directly.
"""
struct ImpedanceValue{T<:Real}
    z::Complex{T}
end

ImpedanceValue(z::Real) = ImpedanceValue(complex(z))
ImpedanceValue(re::Real, im::Real) = ImpedanceValue(complex(re, im))
ImpedanceValue(Z::ImpedanceValue) = Z

"""
    impedance(z::Number) -> ImpedanceValue

Create an impedance from a real or complex number (in ohms).
"""
impedance(z::Number) = ImpedanceValue(z)
impedance(Z::ImpedanceValue) = Z

# Complex value of anything that represents an impedance (ImpedanceValue or number).
_c(Z::ImpedanceValue) = Z.z
_c(x::Number) = x

# Resolve the angular frequency from `f` (Hz) or `ω` (rad/s).
function _omega(f, ω)
    if f === nothing && ω === nothing
        throw(ArgumentError("provide the frequency `f` (Hz) or the `ω` keyword (rad/s)"))
    elseif f !== nothing && ω !== nothing
        throw(ArgumentError("provide either `f` or `ω`, not both"))
    end
    w = ω === nothing ? 2π * f : float(ω)
    w >= 0 || throw(ArgumentError("frequency must be ≥ 0, got $w rad/s"))
    return w
end

_nonneg(x, what) = x >= 0 ? x : throw(ArgumentError("$what must be ≥ 0, got $x"))

# ---------------------------------------------------------------------------
# Constructors
# ---------------------------------------------------------------------------

"""
    resistive(R) -> ImpedanceValue

Resistive impedance `Z = R` (frequency independent).
"""
resistive(R::Real) = ImpedanceValue(float(_nonneg(R, "resistance")))

"""
    inductive(L, f)
    inductive(L; ω)

Inductive impedance `Z = jωL`, with `ω = 2πf`. `L` in henries, `f` in Hz
(or `ω` in rad/s).
"""
inductive(L::Real, f=nothing; ω=nothing) =
    ImpedanceValue(complex(0.0, _omega(f, ω) * _nonneg(L, "inductance")))

"""
    capacitive(C, f)
    capacitive(C; ω)

Capacitive impedance `Z = 1/(jωC) = -j/(ωC)`, with `ω = 2πf`. `C` in farads,
`f` in Hz (or `ω` in rad/s). At `f = 0` the reactance is infinite (open circuit).
"""
capacitive(C::Real, f=nothing; ω=nothing) =
    ImpedanceValue(complex(0.0, -inv(_omega(f, ω) * _nonneg(C, "capacitance"))))

# ---------------------------------------------------------------------------
# Accessors
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

Phase angle of the impedance (or of a complex number, such as a transfer
function), in radians or degrees.
"""
angle(Z::ImpedanceValue; degrees::Bool=false) = phase(Z; degrees=degrees)
phase(Z::ImpedanceValue; degrees::Bool=false) = phase(Z.z; degrees=degrees)
phase(z::Number; degrees::Bool=false) = degrees ? rad2deg(angle(z)) : angle(z)

"""
    resistance(Z) -> Real

Resistive part of `Z` (same as `real(Z)`).
"""
resistance(Z::ImpedanceValue) = real(Z)

"""
    reactance(Z) -> Real

Reactive part of `Z` (same as `imag(Z)`): positive for inductive loads and
negative for capacitive ones.
"""
reactance(Z::ImpedanceValue) = imag(Z)

"""
    admittance(Z) -> Complex

Admittance `Y = 1/Z`, in siemens.
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
# Arithmetic
# ---------------------------------------------------------------------------

+(a::ImpedanceValue, b::ImpedanceValue) = ImpedanceValue(a.z + b.z)
+(a::ImpedanceValue, x::Number) = ImpedanceValue(a.z + x)
+(x::Number, a::ImpedanceValue) = a + x
-(a::ImpedanceValue, b::ImpedanceValue) = ImpedanceValue(a.z - b.z)
-(a::ImpedanceValue, x::Number) = ImpedanceValue(a.z - x)
-(x::Number, a::ImpedanceValue) = ImpedanceValue(x - a.z)
-(a::ImpedanceValue) = ImpedanceValue(-a.z)

# Scaling by a number keeps the unit (Ω).
*(a::ImpedanceValue, x::Number) = ImpedanceValue(a.z * x)
*(x::Number, a::ImpedanceValue) = a * x
/(a::ImpedanceValue, x::Number) = ImpedanceValue(a.z / x)

# Product (Ω²), ratio (dimensionless) and number/Z (e.g. V/Z = current)
# return complex numbers.
*(a::ImpedanceValue, b::ImpedanceValue) = a.z * b.z
/(a::ImpedanceValue, b::ImpedanceValue) = a.z / b.z
/(x::Number, a::ImpedanceValue) = x / a.z

# ---------------------------------------------------------------------------
# Ohm's law
# ---------------------------------------------------------------------------

"""
    voltage(Z, I) -> Complex

Voltage `V = Z·I` across impedance `Z` carrying the phasor current `I`.
"""
voltage(Z::ImpedanceValue, I::Number) = Z.z * I

"""
    current(V, Z) -> Complex

Current `I = V/Z` through impedance `Z` under the phasor voltage `V`.
"""
current(V::Number, Z::ImpedanceValue) = V / Z.z

# ---------------------------------------------------------------------------
# Display
# ---------------------------------------------------------------------------

function show(io::IO, Z::ImpedanceValue)
    re, im = real(Z), imag(Z)
    sign = signbit(im) ? "-" : "+"
    print(io, re, " ", sign, " ", abs(im), "j Ω")
end
