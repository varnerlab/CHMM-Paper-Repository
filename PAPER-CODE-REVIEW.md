# Fresh Technical, Code, and Narrative Review

## Scope and revisions reviewed

**Manuscript:** *Continuous-Emission Hidden Markov Models for Equity Returns: Heavy-Tail Emission Families and Regime-Conditional Value-at-Risk*

**Review date:** 2026-07-16

**Paper repository:** `ca69b68`

**Companion model repository:** `02d3688`

This is a fresh review of the repositories' current heads, not a restatement of the earlier review. I read the main manuscript and relevant appendices, traced the headline values into the current Julia runners and artifacts, inspected the recent source changes, ran the model tests and paper/artifact consistency gate, and compiled the manuscript from a clean temporary build directory.

## Overall assessment

**Recommendation: major revision before submission.**

The latest revision fixes most of the earlier paper/code mismatches. Vendor provenance is now stated honestly; the copula refit has paired targets and `K = 3` marginals; the core Gaussian, Student-t, Laplace, and GED fitters return evaluated parameter iterates; transition-update limits are correct; the spectral diagnostic groups complex-conjugate modes and reconstructs the matrix ACF; VaR forecast origins are aligned; strict-tail DQ results are qualified by a finite-sample exercise; and the main ACF claim is narrower. The current model suite passes 7,100/7,100 tests, the consistency script exits successfully, and the paper builds without unresolved citations or references.

The replacement analyses introduce several new or still-unresolved correctness issues, however. The most consequential are:

1. the ACF confidence band uses 20-day blocks to make claims through lag 252, mechanically destroying dependence beyond the block length;
2. the recommended shared-`nu` model still uses a private runner-level fitter with the old unevaluated-final-update defect;
3. several non-rejections are described as “statistically indistinguishable,” and a bootstrap probability is incorrectly labelled a p-value;
4. the “temporally aware” KS calibration does not simulate the stated two-sample null;
5. the copula conclusion compares the family and refit effects under different scoring designs; and
6. the new provenance manifest and runner documentation are already stale despite the consistency check passing.

These are repairable without abandoning the paper's main contribution, but they affect central claims rather than only presentation.

## What the latest revision fixed correctly

- **Vendor provenance:** Methods and Appendix `sec:feed_boundary` now disclose the date-disjoint Polygon and Alpaca files, retire the circular 323-day comparison, and treat the mid-OoS feed switch as an unresolved limitation.
- **Core EM checkpointing:** the four library fitters in `src/Compute.jl` now evaluate before mutation; Student-t and GED return the best evaluated finite checkpoint, and tests independently recompute the returned likelihood.
- **Transition update:** Algorithm 1 now uses `t = 1,...,T-1` for both expected-transition sums.
- **Spectral decomposition:** `runners/spectral/spectral_common.jl` groups conjugate pairs, uses the unconjugated left-eigenvector product, calls the denominator an absolute component-magnitude budget, and verifies reconstruction against direct matrix powers to numerical precision.
- **GARCH ACF conventions:** the manuscript now distinguishes per-path ACF-MAE from pooled-curve ACF-MAE instead of presenting them as two fits of the same estimand.
- **VaR alignment and qualification:** CHMM and MS-GARCH use the same 573 forecast targets; exact binomial values, a limited parametric DQ calibration, and paired pinball losses substantially improve the risk section.
- **Copula pairing:** static and rolling Student-t copulas are now scored against the same quarter-level targets with the same `K = 3` marginal models.
- **Narrative scope:** the abstract acknowledges the feed change and failure beyond roughly three months; Results has real subsections and an application/specification table.

## Critical technical findings

### 1. The ACF “confidence band” cannot support the horizon claims made from it

`runners/headline/run_acf_horizon_diagnostics.jl` constructs a moving-block bootstrap with fixed block length `L = 20`, concatenating independently sampled blocks, and then reports pointwise percentile bands for lags 1--252. The Figure 2 caption says the observed ACF above the band at lags 21--63 “reflects dependence beyond the block scale.” That behavior is built into the resampling scheme: independently concatenated 20-day blocks sever dependence across block boundaries, so their ACF distribution is forced toward zero beyond approximately 20 days.

