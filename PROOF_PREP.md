# CHMM Paper, Proof-Prep Summary

Last updated 2026-05-01 by automated review pass against arXiv:2603.10202 (the prior Hybrid-HMM paper by the same first author).

This document is the single-page brief a non-specialist reviewer can read before opening the PDF. It records (a) what the paper claims, (b) how that compares to the precursor Hybrid-HMM paper, (c) the acronym key, (d) the test menu and what each number means, (e) the model's position in the existing literature, (f) the pre-arXiv cleanup checklist, and (g) the two analysis pipelines and the data timeline that feeds them. Section refs use the section-file basenames in `sections/`.

---

## 1. arXiv-Readiness Verdict

**Status: ready** with a short pre-submission punch list (see Section 7).

Build evidence: 112-page PDF, clean compile, zero undefined references or labels, zero `[CITE]/[TBD]/TODO` placeholders, 102 figure PDFs all 1-to-1 mapped to `\includegraphics`, 64 tables, 1 theorem with full proof, 4 propositions, 2 assumptions. Reproducibility scaffold complete: deterministic seed root 20260420 with documented sub-seed rule, Julia ≥ 1.12 with pinned `Manifest.toml`, R 4.6 + `renv` lockfile for the MSGARCH reference, public companion repos linked in the conclusion.

Two prose em-dash violations were patched during this review (sensitivity\_appendix.tex lines 185, 1002). Remaining LaTeX warnings (8 overfull hboxes, 19 `[h]→[ht]` automatic float promotions, hyperref bookmark-charset notes) are cosmetic and not arXiv-blocking.

---

## 2. Comparison vs. arXiv:2603.10202 (Alswaidan and Varner, "Hybrid HMM")

The Hybrid-HMM paper is the precursor on the same problem (synthetic generation of US-equity returns under stylized-fact constraints). Where it sits relative to the present work:

| Axis | Hybrid-HMM (2603.10202) | CHMM (this paper) |
|---|---|---|
| State construction | Discretized Laplace quantiles, Poisson jump-duration | Continuous emissions, four families (Gaussian, Student-t, Laplace, GED) |
| Estimator | Direct transition counting (bypasses Baum-Welch) | Full EM/ECM via Baum-Welch forward-backward |
| Universe | 424 US equities, 10 years daily | SPY 2014-2026, 30-ticker sector panel, 60-ticker n=6 expansion, 6-asset copula, CRSP cross-decade 1994-2006, GLD/SLV stress |
| Stylized facts | Heavy tails, low linear ACF, persistent vol clustering | Same three symmetric Cont (2001) facts; explicit out-of-scope statement on leverage and gain-loss asymmetry |
| Volatility-clustering parity | Inferior to GARCH(1,1) | On par with GARCH(1,1) on the absolute-return ACF axis at moderate K |
| Distribution-test parity | Below GARCH on tail tests | KS / AD pass rates documented panel-wide; HSMM ML matches or slightly exceeds CHMM on raw distributional fidelity, with the gap quantified |
| Risk back-test | Not run | Christoffersen joint conditional-coverage VaR test; six-fold rolling-origin walk-forward; quarterly-refit deployment recipe |
| Theoretical contribution | Empirical | Spectral mechanism: the textbook bilinear-ACF identity is recast as an effective-rank statement on the deflated transition matrix, with proof in supplementary |
| Code | Not specified in abstract | Two public repos (CHMM-paper, CHMM-Model), Julia and R reproducer with seed control |

Where the present paper is **strictly stronger**: estimator is principled (likelihood-monotone EM/ECM rather than counting), the spectral identity provides a falsifiable rank diagnostic that explains the Rydén low-K failure, and the risk-management story (conditional-VaR coverage, refit-cadence sweep) is a new dimension absent from the precursor. Reproducibility scaffolding is more explicit (deterministic seed tree, two-language replication).

Where the precursor is **broader**: 424-asset universe vs. 30-60 ticker panel here. The present paper trades breadth for depth (more tests, formal theory, conditional-VaR coverage, periodic-refit recipe). This is the intended positioning, stated in the abstract: "structural use cases (regime-conditional VaR, copula composition, parametric privacy) where multi-state regime-switching is required."

