# CHMM Paper Revamp Plan: 20-Page Main Body

## Style alignment with Varner-lab publication pattern

Calibrated against Prof. Varner's recent publication record at `varnerlab.org/publications.html` and the most directly comparable lab paper, **MarketGPT** (Lou and Varner, arXiv:2411.16585, 2024):

| Reference | Length | Figures | Propositions | Style |
|---|---|---|---|---|
| MarketGPT (closest analog: financial time series, single-asset stylized-facts replication) | **13 pages** | **8** | 0 | Single primary claim |
| Hybrid HMM (predecessor, alswaidan2026hybrid, submitted to JDIQ) | similar single-claim positioning | — | 0 | Empirical-evaluation-centered |
| Validated Synthetic Patient Generation (npj Systems Biology) | submitted | — | software-centric | Julia-package deliverable paired with paper |
| ParetoEnsembles.jl, BSTModelKit.jl | tool papers | — | — | Software-centric |

What this implies for the CHMM paper:

1. **20 pages is the ceiling, not the target.** MarketGPT lands the same kind of single-asset stylized-facts story in 13. A 14-16 page main body is more in keeping with Varner's pattern than the original 20-page brief.
2. **Single primary claim, not three operational axes.** The current paper's "three-way operational split" (distributional fidelity / unconditional VaR / regime-conditional VaR) is the structural source of the bloat. Varner's lab papers in this space pick one claim and defend it. The cleanest single claim here: *moderate-K continuous HMM reproduces the three Cont stylized facts simultaneously inside a unified EM scaffold, and the spectral mechanism explains why*. The VaR work is supporting evidence, not a co-equal axis.
3. **Heavy on figures, light on tables.** MarketGPT runs 8 figures in 13 pages. The current draft is table-dominated (10+ tables in the main body). Convert metric tables into bar/violin figures wherever the comparison is visual; reserve tables for the headline 6-generator panel and the rolling-origin numbers.
4. **Theoretical propositions are not the lab's house style.** MarketGPT and the agent-based paper carry zero formal propositions. Rather than a theorem-corollary scaffold, integrate the spectral ACF identity as a derivation inside §5 (Spectral Mechanism) without `\begin{theorem}` blocks. Keep the formal statements only if a journal reviewer asks for them; relegate them to supplementary by default.
5. **Pair the paper with the Julia package as a co-equal deliverable.** Both `ParetoEnsembles.jl` and `BSTModelKit.jl` ship as standalone tool papers; the CHMM paper should treat `CHMM-Model` (after the cleanup in the next section) as the second deliverable rather than as a code drop hidden behind a footnote. Lead with `using CHMM` examples in the README, mirror the public API in §3, and cite the Julia package as a numbered reference.
6. **Stylized facts as the empirical anchor.** This is the through-line in MarketGPT, the agent-based paper, and the predecessor Hybrid HMM. The CHMM paper already has the right anchor; the bloat is from the secondary axes layered on top of it. Cutting back to "stylized facts + spectral mechanism + one VaR contrast against the discrete predecessor" puts the paper back in the lab's idiom.

These six points sharpen the cuts in the rest of the plan in the same direction, so I'll keep the structural targets the user asked for (20 pages with all the cuts) but flag the lab-style optimum as **14-16 pages** and adjust the figure/table mix accordingly.

## Diagnosis

The current paper sprawls across many axes. Best estimate of what is loaded into the manuscript right now:

- **3 emission families** (CHMM-N, CHMM-t, CHMM-L)
- **16+ baseline generators** in main + appendix tables: i.i.d. bootstrap, stationary block bootstrap, Gaussian i.i.d., Laplace i.i.d., Discrete NJ, Discrete WJ, Bin-T NJ (Kdisc=13), GARCH(1,1), GRU, QuantGAN, Window-Diffusion, MS-GARCH (K=2 and K=3), EGARCH, GJR-GARCH, GARCH-t, HAR-RV
- **2 pipelines** (single-asset Pipeline A, cross-asset Pipeline B with SIM + Gaussian/Student-t copulas, 6 tickers)
- **Semi-Markov ablation** with per-state Pareto/NB/Geometric sojourns (3 SM variants)
- **3 VaR constructions** (unconditional, smoother-Viterbi, filter-forward) with Kupiec + Christoffersen
- **A 7-metric distributional panel** (KS, AD, kurtosis, ACF-MAE, W1, Hellinger, quantile coverage), extended by **6 more axes** (MMD, Signature-MMD, discriminator AUC, leverage effect, aggregational Gaussianity, joint p-value coverage)
- **Rolling-origin OoS** (5 windows), **weekly-frequency** robustness, **OoS price-fan simulation** (terminal coverage, horizon coverage, CRPS), **TSTR HAR vol forecasting**, **walk-forward quarterly refits**
- **7+ propositions** (spectral ACF mixture, Ryden separation corollary, ECM monotonicity, identifiability, MLE consistency, rank-reordering marginal preservation, filter-VaR mixture-quantile inequality, discrete-VaR centroid floor)

