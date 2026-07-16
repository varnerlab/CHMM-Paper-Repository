# Fresh Technical, Statistical, Code, and Narrative Review

## Scope

**Manuscript:** *Continuous-Emission Hidden Markov Models for Equity Returns: Heavy-Tail Emission Families and Regime-Conditional Value-at-Risk*

**Review date:** 2026-07-16

**Paper repository:** `99ed625`

**Companion model repository:** `8b9fe49`

This is a new audit of the current repository heads after the fifth-review response. I reread the main paper and the relevant appendices, traced the revised claims into their runners and artifacts, inspected the CHMM and comparator implementations, ran the full Julia test suite and the paper/artifact gate, performed fresh convergence diagnostics on the headline `K = 3` and `K = 18` Gaussian fits, and compiled the manuscript from a clean temporary copy.

## Overall assessment

**Recommendation: targeted major revision before submission.**

The fifth response genuinely fixes nearly every concrete defect identified in the preceding audit. Strict common random numbers are now used in the quarter-level copula experiment; the observed ACF bootstrap band is restricted to lags 1--5; raw kurtosis bands are explicitly descriptive and winsorized kurtosis is used for inference; Hill-range overlap is described as compatibility rather than equivalence; the far-band ACF language now gives the exact worse-than-i.i.d. values; stale documentation and manifest statuses were repaired; and the `_auc` precedence bug is fixed and tested. The core finite-state CHMM likelihood recursion, transition update, simulation, spectral reconstruction, and VaR indexing remain internally coherent.

Two newly exposed problems nevertheless affect headline scientific claims:

1. The revised experiment does **not identify the decay-mode budget as non-binding**. It compares particular likelihood-fitted models on the same sample used to fit them, changes marginal and temporal capacity simultaneously, uses one deterministic initialization, and does not optimize ACF loss. More seriously, the exact `K = 18` SPY fit used by the runner is not converged at the stated 60-iteration cap.
2. The main table's “ML HSMM-N” comparator is not maximum-likelihood for its declared truncated discrete Pareto duration model. Its duration update uses the continuous, untruncated Pareto formula, and its runner/artifacts are not correctly represented in the manifest.

The paper's strongest defensible conclusion is narrower: **under these particular fitted CHMMs, heavy-tailed emissions improve marginal diagnostics, and increasing the Gaussian state count from 3 to 18 did not improve the in-sample ACF diagnostic.** That is useful empirical evidence, but it is not yet evidence that the attainable two-mode budget is the binding/non-binding constraint.

## Verification results

- **Full model test suite:** `7,140 / 7,140` tests passed in `8m49.9s` under `Pkg.test()`.
- **Optional R baseline:** the opt-in `CHMM_TEST_MSGARCH=1` MCMC-backed reference test was not run; the default suite explicitly reports that skip.
- **Paper/artifact gate:** `runners/diagnostics/run_paper_artifact_check.jl` passed all current manifest, substring, and keyed checks.
- **Clean paper build:** `latexmk -C` followed by `latexmk -pdf -interaction=nonstopmode -halt-on-error paper.tex` succeeded from a clean temporary copy.
- **Build quality:** 84 pages; no unresolved citations or references; no overfull boxes; three underfull boxes in the specification-map table.
- **PDF metadata:** title, subject, keywords, and authors match the current manuscript.
- **Repository hygiene:** both repositories were clean before this review file was replaced; `git diff --check` passed in both.

These gates establish executable and typesetting consistency. They do not validate the interpretation of an experiment or the statistical assumptions behind it.

## Corrections that are now sound

