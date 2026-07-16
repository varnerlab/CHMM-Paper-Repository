# Technical, Code, and Narrative Review

## Manuscript

**Continuous Hidden Markov Models for Equity Returns: Heavy-Tail Emission Families and Regime-Conditional Value-at-Risk**

Review date: 2026-07-16  
Paper repository reviewed at: `9a1d8e4`  
Companion model repository reviewed at: `e34fafa`

## Overall assessment

**Recommendation: major revision before submission.**

The paper asks a worthwhile question and has several real strengths: the positive-lag HMM autocovariance identity is stated with appropriate diagonalizability and moment qualifications; the manuscript now distinguishes a continuous-*emission* HMM from a new model class; the one-step predictive-mixture VaR equations are explicit; the cross-asset rank-reordering construction is correctly scoped as cross-sectional rather than temporal; and the paper is unusually candid about non-stationarity, the i.i.d. bootstrap, the HSMM, and the stronger GARCH ACF results. The current Julia test suite also passes in full (116/116 tests).

The current paper and current code repository are nevertheless not mutually consistent. The two most serious problems are:

1. The paper claims a 323-day Polygon-versus-Alpaca overlap check found no vendor break, but the current code audit establishes that no raw cross-vendor overlap exists and that the earlier check compared the Alpaca extension with the same rows already copied into the stitched file. The stated validation is therefore circular and the sentence in Methods is false.
2. The reported quarterly-copula improvement from 0.207 to 0.185 is not a like-for-like comparison. The static number is a full-window error, the rolling number is an average of quarter-specific errors, and the runner uses `K = 18` marginals while the paper says it holds the headline `K^\star = 3` marginals fixed.

Other major concerns are a one-M-step lag in every EM convergence check, stale spectral numbers, an unsupported expansion of the CRPS/Diebold-Mariano conclusion to the current headline rows, retention of two materially different fits of the same GARCH specification, and a central “reproduces slow decay” claim that is much stronger than the fitted population spectrum supports at long lags.

The paper can become technically defensible without changing its basic contribution. The immediate job is to establish one canonical code commit and regenerate a single internally consistent result bundle, then narrow the central claim from “reproduces slow ACF decay” to what is actually shown by horizon-specific diagnostics.

## Critical findings

### 1. The vendor-overlap validation is circular, and the paper states it as genuine

**Evidence**

- Methods says: “The 323-day Polygon versus Alpaca/IEX overlap check found no visible break at the vendor join” (`sections/methods.tex:4`).
- The current code artifact says the raw files are date-disjoint: Polygon/Massive ends on 2024-12-31 and Alpaca/IEX begins on 2025-01-03. It explicitly records that the retired overlap check compared stitched rows with the Alpaca rows from which they were copied (`../CHMM-Model-Repository/results/diagnostics/feed_boundary_check.txt`).
- The obsolete `vendor_stitch_check.csv` still survives in the current model repository and reports exact equality over 323 days, even though the producing runner has been moved to `_attic`.
- The actual feed switch occurs inside the main OoS evaluation window. The replacement diagnostic finds a VWAP-scale standard deviation of 1.640 before the switch and 2.215 after it. That difference is confounded with time variation, so it does not prove a feed effect, but it makes the unavailable cross-feed validation important rather than cosmetic.
- `RUNNERS.md` still points readers to the retired runner as if it were valid (`../CHMM-Model-Repository/RUNNERS.md`, Diagnostics section).

**Why this matters**

The headline OoS results mix consolidated Polygon aggregates with Alpaca's IEX-only feed. A genuine overlap comparison would be the natural check for a distributional discontinuity, but it was never available from the data in the repository. The paper currently converts a failed provenance check into affirmative evidence.

**Required fix**

