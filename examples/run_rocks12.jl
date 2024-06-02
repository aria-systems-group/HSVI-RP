begin
    using Pkg
    Pkg.activate(joinpath(@__DIR__,".."))
    include("../src/HSVIRP.jl")
    Pkg.activate(@__DIR__)
    using .HSVIRP #this needs to be test
    using POMDPs
    using POMDPModels
    using POMDPTools
    using Spot
    using RockSample
end

pomdp = RockSamplePOMDP{2}(map_size=(12,12), 
                            rocks_positions=[(12/2,12/2), (1,12/2)])

function HSVIRP.labels(pomdp::RockSamplePOMDP, s::RSState, a::Int64)
    if a == RockSample.BASIC_ACTIONS_DICT[:sample] && in(s.pos, pomdp.rocks_positions) # sample 
        rock_ind = findfirst(isequal(s.pos), pomdp.rocks_positions) # slow ?
        if s.rocks[rock_ind]
            return (:good_rock,)
        else
        end
    end
    if isterminal(pomdp, s)
        return (:exit,)
    end
    return ()
end

prop = ltl"F good_rock & F exit"
sarsop = HSVIRP.SARSOPSolver(precision=1e-2, epsilon = 0.01, max_time = 7200.0, init_steps = 200, step_increment= 10)
solver = HSVIRP.ModelCheckingSolver(solver=sarsop, property=prop, verbose=true)
my_policy = solve(solver, pomdp);