The artifact makes the effect visible. At lag 63 the observed ACF is `0.0849`, the bootstrap interval is approximately `[-0.0534, 0.0546]`, and the simulated 90% envelope ends at `0.0622`. Calling this evidence that the model “tracks the observed decay through lag approximately 63” is too strong. The model's fitted population ACF is only `0.0144` at lag 63 and effectively zero by lag 126.

The horizon-banded MAE comparison remains a valid descriptive calculation: CHMM-N improves on the permutation floor at lags 1--63 and loses at lags 64--252. What is not valid is treating the `L = 20` percentile envelope as uncertainty for long-lag ACF estimates or interpreting observed values beyond the block size as departures from that band.

**Required fix:** use an uncertainty method designed for the maximum lag being reported: a substantially longer, data-selected block length; subsampling with explicit lag-dependent validity; a sieve/model-based bootstrap; or asymptotic HAC bands. Report simultaneous rather than only pointwise bands if the curve is used for a horizon-wide claim. Until then, remove the observed-bootstrap band beyond its defensible lag range and change “tracks through 63” to the exact banded-MAE result.

### 2. The shared-`nu` fitter did not receive the core EM checkpoint repair

The core library fitters were repaired, but the recommended shared-`nu` Student-t model is implemented separately inside:

- `runners/headline/run_chmm_t_shared_nu.jl:84-210`; and
- a copied implementation in `runners/robustness/run_crps_dm_kstar3.jl:118-244`.

Both routines evaluate `ll_now`, save the current parameters, perform the M-step, and only then check `abs(ll_now - prev_ll) < tol`. When that condition fires, they return the just-updated parameters, whose likelihood was not evaluated. At the iteration cap they likewise return a post-update iterate. Their “last” snapshot protects only against a later non-finite likelihood; it is not a best-evaluated checkpoint.

This directly affects the row the paper recommends for heavy-tail fidelity, including its KS, kurtosis, and CRPS numbers. It also contradicts the general Methods statement that every parameter iterate is scored before it can escape and that returned parameters, likelihood, and posterior match.

**Required fix:** move shared-`nu` estimation into the library, apply the same evaluate-before-update/best-checkpoint contract, delete the copied runner implementation, add the same returned-likelihood regression test, and regenerate every shared-`nu` artifact.

### 3. The kurtosis bootstrap probability is not a p-value

`run_kurtosis_bootstrap.jl` independently bootstraps the IS and OoS series and computes the fraction of paired Monte Carlo draws satisfying `kurtosis_IS > kurtosis_OoS`. The paper labels `Pr(IS > OoS) = 0.756` an “empirical bootstrap one-sided p-value for the alternative.” It is neither a conventional p-value nor a null-calibrated test. It is a descriptive bootstrap probability under resampling distributions centered near the two observed samples. Calling it a p-value reverses the usual tail-probability convention and does not impose the null of equal kurtosis.

Overlapping marginal 95% confidence intervals also do not by themselves test the difference at 5%; a confidence interval for the difference is required.

**Required fix:** bootstrap the difference and report its percentile/basic/BCa interval, or construct a null-imposed permutation/block-bootstrap test appropriate to two dependent time series. Until then, call `0.756` a descriptive bootstrap probability and remove “statistically indistinguishable.”

### 4. The KS block-bootstrap calibration does not reproduce the stated null

The headline KS pass rates use an i.i.d. two-sample reference despite serial dependence. The appendix attempts to fix this by comparing the fixed observed series with one stationary-block resample of itself and taking the 95th percentile of those KS distances. This is not the null distribution of a KS statistic between two independent dependent series generated from the same marginal process. It conditions on one empirical series, reuses that series as the resampling population, does not refit the candidate generator, and consequently understates or otherwise changes the two-sample uncertainty it claims to calibrate.

