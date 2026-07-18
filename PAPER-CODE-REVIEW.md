# Renewed Technical Review of the Paper and Model Repository

**Review date:** 2026-07-17

**Paper commit:** `e25d5d5`

**Model commit:** `922eb65`

**Recommendation:** **Targeted moderate revision before submission**

## Executive assessment

The eighth-response revision resolves the major defects identified in the previous review. The invalid exponential “capacity ceiling” remains retracted; the valid-HMM capacity results are now persisted as full model certificates and reload-verified; the `K=18` optimizer limitation is stated accurately; the exploratory exponential diagnostic no longer claims to contain every HMM ACF; and the HSMM range, numerical-update wording, and initial-segment convention are corrected.

The new marginal-versus-ACF sweep also adds a real result. Its `lambda=0.1` arm contains valid, nondegenerate three-state Gaussian HMMs that attain a cross-ticker median near-band ACF error of `0.0165` while fitting the empirical distribution body well under the runner's CDF criterion. This is stronger than the former single-point argument and supports the existence of models that fit both measured axes at useful levels.

The remaining problems are narrower but should be fixed before submission:

1. the frontier's “likelihood fit” comparator is a fresh **single-start** Baum-Welch fit, not the published converged multistart likelihood fit invoked throughout the surrounding paper;
2. the manuscript calls the weighted-sweep outputs “near-optimal” frontier points and multistart “optima,” although almost every important weighted arm stopped at the 4,000-iteration cap with no first-order convergence certificate;
3. the joint-regret aggregation is implemented as two separate cross-ticker medians, which does not by itself ensure that the same typical ticker is good on both axes;
4. the conclusion should be scoped to the in-sample, 500-point CDF criterion rather than generalized to “the bulk marginal” without qualification; and
5. the Introduction still says the “distributional channel binds,” contradicting the new body-fit result and the explicit statement that tail-versus-ACF attainability remains open.

These issues do not invalidate the achieved valid-HMM fits. They require comparator alignment, more exact optimizer language, and narrative reconciliation. The paper is considerably closer to technically defensible submission than in the previous pass.

## What the revision fixed successfully

### 1. Capacity certificates are now genuine reproducibility artifacts

The capacity runner now persists 62 JLD2 files: one for every ticker and `K in {3,18}`. Each contains the transition matrix, stationary probabilities, Gaussian emission parameters, fitted and target ACF curves, summary errors, start diagnostics, and the internal likelihood-seed error (`runners/spectral/run_hmm_acf_capacity.jl:114-160`).

`test/test_spectral.jl:164-193` reloads all 62 certificates and checks:

- row-stochastic and strictly positive transitions;
- positive emission scales;
- the stationary-law residual;
- exact reconstruction of the stored population ACF;
- SSE and band-MAE agreement with the CSV; and
- the no-worse-than-seed bookkeeping.

This directly resolves the previous situation in which the CSV called itself a certificate while omitting the actual model.

### 2. Optimizer status is now described honestly for the capacity experiment

The misleading `converged` flag has been replaced by `stop_reason`, distinguishing objective stall from iteration-cap exhaustion (`acf_capacity_common.jl:175-219`). The paper now states that all 31 `K=18` winners hit the cap, that the `K=3` stall rule is not a stationarity test, that the `K=18` stationary laws are near-degenerate, and that `K=3` versus `K=18` is achieved accuracy rather than class-level equivalence (`sections/results.tex:30`; `sections/sensitivity_appendix.tex:154`).

The core attainable result remains valid: every reported capacity row is a feasible HMM, so the `K=3` median near-band error of `0.0162` proves existence at that achieved level even without global optimization.

### 3. The exponential diagnostic is now correctly scoped

The manuscript now explicitly says the dictionary contains representative fixed-angle exponential shapes, not all HMM ACF curves, and acknowledges both continuously varying complex angles and Jordan polynomial-times-geometric terms (`sections/sensitivity_appendix.tex:159-160`). It also deletes the invalid headroom/bracketing inference. This is technically correct and leaves the diagnostic in an appropriate exploratory role.

