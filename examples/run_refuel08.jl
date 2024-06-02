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
    include("models/refuel08/refuel_explicit08.jl")
    file_path = "examples/models/refuel08/refuel08_explicit.prism"
    const NOTBAD = find_label(file_path, r"notbad*.")
    const GOAL = Set([452, 464, 465, 469])
        
    function HSVIRP.labels(pomdp::RefuelPOMDPExplicit08, s, a)
        labelvec = []
        if (s-1) ∈ GOAL
            push!(labelvec, :goal)
        end
        if (s-1) ∈ NOTBAD
            push!(labelvec, :notbad)
        end
        # push!(labelvec, :notbad)
        return Tuple(labelvec)
    end
    prop = ltl"notbad U goal"
    include("models/refuel08/refuel_explicit08.jl")
    pomdp = RefuelPOMDPExplicit08()
end

sarsop = HSVIRP.SARSOPSolver(precision=1e-3, epsilon = 0.0, max_time = 7200.0, init_steps = 200, step_increment=10)
solver = HSVIRP.ModelCheckingSolver(solver=sarsop, property=prop, verbose=true)
my_policy = solve(solver, pomdp);