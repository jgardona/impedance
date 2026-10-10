"""
Integration with the ComplexNumbers package: converts `ImpedanceValue` to and
from `ComplexNumber`, enabling `tostring`, `topolar`, etc.

    using Impedance, ComplexNumbers
    tostring(ComplexNumber(Z); form=:polar, degrees=true)
"""
module ImpedanceComplexNumbersExt

using Impedance
using ComplexNumbers

ComplexNumbers.ComplexNumber(Z::ImpedanceValue) = ComplexNumber(real(Z), imag(Z))
Impedance.ImpedanceValue(z::ComplexNumber) = ImpedanceValue(real(z), imag(z))
Impedance.impedance(z::ComplexNumber) = ImpedanceValue(z)

end # module