**Net assessment: the present paper is at least as good and arguably stronger on methodology and risk management; the precursor remains stronger on cross-sectional breadth.** The two are complementary rather than competing.

---

## 3. Acronym Key

Listed in approximate order of first use. Every acronym in the paper.

**Models and emission families.** CHMM continuous hidden Markov model. CHMM-N, CHMM-t, CHMM-L, CHMM-GED Gaussian, Student-t, Laplace, generalized-error-distribution emission variants. HMM hidden Markov model. HSMM hidden semi-Markov model. SM-CHMM Viterbi-AR(1) plug-in semi-Markov foil. GARCH generalized autoregressive conditional heteroskedasticity. EGARCH exponential GARCH. GJR-GARCH Glosten-Jagannathan-Runkle GARCH. MS-GARCH (also MSGARCH) Markov-switching GARCH. MSSV Markov-switching stochastic volatility. MSM Markov-switching multifractal. SV stochastic volatility. JD jump diffusion. HAR-RV heterogeneous autoregressive realized variance. SIM single-index model. GAN generative adversarial network. WGAN Wasserstein GAN. TCN temporal convolutional network.

**Estimation.** EM expectation maximization. ECM expectation conditional maximization. CM conditional maximization. MLE maximum likelihood estimator. BIC, AIC, HQC, CAIC standard information criteria. NW Newey-West. HAC heteroskedasticity and autocorrelation consistent.

**Statistical tests.** KS Kolmogorov-Smirnov. AD Anderson-Darling. LR likelihood ratio. LR\_uc, LR\_ind, LR\_cc unconditional, independence, conditional-coverage variants. DQ Engle-Manganelli dynamic-quantile. DM Diebold-Mariano. CRPS continuous ranked probability score. ANOVA analysis of variance. FDR false-discovery rate. BH Benjamini-Hochberg.

**Risk metrics.** VaR value at risk. ES expected shortfall.

**Data and series.** ACF autocorrelation function. MAE mean absolute error. MAD mean absolute deviation. CDF, PDF, PMF distribution / density / mass functions. RV realized variance. IS in-sample. OoS out-of-sample. CV cross-validation. CI confidence interval. IQR interquartile range.

**Universes / instruments.** SPY SPDR S\&P 500 ETF. QQQ Invesco Nasdaq-100 ETF. GLD SPDR Gold Trust. SLV iShares Silver Trust. NVDA, JNJ, JPM, AAPL, MSFT, etc. listed equities. ETF exchange-traded fund. GICS Global Industry Classification Standard. CRSP Center for Research in Security Prices. IEX Investors Exchange.

**Software.** SDK software development kit. API application programming interface. PSD positive semidefinite. OLS ordinary least squares. TikZ LaTeX graphics package.

---

## 4. Statistical Tests, in One Paragraph Each

**Kolmogorov-Smirnov (KS)** measures the maximum gap between the empirical CDF of simulated returns and the empirical CDF of observed returns; small gap means the simulator reproduces the marginal distribution. The paper reports both asymptotic critical values and stationary-block-bootstrap recalibrated values at block lengths L ∈ {5, 10, 20}, with both IS-anchored and OoS-anchored variants. Numbers like "OoS KS pass rate = 73%" mean 73% of tickers in the panel cleared the per-ticker null at α = 0.05.

**Anderson-Darling (AD)** is a tail-weighted analogue of KS; it gives more credit to matching the tails. Run alongside KS as a robustness check.

**Kupiec LR\_uc** is the canonical VaR back-test: count violations (days where the realized loss exceeded the predicted VaR), and ask whether the observed violation rate matches the nominal coverage (e.g., 1% for VaR\_99). LR\_uc is asymptotically chi-squared with 1 degree of freedom; the paper also reports an exact-binomial complement so reviewers can see both finite- and asymptotic-sample answers.

**Christoffersen LR\_ind, LR\_cc** ask whether VaR violations are independent in time (LR\_ind) and jointly whether coverage and independence both hold (LR\_cc, the headline conditional-coverage statistic). A clustered-violations failure mode is one where unconditional coverage looks fine but the breaches arrive in batches, signaling a model that ignores time-varying risk.

