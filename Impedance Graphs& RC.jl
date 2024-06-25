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

function find_maxima_Zimg(df)
    df = df[df."-Z'' (Ω)".>=0, :]
    Index=df."Index"
    Zimg=df."-Z'' (Ω)"
    M=[]
    I=[]
    print(maximum(Index))
    for i in 2:(length(Index)-1)
        println(i," ",Zimg[i])
        if(Zimg[i-1]<Zimg[i]>Zimg[i+1])
            push!(M,Zimg[i])
            push!(I,Index[i])
        end
    end
    if (length(M)==1)
        println(M,"\n",I,"\n",
    "There is most likely $(length(M)) parallel RC circuit for this data file")
    else
    println(M,"\n",I,"\n",
    "There are most likely $(length(M)) parallel RC circuits for this data file")
    end
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

    #p_ZimgD=Difference_plot(f,Zimg,:log10,"Frequency (Hz)","Diff(Zimg) (Ω)")
   # savefig(p_ZimgD,ff*"_ZimgD.html")
    
    p_ZimgDZre=plot_format(f,Zimg.-Zre,:log10,"Frequency (Hz)","Zimg-Zre (Ω)")
    savefig(p_ZimgDZre,ff*"_ZimgDZre.html")

    find_maxima_Zimg(df)
    
end

pick_your_poison() 

x=[1,2,3,4,5]
y=diff(x)
print(y," ")

df=CSV.read("C:\\Users\\Batcomputr\\Desktop\\Modelling Data\\5 06 2024\\RC serie 47",DataFrame)
Zimg=df."-Z'' (Ω)"
