using POMDPTools

function parse_prism_file(filename)

    actionpattern = r"\[.*\]"
    statepattern = r"s=(\d+)"
    nextstatepattern = r"s'=(\d+)"
    nextobspattern = r"o'=(\d+)"
    my_observations = Dict{Int, Int}()
    my_transitions = Dict{Tuple{Int, Int}, Vector{Int}}()

    act0 = Dict{Int, Vector{Int}}()
    act1 = Dict{Int, Vector{Int}}()
    act2 = Dict{Int, Vector{Int}}()
    act3 = Dict{Int, Vector{Int}}()

    open(filename, "r") do file
        for line in eachline(file)
            #find action
            m = match(actionpattern, line)
            if m === nothing
                # @show line, nothing
                continue
            end

            act = parse(Int, m.match[end-1]) + 1

            #find state

            m = match(statepattern, line)
            if m !== nothing
                s = parse(Int, m[1])
            end

            if s == 125
                @show line
            end

            #find next state

            spvec = []
            m = match(r"1.0 :.*", line) #only one next state
            if m !== nothing
                if s == 125
                    @show line
                end
                sp = match(nextstatepattern, line)
                obs = match(nextobspattern, line)
                push!(spvec, parse(Int, sp[1]))
                my_observations[parse(Int, sp[1])] = parse(Int, obs[1])
            end
            m = match(r"0.7 :.* \+", line) # 0.7 came first
            if m !== nothing
                if s == 125
                    @show line
                end
                state_matches = [match.match[4:end] for match in eachmatch(nextstatepattern, line)]
                obs_matches = [match.match[4:end] for match in eachmatch(nextobspattern, line)]
                push!(spvec, parse(Int, state_matches[1]))
                push!(spvec, parse(Int, state_matches[2]))
                my_observations[parse(Int, state_matches[1])] = parse(Int, obs_matches[1])
                my_observations[parse(Int, state_matches[2])] = parse(Int, obs_matches[2])
            end
            m = match(r"0.3 :.* \+", line) # 0.3 came first
            if m !== nothing
                if s == 125
                    @show line
                end
                state_matches = [match.match[4:end] for match in eachmatch(nextstatepattern, line)]
                obs_matches = [match.match[4:end] for match in eachmatch(nextobspattern, line)]
                push!(spvec, parse(Int, state_matches[2]))
                push!(spvec, parse(Int, state_matches[1]))
                my_observations[parse(Int, state_matches[1])] = parse(Int, obs_matches[1])
                my_observations[parse(Int, state_matches[2])] = parse(Int, obs_matches[2])
            end

            my_transitions[(s, act)] = spvec
            if (act == 1)
                act0[s] = spvec
            elseif (act == 2)
                act1[s] = spvec
            elseif (act == 3)
                act2[s] = spvec
            elseif (act == 4)
                act3[s] = spvec
            end
        end
    end
    return my_observations, my_transitions, act0, act1, act2, act3
end
function find_different_pairs(dict1, dict2)
    different_pairs = Dict()

    # Check keys in the first dictionary
    for (key, value1) in dict1
        if haskey(dict2, key)
            value2 = dict2[key]
            if value1 != value2
                different_pairs[key] = (value1, value2)
            end
        else
            different_pairs[key] = (value1, nothing)
        end
    end

    # Check keys in the second dictionary that are not in the first
    for (key, value2) in dict2
        if !haskey(dict1, key)
            different_pairs[key] = (nothing, value2)
        end
    end

    return different_pairs
end

function find_label(filename, string)
    stringset = Set{Int}()
    open(filename, "r") do file
        for line in eachline(file)
            #find action
            m = match(string, line)
            if m !== nothing
                state_matches = [match.match for match in eachmatch(r"s=(\d+)", line)]
                for state in state_matches
                    push!(stringset, parse(Int, state[3:end]))
                end
            end
        end
    end
    return stringset
end