**Engle-Manganelli Dynamic Quantile (DQ)** is a higher-power VaR back-test based on regressing the violation indicator on lagged information; chosen with 4 lags as the standard configuration. Used as a second-opinion at α = 0.01 because it can detect mis-specification that Christoffersen-cc misses on small breach counts.

**Diebold-Mariano (DM)** compares predictive accuracy of two forecasters on the same series; here applied to CRPS losses with a Newey-West HAC variance estimator under the Bartlett kernel. Bandwidth-sweep robustness is reported because DM is famously sensitive to bandwidth choice.

**Ljung-Box (LB)** tests joint autocorrelation at multiple lags. The paper cites LB\_G ≈ 5.5 (linear ACF, near-zero, expected for daily equity returns) and LB\_|G| = 2,959.3 (absolute-return ACF, large, the "volatility-clustering smoking gun").

**Jarque-Bera** tests joint skewness-and-kurtosis normality; cited in the descriptive-statistics block alongside the heavy-tail evidence.

**One-way ANOVA by GICS sector**, both parametric F and 5,000-replicate permutation. Tests whether OoS KS varies systematically by sector. The paper reports F(9, 50) = 0.37, p = 0.946, η² = 0.062 on the n = 6 expansion, so the no-sector-effect null is not rejected at adequate power.

**Wilks profile-LL CI plus parametric bootstrap CI** for the Student-t copula's degrees-of-freedom parameter ν★. Both methods are reported because Wilks is asymptotic and the bootstrap is finite-sample; agreement between them is the headline.

**Stationary block bootstrap (Politis-Romano 1994)** is the resampling scheme used for kurtosis CIs and KS recalibration; preserves serial dependence, which i.i.d. bootstrap destroys.

**BH-FDR at 0.05** controls false-discovery rate across the 40-test conditional-coverage panel; the paper applies it because running 40 individual α = 0.05 tests would expect ~2 spurious rejections.

---

## 5. What the Numbers Mean

The headline numerical claims and what they encode for a reviewer skimming the abstract.

- **Three symmetric Cont (2001) stylized facts reproduced.** (a) Heavy-tailed marginal distribution: kurtosis CIs cover or exceed the empirical SPY value; the simulator is not Gaussian. (b) Negligible linear ACF: the lag-1 autocorrelation of returns is near zero, matching efficient-market behavior. (c) Slow |G\_t| ACF decay: the autocorrelation of absolute returns decays slowly (volatility clustering). The paper says CHMM matches GARCH(1,1) on (c), the historical bar that simple HMMs fail.

- **Spectral effective-rank claim.** At K = 18 on SPY the dominant transition-matrix mode carries 93.6% of the deflated trace. Cross-ticker median is 0.756. This is the falsifiable, mathematical version of the Rydén low-K failure: a K-state HMM cannot reproduce slow ACF decay if the effective rank of its deflated transition matrix is 1; CHMM at K ≥ 3 has effective rank > 1 on the cross-ticker median. This is the paper's principal theoretical contribution.

- **Christoffersen-cc passes on the headline window** at the conventional α = 0.05 (regime-conditional VaR, propagating one-step-ahead state forecasts through the predictive mixture). Six-fold rolling-origin walk-forward: pass on the bulk, rejections concentrated on out-of-distribution stress folds (W2, W4 mid-COVID and 2022 inflation regime introductions). The paper says periodic refit (quarterly cadence) is the deployment recipe, with the refit-cadence sweep table backing the recommendation.

- **Non-equity stress test (GLD, SLV) collapses under static fitting.** This is reported as a negative result; it is the boundary of the headline claim. The static-fit collapse is documented and discussed; periodic refit is again the proposed remedy.

- **HSMM ML matches or slightly exceeds CHMM on raw distributional fidelity.** This is the positioning sentence: CHMM does not claim distributional dominance. The paper's proposition is that CHMM is preferable when the downstream use case is regime-conditional VaR, copula composition, or parametric privacy, all of which require state semantics that an HSMM with non-geometric sojourns does not naturally provide.

---

