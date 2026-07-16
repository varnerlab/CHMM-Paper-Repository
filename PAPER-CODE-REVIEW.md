# Fresh Technical, Code, and Narrative Review

## Scope and revisions reviewed

**Manuscript:** *Continuous-Emission Hidden Markov Models for Equity Returns: Heavy-Tail Emission Families and Regime-Conditional Value-at-Risk*

**Review date:** 2026-07-16

**Paper repository:** `2f1c0ab` (scientific-content revision `b12bbd5`; the head commit only deletes the preceding review file)

**Companion model repository:** `b281f09`

This is another fresh audit of the current repository heads. I checked the fourth-review response against the implementation rather than accepting the commit summary, reread the main paper and relevant appendices, traced headline values into runners and artifacts, ran the current Julia test suite and consistency gate, and compiled the paper from a clean temporary directory.

## Overall assessment

**Recommendation: targeted major revision before submission.**

The latest response fixes most of the concrete defects from the preceding audit. The shared-`nu` fitter is now a tested library routine with a best-evaluated-iterate contract; the observed ACF band is no longer drawn through lag 252; kurtosis results no longer call `Pr(IS > OoS)` a p-value; the KS sensitivity draws two independent block resamples; CRPS language distinguishes non-rejection from equivalence; the copula comparison is now a nominal `2 x 2` design on common quarter targets; the strict-tail DQ calibration uses 2,000 replications and explicitly covers only two rows; and the provenance gate now rejects known-stale manifest statuses. The core spectral identity, transition update, forecast alignment, likelihood checkpointing, and reported numerical values remain internally coherent.

The paper is therefore much closer to technically defensible than the version covered by the preceding review. The remaining problems are narrower but still touch headline claims:

1. the cross-ticker spectral evidence does not establish that the two-mode budget at `K = 3` is non-binding outside SPY;
2. the quarter-level copula runner claims common random numbers across families but calls the non-CRN simulation interface;
3. the `L = 20` moving-block ACF band is still invalid or strongly attenuated near lag 20, not merely beyond it;
4. ordinary bootstrap inference for sample kurtosis is difficult to justify when the paper's own tail estimate implies that the fourth moment may be infinite;
5. overlapping Hill intervals are still converted into a “matched” tail claim without an equivalence test; and
6. repository-level reproducibility documentation remains partly stale and the artifact gate is not a complete rebuild or semantic verification.

The main CHMM implementation is not the weak point now. The needed revision is primarily about inferential design, exact scope, and aligning the headline narrative with what the diagnostics actually identify.

## Verification results

- **Model tests:** `7,127 / 7,127` passed in `8m38s` under `Pkg.test()`.
- **Optional R baseline:** the opt-in `CHMM_TEST_MSGARCH=1` reference-MSGARCH test was not run; the standard suite explicitly skips it.
- **Paper/artifact gate:** `runners/diagnostics/run_paper_artifact_check.jl` exited successfully.
- **Clean paper build:** `latexmk -pdf -interaction=nonstopmode -halt-on-error paper.tex` succeeded from a clean temporary copy.
- **Build quality:** 84 pages; no unresolved citations or references; three underfull boxes in the specification-map table; no overfull boxes found.
- **PDF metadata:** title, subject, keywords, and authors match the current manuscript.
- **Repository hygiene:** both worktrees were clean before this review file was added; `git diff --check` passed in both repositories.

Passing these gates establishes executable consistency, not validity of every statistical conclusion. The distinctions below are important.

## Corrections that are now technically sound

