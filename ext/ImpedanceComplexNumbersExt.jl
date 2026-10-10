"""
Integração com o pacote ComplexNumbers: converte `ImpedanceValue` de/para
`ComplexNumber`, permitindo usar `tostring`, `topolar` etc.

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
