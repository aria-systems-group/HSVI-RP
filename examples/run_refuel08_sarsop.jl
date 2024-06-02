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
    using SARSOP
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

discounts = [0.95, 0.98, 0.99, 0.999, 0.99999, 1-eps()]

println("------------------------------------")
println("Conducting trials for the following discount factors:")
println("------------------------------------")

for discount in discounts
    println("Discount: $discount")
end

for discount in discounts
    pomdp = RefuelPOMDPExplicit08();
    cppsarsop = SARSOP.SARSOPSolver(precision=1e-3, timeout=900)
    cpp_solver = HSVIRP.ModelCheckingSolver(solver=cppsarsop, property=prop, verbose=false)
    POMDPs.discount(problem::Union{ProductMDP, ProductPOMDP}) =  discount
    cpp_policy = solve(cpp_solver, pomdp);
end