Three problems flow from this:
1. **No single load-bearing claim** survives reader attention. Every section trades a finding for a caveat.
2. **The negative results are genuine but they obscure the positive headline.** The filter-VaR Kupiec failure, NVDA/JPM OoS cliff, K=18 vs K=3 likelihood-suboptimality flag, and CHMM-t kurtosis overshoot each take real estate to defend.
3. **Some of the loudest experiments are the weakest.** Pipeline B copula vs SIM is a known result. The SM ablation is a plug-in fit, not a principled MLE. Deep-generative QuantGAN/Diffusion are deliberate first-pass baselines. Expanded GARCH-t beats CHMM on ACF-MAE and Kupiec, threatening the headline if read carelessly.

## What to keep (true, primary, and defensible)

These claims I am confident about based on the underlying numbers in `sections/results.tex` and `sections/var_backtest.tex`:

1. **A continuous Gaussian HMM at moderate K reproduces the three Cont stylized facts simultaneously on SPY daily data.** IS KS 93.8%, OoS KS 84.2%, ACF-MAE 0.0507, kurtosis 5.0 vs observed 7.7. This is the headline fact.
2. **The slow absolute-return ACF mechanism is spectral.** ρ_|G|(τ) = Σ_{k≥2} w_k λ_k^τ over the non-unit eigenvalues of T. This recasts Ryden et al. as a K-rank statement: at K=2 a single eigenvalue forces the trade-off; at K≥3 it decouples. This is the genuine theoretical contribution.
3. **Quantile-based initialization is what makes Baum-Welch reach a non-degenerate K≥3 fit.** The K=2 replication shows ACF is fine even at K=2 with quantile init; KS is what requires moderate K.
4. **Heavy-tailed Student-t emissions close the residual kurtosis gap inside the same EM scaffold.** Same forward-backward; M-step swap only. CHMM-t lands the smallest MMD and the discriminator AUC closest to 0.5 in the panel.
5. **Honest stationarity scope.** The 2022 rolling-origin window is a structural break that the IS-fixed parameters cannot track. The paper's headline is single-window; rolling-origin shows 4/5 windows replicate it and 1/5 doesn't. This must stay because it's the most informative single piece of negative evidence.
6. **One sharp VaR result against the discrete predecessor.** Discrete NJ/WJ at K_disc=90 fail Kupiec at 5% with LR_uc=16.81 (breach rate 1.7% vs 5% target); all CHMM variants pass. Proposition (centroid floor) explains why structurally. This is the cleanest single-number contrast against the prior paper.

## What to cut (defer to companion papers or repo notes)

