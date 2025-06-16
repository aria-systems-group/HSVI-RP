using POMDPs
using Parameters
using POMDPTools

include("generic_prism_parser.jl")

@with_kw struct GenericPrismPOMDP <: POMDP{Int, Int, Int}
    transitions::Dict{Tuple{Int, Int}, SparseCat{Vector{Int}, Vector{Float64}}}
    observations::Dict{Int, Int}
    labels::Dict{String, Set{Int}}
    action_map::Dict{String, Int}
    metadata::Dict{String, Any}
    reward_dict::Dict{String, Float64} = Dict("goal" => 1.0, "traps" => -1.0)
    discount::Float64 = 0.99
end

function GenericPrismPOMDP(filename::String; kwargs...)
    trans, obs, labels, act_map, meta = parse_generic_prism_file(filename)
    # Check if an initial state was found
    if meta["initial_state"] == -1
        @warn "Initial state not found in PRISM file, defaulting to state 0."
        meta["initial_state"] = 0
    end
    return GenericPrismPOMDP(;
        transitions=trans,
        observations=obs,
        labels=labels,
        action_map=act_map,
        metadata=meta,
        kwargs...
    )
end

## States, Actions, Observations
POMDPs.states(pomdp::GenericPrismPOMDP) = 0:(pomdp.metadata["num_states"]-1)
POMDPs.actions(pomdp::GenericPrismPOMDP) = 1:pomdp.metadata["num_actions"]
POMDPs.observations(pomdp::GenericPrismPOMDP) = 0:(pomdp.metadata["num_obs"]-1)

POMDPs.stateindex(pomdp::GenericPrismPOMDP, s::Int) = s + 1
POMDPs.actionindex(pomdp::GenericPrismPOMDP, a::Int) = a
POMDPs.obsindex(::GenericPrismPOMDP, o::Int) = o+1

## Initial State
POMDPs.initialstate(pomdp::GenericPrismPOMDP) = Deterministic(pomdp.metadata["initial_state"])

## Transition Function
function POMDPs.transition(pomdp::GenericPrismPOMDP, s::Int, a::Int)
    if haskey(pomdp.transitions, (s, a))
        return pomdp.transitions[(s, a)]
    end
    # Terminal states (that have no outgoing transitions) transition to themselves
    return Deterministic(s)
end

## Observation Function
function POMDPs.observation(pomdp::GenericPrismPOMDP, a::Int, sp::Int)
    obs_val = get(pomdp.observations, sp, -1) # Default to -1 if no obs is specified
    return Deterministic(obs_val)
end

## Reward Function
function POMDPs.reward(pomdp::GenericPrismPOMDP, s::Int, a::Int, sp::Int)
    for (label, reward_val) in pomdp.reward_dict
        if sp in get(pomdp.labels, label, Set())
            r += reward_val
        end
    end
    return r
end

## Terminal States
function POMDPs.isterminal(pomdp::GenericPrismPOMDP, s::Int)
    for label in keys(pomdp.reward_dict)
        if s in get(pomdp.labels, label, Set())
            return true
        end
    end
    return false
end

## Discount Factor
POMDPs.discount(pomdp::GenericPrismPOMDP) = pomdp.discount