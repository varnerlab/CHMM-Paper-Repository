# Paper and Model Repository Review (Tenth Pass)

**Review date:** 2026-07-18

**Paper commit reviewed:** `57cea34` (scientific revision in `a1267d9`)

**Model commit reviewed:** `7230f71`

**Scope:** technical accuracy, paper-to-code consistency, reproducibility, claim calibration, and narrative flow.

## Overall verdict

The ninth-response revision resolves the substantive findings from the previous review. I found no new blocking mathematical, implementation, or paper-to-artifact contradiction. The central finite-band result is now technically defensible:

- the reported ACF and frontier fits are valid stationary Gaussian HMMs, not unrestricted curve fits;
- the frontier comparator is now the published converged multistart likelihood fit;
- all important frontier language is framed as achieved feasible performance rather than certified optimization;
- the same-ticker joint-regret statistic supports the body-plus-ACF claim for the typical ticker;
- the claim is scoped to an in-sample, 500-quantile CDF criterion;
- the unresolved deep-tail axis is stated explicitly; and
- optimizer failures, panel dependence, held-out deterioration, and the finite-geometric-memory boundary are disclosed.

My recommendation is **minor revision before submission**, primarily for claim precision, comparator-provenance hardening, and prose compression. The remaining items do not overturn the numerical findings.

## What was checked in this pass

This review re-read the revised abstract, Introduction, Results, Discussion, Conclusion, and spectral/frontier appendix; traced the associated frontier, capacity, spectral, and artifact-check code; inspected the generated CSV/JLD2 artifacts and certificate tests; independently recomputed the reported paired counts and regret summaries; ran the paper-to-artifact gate; ran the full Julia package test suite; and rebuilt the PDF.

The detailed frontier checks confirmed:

| Statement | Independent result |
|---|---:|
| `lambda=0.1` beats `ml_multi` on near-band ACF MAE | 31/31 tickers |
| `lambda=0.1` beats `ml_multi` on the CDF criterion | 31/31 tickers |
| Median per-ticker maximum regret, `lambda=0.1` | 1.1735 |
| Both regrets at or below 1.5, `lambda=0.1` | 24/31 |
| Both regrets at or below 1.5, `lambda=0.3` | 25/31 |
| Both regrets at or below 1.5, `lambda=1` | 25/31 |
| Better 1% / 5% / 95% / 99% quantile error than `ml_multi` | 5 / 21 / 21 / 6 tickers |
| Median `lambda=0.1` / `ml_multi` marginal log density | -2.6081 / -2.5968 |

These reproduce the manuscript at its printed precision.

## Previously raised findings now resolved

### 1. The frontier uses the correct published likelihood comparator

The runner now distinguishes:

- `ml_ref`: the internal single-start fit used as an optimizer seed and to define the historical balance scale; and
- `ml_multi`: the converged multistart likelihood fit used by the published spectral panel and by all paper comparisons.

The multistart constants, seed schedule, data path, and fitting routine mirror the spectral runner. The complete comparator parameters and metrics are persisted in every frontier JLD2 file. Certificate tests validate stochasticity, stationarity, positive scales, reconstructed ACF/CDF metrics, and agreement of the best log-likelihood with the spectral artifact.

The manuscript now consistently says “published converged multistart likelihood fit” where the distinction matters. This fixes the former comparator mismatch.

### 2. Optimizer language now matches the evidence

The manuscript no longer calls the weighted-sweep points optima or near-optimal class-frontier estimates. It labels them valid achieved feasible fits and explicitly reports that 29/31 `lambda=0.1` winners and 19/31 pure-marginal winners hit the 4,000-iteration cap. Objective stall is correctly distinguished from a first-order stationarity certificate.

That is the right evidentiary framing. A feasible fitted HMM is sufficient for an existence/attainability statement at its achieved error, even when it does not certify the best possible class error.

### 3. The panel claim now uses a same-ticker joint statistic

The runner persists per-ticker ACF regret, CDF regret, their maximum, and the joint threshold flag. The manuscript reports the median of the per-ticker maximum and the count satisfying both thresholds. This eliminates the earlier logical gap in which separate medians could have been supported by different tickers.

The reported conclusion is supported: the `lambda=0.1` arm has median maximum regret 1.17, with 24/31 tickers within 1.5 on both axes using the same chain.

### 4. The marginal-body claim is now scoped correctly

The paper consistently limits the result to the in-sample empirical-quantile CDF criterion and distinguishes the distribution body from the deep tail. It no longer generalizes the finding to marginal adequacy as a whole.

