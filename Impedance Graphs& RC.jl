using Plots
using CSV
using NativeFileDialog
using DataFrames
using LsqFit
plotlyjs()

function plot_format(x,y)
    plot(x,y,xscale=:log10,
    framestyle=:box,right_margin=7*Plots.mm,linewidth=4,
    formatter=:plain,
    top_margin=5*Plots.mm)
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


    c=curve_fit(curvy, Zre, Zimg, p0_bounds, lower=lb, upper=ub)
    

    savefig(p_R,ff*"_"*name*"Circleqm.html")

    p_module=plot_format(f,Z)
    savefig(p_module,ff*"_"*name*"Module.html")
    p_N=plot_format(Zre,Zimg)
    savefig(p_N,ff*"_"*name*"Nyquist.html")

end

pick_your_poison("1kohm p 1 mF")