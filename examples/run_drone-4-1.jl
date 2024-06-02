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
end

begin
    include("models/drone41/drone-4-1.jl")
    file_path = "examples/models/drone41/drone41_explicit.prism"
    const CRASH41 = find_label(file_path, r"notbad*.")
    const DRONEGOAL41 = find_label(file_path, r"goal*.")
    function HSVIRP.labels(pomdp::Drone41, s, a)
        labelvec = []
        if (s-1) ∈ DRONEGOAL41
            push!(labelvec, :goal)
        end
        if (s-1) ∈ CRASH41
            push!(labelvec, :notbad)
        end
        # push!(labelvec, :notbad)
        return Tuple(labelvec)
    end

    prop = ltl"notbad U goal"

    include("models/drone41/drone-4-1.jl")
    pomdp = Drone41()
end

sarsop = HSVIRP.SARSOPSolver(precision=1e-2, epsilon = 0.01, max_time = 7200.0, init_steps = 200, step_increment= 10)
solver = HSVIRP.ModelCheckingSolver(solver=sarsop, property=prop, verbose=true)
my_policy = solve(solver, pomdp);