- **Cross-asset Pipeline B (SIM, Gaussian copula, Student-t copula).** Substantial, but it's a known ordering and not central to the synthetic-data-generator claim. Move to a follow-up paper or to a one-paragraph mention with table in supplementary materials.
- **Semi-Markov ablation in full.** Plug-in fit (Viterbi run-lengths + AIC family selection), not a principled SM-MLE. The risk-calibration gain is genuine but the marginal-fidelity trade-off is a wash. Cut to one paragraph noting the direction; defer detailed table to a companion paper.
- **Deep-generative baselines (GRU, QuantGAN, Window-Diffusion).** They are by-design first-pass reproducible negative controls. Either remove entirely or compress to one row in the main table. The paper is not making a deep-generative claim.
- **Expanded GARCH suite (EGARCH, GJR-GARCH, GARCH-t, HAR-RV, MS-GARCH K=3).** Keep one GARCH(1,1) as the parametric volatility benchmark. Push the rest to appendix.
- **Bin-T NJ.** Useful ablation but it confounds bin-count and emission family at the same time. The discrete NJ/WJ row is enough for the Kupiec contrast.
- **Block bootstrap (b=10).** A non-parametric ceiling that is not load-bearing. Keep only the i.i.d. bootstrap as the unconditional ceiling.
- **CHMM-L (Laplace emissions).** Closes the kurtosis gap cleanly but the central kurtosis story can be told with N (gap) → t (closes the gap, with overshoot diagnosis). Adding L is a third color in a story that needs two. Cut from main; mention as one sentence.
- **Filter-vs-Smoother regime-conditional VaR.** The negative finding is honest but it's a 1.5-page detour into a result that says "this isn't deployable yet." Move to a single paragraph in Discussion, with the proposition in appendix. The smoother diagnostic is an IS goodness-of-fit exercise that doesn't translate to operational claims.
- **OoS price-fan simulation (CRPS, terminal-band, horizon-coverage).** Adds a price-space dimension that requires its own metric definitions and tickers. Defer entirely.
- **TSTR HAR vol forecasting.** Defer entirely.
- **Weekly-frequency robustness.** Defer to appendix as a one-paragraph robustness note.
- **Walk-forward quarterly refit on NVDA/JPM.** Compress to a one-sentence acknowledgment that walk-forward partially closes the OoS cliff.
- **K=18 vs K=3 likelihood-validation table.** This admits the K=18 choice is contaminated. Either fix the choice (pick a clean validation-window K and rerun the whole panel) or compress to a footnote. Don't lead with both K=18 and "K=3 is what held-out log-lik picks" in the main body.
- **Penalized-ECM 1/ν shrinkage sweep.** Useful diagnostic for the kurtosis overshoot but takes a paragraph plus a table. Compress to two sentences ("an exponential 1/ν shrinkage at λ=20 brings simulated kurtosis from 14.30 to ≈8 with a 1pp KS cost").
- **6 of 7 propositions.** Keep only the spectral ACF theorem and the discrete-VaR centroid floor; the rest move to appendix as cited theorems with one-line proof sketches.

## Proposed structure (16-page target, 20-page ceiling)

Calibrated to MarketGPT-style length (13 pages, 8 figures, single-claim) but absorbing one extra integrative axis (cross-ticker generalization + VaR contrast against the discrete predecessor):

| Section | Pages | Contents |
|---|---|---|
| Abstract | 0.5 | One CHMM family (N + t), spectral ACF mechanism, single panel comparison, one VaR contrast against the discrete predecessor, stationarity-scope caveat |
| 1. Introduction | 1.5 | Stylized facts, Ryden limitation, the spectral resolution, our scope. Cut current scope to the single-asset return-space claim. |
| 2. Related Work | 1 | One paragraph each: GARCH, regime-switching/Ryden, HSMM/jump-augmented routes, deep-generative (one sentence). Drop the multi-paragraph theoretical-antecedents bookkeeping; drop copula paragraph entirely. |
| 3. Model | 1.5 | Data definition, CHMM definition, two emission variants (N as baseline, t as the heavy-tailed extension), one architecture figure. Drop the pipeline schematic. Lead with a snippet showing the public `CHMM-Model` Julia API. |
| 4. Estimation | 1 | EM scaffold, quantile initialization, ECM golden-section for ν_k. One convergence figure. |
| 5. Spectral ACF Mechanism | 1.5 | Mixture-of-eigenvalues identity ρ_\|G\|(τ) = Σ w_k λ_k^τ as a labeled equation with a one-paragraph derivation; the K-rank reading of the Ryden et al. failure as a corollary in prose. **No `\begin{theorem}` blocks** in the main body (Varner-lab idiom); relocate the formal proposition + proof to supplementary. |
| 6. Empirical Study | 5.5 | (6.1) Descriptive stats + K-selection (one figure: IC-min band + K-sweep KS/ACF curve, one paragraph of prose). (6.2) Single 6-generator comparison table: Bootstrap, Gaussian, Laplace, GARCH, Discrete NJ, CHMM-N, CHMM-t on 4 core metrics (IS/OoS KS, IS kurt, ACF-MAE). (6.3) Stylized-facts figure (3-panel: marginal density, ACF of \|G\|, Q-Q tail). (6.4) Cross-ticker generalization figure (bar plot, 5 tickers + SPY, CHMM-t IS/OoS KS). (6.5) Rolling-origin honest-scope figure (5-window LR_uc panel). |
| 7. VaR Calibration | 1.5 | (7.1) Unconditional Kupiec at 1% and 5%, single VaR/ES envelope figure. (7.2) Discrete-baseline Kupiec failure as a sharp one-number contrast, with the centroid-floor identity stated inline (proof in supplementary). (7.3) One paragraph noting filter-VaR over-conservatism as an open question for operational deployment. |
| 8. Discussion | 1 | Where the headline holds; where it doesn't (NVDA/JPM cliff; 2022 break; CHMM-t kurt overshoot; filter-VaR). |
| 9. Conclusion | 0.5 | Two sentences for the headline; three for limits; one for the future-work pointer. Cite `CHMM-Model.jl` as a co-deliverable. |
| References | 1 | |