- **Strict copula CRN is real.** All four quarter arms call `simulate(model, n_days, N_PATHS, crn)` in `runners/cross_asset/run_cross_asset_rolling_copula.jl:181-188`. Separate base-normal, chi-square, and marginal-path streams are implemented in `src/CrossAsset.jl:525-602`, and the runner's call sites now have a source-level regression test.
- **The copula artifact is synchronized.** The paper and artifact agree on Student-t `0.264 -> 0.186`, Gaussian `0.261 -> 0.179`, and family effects of `0.003--0.007`. The paper appropriately calls the nine-quarter result suggestive.
- **The ACF band repair is correct.** `runners/headline/run_acf_horizon_diagnostics.jl:147-174` records `NaN` after lag 5, and the paper explains gradual block-boundary contamination rather than asserting a false cutoff at lag 20.
- **Kurtosis layers are separated.** The raw fourth-moment bootstrap is labelled descriptive; the difference in winsorized kurtosis is the stated inferential target; and non-rejection is not presented as equality.
- **Hill wording is now logically correct.** `sections/results.tex:76` explicitly says that overlapping observed and simulated ranges are different inferential objects and are not a difference interval or equivalence test.
- **ACF horizon wording is accurate.** The paper says the CHMM beats the i.i.d. reference at lags 1--63 and is slightly worse at lags 64--252 (`0.041` versus `0.036`).
- **Repository synchronization improved.** `README.md`, `RUNNERS.md`, `src/Types.jl`, the manifest, and the manuscript's refit medians now agree. The `_auc` empty-class condition is parenthesized and tested.

## High-priority technical findings

### 1. The “mode budget is not binding” experiment does not identify that constraint

The revised spectral runner is much better than its predecessor. It runs at both `K = 3` and `K = 18`, groups complex-conjugate modes, adds a horizon-aware contribution norm, and compares fitted population ACFs against the observed sample ACF. Its reported numbers reproduce: near-band median MAE is `0.0543` at `K = 3`, `0.0697` at `K = 18`, and `0.0901` for the zero curve; `K = 18` is better on only `1/31` series.

That establishes a descriptive fact about these fitted models. It does not establish that the two-mode capacity at `K = 3` is non-binding:

- Both models are fitted by observed-data likelihood, not by ACF loss. A higher-state likelihood optimum can improve the marginal likelihood while worsening ACF MAE. Failure of a likelihood fit to use its extra modes is not proof that extra modes cannot reduce the ACF approximation error.
- Moving from `K = 3` to `K = 18` changes the emission mixture and transition spectrum together. The experiment therefore does not isolate marginal capacity from temporal capacity.
- The comparison is in-sample: the sample ACF being scored is calculated from the same observations used by EM (`runners/spectral/run_spectral_rank_cross_ticker.jl:98-113`). It provides neither out-of-sample ACF evidence nor a constrained approximation benchmark.
- The Gaussian fitter uses one deterministic quantile initialization and a uniform transition matrix (`src/Compute.jl:294-316`). No multistart or optimizer-sensitivity analysis is applied to the high-dimensional `K = 18` fits.
- The count `1/31` includes SPY with the 30-stock panel. It is descriptive and carries no cross-sectional uncertainty analysis; the tickers also share market-wide dependence.

The runner itself overstates its logic when it says the binding question is “settled” (`run_spectral_rank_cross_ticker.jl:231-234`). The manuscript repeats the leap in the abstract (`paper.tex:146`), Results (`sections/results.tex:23`), sensitivity reading (`sections/sensitivity_appendix.tex:137`), and Conclusion (`sections/conclusion.tex:1`).

**Required correction:** replace “the mode budget is not the binding constraint” with “the additional states did not improve ACF MAE for these likelihood fits.” To identify the stronger claim, use converged multistart fits and one of the following designs:

1. compare the best attainable ACF approximation under a two-mode restriction with a richer-mode restriction while holding the marginal moments fixed;
2. add an ACF-targeted or likelihood-plus-ACF constrained fit, then test on held-out ACF loss; or
3. show that a nested/richer fit, after optimizer sensitivity and convergence checks, cannot materially improve a pre-specified out-of-sample ACF criterion.

### 2. The headline `K = 18` spectral comparator is not converged

The runner caps every Gaussian fit at 60 M-steps and does not report convergence or the final likelihood increment. A fresh reproduction using the identical SPY data and fitter gives:

