function max_alpha_val(Γ, b)
    max_α = first(Γ)
    max_val = -Inf
    for α ∈ Γ
        val = dot(α, b)
        if val > max_val
            max_α = α
            max_val = val
        end
    end
    return max_α.alpha
end

function backup_a!(α, pomdp::ModifiedSparseTabular, cache::TreeCache, a, Γao)
    γ = 1.0
    R = @view pomdp.R[:,a]
    T_a = pomdp.T[a]
    Z_a = cache.Oᵀ[a]
    Γa = @view Γao[:,:,a]

    Tnz = nonzeros(T_a)
    Trv = rowvals(T_a)
    Znz = nonzeros(Z_a)
    Zrv = rowvals(Z_a)

    for s ∈ eachindex(α)
        v = 0.0
        for sp_idx ∈ nzrange(T_a, s)
            sp = Trv[sp_idx]
            p = Tnz[sp_idx]
            tmp = 0.0
            for o_idx ∈ nzrange(Z_a, sp)
                o = Zrv[o_idx]
                po = Znz[o_idx]
                tmp += po*Γa[sp, o]
            end
            v += tmp*p
        end
        α[s] = v
    end
    @. α = R + γ*α
end

function backup!(tree, b_idx)
    Γ = tree.Γ
    b = tree.b[b_idx]
    pomdp = tree.pomdp
    S = states(tree)
    A = actions(tree)
    O = observations(tree)

    Γao = tree.cache.Γ

    for a ∈ A
        ba_idx = tree.b_children[b_idx][a]

        for o ∈ O
            bp_idx = tree.ba_children[ba_idx][o]
            bp = tree.b[bp_idx]
            Γao[:,o,a] .= max_alpha_val(Γ, bp)
        end
    end

    V = -Inf
    α_a = tree.cache.alpha
    best_α = zeros(Float64, length(S))
    best_action = first(A)

    for a ∈ A
        α_a = backup_a!(α_a, pomdp, tree.cache, a, Γao)
        Qba = dot(α_a, b)
        tree.Qa_lower[b_idx][a] = Qba
        if Qba > V
            V = Qba
            best_α .= α_a
            best_action = a
        end
    end

    α = AlphaVec(best_α, best_action)
    push!(Γ, α)
    tree.V_lower[b_idx] = V

    for a ∈ A
        Rba = belief_reward(tree, b, a)
        tree.Qa_upper[b_idx][a] = Rba
        ba_idx = tree.b_children[b_idx][a]

        nonzeros = findall(tree.poba[ba_idx] .> 0)
        for o ∈ nonzeros
            bp_idx = tree.ba_children[ba_idx][o]
            bp = tree.b[bp_idx]
            Qba = tree.V_upper[bp_idx]
            po = tree.poba[ba_idx][o]
            tree.Qa_upper[b_idx][a] += po*Qba
        end
    end

    tree.V_upper[b_idx] = maximum(tree.Qa_upper[b_idx])
end

function backup_upper!(tree, b_idx)
    b = tree.b[b_idx]
    pomdp = tree.pomdp
    γ = discount(tree)
    S = states(tree)
    A = actions(tree)
    O = observations(tree)
    b = tree.b[b_idx]
    for a ∈ A
        Rba = belief_reward(tree, b, a)
        tree.Qa_upper[b_idx][a] = Rba
        ba_idx = tree.b_children[b_idx][a]
        for o ∈ O
            bp_idx = tree.ba_children[ba_idx][o]
            Qba = tree.V_upper[bp_idx]
            po = tree.poba[ba_idx][o]
            tree.Qa_upper[b_idx][a] += po*Qba
        end

        if abs(tree.Qa_upper[b_idx][a] - 0.0) < 1e-15
            tree.Qa_upper[b_idx][a] = 0.0
        end
    end
    tree.V_upper[b_idx] = maximum(tree.Qa_upper[b_idx])
end

function backup!(tree)
    for i ∈ reverse(eachindex(tree.sampled))
        backup!(tree, tree.sampled[i])
    end
end
