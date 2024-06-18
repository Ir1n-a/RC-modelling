using Plots 
using CSV
using DataFrames 
using NativeFileDialog
plotlyjs()

function plot_Nyquist(df)
    x=df."Z' (Ω)"
    y=df."-Z'' (Ω)"
    plot(x,y,seriestype=:scatter,dpi=360,
title="Nyquist",xlabel="Zre (Ω)",ylabel="Zimg (Ω)",
right_margin=7*Plots.mm,framestyle=:box,
linewidth=2, formatter=:plain,xlims=[0,
maximum(x)],leg=false,size=(500,500),
markersize=3, top_margin=5*Plots.mm)
end

function plot_Bode(df)
    x=df."Frequency (Hz)"
    y=df."-Phase (°)"
    plot(x,y,dpi=360,xscale=:log10,title="Bode",
    xlabel="Frequency (Hz)",ylabel="Phase Difference (deg)",
    framestyle=:box,right_margin=7*Plots.mm,linewidth=4,
    formatter=:plain, xticks=10.0 .^(-2:5),leg=false,
    top_margin=5*Plots.mm)
end

function picking_RandC(name)
    f2=pick_file()
    df=CSV.read(f2,DataFrame)
    f=df."Frequency (Hz)"
    Zre=df."Z' (Ω)"
    Zimg=df."-Z'' (Ω)"
    Phase=df."-Phase (°)"

    R=(Zre.^2 + Zimg.^2)./Zre
    C=Zimg./((2*π.*f).*(Zre.^2 + Zimg.^2))
    s=plot(f,R,xscale=:log10,framestyle=:box,right_margin=7*Plots.mm,linewidth=4,
    formatter=:plain,leg=false,top_margin=5*Plots.mm,xlabel="Frequency (Hz)",
    ylabel="Resistance (ohm)")
    v=plot(f,C,xscale=:log10,framestyle=:box,right_margin=7*Plots.mm,linewidth=4,
    formatter=:plain,leg=false,top_margin=5*Plots.mm,xlabel="Frequency (Hz)",
    ylabel="Capacitance (F)")
    savefig(s,name*"_R.html")
    savefig(v,name*"_C.html")
end

plot()
picking_RandC("RC ladder")
