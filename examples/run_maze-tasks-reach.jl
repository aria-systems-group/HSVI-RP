begin
    # --- Standard Setup ---
    using Pkg
    Pkg.activate(joinpath(@__DIR__,".."))
    include("../src/HSVIRP.jl")
    Pkg.activate(@__DIR__)
    
    using .HSVIRP
    using POMDPs
    using POMDPTools
    using Spot

    include("models/generic_prism_pomdp.jl") 
end

begin
    # --- Load model directly from the PRISM file ---
    pomdp = GenericPrismPOMDP("examples/models/maze-tasks-reach/explicit.templ")

    # The LTL property itself
    prop = ltl"notbad U goal"

    function HSVIRP.labels(pomdp::GenericPrismPOMDP, s::Int, a::Int)
        goal_states = get(pomdp.labels, "goal", Set{Int}())

        if s in goal_states
            return (:goal,)
        else
            # For this property, any state that is NOT a goal is "notbad".
            return (:notbad,)
        end
    end
end


sarsop = HSVIRP.SARSOPSolver(precision=1e-3, epsilon = 0.01, max_time = 7200.0, init_steps = 200, step_increment = 10);
solver = HSVIRP.ModelCheckingSolver(solver=sarsop, property=prop, verbose=true);
my_policy = solve(solver, pomdp);