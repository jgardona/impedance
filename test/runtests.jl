using Impedance
using Test

@testset "Impedance" begin

    @testset "Construtores numéricos" begin
        @test resistive(100) == ImpedanceValue(100.0, 0.0)
        @test inductive(1e-3, 1e3) ≈ ImpedanceValue(0, 2π)
        @test capacitive(1e-6, 1e3) ≈ ImpedanceValue(0, -1 / (2π * 1e-3))
        @test inductive(2; ω=10) ≈ ImpedanceValue(0, 20)
        @test capacitive(0.1; ω=10) ≈ ImpedanceValue(0, -1)
        @test isinf(capacitive(1e-6, 0))
        @test iszero(inductive(1e-3, 0))
        @test impedance(3 + 4im) == ImpedanceValue(3, 4)
        @test_throws ArgumentError resistive(-1)
        @test_throws ArgumentError inductive(1e-3)
        @test_throws ArgumentError inductive(1e-3, 1; ω=1)
        @test_throws ArgumentError capacitive(1e-6, -1)
    end

    @testset "Acessores" begin
        Z = ImpedanceValue(3, 4)
        @test real(Z) == 3 && imag(Z) == 4
        @test resistance(Z) == 3 && reactance(Z) == 4
        @test abs(Z) ≈ 5
        @test angle(Z) ≈ atan(4, 3)
        @test angle(Z; degrees=true) ≈ rad2deg(atan(4, 3))
        @test admittance(Z) ≈ 1 / (3 + 4im)
        @test inv(Z) == admittance(Z)
        @test conj(Z) == ImpedanceValue(3, -4)
        @test Complex(Z) == 3 + 4im
        @test sprint(show, Z) == "3 + 4j Ω"
        @test sprint(show, ImpedanceValue(1.5, -2.0)) == "1.5 - 2.0j Ω"
    end

    @testset "Aritmética" begin
        a, b = ImpedanceValue(1, 2), ImpedanceValue(3, -1)
        @test a + b == ImpedanceValue(4, 1)
        @test a - b == ImpedanceValue(-2, 3)
        @test -a == ImpedanceValue(-1, -2)
        @test 2a == ImpedanceValue(2, 4)
        @test a / 2 ≈ ImpedanceValue(0.5, 1)
        @test a + 1 == ImpedanceValue(2, 2)
        @test a * b == (1 + 2im) * (3 - im)
        @test a / b ≈ (1 + 2im) / (3 - im)
        @test voltage(a, 2) == 2 + 4im
        @test current(10, resistive(5)) ≈ 2
        @test 10 / resistive(5) ≈ 2
    end

    @testset "Série e paralelo (valores)" begin
        r = resistive(100)
        @test r + r == resistive(200)
        @test series(r, r, r) == resistive(300)
        @test (r ∥ r) ≈ resistive(50)
        @test parallel(r, r, r, r) ≈ resistive(25)
        @test (100 ∥ 100) ≈ 50
        @test iszero(r ∥ resistive(0))                     # curto-circuito
        @test (r ∥ capacitive(1e-6, 0)) ≈ r                  # circuito aberto
        # L ∥ C na ressonância → circuito aberto
        f0 = resonantfrequency(1e-3, 1e-6)
        @test abs(inductive(1e-3, f0) ∥ capacitive(1e-6, f0)) > 1e9
        @test_throws ArgumentError parallel()
    end

    @testset "Elementos" begin
        R, L, C = Resistor(100), Inductor(10e-3), Capacitor(1e-6)
        @test_throws ArgumentError Resistor(-1)
        @test_throws ArgumentError Capacitor(-1e-6)
        f = 1e3

        @test R(f) == resistive(100)
        @test L(f) ≈ inductive(10e-3, f)
        @test C(f) ≈ capacitive(1e-6, f)
        @test impedance(L; ω=100) ≈ inductive(10e-3; ω=100)

        net = R + (L ∥ C)
        @test net isa Series
        @test net(f) ≈ resistive(100) + (inductive(10e-3, f) ∥ capacitive(1e-6, f))

        s = (R + L) + C
        @test s isa Series && length(s.elements) == 3
        p = (R ∥ L) ∥ C
        @test p isa Parallel && length(p.elements) == 3
        @test parallel(R, L, C)(f) ≈ p(f)
        @test series(R) === R

        # Mistura de elemento e valor fixo
        m = R + ImpedanceValue(0, 50)
        @test m(f) ≈ ImpedanceValue(100, 50)
        @test (ImpedanceValue(0, 50) ∥ R) isa Parallel

        @test sprint(show, net) == "R(100 Ω) + (L(10 mH) ∥ C(1 µF))"
        @test sprint(show, Resistor(4700)) == "R(4.7 kΩ)"
    end

    @testset "Divisores" begin
        @test voltagedivider(10, resistive(1), resistive(1)) ≈ 5
        @test voltagedivider(12, 3, 1) ≈ 3
        Zs = [resistive(1), inductive(1e-3, 1e3), capacitive(1e-6, 1e3)]
        @test sum(voltagedivider(10, Zs)) ≈ 10
        @test currentdivider(1, resistive(1), resistive(3)) ≈ 0.75
        @test sum(currentdivider(2, Zs)) ≈ 2
        R, C = Resistor(1e3), Capacitor(1e-6)
        f = cutofffrequency(R, C)
        @test voltagedivider(1, R, C, f) ≈ transfer(R, C, f)
        @test voltagedivider(1, [R, C], f)[2] ≈ transfer(R, C, f)
        @test sum(currentdivider(1, [R, C], f)) ≈ 1
    end

    @testset "Resposta em frequência" begin
        R, C, L = Resistor(1e3), Capacitor(1e-6), Inductor(1e-3)
        fc = cutofffrequency(R, C)
        @test fc ≈ 1 / (2π * 1e3 * 1e-6)
        @test cutofffrequency(C, R) == fc
        @test cutofffrequency(R, L) ≈ 1e3 / (2π * 1e-3)
        H = transfer(R, C, fc)
        @test abs(H) ≈ 1 / √2
        @test db(H) ≈ -3.0103 atol = 1e-4
        @test phase(H; degrees=true) ≈ -45
        @test transfer(R, C, 0) ≈ 1                         # DC passa
        fs = logfreqs(10, 1e5, 50)
        @test length(fs) == 50 && fs[1] ≈ 10 && fs[end] ≈ 1e5
        Hs = frequencyresponse(R, C, fs)
        @test all(diff(abs.(Hs)) .< 0)                     # passa-baixas
        Zs = frequencyresponse(R + C, fs)
        @test Zs[1] ≈ (R + C)(10)
        @test_throws ArgumentError logfreqs(0, 10, 5)
    end

    @testset "Ressonância e fatores" begin
        R, L, C = Resistor(10), Inductor(1e-3), Capacitor(1e-6)
        f0 = resonantfrequency(L, C)
        @test f0 ≈ 1 / (2π * sqrt(1e-9))
        @test resonantfrequency(C, L) == f0
        @test abs(imag((R + L + C)(f0))) < 1e-9
        @test only(resonantfrequencies(R + L + C; fmax=1e6)) ≈ f0 rtol = 1e-9
        @test only(resonantfrequencies(parallel(R, L, C); fmax=1e6)) ≈ f0 rtol = 1e-9
        @test isempty(resonantfrequencies(R + L; fmax=1e6))

        @test qfactor(R, L, C) ≈ sqrt(1e-3 / 1e-6) / 10
        @test qfactor(R, L, C; topology=:parallel) ≈ 10 * sqrt(1e-6 / 1e-3)
        @test_throws ArgumentError qfactor(R, L, C; topology=:foo)
        @test bandwidth(R, L, C) ≈ f0 / qfactor(R, L, C)
        @test bandwidth(1000, 10) == 100

        @test powerfactor(resistive(3) + ImpedanceValue(0, 4)) ≈ 0.6
        @test powerfactor(resistive(10)) ≈ 1
        @test pfnature(ImpedanceValue(1, 1)) == :lagging
        @test pfnature(ImpedanceValue(1, -1)) == :leading
        @test pfnature(resistive(1)) == :unity
        @test pfnature(ImpedanceValue(1, 1e-12); atol=1e-9) == :unity
    end

    @testset "Coeficiente de reflexão" begin
        @test reflectioncoefficient(resistive(50)) ≈ 0
        @test reflectioncoefficient(resistive(0), 50) ≈ -1
        @test reflectioncoefficient(capacitive(1e-9, 0), 50) ≈ 1
        Γ = reflectioncoefficient(resistive(75), 50)
        @test Γ ≈ 0.2
        @test vswr(Γ) ≈ 1.5
        @test returnloss(Γ) ≈ -20log10(0.2)
        @test vswr(reflectioncoefficient(resistive(0))) == Inf
        @test reflectioncoefficient(Resistor(75), 1e6, 50) ≈ 0.2
        @test reflectioncoefficient(ImpedanceValue(50, 50), 50) ≈ (50im) / (100 + 50im)
    end
end
