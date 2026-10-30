# ---------------------------------------------------------------------------
# Bode plot of the RC low-pass example from README section 6
# ---------------------------------------------------------------------------
#
# Writes assets/bode-rc-lowpass.svg. Run from the repository root:
#
#     julia --project=scripts -e 'using Pkg; Pkg.instantiate()'
#     julia --project=scripts scripts/bode.jl
#
# Julia 1.10 ignores the [sources] entry in scripts/Project.toml; there, run
# `using Pkg; Pkg.develop(path=".")` inside `julia --project=scripts` first.
#
# Everything between the two markers below is copied verbatim into the README.

# --- README snippet: begin ---
using Impedance, Plots

R, C = Resistor(1e3), Capacitor(1e-6)
fs = logfreqs(10, 1e5, 200)
H = frequencyresponse(R, C, fs)
fc = cutofffrequency(R, C)

ticks = (exp10.(1:5), ["10", "100", "1k", "10k", "100k"])

mag = plot(fs, db.(H); xscale=:log10, xticks=ticks, ylabel="Magnitude (dB)",
           label="|H|", title="Bode plot — RC low-pass (R = 1 kΩ, C = 1 µF)")
vline!(mag, [fc]; linestyle=:dash, label="fc ≈ 159 Hz")

pha = plot(fs, phase.(H; degrees=true); xscale=:log10, xticks=ticks,
           xlabel="Frequency (Hz)", ylabel="Phase (°)", ylims=(-90, 0),
           yticks=-90:15:0, label="∠H")
vline!(pha, [fc]; linestyle=:dash, label="fc ≈ 159 Hz")

plot(mag, pha; layout=(2, 1), size=(800, 600), background_color=:white)
# --- README snippet: end ---

out = joinpath(@__DIR__, "..", "assets", "bode-rc-lowpass.svg")
savefig(out)
println("Wrote ", normpath(out))
