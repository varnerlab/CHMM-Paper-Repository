# Code

This directory contains all scripts to reproduce the results in the paper.

## Experiments

### `spy-experiment/`
Main analysis pipeline. Trains continuous Gaussian HMMs via Baum-Welch for K = {3, 6, 9, 11, 13} states on SPY daily excess growth rates (2014-2024), performs jump hyperparameter grid search, simulates 1,000 paths per model, and evaluates against 5 complementary quality metrics.

**Run:**
```bash
cd spy-experiment
julia --project=. -e 'using Pkg; Pkg.instantiate()'
julia --project=. run_all_analysis.jl
```

## Source Code (`spy-experiment/src/`)

| File | Purpose |
|------|---------|
| `Types.jl` | Abstract and concrete model type definitions |
| `Files.jl` | JLD2 data loading utilities |
| `Factory.jl` | Model constructors (`build` methods for all HMM variants) |
| `Compute.jl` | Baum-Welch algorithm, simulation, excess growth rate calculations |
| `Visualize.jl` | ACF comparison plotting |
