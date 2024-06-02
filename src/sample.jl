function sample!(sol, tree, steps, effective_discount)
    empty!(tree.sampled)
    empty!(tree.actions_sampled)
    L = tree.V_lower[1]
    U = L + sol.epsilon*root_diff(tree)
    cycle_detector = Dict{Int, Int}()
    sample_points(sol, tree, 1, 0, sol.epsilon*root_diff(tree), steps, effective_discount, cycle_detector)
end

function sample_points(sol::SARSOPSolver, tree::SARSOPTree, b_idx::Int, t, ϵ, steps, effective_discount, cycle_detector)
    tree.b_pruned[b_idx] = false
    if !tree.is_real[b_idx]
        tree.is_real[b_idx] = true
        push!(tree.real, b_idx)
    end

    if tree.is_terminal[b_idx]
        return
    end

    fill_belief!(tree, b_idx)
    V̲, V̄ = tree.V_lower[b_idx], tree.V_upper[b_idx]
    γ = effective_discount
    V̂ = V̄

    if V̂ ≤ V̲ + sol.kappa*ϵ*γ^(-t) || t > steps
        push!(tree.sampled, b_idx)
        return
    else
        a′, op_idx, cycle_detector = choose_action_and_observation(tree, b_idx, ϵ, γ, t+1, cycle_detector)
        if a′ == 0 || op_idx == 0
            push!(tree.sampled, b_idx)
            cycle_detector[b_idx] = -1
            
            if all(values(cycle_detector) .== -1)
                return
            end
            for b_indices in tree.sampled
                if b_indices ∈ keys(cycle_detector)
                    if cycle_detector[b_indices] != -1
                        sample_points(sol, tree, b_indices, t+1, ϵ, steps, effective_discount, cycle_detector)
                        return
                    end
                end
            end
        end
        ba_idx = tree.b_children[b_idx][a′]
        bp_idx = tree.ba_children[ba_idx][op_idx]
        tree.Nb[b_idx] += 1
        tree.Nba[b_idx][a′] += 1
        tree.Nbao[ba_idx][op_idx] += 1
        push!(tree.sampled, b_idx)
        push!(tree.actions_sampled, a′)
        sample_points(sol, tree, bp_idx, t+1, ϵ, steps, effective_discount, cycle_detector)
    end
end

function choose_action_and_observation(tree, b_idx, ϵ, γ, t, cycle_detector)
    actions_left = Set(actions(tree.pomdp))
    a′ = -1
    op_idx = -1
    while a′ ≤ 0 || op_idx ≤ 0
        Q̲, Q̄, a′ = max_r_and_q(tree, b_idx, actions_left)
        if a′ == 0
            break
        end
        delete!(actions_left, a′)
        ba_idx = tree.b_children[b_idx][a′]
        tree.ba_pruned[ba_idx] = false
        op_idx, cycle_detector = best_obs(tree, b_idx, ba_idx, ϵ, γ, t, cycle_detector)
    end
    return a′, op_idx, cycle_detector
end

belief_reward(tree, b, a) = dot(@view(tree.pomdp.R[:,a]), b)

function rand_r_and_q(tree::SARSOPTree, b_idx::Int)
    i = rand(1:length(tree.b_children[b_idx]))
    a′ = i
    Q̄ = tree.Qa_upper[b_idx][i]
    Q̲ = tree.Qa_lower[b_idx][i]
    return Q̲, Q̄, a′
end

function max_r_and_q(tree::SARSOPTree, b_idx::Int, actions_left)
    Q̲ = -Inf
    Q̄ = -Inf
    a′ = 0

    best_action = []
    bestval = maximum(tree.Qa_upper[b_idx])

    for (i,ba_idx) in enumerate(tree.b_children[b_idx])
        if i ∉ actions_left
            continue
        end
        Q̄′ = tree.Qa_upper[b_idx][i]
        Q̲′ = tree.Qa_lower[b_idx][i]
        if Q̲′ > Q̲
            Q̲ = Q̲′
        end
        if Q̄′ > Q̄
            Q̄ = Q̄′
            a′ = i
        end
        if abs(Q̄′ - bestval) ≤ 0.1
            maxval = Q̄′ + 0.01*sqrt(tree.Nb[b_idx])/(1 + tree.Nba[b_idx][i])
            if (maxval > Q̄)
                a′ = i
                Q̄ = maxval
            end
        end 
        if Q̄′ < Q̲
            delete!(actions_left, i)
        end
    end
    return Q̲, Q̄, a′
end


function best_obs(tree::SARSOPTree, b_idx, ba_idx, ϵ,γ, t, cycle_detector)
    S = states(tree)
    O = observations(tree)

    best_o = 0
    best_gap = -Inf

    nonzeros = findall(tree.poba[ba_idx] .> 0)

    for o in nonzeros
        poba = tree.poba[ba_idx][o]
        bp_idx = tree.ba_children[ba_idx][o]
        if bp_idx ∈ tree.sampled
            if !haskey(cycle_detector, bp_idx)
                cycle_detector[bp_idx] = 1
            else
                continue
            end
        end
        if tree.V_upper[bp_idx] == 0.0
            continue
        end
        gap = tree.V_upper[bp_idx] - tree.V_lower[bp_idx] + poba*(0.01*sqrt(tree.Nb[b_idx])/(1 + tree.Nbao[ba_idx][o]))
        if gap > best_gap
            best_gap = gap
            best_o = o
        end
    end
    return best_o, cycle_detector
end

obs_prob(tree::SARSOPTree, ba_idx::Int, o_idx::Int) = tree.poba[ba_idx][o_idx]