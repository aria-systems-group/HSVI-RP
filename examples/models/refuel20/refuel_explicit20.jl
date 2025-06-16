#=
Refueling Problem
=#

using StaticArrays
using LinearAlgebra
using Random
using POMDPs
using POMDPModels
using Compose
using ColorSchemes
using Parameters
include("../prism_parser.jl")


#slippery

function getDict()


end

@with_kw struct RefuelPOMDPExplicit20 <: POMDP{Int, Int, Int}
    slippery::Float64                  = 0.3
    obsdict::Dict{Int, Int}            = ObservationDict()
    act0dict::Dict{Int, Vector{Int}}   = TransitionDictAct0()
    act1dict::Dict{Int,  Vector{Int}}           = TransitionDictAct1()
    act2dict::Dict{Int,  Vector{Int}}           = TransitionDictAct2()
    act3dict::Dict{Int,  Vector{Int}}           = TransitionDictAct3()
end

function TransitionDictAct0()
    file_path = "examples/models/refuel20/refuel20_explicit.prism"
    my_observations, my_transitions, act0, act1, act2, act3 = parse_prism_file(file_path);  
    return act0
end


function TransitionDictAct1()
    file_path = "examples/models/refuel20/refuel20_explicit.prism"
    my_observations, my_transitions, act0, act1, act2, act3 = parse_prism_file(file_path);  
    return act1
end

function TransitionDictAct2()
    file_path = "examples/models/refuel20/refuel20_explicit.prism"
    my_observations, my_transitions, act0, act1, act2, act3 = parse_prism_file(file_path);  
    return act2
end

function TransitionDictAct3()
    file_path = "examples/models/refuel20/refuel20_explicit.prism"
    my_observations, my_transitions, act0, act1, act2, act3 = parse_prism_file(file_path);  
    return act3
end
## States 

POMDPs.length(pomdp::RefuelPOMDPExplicit20) = 6834+1

POMDPs.states(pomdp::RefuelPOMDPExplicit20) = 1:6835

POMDPs.stateindex(pomdp::RefuelPOMDPExplicit20, s::Int) = s

function POMDPs.initialstate(pomdp::RefuelPOMDPExplicit20)
    return Deterministic(1)
end


function POMDPs.transition(pomdp::RefuelPOMDPExplicit20, s::Int, a::Int)

    probs = [1- pomdp.slippery, pomdp.slippery]
    dests = []
    if a == 1
        if haskey(pomdp.act0dict, s-1)
            dests = deepcopy(pomdp.act0dict[s-1])
        else
            dests = [6834]
        end
    elseif a == 2
        if haskey(pomdp.act1dict, s-1)
            dests = deepcopy(pomdp.act1dict[s-1])
        else
            dests = [6834]
        end
    elseif a == 3
        if haskey(pomdp.act2dict, s-1)
            dests = deepcopy(pomdp.act2dict[s-1])
        else
            dests = [6834]
        end
    elseif a == 4
        if haskey(pomdp.act3dict, s-1)
            dests = deepcopy(pomdp.act3dict[s-1])
        else
            dests = [6834]
        end
    end

    if length(dests) == 1
        return SparseCat([dests[1] + 1], [1.0])
    end

    return SparseCat(dests + [1,1], probs)
end

## Actions 

POMDPs.actions(pomdp::RefuelPOMDPExplicit20) = 1:4 
POMDPs.actionindex(pomdp::RefuelPOMDPExplicit20, a::Int) = a

## transition

function POMDPs.isterminal(m::RefuelPOMDPExplicit20, s::Int)
    if (s-1) in Set(6524, 6608, 6649, 6709, 6734, 6774, 6787, 6811, 6816, 6828, 6829, 6833, 6127, 6267, 6346, 6458, 6518, 6602, 6644, 6704, 6728, 6768, 6782, 6806, 6823, 6830)
        return true
    end
end

## Observation 

POMDPs.observations(pomdp::RefuelPOMDPExplicit20) = 1:175
POMDPs.obsindex(::RefuelPOMDPExplicit20, o::Int) = o

function POMDPs.initialobs(pomdp::RefuelPOMDPExplicit20, s) 
    return observations(pomdp, :up, s)
end

function ObservationDict()

    file_path = "examples/models/refuel20/refuel20_explicit.prism"
    my_observations, my_transitions, act0, act1, act2, act3 = parse_prism_file(file_path);  
    
    my_observations[0] = 127
    my_observations[6834] = 175
    return my_observations
end

function POMDPs.observation(pomdp::RefuelPOMDPExplicit20, a, s)
    
    return Deterministic(pomdp.obsdict[s-1] + 1)
end

## Reward 
POMDPs.reward(pomdp::RefuelPOMDPExplicit20, s::Int) = 1.0
POMDPs.reward(pomdp::RefuelPOMDPExplicit20, s, a, sp) = reward(pomdp, s)
POMDPs.reward(pomdp::RefuelPOMDPExplicit20, s, a) = reward(pomdp, s)
POMDPs.discount(pomdp::RefuelPOMDPExplicit20) = 0.999