# Continuous Hidden Markov Model with Jump-Diffusion for Equity Excess Growth Rate Dynamics

This repository contains the code, data pipeline, and figure-generation scripts for the paper:

> **Alswaidan A, Varner JD.** *Continuous Hidden Markov Models with Poisson Jump Processes for Financial Time Series.* Cornell University, 2026. *(In preparation)*

## Overview
This work extends the discrete HMM framework in [Alswaidan & Varner (2026)](https://arxiv.org/abs/2603.10202) to **continuous Gaussian emissions** learned via the **Baum-Welch (Expectation-Maximization) algorithm**, eliminating the quantization error inherent in Laplace quantile binning. The Poisson jump-duration mechanism is preserved to enforce realistic tail-state dwell times and partially reproduce volatility clustering.

### Key Contributions
- **Baum-Welch training** of emission means, variances, and transition probabilities directly from continuous observations
- **Quantile-based EM initialization** to avoid degenerate local optima
- **State resolution analysis** across K = {3, 6, 9, 11, 13} hidden states
- **Comprehensive validation** using KS/AD pass rates, Wasserstein-1, Hellinger distances, and ACF-MAE

## Repository Structure

```
.
|-- README.md
|-- code/
|   |-- spy-experiment/
|   |   |-- Include.jl              # Entry point (loads dependencies + src)
|   |   |-- Project.toml            # Julia dependencies
|   |   |-- src/                    # Core model code
|   |   |   |-- Types.jl
|   |   |   |-- Files.jl
|   |   |   |-- Factory.jl
|   |   |   |-- Compute.jl
|   |   |   |-- Visualize.jl
|   |   |-- run_all_analysis.jl     # Full pipeline: trains + validates K={3,6,9,11,13}
|   |   |-- data/                   # Training/test datasets (JLD2)
|   |   |-- figs/                   # Pre-generated figures from analysis
|   |   |-- results/                # Full results organized by K
|   |   |   |-- SPY/
|   |   |       |-- stylized_facts/ # Figure 1, Table 1
|   |   |       |-- K3/             # All figures + metrics for K=3
|   |   |       |-- K6/
|   |   |       |-- K9/
|   |   |       |-- K11/
|   |   |       |-- K13/
|   |   |       |-- Table-T1-State-Resolution-Sensitivity.txt
|-- paper/
|   |-- sections/
|   |   |-- figs/                   # Paper-ready figures (PDF)
```

## Reproducing Results

### Prerequisites
- Julia 1.9+ (tested on 1.11.4 and 1.12.5)
- All dependencies are managed via `Project.toml`

### Quick Start

```bash
cd code/spy-experiment
julia --project=. -e 'using Pkg; Pkg.instantiate()'
julia --project=. run_all_analysis.jl
```

This runs the full analysis pipeline for K = {3, 6, 9, 11, 13} states:
1. Trains continuous Gaussian HMMs via Baum-Welch
2. Performs grid search over jump parameters (epsilon, lambda)
3. Simulates 1,000 paths per model (NJ and WJ variants)
4. Computes validation metrics (KS, AD, Wasserstein-1, Hellinger, ACF-MAE)
5. Generates all figures (SVG + PDF)

### Output
Results are saved to `results/SPY/K{N}/` with:
- 11 figures per K value (convergence, emissions, transition matrix, ACF, validation, etc.)
- `Metrics.txt` with full IS/OoS validation table
- `Emission-Parameters.txt` with learned regime parameters

## Related Repositories
- [JumpHMM.jl](https://github.com/varnerlab/JumpHMM.jl) -- Core model package (discrete HMM)
- [HMM-w-jumps-paper](https://github.com/varnerlab/HMM-w-jumps-paper) -- Discrete paper repository (arXiv:2603.10202)
- [ContinuousJumpHMM (WIP)](https://github.com/altashly1/HMM-withJumps-WIP) -- Development repository

## Citation
```bibtex
@article{alswaidan2026continuous,
  title={Continuous Hidden Markov Models with Poisson Jump Processes for Financial Time Series},
  author={Alswaidan, Abdulrahman and Varner, Jeffrey D.},
  year={2026},
  note={In preparation}
}
```

## Disclaimer
This project is intended **for research and educational purposes only**. It does **not** constitute financial advice, investment recommendations, or trading strategies. The models and simulations are simplified representations of financial markets. Users are solely responsible for any decisions made using this code.

## License
MIT License. See [LICENSE](LICENSE) for details.