- Delete the 323-day-overlap sentence and state the true provenance and feed-switch date.
- Remove the obsolete CSV and stale `RUNNERS.md` entry.
- Either obtain a genuine same-date cross-feed sample or rerun the headline OoS analysis on a single consistent feed/cutoff. At minimum, report pre/post-feed results separately and state that time and feed effects cannot be identified from the current design.
- Update the Data Availability statement to the actual vendor cutoffs.

### 2. The quarterly-copula “0.207 to 0.185” improvement is not identified by the implemented comparison

**Evidence**

- The paper says the rolling exercise holds the Table 3 `K^\star = 3` CHMM-N marginals fixed (`sections/cross_asset_appendix.tex:116,122`).
- The runner hard-codes `K = 18` and refits those marginals for the rolling harness (`../CHMM-Model-Repository/runners/cross_asset/run_cross_asset_rolling_copula.jl:36,81-89`).
- The static baseline compares one simulated 572-day panel with the one full-OoS correlation matrix (`run_cross_asset_rolling_copula.jl:102-109`).
- Each rolling number instead compares a simulated 63-day panel with that quarter's realized correlation matrix, after which the nine quarter-specific MAEs are averaged (`run_cross_asset_rolling_copula.jl:111-143`). Mean quarter-specific MAE is not the same estimand as full-window MAE.
- The last five OoS observations are omitted from the nine complete 63-day rolling blocks, although the prose says the exercise covers the OoS span.
- The paper calls 0.209 versus 0.207 “path noise,” but those figures also differ in state count and harness.

**Why this matters**

The reported difference cannot be attributed to refitting because the baseline and treatment are scored on different targets. Quarter-to-quarter variation in realized correlations changes the difficulty of the metric independently of refitting.

**Required fix**

Choose one of two valid designs:

1. Score both a static copula and the rolling-refit copula against every identical next-quarter target, then compare paired quarter-level losses; or
2. concatenate static and rolling simulations over the same complete OoS dates and score both against the same full-window target.

Use `K^\star = 3` in both arms if that is the paper's headline, include the final partial quarter under a stated convention, and attach uncertainty across dates/blocks rather than only Monte Carlo paths.

## Major technical findings

### 3. Paper and code are pinned to incompatible revisions

The Data Availability statement says the reported results correspond to model commit `5d406b7` (`sections/conclusion.tex`, Data Availability Statement), while the reviewed model repository is four substantive commits later. Those commits:

- invalidate the vendor-overlap check;
- change the cross-ticker spectral median from 0.756 to 0.726, median `n95` from 6 to 7, and NEM's minimum share from 0.326 to 0.287;
- add the missing shared-`nu` CRPS result (OoS 1.0406); and
- correct a figure-axis label.

The paper still prints the pre-fix spectral values throughout the abstract/Results/Conclusion and Table S (`sections/results.tex:1`; `sections/sensitivity_appendix.tex:118-133`). It also prints SPY `n95 = 2` in the cross-ticker table, while the corrected artifact gives 3.

**Fix:** select one release commit, regenerate/copy every consumed artifact, update every number, and record both paper and model commit hashes in a machine-readable manifest. A paper-facing `artifacts.csv` should map each table/figure to runner, input data hash, seed, and output file.

### 4. The EM routines return parameters whose likelihood was not evaluated

All four fitters compute the observed-data likelihood in the E-step, perform the M-step, and then test convergence using the pre-M-step likelihood. On convergence or at `max_iter`, they return the post-M-step parameters (`../CHMM-Model-Repository/src/Compute.jl:317-401,508-599,663-722,843-935`). Algorithm 1 discloses the lag at `sections/algorithms_appendix.tex:146-151`.

Consequences:

- the reported final likelihood and posterior `gamma` do not correspond to the returned parameters;
- the final update is never checked for finiteness or decrease when convergence fires or the iteration cap is reached;
- the Student-t/GED “last-known-good” snapshot is restored only if the *next* iteration discovers a non-finite likelihood, not when the loop exits normally;
- this is especially material for the hybrid Student-t and non-convex GED blocks, for which monotone observed-likelihood ascent is not guaranteed.