function parse_prism_file_drone(filename)

    actionpattern = r"\[.*\]"
    statepattern = r"s=(\d+)"
    nextstatepattern = r"s'=(\d+)"
    nextobspattern = r"o'=(\d+)"
    my_observations = Dict{Int, Int}()
    my_transitions = Dict{Tuple{Int, Int}, Vector{Int}}()

    act0 = Dict{Int, Vector{Int}}()
    act1 = Dict{Int, Vector{Int}}()
    act2 = Dict{Int, Vector{Int}}()
    act3 = Dict{Int, Vector{Int}}()

    open(filename, "r") do file
        for line in eachline(file)
            allact = false
            #find action
            m = match(actionpattern, line)
            if m === nothing
                # @show line, nothing
                continue
            end

            act = parse(Int, m.match[end-1]) + 1

            #find state

            m = match(statepattern, line)
            if m !== nothing
                s = parse(Int, m[1])
            end

            #find next state

            spvec = []
            m = match(r"1.0 :.*", line) #only one next state
            if m !== nothing
                sp = match(nextstatepattern, line)
                obs = match(nextobspattern, line)
                push!(spvec, parse(Int, sp[1]))
                my_observations[parse(Int, sp[1])] = parse(Int, obs[1])
            end
            m = match(r"0.7 :.* \+", line) # 0.7 came first
            if m !== nothing
                state_matches = [match.match[4:end] for match in eachmatch(nextstatepattern, line)]
                obs_matches = [match.match[4:end] for match in eachmatch(nextobspattern, line)]
                push!(spvec, parse(Int, state_matches[1]))
                push!(spvec, parse(Int, state_matches[2]))
                my_observations[parse(Int, state_matches[1])] = parse(Int, obs_matches[1])
                my_observations[parse(Int, state_matches[2])] = parse(Int, obs_matches[2])
            end
            m = match(r"0.3 :.* \+", line) # 0.3 came first
            if m !== nothing
                state_matches = [match.match[4:end] for match in eachmatch(nextstatepattern, line)]
                obs_matches = [match.match[4:end] for match in eachmatch(nextobspattern, line)]
                push!(spvec, parse(Int, state_matches[2]))
                push!(spvec, parse(Int, state_matches[1]))
                my_observations[parse(Int, state_matches[1])] = parse(Int, obs_matches[1])
                my_observations[parse(Int, state_matches[2])] = parse(Int, obs_matches[2])
            end

            m = match(r"0.25 :.*", line) # other agent randomly moving in all 4 directions

            if m !== nothing
                prob_matches = [match.match for match in eachmatch(r"0\.(\d+)", line)]
                state_matches = [match.match[4:end] for match in eachmatch(nextstatepattern, line)]
                obs_matches = [match.match[4:end] for match in eachmatch(nextobspattern, line)]

                if length(state_matches) != 3 && length(state_matches) != 4
                    @show prob_matches
                    @show state_matches
                end
                allact = true
                if length(state_matches) == 4
                    push!(spvec, parse(Int, state_matches[1]))
                    push!(spvec, parse(Int, state_matches[2]))
                    push!(spvec, parse(Int, state_matches[3]))
                    push!(spvec, parse(Int, state_matches[4]))
                    my_observations[parse(Int, state_matches[1])] = parse(Int, obs_matches[1])
                    my_observations[parse(Int, state_matches[2])] = parse(Int, obs_matches[2])
                    my_observations[parse(Int, state_matches[3])] = parse(Int, obs_matches[3])
                    my_observations[parse(Int, state_matches[4])] = parse(Int, obs_matches[4])
                else
                    prob_matches = parse.(Float64, prob_matches)
                    for i in 1:3
                        if prob_matches[i] == 0.5
                            pushfirst!(spvec, parse(Int, state_matches[i]))
                        else
                            push!(spvec, parse(Int, state_matches[i]))
                        end
                        my_observations[parse(Int, state_matches[i])] = parse(Int, obs_matches[i])
                    end
                end
            end

            if allact
                act0[s] = spvec
                act1[s] = spvec
                act2[s] = spvec
                act3[s] = spvec
            else

                my_transitions[(s, act)] = spvec
                if (act == 1)
                    act0[s] = spvec
                elseif (act == 2)
                    act1[s] = spvec
                elseif (act == 3)
                    act2[s] = spvec
                elseif (act == 4)
                    act3[s] = spvec
                end
            end
        end
    end
    return my_observations, my_transitions, act0, act1, act2, act3
end

