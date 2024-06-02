#=
Super Blind GridWorld
The robot has a uninformative measurement of its position until reaching bad or goal state
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


const dir = Dict(:up=>GWPos(0,1), :down=>GWPos(0,-1), :left=>GWPos(-1,0), :right=>GWPos(1,0))
const aind = Dict(:up=>1, :down=>2, :left=>3, :right=>4)


function inbounds(m::SimpleGridWorld, s::AbstractVector{Int})
    return 1 <= s[1] <= m.size[1] && 1 <= s[2] <= m.size[2]
end

function POMDPs.transition(mdp::SimpleGridWorld, s::AbstractVector{Int}, a::Symbol)
    if s in mdp.terminate_from || isterminal(mdp, s) || s == GWPos(2,2)
        return Deterministic(GWPos(-1,-1))
    end

    destinations = MVector{2, GWPos}(undef)
    probs = @MVector(zeros(2))

    destinations[1] = s
    dest = s + dir[a]
    destinations[2] = dest
    if !inbounds(mdp, dest) 
        probs[1] = 1.0
        probs[2] = 0.0
        destinations[2] = GWPos(-1, -1)
    else
        probs[1] = 1.0 - mdp.tprob
        probs[2] = mdp.tprob
    end
    return SparseCat(convert(SVector, destinations), convert(SVector, probs))
end

@with_kw struct SuperBlindGridWorld <: POMDP{GWPos, Symbol, Int} #GWPos/Bool
    size::Tuple{Int64, Int64} = (10,10)
    exit::GWPos = GWPos(10,1)
    simple_gw::SimpleGridWorld = SimpleGridWorld(size=size, rewards=Dict(exit=>1.0), terminate_from=Set([exit]))
end

## States 

POMDPs.states(pomdp::SuperBlindGridWorld) = states(pomdp.simple_gw)
POMDPs.stateindex(pomdp::SuperBlindGridWorld, s::AbstractVector{Int}) = stateindex(pomdp.simple_gw, s)
# POMDPs.initialstate(pomdp::SuperBlindGridWorld) = uniform_belief(pomdp)

function POMDPs.initialstate(pomdp::SuperBlindGridWorld)

    probs = Vector{Float64}(undef, 17)
    i = 1
    for (s_idx, s) ∈ enumerate(states(pomdp))
        if (s == GWPos(-1, -1) || s == GWPos(4, 1) || s == GWPos(2,2))
            probs[i] = 0.0
        else
            probs[i] = 1/14
        end
        i += 1
    end
    return DiscreteBelief(pomdp, probs)
end 

POMDPs.actions(pomdp::SuperBlindGridWorld) = actions(pomdp.simple_gw)
POMDPs.actionindex(pomdp::SuperBlindGridWorld, a::Symbol) = actionindex(pomdp.simple_gw, a)

## Transition

POMDPs.isterminal(m::SuperBlindGridWorld, s::AbstractVector{Int}) = (s == m.exit || s == GWPos(-1,-1) || s == GWPos(2, 2))
POMDPs.transition(pomdp::SuperBlindGridWorld, s::AbstractVector{Int}, a::Symbol) = transition(pomdp.simple_gw, s, a)

## Observation 

POMDPs.observations(pomdp::SuperBlindGridWorld) = (1,2,3)
POMDPs.obsindex(::SuperBlindGridWorld, o::Int) = o
function POMDPs.initialobs(pomdp::SuperBlindGridWorld, s) 
    return 1
end

function POMDPs.observation(pomdp::SuperBlindGridWorld, a::Symbol, sp::AbstractVector{Int})
    if sp == GWPos(10,1)
        return Deterministic(3)
    end
    if sp == GWPos(2,2) || sp == GWPos(3,3) || sp == GWPos(4,4)
        return Deterministic(2)
    end
    return Deterministic(1)
end

## Reward 
POMDPs.reward(pomdp::SuperBlindGridWorld, s::GWPos) = reward(pomdp.simple_gw, s)
POMDPs.reward(pomdp::SuperBlindGridWorld, s, a, sp) = reward(pomdp.simple_gw, s)
POMDPs.reward(pomdp::SuperBlindGridWorld, s, a) = reward(pomdp.simple_gw, s)
POMDPs.discount(pomdp::SuperBlindGridWorld) = 1.0