### 4. The HSMM corrections are accurate

The main text now calls the censored duration block a grid-bracketed numerical update rather than exact global maximization. The sensitivity range is corrected from `0.039-0.045` to `0.039-0.046`, and the automated gate recomputes both extrema from all grid rows. The appendix states that the initial sojourn begins at `t=1` with no equilibrium left-censoring (`sections/sensitivity_appendix.tex:424`).

The underlying right-censored forward-backward recursion and exhaustive tiny-case tests remain technically strong.

### 5. The new frontier artifacts are materially better than summary-only evidence

The model repository persists 31 frontier JLD2 files containing all nine arm winners, full model parameters, fitted curves, the CDF grid, and per-start diagnostics. Reload tests verify stochasticity, stationarity, the population ACF, near-band error, and CDF metric (`test/test_spectral.jl:195-216`).

An additional inspection in this review found no stationary-weight collapse in the headline `lambda=0.1` arm: the minimum state probability across its 93 state weights is approximately `0.014`, with a median around `0.331`. Thus the headline joint-fit result is not being produced by effectively discarding a state.

## Findings requiring correction

### High 1 — the frontier compares against a different likelihood fit from the published one

**Locations:** `paper.tex:146`; `sections/results.tex:32`; `sections/conclusion.tex:1`; `sections/sensitivity_appendix.tex:157`; `runners/spectral/run_hmm_acf_frontier.jl:21-29,121-152`.

The frontier runner's `ml_ref` is a fresh, canonical, single-start Gaussian Baum-Welch fit capped at 1,000 iterations. The paper's surrounding ACF comparisons and spectral conclusions use separately computed converged multistart fits. The capacity paragraph carefully distinguishes these objects (`sections/results.tex:30`), but the frontier paragraph reverts to unqualified phrases such as “the likelihood fit's own” CDF distance and marginal density. In the abstract and conclusion, a reader will naturally understand those phrases as referring to the published converged likelihood fit.

This is not merely naming. The spectral optimizer artifact shows that the canonical start is the best start at only 12/31 `K=3` tickers; three tickers have a cross-start log-likelihood spread above 10 nats, with a maximum of about 31.1 nats. The median spread is negligible, so the aggregate conclusion may survive, but that must be demonstrated using the actual comparison object.

**Required correction:** load or recompute the exact converged multistart `K=3` fits used in the spectral panel, persist their full parameters, and evaluate their CvM-type distance, stationary-mixture marginal log likelihood, kurtosis/tail measures, and quantile errors in the frontier artifact. Use those rows in the paper. If the single-start reference is retained, label every comparison explicitly as “the internal single-start reference,” including in the abstract and conclusion.

The SPY balance scale `s` is also set from that single-start reference. This is less serious because the sweep spans several orders of magnitude in `lambda`, but it should be aligned with the final reference for internal consistency.

### High 2 — “near-optimal frontier” and “multistart optima” overstate the optimizer evidence

**Locations:** `paper.tex:146`; `sections/results.tex:32-34`; `sections/conclusion.tex:1`; `sections/sensitivity_appendix.tex:157`; `runners/spectral/run_hmm_acf_frontier.jl:37-40,219-220`.

The weighted-arm stop counts from `hmm_acf_frontier.csv` are:

| Arm | Objective stall | Iteration cap |
|---|---:|---:|
| `lambda=0` | 25 | 6 |
| `lambda=0.1` | 2 | 29 |
| `lambda=0.3` | 2 | 29 |
| `lambda=1` | 2 | 29 |
| `lambda=3` | 2 | 29 |
| `lambda=10` | 1 | 30 |
| `lambda=30` | 0 | 31 |
| `lambda=100` | 0 | 31 |
| pure marginal | 12 | 19 |

