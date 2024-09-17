using Plots
using CSV
using NativeFileDialog
using DataFrames

function RC_series(df,R,C)
    fr=df."Frequency (Hz)"
    x=zeros(length(fr))
    for i in 1:length(fr)
        x[i]=R
    end
    y=1 ./(2*π .*fr .*C)
    print(x)
    plot(x,y)
end

function pick_freq()
    fq=pick_file()
    df=CSV.read(fq,DataFrame)
    f1=df."Frequency (Hz)"
    Zre1=df."Z' (Ω)"
    Zimg1=df."-Z'' (Ω)"
    Z=df."Z (Ω)"
    Yi=1 ./ Zimg1
    Y=1 ./ Z
    plot(f1,Yi,legend=false,xscale=:log10)
    #RC_series(df,100,0.0001)
end

pick_freq()

plot()