The prose now says it restores “the last parameter iterate whose likelihood was finite” (`sections/methods.tex:89`), but normal convergence can still return an unevaluated iterate. The code docstring also contradicts the manuscript by saying GED monotonicity holds on the compact bracket (`src/Compute.jl:749-751`), even though the location objective is non-convex for `p < 1` and the golden-section search assumes unimodality.

**Fix:** evaluate the likelihood after every complete update, store a coherent `(parameters, likelihood, gamma)` checkpoint, return the best evaluated finite iterate for hybrid blocks, and optionally backtrack a materially decreasing update. Add regression tests that recompute the returned model's likelihood and compare it with the final stored value.

### 5. The transition update is wrong in the displayed pseudocode

Algorithm 1 writes

`T_ij <- sum_t xi_t(i,j) / sum_t gamma_t(i)`

after Methods has said unqualified sums run over `t = 1,...,T`. The correct denominator is `sum_{t=1}^{T-1} gamma_t(i)`. The source code avoids the mistake by normalizing each row of the accumulated expected-transition counts (`src/Compute.jl:380-385`, and analogues), so this is a paper/code mismatch rather than the fitted-code defect.

**Fix:** put explicit limits on both sums in the paper and add a unit test against a small reference HMM.

### 6. The current CRPS significance claim is not backed by a current runnable comparison

The main text says the four `K^\star = 3` CHMM variants are statistically indistinguishable on OoS CRPS and the table caption repeats that conclusion (`sections/results.tex:5,9`). The support is not aligned with those rows:

- the DM runner is archived under `_attic` and points to a missing `results/_attic_v10/...` cache;
- its comparison covers CHMM-N, unpenalized CHMM-t, and CHMM-L, but not CHMM-GED, penalized CHMM-t, or shared-`nu` CHMM-t;
- `results/robustness/crps_dm_multiday.csv` likewise contains only N/t/L legacy rows;
- the current `K = 3` headline CRPS values come from a different runner and simulation bundle;
- the newly scored shared-`nu` row is 1.0406 in the model artifact, while it has no corresponding current DM test.

The sample-CRPS definition itself is transparently described as marginal/unconditional (`sections/metrics_appendix.tex:67-73`), which is good. The problem is only the scope of the inference.

**Fix:** produce one current per-day loss matrix for every row in the displayed table, run the same HAC comparison on those exact simulations, correct for the family of pairwise comparisons, and vendor the output. Until then, report the CRPS values descriptively without “statistically indistinguishable.”

### 7. The spectral “share of the ACF” statistic needs a mathematically consistent complex-mode definition

The theoretical text correctly says complex-conjugate eigenvalues combine into real damped oscillatory modes (`sections/theory.tex:3-10`). The diagnostic code instead counts every complex eigenvalue separately and defines share using `sum |a_k lambda_k|` (`runners/spectral/run_spectral_rank*.jl`). For a conjugate pair, the real ACF contribution is `2 Re(a_k lambda_k^tau)`, not `2 |a_k lambda_k^tau|`; cancellation and phase therefore matter. Even among real modes, an absolute-contribution budget is not literally a percentage of `rho(1)`.

This distinction is material off SPY: changing from `|Re(a lambda)|` to `|a lambda|` moved the cross-ticker median from 0.756 to 0.726 and substantially increased the effective-rank counts.

**Fix:** group conjugate pairs into real components before ranking, call the denominator an “absolute component-magnitude budget,” and separately report reconstruction error of the theoretical ACF against the direct matrix formula. Avoid saying a mode “carries X% of the ACF” unless the share is defined on signed real contributions without hidden cancellation.

### 8. The fitted population spectrum does not support a strong one-year “slow decay reproduced” claim