- **Shared-`nu` estimation:** `src/Compute.jl` now contains `baum_welch_student_t_shared_nu`, evaluates an iterate before mutation, checkpoints the best finite evaluated likelihood, and returns the matching posterior. The two runners now call the library routine rather than carrying divergent private copies.
- **Core EM return contract:** the Gaussian, per-state Student-t, shared-`nu` Student-t, Laplace, and GED paths have regression coverage for returned likelihood/parameter agreement.
- **ACF horizon disclosure:** the manuscript now states directly that the CHMM advantage is at lags 1--63 and that the fitted population ACF is essentially zero at long horizons. The banded MAE table is a valid descriptive comparison.
- **Kurtosis probability label:** `Pr(IS > OoS) = 0.756` is correctly described as a descriptive bootstrap probability, not a null-calibrated p-value.
- **KS sensitivity construction:** each null replication now compares two independent stationary-block resamples instead of comparing a fixed observed series with one resample.
- **CRPS inference:** all ten pairs among the five displayed CHMM rows are covered; HAC confidence intervals are reported; Holm correction is applied; and the manuscript explicitly calls the result a non-rejection rather than equivalence.
- **Copula target pairing:** the four arms are evaluated on the same complete quarter blocks, and the five-day partial block is excluded from inference.
- **VaR alignment and qualification:** CHMM and MS-GARCH use the same 573 forecast targets; the DQ bootstrap scope and lack of parameter re-estimation are disclosed; exact binomial values and paired pinball losses are useful additions.
- **Provenance status gate:** known `STALE`, `UNTRACED`, `pending`, and `defect` statuses now fail the consistency runner.

## High-priority technical findings

### 1. The cross-ticker spectrum does not support the general low-`K` non-binding claim

The algebraic identity in `sections/theory.tex` is correct, and `runners/spectral/spectral_common.jl` reconstructs the direct matrix ACF to numerical precision. The interpretive leap is not.

The manuscript says that the decay-mode budget was not empirically active “at the typical ticker” and repeatedly concludes that the marginal mixture, rather than the ACF mode budget, binds at low state count. But the cross-ticker diagnostic is run only at `K = 18`. Its median dominant-component share is `0.785`, and the median number of grouped components needed for 95% of the absolute lag-1 budget is **four**. A `K = 3` chain can supply at most two non-unit modes. Thus the `K = 18` cross-section does not show that the `K = 3` budget is sufficient at the typical ticker; if anything, its median `n95 = 4` leaves that question open.

The artifact itself contains an older reading rule saying that a median dominant share of at least `0.90` would support generalizing the result beyond SPY. The observed `0.785` does not meet that rule. The manuscript partially acknowledges that the cross-ticker diagnostic was not rerun at `K = 3`, but the abstract, Introduction, and Conclusion still generalize the non-binding conclusion beyond the SPY instance.

There is a second scope issue: components are ranked by absolute contribution at **lag 1**. A component small at lag 1 can matter at later lags if it has a larger eigenvalue or a different phase. A lag-1 budget is not by itself an effective-rank diagnostic for the complete lag-1--252 curve.

**Required correction:** restrict the non-binding conclusion to the fitted SPY models. To generalize, rerun the grouped diagnostic at `K = 3` across tickers and summarize a horizon-aware contribution norm (for example, integrated squared or absolute contribution over the reported lag band), then show that additional modes do not improve out-of-sample ACF loss.

### 2. The quarter-level `2 x 2` copula runner does not use strict CRN across families

`runners/cross_asset/run_cross_asset_rolling_copula.jl:173-181` resets the same global seed and then calls the three-argument `simulate(model, T, n_paths)` method for all four arms. That pairs the seed, but it does not produce strict common random numbers between Gaussian and Student-t copulas:

- the Gaussian sampler consumes base normal draws;
- the Student-t sampler consumes the base normals plus a chi-square mixing stream; and
- each method simulates the CHMM marginal paths only after those copula draws.

The additional Student-t draws therefore shift the random stream, so Gaussian and Student-t arms do not receive identical marginal paths. This matters most for the reported family effects, which are only `0.003`--`0.007`.

The repository already contains the correct solution in `src/CrossAsset.jl:525-604`: the four-argument strict-CRN simulation interface gives base normals, chi-square mixing, and each asset's marginal path separate deterministic streams. The seed-uncertainty runner uses it, but the headline quarter-level `2 x 2` runner does not.

