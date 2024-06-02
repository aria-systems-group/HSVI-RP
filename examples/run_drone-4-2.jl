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

include("models/drone42/drone-4-2.jl")
file_path = "examples/models/drone42/drone42_explicit.prism"
const CRASH = find_label(file_path, r"notbad*.")
const DRONEGOAL42 = Set([1201, 1202, 1203, 1204, 1205, 1206, 1207, 1208, 1209, 1210, 1211, 1212, 1213, 1214, 1215, 1216, 1217, 1218, 1219, 1220, 1221, 1222, 1223, 1224, 1225])
function HSVIRP.labels(pomdp::Drone42, s, a)
    labelvec = []
    if (s-1) ∈ DRONEGOAL42
        push!(labelvec, :goal)
    end
    if (s-1) ∈ CRASH
        push!(labelvec, :notbad)
    end
    # push!(labelvec, :notbad)
    return Tuple(labelvec)
end
prop = ltl"notbad U goal"
pomdp = Drone42()
sarsop = HSVIRP.SARSOPSolver(precision=1e-3, epsilon = 0.01, max_time = 7200.0, init_steps = 200, step_increment= 10)
solver = HSVIRP.ModelCheckingSolver(solver=sarsop, property=prop, verbose=true)
my_policy = solve(solver, pomdp);