For the SPY `K = 3` fit, the dominant eigenvalue is 0.9534 and the second is 0.8656. Using the reported weights, the theoretical population `|G|` ACF at lag 252 is approximately `1.7e-6`; the dominant-mode half-life is about 14.5 trading days. The model can improve average sample-ACF MAE over 252 lags while still having essentially no population persistence at the far end of that range.

The current success rule is explicitly post hoc: CHMM-N's 0.0462 is below an i.i.d. path-noise floor near 0.063, and the paper calls that “within our lag-252 MAE tolerance” (`sections/results.tex:5`). A well-fit GARCH/MS-GARCH reaches 0.0284-0.0316 on the same IS metric. No simulated-versus-observed ACF curve appears in the main paper; all empirical figures are in the appendix, and the available figure set is not actually included for the headline claim.

**Fix:** replace “reproduces slow decay” with “reduces lag-252 sample-ACF error relative to i.i.d. baselines” unless stronger evidence is added. Put an empirical-versus-simulated ACF plot in Results, show horizon-banded error (1-5, 6-20, 21-63, 64-252), compare the theoretical population ACF with the empirical confidence band, and pre-specify any tolerance.

### 9. Two different fits of the same GARCH(1,1) specification remain in the headline evidence

The main table retains a GARCH(1,1) row with ACF-MAE 0.0490 “for artifact consistency,” while the appendix's grid-initialized ML refit of the same specification gives 0.0309 (`sections/results.tex:3,9`). This is not a harmless footnote: the difference changes the comparative conclusion on volatility clustering.

The single ACF columns in the main table are also IS values, although the table juxtaposes IS and OoS distributional columns without labeling the ACF window. The paper then makes broad model-class statements from those values.

**Fix:** choose one canonical multi-start fit and regenerate every GARCH artifact from it. Label ACF columns by window and report both IS and OoS. Do not preserve a known inferior fit in a headline comparison merely to keep an older artifact stable.

### 10. Strict-tail VaR inference remains too dependent on asymptotic p-values

The revised paper correctly adds the strong MS-GARCH `K = 4` comparator and avoids claiming pairwise superiority. Remaining issues are:

- at 1% VaR and 573 forecasts, only about 5.7 breaches are expected;
- the DQ `chi^2_6` p-values that drive the family separation have no finite-sample null calibration in the repository;
- the Christoffersen power runner does not calibrate DQ and its own local Kupiec implementation incorrectly sets `LR_uc = 0` when the simulated breach count is zero (`runners/var_backtest/run_christoffersen_power.jl:40-48`);
- CHMM/filtered-bootstrap/CAViaR use 573 forecasts, while MS-GARCH uses 572;
- separate specification-test p-values do not rank quantile forecasts.

**Fix:** align forecast origins, use an exact/binomial or parametric-bootstrap calibration at 1%, bootstrap the DQ statistic under each fitted null, and add a paired quantile-loss comparison with dependence-robust uncertainty. Until then, make 5% conditional coverage primary and treat 1% DQ as exploratory.

## Model-selection and narrative coherence

### 11. The paper does not maintain one primary CHMM specification through its applications

The narrative calls shared-`nu` CHMM-t the preferred penalty-free heavy-tail trade-off, but:

- the cross-asset head uses CHMM-N;
- the main VaR head emphasizes CHMM-N and penalized per-state CHMM-t;
- the sixteen-row VaR family panel omits the shared-`nu` variant;
- the main table contains five CHMM rows, while its caption says “the four CHMM rows”;
- Methods presents four emission families, but shared-`nu` versus per-state-`nu` is a consequential fifth specification choice.

This makes it unclear whether the contribution is a model, a family-comparison platform, or several use-case-specific choices.

**Fix:** define a decision rule before Results. Either designate one primary configuration and run all downstream heads on it, or explicitly present the paper as a modular framework and give a short table mapping each use case to its chosen variant and selection criterion. Do not call a variant preferred if the applications do not use it.

