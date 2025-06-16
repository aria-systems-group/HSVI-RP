#=
Drone Problem
=#

using StaticArrays
using LinearAlgebra
using Random
using POMDPs
using POMDPModels
using POMDPTools
using Compose
using ColorSchemes
using Parameters
include("../prism_parser.jl")

@with_kw struct GridAvoid20 <: POMDP{Int, Int, Int}
    slippery::Float64                  = 0.5
    obsdict::Dict{Int, Int}            = ObservationDict()
    act0dict::Dict{Int, Vector{Int}}   = TransitionDictAct0()
    act1dict::Dict{Int,  Vector{Int}}           = TransitionDictAct1()
    act2dict::Dict{Int,  Vector{Int}}           = TransitionDictAct2()
    act3dict::Dict{Int,  Vector{Int}}           = TransitionDictAct3()
end

function TransitionDictAct0()
    file_path = "examples/models/grid-20/gridavoid_explicit20.prism"
    my_observations, my_transitions, act0, act1, act2, act3 = parse_prism_file_gridavoid(file_path);  
    return act0
end


function TransitionDictAct1()
    file_path = "examples/models/grid-20/gridavoid_explicit20.prism"
    my_observations, my_transitions, act0, act1, act2, act3 = parse_prism_file_gridavoid(file_path);  
    return act1
end

function TransitionDictAct2()
    file_path = "examples/models/grid-20/gridavoid_explicit20.prism"
    my_observations, my_transitions, act0, act1, act2, act3 = parse_prism_file_gridavoid(file_path);  
    return act2
end

function TransitionDictAct3()
    file_path = "examples/models/grid-20/gridavoid_explicit20.prism"
    my_observations, my_transitions, act0, act1, act2, act3 = parse_prism_file_gridavoid(file_path);  
    return act3
end



## States 
POMDPs.length(pomdp::GridAvoid20) = 402

POMDPs.states(pomdp::GridAvoid20) = 1:402

POMDPs.stateindex(pomdp::GridAvoid20, s::Int) = s

function POMDPs.initialstate(pomdp::GridAvoid20)
    return Deterministic(1)
end

function POMDPs.transition(pomdp::GridAvoid20, s::Int, a::Int)

    probs = [1- pomdp.slippery, pomdp.slippery]
    probs2 = (1/21)*ones(21)

    dests = []
    if a == 1
        if haskey(pomdp.act0dict, s-1)
            dests = deepcopy(pomdp.act0dict[s-1])
        else
            dests = [401]
        end
    elseif a == 2
        if haskey(pomdp.act1dict, s-1)
            dests = deepcopy(pomdp.act1dict[s-1])
        else
            dests = [401]
        end
    elseif a == 3
        if haskey(pomdp.act2dict, s-1)
            dests = deepcopy(pomdp.act2dict[s-1])
        else
            dests = [401]
        end
    elseif a == 4
        if haskey(pomdp.act3dict, s-1)
            dests = deepcopy(pomdp.act3dict[s-1])
        else
            dests = [401]
        end
    end

    if length(dests) == 1
        return SparseCat([dests[1] + 1], [1.0])
    end

    if length(dests) == 2
        return SparseCat(dests + [1,1], probs)
    end

    if length(dests) > 2
        dests .+= 1
        return SparseCat(dests, probs2)
    end

    @show dests, a, s

    # return SparseCat(dests + [1,1,1, 1], probs4)
end

## Actions 

POMDPs.actions(pomdp::GridAvoid20) = 1:4
POMDPs.actionindex(pomdp::GridAvoid20, a::Int) = a

## Transition

function POMDPs.isterminal(m::GridAvoid20, s::Int)
    if (s-1) in Set() #TODO
        return true
    end
end
# module model
# 	s : [0..203] init 0;
# 	o : [0..4] init 3;
## Observation 

# s : [0..401] init 0;
# o : [0..4] init 3;

POMDPs.observations(pomdp::GridAvoid20) = 1:5
POMDPs.obsindex(::GridAvoid20, o::Int) = o

function POMDPs.initialobs(pomdp::GridAvoid20, s) 
    return observations(pomdp, :up, s)
end

# s : [0..101] init 0;


function ObservationDict()

    file_path = "examples/models/grid-20/gridavoid_explicit20.prism"
    my_observations, my_transitions, act0, act1, act2, act3 = parse_prism_file_gridavoid(file_path);  
    
    my_observations[0] = 3
    my_observations[401] = 1
    return my_observations
end

function POMDPs.observation(pomdp::GridAvoid20, a, s)
    
    return Deterministic(pomdp.obsdict[s-1] + 1)
end

## Reward 
POMDPs.reward(pomdp::GridAvoid20, s::Int) = 1.0
POMDPs.reward(pomdp::GridAvoid20, s, a, sp) = reward(pomdp, s)
POMDPs.reward(pomdp::GridAvoid20, s, a) = reward(pomdp, s)
POMDPs.discount(pomdp::GridAvoid20) = 1.0