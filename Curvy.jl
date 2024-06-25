using LsqFit


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

#R=((Zre.+500).^2).+(Zimg.^2)
    #p_R=scatter(f,R,xscale=:log10)
    lb=[0,0,0]
    ub=[maximum(Zre),maximum(Zimg),maximum(Zre)/2]
    p0_bounds=[maximum(Zre)/2,maximum(Zimg)/2,1]


    #c=curve_fit(curvy, Zre, Zimg, p0_bounds, lower=lb, upper=ub)
    

    #savefig(p_R,ff*"_"*name*"Circleqm.html")