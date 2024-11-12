using Plots
using CSV
using NativeFileDialog
using DataFrames
using StatsBase
using DataInterpolations
using Optimization
using PrettyTables
plotlyjs()
#gr()
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

function print_vector(v)
    if length(v) ==1
        (string(v))
    else
    join(string.(v),"; ")
    end
end

function find_maxima_Zimg(df)
    df = df[df."-Z'' (Ω)".>=0, :]
    Index=df."Index"
    Zimg=df."-Z'' (Ω)"
    Frequency=df."Frequency (Hz)"
    M=[]
    I=[]
    m=[]
    ix=[]
    f=[Frequency[1]]
    #print(maximum(Index))
    for i in 2:(length(Index)-1)
        #println(i," ",Zimg[i])
        if(Zimg[i-1]<Zimg[i]>Zimg[i+1])
            push!(M,Zimg[i])
            push!(I,i)
        else
            if (Zimg[i-1]>Zimg[i]<Zimg[i+1])
                push!(m,Zimg[i])
                push!(ix,i)
                push!(f,Frequency[i])
            end
        end
    end
    push!(f,Frequency[end])

    if (length(M)==1)
    println("Maxima = ",print_vector(M),"\n","Index = ",print_vector(I),"\n")
    printstyled("There is most likely $(length(M)) parallel RC circuit for this data file\n"
    ,bold=true)
    else
    println("Maxima = ",print_vector(M),"\n","Index = ",print_vector(I),"\n")
    printstyled("There are most likely $(length(M)) parallel RC circuits for this data file\n"
    ,bold=true)
    end

    if(length(m)==length(M))
        printstyled("Series RC's might be present in the circuit\n",bold=true)
        println("\n","minima = ",print_vector(m),"\n","indexm = ",print_vector(ix))
    else printstyled("Probably no series RC's are present in the circuit\n",bold=true)
        println("\n","minima = ",print_vector(m),"\n","indexm = ",print_vector(ix))
    end

    #print(m,ix)
    print(f)
    return M,I,m,ix
end

function Parameter_calculation(df,M,I,ix)
    f=df."Frequency (Hz)"
    Zre=df."Z' (Ω)"
    df = df[df."-Z'' (Ω)".>=0, :]
    R=[]
    C=[]
    Rp=[]
    Rs=Zre[1]
    push!(Rp,((Zre[I[1]])^2 + (M[1])^2)/Zre[I[1]]-Rs)
    #push!(Rp,R[1]-Rs)
    for i in 1:length(I)
        push!(R,((Zre[I[i]]).^2 .+ (M[i]).^2)./Zre[I[i]])
        push!(C,M[i]./((2*π*f[I[i]]).*(Zre[I[i]].^2 .+ M[i].^2)))
    end

    for i in 2:length(I)
        push!(Rp,R[i].-R[i-1])
    end
    println("\n","R=",R,"\n","C=",C,"\n","Rs=",Rs,"\n","Rp=",Rp)
end

function Parameter_calculation(df,M,I)
    f=df."Frequency (Hz)"
    Zre=df."Z' (Ω)"
    df = df[df."-Z'' (Ω)".>=0, :]
    R=[]
    C=[]
    Rp=[]
    Rs=Zre[1]
    push!(Rp,((Zre[I[1]])^2 + (M[1])^2)/Zre[I[1]]-Rs)
    for i in 1:length(I)
        push!(R,Zre[I[i]].*2)
    end

    for i in 2:length(I)
        push!(Rp,R[i].-R[i-1])
    end

    for i in 1:length(I)
        push!(C,1 ./(2*π*f[I[i]].*Rp[i]))
    end
    println("\n","R = ",print_vector(R),"\n","C = ",print_vector(C),"\n","Rs = ",
    print_vector(Rs),"\n","Rp = ",print_vector(Rp))
end

function Parameter_calculation(df,M,I,m,ix)
    f=df."Frequency (Hz)"
    Zre=df."Z' (Ω)"
    Index=df."Index"
    df = df[df."-Z'' (Ω)".>=0, :]
    R=[]
    C=[]
    Rp=[]
    Rs=Zre[1]
    
    for i in 1:length(ix)
        push!(R,Zre[ix[i]])
    end

    if(length(m)<length(M)) 
        push!(R,Zre[length(Index)])
    end

    push!(Rp,R[1]-Rs)

    if(length(I)>1)
        for i in 2:length(I)
        push!(Rp,R[i].-R[i-1])
        end
    end

    for i in 1:length(I)
        push!(C,1 ./(2*π*f[I[i]].*Rp[i]))
    end

    println("\n","R = ",print_vector(R),"\n","C = ",print_vector(C),"\n",
    "Rs = ",print_vector(Rs),"\n","Rp = ",print_vector(Rp))

    return ix,Rs,Rp,C