Within-family static-versus-rolling comparisons are much less affected because both arms call the same family sampler and consume the same number of draws. The claimed refit improvement (`0.078`--`0.082`) is also much larger than the family effect, so the qualitative ordering may survive. Nevertheless, the current family contrasts and the claim that all four arms differ only by design factor are not exact.

**Required correction:** call `simulate(model, n_days, N_PATHS, crn_seed)` in every quarter arm, regenerate the four-arm artifact, and add a test asserting that the actual headline runner uses the strict interface. Recompute the family/refit contrasts before retaining “order of magnitude.”

### 3. Restricting an `L = 20` moving-block ACF band to lags `<= 20` is still too permissive

The revision correctly removes the band beyond the block length. It now says the band is valid through lag 20. At lag exactly equal to the block length, however, every resampled lag-20 pair crosses an independently concatenated block boundary; the resample contains no original lag-20 pair. At lags close to 20, only a small fraction of pairs remain inside the same source block, so dependence is strongly attenuated.

The issue is therefore gradual edge contamination, not a sharp validity boundary at `h = L`. A block length used to estimate uncertainty at maximum lag `h` must be materially longer than `h` and should grow with sample size under the bootstrap's asymptotics. A fixed `L = 20` band is defensible only for substantially shorter lags, not through 20.

**Required correction:** either display the current band only over a conservative low-lag range such as 1--5, or select a substantially longer block length and demonstrate sensitivity. If a curve-wide uncertainty statement is desired, use a method designed for dependent ACF estimates and simultaneous inference. Keep the banded MAE table as descriptive evidence.

### 4. The kurtosis bootstrap conflicts with the paper's own heavy-tail diagnosis

The paper reports a Hill estimate near `3.15` and explicitly says that the population fourth moment is plausibly infinite. It then treats the ordinary stationary-block percentile bootstrap interval for sample excess kurtosis as an inferential confidence interval and uses coverage of zero by the IS-minus-OoS difference interval to support a non-rejection.

If the tail index is below four, population kurtosis is not finite, so there is no stable population excess-kurtosis parameter for this interval to estimate. Even when the fourth moment exists, conventional asymptotic inference for sample kurtosis generally needs stronger tail moments; a standard `n`-out-of-`n` percentile bootstrap can be unreliable in the exact heavy-tail regime emphasized by the paper. Dependence-aware blocks do not solve the non-regular tail-functional problem.

The wide interval is descriptively useful as a sensitivity display, but calling it a conventional 95% inferential interval overstates what the assumptions support.

**Required correction:** make excess kurtosis explicitly descriptive, and use a tail-robust target for inference: a trimmed/winsorized fourth-moment functional, quantile-based tail ratio, or a heavy-tail-appropriate subsampling/`m`-out-of-`n` procedure with stated assumptions. Do not use the current percentile interval to test equality of population kurtosis if the paper retains the possible-infinite-fourth-moment interpretation.

### 5. Overlapping Hill intervals do not establish that the simulated tail is “matched”

`sections/results.tex` says that the shared-`nu` simulated Hill band overlaps the observed bootstrap CI, “so the simulated tail is matched.” The two ranges are not the same inferential object: one is an observed-series block-bootstrap interval and the other is an across-simulated-path distribution. Their overlap is neither a confidence interval for the difference nor an equivalence test.

This is the same logical distinction the revised CRPS section now handles correctly. The supported statement is that the observed estimate is compatible with the simulated dispersion at the chosen top-5% threshold. It does not prove equivalence, and it is especially weak as a family discriminator because every emission family yields a similar threshold-local estimate while their far-tail behavior differs structurally.

**Required correction:** replace “matched” with “compatible at this threshold under this descriptive diagnostic,” or construct a paired/bootstrap distribution for the difference and pre-specify an equivalence margin.

## Additional correctness and interpretation findings

### 6. “At the i.i.d. floor” should be “does not beat the i.i.d. floor”