The construction may be useful as a conditional posterior-predictive distance threshold, but it is not a generic “temporally aware KS test.” The fact that its critical values are smaller than the i.i.d. two-sample value is a warning that the estimand has changed, not evidence that accounting for clustering necessarily makes the test stricter.

**Required fix:** simulate two independent block-bootstrap series per null replicate, or use a model-based bootstrap that refits the generator and reproduces the complete comparison. State whether the goal is a conditional goodness-of-fit check or an unconditional two-sample test. Until then, lead with continuous distances/proper scores and keep both KS pass rates descriptive.

## Major findings

### 5. “Statistically indistinguishable” is still inferred from failure to reject

The current CRPS runner now covers the exact five displayed CHMM rows and applies Holm correction, which is a real improvement. The supported statement is: **none of ten pairwise equal-mean-loss nulls was rejected after Holm correction.** That is not evidence that the rows are statistically equivalent or indistinguishable; no equivalence margins, power analysis, or confidence-interval decision rule is supplied. One unadjusted comparison is nominally significant (`p = 0.0417`) before Holm correction.

The stale `sections/metrics_appendix.tex:73` is worse: it still says four CHMM variants are indistinguishable from the i.i.d. bootstrap and GARCH and that Gaussian i.i.d. is the only significantly worse comparator, while the current runner tests only ten pairs among five CHMM rows.

**Fix:** use “no pairwise null was rejected after Holm correction,” show confidence intervals for the loss differences, and reserve “equivalent/indistinguishable” for a pre-specified equivalence test.

### 6. The family-versus-refit copula conclusion is not like-for-like

The repaired static-versus-rolling comparison is like-for-like within the Student-t family. The broader conclusion that “refitting the dependence layer, not choosing its family, drives out-of-sample dependence error” is still based on two different designs:

- Student-t versus Gaussian family choice is scored mainly against one full-window OoS correlation matrix (`0.209` versus `0.204`); and
- static versus rolling Student-t is scored against ten quarter-specific matrices (`0.289` versus `0.223`).

Effect sizes from those different targets are not directly comparable. To identify the claim, the same quarter-level harness must cross family and refit status: static Gaussian, rolling Gaussian, static Student-t, and rolling Student-t.

The quarter inference also gives the final five-day block the same weight as each 63-day block. A six-variable sample correlation matrix from five observations is extremely noisy and rank-deficient, and the appendix itself calls that row target-noise-dominated. A paired t-test over only ten adjacent time blocks, with overlapping 252-day estimation windows and no dependence correction, should be described as suggestive rather than “statistically supported.”

**Fix:** run the 2x2 family/refit design on identical complete blocks; handle the final partial block separately or weight by information/horizon; use block/wild-bootstrap uncertainty or report the ten differences descriptively.

### 7. The “specification map” is retrospective and internally inconsistent

Results says the map turns application choices into a “declared protocol rather than post hoc preferences,” but the map is written after the results and explicitly uses OoS performance to recommend shared-`nu` Student-t (“best CHMM OoS KS”). That is model selection on the held-out evaluation window unless another untouched test set is reserved.

The map also lists the cross-ticker application as penalized CHMM-t at `K = 18`, while the main cross-ticker paragraph says it fits that model at `K* = 3` and reports the `69.1%` median/quarterly-refit result at `K = 3`. The `K = 18` result is a sensitivity check. The cross-asset rationale “closed-form per-state CDFs” does not uniquely select CHMM-N because the other implemented emission families also expose CDFs.

**Fix:** call the map an ex-post analysis map, correct the cross-ticker row, and separate selection, validation, and final testing. If OoS is used to choose the recommended family, report the choice as exploratory or evaluate it on a new window.

### 8. The ACF claim remains contradictory across sections

The abstract and Results now correctly say the advantage occurs at short and medium horizons and that the population ACF vanishes at long horizons. Discussion then says the model “matched the three symmetric Cont stylized-fact diagnostics,” that the ACF was “matched within our lag-252 MAE tolerance at any K >= 2,” and that the marginal, not the ACF, binds. No pre-registered tolerance exists, and the new horizon result explicitly shows the model loses to i.i.d. at lags 64--252.

