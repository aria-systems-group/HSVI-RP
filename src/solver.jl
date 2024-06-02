Base.@kwdef struct SARSOPSolver{LOW,UP} <: Solver
    epsilon::Float64    = 0.5
    precision::Float64  = 1e-3
    kappa::Float64      = 0.5
    delta::Float64      = 1e-1
    max_time::Float64   = 1.0
    max_steps::Int      = typemax(Int)
    init_steps::Int     = 20
    step_increment::Int = 20
    verbose::Bool       = true
    init_lower::LOW     = BlindLowerBound(bel_res = 1e-15)
    init_upper::UP      = FastInformedBound(bel_res= eps())
    prunethresh::Float64= 0.10
end

function POMDPTools.solve_info(solver::SARSOPSolver, pomdp::POMDP)
    
    filename = "results/ours/" * string(typeof(pomdp.problem)) * ".txt"
    io = open(filename, "a");
    
    tree = SARSOPTree(solver, pomdp)
    steps = solver.init_steps
    t0 = time()
    iter = 0
    effective_discount = 0.999999
    first = true
    numalphas = size(tree.Γ, 1)
    value_iter_max = 10000
    steps += solver.step_increment
    while steps < solver.max_steps && time() - t0 < solver.max_time && root_diff(tree) > solver.precision
        counter = 0
        iter += 1
        latest_rootdiff = root_diff(tree)
        while time()-t0 < solver.max_time && root_diff(tree) > solver.precision && counter < 10
            sample!(solver, tree, steps, effective_discount)
            backup!(tree)
            counter += 1
            if (size(tree.Γ, 1)) > 1.1*numalphas
                prune!(solver, tree)
                numalphas = size(tree.Γ, 1)
            end
            write(io, "time: $(time()-t0), root_diff: $(root_diff(tree)), V_lower: $(tree.V_lower[1]), V_upper: $(tree.V_upper[1]), Belief Size: $(size(tree.b, 1)), Controller Size: $(size(tree.Γ, 1))\n")
        end

        pausedtime = time()
        println("time: $(time()-t0), root_diff: $(root_diff(tree)), V_lower: $(tree.V_lower[1]), V_upper: $(tree.V_upper[1]), Belief Size: $(size(tree.b, 1)), Controller Size: $(size(tree.Γ, 1))")
        write(io, "time: $(time()-t0), root_diff: $(root_diff(tree)), V_lower: $(tree.V_lower[1]), V_upper: $(tree.V_upper[1]), Belief Size: $(size(tree.b, 1)), Controller Size: $(size(tree.Γ, 1))\n")
        t0 += time() - pausedtime

        if abs(root_diff(tree) - latest_rootdiff) < 1e-2
            effective_discount += 9/(10^(length(string(effective_discount))-1))
            steps += solver.step_increment
        end

        firstvalue = copy(tree.V_upper[1])

        for b_idx in 1:size(tree.b)[1]
            V_upper = copy(tree.V_upper)
            if isempty(tree.b_children[b_idx])
                tree.V_upper[b_idx] = reset_upper(tree, V_upper, tree.b[b_idx])
            end
        end

        for b_idx in 1:size(tree.b)[1]
            if !isempty(tree.b_children[b_idx])
                tree.V_upper[b_idx] = tree.V_lower[b_idx]
            end
        end

        for i in 1:value_iter_max
            changed = false
            for b_idx in reverse(1:size(tree.b)[1])
                if !isempty(tree.b_children[b_idx])
                    old = tree.V_upper[b_idx]
                    backup_upper!(tree, b_idx)
                    new = tree.V_upper[b_idx]
                    if abs(old - new) > eps()
                        changed = true
                    end
                end
            end
            if changed == false
                break
            end
        end
        write(io, "time: $(time()-t0), root_diff: $(root_diff(tree)), V_lower: $(tree.V_lower[1]), V_upper: $(tree.V_upper[1]), Belief Size: $(size(tree.b, 1)), Controller Size: $(size(tree.Γ, 1))\n")
    end
    
    write(io, "Total time: $(time()-t0), root_diff: $(root_diff(tree)), V_lower: $(tree.V_lower[1]), V_upper: $(tree.V_upper[1]), Belief Size: $(size(tree.b, 1)), Controller Size: $(size(tree.Γ, 1))\n")
    close(io)
    pol = AlphaVectorPolicy(
        pomdp,
        getproperty.(tree.Γ, :alpha),
        ordered_actions(pomdp)[getproperty.(tree.Γ, :action)]
    )
    return pol
end

POMDPs.solve(solver::SARSOPSolver, pomdp::POMDP) = solve_info(solver, pomdp)