## 6. Position vs. Existing Models, and Why It Is Worth Working On

**Where the field stands.** Daily equity return generation is a 30-year-old problem with three strong lineages: GARCH-family (Bollerslev 1986; Nelson 1991; Glosten-Jagannathan-Runkle 1993; Engle 1982; Bollerslev 1987), regime-switching variants (Hamilton 1989; Haas-Mittnik-Paolella 2004 MS-GARCH; Calvet-Fisher 2004 MSM; So 1998 / Carvalho-Lopes 2007 MSSV), and deep generative methods (Wiese et al. 2020 QuantGAN; Yoon 2019 TimeGAN; Rasul 2021 autoregressive diffusion). Hidden Markov models in particular have a known low-K failure (Rydén, Teräsvirta, Åsbrink 1998) on the absolute-return ACF axis.

**Existing weaknesses the paper addresses.**
- HMMs are routinely dismissed for stylized-fact reproduction because of the Rydén K=2 result. The paper recasts that failure as an effective-rank statement and shows the rank constraint is non-binding at K ≥ 3 for the cross-ticker median; HMMs are not architecturally limited, they were limited by misspecified low K.
- GARCH-family and deep generative methods do not produce semantically interpretable latent states. CHMM does. This is the structural-use-case argument: regime-conditional VaR, copula composition, parametric privacy guarantees, scenario stress-testing.
- The unified ECM scaffold across four emission families with identical forward-backward recursions is a methodological contribution: only the M-step changes between families, so practitioners can swap distributional assumptions without re-implementing the algorithm.
- The risk-management evaluation (Christoffersen-cc, DQ, walk-forward refit cadence) is more rigorous than the typical generative-model evaluation, which stops at marginal-distribution KS.

**Why it is worth working on.**
- Synthetic financial data is in active demand for backtesting, stress testing, and privacy-preserving data sharing under regulatory constraints. The structural-use-case framing maps onto deployment problems regulators and risk desks actually face.
- The spectral identity is a genuine theoretical result with a clean proof; it sharpens what the field thought it knew about HMM expressiveness.
- The reproducer is fully open: two public repos (CHMM-paper, CHMM-Model), Julia ≥ 1.12 + R 4.6, deterministic seed tree, R `renv` lockfile, CRSP slice for an out-of-decade independence test. Other groups can pick this up and extend it without reimplementation cost.

---

## 7. Cleanup Checklist (pre-arXiv tarball)

Findings from the cleanup audit, ordered by impact.

### CHMM-Model repo
1. **Drop the `Alpaca` dependency from `Project.toml`** after deleting the two probe scripts (`run_probe_alpaca_history.jl`, `run_fetch_spy_independent_decade.jl`). `Alpaca` is a non-registered git-URL dep and the most likely cause of `Pkg.instantiate()` failures for outside readers. Single highest-leverage change.
2. **Delete `_attic_v10/data/`** (~298 MB of pre-final-split snapshots; superseded by `data/CHMM-SP500-Train-10yr.jld2` and `data/CHMM-SP500-OoS-Remainder.jld2`).
3. **Delete `_attic_v10/runners/`** (9 archived `track_*.jl` scripts; zero references from active code).
4. **Delete `_attic_v10/docs/`** (planning notes, downloaded references; not part of public release).
5. **Gitignore raw OHLC bundles** (`data/SP500-Daily-OHLC-*.jld2`, ~99 MB) plus `data/external/` (regenerated by `build_new_train_oos.jl`).
6. **Prune dead K-variant runners** identified in the audit:
   - Sector panel: `run_sector_panel_k3.jl`, `run_sector_panel_k6.jl`, `run_sector_panel_monthly_refit.jl` (outputs not cited).
   - K-selection: `run_k_selection_validation.jl`, `run_k_selection_validation_pre2020.jl` (superseded by k-fold variants).
   - VaR: `run_christoffersen_var.jl`, `run_conditional_var.jl` (superseded by `_all_families` and `_power` variants).
   - Walk-forward: `run_walkforward_oos.jl`, `run_walkforward_conditional_var.jl` (superseded by W7 + refit-cadence).
   - Copula: `run_cross_asset_rolling_copula.jl`, `run_full_tcopula_mle.jl` (outputs not cited).
   - KS bootstrap: `run_ks_block_bootstrap.jl`, `run_ks_block_body_kstar.jl` (only `_oos` cited).
   - MS-GARCH: `run_msgarch_higher_k.jl` (uncited).
   - Misc: `run_chmm_t_penalised_headline.jl`, `run_t_singular_values.jl`, `run_per_ticker_lambda_sweep.jl`, `run_kstar3_headline.jl`, `run_garch_suite.jl`, `run_nu_shrinkage_sweep.jl`.