### 12. KS pass rate is too prominent for a deliberately uncalibrated metric

The paper acknowledges that the two-sample KS null assumes i.i.d. samples and calls the pass rate descriptive. It nevertheless uses that pass rate as the lead headline metric, uses thresholds such as 60% to define failures, and makes “robust ranking” claims from it. Serial dependence differs across generators, so the degree of miscalibration is model-dependent; a pass-rate comparison is not simply a noisy version of a common test.

**Fix:** lead with a common distance/proper-score axis (Wasserstein, energy/MMD, marginal CRPS) and uncertainty over time blocks. Keep KS as a familiar descriptive diagnostic, preferably using the same block-aware calibration for every headline row.

### 13. The return construction is transparent now, but it remains an unusual risk scale

The manuscript correctly clarifies that the data are split-adjusted, not dividend-adjusted, and that `G_t = 252 log(P_t/P_{t-1})` is annualized log *price* growth with `r_f = 0`. That correction should be carried through the title/captions and tables more consistently:

- VaR around -4.56 visually looks extreme until divided by 252 (about -1.8% daily);
- using session VWAP rather than a standard adjusted close makes comparison with the cited daily-return literature less direct;
- omission of dividends is not innocuous for the high-dividend sector names.

**Fix:** report risk results primarily in daily percentage units, with annualized growth in parentheses if needed. Add adjusted-close/total-return sensitivity or narrow all claims to VWAP price growth.

## Code quality and reproducibility

### 14. The test suite passes but does not cover the failure modes that matter most to the paper

Verification on the reviewed model commit: `Pkg.test()` passed 116/116 tests in about 96 seconds. The optional R/MSGARCH test was not run by default.

Important gaps:

- no returned-parameter/final-likelihood consistency test;
- no monotonicity/decrease checkpoint tests for Student-t or GED;
- no GED factory/simulation test in the main compute suite;
- no VaR no-lookahead/indexing regression test;
- no DQ reference implementation or finite-sample calibration test;
- no spectral reconstruction/conjugate-pair test;
- no test that the rolling and static copula comparisons use identical state counts, dates, and scoring targets;
- no test that paper-facing numbers match current artifacts.

**Fix:** add small deterministic reference tests for each item and a paper-artifact validation script that fails when a displayed value differs from its CSV/text source.

### 15. The reproducibility documentation is materially stale

Examples:

- `RUNNERS.md` maps a deleted vendor runner and describes outputs/section numbers that no longer match the paper.
- `results/README.md` lists old `track_*` directories and scripts that are absent or archived.
- `SPECIFICATION.md` still lists Student-t emissions as a future direction even though they are central to the paper.
- `CLAUDE.md` describes the contribution as Gaussian CHMM and claims it reproduces all facts at small K, inconsistent with the current paper's caveats.
- `run_full_rebuild.jl` calls itself an eight-stage driver while its header enumerates nine stages and the executable list runs eight; it explicitly does not rebuild many paper-facing results.
- the current CRPS inference runner is archived and not runnable from its documented input path.

**Fix:** generate the runner-to-artifact map from a manifest rather than hand-maintaining it. Provide a clean-environment smoke target, a full paper target, and a documented “slow/external” target for R/QuantGAN/CRSP components.

### 16. Smaller correctness/documentation defects

- `_weighted_median` says it returns the upper endpoint when half the weight falls between adjacent observations, but its `>= half` condition returns the lower endpoint in the equal-weight two-point case (`src/Compute.jl:603-625`). Both are valid minimizers, but documentation and behavior disagree.
- `viterbi` always initializes with a uniform prior even for heavy-tailed models whose fitter updates `pi` (`src/Compute.jl:132-135`), and the model structs do not store fitted `pi`. This does not affect the reported forward-filter VaR, which starts from stationarity, but it makes the general API inconsistent with the fitted model definition.
- The existing LaTeX log contains an overfull box of about 56 pt for the large VaR table (`paper.log`, lines 927 onward). `make` currently reports the target up to date rather than performing a fresh rebuild.
- The main-table caption says “four CHMM rows” although five are printed.

