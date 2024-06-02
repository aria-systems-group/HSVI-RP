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

begin
    include("models/grid-10/gridavoid_explicit10.jl")
    file_path = "examples/models/grid-10/gridavoid_explicit10.prism"
    const BAD10 = find_label(file_path, r"bad*.")
    const GOAL10 = find_label(file_path, r"goal*.")
    function HSVIRP.labels(pomdp::GridAvoid10, s, a)
        labelvec = []
        if (s-1) ∈ GOAL10
            push!(labelvec, :goal)
        end
        if (s-1) ∈ BAD10
            push!(labelvec, :notbad)
        end
        # push!(labelvec, :notbad)
        return Tuple(labelvec)
    end
end

prop = ltl"!bad U goal"

include("models/grid-10/gridavoid_explicit10.jl")
pomdp = GridAvoid10(slippery=0.3)
sarsop = HSVIRP.SARSOPSolver(precision=1e-3, epsilon = 0.01, max_time = 7200.0, init_steps = 200, step_increment = 10);
solver = HSVIRP.ModelCheckingSolver(solver=sarsop, property=prop, verbose=true)
my_policy = solve(solver, pomdp);