#=
nrp8 Problem
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

@with_kw struct nrp8 <: POMDP{Int, Int, Int}
    obsdict::Dict{Int, Int}            = ObservationDict()
    act0dict::Dict{Int, Vector{Int}}   = TransitionDictAct0()
    act1dict::Dict{Int,  Vector{Int}}           = TransitionDictAct1()
end

function TransitionDictAct0()
    file_path = "examples/models/nrp8/nrp8.prism"
    my_observations, my_transitions, act0, act1 = parse_prism_file_nrp8(file_path);  
    return act0
end

function TransitionDictAct1()
    file_path = "examples/models/nrp8/nrp8.prism"
    my_observations, my_transitions, act0, act1 = parse_prism_file_nrp8(file_path);  
    return act1
end

## States 

#s : [0..125] init 0;
# o : [0..41] init 30;

POMDPs.length(pomdp::nrp8) = 126

POMDPs.states(pomdp::nrp8) = 1:126

POMDPs.stateindex(pomdp::nrp8, s::Int) = s

function POMDPs.initialstate(pomdp::nrp8)
    return Deterministic(1)
end

function POMDPs.transition(pomdp::nrp8, s::Int, a::Int)
    probs2 = fill(0.125, 8)
    dests = []

    if a == 1
        if haskey(pomdp.act0dict, s-1)
            dests = deepcopy(pomdp.act0dict[s-1])
        else
            dests = [125]
        end
    elseif a == 2
        if haskey(pomdp.act1dict, s-1)
            dests = deepcopy(pomdp.act1dict[s-1])
        else
            dests = [125]
        end
    end

    if length(dests) == 1
        return SparseCat([dests[1] + 1], [1.0])
    end
    if length(dests) > 1
        dests .+= 1
        return SparseCat(dests, probs2)
    end
end

## Actions 

POMDPs.actions(pomdp::nrp8) = 1:2
POMDPs.actionindex(pomdp::nrp8, a::Int) = a

## Transition

function POMDPs.isterminal(m::nrp8, s::Int)
    if (s-1) in Set() #TODO
        return true
    end
end

## Observation 
# s : [0..125] init 0;
# o : [0..41] init 30;
POMDPs.observations(pomdp::nrp8) = 1:42
POMDPs.obsindex(::nrp8, o::Int) = o

function POMDPs.initialobs(pomdp::nrp8, s) 
    return observations(pomdp, :up, s)
end

function ObservationDict()

    file_path = "examples/models/nrp8/nrp8.prism"
    my_observations, my_transitions, act0, act1 = parse_prism_file_nrp8(file_path);  
    
    my_observations[0] = 30
    my_observations[125] = 41
    return my_observations
end

function POMDPs.observation(pomdp::nrp8, a, s)
    
    return Deterministic(pomdp.obsdict[s-1] + 1)
end

## Reward 
POMDPs.reward(pomdp::nrp8, s::Int) = 1.0
POMDPs.reward(pomdp::nrp8, s, a, sp) = reward(pomdp, s)
POMDPs.reward(pomdp::nrp8, s, a) = reward(pomdp, s)
POMDPs.discount(pomdp::nrp8) = 1.0