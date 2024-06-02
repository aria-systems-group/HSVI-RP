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
    include("models/crypt4/crypt4.jl")
    file_path = "examples/models/crypt4/crypt4.prism"
    const CRYPT4GOAL = find_label(file_path, r"goal*.")
    function HSVIRP.labels(pomdp::Crypt4, s, a)
        labelvec = []
        if (s-1) ∈ CRYPT4GOAL
            push!(labelvec, :goal)
        end
        # push!(labelvec, :bad)
        return Tuple(labelvec)
    end

    prop = ltl"!bad U goal"
    include("models/crypt4/crypt4.jl")
    pomdp = Crypt4()
end

sarsop = HSVIRP.SARSOPSolver(precision=1e-3, epsilon = 0.01, max_time = 7200.0, init_steps = 200, step_increment= 10)
solver = HSVIRP.ModelCheckingSolver(solver=sarsop, property=prop, verbose=true)
my_policy = solve(solver, pomdp);