## Narrative-flow review

### What works

- The central temporal-versus-marginal decomposition is intelligible and potentially useful.
- The paper now distinguishes algebraic capacity from empirical use of that capacity.
- Limitations around non-stationarity, privacy, finite geometric memory, and cross-sectional copula composition are unusually explicit.
- The strongest comparators are no longer completely hidden: bootstrap, HSMM, well-fit GARCH, and MS-GARCH VaR results are visible.

### What needs restructuring

The 79-page compiled document reads like an accumulated review-response record rather than a focused paper. The same Ryden story and the same finite-geometric-memory caveat recur in the Introduction, Related Work, Theory, Results, Discussion, and Conclusion. Results is a sequence of extremely long paragraphs rather than a hierarchy of empirical questions. Discussion and Conclusion largely repeat Results, sometimes with additional numbers.

Recommended main-text structure:

1. **Question and contribution.** One page: low-K temporal versus marginal channels, what is new, and what is not.
2. **Model and estimation.** Define the four families, one primary variant, and the convergence qualification.
3. **Evaluation protocol.** Data provenance, state-count selection, primary metrics, baselines, and predeclared success criteria.
4. **Single-asset results.** Put the observed/simulated ACF figure in the main text; show distributional and temporal axes separately.
5. **Risk application.** One aligned VaR table with finite-sample caveats and pairwise loss comparison.
6. **Cross-asset application.** Clearly label it cross-sectional; show a like-for-like rolling comparison.
7. **Limitations and conclusion.** One short section: finite memory, feed/data scope, regime introduction, dividends, privacy.

Specific editing recommendations:

- Cut the abstract to the question, method, two principal results, and two scope limits. It currently contains too many diagnostics and comparator caveats to function as an abstract.
- Add Results subsections; most current paragraphs carry five to ten distinct claims.
- Move sensitivity numbers, implementation histories, and reviewer-response explanations out of captions.
- Replace repeated “reproduced the three stylized facts” language with metric-specific claims.
- Shorten the Conclusion to a synthesis rather than a second Discussion plus research agenda.
- Consider the title “Continuous-Emission Hidden Markov Models...” because “continuous hidden Markov model” can be read as continuous-time or continuous-state.

## Suggested revision order

1. Freeze a canonical model commit and create the paper-artifact manifest.
2. Correct the vendor provenance and decide whether a single-feed rerun is required.
3. Rebuild the rolling-copula experiment with identical arms and targets.
4. Repair EM checkpointing and rerun all affected CHMM artifacts, especially Student-t/GED.
5. Regenerate the spectral table with grouped real modes and update all stale values.
6. Recompute CRPS/DM on the exact displayed rows and align the VaR forecast windows.
7. Replace the stale GARCH headline row with the canonical fit.
8. Recalibrate the central ACF claim with plots, horizon bands, and a predeclared tolerance.
9. Restructure and shorten the manuscript.
10. Run a clean full rebuild, all tests including optional external baselines, and an automated paper/artifact consistency check.

## Verification performed for this review

- Read the complete paper shell and all main section sources, plus the relevant algorithm, metrics, sensitivity, baseline, and cross-asset appendices.
- Traced headline claims into the Julia fitters, VaR filters, DQ/Christoffersen code, spectral diagnostics, cross-asset runners, result artifacts, and repository history.
- Compared the paper's pinned model commit with the current model HEAD.
- Ran the Julia test suite: **116/116 passed**; optional R/MSGARCH tests remained opt-in.
- Inspected the current compiled PDF metadata (79 pages) and LaTeX log; no unresolved citation/reference warning was found, but one large overfull box remains.
- Confirmed both worktrees were clean before writing this review.