For lags 64--252 the artifact reports CHMM-N MAE `0.0410` and i.i.d. MAE `0.0356`; the CHMM is about 15% worse, not equal. The figure caption and Discussion give the exact values, but the Conclusion says the model “leaves the far band at the i.i.d. floor.” Use the more exact “does not beat the i.i.d. floor” or “is slightly worse than the i.i.d. reference.”

### 7. “Matches/fits the heavy-tailed marginal” remains stronger than the displayed evidence

At the recommended shared-`nu`, `K = 3` setting, simulated IS excess kurtosis is `4.68` against observed `7.68`; the KS score is a conditional descriptive pass rate under serial dependence; and the Hill comparison does not establish equivalence. The model clearly improves on CHMM-N's tail gap and produces a heavy-tailed marginal, but “matches the heavy-tailed marginal” in the abstract and Introduction is too categorical.

**Correction:** say “substantially improves marginal/tail fidelity” or identify the exact metric and tolerance being matched.

### 8. The block-bootstrap KS panel remains a descriptive sensitivity, not a calibrated generator test

Drawing two independent block resamples is the correct repair to the earlier one-fixed/one-resampled construction. The threshold is still conditional on the empirical observed series, assumes both null series share its marginal and short-range dependence, does not refit a candidate generator, and is reused across generators with different dependence structures. It should not be read as a generic dependence-corrected goodness-of-fit test for each fitted model.

The manuscript now states that the values are descriptive, which is appropriate. Keep that qualification wherever the near-100% CHMM pass rates are summarized, and avoid treating the wider critical values as proof that the original asymptotic pass rates are universally conservative.

### 9. Copula inference is appropriately labelled suggestive, but the headline wording should retain that qualifier

The paired t-statistics use only nine adjacent time blocks, and consecutive rolling fits use overlapping 252-day windows. The runner and appendix disclose that no dependence correction is used. The abstract and Conclusion state the order-of-magnitude result without the “suggestive” qualifier. Even after strict CRN is repaired, the result is one basket and nine correlated blocks, so the abstract should say “in a descriptive/suggestive `2 x 2` experiment.”

### 10. The mixed-vendor OoS window remains a binding identification limitation

The manuscript now describes the Polygon-to-Alpaca/IEX switch honestly. Because the source files are date-disjoint, pre/post differences cannot separate vendor effects from calendar-regime effects. Every single-window OoS ranking crosses this switch. The limitation is disclosed but not resolved; a same-date overlap or consistent-vendor rerun is still needed for a clean headline OoS estimand.

## Code and reproducibility findings

### What is strong

- The executable test suite is large and currently green.
- Returned-likelihood checks, spectral reconstruction, forecast indexing, strict-CRN primitives, and artifact-shape tests cover the failures that previously mattered most.
- The shared-`nu` implementation is no longer duplicated.
- The manuscript commit pins the model commit, and the artifact manifest maps the principal tables to runners.
- The headline rebuild script now says explicitly that it is not a complete-paper rebuild.

### Remaining gaps

1. **The model README is stale and overclaims.** It says the CHMM reproduces all three Cont facts, calls Student-t and Gaussian OoS copulas “statistically indistinguishable,” says VaR passes cleanly across families, and labels `run_full_rebuild.jl` an end-to-end rebuild of every paper artifact. Those statements conflict with the current paper and with the rebuild script's own header.
2. **The manifest is not fully verified.** Twelve rows still carry an `unverified` status. The status gate permits this by design, so “ALL CHECKS PASS” does not mean every paper artifact has been independently checked.
3. **Most consistency checks remain substring checks.** Only six values use keyed extraction. A number can still pass by appearing in the wrong row or surrounding prose. The gate does not validate runner commit, input hashes, output hashes, or a clean rebuild.
4. **`RUNNERS.md` contains at least one path mismatch.** It maps `run_kurtosis_bootstrap.jl` to `results/SPY/diagnostics/kurtosis_bootstrap.txt`, while the runner writes `results/diagnostics/kurtosis_bootstrap.txt`.
5. **The optional R baseline is outside the default verification.** That is acceptable if prominently disclosed, but the reference Bayesian rows are still printed in the main table.
6. **A code docstring contradicts the paper's identifiability caveat.** `src/Types.jl` asserts finite GED-mixture identifiability from Yakowitz--Spragins, whereas the paper correctly says it does not prove linear independence for the varying-shape GED family. Align the code documentation with the paper.
7. **The strict-CRN primitive is tested, but its use by the headline `2 x 2` runner is not.** The existing tests verify the four-argument simulator and artifact shape, not that the runner actually invokes that interface.
8. **Minor utility bug:** `_auc` in `src/Metrics.jl` uses `np == 0 || nn == 0 && return 0.5`; because of short-circuit precedence, an empty positive class can fall through instead of returning. Parenthesize the condition. It does not appear to affect the paper artifacts, but it is a real library edge case.

