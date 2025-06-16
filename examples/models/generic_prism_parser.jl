"""
    parse_generic_prism_file(filename::String)

Parses a PRISM explicit model file into generic data structures.

This function reads a .prism file with headers (pomdp, module, etc.) and
extracts the transition model, observation function, variable declarations,
and any defined labels. It is designed to be general and not specific
to any particular model.
"""
function parse_generic_prism_file(filename::String)
    # Regex patterns to parse different parts of the file
    var_decl_regex = r"^\s*(\w+)\s*:\s*\[0\.\.(\d+)\]\s*init\s*(\d+);"
    transition_line_regex = r"\[(\w+)\]\s*s=(\d+)\s*->\s*(.*);"
    label_line_regex = r"label\s*\"(\w+)\"\s*=\s*(.*);"
    label_state_regex = r"s=(\d+)"

    # --- START: MORE ROBUST OUTCOME REGEXES ---
    # Captures the probability and the content inside the parentheses separately
    main_outcome_regex = r"([\d\.]+)\s*:\s*\((.*)\)"
    s_prime_regex = r"s'=(\d+)"
    o_prime_regex = r"o'=(\d+)"
    # --- END: MORE ROBUST OUTCOME REGEXES ---

    # Data structures to populate
    transitions = Dict{Tuple{Int, Int}, SparseCat{Vector{Int}, Vector{Float64}}}()
    observations = Dict{Int, Int}()
    labels = Dict{String, Set{Int}}()
    action_map = Dict{String, Int}()
    metadata = Dict{String, Any}()

    max_s_seen = -1
    max_o_seen = -1
    initial_s = -1
    initial_o = -1

    open(filename, "r") do file
        for (line_num, line) in enumerate(eachline(file))
            m_var = match(var_decl_regex, line)
            if m_var !== nothing
                var_name, max_val_str, init_val_str = m_var.captures
                max_val = parse(Int, max_val_str)
                init_val = parse(Int, init_val_str)
                if var_name == "s"
                    metadata["num_states"] = max_val + 1
                    initial_s = init_val
                elseif var_name == "o"
                    metadata["num_obs"] = max_val + 1
                    initial_o = init_val
                end
                continue
            end

            m_trans = match(transition_line_regex, line)
            if m_trans !== nothing
                action_name, s_str, updates_str = m_trans.captures
                s = parse(Int, s_str)

                if !haskey(action_map, action_name)
                    action_map[action_name] = length(action_map) + 1
                end
                action_idx = action_map[action_name]

                next_states = Int[]
                probabilities = Float64[]
                
                outcome_strings = split(updates_str, r"\s*\+\s*")

                for outcome_str in outcome_strings
                    # --- START: NEW PARSING LOGIC ---
                    m_main = match(main_outcome_regex, outcome_str)
                    if m_main === nothing
                        @warn "L$line_num: Failed to parse main outcome structure in: `$outcome_str`"
                        continue
                    end

                    prob_str, content_str = m_main.captures
                    
                    m_s = match(s_prime_regex, content_str)
                    m_o = match(o_prime_regex, content_str)

                    if m_s === nothing || m_o === nothing
                        @warn "L$line_num: Failed to find s' or o' within `($content_str)`"
                        continue
                    end

                    p = parse(Float64, prob_str)
                    sp = parse(Int, m_s[1])
                    o = parse(Int, m_o[1])
                    # --- END: NEW PARSING LOGIC ---

                    push!(next_states, sp)
                    push!(probabilities, p)
                    observations[sp] = o
                    
                    max_s_seen = max(max_s_seen, s, sp)
                    max_o_seen = max(max_o_seen, o)
                end

                if !isempty(probabilities) && !isapprox(sum(probabilities), 1.0)
                    @warn "L$line_num: Probabilities for s=$s, a=$action_name do not sum to 1.0: $(sum(probabilities))"
                end

                transitions[(s, action_idx)] = SparseCat(next_states, probabilities)
                continue
            end

            m_label = match(label_line_regex, line)
            if m_label !== nothing
                label_name, states_str = m_label.captures
                state_set = Set{Int}()
                for m_state in eachmatch(label_state_regex, states_str)
                    push!(state_set, parse(Int, m_state[1]))
                end
                labels[label_name] = state_set
            end
        end
    end

    metadata["action_map"] = action_map
    metadata["num_actions"] = length(action_map)
    metadata["initial_state"] = initial_s

    if !haskey(metadata, "num_states")
        metadata["num_states"] = max_s_seen + 1
    end
    if !haskey(metadata, "num_obs")
        metadata["num_obs"] = max_o_seen + 1
    end

    if initial_s != -1 && initial_o != -1
        observations[initial_s] = initial_o
    end

    return transitions, observations, labels, action_map, metadata
end