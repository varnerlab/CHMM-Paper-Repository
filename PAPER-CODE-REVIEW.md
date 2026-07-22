# Paper and Model Repository Review (Eleventh Pass)

**Review date:** 2026-07-21

**Paper commit reviewed:** `40a0a84` (scientific revision in `6430ec4`)

**Model commit reviewed:** `4a98981`

**Scope:** technical accuracy, manuscript-to-code consistency, reproducibility, statistical claim calibration, and narrative flow.

## Overall verdict

I found **no blocking or moderate technical-correctness issue** in the current paper or companion model repository. The tenth-response revision closes the remaining substantive and engineering findings from the prior pass. The central argument is now internally consistent, appropriately scoped, and backed by valid persisted HMMs, traceable artifacts, same-ticker panel statistics, and a strong automated verification stack.

The paper is ready for external peer review. I recommend only a final minor copy-editing pass before journal submission. The remaining observations below concern two residual phrases, optional prose compression, and code-output nomenclature; none changes a reported result or conclusion.

## What changed since the tenth review

The revision successfully:

- replaced categorical “do not compete” language in the abstract, main frontier result, and Conclusion with the achieved-level formulation;
- corrected the claim that likelihood “weights” tail observations, now accurately describing the log-density penalty at observed extremes;
- explained why `lambda=0.1` is the headline arm while reporting that the primary joint statistic is best at `lambda=0.3`;
- added an automated check for the `lambda=0.3` median maximum regret of 1.11;
- removed review-process language from the scientific appendix;
- shortened the abstract from 346 to 281 words;
- split the Results frontier discussion into joint-attainability, deep-tail, and limitations paragraphs;
- split the appendix frontier discussion into design, comparator/rule, result, and optimizer-limit paragraphs;
- reduced duplicated numeric detail in the Conclusion; and
- centralized the published multistart comparator configuration and fitting call in one shared model-repository helper.

These edits materially improve both scientific precision and readability.

## Technical assessment

### 1. The central finite-band ACF claim is technically supported

The capacity experiment optimizes actual stationary Gaussian-emission HMMs:

- transition rows are strictly positive and stochastic through a softmax parameterization;
- emission scales are positive through log parameterization;
- the stationary distribution is recomputed from every candidate transition matrix;
- the population absolute-return ACF uses the correct stationary HMM moment identity; and
- every reported winner is stored with parameters, target and fitted curves, optimizer diagnostics, and reconstructable metrics.

Accordingly, the reported `K=3` near-band ACF MAE of 0.0162 is a valid existence/attainability certificate. The paper correctly avoids treating it as a globally optimal class error.

The comparison with `K=18` is also calibrated correctly: the achieved median difference is small, but all `K=18` capacity winners reached the iteration cap and have near-degenerate stationary mass, so the manuscript calls this achieved accuracy rather than class equivalence.

### 2. The body-plus-ACF frontier result is now stated at the right strength

The paper reports valid achieved three-state fits under the in-sample 500-quantile CDF criterion. At `lambda=0.1`:

| Quantity | Result |
|---|---:|
| Median near-band ACF MAE | 0.0165 |
| Median CDF criterion | 7.237e-6 |
| Published likelihood comparator CDF criterion | 5.178e-5 |
| Median marginal log density | -2.6081 |
| Published comparator marginal log density | -2.5968 |
| Median per-ticker maximum regret | 1.1735 |
| Tickers within 1.5 on both axes | 24/31 |

The same-ticker statistic establishes that the aggregate result is not an artifact of different tickers supporting the two marginal medians. The revised wording—“no necessary trade-off between the two measured targets at the achieved levels under this in-sample criterion”—matches the evidence.

The `lambda=0.1` choice is now transparent: it is the first jointly admissible arm and retains the closest ACF fit. The manuscript also reports the better primary-statistic arm, `lambda=0.3`, with median maximum regret 1.1097 and 25/31 tickers within threshold.

### 3. The deep-tail interpretation is correct and appropriately separate

The paper now leads with the more defensible quantile-error evidence:

- the `lambda=0.1` fit improves on the likelihood comparator at only 5/31 tickers at the 1% quantile and 6/31 at the 99% quantile;
- it improves at 21/31 tickers at each central 5% and 95% quantile; and
- its median 99% quantile error is 0.83 versus 0.23 for the likelihood fit.

Raw mixture excess kurtosis is labeled descriptive, consistent with the paper's tail-index argument that the corresponding observed population moment is unstable. The paper correctly leaves deep-tail-plus-ACF joint attainability unresolved in both directions.

The revised causal sentence is accurate: ordinary likelihood does not explicitly give tail observations larger weights, but the log score strongly penalizes assigning very low density to an observed extreme relative to the equal-quantile CDF loss.

### 4. Long-horizon and held-out limitations remain explicit

The manuscript separates three claims that were conflated in earlier drafts:

1. a three-state HMM can attain a much better fit to the finite in-sample ACF curve;
2. the likelihood-fitted models still fail to reproduce the far-band persistence; and
3. a finite-state Markov chain cannot generate genuinely non-geometric asymptotic memory.

The held-out panel result is not hidden: at the median single-name ticker, the likelihood-fitted `K=3` and `K=18` models both trail the out-of-sample zero-curve reference, while SPY is an exception. This prevents the capacity result from being misread as a generalization claim.

### 5. The comparator refactor resolves the provenance weakness

The new `runners/spectral/ml_multistart_config.jl` is consumed by both:

- `run_spectral_rank_cross_ticker.jl`; and
- `run_hmm_acf_frontier.jl`.

It centralizes the base seed, per-`K` start counts, iteration limit, tolerance, seed schedule, and fitting call. Both runners still construct the in-sample panel identically before invoking the shared helper.

The certificate test now ties every stored frontier comparator to the published spectral optimizer row using:

- winning start index;
- exact winning iteration count;
- best likelihood at artifact precision; and
- cross-start likelihood spread at artifact precision.

This is substantially stronger than the former rounded-likelihood-only link. Because both runners now call the same helper, configuration drift is no longer a credible current failure mode.

The artifacts were not regenerated for this refactor, which is acceptable here: the computational call is behavior-identical, and the stored comparator diagnostics pass the enhanced identity checks across all 31 tickers.

### 6. Broader model-repository correctness remains strong

The repository continues to demonstrate good research-software practice:

- EM routines use the best-evaluated-iterate contract rather than blindly returning the last update;
- spectral components handle complex-conjugate pairs and stationary moments correctly;
- HSMM terminal durations are right-censored and checked against exhaustive tiny-case enumeration;
- VaR backtests distinguish asymptotic, exact-binomial, and finite-sample DQ evidence;
- cross-asset family/refit effects use common targets and strict common random numbers;
- capacity and frontier conclusions are backed by reloadable JLD2 certificates;
- the artifact manifest maps scientific outputs to runners, seeds, and paper locations; and
- the paper pins the exact model commit reviewed here.

I found no newly introduced algebraic, indexing, seed, data-window, or artifact-selection error in the changed code.

## Remaining minor findings

### Minor 1 — two interpretive phrases should use the achieved-level formulation

**Locations:** `sections/results.tex:36`; `sections/conclusion.tex:11`.

Most of the paper now uses the correct wording, but two phrases remain slightly categorical:

- “the marginal body does not trade off against the ACF”; and
- “the marginal body can come along at essentially no ACF cost.”

Nearby text supplies the in-sample and optimizer caveats, so these are not materially misleading in context. For complete consistency, revise them to:

> the sweep finds no necessary marginal-body/ACF trade-off at the achieved levels under its in-sample criterion

and:

> the achieved sweep carries the marginal body with little median ACF cost under its in-sample criterion.

### Minor 2 — the abstract may still exceed a venue-specific limit

The abstract is now approximately 281 words, down from 346, and its narrative is much cleaner. Many journals impose 250-word limits, although no target venue or limit is declared in the repository.

If a 250-word limit applies, remove roughly 30 words by:

- shortening the list of emission families to “four continuous emission families”;
- compressing the optimizer/comparator clause; and
- reducing the two application descriptions to one sentence with no design detail.

