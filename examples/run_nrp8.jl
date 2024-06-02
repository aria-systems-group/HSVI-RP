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
    include("models/nrp8/nrp8.jl")
    file_path = "examples/models/nrp8/nrp8.prism"
    const NRP8GOAL = find_label(file_path, r"unfair*.")
    function HSVIRP.labels(pomdp::nrp8, s, a)
        labelvec = []
        if (s-1) ∈ NRP8GOAL
            push!(labelvec, :goal)
        end
        # push!(labelvec, :bad)
        return Tuple(labelvec)
    end
    prop = ltl"!bad U goal"
    pomdp = nrp8();
end

sarsop = HSVIRP.SARSOPSolver(precision=1e-3, epsilon = 0.01, max_time = 7200.0, init_steps = 200, step_increment= 10);
solver = HSVIRP.ModelCheckingSolver(solver=sarsop, property=prop, verbose=true);
my_policy = solve(solver, pomdp);