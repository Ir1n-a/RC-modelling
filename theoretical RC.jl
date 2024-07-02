using Plots
using CSV
using DataFrames
using NativeFileDialog
using Optimization
using ForwardDiff
plotlyjs()

function RC_formation(df,R,C)
    f=df."Frequency (Hz)"

    yt=(2*π.*f.*(R^2)*C)./(1 .+4*(π^2).*(f.^2).*(R*C)^2)
    xt=R./(1 .+4*(π^2).*(f.^2).*(R*C)^2)
    
    #pt=plot(xt,yt)
    return xt, yt
    
end

function RC_plot_t(df,R,C)
    f=df."Frequency (Hz)"

    yt=(2*π.*f.*(R^2)*C)./(1 .+4*(π^2).*(f.^2).*(R*C)^2)
    xt=R./(1 .+4*(π^2).*(f.^2).*(R*C)^2)
    
    plot(xt,yt)
end

function Nyquist_plot(df)
    x=df."Z' (Ω)"
    y=df."-Z'' (Ω)"
    plot!(x,y,seriestype=:scatter,dpi=360
    ,xlabel="Zre (Ω)",ylabel="Zimg (Ω)",
right_margin=7*Plots.mm,framestyle=:box,
linewidth=2, formatter=:plain,xlims=[0,
maximum(x)],leg=false,size=(500,500),
markersize=3, top_margin=5*Plots.mm)
end

    
function plot_Nyquist(df)
    x=df."Z' (Ω)"
    y=df."-Z'' (Ω)"
    #=pe=plot!(x,y,seriestype=:scatter,dpi=360
    ,xlabel="Zre (Ω)",ylabel="Zimg (Ω)",
right_margin=7*Plots.mm,framestyle=:box,
linewidth=2, formatter=:plain,xlims=[0,
maximum(x)],leg=false,size=(500,500),
markersize=3, top_margin=5*Plots.mm)=#
    return x, y
end

function difference_et(Rc1,df)
    R,C=Rc1
    xt,yt=RC_formation(df,R,C)
    xe,ye=plot_Nyquist(df)
    x=abs2.(xe-xt)
    y=abs2.(ye-yt)
    z=sum(sqrt.(x+y))
    return z
end


function pick_RC()
    fi=pick_file()
    df=CSV.read(fi,DataFrame)
    #mdf = df[df."-Z'' (Ω)".>=0, :]

    #x,y,Rc=RC_formation(mdf,1000,0.001)
    #savefig(Rc,fi*"_RCtheoretical.html")

    #x,y,Nyq=plot_Nyquist(mdf)
    #savefig(Nyq,fi*"_RCexperimental.html")

    #difference_et(mdf,1000,0.001)
    p0=[1000,0.001]
    optimization_function=OptimizationFunction(difference_et,AutoForwardDiff())
    probleeem=OptimizationProblem(optimization_function,p0,df)
    rezz=solve(probleeem,Optimization.LBFGS(),maxiters=100)

end

function pick_RC_graph()
    fi=pick_file()
    df=CSV.read(fi,DataFrame)
    mdf = df[df."-Z'' (Ω)".>=0, :]

    rezz=pick_RC()
    Rc=RC_plot_t(mdf,rezz[1],rezz[2])
    display(Rc)
    savefig(Rc,fi*"_RCtheoretical.html")

    Nyq=Nyquist_plot(mdf)
    savefig(Nyq,fi*"_RCexperimental.html")
end
pick_RC()
pick_RC_graph()
plot()