- `K = 3`: 53 likelihood evaluations, final increment `8.56e-5`; this satisfies the fitter's `1e-4` tolerance.
- `K = 18`: 61 likelihood evaluations (the cap plus the final evaluation), final increment `+0.58097`; this is about 5,800 times the convergence tolerance.

The `K = 18` likelihood remained monotone, so this is not numerical failure; it simply had not converged. Extending the same deterministic fit to 200 M-steps still hit the cap with a final increment of `+0.0422`. On SPY the exact-moment near-band ACF MAE was fairly stable (`0.0772`, versus the stored 60-step Monte-Carlo-moment value `0.0778`), which is reassuring for that one series, but it does not validate the other 30 capped high-state fits.

This is a direct correctness problem for the experiment underpinning the abstract's primary claim: a converged low-state fit is compared with an unconverged high-state fit, while no per-ticker convergence table is retained.

**Required correction:** fit each state count to a defensible convergence rule, save `n_iter`, final likelihood increment, and best likelihood per initialization, and rerun the entire `K = 3`/`K = 18` panel. Use several starts at `K = 18`. If practical convergence cannot be reached, label the high-state result as a fixed-compute sensitivity rather than evidence about model capacity.

### 3. “A different duration law, not a larger state count” is mathematically too categorical

A finite irreducible HMM has an ACF that is a finite sum of geometric, damped-oscillatory, or Jordan polynomial-times-geometric terms. It therefore cannot have an exact power-law asymptote. The paper's spectral theorem supports that statement.

It does **not** follow that more states cannot improve persistence over the finite reported horizon. Increasing `K` adds eigenmodes, and transition eigenvalues can move closer to one; finite mixtures of exponentials can approximate slow or power-law-like decay over a bounded interval. Even a fixed low-state model can extend its half-life through a more persistent transition matrix. The present `K = 18` likelihood fits did not do so, but that empirical result is not a structural impossibility.

The abstract and Conclusion repeatedly say that escaping the lags-64--252 ceiling “requires a different duration law rather than more states” (`paper.tex:146`; `sections/conclusion.tex:1,3`). This conflates failure of the fitted models over a finite interval with the asymptotic finite-geometric limitation.

**Required correction:** say that a different duration law or long-memory latent process is required for genuine non-geometric/power-law asymptotics, while additional states or more persistent transitions may improve a finite-horizon approximation but did not do so in the reported fits.

### 4. The main table's “ML HSMM-N” is not maximum-likelihood for its declared duration PMF

The main generator table reports a co-main “ML HSMM-N” with IS/OoS KS `98.4% / 91.0%`, kurtosis `3.46 / 3.38`, and ACF-MAE `0.0629`. Those values trace to `results/hsmm_ml/hsmm_ml_metrics.csv` and the archived runner `_attic/runners/run_hsmm_ml.jl`.

The runner declares the truncated discrete Pareto duration model

`p_alpha(d) = d^(-(alpha+1)) / Z_D(alpha),  d = 1,...,D`.

For expected duration counts `w_d`, its Q-function score must solve

`E_w[log d] = E_alpha[log D]`,

where the right side is computed under the normalized truncated discrete PMF and depends on both `alpha` and `D`. Instead, `_fit_pareto_alpha` returns

`alpha = 1 / E_w[log d]`

at `_attic/runners/run_hsmm_ml.jl:79-86`. That is the continuous, untruncated Pareto result; it is not the optimizer of the discrete truncated likelihood evaluated by `_pareto_logpmf`. The M-step at lines 350--361 is therefore not an exact ML/EM duration update, and monotonic likelihood improvement is not guaranteed by the claimed argument.

This does not prove the stored HSMM metrics are numerically poor. It does make the “maximum-likelihood HSMM” label technically false, which matters because the abstract-level narrative uses this comparator to delimit the CHMM's raw-fit performance.