**Target: 16 pages, 6-7 figures, 2-3 tables. Ceiling: 20 pages.**

The figure-to-table inversion versus the current draft is deliberate: the current draft has roughly 10 tables and 5 figures in the main body; the target has 6-7 figures and 2-3 tables, in line with MarketGPT's 8 figures over 13 pages.

## Concrete edits, by file

| File | Action |
|---|---|
| `paper.tex` | Drop title sub-clause "Extended Evaluation, Semi-Markov Ablation, and Regime-Conditional Value-at-Risk." Keep just the headline title. Remove `cross_asset_appendix.tex` and `baselines_appendix.tex` includes; collapse into a single `supplementary.tex`. |
| `sections/introduction.tex` | Cut from 41 lines to ~20. Remove the multi-paragraph mention of every metric, every benchmark, every proposition. Remove the cross-asset paragraph. Remove the conditional-VaR paragraph. Keep the spectral-mechanism positioning, the moderate-K story, and the two-emission scope statement. |
| `sections/related_work.tex` | Keep the four-paragraph structure but cut the long theoretical-antecedents enumeration (currently ~10 cited results) to one sentence. |
| `sections/model.tex` | Remove Pipeline B subsection. Remove all benchmarks except: Bootstrap, Gaussian i.i.d., Laplace i.i.d., GARCH(1,1), Discrete NJ. Drop Block-BS, Bin-T NJ, GRU, QuantGAN, Diffusion, MS-GARCH, Discrete WJ. Drop CHMM-L subsection. Remove the pipeline-schematic figure. |
| `sections/estimation.tex` | Largely keep; trim the K-selection subsection because it lives in Results. |
| `sections/theory.tex` | Cut from 622 lines to ~150. Keep Theorem `acf_mixture` and Corollary `ryden_separation`, plus Assumptions. Move identifiability, consistency, ECM monotonicity, rank-reordering, filter-VaR, and discrete-VaR-floor to a single supplementary section that just states each result with one-sentence proof sketches. |
| `sections/results.tex` | Cut from 657 lines to ~250. Drop: extended evaluation panel (MMD, Sig-MMD, AUC, leverage, agg kurtosis, joint pv); cross-asset univariate table; cross-asset SIM/copula table; rolling-origin window-by-window discussion (keep one row of headline numbers); weekly-frequency table; price-fan table; TSTR HAR vol-forecasting paragraph; Bin-T NJ paragraph; GRU paragraph; expanded GARCH-suite table; K-selection contamination subsection. |
| `sections/var_backtest.tex` | Cut from 225 lines to ~80. Keep: VaR/ES envelope table for the 6-generator panel; the discrete-baseline Kupiec failure paragraph; one paragraph each for filter-vs-smoother that lands the open-question framing. Drop: SM ablation in full; SM-conditional VaR; bootstrap MC band on Kupiec; bootstrap null for LR_ind. |
| `sections/discussion.tex` | Cut from 84 lines to ~50. Drop: three-way operational split paragraph (it is a defensive scaffold for the SM and filter-VaR results we are removing); ECM 1/ν shrinkage details; SM marginal-fidelity trade-off; cross-asset robustness paragraph. Keep: Ryden replication, OoS KS power, kurtosis-gap → t closure, NVDA/JPM stationarity, 2022 break. |
| `sections/conclusion.tex` | Cut from 43 lines to ~20. Drop the proposition-by-proposition recap paragraph and the cross-asset summary paragraph. |

