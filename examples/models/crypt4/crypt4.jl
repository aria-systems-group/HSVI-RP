#=
Crypt4 Problem
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

@with_kw struct Crypt4 <: POMDP{Int, Int, Int}
    obsdict::Dict{Int, Int}            = ObservationDict()
    act0dict::Dict{Int, Vector{Int}}   = TransitionDictAct0()
    act1dict::Dict{Int,  Vector{Int}}           = TransitionDictAct1()
    act2dict::Dict{Int,  Vector{Int}}           = TransitionDictAct2()
    act3dict::Dict{Int,  Vector{Int}}           = TransitionDictAct3()
    act4dict::Dict{Int,  Vector{Int}}           = TransitionDictAct4()
    act5dict::Dict{Int,  Vector{Int}}           = TransitionDictAct5()
end

function TransitionDictAct0()
    file_path = "examples/models/crypt4/crypt4.prism"
    my_observations, my_transitions, act0, act1, act2, act3, act4, act5 = parse_prism_file_crypt4(file_path);  
    return act0
end

function TransitionDictAct1()
    file_path = "examples/models/crypt4/crypt4.prism"
    my_observations, my_transitions, act0, act1, act2, act3, act4, act5 = parse_prism_file_crypt4(file_path);  
    return act1
end

function TransitionDictAct2()
    file_path = "examples/models/crypt4/crypt4.prism"
    my_observations, my_transitions, act0, act1, act2, act3, act4, act5 = parse_prism_file_crypt4(file_path);  
    return act2
end

function TransitionDictAct3()
    file_path = "examples/models/crypt4/crypt4.prism"
    my_observations, my_transitions, act0, act1, act2, act3, act4, act5 = parse_prism_file_crypt4(file_path);  
    return act3
end

function TransitionDictAct4()
    file_path = "examples/models/crypt4/crypt4.prism"
    my_observations, my_transitions, act0, act1, act2, act3, act4, act5 = parse_prism_file_crypt4(file_path);  
    return act2
end

function TransitionDictAct5()
    file_path = "examples/models/crypt4/crypt4.prism"
    my_observations, my_transitions, act0, act1, act2, act3, act4, act5 = parse_prism_file_crypt4(file_path);  
    return act3
end

## States 

POMDPs.length(pomdp::Crypt4) = 1973

POMDPs.states(pomdp::Crypt4) = 1:1973

POMDPs.stateindex(pomdp::Crypt4, s::Int) = s

function POMDPs.initialstate(pomdp::Crypt4)
    return Deterministic(1)
end

function POMDPs.transition(pomdp::Crypt4, s::Int, a::Int)

    probs = fill(1/3, 3)
    probs2 = fill(0.0625, 16)
    dests = []

    if s == 1973
        return SparseCat([1973], [1.0])
    end

    if a == 1
        if haskey(pomdp.act0dict, s-1)
            dests = deepcopy(pomdp.act0dict[s-1])
        else
            dests = deepcopy(pomdp.act0dict[s-1]) #[1972]
        end
    elseif a == 2
        if haskey(pomdp.act1dict, s-1)
            dests = deepcopy(pomdp.act1dict[s-1])
        else
            dests = deepcopy(pomdp.act0dict[s-1]) #[1972]
        end
    elseif a == 3
        if haskey(pomdp.act2dict, s-1)
            dests = deepcopy(pomdp.act2dict[s-1])
        else
            dests = deepcopy(pomdp.act0dict[s-1]) #[1972]
        end
    elseif a == 4
        if haskey(pomdp.act3dict, s-1)
            dests = deepcopy(pomdp.act3dict[s-1])
        else
            dests = deepcopy(pomdp.act0dict[s-1]) #[1972]
        end
    elseif a == 5
        if haskey(pomdp.act3dict, s-1)
            dests = deepcopy(pomdp.act3dict[s-1])
        else
            dests = deepcopy(pomdp.act0dict[s-1]) #[1972]
        end
    elseif a == 6
        if haskey(pomdp.act3dict, s-1)
            dests = deepcopy(pomdp.act3dict[s-1])
        else
            dests = deepcopy(pomdp.act0dict[s-1]) #[1972]
        end
    else
        @show "Unknown Action"
    end

    if length(dests) == 1
        return SparseCat([dests[1] + 1], [1.0])
    end
    if length(dests) == 3
        return SparseCat(dests + [1,1,1], probs)
    end
    if length(dests) > 3
        dests .+= 1
        return SparseCat(dests, probs2)
    end
end

## Actions 

POMDPs.actions(pomdp::Crypt4) = 1:6
POMDPs.actionindex(pomdp::Crypt4, a::Int) = a

## Transition

function POMDPs.isterminal(m::Crypt4, s::Int)
    if (s-1) in Set() #TODO
        return true
    end
end

## Observation 
#s : [0..1972] init 0;
#o : [0..510] init 407;
POMDPs.observations(pomdp::Crypt4) = 1:511
POMDPs.obsindex(::Crypt4, o::Int) = o

function POMDPs.initialobs(pomdp::Crypt4, s) 
    return observations(pomdp, :up, s)
end

function ObservationDict()

    file_path = "examples/models/crypt4/crypt4.prism"
    my_observations, my_transitions, act0, act1, act2, act3, act4, act5 = parse_prism_file_crypt4(file_path);  
    
    my_observations[0] = 407
    my_observations[1972] = 509
    return my_observations
end

function POMDPs.observation(pomdp::Crypt4, a, s)
    
    return Deterministic(pomdp.obsdict[s-1] + 1)
end

## Reward 
POMDPs.reward(pomdp::Crypt4, s::Int) = 1.0
POMDPs.reward(pomdp::Crypt4, s, a, sp) = reward(pomdp, s)
POMDPs.reward(pomdp::Crypt4, s, a) = reward(pomdp, s)
POMDPs.discount(pomdp::Crypt4) = 0.999