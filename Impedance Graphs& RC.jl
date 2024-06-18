using Plots
using CSV
using NativeFileDialog
using DataFrames
using LsqFit
using StatsBase
plotlyjs()

function plot_format(x,y,sc,xl,yl)
    max=maximum(x)
    min=minimum(x)
    plot(x,y,xscale=sc,
    framestyle=:box,right_margin=7*Plots.mm,linewidth=4,
    formatter=:plain,
    top_margin=5*Plots.mm,xlabel=xl,ylabel=yl,legend=false,
    ylims=(0,maximum(y)+maximum(y)/10))
end

function curvy(x,p)
    r=p[1] 
    x0=p[2] 
    y0=p[3]
    [(x[1]-x0)^2 + (x[2]-y0)^2 - r^2]
end
ff=pick_file()
df=CSV.read(ff,DataFrame)
Zre=df."Z' (Ω)"
Zimg=df."-Z'' (Ω)"
lb=[0,0,0]
ub=[maximum(Zre),maximum(Zimg),maximum(Zre)/2]
p0_bounds=[maximum(Zre)/2,maximum(Zimg)/2,1]

(x.-Zre).^2 + (y.-Zimg).^2 -r^2 

c=curve_fit(curvy, Zre, Zimg, p0_bounds, lower=lb, upper=ub) 

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
    #R=((Zre.+500).^2).+(Zimg.^2)
    #p_R=scatter(f,R,xscale=:log10)
    lb=[0,0,0]
    ub=[maximum(Zre),maximum(Zimg),maximum(Zre)/2]
    p0_bounds=[maximum(Zre)/2,maximum(Zimg)/2,1]


    #c=curve_fit(curvy, Zre, Zimg, p0_bounds, lower=lb, upper=ub)
    

    #savefig(p_R,ff*"_"*name*"Circleqm.html")

    p_module=plot_format(f,Z,:log10,"Frequency (Hz)","Z (Ω)")
   
    savefig(p_module,ff*"_"*name*" Module.html")

    p_N=plot_format(Zre,Zimg,:identity,"Zre (Ω)","Zimg (Ω)")
    savefig(p_N,ff*"_"*name*" Nyquist.html")

    p_B=plot_format(f,Phase,:log10,"Frequency (Hz)","Phase Difference (deg)")
    savefig(p_B,ff*"_"*name*" Bode.html")
    
    D=diff(Z)
    Dp=plot(midpoints(f),D,xscale=:log10)
    savefig(Dp,ff*"_Diff_Module.html")

end

pick_your_poison("220 ohm p 1 mF")  