# v7 Rebuild — Complete and Verified

**Date:** 2026-04-21
**Paper:** `Paper_v7.pdf` (52 pages, 3.33 MB)

## Pipeline execution

All **8 pipeline stages** ran successfully against the new training / OoS split:

- New training dataset: `data/CHMM-SP500-Train-10yr.jld2`
- New OoS dataset: `data/CHMM-SP500-OoS-Remainder.jld2`

Driver script: `run_v7_full_rebuild.jl`

| # | Stage | Runtime | Status |
|---|---|---|---|
| 1 | `run_all_analysis.jl` | 100.3 s | ok |
| 2 | `run_multi_emission_analysis.jl` | 201.1 s | ok |
| 3 | `run_baselines_and_cross_asset.jl` | 260.6 s | ok |
| 4 | `run_cross_asset_sim_copula.jl` | 15.5 s | ok |
| 5 | `run_v7_revisions.jl` | 185.1 s | ok |
| 6 | `run_v7_gru.jl` | 299.4 s | ok |
| 7 | `run_v7_vix.jl` | 88.2 s | ok |
| 8 | `run_v7_figures.jl` | re-run standalone | ok |

## Window changes

| Window | Before (v6/early v7) | After (current v7) |
|---|---|---|
| IS period | 2014-01-03 → 2024-12-31 | 2014-01-03 → 2024-01-03 |
| IS length (T) | 2,766 | **2,516** |
| OoS period | 2025-01-03 → 2025-11-18 | 2024-01-04 → 2026-04-20 |
| OoS length (T) | 219 | **572** (2.6×) |
| Ticker universe | 424 | **413** (AAPL-matched) |
| IS kurtosis (observed) | 7.71 | 7.68 |
| OoS kurtosis (observed) | 6.24 | 5.29 |

## Tables refreshed

| Table | What changed |
|---|---|
| Table 1 (descriptive) | IS T=2516, OoS T=572; IS kurt 7.68, OoS 5.29; LB raw OoS now rejects |
| Table 2 (main 12-model) | All 12 rows — GRU, Block-BS, Bin-T NJ, Discrete NJ/WJ, GARCH, CHMM-N/t/L |
| Table T1 (K-sweep CHMM-N) | Full sweep; K=21 now top OoS KS performer (86.6%) |
| Table T1-multi (K × family) | All 21 rows refreshed |
| Table T2 (cross-asset 6-ticker × 3-family) | All 18 rows — notable: NVDA OoS KS 55.8%, JPM 49.8% |
| Table SIM/copula | Mean IS KS: SIM 72.1, Gauss 97.5, Student-t 96.2 |
| Table SIM regression | β and R² updated to new fits |
| Table VaR/ES | All rows with new IS/OoS observed and simulated values |
| Table ν-bracket sensitivity | All 5 rows with new numbers |
| Table Rydén K=2 | All 6 rows with new numbers |
| Table KS power | 100% known-correct, 90.0% nearly-correct |
| Table walk-forward | JPM recovery now +15 pp (strongest stationarity evidence) |
| Table block-bootstrap | Both rows refreshed |
| Table bin-T NJ | Both rows refreshed |
| Table GRU | IS KS 18.1%, OoS 52.5%, final NLL 0.200 |
| Table VIX | Unchanged (VIX dataset was not extended) |

## Key new numbers

### SPY main body
- **CHMM-N @ K=18**: IS KS **94.7%**, OoS KS **84.0%**, ACF-MAE **0.0513**, kurt 5.02 IS / 4.42 OoS
- **CHMM-t @ K=18**: IS KS 94.7%, OoS KS 83.4%, kurt **17.34** IS / **10.24** OoS (larger overshoot than v6)
- **CHMM-L @ K=18**: IS KS **95.2%** (top), IS AD **93.2%**, kurt 6.76 IS / 6.27 OoS (closest to observed)
- **GARCH(1,1)**: IS KS 23.1%, ACF-MAE 0.0492
- **GRU baseline**: IS KS 18.1%, ACF-MAE 0.0518 (reproduces clustering, fails distributional)
- **Discrete NJ/WJ**: now correctly rejected OoS at 36-38% (was inflated to 85-88% in v6)

### Cross-asset (univariate CHMM-N)
- **SPY**: 95.5% IS / 81.4% OoS
- **NVDA**: 96.7% IS / **55.8% OoS** (2024–2026 AI-driven regime)
- **JNJ**: 99.4% / 93.9%
- **JPM**: 97.8% / **49.8% OoS**, walk-forward recovers to 64.3% (+15 pp)
- **AAPL**: 98.3% / 93.8%
- **QQQ**: 95.5% / 92.3%

