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
    include("models/grid-20/gridavoid_explicit20.jl")
    file_path = "examples/models/grid-20/gridavoid_explicit20.prism"
    const BAD20 = find_label(file_path, r"bad*.")
    const GOAL20 = find_label(file_path, r"goal*.")
    function HSVIRP.labels(pomdp::GridAvoid20, s, a)
        labelvec = []
        if (s-1) ∈ GOAL20
            push!(labelvec, :goal)
        end
        if (s-1) ∈ BAD20
            push!(labelvec, :notbad)
        end
        # push!(labelvec, :notbad)
        return Tuple(labelvec)
    end
end

prop = ltl"!bad U goal";

discounts = [0.95, 0.98, 0.99, 0.999, 0.99999, 1-eps()]

println("------------------------------------")
println("Conducting trials for the following discount factors:")
println("------------------------------------")

for discount in discounts
    println("Discount: $discount")
end

for discount in discounts
    pomdp = GridAvoid20(slippery=0.5);
    cppsarsop = SARSOP.SARSOPSolver(precision=1e-3, timeout=900)
    cpp_solver = HSVIRP.ModelCheckingSolver(solver=cppsarsop, property=prop, verbose=false)
    POMDPs.discount(problem::Union{ProductMDP, ProductPOMDP}) =  discount
    cpp_policy = solve(cpp_solver, pomdp);
end