The defensible conclusion is narrower: on SPY, the fitted CHMM reduces a sample-ACF MAE aggregate because it captures lags 1--63; it does not reproduce the long-horizon slow-decay component. The cross-ticker `K = 18` spectrum has median `n95 = 4`, so the stronger rank-non-binding statement is established only for SPY at low K, as Results partly acknowledges.

**Fix:** use that narrow claim consistently in Introduction, Discussion, and Conclusion. Remove “matched all three” and the undefined lag-252 tolerance.

### 9. Provenance tooling reports green while its own metadata is stale

`results/artifacts_manifest.csv` still marks the MS-GARCH conditional block “UNTRACED,” the spectral paper values stale, the Christoffersen zero-breach bug known, and the rolling-copula artifact pending. All four were supposedly repaired in the same commit. `RUNNERS.md` still describes the rolling-copula output as the obsolete `0.185` result with `0/6` failures, and `results/README.md` retains old table numbering and runner paths.

The consistency checker passes because it searches for a numeric substring anywhere in an artifact path and anywhere in a TeX file. It does not parse tables, verify labels/rows/columns, validate seeds/data hashes, or confirm that a runner produced the current file. For example, the string `0.223` appearing somewhere in a report is sufficient.

**Fix:** make the manifest authoritative and machine-readable; store exact row/column keys, hashes, runner commit, inputs, and seeds; have the checker parse CSV/TOML/JSON values rather than search strings; fail on stale manifest statuses. Add the shared-`nu`, ACF-band, and inference artifacts to the test contract.

### 10. The mixed-feed OoS window remains an unresolved identification limit

The paper now states this correctly, but the issue still constrains every single-window OoS ranking: consolidated Polygon data and IEX-only Alpaca bars are mixed inside the evaluation period, with no same-date overlap to estimate a feed effect. The appendix's pre/post comparison cannot identify vendor versus calendar-regime change.

**Fix:** obtain a genuine same-date overlap, rerun on a consistent vendor/cutoff, or split the headline evaluation at the feed boundary. The current caveat is honest but does not restore a clean OoS estimand.

### 11. VaR inference is improved, but the strict-tail evidence remains narrow

The aligned 573-day harness, exact binomial calculation, and paired pinball loss are technically useful. The finite-sample DQ bootstrap, however, covers only CHMM-N `K = 3` and MS-GARCH `K = 4`, uses `B = 500`, and conditions on estimated parameters without refitting. It cannot calibrate every strict-tail DQ row in the large family panel. The paper mostly acknowledges this and now makes the 5% tier primary, which is appropriate.

**Fix:** retain the conservative wording, increase `B`, and if strict-tail comparisons remain prominent, bootstrap every displayed contender with parameter re-estimation or explicitly limit inference to the two calibrated rows. In the abstract, prefer “was not rejected” to “passes.”

## Code-quality findings

- The main Julia suite passes **7,100/7,100 tests in 5m38s**. The optional R/`MSGARCH` tests remain opt-in and were not run.
- The new likelihood-consistency, spectral reconstruction, VaR-indexing, and artifact-shape tests are valuable.
- No test exercises the private shared-`nu` fitter's likelihood/parameter consistency.
- Artifact tests validate stored breach flags against stored returns and VaR values, but do not independently reproduce the forecasting recursion; a jointly shifted forecast/return pair could still pass.
- `baum_welch_student_t` contains a duplicated `K = number_of_states` assignment, and `baum_welch_laplace` contains a duplicated nested `if Σw > 0`; harmless at runtime, but evidence that the large patch needs a cleanup pass.
- `Types.jl` describes the Gaussian model as having “continuous states” rather than continuous emissions and calls its uniform initial distribution fitted, contradicting the documented Gaussian convention.
- The shared-`nu` implementation is duplicated across runners instead of being a tested library component.
- `run_full_rebuild.jl` explicitly rebuilds only eight headline stages, while the Data Availability Statement says runners regenerate every reported table. There is no single clean-environment command that proves the complete 83-page artifact set, including R, CRSP, VaR, robustness, and cross-asset extras.