Objective stall is itself not a first-order stationarity certificate. Therefore these outputs are valid **achieved feasible points**, but most are not demonstrated weighted-objective optima and should not be called such. The pure-marginal endpoint is particularly important: its optimization contains redundant transition-matrix directions and 19/31 winners hit the cap, so it is not a strong proxy for the best achievable three-Gaussian-mixture CDF fit.

The existence result survives. A valid model with ACF MAE `0.0165` and low measured CDF error is still a valid existence witness. What does not survive unchanged is “simultaneously near-optimal” at the class level, because both regrets are normalized to the best values found by incomplete heuristic searches.

**Required correction, no rerun:** replace “frontier optima,” “near-optimal,” and “all frontier points are achieved multistart optima” with “weighted-sweep feasible fits,” “close to the best values achieved in the sweep,” and “valid achieved points.” State the cap counts in the appendix.

**Stronger correction:** optimize the marginal endpoint directly as a stationary three-Gaussian mixture, use an optimizer with a gradient/stationarity diagnostic for the weighted arms, and retain the existing multistart sensitivity.

### Moderate 3 — separate median regrets do not establish same-ticker joint performance

**Locations:** `run_hmm_acf_frontier.jl:31-36,197-209,239-250`; `sections/sensitivity_appendix.tex:157`.

The reading rule computes, for each arm:

`median(ACF regret)` and `median(CvM regret)`

and then tests whether both medians are at most 1.5. In general, those two medians can be supported by different subsets of tickers; the rule does not directly report the typical per-ticker joint regret. The appropriate panel summary is one or both of:

- `median_ticker(max(ACF_regret_ticker, CvM_regret_ticker))`; and
- the count/share of tickers for which both regrets are at most 1.5.

This review recomputed those quantities from the CSV. The result is favorable to the paper: for `lambda=0.1`, the median per-ticker maximum regret is about `1.173`, and 24/31 tickers satisfy both thresholds. For `lambda=0.3` and `lambda=1`, 25/31 satisfy both. Thus the claimed typical joint behavior appears to hold, but it should be computed and persisted by the runner rather than inferred from a weaker aggregation rule.

Add these statistics to the text artifact, CSV gate, and paper. This would turn a methodological objection into supporting evidence.

### Moderate 4 — scope the body-fit claim to its exact in-sample criterion

**Locations:** `paper.tex:146`; `sections/results.tex:32-34`; `sections/conclusion.tex:1,7`.

The marginal objective is a CvM-type mean squared CDF discrepancy evaluated on 500 in-sample empirical quantiles. It is a reasonable distribution-body measure, but it is not a general certificate of marginal adequacy. It intentionally places little emphasis on the 1% and 99% tails, is evaluated on the same data used for optimization, and has no held-out or resampling uncertainty assessment in this experiment.

The strongest defensible wording is:

> Under the in-sample 500-quantile CDF criterion, the weighted sweep found valid three-state models with ACF error close to the best achieved ACF arm and body-CDF error below the internal likelihood reference. This rejects a necessary trade-off between those two measured targets at the achieved levels; it does not establish a general absence of marginal/dependence trade-offs.

The abstract's categorical “the autocorrelation and the bulk marginal do not compete at three states” should at least add “under this in-sample CDF criterion.” The conclusion's claim that the experiments “locate the limitation outside the class” is too broad while tail-and-ACF joint attainability remains explicitly unresolved.

### Moderate 5 — the Introduction contradicts the new result

**Location:** `sections/introduction.tex:1`.

The Introduction still states:

> on our non-outlier-reduced data the distributional channel binds instead.

The new Results say the marginal body does **not** bind or compete with the ACF under the frontier criterion, while the deep-tail question is neither established nor excluded. Those statements cannot all stand without defining “distributional channel” more narrowly.

Replace the Introduction sentence with something such as:

> On our non-outlier-reduced data, the likelihood fits improve the marginal tail while leaving finite-band ACF capacity unused; the body marginal is jointly attainable with the ACF under the frontier criterion, while tail-and-ACF joint attainability remains open.

Also narrow `sections/conclusion.tex:1` from “locate the limitation outside the class” to “show that the observed finite-band ACF gap is not a class-capacity limit at the achieved body-fit level.”

### Moderate 6 — the “deep tail” evidence should not lean on raw excess kurtosis

**Locations:** `paper.tex:146`; `sections/results.tex:23,32`; `sections/sensitivity_appendix.tex:157`.

The manuscript correctly states that the observed tail index is below four and that raw excess kurtosis has no stable population target (`results.tex:23`). The frontier then foregrounds mixture excess kurtosis `2.3` versus likelihood-fit `7.0` as evidence about the deep tail. That comparison is descriptive and unstable by the paper's own argument.

The 1% and 99% quantile errors are better support for the stated tail gap, though they use only roughly 25 observations per tail at this sample size and remain in-sample. Lead with the paired quantile-error result and label kurtosis descriptive. A serious tail-versus-ACF frontier should use a tail-weighted CDF/quantile loss, exceedance likelihood, winsorized functional, or another finite target, ideally with held-out or bootstrap uncertainty.

### Minor 7 — frontier diagnostics are mislabeled as SSE

**Location:** `runners/spectral/acf_capacity_common.jl:241-302` and the frontier JLD2 diagnostics.

When `fit_acf_hmm` receives the frontier's custom objective, diagnostic fields named `sse_init` and `sse_final`, the return field `sse`, and the local variable `best_sse` actually contain the weighted objective `J_lambda`—or pure CvM for the marginal arm—not ACF SSE. This does not alter model selection because the correct objective is minimized, but it makes the saved per-start diagnostics semantically incorrect.

Rename these generic fields to `objective_init`, `objective_final`, and `objective_value`, or add parallel generic fields while preserving capacity compatibility. The frontier certificate test should recompute each arm's objective and compare it with the saved winning value.

The docstring at `acf_capacity_common.jl:237-239` also still describes the old `converged` diagnostic field rather than `stop_reason`.

## Independent checks of the new frontier result

The following read-only calculations were performed directly from `hmm_acf_frontier.csv` and the persisted JLD2 models:

- `lambda=0.1` improves near-band ACF error over the internal `ml_ref` at 31/31 tickers.
- `lambda=0.1` improves the CvM-type error over the internal `ml_ref` at 31/31 tickers.
- 24/31 tickers have both ACF and CvM regrets at or below 1.5 for `lambda=0.1`.
- The median per-ticker maximum regret for `lambda=0.1` is approximately `1.173`.
- The median paired marginal-density loss relative to the internal `ml_ref` is approximately `0.01133` nats per observation; only 1/31 frontier models exceeds the reference marginal-density score.
- The 5% and 95% quantile errors improve at 21/31 tickers, while the 1% and 99% errors improve at only 5/31 and 6/31, respectively. This supports the manuscript's body-versus-tail distinction.
- The `lambda=0.1` state probabilities are nondegenerate: minimum about `0.014`, median across all state weights about `0.331`.

These checks support a scoped existence statement. They do not resolve the comparator mismatch or turn the capped weighted searches into class-level optima.

## Narrative flow

The Results section is substantially improved. The sequence “ACF attainability -> joint body fit -> interpretation and limits -> held-out scope” is clear and matches the evidentiary hierarchy. The appendix is also much more candid about the capacity and exponential-diagnostic limitations.

Remaining narrative issues:

