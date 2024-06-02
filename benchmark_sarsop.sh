#!/bin/bash

julia examples/run_gridavoid4_sarsop.jl > results/sarsop/grid-4/logs.txt
julia examples/run_gridavoid20_sarsop.jl > results/sarsop/grid-20/logs.txt
julia examples/run_refuel06_sarsop.jl > results/sarsop/refuel-06/logs.txt
julia examples/run_refuel08_sarsop.jl > results/sarsop/refuel-08/logs.txt