function parse_prism_file_gridavoid(filename)

    actionpattern = r"\[.*\]"
    statepattern = r"s=(\d+)"
    nextstatepattern = r"s'=(\d+)"
    nextobspattern = r"o'=(\d+)"
    my_observations = Dict{Int, Int}()
    my_transitions = Dict{Tuple{Int, Int}, Vector{Int}}()

    act0 = Dict{Int, Vector{Int}}()
    act1 = Dict{Int, Vector{Int}}()
    act2 = Dict{Int, Vector{Int}}()
    act3 = Dict{Int, Vector{Int}}()

    open(filename, "r") do file
        for line in eachline(file)
            #find action
            m = match(actionpattern, line)
            if m === nothing
                # @show line, nothing
                continue
            end

            act = parse(Int, m.match[end-1]) + 1

            #find state

            m = match(statepattern, line)
            if m !== nothing
                s = parse(Int, m[1])
            end

            #find next state

            spvec = []
            m = match(r"1.0 :.*", line) #only one next state
            if m !== nothing
                sp = match(nextstatepattern, line)
                obs = match(nextobspattern, line)
                push!(spvec, parse(Int, sp[1]))
                my_observations[parse(Int, sp[1])] = parse(Int, obs[1])
            end
            m = match(r"0.9 :.* \+", line) # 0.7 came first
            if m !== nothing
                state_matches = [match.match[4:end] for match in eachmatch(nextstatepattern, line)]
                obs_matches = [match.match[4:end] for match in eachmatch(nextobspattern, line)]
                push!(spvec, parse(Int, state_matches[1]))
                push!(spvec, parse(Int, state_matches[2]))
                my_observations[parse(Int, state_matches[1])] = parse(Int, obs_matches[1])
                my_observations[parse(Int, state_matches[2])] = parse(Int, obs_matches[2])
            end
            m = match(r"0.1 :.* \+", line) # 0.3 came first
            if m !== nothing
                state_matches = [match.match[4:end] for match in eachmatch(nextstatepattern, line)]
                obs_matches = [match.match[4:end] for match in eachmatch(nextobspattern, line)]
                push!(spvec, parse(Int, state_matches[2]))
                push!(spvec, parse(Int, state_matches[1]))
                my_observations[parse(Int, state_matches[1])] = parse(Int, obs_matches[1])
                my_observations[parse(Int, state_matches[2])] = parse(Int, obs_matches[2])
            end

            m = match(r"0.045454545454545456 :.*", line) # other agent randomly moving in all 4 directions

            if m !== nothing
                state_matches = [match.match[4:end] for match in eachmatch(nextstatepattern, line)]
                obs_matches = [match.match[4:end] for match in eachmatch(nextobspattern, line)]
                
                for i in 1:22
                    push!(spvec, parse(Int, state_matches[i]))
                    my_observations[parse(Int, state_matches[i])] = parse(Int, obs_matches[i])
                end
            end

            m = match(r"0.047619047619047616 :.*", line) # other agent randomly moving in all 4 directions

            if m !== nothing
                state_matches = [match.match[4:end] for match in eachmatch(nextstatepattern, line)]
                obs_matches = [match.match[4:end] for match in eachmatch(nextobspattern, line)]
                
                for i in 1:21
                    push!(spvec, parse(Int, state_matches[i]))
                    my_observations[parse(Int, state_matches[i])] = parse(Int, obs_matches[i])
                end
            end

            m = match(r"0.030303030303030304 :.*", line) # other agent randomly moving in all 4 directions

            if m !== nothing
                state_matches = [match.match[4:end] for match in eachmatch(nextstatepattern, line)]
                obs_matches = [match.match[4:end] for match in eachmatch(nextobspattern, line)]
                
                for i in 1:33
                    push!(spvec, parse(Int, state_matches[i]))
                    my_observations[parse(Int, state_matches[i])] = parse(Int, obs_matches[i])
                end
            end

            my_transitions[(s, act)] = spvec
            if (act == 1)
                act0[s] = spvec
            elseif (act == 2)
                act1[s] = spvec
            elseif (act == 3)
                act2[s] = spvec
            elseif (act == 4)
                act3[s] = spvec
            end
        end
    end
    return my_observations, my_transitions, act0, act1, act2, act3
end


