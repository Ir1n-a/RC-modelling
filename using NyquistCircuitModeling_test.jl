using NyquistCircuitModeling
using CSV
using NativeFileDialog
using DataFrames
using Plots
Rp_pe,C_pe,Rs_pe=Estimate_Parameters()
r=optim_param()
Rp_o=r[1:length(r)÷2]
C_o= r[length(r)÷2+1:length(r)]
ff=pick_file()
df=CSV.read(ff,DataFrame)
Zre=df."Z' (Ω)"
Zimg=df."-Z'' (Ω)"
plot(Zre,Zimg)
Zre_ep,Zimg_ep=Theoretical_Z(Rp_pe,C_pe,df)
Zre_o,Zimg_o=Theoretical_Z(Rp_o,C_o,df)
print(Rs_pe)
plot!(Zre_ep,Zimg_ep)
plot!(Zre_o,Zimg_o)