## Decision points before drafting

These choices need explicit confirmation before we touch any prose:

1. **Two emission families (N + t) or one (just t)?** Recommend two: CHMM-N is the natural "Ryden replication with quantile init" baseline; CHMM-t is the heavy-tailed extension that earns the kurtosis story. Dropping N would conflate the moderate-K Gaussian claim with the Student-t-emission claim.
2. **How firm is the K=18 vs K=3 contamination concern?** If we keep K=18 as the operating point, we owe the reader either a clean re-selection on a non-OoS validation slice (and re-run all main tables there) or a one-paragraph footnote acknowledging the multi-metric nature of the choice. Recommend the footnote: a full re-run is multi-day work and the contamination is mild relative to the headline claims.
3. **Cross-asset cut (Pipeline B): zero mention or one paragraph?** Recommend one paragraph in Discussion plus a single supplementary table, citing the SIM-loses-to-copulas finding without the full panel.
4. **Filter-VaR negative finding: keep visible or push to limits?** Recommend one paragraph in Discussion plus the proposition in supplementary. It's an honest limit on operational deployment, but it's not the paper's contribution.
5. **Single-asset only (SPY) or 6-ticker?** Recommend 6 tickers for cross-asset robustness on Pipeline A only; this stays inside 20 pages with one table. The Pipeline B (SIM/copulas) layer is what we cut.

## Risk register

- **Length still creeps.** A 20-page main body with 6 tickers and a 5-window rolling-origin table can absorb 1-2 extra pages of figures fast. Budget 2 figures in main body, the rest in supplementary.
- **Reviewer asks "where is the deep-generative comparison?"** If GRU/QuantGAN/Diffusion are cut, we need one defensive sentence in Related Work that says deep-generative comparison is a separate axis we are not making claims on.
- **Removing CHMM-L undersells one strong result** (it has the cleanest IS kurtosis match). Mitigation: one footnote pointing readers to the supplementary that includes the L variant alongside N and t.
- **Removing the SM ablation undersells the only mechanism that closes Kupiec at 5% with margin.** Mitigation: the one-line acknowledgment that "an explicit-duration sojourn extension is the natural follow-up" plus a citation slot for the companion paper.

## Drafting order

If we go with this plan, the lowest-risk drafting order is:
1. Tighten introduction and related work to the new scope (cuts only).
2. Strip results.tex and var_backtest.tex to the 6-generator panel; verify the residual numbers are internally consistent before any new prose lands.
3. Trim theory.tex to the spectral mechanism + assumptions; move displaced propositions to supplementary.
4. Rewrite discussion.tex around the new headline.
5. Conclusion last.

Bibliography stays intact; cuts don't reduce the citation graph.

## CHMM-Model code repo: parallel cleanup

The companion `CHMM-Model` repo at `/Users/abdulrahmanalswaidan/Desktop/Project-Repos/CHMM-Model` has been built up alongside the paper's expansion and now carries 11 source files (~5K LOC) and 31 top-level `run_*.jl` scripts (~10K LOC). For the trimmed paper to be reproducible from the public code without dragging readers through the exploratory tracks, the repo needs a parallel scope cut. Mirror the paper structure exactly so a reader who runs `run_full_rebuild.jl` reproduces the 20-page main body and nothing else; the cut tracks live in a `legacy/` subtree they can opt into.

### `src/` triage

