# Julia
All code for this project is written in Julia v1.8.
The language can be downloaded [here](https://julialang.org/).

# Initialization

Before running any benchmarks, ensure that the package is instantiated.

` julia `

` using Pkg`

` Pkg.activate("examples") `

` Pkg.precompile() `

# Running the models

The following models are available: crpyt4, drone-4-1, drone-4-2, gridavoid4, gridavoid10, gridavoid20, nrp8, refuel06, refuel08, refuel20, rocks12

To run all the benchmarks, run the bash script

` ./benchmark.sh `

You can also run each model benchmark separately. For example, to run nrp8, run

` julia examples/run_nrp8.jl `

The results logs for each benchmark can be found in the original_results folder.

# Comparison algorithms

To reproduce results for SARSOP, run benchmark_sarsop.sh.

To reproduce results for STORM, PAYNT, SAYNT, and Overapp use the [toolbox artifact](https://doi.org/10.5281/zenodo.7874513) from the SAYNT paper. The experiment.py config is available in /original_results/config/experiments.py.

To reproduce the results for PRISM, use the [PRISM Model Checker](https://www.prismmodelchecker.org/download.php).