function parse_prism_file_crypt4(filename)

    actionpattern = r"\[.*\]"
    statepattern = r"s=(\d+)"
    nextstatepattern = r"s'=(\d+)"
    nextobspattern = r"o'=(\d+)"
    my_observations = Dict{Int, Int}()
    my_transitions = Dict{Tuple{Int, Int}, Vector{Int}}()

    act0 = Dict{Int, Vector{Int}}()
    act1 = Dict{Int, Vector{Int}}()
    act2 = Dict{Int, Vector{Int}}()
    act3 = Dict{Int, Vector{Int}}()
    act4 = Dict{Int, Vector{Int}}()
    act5 = Dict{Int, Vector{Int}}()

    open(filename, "r") do file
        for line in eachline(file)
            #find action
            m = match(actionpattern, line)
            if m === nothing
                # @show line, nothing
                continue
            end

            act = parse(Int, m.match[end-1]) + 1

            #find state

            m = match(statepattern, line)
            if m !== nothing
                s = parse(Int, m[1])
            end

            #find next state

            spvec = []
            m = match(r"1.0 :.*", line) #only one next state
            if m !== nothing
                sp = match(nextstatepattern, line)
                obs = match(nextobspattern, line)
                push!(spvec, parse(Int, sp[1]))
                my_observations[parse(Int, sp[1])] = parse(Int, obs[1])
            end

            m = match(r"0.3333333333333333 :.*", line)

            if m !== nothing
                state_matches = [match.match[4:end] for match in eachmatch(nextstatepattern, line)]
                obs_matches = [match.match[4:end] for match in eachmatch(nextobspattern, line)]
                
                for i in 1:3
                    push!(spvec, parse(Int, state_matches[i]))
                    my_observations[parse(Int, state_matches[i])] = parse(Int, obs_matches[i])
                end
            end

            m = match(r"0.0625 :.*", line)

            if m !== nothing
                state_matches = [match.match[4:end] for match in eachmatch(nextstatepattern, line)]
                obs_matches = [match.match[4:end] for match in eachmatch(nextobspattern, line)]
                
                for i in 1:16
                    push!(spvec, parse(Int, state_matches[i]))
                    my_observations[parse(Int, state_matches[i])] = parse(Int, obs_matches[i])
                end
            end

            my_transitions[(s, act)] = spvec
            if (act == 1)
                act0[s] = spvec
            elseif (act == 2)
                act1[s] = spvec
            elseif (act == 3)
                act2[s] = spvec
            elseif (act == 4)
                act3[s] = spvec
            elseif (act == 5)
                act4[s] = spvec
            elseif (act == 6)
                act5[s] = spvec
            end
        end
    end
    return my_observations, my_transitions, act0, act1, act2, act3, act4, act5
end

function parse_prism_file_nrp8(filename)
    actionpattern = r"\[.*\]"
    statepattern = r"s=(\d+)"
    nextstatepattern = r"s'=(\d+)"
    nextobspattern = r"o'=(\d+)"
    my_observations = Dict{Int, Int}()
    my_transitions = Dict{Tuple{Int, Int}, Vector{Int}}()

    act0 = Dict{Int, Vector{Int}}()
    act1 = Dict{Int, Vector{Int}}()

    open(filename, "r") do file
        for line in eachline(file)
            #find action
            m = match(actionpattern, line)
            if m === nothing
                # @show line, nothing
                continue
            end

            act = parse(Int, m.match[end-1]) + 1

            #find state

            m = match(statepattern, line)
            if m !== nothing
                s = parse(Int, m[1])
            end

            #find next state

            spvec = []
            m = match(r"1.0 :.*", line) #only one next state
            if m !== nothing
                sp = match(nextstatepattern, line)
                obs = match(nextobspattern, line)
                push!(spvec, parse(Int, sp[1]))
                my_observations[parse(Int, sp[1])] = parse(Int, obs[1])
            end

            m = match(r"0.125 :.*", line)

            if m !== nothing
                state_matches = [match.match[4:end] for match in eachmatch(nextstatepattern, line)]
                obs_matches = [match.match[4:end] for match in eachmatch(nextobspattern, line)]
                
                for i in 1:8
                    push!(spvec, parse(Int, state_matches[i]))
                    my_observations[parse(Int, state_matches[i])] = parse(Int, obs_matches[i])
                end
            end

            my_transitions[(s, act)] = spvec
            if (act == 1)
                act0[s] = spvec
            elseif (act == 2)
                act1[s] = spvec
            end
        end
    end
    return my_observations, my_transitions, act0, act1
end

function parse_results(filename)

    totaltime = r"Total time"
    vlower = r"V_lower:\s*([-+]?\d*\.?\d+([eE][-+]?\d+)?)"
    vupper = r"V_upper:\s*([-+]?\d*\.?\d+([eE][-+]?\d+)?)"
    beliefsize = r"Belief Size:\s*(\d+)"
    Vlower = []
    Vupper = []
    belief_size = []

    open(filename, "r") do file
        for line in eachline(file)
            allact = false
            #find action
            m = match(totaltime, line)
            if m === nothing
                # @show line, nothing
                continue
            end
            if m !== nothing
                m = match(vlower, line)
                if m !== nothing
                    push!(Vlower, parse(Float64, m[1]))
                end
                m = match(vupper, line)
                if m !== nothing
                    push!(Vupper, parse(Float64, m[1]))
                end

                m = match(beliefsize, line)
                if m !== nothing
                    push!(belief_size, parse(Int, m[1]))
                end
            end
        end
    end
    return Vlower, Vupper, belief_size
end


# file_path = "test/refuel08_explicit.prism"
# find_label(file_path, r"notbad*.")


# my_observations, my_transitions, act0, act1, act2, act3 = parse_prism_file(file_path);