This is a submission-format check, not a scientific-flow defect.

### Minor 3 — “Pareto frontier” remains stronger than the code's optimizer status

**Locations:** `runners/spectral/run_hmm_acf_frontier.jl:4,326`; generated frontier summary heading.

The paper itself mostly says “frontier experiment” or “weighted-objective sweep” and clearly labels all points achieved feasible fits. The runner and generated summary still use “Pareto frontier,” which can imply a globally optimized nondominated boundary even though most weighted winners hit the iteration cap.

Consider renaming only the heading/comment to:

> weighted-objective ACF-versus-marginal frontier sweep over achieved feasible HMMs

No artifact values or scientific conclusions need to change.

## Narrative flow

The manuscript's evidentiary sequence is now coherent:

1. select and evaluate the fitted model;
2. describe the fitted spectral structure;
3. demonstrate realizable finite-band ACF capacity;
4. test joint marginal-body/ACF attainability;
5. isolate the unresolved deep-tail axis;
6. disclose held-out and optimizer limits; and
7. distinguish finite-band improvement from the structural long-memory boundary.

The abstract now focuses on the central finding, its boundary, and the two applications. The Results split makes the frontier argument much easier to follow, and the appendix now separates design from interpretation instead of presenting a 467-word block.

One stylistic opportunity remains: the parenthetical explanation for the `lambda=0.1` headline in Results is important enough to be an ordinary sentence rather than a parenthesis. That change would make the result read more deliberately without adding length.

The 90-page length is driven largely by detailed appendices and reproducibility material. It is defensible for a thesis-oriented manuscript, though a journal version may need a main-paper/supplement split.

## Limitations correctly disclosed

The following are limitations rather than correctness defects, and the manuscript states them:

- frontier and capacity optimization are in-sample;
- most weighted frontier winners reach the iteration cap;
- objective stall is not a stationarity certificate;
- the pure-marginal transition parameters are nonidentified and that endpoint is weak;
- cross-ticker summaries are descriptive over a dependent panel;
- the out-of-sample window contains a vendor-feed change;
- no formal privacy guarantee is claimed for synthetic paths;
- exact non-geometric memory lies outside the finite-state Markov class; and
- licensed CRSP and vendor data are not redistributed.

The default Julia suite also excludes the opt-in R-side MSGARCH MCMC path. That is disclosed in the test output, and the verification table should not be read as covering that external optional path.

## Verification

| Check | Result |
|---|---|
| Paper-to-artifact consistency gate | **PASS**: manifest, substring, keyed, aggregate, and typography checks |
| New `lambda=0.3` aggregate gate | **PASS**: median maximum regret 1.1097 rounds to 1.11 |
| Independent frontier counts and regrets | **PASS**: manuscript values reproduced |
| Shared comparator source audit | **PASS**: both runners call the same configuration/helper |
| Comparator certificate identity checks | **PASS** as part of the Julia suite |
| Full Julia package suite | **PASS**: 11,544/11,544 tests |
| LaTeX rebuild | **PASS**: 90-page PDF |
| Undefined citations/references | None |
| Overfull boxes | None |
| Layout warnings | Three underfull boxes in the Results table area; non-blocking |

The build-generated PDF was restored after verification so the requested review file is the only workspace modification.

## Recommended final actions

### Before submission

1. Align the two residual trade-off phrases with the achieved-level wording.
2. Check the target venue's abstract word limit.
3. Move the `lambda=0.1` explanation out of parentheses.

### Optional code/documentation polish

4. Rename the runner's “Pareto frontier” heading to “weighted-objective frontier sweep.”

No further experiment, artifact regeneration, or model-code correction is required based on this review.

## Bottom line

The tenth-response revision succeeds. The paper's main findings are technically supportable, the narrative now matches the evidentiary strength, and the code repository provides unusually strong research-artifact traceability. The shared comparator refactor closes the last meaningful provenance weakness without changing behavior.

Subject to a small wording and venue-format pass, I regard the manuscript and companion repository as technically coherent and ready for external peer review.
