begin
    using Pkg
    Pkg.activate(joinpath(@__DIR__,".."))
    include("../src/HSVIRP.jl")
    Pkg.activate(@__DIR__)
    using .HSVIRP #this needs to be test
    using POMDPs
    using POMDPModels
    using POMDPTools
    include("models/grid-4/grid4.jl")
    using Spot
    # using POMDPModelChecking
end

const LABELLED_STATES = Dict(GWPos(2,2) => :bad, GWPos(4,1)=>:goal)

function HSVIRP.labels(mdp::SimpleGridWorld, s, a)
    if haskey(LABELLED_STATES, s)
        return tuple(LABELLED_STATES[s])
    else
        return ()
    end
end

function labels(mdp::SimpleGridWorld, s, a)
    if haskey(LABELLED_STATES, s)
        return tuple(LABELLED_STATES[s])
    else
        return ()
    end
end

prop = ltl"!bad U goal"
include("models/grid-4/grid4.jl")
mdp = SimpleGridWorld(size=(4,4),rewards=Dict(GWPos(4,1)=>10.0), discount=1.0, tprob = 0.9)

HSVIRP.labels(pomdp::SuperBlindGridWorld, s, a) = HSVIRP.labels(pomdp.simple_gw, s, a)

labels(pomdp::SuperBlindGridWorld, s, a) = labels(pomdp.simple_gw, s, a)

pomdp = SuperBlindGridWorld(exit=GWPos(4,1), simple_gw = mdp)
sarsop = HSVIRP.SARSOPSolver(precision=1e-3, epsilon = 0.01, max_time = 7200.0, init_steps = 200, step_increment = 10);
solver = HSVIRP.ModelCheckingSolver(solver=sarsop, property=prop, verbose=true)
my_policy = solve(solver, pomdp);