function deterministic_belief(pomdp, s)
    b = zeros(length(states(pomdp)))
    si = stateindex(pomdp, s)
    b[si] = 1.0
    return DiscreteBelief(pomdp, b)
end

function POMDPs.isterminal(pomdp::ProductPOMDP, b::DiscreteBelief)
    belief_support = states(policy.problem)[findall(b.b .> 0)]
    for s in belief_support
        if !isterminal(pomdp, s)
            return false 
        end
    end
    return true
end

## Rendering 

function POMDPModelTools.render(pomdp::SuperBlindGridWorld, step::Union{NamedTuple, Dict})
    return POMDPModelTools.render(pomdp.simple_gw, step)
end

function POMDPModels.tocolor(r::Float64, minr=0., maxr=1.0)
    frac = (r-minr)/(maxr-minr)
    return get(ColorSchemes.redgreensplit, frac)
end

function POMDPModels.render(mdp::SimpleGridWorld, step::Union{NamedTuple,Dict};
                valuecolor = s -> reward(mdp, s),
                value = nothing,
                action = nothing,
                landmark = nothing,
                minr = 0.,
                maxr = 1.0,
               )

    nx, ny = mdp.size
    cells = []
    vals = []
    acts = []
    landmarks = []
    for x in 1:nx, y in 1:ny
        clr = valuecolor !== nothing ? POMDPModels.tocolor(valuecolor(GWPos(x,y)), minr, maxr) : RGB(1.0,1.0,1.0)
        ctx = POMDPModels.cell_ctx((x,y), mdp.size)
        cell = compose(ctx, rectangle(), fill(clr))
        if value !== nothing
            val = compose(ctx, text(0.5,0.5, round(value(GWPos(x,y)), digits=3), hcenter, vcenter))
            push!(vals, val)
        end
        
        if action !== nothing 
            act = actionarrow(ctx, action(GWPos(x,y)))
            push!(acts, act)
        end

        if landmark !== nothing 
            if landmark(GWPos(x,y))#haskey(landmark, GWPos(x,y))
                txt = string(LABELLED_STATES[GWPos(x,y)])
                push!(landmarks, compose(ctx, text(0.5, 0.5, txt, hcenter, vcenter)))
            end
        end

        push!(cells, cell)
    end
    vals = compose(context(), vals...)
    acts = compose(context(), acts...)
    landmarks = compose(context(), landmarks...)
    grid = compose(context(), linewidth(1Compose.mm), stroke("gray"), cells...)
    outline = compose(context(), linewidth(1Compose.mm), rectangle())

    if haskey(step, :s)
        agent_ctx = POMDPModels.cell_ctx(step[:s], mdp.size)
        agent = compose(agent_ctx, circle(0.5, 0.5, 0.4), fill("orange"))
        if haskey(step, :a)
            agent = compose(agent, actionarrow(agent_ctx, step[:a]))
        end 
    else
        agent = nothing
    end
    
    sz = min(w,h)
    gw_ctx = context((w-sz)/2, (h-sz)/2, sz, sz)
    if value !== nothing
        gw_ctx = compose(gw_ctx, vals)
    end
    if action !== nothing 
        gw_ctx = compose(gw_ctx, acts)
    end
    if landmark !== nothing 
        gw_ctx = compose(gw_ctx, landmarks)
    end
    return compose(gw_ctx, agent, grid)
end

function actionarrow(ctx, act::Symbol)
    if act == :up 
        return compose(ctx, line([(0.5,0.5), (0.5, 0.35)]), stroke(["gray"]), arrow())
    elseif act == :down
        return compose(ctx, line([(0.5,0.5), (0.5, 0.65)]), stroke(["gray"]), arrow())
                        
    elseif act == :right
        return compose(ctx, line([(0.5,0.5), (0.65, 0.5)]), stroke(["gray"]), arrow())
                      
    elseif act == :left 
        return compose(ctx, line([(0.5,0.5), (0.35, 0.5)]), stroke(["gray"]), arrow())            
    end
end

function highlight_goodstates(ctx, mdp::SimpleGridWorld, states::Vector{GWPos})
    goodstates = []
    for s in states
        x, y = s
        cctx = POMDPModels.cell_ctx((x,y), mdp.size)
        push!(goodstates, compose(cctx, circle(), fill("purple")))
    end
    goodstates = compose(context(), goodstates...)
    compose(goodstates, ctx)
end