7. **Archive (move to `_attic_v10/runners/`)**: `regen_var_es_fig.jl`, `run_copula_profile_ci.jl`, `run_crps_dm.jl`, `run_crps_extra_rows.jl`, `run_ged_bracket_sensitivity.jl`, `run_ged_robustness.jl`, `run_hsmm_ml.jl`, `run_multiseed_headline.jl`.
8. Rough disk savings: ~400 MB; rough script-count reduction: 80 → ~40-45 active.

### CHMM-paper repo
1. **Delete `figs/_attic/`** (15 superseded PDFs, ~700 KB, zero references).
2. **Delete the working-tree `.DS_Store`** (already gitignored, but the file is on disk).
3. **Decide policy on `results/robustness/`**: 21 of 27 CSVs have no LaTeX reference. Suggested split: keep in the public repo as a data archive, exclude from the arXiv tarball.
4. Run `make clean` before tarballing for arXiv (drops local `.aux/.bbl/.log/.out`; they are gitignored, but if you copy the working tree, they ship).
5. No `.tex` cleanup needed: all 17 section files are wired into the build via `\input`.

### Pre-submission punch list
- [x] Two prose em-dash violations (sensitivity\_appendix.tex 185, 1002) replaced with semicolons.
- [ ] Optional: tighten the four largest overfull hboxes in sensitivity\_appendix.tex (lines ~1111, 1378, 1454, 1484, 1510) by widening `\resizebox` tables or switching to `tabularx`. Cosmetic; not arXiv-blocking.
- [ ] Optional: replace `\begin{table}[h]` with `\begin{table}[!ht]` on the 19 tables that triggered the auto-promotion warning. Cosmetic.
- [ ] Optional: `\texorpdfstring{...}{...}` wrappers on math-heavy section titles to silence hyperref bookmark-charset warnings. Cosmetic.
- [ ] Verify `figs/_attic/` removal (and the `_attic_v10/` removal in the model repo) does not break any `\includegraphics` paths via a final `make` build.
- [ ] Add the two repo links and the seed-root statement to the arXiv abstract page if they are not already in the version uploaded.

---

## 8. Analysis Pipelines and Data Timeline

The paper does provide reproducible end-to-end pipelines. Earlier drafts of this brief understated this; correction below. The empirical study is organised along **two named pipelines**, both defined in `model.tex` line 9 and diagrammed in `algorithms_appendix.tex:366` (`\label{sec:supp_pipeline_schematic}`, Fig.~`fig:pipeline_schematic`). The single-asset CHMM scaffold is shared across both. The driver `CHMM-Model/run_full_rebuild.jl` chains them end-to-end (stages 3 and 4 of the rebuild dispatcher).

### 8.1 Pipeline A, single-asset (no cross-asset coupling)

**What it does.** Fit one CHMM per ticker, independently; simulate; score per-asset metrics (KS, AD, kurtosis, |G_t| ACF-MAE, raw-return ACF-MAE, Wasserstein-1, Hellinger, quantile-envelope coverage, CRPS); also drives the regime-conditional VaR back-test in `var_backtest.tex` (state filter on a single ticker).

