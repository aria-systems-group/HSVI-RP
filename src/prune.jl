@inline function should_prune_alphas(tree::SARSOPTree)
    p = (length(tree.Γ) - tree.prune_data.last_Γ_size) / tree.prune_data.last_Γ_size
    return p > tree.prune_data.prune_threshold
end

function prune!(solver::SARSOPSolver, tree::SARSOPTree)
    if should_prune_alphas(tree)
        prune_alpha!(tree, solver.delta)
    end
end

function pruneSubTreeBa!(tree::SARSOPTree, ba_idx::Int)
    tree.ba_pruned[ba_idx] = true
    for b_idx in tree.ba_children[ba_idx]
        if tree.b_pruned[b_idx]
            continue
        end
        pruneSubTreeB!(tree, b_idx)
    end
end

function pruneSubTreeB!(tree::SARSOPTree, b_idx::Int)
    tree.b_pruned[b_idx] = true
    for ba_idx in tree.b_children[b_idx]
        if tree.ba_pruned[ba_idx]
            continue
        end
        pruneSubTreeBa!(tree, ba_idx)
    end
end

function prune!(tree::SARSOPTree)
    for b_idx in tree.sampled
        if tree.b_pruned[b_idx]
            break
        else
            Qa_upper = tree.Qa_upper[b_idx]
            Qa_lower = tree.Qa_lower[b_idx]
            b_children = tree.b_children[b_idx]
            ba = tree.b_children[b_idx]
            max_lower_bound = maximum(Qa_lower)
            for (idx, Qba) ∈ enumerate(Qa_upper)
                ba_idx = b_children[idx]
                all_ba_pruned = true
                if !tree.ba_pruned[ba_idx] && Qa_upper[idx] < max_lower_bound
                    pruneSubTreeBa!(tree, ba_idx)
                else
                    all_ba_pruned = false
                end
                all_ba_pruned && (tree.b_pruned[b_idx] = true)
            end
        end
    end
end

function belief_space_domination(α1, α2, B, δ)
    δ = 0.01
    a1_dominant = true
    a2_dominant = true
    for b ∈ B
        !a1_dominant && !a2_dominant && return (false, false)
        δV = intersection_distance(α1, α2, b)
        δV ≤ δ && (a1_dominant = false)
        δV ≥ -δ && (a2_dominant = false)
    end
    return a1_dominant, a2_dominant
end

@inline function intersection_distance(α1, α2, b)
    s = 0.0
    dot_sum = 0.0
    I,B = b.nzind, b.nzval
    @inbounds for _i ∈ eachindex(I)
        i = I[_i]
        diff = α1[i] - α2[i]
        s += abs2(diff)
        dot_sum += diff*B[_i]
    end
    return dot_sum / sqrt(s)
end

function prune_alpha!(tree::SARSOPTree, δ)
    Γ = tree.Γ
    Γ_init = tree.Γ_init
    B_valid = tree.b[map(!,tree.b_pruned)]
    pruned = falses(length(Γ))

    # checking if α_i dominates α_j
    for (i,α_i) ∈ enumerate(Γ)
        pruned[i] && continue
        for (j,α_j) ∈ enumerate(Γ)
            (α_j ∈ Γ_init) && continue
            (j ≤ i || pruned[j]) && continue
            a1_dominant,a2_dominant = belief_space_domination(α_i, α_j, B_valid, δ)
            if a1_dominant
                pruned[j] = true
            elseif a2_dominant
                pruned[i] = true
                break
            end
        end
    end
    deleteat!(Γ, pruned)
    tree.prune_data.last_Γ_size = length(Γ)
end