using Plots
using CSV
using NativeFileDialog
using DataFrames
using StatsBase
plotlyjs()

function plot_format(x,y,sc,xl,yl)
    max=maximum(x)
    min=minimum(x)
    plot(x,y,xscale=sc,
    framestyle=:box,right_margin=7*Plots.mm,linewidth=4,
    formatter=:plain,
    top_margin=5*Plots.mm,xlabel=xl,ylabel=yl,legend=false,
    #=ylims=(0,maximum(y)+maximum(y)/10)=#)
end

function Difference_plot(Xd,Yd,sc_d,xl_d,yl_d)
    D=diff(Yd)
    scatter(midpoints(Xd),D,xscale=sc_d,xlabel=xl_d,ylabel=yl_d,
    framestyle=:box,right_margin=7*Plots.mm,linewidth=4,
    legend=false,top_margin=5*Plots.mm)
end

function pick_your_poison()
    ff=pick_file()
    df=CSV.read(ff,DataFrame)
    df = df[df."-Z'' (Ω)".>=0, :] 

    Index=df."Index"
    f=df."Frequency (Hz)"
    Zre=df."Z' (Ω)"
    Zimg=df."-Z'' (Ω)"
    Z=df."Z (Ω)"
    Phase=df."-Phase (°)"
    Time="Time (s)"
    
    p_module=plot_format(f,Z,:log10,"Frequency (Hz)","Z (Ω)")
    savefig(p_module,ff*"_Module.html")

    p_N=plot_format(Zre,Zimg,:identity,"Zre (Ω)","Zimg (Ω)")
    savefig(p_N,ff*"_Nyquist.html")

    p_B=plot_format(f,Phase,:log10,"Frequency (Hz)","Phase Difference (deg)")
    savefig(p_B,ff*"_Bode.html")

    p_img=plot_format(f,Zimg,:log10,"Frequency (Hz)","Zimg (Ω)")
    savefig(p_img,ff*"_Zimg(f).html")

    p_re=plot_format(f,Zre,:log10,"Frequency (Hz)","Zre (Ω)")
    savefig(p_re,ff*"_Zre(f).html")

    p_ZimgD=Difference_plot(f,Zimg,:log10,"Frequency (Hz)","Diff(Zimg) (Ω)")
    savefig(p_ZimgD,ff*"_ZimgD.html")
    
    p_ZimgDZre=plot_format(f,Zimg.-Zre,:log10,"Frequency (Hz)","Zimg-Zre (Ω)")
    savefig(p_ZimgDZre,ff*"_ZimgDZre.html")

    
    #=D=diff(Zimg)
    J=diff(Zre)
    print(D," ")
    Dp=plot(midpoints(f),D,xscale=:log10)
    savefig(Dp,ff*"_Diff_Module.html")

    Der=plot(midpoints(f),D./J,xscale=:log10)
    savefig(Der,ff*"_Der.html")

    Dp_N=Difference_plot(f,Zimg,:log10,"Zre (Ω)","Zimg (Ω)")
    savefig(Dp_N,ff*"_Zimg_D.html")=#

end

pick_your_poison() 

x=[1,2,3,4,5]
y=diff(x)
print(y," ")

smooth?