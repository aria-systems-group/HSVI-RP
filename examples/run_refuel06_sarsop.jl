begin
    using Pkg
    Pkg.activate(joinpath(@__DIR__,".."))
    include("../src/HSVIRP.jl")
    Pkg.activate(@__DIR__)
    using .HSVIRP
    using POMDPs
    using POMDPModels
    using POMDPTools
    include("models/refuel06/refuel_explicit06.jl")
    using Spot
    using SARSOP
end

begin
    include("models/refuel06/refuel_explicit06.jl")
    const GOAL06 = Set([184, 199, 203, 207])
    const NOTBAD06 = ([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 89, 93, 114, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 196, 197, 198, 199, 201, 202, 203])
    function HSVIRP.labels(pomdp::RefuelPOMDPExplicit06, s, a)
        labelvec = []
        if (s-1) ∈ GOAL06
            push!(labelvec, :goal)
        end
        if (s-1) ∈ NOTBAD06
            push!(labelvec, :notbad)
        end
        # push!(labelvec, :notbad)
        return Tuple(labelvec)
    end
    prop = ltl"notbad U goal"
    include("models/refuel06/refuel_explicit06.jl")
end

discounts = [0.95, 0.98, 0.99, 0.999, 0.99999, 1-eps()]

println("------------------------------------")
println("Conducting trials for the following discount factors:")
println("------------------------------------")

for discount in discounts
    println("Discount: $discount")
end

for discount in discounts
    pomdp = RefuelPOMDPExplicit06();
    cppsarsop = SARSOP.SARSOPSolver(precision=1e-3, timeout=900)
    cpp_solver = HSVIRP.ModelCheckingSolver(solver=cppsarsop, property=prop, verbose=false)
    POMDPs.discount(problem::Union{ProductMDP, ProductPOMDP}) =  discount
    cpp_policy = solve(cpp_solver, pomdp);
end