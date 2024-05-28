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

function pick_your_poison()
    ff=pick_file()
    df=CSV.read(ff,DataFrame)

    Index=df."Index"
    f=df."Frequency (Hz)"
    Zre=df."Z' (Ω)"
    Zimg=df."-Z'' (Ω)"
    Z=df."Z (Ω)"
    Phase=df."-Phase (°)"
    Time="Time (s)"

    p=plot_format(f,Z)
    savefig(p,ff*"_Name.html")
end

pick_your_poison()