## Narrative-flow review

### Improvements

- The new title removes the continuous-state/continuous-time ambiguity.
- The abstract is more candid and focused than the previous version.
- Results now has four meaningful subsections and a useful application map.
- The main ACF curve, feed limitation, strong MS-GARCH comparator, and finite-sample VaR caveat are visible rather than buried.

### Remaining problems

The clean build is **83 pages**: 22 pages through the Conclusion and 61 pages of supplementary material. The body is more structured, but many paragraphs still carry an entire referee-response chain, and table captions regularly contain methods, caveats, provenance, historical corrections, and conclusions at once. Phrases such as “earlier drafts mixed,” “third-review item,” retired procedures, runner names, and artifact paths belong in a reproducibility note or changelog, not the scientific narrative.

Discussion and Conclusion repeat nearly the whole result panel and sometimes revert to stronger claims than Results. The cross-ticker, ACF, CRPS, copula, and VaR qualifications are individually responsible, but their accumulation makes the paper read as a response dossier rather than a focused contribution.

Recommended body structure:

1. **Question and contribution:** one precise claim about temporal modes versus marginal flexibility.
2. **Model and estimation:** four families plus the shared-`nu` variant, with a single convergence contract.
3. **Evaluation design:** state selection, untouched test policy, metrics, feeds, and baselines.
4. **Single-asset evidence:** marginal fit and horizon-banded ACF, with one valid uncertainty figure.
5. **Risk application:** aligned VaR comparison, 5% tier primary.
6. **Cross-asset application:** cross-sectional-only composition and a 2x2 family/refit experiment.
7. **Scope and conclusion:** feed, finite memory, regime introduction, and no privacy claim.

Specific edits:

- Replace all “statistically indistinguishable” language with the exact test outcome unless an equivalence test is added.
- Remove reviewer-history prose and file paths from main captions.
- Make one statement about the three stylized facts and use it consistently.
- Shorten the Conclusion to synthesis; it currently functions as a second Results/Discussion.
- Update `hyperref` metadata: the compiled PDF title still says “Continuous Hidden Markov Models,” not the new “Continuous-Emission” title.
- Reduce the specification-map language from “declared protocol” to an honest analysis map unless it was timestamped before evaluation.

## Recommended revision order

1. Repair and centralize the shared-`nu` fitter; regenerate its row and CRPS panel.
2. Replace the invalid long-lag ACF bootstrap band and harmonize the ACF claim everywhere.
3. Correct the kurtosis bootstrap inference and all non-rejection/equivalence language.
4. Redesign the block-aware KS calibration or demote KS to a descriptive metric.
5. Run the copula 2x2 family/refit experiment on identical complete blocks.
6. Correct the specification map and protect a genuinely untouched test window.
7. Refresh the manifest/docs and replace substring checks with structured artifact assertions.
8. Decide whether a consistent-feed rerun is required for the headline OoS panel.
9. Tighten the body and captions; move response history to a separate document.
10. Run the full Julia suite, optional R tests, every paper-facing runner, and a clean end-to-end paper rebuild.

## Verification performed

- Reviewed paper commit `ca69b68` and model commit `02d3688`; both worktrees were clean before this file was replaced.
- Read the complete main manuscript and the relevant algorithms, metrics, sensitivity, baseline, cross-asset, and feed appendices.
- Traced headline ACF, spectral, CRPS, copula, VaR, GARCH, vendor, and state-selection claims into current source and artifacts.
- Ran `Pkg.test()`: **7,100/7,100 tests passed** in 5m38s; optional R/MSGARCH tests were not run.
- Ran `runners/diagnostics/run_paper_artifact_check.jl`: it reported all registered checks passing, subject to the checker limitations above.
- Compiled from a clean temporary directory with `latexmk`: success, **83 pages**, no unresolved citations or references; only three underfull boxes in the specification-map table.
- Confirmed the paper and model worktrees remained otherwise unchanged.
