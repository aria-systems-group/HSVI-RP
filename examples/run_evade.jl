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
    pomdp = GenericPrismPOMDP("examples/models/new/evade/explicit.templ")

    # The LTL property itself
    prop = ltl"notbad U goal"

    function HSVIRP.labels(pomdp::GenericPrismPOMDP, s::Int, a::Int)
        required_props = Set(["notbad", "goal"])
        
        labelvec = Symbol[]
        for (label_name, state_set) in pomdp.labels
            if label_name in required_props && s in state_set
                push!(labelvec, Symbol(label_name))
            end
        end
        return Tuple(labelvec)
    end
end


sarsop = HSVIRP.SARSOPSolver(precision=1e-3, epsilon = 0.01, max_time = 7200.0, init_steps = 200, step_increment = 10);
solver = HSVIRP.ModelCheckingSolver(solver=sarsop, property=prop, verbose=true);
my_policy = solve(solver, pomdp);