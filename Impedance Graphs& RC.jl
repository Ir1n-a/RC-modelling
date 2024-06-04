using Plots
using CSV
using NativeFileDialog
using DataFrames
plotlyjs()

function plot_format(x,y)
    plot(x,y,xscale=:log10,
    framestyle=:box,right_margin=7*Plots.mm,linewidth=4,
    formatter=:plain,
    top_margin=5*Plots.mm)
end

function pick_your_poison(name)
    ff=pick_file()
    df=CSV.read(ff,DataFrame)

    Index=df."Index"
    f=df."Frequency (Hz)"
    Zre=df."Z' (Ω)"
    Zimg=df."-Z'' (Ω)"
    Z=df."Z (Ω)"
    Phase=df."-Phase (°)"
    Time="Time (s)"

    p_module=plot_format(f,Z)
    savefig(p_module,ff*"_"*name*"Module.html")
    p_N=plot_format(Zre,Zimg)
    savefig(p_N,ff*"_"*name*"Nyquist.html")

end

pick_your_poison("P130_full_EIS")