| File | Decision | Rationale |
|---|---|---|
| `Types.jl` | **Keep** | Core CHMM type definitions, used everywhere. |
| `Compute.jl` (1,344 lines) | **Keep, trim** | Baum-Welch, ECM, forward-backward, Viterbi. Audit for code paths that exist only to support cut tracks (filter-VaR mixture-quantile sampler, SM-aware decoder shims, skew-emission posterior). Move those to `legacy/`. |
| `Factory.jl` | **Keep, trim** | Model constructors. Drop `make_chmm_l` and skew-emission constructors if CHMM-L is cut from main; keep behind a feature flag if we keep it as a footnote. |
| `Metrics.jl` (531 lines) | **Keep, trim hard** | Currently implements all 13 metrics (KS, AD, kurtosis, ACF-MAE, W1, Hellinger, quantile coverage, MMD, Sig-MMD, discriminator AUC, leverage, agg kurtosis, joint pv). Keep KS, ACF-MAE, kurtosis, Kupiec/Christoffersen LR. Move MMD, Sig-MMD, AUC, leverage, agg kurtosis, joint pv to `legacy/extended_metrics.jl`. |
| `Visualize.jl` | **Keep** | Plotting. |
| `Files.jl` | **Keep** | I/O. |
| `GARCHFamily.jl` (336 lines) | **Cut to GARCH(1,1) only** | Currently implements GARCH(1,1), EGARCH, GJR-GARCH, GARCH-t, HAR-RV. The trimmed paper carries only one parametric volatility benchmark; rename to `GARCH.jl` with just the (1,1) Gaussian path. Move EGARCH/GJR/GARCH-t/HAR-RV to `legacy/`. |
| `MSGARCH.jl` (392 lines) | **Move to legacy** | MS-GARCH was the top-of-panel unconditional VaR row; if we cut the SM ablation and the unconditional-VaR sub-ranking from the main body, the variance-regime baseline goes with it. |
| `SemiMarkov.jl` (349 lines) | **Move to legacy** | Plug-in SM fit. Defer to companion paper. |
| `CrossAsset.jl` (597 lines) | **Move to legacy** | SIM, Gaussian copula, Student-t copula, rank-reordering. Pipeline B is cut. |
| `SkewEmissions.jl` (157 lines) | **Move to legacy** | Skew emissions ablation is cut from main body. |

After this cut, `src/` carries roughly 2,500 LOC across 6 files instead of 5,000 across 11. Compile times drop, the public surface in `Include.jl` shrinks, and the `Project.toml` may shed dependencies.

### `run_*.jl` script triage

The 31 run scripts split cleanly along the paper-section boundary. Rough mapping:

| Script | Paper home | Decision |
|---|---|---|
| `run_track_a_metrics.jl` (596) | §6 main panel | **Keep**, trim to the 6-generator panel and the 4-metric core. |
| `run_track_a_utility.jl` (382) | §7 VaR/ES envelope | **Keep**, trim. |
| `run_multi_emission_analysis.jl` (472) | §6 N+t (drop L) | **Keep**, restrict to N and t. |
| `run_k_selection_validation.jl` (283) | §6 K-selection | **Keep**. Optionally use the held-out validation slice as the primary K-selection (resolves the contamination issue) instead of the multi-metric IC + IS/OoS criterion. |
| `run_rolling_and_weekly.jl` (314) | §6.5 rolling-origin | **Keep rolling, cut weekly.** Split the script: `run_rolling_origin.jl` and `legacy/run_weekly_frequency.jl`. |
| `run_multiseed_headline.jl` (227) | seed reproducibility | **Keep**. |
| `run_diagnostics.jl` (872) | model internals | **Keep**, audit for legacy-track diagnostics and trim. |
| `run_figures.jl`, `run_figures_ksweep.jl` | figures | **Keep**, regenerate only the figures used in the trimmed main body. |
| `run_full_rebuild.jl` (88) | top-level driver | **Rewrite** to call only the kept scripts in order; this is the one-command reproducer for the 20-page paper. |
| `run_baselines_and_cross_asset.jl` (443) | mixed | **Split**: keep the baselines half (Bootstrap, Gaussian, Laplace, GARCH, Discrete NJ); move the cross-asset half to `legacy/`. |
| `run_garch_suite.jl` (284) | expanded GARCH | **Move to legacy**. |
| `run_gru_baseline.jl`, `run_track_b1_quantgan.jl`, `run_track_b3_diffusion.jl` | deep-generative | **Move to legacy**. |
| `run_track_b4_msgarch.jl` | MS-GARCH | **Move to legacy**. |
| `run_track_c1_smchmm.jl` (573) | SM ablation | **Move to legacy**. |
| `run_track_c2_large_universe.jl` | 424-asset cross-asset | **Move to legacy**. |
| `run_track_c3_conditional_var.jl`, `run_track_c3_filter_var.jl`, `run_track_c3_time_varying_transition.jl`, `run_track_c3_external_covariates.jl` | conditional VaR family | **Move to legacy**. The trimmed §7 keeps only the unconditional VaR/ES envelope plus a one-paragraph filter-VaR negative finding, which can be supported by a 50-line snippet rather than the four full track-c3 scripts. |
| `run_track_c4_leverage_emission.jl` | leverage emission | **Move to legacy**. |
| `run_cross_asset_sim_copula.jl` (307) | Pipeline B | **Move to legacy**. |
| `run_equity_price_sim.jl` (319) | OoS price fan / CRPS | **Move to legacy**. |
| `run_skew_emissions_ablation.jl` (358) | skew ablation | **Move to legacy**. |
| `run_kdisc13_centroid_ablation.jl` (190) | Bin-T NJ | **Move to legacy**. |
| `run_ks_block_bootstrap.jl` (278) | block bootstrap | **Move to legacy**. |
| `run_kupiec_mc_ci.jl`, `run_lr_ind_bootstrap_null.jl` | bootstrap MC bands on LR | **Move to legacy**. |
| `run_mmd_fixed_bandwidth.jl` | MMD diagnostic | **Move to legacy**. |
| `run_nu_shrinkage_sweep.jl` (248) | 1/ν penalty sweep | **Move to legacy**. The diagnostic compresses to two sentences in §8; the script is the source of those numbers but doesn't need to live in the top-level. |