**Owning runners (CHMM-Model).**
- `run_baselines_and_cross_asset.jl`: headline single-window panel, six-generator comparison on SPY (Table~2, `tab:model_comparison`); per-ticker emission-family panel (Table~T2).
- `run_multi_emission_analysis.jl`: K-sweep across $\{3, 6, 9, 12, 15, 18, 21\}$ for all four emission families on SPY; produces Table~T1 and per-(K, family) figures.
- `run_all_analysis.jl`: SPY-only K-sweep, stylized-fact figures, per-K internals.
- `run_sector_panel.jl`, `run_sector_panel_n6.jl`, `run_sector_panel_quarterly_refit.jl`: 30- and 60-ticker sector panels with quarterly-refit recipe.
- `run_walkforward_w7.jl`, `run_walkforward_cond_var_refit_cadence.jl`: rolling-origin walk-forward folds W1..W7, refit-cadence sweep.
- `run_christoffersen_power.jl`, `run_conditional_var_all_families.jl`, `run_engle_manganelli_dq.jl`, `run_exact_binomial_kupiec.jl`, `run_quarterly_refit_conditional_var.jl`: VaR back-test (Christoffersen LR_uc / LR_ind / LR_cc, DQ, exact-binomial Kupiec, quarterly-refit variant).
- `run_cross_decade_validation.jl`: 1994-2004 IS / 2004-2006 OoS CRSP cross-decade rebuild at $K^\star = 3$ and $K = 18$.
- `run_non_equity_validation.jl`: GLD / SLV stress test on the same body windows.
- `run_chmm_t_shared_nu.jl`: shared-$\nu$ Student-$t$ ablation row.
- Baseline rows used in the same Table~2 panel: `run_msgarch_baselines.jl` (in-house Nelder-Mead MS-GARCH K=2/3), `run_msgarch_reference.jl` (R + RCall, CRAN MSGARCH 2.51, K=2/3/4), `run_smchmm_baseline.jl` (SM-CHMM Viterbi-AR(1) plug-in foil), `run_hsmm_ml_gamma.jl` / `run_hsmm_ml_intermediate_K.jl` (HSMM-N ML reference), `run_quantgan_baseline.jl` (in-house WGAN, deferred follow-up), `run_sv_msm_jd_baselines.jl`, `run_mssv_baseline.jl`, `run_leverage_effect.jl`.

**Paper sections that depend on Pipeline~A.** `results.tex` §descriptive--§cross_asset_univariate, `var_backtest.tex`, `walkforward_body_table.tex`, plus the bulk of `sensitivity_appendix.tex`, `baselines_appendix.tex`, and `metrics_appendix.tex`.

### 8.2 Pipeline B, cross-asset dependence

**What it does.** Reuse the per-asset CHMM-N marginals from Pipeline~A, then inject cross-asset dependence through a rank-based copula. Sklar's-theorem rank reordering preserves each fitted CHMM marginal exactly while coupling the asset ranks to the copula sample (Iman-Conover 1982). Profile MLE selects the Student-$t$ copula degrees-of-freedom $\nu^\star = 6$ on the body universe.

**Owning runners (CHMM-Model).**
- `run_cross_asset_sim_copula.jl`: body Pipeline~B at $K = 18$, six-asset US-equity universe (SPY, NVDA, JNJ, JPM, AAPL, QQQ), produces Table~T3 (`tab:cross_asset`) and Fig.~7.
- `run_cross_asset_sim_copula_k6.jl`: $K^\star = 6$ marginals sensitivity rebuild.
- `run_copula_profile_ci_halfunit.jl`: half-unit-grid refinement and parametric-bootstrap CI on $\nu^\star$.
- `run_non_us_asset.jl`: GLD / SLV non-equity stress test under the cross-asset construction.

**Comparators inside Pipeline~B.** Single Index Model with SPY as the market factor; Gaussian copula on CHMM marginals; truncated level-1 C-vine with edge-wise AIC family selection; full one-shot $(\Sigma, \nu)$ MLE used as a robustness check on the Kendall's-$\tau$ two-step estimator.

**Paper sections that depend on Pipeline~B.** `results.tex` §cross_asset, `model.tex` §cross_asset_methods, `cross_asset_appendix.tex`.

### 8.3 Data timeline (single source of truth)

The IS / OoS split is built by `CHMM-Model/build_new_train_oos.jl`. The 10-year boundary is anchored on AAPL's first continuous trading day (2014-01-03) plus 10 years; the OoS slice is everything after that boundary through 2026-04-20. Tickers are kept only if they have a full AAPL-matched coverage. The split is reproducible from the two raw OHLC bundles in `data/`.

