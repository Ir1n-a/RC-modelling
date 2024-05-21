function RC_ratio_calculation(C,n)
    R=n/C
    print(R,"")
end

function Reactance(f,C)
    Xc=1/(2*π*f*C)
    print(Xc," ")
end

RC_ratio_calculation(0.47,10)
Reactance(0.1,0.0047)
#= I need to calculate the time constant ratio between two RCs to measure them. I set
the first one as 1, so the second one has to be the value of the ratio, because d'uh. Yeah,
slow day...but I needed to calculate this anyway and this is faster so yeah=#