end

function RC_series(df,ix,Zre)
    df = df[Zre .>= Zre[ix[length(ix)]], :]
    f=df."Frequency (Hz)"
    Zre=df."Z' (Ω)"
    Zimg=df."-Z'' (Ω)"
    Z=df."Z (Ω)"
    C=1 ./ (2*π*f .*Zimg)
    d=[]
    p_N_s = plot(midpoints(Zre),diff(C),legend=false)
    #RC_s=(1 ./2*π*f).*(Zre ./ Zimg)
    #plot(midpoints(f),diff(RC_s),legend=false)
    #plot(Zre,Zimg,xscale=:log10,legend=false)
    #s=LinearInterpolation(Z,f,extrapolate=true)
    #plot(f,x->s(x))
    #=for i in 1:length(Zre)
        push!(d,DataInterpolations.derivative(s,f[i],1))
    end
    plot(Z,d,legend=false)=#
end


function Estimate_Parameters()
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

    #p_re=plot_format(f,Zre,:log10,"Frequency (Hz)","Zre (Ω)")
    #savefig(p_re,ff*"_Zre(f).html")

    #p_ZimgD=Difference_plot(f,Zimg,:log10,"Frequency (Hz)","Diff(Zimg) (Ω)")
   # savefig(p_ZimgD,ff*"_ZimgD.html")
    
    p_ZimgDZre=plot_format(f,Zimg.-Zre,:log10,"Frequency (Hz)","Zimg-Zre (Ω)")
    savefig(p_ZimgDZre,ff*"_ZimgDZre.html")

    M,I,m,ix=find_maxima_Zimg(df)
    ix,_=Parameter_calculation(df,M,I,m,ix)

    RC_series(df,ix,Zre)
    
end

Estimate_Parameters() 

function Theoretical_Z(Rp,C,df)
    f=df."Frequency (Hz)"
    Zre_t= Rs .+Rp[1] ./(1 .+ (2*π*f*Rp[1]*C[1]).^2) .+ Rp[2] ./(1 .+ (2*π*f*Rp[2]*C[2]).^2) .+
    Rp[3] ./(1 .+ (2*π*f*Rp[3]*C[3]).^2) .+ Rp[4] ./(1 .+ (2*π*f*Rp[4]*C[4]).^2)

    Zimg_t= (2*π*f.*(Rp[1].^2)*C[1]) ./ (1 .+ (2*π*f*Rp[1]*C[1]).^2) .+ 
    (2*π*f.*(Rp[2].^2)*C[2]) ./ (1 .+ (2*π*f*Rp[2]*C[2]).^2) .+
    (2*π*f.*(Rp[3].^2)*C[3]) ./ (1 .+ (2*π*f*Rp[3]*C[3]).^2) .+ 
    (2*π*f.*(Rp[4].^2)*C[4]) ./ (1 .+ (2*π*f*Rp[4]*C[4]).^2)

    return Zre_t,Zimg_t
end

function difference_et(x, df)
    Rp=x[1:length(x)÷2]
    C= x[length(x)÷2+1:length(x)]
    Zre_t,Zimg_t=Theoretical_Z(Rp,C,df)
    Zre=df."Z' (Ω)"
    Zimg=df."-Z'' (Ω)"
    sum(abs2.(Zre.-Zre_t))/length(Zre) + sum(abs2.(Zimg.-Zimg_t))/length(Zimg)
end
ff=pick_file()
df=CSV.read(ff,DataFrame)
M,I,m,ix=find_maxima_Zimg(df)
ix,Rs,Rp,C=Parameter_calculation(df,M,I,m,ix)
p0=Float64.(vcat(Rp,C))
optimization_function=OptimizationFunction(difference_et,AutoForwardDiff())
probleeem=OptimizationProblem(optimization_function,p0,df)
rezz=solve(probleeem,Optimization.LBFGS(),maxiters=100)
print(rezz-p0)