| Slice | Window | Trading days | Universe | Source | Used by |
|---|---|---|---|---|---|
| **Body IS (training)** | 2014-01-03 to 2024-01-02 | 2,516 | SPY headline; 6-ticker copula universe (SPY, NVDA, JNJ, JPM, AAPL, QQQ); 30-ticker sector panel ($10$ GICS $\times 3$); 60-ticker $n = 6$ expansion | Polygon.io / Alpaca / IEX, packed into `data/CHMM-SP500-Train-10yr.jld2` | Both pipelines, all body tables |
| **Body OoS (held-out)** | 2024-01-04 to 2026-04-20 | 573 (572 in some panels) | Same universes as IS | `data/CHMM-SP500-OoS-Remainder.jld2` | Both pipelines, all OoS columns |
| **K-selection pre-2020 slice** | est.\ 2014-01 to 2018-06; val.\ 2018-07 to 2019-12 | sub-slice of body IS | SPY | Carved from body IS by `run_k_selection_kfold_pre2020.jl` | Pipeline A, K-selection (pre-2020 to avoid COVID leakage) |
| **Walk-forward folds W1..W7** | rolling 5y train + 1y test, body window | 7 folds | SPY | Carved from body IS+OoS by `run_walkforward_w7.jl` and friends | Pipeline A; W2 = COVID, W4 = 2022 rate-hike, W7 = 2017--2018 + 2019 trade-war |
| **Quarterly refit window** | every 63 trading days, rolling | varies | SPY (univariate) and 6-asset (Pipeline B) | `run_quarterly_refit_conditional_var.jl`, `run_sector_panel_quarterly_refit.jl` | Both pipelines, deployment recipe |
| **Cross-decade IS / OoS (CRSP)** | IS 1994-01-03 to 2004-01-02 (~2520); OoS 2004-01-05 to 2006-04-28 (~585) | ~3,100 | SPY plus 28 of the 30 sector-panel tickers (NEE and APD missing from CRSP query) | WRDS day-pass, `data/external/crsp_1994_2006.csv` | Pipeline A, cross-decade independence test (`run_cross_decade_validation.jl`) |
| **Non-equity stress** | same as body windows | 2,516 IS / 573 OoS | GLD, SLV | Same Polygon/Alpaca bundles | Both pipelines, scope-boundary test |
| **Independent-decade fetch (probe)** | not yet in paper | -- | -- | `data/independent_decade/fetch_log.txt` (probe artefact, slated for cleanup) | None; flagged for removal |

**Returns convention.** Annualised excess log returns $G_t = (1/\Delta t) \ln(P_t / P_{t-1}) - r_f$, with $\Delta t = 1/252$ and $r_f = 0$. Prices are session VWAP (`model.tex:9`).

### 8.4 End-to-end reproducer

```bash
julia --project=. -e 'using Pkg; Pkg.instantiate()'
julia --project=. build_new_train_oos.jl    # rebuilds the IS / OoS JLD2 split
julia --project=. run_full_rebuild.jl       # chains both pipelines + figures
```

`run_full_rebuild.jl` runs `run_all_analysis.jl` → `run_multi_emission_analysis.jl` → `run_baselines_and_cross_asset.jl` (Pipeline A core) → `run_cross_asset_sim_copula.jl` (Pipeline B core) → diagnostics, MS-GARCH baselines, SM-CHMM baseline, figures. QuantGAN is excluded by default (slowest stage, deterministic at the global seed) and is run standalone when the row needs refreshing. The MS-GARCH reference row additionally requires `R >= 4.2` and a one-time `Rscript r_msgarch/setup.R`; everything else runs with Julia alone.

---

## 9. CHMM-GED variant (memory note)

A fourth emission family, per-state GED with state-specific shape parameter $p_k$, is implemented and validated in the model repo (multiseed and cross-ticker), but is not yet in the paper. Decision pending whether to fold it into the published manuscript or hold for a follow-up. If folded in, the natural insertion point is the multi-emission K-sweep tables in `sensitivity_appendix.tex` and a new row in the headline `tab:model_comparison`.
