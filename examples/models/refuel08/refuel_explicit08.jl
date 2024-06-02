#=
Refueling Problem
=#

using StaticArrays
using LinearAlgebra
using Random
using POMDPs
using POMDPModels
using POMDPModelTools
using Compose
using ColorSchemes
using Parameters
using BeliefUpdaters
include("../prism_parser.jl")


#slippery

function getDict()


end

@with_kw struct RefuelPOMDPExplicit08 <: POMDP{Int, Int, Int}
    slippery::Float64                  = 0.3
    obsdict::Dict{Int, Int}            = ObservationDict()
    act0dict::Dict{Int, Vector{Int}}   = TransitionDictAct0()
    act1dict::Dict{Int,  Vector{Int}}           = TransitionDictAct1()
    act2dict::Dict{Int,  Vector{Int}}           = TransitionDictAct2()
    act3dict::Dict{Int,  Vector{Int}}           = TransitionDictAct3()
end

function TransitionDictAct0()
    file_path = "examples/models/refuel08/refuel08_explicit.prism"
    my_observations, my_transitions, act0, act1, act2, act3 = parse_prism_file(file_path);  
    return act0
end


function TransitionDictAct1()
    file_path = "examples/models/refuel08/refuel08_explicit.prism"
    my_observations, my_transitions, act0, act1, act2, act3 = parse_prism_file(file_path);  
    return act1
end

function TransitionDictAct2()
    file_path = "examples/models/refuel08/refuel08_explicit.prism"
    my_observations, my_transitions, act0, act1, act2, act3 = parse_prism_file(file_path);  
    return act2
end

function TransitionDictAct3()
    file_path = "examples/models/refuel08/refuel08_explicit.prism"
    my_observations, my_transitions, act0, act1, act2, act3 = parse_prism_file(file_path);  
    return act3
end
## States 

POMDPs.length(pomdp::RefuelPOMDPExplicit08) = 471

POMDPs.states(pomdp::RefuelPOMDPExplicit08) = 1:471

POMDPs.stateindex(pomdp::RefuelPOMDPExplicit08, s::Int) = s

function POMDPs.initialstate(pomdp::RefuelPOMDPExplicit08)
    return Deterministic(1)
end

function POMDPs.transition(pomdp::RefuelPOMDPExplicit08, s::Int, a::Int)

    probs = [1- pomdp.slippery, pomdp.slippery]
    dests = []
    if a == 1
        if haskey(pomdp.act0dict, s-1)
            dests = deepcopy(pomdp.act0dict[s-1])
        else
            dests = [470]
        end
    elseif a == 2
        if haskey(pomdp.act1dict, s-1)
            dests = deepcopy(pomdp.act1dict[s-1])
        else
            dests = [470]
        end
    elseif a == 3
        if haskey(pomdp.act2dict, s-1)
            dests = deepcopy(pomdp.act2dict[s-1])
        else
            dests = [470]
        end
    elseif a == 4
        if haskey(pomdp.act3dict, s-1)
            dests = deepcopy(pomdp.act3dict[s-1])
        else
            dests = [470]
        end
    end

    if length(dests) == 1
        return SparseCat([dests[1] + 1], [1.0])
    end

    return SparseCat(dests + [1,1], probs)
end

## Actions 

POMDPs.actions(pomdp::RefuelPOMDPExplicit08) = 1:4
POMDPs.actionindex(pomdp::RefuelPOMDPExplicit08, a::Int) = a

## Transition


function POMDPs.isterminal(m::RefuelPOMDPExplicit08, s::Int)
    if (s-1) in Set(452, 464, 465,469, 373, 410, 418, 442, 458, 466)
        return true
    end
end


## Observation 

POMDPs.observations(pomdp::RefuelPOMDPExplicit08) = 1:67
POMDPs.obsindex(::RefuelPOMDPExplicit08, o::Int) = o

function POMDPs.initialobs(pomdp::RefuelPOMDPExplicit08, s) 
    return observations(pomdp, :up, s)
end


function ObservationDict()

    file_path = "examples/models/refuel08/refuel08_explicit.prism"
    my_observations, my_transitions, act0, act1, act2, act3 = parse_prism_file(file_path);  
    
    my_observations[0] = 62
    my_observations[470] = 66
    return my_observations
end

function POMDPs.observation(pomdp::RefuelPOMDPExplicit08, a, s)
    
    return Deterministic(pomdp.obsdict[s-1] + 1)
end

## Reward 
POMDPs.reward(pomdp::RefuelPOMDPExplicit08, s::Int) = 1.0
POMDPs.reward(pomdp::RefuelPOMDPExplicit08, s, a, sp) = reward(pomdp, s)
POMDPs.reward(pomdp::RefuelPOMDPExplicit08, s, a) = reward(pomdp, s)
POMDPs.discount(pomdp::RefuelPOMDPExplicit08) = 0.999

## distributions 
## helpers

function deterministic_belief(pomdp, s)
    b = zeros(length(states(pomdp)))
    si = stateindex(pomdp, s)
    b[si] = 1.0
    return DiscreteBelief(pomdp, b)
end