- The abstract remains an extremely dense single paragraph containing the model, four empirical findings, frontier interpretation, tail caveat, long-memory boundary, VaR, copulas, vendor drift, and production advice. Shorten it and keep only one sentence for the frontier result.
- The first Conclusion paragraph is still page-scale and combines supported results with class-level interpretation. Split it into finite-band ACF, body/tail frontier, and generalization limits.
- Reconcile the stale “distributional channel binds” sentence in the Introduction with the new body-fit result.
- Use one stable vocabulary: “internal single-start reference,” “published converged multistart likelihood fit,” “valid achieved weighted-sweep fit,” and “best achieved arm.” Avoid using “the likelihood fit” or “frontier optimum” for multiple objects.
- The appendix repeats substantial portions of Results verbatim. It should retain design details, optimizer counts, certificate descriptions, and full limitations while the main text carries the compact result.

## Overall code quality

The model code is in strong condition for a research repository:

- valid-HMM constraints are explicit and correctly implemented;
- population ACF computation matches the HMM moment identity;
- capacity and frontier models are persisted rather than represented only by summaries;
- certificate tests reconstruct the core reported metrics;
- HSMM censoring tests use exhaustive enumeration rather than shallow smoke checks;
- artifact checking now includes aggregate minima, maxima, medians, and counts; and
- review-history notes have largely moved out of scientific runner headers.

The main code-quality weakness is the use of a generic finite-difference Adam routine without first-order diagnostics for claims labeled as a frontier. For existence witnesses this is acceptable. For statements about near-optimality or a Pareto frontier, optimizer termination and endpoint quality need stronger evidence.

## Verification performed

| Check | Result |
|---|---|
| Paper-to-artifact consistency gate | **PASS** — all substring, keyed, and aggregate checks; manifest clean across 55 rows |
| Frontier certificate inspection | **PASS** — all expected files present; headline arm valid and nondegenerate |
| LaTeX rebuild (`make -B`) | **PASS** — 88-page PDF produced |
| Undefined citations/references | **None** |
| Overfull boxes | **None** |
| Layout warnings | Three underfull boxes in the Results table area; non-blocking |
| Full Julia package test suite | **PASS** — 9,558/9,558 tests in 9m05.2s; optional R-side MSGARCH MCMC tests were not enabled |

The rebuilt PDF is a verification output only and should be restored to the committed version so the final workspace change is limited to this review.

## Prioritized revision checklist

### Required before submission

1. Evaluate the frontier metrics on the exact published converged multistart likelihood fits, or label the single-start comparator everywhere.
2. Replace “near-optimal frontier points/multistart optima” with achieved-feasible terminology unless stronger convergence evidence is produced.
3. Add median per-ticker maximum regret and the both-threshold count to the runner, artifact gate, and manuscript.
4. Scope “the body marginal does not compete” to the exact in-sample CvM-type criterion.
5. Reconcile the Introduction's “distributional channel binds” claim and narrow “limitation outside the class.”

### Strongly recommended

6. Lead the tail discussion with quantile errors and demote raw kurtosis to descriptive evidence.
7. Rename the frontier diagnostic objective fields currently labeled `sse_*`.
8. Report weighted-arm stop counts and, if near-optimal language is desired, add gradient/stationarity diagnostics or a stronger optimizer.
9. Shorten the abstract and split the first Conclusion paragraph.

## Bottom line

The repositories now support a credible, useful result: valid three-state HMMs can reproduce the studied finite-band sample ACF at much lower error than likelihood-trained fits, and the weighted sweep finds valid three-state models that simultaneously achieve low ACF error and strong in-sample distribution-body fit under the chosen CDF metric. The previous claim of a necessary marginal-versus-ACF competition has been appropriately withdrawn.

The paper should stop one step short of its current wording. It has demonstrated **achieved joint feasibility under an in-sample body-CDF criterion relative to an internal single-start reference**. It has not demonstrated class-level near-optimality, comparison against the exact published multistart likelihood fits, or the absence of a tail-versus-ACF trade-off. With those distinctions made explicit—and with the stale Introduction claim corrected—the paper would be technically much more coherent and close to submission-ready.
