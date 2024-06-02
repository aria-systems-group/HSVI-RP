#=
Drone Problem
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

@with_kw struct Drone41 <: POMDP{Int, Int, Int}
    slippery::Float64                  = 0.3
    obsdict::Dict{Int, Int}            = ObservationDict()
    act0dict::Dict{Int, Vector{Int}}   = TransitionDictAct0()
    act1dict::Dict{Int,  Vector{Int}}           = TransitionDictAct1()
    act2dict::Dict{Int,  Vector{Int}}           = TransitionDictAct2()
    act3dict::Dict{Int,  Vector{Int}}           = TransitionDictAct3()
end

function TransitionDictAct0()
    file_path = "examples/models/drone41/drone41_explicit.prism"
    my_observations, my_transitions, act0, act1, act2, act3 = parse_prism_file_drone(file_path);  
    return act0
end


function TransitionDictAct1()
    file_path = "examples/models/drone41/drone41_explicit.prism"
    my_observations, my_transitions, act0, act1, act2, act3 = parse_prism_file_drone(file_path);  
    return act1
end

function TransitionDictAct2()
    file_path = "examples/models/drone41/drone41_explicit.prism"
    my_observations, my_transitions, act0, act1, act2, act3 = parse_prism_file_drone(file_path);  
    return act2
end

function TransitionDictAct3()
    file_path = "examples/models/drone41/drone41_explicit.prism"
    my_observations, my_transitions, act0, act1, act2, act3 = parse_prism_file_drone(file_path);  
    return act3
end
## States 


POMDPs.length(pomdp::Drone41) = 1227

POMDPs.states(pomdp::Drone41) = 1:1227

POMDPs.stateindex(pomdp::Drone41, s::Int) = s

function POMDPs.initialstate(pomdp::Drone41)
    return Deterministic(1)
end

function POMDPs.transition(pomdp::Drone41, s::Int, a::Int)

    probs = [1- pomdp.slippery, pomdp.slippery]


    probs3 = [0.5, 0.25, 0.25]


    probs4 = [0.25, 0.25, 0.25, 0.25]

    dests = []
    if a == 1
        if haskey(pomdp.act0dict, s-1)
            dests = deepcopy(pomdp.act0dict[s-1])
        else
            dests = [1226]
        end
    elseif a == 2
        if haskey(pomdp.act1dict, s-1)
            dests = deepcopy(pomdp.act1dict[s-1])
        else
            dests = [1226]
        end
    elseif a == 3
        if haskey(pomdp.act2dict, s-1)
            dests = deepcopy(pomdp.act2dict[s-1])
        else
            dests = [1226]
        end
    elseif a == 4
        if haskey(pomdp.act3dict, s-1)
            dests = deepcopy(pomdp.act3dict[s-1])
        else
            dests = [1226]
        end
    end

    if length(dests) == 1
        return SparseCat([dests[1] + 1], [1.0])
    end

    if length(dests) == 2
        return SparseCat(dests + [1,1], probs)
    end

    if length(dests) == 3
        return SparseCat(dests + [1,1, 1], probs3)
    end

    return SparseCat(dests + [1,1,1, 1], probs4)
end

## Actions 

POMDPs.actions(pomdp::Drone41) = 1:4
POMDPs.actionindex(pomdp::Drone41, a::Int) = a

## Transition


function POMDPs.isterminal(m::Drone41, s::Int)
    if (s-1) in Set(452, 464, 465,469, 373, 410, 418, 442, 458, 466) #TODO
        return true
    end
end

## Observation 

POMDPs.observations(pomdp::Drone41) = 1:385
POMDPs.obsindex(::Drone41, o::Int) = o

function POMDPs.initialobs(pomdp::Drone41, s) 
    return observations(pomdp, :up, s)
end


function ObservationDict()
    file_path = "examples/models/drone41/drone41_explicit.prism"
    my_observations, my_transitions, act0, act1, act2, act3 = parse_prism_file_drone(file_path);  
    
    my_observations[0] = 243
    my_observations[1226] = 384
    return my_observations
end

function POMDPs.observation(pomdp::Drone41, a, s)
    
    return Deterministic(pomdp.obsdict[s-1] + 1)
end

## Reward 
POMDPs.reward(pomdp::Drone41, s::Int) = 1.0
POMDPs.reward(pomdp::Drone41, s, a, sp) = reward(pomdp, s)
POMDPs.reward(pomdp::Drone41, s, a) = reward(pomdp, s)
POMDPs.discount(pomdp::Drone41) = 1.0