**Required correction:** numerically maximize the actual expected truncated-discrete duration log-likelihood for each state (or use a root solve for the correct score), add monotonicity and returned-iterate tests, rerun the HSMM artifact, and only then retain “ML HSMM-N.” Until then, call it an approximate or generalized-EM Pareto-duration HSMM.

### 5. The ML-HSMM result is missing from the live provenance map

The runner for the main-table ML HSMM is in `_attic/`, while the `tab:model_comparison` manifest row maps the table to `run_smchmm_baseline.jl` and omits both `_attic/runners/run_hsmm_ml.jl` and `results/hsmm_ml/`. The live `run_hsmm_gamma.jl` merely prints the old Pareto values as a hard-coded comparison reference.

Consequently, the passing artifact gate does not check the main table's HSMM row. A substring checker could even find the hard-coded numbers in the wrong runner without establishing provenance. This conflicts with the Data Availability statement that the manifest maps each table to its runner and artifact (`sections/conclusion.tex:12`).

**Required correction:** restore the corrected ML-HSMM runner to the live runner tree, map its precise artifact in `results/artifacts_manifest.csv`, and add keyed checks for the actual CSV row. The consistency gate should verify file existence and, ideally, artifact/runner commit or content hashes.

## Additional statistical and code findings

### 6. Winsorization fixes the infinite-fourth-moment problem, but the bootstrap assumptions are underspecified

Clamping at fixed interior quantiles makes the winsorized variable bounded, so the raw-tail-index objection no longer applies. The code also correctly recomputes empirical thresholds inside each resample.

However, “finite moments at any tail index” is not by itself enough to validate the stationary-block percentile interval. Quantile-estimated winsorized kurtosis requires regularity at the clamp quantiles (for example, continuity and positive density), nondegenerate variance, and dependence conditions strong enough for the empirical quantiles and moment functional. The paper states only that the method is standard “under mixing,” without specifying or checking those conditions. More importantly, its own walk-forward failures, regime introductions, and mixed-vendor OoS window challenge within-window stationarity.

At `q = 0.01`, the 572-observation OoS window has only about six observations per tail beyond each empirical clamp, so finite-sample quantile uncertainty is substantial. Reporting `q = 0.05` and all block lengths is helpful, and every interval covers zero, but the result should be stated as conditional on stationarity/mixing and quantile regularity rather than as assumption-free inference.

Also keep the estimand distinction explicit: winsorized kurtosis says nothing direct about equality of the extreme tails or the possibly undefined raw population kurtosis.

### 7. The spectral runners use an ad hoc stationary-distribution calculation

`runners/spectral/spectral_common.jl:32` uses `(T^2000)[1, :]`, and the ACF horizon runner uses `(T^1000)[1, :]`. This is adequate when the subdominant eigenvalue is well below one, but no residual such as `||pi' T - pi'||` is checked. A highly persistent high-state fit can remain dependent on the arbitrary starting row after a fixed number of powers.

The fresh 200-step SPY `K = 18` fit had a negligible stationary residual after 5,000 powers, so there is no demonstrated SPY error. The cross-ticker runner, however, should calculate the stationary vector by a left-eigenvector or constrained linear solve and assert normalization, non-negativity, uniqueness, and a small stationarity residual for every fit.

### 8. The spectral moments should be analytic for Gaussian emissions

The cross-ticker diagnostic estimates `E|G|` and `E[G^2]` from 200,000 draws per state even though both are closed form for a Normal emission. This introduces unnecessary Monte-Carlo variation into a supposedly deterministic model-vs-sample comparison. It is unlikely to explain the median differences, but exact folded-normal moments would be faster, auditable, and eliminate one source of rerun noise.

### 9. The artifact gate is improved but remains a consistency sampler, not a rebuild guarantee

All 52 manifest rows now avoid known-bad statuses, and nine drift-prone values use keyed regex extraction. Most other checks still search for a numeric substring anywhere in an artifact directory and anywhere in a TeX file. The gate does not execute runners, validate input hashes, validate the pinned model commit, or prove that a number came from the intended row. “ALL CHECKS PASS” should continue to be described as a consistency gate, not a complete reproduction.