The extreme-quantile counts now lead the tail discussion. Raw excess kurtosis is retained only as descriptive evidence, consistent with the paper's own tail-index argument that the corresponding population moment is unstable.

### 5. The Introduction, Discussion, Results, and Conclusion now tell the same story

The former “distributional channel binds” contradiction has been replaced by a more precise result:

1. likelihood fits leave finite-band ACF capacity unused;
2. the marginal body and ACF are jointly achievable at the reported levels under the in-sample CDF criterion;
3. deep-tail-plus-ACF attainability is unresolved; and
4. exact non-geometric long-memory behavior remains outside a finite-state Markov chain.

The Conclusion also separates the finite-band ACF result, the body/tail frontier, and generalization limits into distinct paragraphs.

### 6. Frontier diagnostics and artifact checks are materially stronger

The shared optimizer now exposes generic `objective_init`, `objective_final`, and `objective_value` fields while retaining the legacy `sse_*` aliases for capacity compatibility. Tests recompute the weighted objective from every saved winner.

The paper-artifact checker now verifies the new medians, counts, cap status, and source typography. The current manifest contains 55 tracked rows with no stale, untraced, pending, or defect status.

## Remaining findings

### Moderate 1 — “do not compete” is still slightly stronger than the optimizer evidence

**Locations:** `paper.tex:146`; `sections/results.tex:32-34`; `sections/conclusion.tex:3`.

The evidence proves that valid fits exist with strong absolute performance on both measured axes and that most tickers are close to the **best values achieved in this sweep**. It does not establish closeness to the unknown class-wide single-axis optima because most weighted runs hit the iteration cap, and 7/31 tickers fail the declared 1.5 joint threshold at `lambda=0.1`.

The Conclusion already gives the safest formulation: the result “rejects a necessary trade-off between the two measured targets at the achieved levels.” Use that formulation everywhere. In the abstract and Results, replace the categorical “the ACF and the bulk marginal do not compete at three states” with:

> the sweep finds no necessary trade-off between the ACF and marginal-body targets at the achieved levels under this in-sample CDF criterion.

This preserves the contribution without implying a globally resolved Pareto frontier.

### Minor 2 — comparator identity is correct but maintained through duplicated configuration

**Locations:** `runners/spectral/run_hmm_acf_frontier.jl:33-40,91-95,369-389`; `test/test_spectral.jl:196-270`.

The comparator is deterministically recomputed with the same routine, data, start count, iteration limit, tolerance, and seed schedule as the spectral runner. That is technically sound today. The regression test, however, ties it to the spectral artifact only through `ll_best` rounded to four decimals with an absolute tolerance of `1e-3`.

Future edits could let the two runners drift while still producing a near-equal likelihood. Prefer one of:

- factor the multistart constants and comparator-fitting call into a shared helper used by both runners;
- persist the exact published comparator models in the spectral run and load them in the frontier run; or
- add a version/hash plus a stronger parameter- or full-precision-likelihood identity check.

This is a reproducibility-maintenance recommendation, not evidence that the current comparator is wrong.

### Minor 3 — the likelihood/tail causal sentence is imprecise

**Location:** `sections/results.tex:32`.

The sentence saying the likelihood criterion “weights tail observations heavily” is not quite accurate. Ordinary maximum likelihood does not explicitly assign larger observation weights to tail points; its log score can impose a large penalty when a fitted density assigns very low density to an observed extreme. The empirical-quantile CDF loss, by contrast, gives each quantile-grid location equal weight and therefore weak leverage to the deepest tails.

A more precise sentence would be:

> Relative to the unweighted quantile-grid CDF loss, the log-likelihood penalizes very low fitted density at observed extremes; the resulting likelihood fits have better extreme-tail errors but far worse ACF tracking.

### Minor 4 — explain why `lambda=0.1` is the headline arm

**Locations:** `sections/results.tex:32`; `sections/sensitivity_appendix.tex:157`.

The primary per-ticker statistic is actually best at `lambda=0.3` (median maximum regret 1.1097, 25/31 within threshold), not `lambda=0.1` (1.1735, 24/31). The `lambda=0.1` arm is nevertheless a reasonable headline because it preserves the closest median ACF fit: 0.0165, within 1% of the best achieved ACF arm.

Add a short rationale such as “we report the first jointly admissible arm, which retains the closest ACF fit.” Otherwise a careful reader may wonder why the primary statistic's best arm is relegated to a parenthesis.

### Minor 5 — remove review-process language from the scientific appendix

**Location:** `sections/sensitivity_appendix.tex:157`.

“The primary panel summary, added at review, is...” is revision-history language rather than scientific exposition. Delete “added at review.” The surrounding sentence already explains why the statistic is primary.