## Narrative-flow review

### Improvements

- The title is precise and no longer suggests continuous latent states.
- The Results section has a coherent order: specification, single-asset generator, cross-asset composition, then VaR.
- The paper now states non-rejection, ex-post selection, feed provenance, finite-sample DQ scope, and long-horizon ACF failure candidly.
- The Conclusion is more synthetic and less repetitive than the preceding version.

### Remaining flow problems

The clean build is 84 pages: the Conclusion ends on page 22, references occupy pages 24--29, and supplementary material runs to page 84. Length alone is not an error, but the scientific through-line is still buried under audit detail.

- The abstract is one very long paragraph carrying model family, spectral mechanism, four evaluation settings, VaR, copula interaction, and two limitations. It should foreground one primary empirical claim and one boundary.
- Several Results paragraphs combine setup, estimates, inference, caveats, provenance, and rebuttal history in a single block. The VaR paragraph is especially difficult to parse on first reading.
- Main-table captions function as mini-method sections. Move estimator conventions and provenance into short notes or the metric appendix.
- The appendices and artifacts retain “third-review,” “fourth-review,” “peer-review item,” retired-method, and response-plan language. This is useful development history but makes the public research package read like a referee dossier. Move it to a changelog.
- The abstract and Conclusion sometimes drop qualifiers that are present in Results (“suggestive,” “descriptive,” “SPY-only”), recreating overclaim at the exact points most readers will see.

## Recommended revision order

1. Regenerate the copula `2 x 2` experiment using the strict four-argument CRN simulator.
2. Restrict the spectral non-binding claim to SPY, or add `K = 3` cross-ticker and horizon-aware diagnostics.
3. Remove the ACF bootstrap band near the block boundary or rebuild it with a defensible longer/data-selected block scheme.
4. Recast kurtosis intervals as descriptive unless a heavy-tail-valid inferential method is supplied.
5. Replace Hill-interval-overlap “match” language with compatibility/non-rejection language.
6. Narrow “matches the heavy-tailed marginal,” “at the i.i.d. floor,” and unqualified copula-order claims in the abstract and Conclusion.
7. Synchronize the model README, `RUNNERS.md`, and `Types.jl` documentation with the current paper.
8. Convert the remaining high-value artifact checks to keyed row/column checks and resolve the twelve `unverified` manifest entries.
9. Condense the main narrative and move review-response history to a changelog or reproducibility note.

## Bottom line

The implementation is now substantially healthier than the narrative risk around it: the current Julia suite passes, the central CHMM and spectral algebra are coherent, the shared-`nu` repair is real, the VaR origins are aligned, and the paper builds cleanly. The remaining submission risk comes from drawing general or equivalence-like conclusions from diagnostics that are narrower than the prose: a SPY-only low-`K` spectral result, a nominal rather than strict-CRN copula interaction, block-bootstrap ACF and kurtosis inference at the edge of their assumptions, and interval overlap described as a match.

After those claims and two affected analyses are corrected, the paper would be technically credible as an empirical comparison with clearly bounded scope. In its current form, the core results are promising, but the abstract-level story is still stronger than the evidence that survives the paper's own caveats.