Zre_t,Zimg_t=Theoretical_Z(Rp,C,df)
Zre_new,Zimg_new=Theoretical_Z(rezz[1:length(rezz)÷2],rezz[length(rezz)÷2+1:end],df)
Zre=df."Z' (Ω)"
Zimg=df."-Z'' (Ω)"
scatter(Zre,Zimg,framestyle=:box,right_margin=7*Plots.mm,linewidth=4,
formatter=:plain,top_margin=5*Plots.mm,label="Experimental",legend=:bottom,dpi=360,
xlabel="Zre (Ω)",ylabel="Zimg (Ω)",color=:red)
scatter!(Zre_t,Zimg_t,label="Initial Values",color=:maroon)
scatter!(Zre_new,Zimg_new,label="Optimization Result",color=:turquoise)
savefig("Result")
print(Rp,C)
print(rezz)

ff=pick_file()
df=CSV.read(ff,DataFrame)
xe=df."Z' (Ω)"
ye=df."-Z'' (Ω)"
println(ye😂)
phy=atan.(y,x)
fr=df."Frequency (Hz)"
plot(fr,phy,xscale=:log10)
plot(fr,y./x,xscale=:log10)
#f=collect(0.01:5:10000)
print(f)
typeof(f)
R=1000
C=0.001
Rs=14
x=R ./(1 .+ (2*π*f*R*C).^2) .+ Rs
y=(2*π*f.*(R.^2)*C) ./ (1 .+ (2*π*f*R*C).^2)
plot(x,y,xlabel="Zre",ylabel="Zimg",framestyle=:box,legend=false,dpi=360)
savefig("semicircle")
ω

R=1000
C=0.0001
f=collect(0.01:100:20000)
x=R ./(1 .+ (2*π*f*R*C).^2)
y=(2*π*f.*(R.^2)*C) ./ (1 .+ (2*π*f*R*C).^2)
R1=[]
for i in 1:200
    push!(R1,1000)
end
x1=R1
y1=1 ./(f .* C)
plot(x1,y1,xlimits=[900,1005])
plot()
ϕ
j=0
k=0
for i in 2:50
    if ye[i]-ye[i-1]>0
        println("some found")
        k=k+1
    else 
        println("none found")
        j=j+1
    end
end
print(j,"  ",k)

plot(x,y,legend=false,dpi=360,xlabel="Zre (Ω)",ylabel="Zimg (Ω)",framestyle=:box,ylims=[0,600])
savefig("Nyquistth")
phi=atan.(y,x)
#y_b=atan(phi)
plot(f,phi,xscale=:log10)
savefig("Phase")
z=sqrt.(x.^2 + y.^2)
plot(f,z,xscale=:log10,dpi=360,framestyle=:box,xlabel="Frequency (Hz)", ylabel="Z (Ω)",legend=false)
savefig("Module")
plot(f,y./x)
savefig("ok")
phi=rad2deg.(atan.(2*π*f.*R*C))
plot(f,phi,xscale=:log10,xticks=[0,10,100,1000,10000,100000,1000000])
savefig("what")
plot(z,x)
plot(z,y)

plot(legend=false,dpi=360,xlabel="Potential (V)",ylabel="Current (mA)",framestyle=:box,xlimits=(-1,1),ylimits=(-0.6,0.6),yticks=[-0.6,-0.4,-0.2,0,0.2,0.4,0.6])
savefig("CVplotempty")
V=collect(-1:0.005:1)
t=collect(1:0.297:120)
C=0.001
I=[]
for i in 1:400
    I[i]=C*((V[i+1]-V[i])./(t[i+1]-t[i]))
end
print(I)
plot(V,I)
plot!(V,-I)
plot(legend=false,dpi=360,xlabel="Time (s)",ylabel="Potential (V)",framestyle=:box,xlimits=(0,40),ylimits=(0,1.2),yticks=[0,0.2,0.4,0.6,0.8,1,1.2])
savefig("CDplotempty")

t=collect(0:0.05:1000)
V=0.01*sin.(2*π*0.002 .* t)
plot(t,V,legend=false,framestyle=:box,ylabel="Potential (V)", xlabel="Time (s)",linewidth=2,dpi=360)
savefig("sinus")
V1=0.01*sin.(2*π*0.002 .* t .+ 1.5708)
plot!(t,V1,linewidth=2,dpi=360)
savefig("phasediff")
