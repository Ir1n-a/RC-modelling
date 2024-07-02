using ModelingToolkit, OrdinaryDiffEq, Plots
using ModelingToolkitStandardLibrary.Electrical
using ModelingToolkitStandardLibrary.Blocks: Constant,Sine
using ModelingToolkit: t_nounits as t

R = 2000.0
C = 1.0
V = 1.0
@named resistor = Resistor(R = R)
@named capacitor = Capacitor(C = C, v = 0.0)
@named source = Voltage()
@named constant = Constant(k = V)
@named ground = Ground()

rc_eqs = [connect(constant.output, source.V)
          connect(source.p, resistor.p)
          connect(resistor.n, capacitor.p)
          connect(capacitor.n, source.n, ground.g)]

@named rc_model = ODESystem(rc_eqs, t,
    systems = [resistor, capacitor, constant, source, ground])
sys = structural_simplify(rc_model)
prob = ODEProblem(sys, Pair[], (0, 50000.0))
sol = solve(prob, Tsit5())
plot(sol, idxs = [capacitor.v, resistor.i],
    title = "RC Circuit Demonstration",
    labels = ["Capacitor Voltage" "Resistor Current"],legend=false)
savefig("plot.png");


function RC_4(Rp,C,Rs,f)

    @named resistorS = Resistor(R=Rs)
    @named resistor1 = Resistor(R=Rp[1])
    @named resistor2 = Resistor(R=Rp[2])
    @named resistor3 = Resistor(R=Rp[3])
    @named resistor4 = Resistor(R=Rp[4])

    @named capacitor1 = Capacitor(C=C[1])
    @named capacitor2 = Capacitor(C=C[2])
    @named capacitor3 = Capacitor(C=C[3])
    @named capacitor4 = Capacitor(C=C[4])

    @named ground = Ground()
    @named source = Voltage()
    @named input_signal = Sine(frequency=f,amplitude=0.01)

    eqs = [connect(input_signal.output,source.V)
        connect(source.p,resistorS.p)
        connect(resistorS.n,resistor1.p,capacitor1.p)
        connect(resistor1.n,capacitor1.n,resistor2.p,capacitor2.p)
        connect(resistor2.n,capacitor2.n,resistor3.p,capacitor3.p)
        connect(resistor3.n,capacitor3.n,resistor4.p,capacitor4.p)
        connect(resistor4.n,capacitor4.n,source.n,ground.g)]
    

    @named rc_model = ODESystem(eqs, t,
    systems = [resistorS,resistor1,resistor2,
    resistor3,resistor4, capacitor1, capacitor2,
    capacitor3,capacitor4, input_signal, source, ground])
end

ff=pick_file()
df=CSV.read(ff,DataFrame)
M,I,m,ix=find_maxima_Zimg(df)
ix,Rs,Rp,C=Parameter_calculation(df,M,I,m,ix)
sys = RC_4(Rp,C,Rs,5)
circuit_model = structural_simplify(sys)

prob = ODEProblem(circuit_model, Pair[], (0, 50.0))
sol = solve(prob, OrdinaryDiffEq.DefaultODEAlgorithm())
plot(sol, idxs = [sys.capacitor4.v/sys.capacitor4.i],
    title = "RC Circuit",
    labels = ["Series Resistor Current" "Source Voltage"],legend=false,ls = [:line :dash])
#sol[sys.capacitor1.v,sys.resistorS.i]

