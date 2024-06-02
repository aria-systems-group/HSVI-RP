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
    using SARSOP
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

discounts = [0.95, 0.98, 0.99, 0.999, 0.99999, 1-eps()]

println("------------------------------------")
println("Conducting trials for the following discount factors:")
println("------------------------------------")

for discount in discounts
    println("Discount: $discount")
end

for discount in discounts
    pomdp = SuperBlindGridWorld(exit=GWPos(4,1), simple_gw = mdp)
    cppsarsop = SARSOP.SARSOPSolver(precision=1e-3, timeout=900)
    cpp_solver = HSVIRP.ModelCheckingSolver(solver=cppsarsop, property=prop, verbose=false)
    POMDPs.discount(problem::Union{ProductMDP, ProductPOMDP}) =  discount
    cpp_policy = solve(cpp_solver, pomdp);
end