### Cross-asset (SIM / copulas, 6-asset universe)
- SIM: mean IS KS 72.1%, median 78.5%
- Gaussian copula: mean IS KS 97.5%, median 97.8%
- Student-t copula (ν\*=6): mean IS KS 96.2%, median 96.0%
- Correlation off-diag MAE: SIM 0.076, Gauss 0.031, Student-t 0.027 (best)

### CHMM-t ν_k diagnostics
- 13 of 18 states at upper bracket (ν=50)
- Only 2 states near lower bracket: ν_2 = 2.19, ν_4 = 2.10
- Bracket sensitivity: raising ν_min from 2.1 → 4.0 does **not** reduce overshoot (kurt stays 12.3–15.1)

### VaR / Expected Shortfall back-test
- Observed IS VaR_0.01 = −6.38, ES_0.01 = −9.00
- All three CHMM variants bracket observed within 5–95% envelopes on both IS and OoS
- CHMM-N median VaR_0.01 = −6.64 (closest to observed)
- CHMM-t widens the envelope but does not systematically overstate risk

### KS-test power calibration
- Known-correct generator (T=572): 100%
- Nearly-correct (IS bootstrap at T=572): 90.0%
- Misspecified Gaussian (T=2516): 0% (correctly rejected)
- CHMM OoS rates (80–84%) sit just below 90% ceiling — genuine fidelity, not low-power artefact

### Copula profile log-likelihood
- ν* = 6 at log-L = 6157.47
- Smooth single-peaked curve; neighbors ν=5 and ν=8 within 15 log-likelihood units

### Walk-forward (quarterly CHMM-N refit)
- JNJ: 94.0 → 94.9 OoS KS (+0.9 pp)
- JPM: **49.0 → 64.3 OoS KS (+15.3 pp)** — strong stationarity evidence

### VIX (unchanged from earlier v7)
- CHMM-N: IS KS 99.5%, OoS KS 99.0%, kurt 4.03 (observed 6.56)
- CHMM-t: overshoots kurt to 12.59
- CHMM-L: closest kurt match at 5.42
- ACF-MAE on |R_t|: 0.018 (about 3× tighter than SPY)

## Figures regenerated

- **Main body at K=18** with 10pt sub-panel titles + explicit colorbars on heatmaps:
  - `Fig-3-IS-Comparison-K18.pdf`
  - `Fig-4-OoS-Validation-K18.pdf`
  - `Fig-Emission-PDFs-K18.pdf`
  - `Fig-Transition-Matrix-K18.pdf`
- **Per-family variants** at K=18: `{Fig-3, Fig-4, Fig-Transition-Matrix}-K18-{N,t,L}.pdf`
- **K-sweep panels** (K ∈ {3, 6, 9, 12, 15, 18, 21}): `{Fig-Convergence, Fig-Emission, Fig-Transition, Fig-Stationary, Fig-Residence, Fig-Trajectory}`
- **v7-specific**: `Fig-v7-nu-Histogram.pdf`, `Fig-v7-VaR-ES.pdf`, `Fig-v7-Copula-Profile.pdf`
- **Cross-asset**: `Fig-Cross-Asset-Correlation.pdf`, `Fig-Cross-Asset-KS-Dist.pdf`

## Final compile status

- `Paper_v7.pdf`: 52 pages, 3.33 MB
- Bibliography: 6 new entries resolved (`abantovalle2017svm`, `angbekaert2002regime`, `baekimmulvey2014`, `yoon2019timegan`, `innes2018flux`, `politis1994stationary`)
- No undefined references
- No undefined citations
- No LaTeX errors

## Reproducibility

All revision experiments use deterministic seed `V7_SEED = 20260420`. The full rebuild is re-runnable via:

```julia
julia --project=. run_v7_full_rebuild.jl
```

Per-experiment entry points:

- `run_all_analysis.jl` — stylized facts, per-K figures
- `run_multi_emission_analysis.jl` — K × family sensitivity
- `run_baselines_and_cross_asset.jl` — main Table 2 + cross-asset
- `run_cross_asset_sim_copula.jl` — SIM + Gaussian/Student-t copulas
- `run_v7_revisions.jl` — VaR/ES, ν diagnostics, KS power, Rydén, walk-forward, copula profile, block bootstrap, bin-T
- `run_v7_gru.jl` — GRU deep-generative baseline
- `run_v7_vix.jl` — VIX three-family panel
- `run_v7_figures.jl` — main-body K=18 figures

## Data pipeline

- `fetch_oos_extended.jl` — pulls daily Alpaca bars (2025-11-19 → 2026-04-20) for all existing OoS tickers + VXX, merges with existing OoS frame, writes extended JLD2
- `build_new_train_oos.jl` — combines 2014–2024 + extended OoS, uses AAPL as reference ticker, splits first 10 trading years as training and the remainder as OoS, retains only tickers with AAPL-matched coverage