### 10. The optional reference MSGARCH result remains outside the default test gate

The default suite clearly discloses this and the R environment is pinned, so this is not a hidden defect. It remains important in the reproducibility statement because the reference Bayesian MSGARCH rows appear in the main generator table despite not being exercised by the reported `7,140`-test run.

## Narrative-flow review

### Improvements

- The abstract now has one primary empirical story, one long-horizon boundary, and appropriately qualified copula and VaR applications.
- The Results order is coherent: state-count/evaluation protocol, single-asset results, cross-asset composition, then VaR.
- The manuscript is candid about ex-post selection, non-rejection versus equivalence, mixed-vendor data, stress-fold failures, the loss of serial dependence under cross-asset rank reordering, and the absence of a privacy guarantee.
- The Hill, ACF, copula, and kurtosis caveats now appear near the claims they qualify rather than only in the supplement.

### Remaining flow problems

The paper is still written partly as an audit dossier rather than a journal narrative. The clean build is 84 pages, with the main Conclusion on page 22 and supplementary material through page 84. Several individual paragraphs carry setup, estimator details, numerical results, inference, caveats, and rebuttal history at once:

- `sections/results.tex:23` combines stylized-fact confirmation, raw and winsorized kurtosis, four state-count-selection schemes, two spectral norms, and the bindingness conclusion.
- `sections/results.tex:103` is an extremely long cross-asset paragraph spanning in-sample family selection, non-overlap sensitivity, seed uncertainty, the quarter experiment, and marginal failures.
- The first Discussion and Conclusion paragraphs each restate most of the paper's quantitative results.

The dominant narrative issue is not merely length; it is that the strongest causal wording appears in the abstract and Conclusion, while the limitations that make it descriptive appear later. Once the bindingness and duration-law claims are narrowed, the flow will improve automatically.

Recommended structural edit:

1. End the state-count subsection after selection and basic ACF horizon evidence.
2. Put the spectral mechanism in a short separate subsection titled “What the fitted spectra do—and do not—show.”
3. Split the cross-asset paragraph into construction, static results, and rolling `2 x 2` evidence.
4. Reduce the Conclusion to the supported contribution, two application results, and three limitations; move numerical inventories to the Results tables.
5. Keep development history in `CHANGELOG.md`, not in scientific prose or live-runner comments.

## Recommended revision order

1. Rerun the `K = 18` spectral panel to convergence with multistart diagnostics and save optimizer evidence for every ticker.
2. Narrow the mode-budget claim unless a design that holds marginal capacity fixed and evaluates held-out ACF loss is added.
3. Correct the finite-horizon versus asymptotic duration-law statement throughout the abstract, Discussion, and Conclusion.
4. Replace the Pareto-duration HSMM update with the true truncated-discrete likelihood optimizer, rerun it, and restore its live provenance.
5. State the regularity and stationarity assumptions for winsorized-kurtosis inference; otherwise present it as a robust sensitivity interval.
6. Replace fixed matrix powers with a checked stationary-vector solver and use analytic Gaussian folded moments.
7. Add keyed checks for the HSMM and other main-table rows, plus runner/artifact existence and hash metadata.
8. Condense the large Results, Discussion, and Conclusion paragraphs after the scientific scope is settled.

## Bottom line

The fifth response is a substantial improvement and the core CHMM implementation is in good shape: all 7,140 default tests pass, the paper builds cleanly, strict CRN is correctly implemented, the spectral identity reconstructs the direct ACF, and the earlier inferential-language defects are largely repaired.

The current submission risk is now concentrated rather than diffuse. The paper's primary abstract claim is stronger than the revised experiment can identify, and its high-state comparator is demonstrably unconverged. Separately, a main-table comparator is called maximum-likelihood despite using the wrong duration-parameter update for its stated PMF and lacking live provenance. Fixing those two analyses and narrowing the finite-horizon structural language would make the work technically credible as an empirical CHMM comparison with clearly bounded claims.