After this cut, the top-level reproducer (`run_full_rebuild.jl`) drives roughly **8 scripts** instead of 31, against 6 src files instead of 11. The reader reproduces the 20-page paper by running `julia --project=. run_full_rebuild.jl` and nothing in `legacy/`.

### `results/` directory

The repo's `results/` tree carries 19 directories (`track_a`, `track_b1`, `track_b3`, `track_b4`, `track_c1`, `track_c3`, `track_c4`, `track_m2`...`track_m10`, `track_minor*`, `cross_asset`, `cross_asset_large`, `equity_price_sim`, `diagnostics`, `SPY`). A parallel cleanup:

- **Keep at top level**: `track_a/`, `diagnostics/`, `SPY/`, plus a new `rolling_origin/` subdir.
- **Move to `legacy/results/`**: every `track_b*`, `track_c*`, `track_m*`, `track_minor*`, `cross_asset*`, `equity_price_sim/`.
- The trimmed paper's `\input` of CSVs and tables only references `track_a/` and `diagnostics/`; the `results/README.md` should be updated to reflect the split.

### Cross-paper-citations bookkeeping

The repo has `plan-cross-paper-citations.md` and `plan-icaif-resync.md` already. The cuts above either feed companion papers (SM-CHMM, large-universe cross-asset, conditional-VaR, skew-emissions) or feed a follow-up edition; record the disposition in `CHANGELOG.md` so the legacy code is recoverable. Specifically:

- SM-CHMM track → `SM-CHMM-AR-Paper` repo already exists at `/Users/abdulrahmanalswaidan/Desktop/Project-Repos/SM-CHMM-AR-Paper` (existing scaffold), absorbs `SemiMarkov.jl` and `run_track_c1_smchmm.jl` cleanly.
- Cross-asset (Pipeline B + 424-asset) → candidate companion paper, possibly merged with the existing `CHMM-icaif-paper` content; absorbs `CrossAsset.jl`, `run_cross_asset_sim_copula.jl`, `run_track_c2_large_universe.jl`.
- Conditional-VaR (filter, time-varying, external covariates) → standalone follow-up, absorbs the four `run_track_c3_*.jl` scripts.
- Skew-emissions, MS-GARCH, deep-generative → exploratory; defer or fold into a benchmark-only short paper.

### Order of operations

The repo cleanup should run in lockstep with the paper drafting, not before:
1. Land the paper-side cuts first (no code changes).
2. Once §6 and §7 are stable, regenerate the kept tables from the existing `results/track_a/` and `results/diagnostics/` to confirm the numbers; do not re-run anything yet.
3. Move legacy code only after the paper compiles and passes the internal-consistency check; this preserves the ability to recover any number we decide to put back.
4. Update `Manifest.toml` and `Project.toml` after the legacy code is moved; only at this point do dependencies shrink.

The risk in jumping straight to the repo cleanup before the paper is settled is non-trivial: a number in the paper that depends on a metric in `Metrics.jl` we've moved to legacy is harder to recover than a paragraph we've removed from `results.tex`.