## Narrative flow and presentation

The logical order is now good: fitted spectra, realizable ACF capacity, joint body/ACF attainability, deep-tail limit, held-out scope, and structural long-memory boundary. Readers can distinguish class capacity from likelihood-fit behavior.

The remaining narrative problem is sentence and paragraph density:

- the abstract is approximately **346 words** in one paragraph;
- the main frontier paragraph in Results is approximately **334 words**;
- the appendix frontier paragraph is approximately **467 words**; and
- the compiled paper is 90 pages.

These passages contain too many nested qualifications for one paragraph. The qualifications are necessary, but the syntax makes the contribution harder to absorb.

Recommended compression:

1. Reduce the abstract to the question, model, two central findings, one boundary, and one application sentence. Move the copula design detail and vendor/refit advice to the paper body.
2. Split the Results frontier paragraph after the joint-regret statistic. Put the tail result and optimizer caveat in separate paragraphs.
3. In the appendix, separate design, comparator/reading rule, results, and optimizer limits.
4. Remove repeated full restatements of the frontier result across Introduction, Results, Discussion, Conclusion, and Appendix. Keep the numerical detail in Results/Appendix and use one-sentence interpretations elsewhere.

The removal of em dashes is complete and machine-enforced. The resulting punctuation is grammatically valid, though some of the former em-dash sentences now rely on long colon/semicolon chains; paragraph splitting will improve readability more than further punctuation substitution.

## Technical assessment of the model repository

The repository is in strong research-code condition.

Strengths:

- the transition parameterization enforces strictly positive row-stochastic matrices;
- stationary laws are recomputed from each candidate transition matrix;
- positive emission scales are enforced by log parameterization;
- the population absolute-return ACF implements the correct stationary HMM moment identity;
- capacity and frontier claims are backed by full model certificates rather than summary CSVs alone;
- certificate tests reconstruct reported ACF, CDF, objective, stationarity, and likelihood-comparator quantities;
- the HSMM right-censoring and tiny-case enumeration tests remain unusually thorough;
- artifact-to-paper checks include keyed values and aggregate minima, maxima, medians, and counts; and
- deterministic seeds and the model commit are disclosed.

Limitations that are now appropriately disclosed:

- the frontier uses finite-difference Adam with no gradient-norm/stationarity certificate;
- most weighted arms terminate at the iteration cap;
- the marginal-only arm has nonidentified transition directions and is a weak proxy for the best stationary three-Gaussian-mixture fit;
- frontier and capacity experiments are in-sample;
- cross-ticker summaries are descriptive over a dependent panel; and
- the licensed raw data are not redistributable, so exact external end-to-end reproduction requires the same data access.

No code change is required for correctness based on this pass. The shared-comparator refactor above is the most useful next engineering improvement.

## Verification

| Check | Result |
|---|---|
| Paper-to-artifact consistency gate | **PASS**: all substring, keyed, aggregate, manifest, and typography checks |
| Independent frontier counts/regrets | **PASS**: all quoted values reproduced |
| Frontier certificate tests | **PASS** as part of the package suite |
| Full Julia package suite | **PASS**: 11,451/11,451 tests |
| LaTeX rebuild | **PASS**: 90-page PDF |
| Undefined citations/references | None |
| Overfull boxes | None |
| Layout warnings | Three underfull boxes in the Results table area; non-blocking |

The optional R-side MSGARCH MCMC tests are not enabled by the default Julia package suite, so the test count should not be read as covering that external optional path.

## Prioritized action list

### Before submission

1. Replace categorical “do not compete” wording with the achieved-level formulation already used in the Conclusion.
2. Correct the “likelihood weights tails heavily” sentence.
3. Explain the choice of `lambda=0.1` or headline the best primary-statistic arm.
4. Remove “added at review” from the appendix.
5. Compress the abstract and split the two frontier mega-paragraphs.

### Engineering hardening

6. Make the spectral and frontier runners consume one shared multistart comparator configuration/model.
7. Strengthen comparator identity beyond rounded best log-likelihood.

## Bottom line

The ninth revision succeeds technically. The earlier comparator mismatch, optimizer overclaim, cross-ticker aggregation gap, body/tail scope problem, and narrative contradiction are fixed. The paper's central result is now supported by valid persisted HMMs, reproducible artifacts, same-ticker joint statistics, and a passing test/gate stack.

What remains is a small calibration pass: say “no necessary trade-off at the achieved levels” consistently, tighten one causal likelihood sentence, explain the representative frontier arm, remove review-history prose, and reduce paragraph density. After those edits, I would regard the paper and companion model repository as technically coherent and ready for external peer review.
