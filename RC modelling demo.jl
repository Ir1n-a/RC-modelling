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

function picking_RC()
    f2=pick_file()
    df=CSV.read(f2,DataFrame)
    f=df."Frequency (Hz)"
    Zre=df."Z' (Ω)"
    Zimg=df."-Z'' (Ω)"
    Phase=df."-Phase (°)"
    
    Rc=((1/2π).*1 ./f) .*(Zimg./Zre)
    👍=plot(f,Rc,xscale=:log10)
    savefig(👍,f2*"_RCM.html")
    N=plot_Nyquist(df)
    savefig(N,f2*"_Nyquist.html")
    
    B=plot_Bode(df)
    savefig(B,f2*"_Bode.html")
end
    
picking_RC()

