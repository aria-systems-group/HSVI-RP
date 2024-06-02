begin
    using Pkg
    Pkg.activate(joinpath(@__DIR__,".."))
    include("../src/HSVIRP.jl")
    Pkg.activate(@__DIR__)
    using .HSVIRP
    using POMDPs
    using POMDPModels
    using POMDPTools
    using Spot
end
using Spot

begin
    include("models/refuel20/refuel_explicit20.jl")
    file_path = "examples/models/refuel20/refuel20_explicit.prism"
    const NOTBAD20 = find_label(file_path, r"notbad*.")
    const GOAL20 = Set([6524, 6608, 6649, 6709, 6734, 6774, 6787, 6811, 6816, 6828, 6829, 6833])
        
    function HSVIRP.labels(pomdp::RefuelPOMDPExplicit20, s, a)
        labelvec = []
        if (s-1) ∈ GOAL20
            push!(labelvec, :goal)
        end
        if (s-1) ∈ NOTBAD20
            push!(labelvec, :notbad)
        end
        # push!(labelvec, :notbad)
        return Tuple(labelvec)
    end

    prop = ltl"notbad U goal"

    include("models/refuel20/refuel_explicit20.jl")
    pomdp = RefuelPOMDPExplicit20()
end

sarsop = HSVIRP.SARSOPSolver(precision=1e-3, epsilon = 0.01, max_time = 7200.0, init_steps = 200, step_increment = 10)
solver = HSVIRP.ModelCheckingSolver(solver=sarsop, property=prop, verbose=true)
my_policy = solve(solver, pomdp);