# Renewed Technical Review of the Paper and Model Repository

**Review date:** 2026-07-17  
**Paper commit:** `fcb65e0`  
**Model commit:** `9c8ad5e`  
**Recommendation:** **Targeted major revision before submission**

## Executive assessment

This revision is materially stronger than the preceding one. The invalid free-exponential “capacity ceiling” has been explicitly retracted and replaced with an experiment that optimizes actual, valid Gaussian-emission HMMs. The replacement code enforces a strictly positive row-stochastic transition matrix, computes its stationary distribution, and evaluates the exact population absolute-return ACF. Consequently, the reported three-state error is legitimate evidence of **attainability**: the three-state class contains valid models that reproduce the finite-band sample ACF substantially better than the likelihood-trained fits. The HSMM terminal-boundary mismatch has also been corrected with a right-censored likelihood, a matching simulator, multistart fitting, and unusually good tiny-case enumeration tests.

The paper is nevertheless not ready in its present narrative form. Its central interpretation goes beyond what the replacement experiment identifies. The experiment establishes that a three-state HMM can fit the ACF **in isolation**. It does not establish that marginal fit and ACF fit necessarily compete for the same states, that a good marginal is the necessary cost of a good ACF, or that maximum likelihood “allocates” the states to the marginal. Those stronger claims appear in the abstract, Results, and Conclusion even though the appendix correctly admits that joint attainability has not been tested. This is the main remaining issue and is a claim/evidence mismatch, not a defect in the new population-ACF calculation.

The cleanest resolution is either:

1. narrow the headline claim to finite-band ACF attainability under a different objective; or
2. retain the mechanism claim only after estimating a marginal-versus-ACF Pareto frontier with constrained or weighted joint optimization.

There are also several concrete reproducibility and wording defects: the HMM “certificate” artifact does not save the model parameters or per-start diagnostics, the unrestricted exponential diagnostic does not span every possible HMM ACF shape, all 31 reported `K=18` ACF-targeted fits hit the iteration cap, and the HSMM sensitivity range is misstated as ending at `0.045` when the grid reaches `0.046037`.

## What is now technically sound

### 1. The invalid capacity-ceiling argument was correctly withdrawn

The replacement core in `runners/spectral/acf_capacity_common.jl` parameterizes each transition row through a softmax, exponentiates the emission scales, solves for the stationary law, and evaluates

\[
\rho_{|G|}(h)=
\frac{m^\top\operatorname{diag}(\bar\pi)T^h m-(\bar\pi^\top m)^2}
{\bar\pi^\top M-(\bar\pi^\top m)^2}.
\]

This is the correct population ACF for conditionally independent HMM emissions. Every finite objective value returned by this parameterization corresponds to a valid, irreducible, aperiodic HMM. The achieved error is therefore an upper bound on the class's best possible error and proves existence at the achieved level. The code is appropriately explicit that it does **not** prove global optimality (`acf_capacity_common.jl:4-19`, `:115-156`, `:175-218`).

The reported panel medians reproduce consistently across the artifact gate:

| Fit | Near band, lags 1-63 | Far band, lags 64-252 |
|---|---:|---:|
| Likelihood HMM, `K=3` | 0.0497 | 0.0245 |
| Likelihood HMM, `K=18` | 0.0551 | 0.0224 |
| ACF-targeted valid HMM, `K=3` | 0.0162 | 0.0162 |
| ACF-targeted valid HMM, `K=18` | 0.0140 | 0.0154 |

The defensible conclusion is: **the three-state class can attain a median near-band error of about 0.016 on these sample curves when the ACF alone is optimized.**

### 2. The HSMM finite-window likelihood is now self-consistent

The new HSMM E-step treats the last segment as ongoing at the sample endpoint and weights it by the duration survival probability. The simulator draws an ordinary duration and truncates only the observed terminal segment. Those conventions now match (`runners/baselines/hsmm_core.jl:103-259`, `:420-464`).

The strongest validation is `test/test_hsmm_core.jl:23-123`, which enumerates every segmentation of a small series and checks the likelihood, state occupancies, transition counts, completed-duration counts, censored-duration counts, and initial-state posterior against the dynamic program to approximately machine precision. Separate tests check duration survival, censored-update behavior, EM monotonicity, and the multistart contract (`test_hsmm_core.jl:125-177`). This directly resolves the earlier estimator/generator boundary error.

### 3. The HSMM optimizer and specification limitations are mostly disclosed

The headline Pareto-HSMM rows now use five starts at `K=3` and three at `K=18`; the runner persists the fitted models, likelihood histories, parameters, and per-start diagnostics (`run_hsmm_ml.jl:126-190`). The appendix calls them local-EM fits, reports the likelihood spreads, states that the persistent exponent is at the lower search bound, and discloses that the `D_max x alpha-floor` grid uses one canonical start per cell (`sections/sensitivity_appendix.tex:424`). These are appropriate limitations.

### 4. General empirical scope is substantially more honest

The manuscript now distinguishes in-sample from held-out ACF behavior, reports that the typical single-name OoS fit loses to the zero-ACF reference, limits the successful clustering statement to lags 1-63, and states that finite HMMs cannot reproduce non-geometric asymptotics. It also separates converged spectral fits from fixed-compute `K=18` rows elsewhere. These changes improve both technical accuracy and reader trust.

## Findings requiring revision

### Major 1 — the central “axes compete and ML sides with the marginal” mechanism is not identified

**Locations:** `paper.tex:146`; `sections/results.tex:30`; `sections/conclusion.tex:1,7`; `sections/sensitivity_appendix.tex:154,159-160`.

The ACF-only optimizer returns a valid three-state solution with low ACF error and low excess kurtosis. The likelihood fit returns a different solution with worse ACF error and better marginal behavior. This comparison proves that the likelihood criterion did not select the demonstrated ACF solution. It does **not** prove any of the following:

- all three-state solutions with similarly good ACF fit have poor marginals;
- all three-state solutions with good marginals have poor ACF fit;
- no three-state solution fits both axes well;
- the state count, rather than optimization or objective mismatch, is irrelevant to the joint task;
- maximum likelihood made a causal “allocation” decision in favor of the marginal.

The paper itself concedes the missing step: “whether a three-state chain can serve both axes simultaneously is not established” (`sensitivity_appendix.tex:154`) and “it does not establish that both axes are jointly attainable” (`results.tex:30`). Those sentences contradict the abstract's and conclusion's categorical claims that the axes compete and that the binding constraint has been identified.

This distinction matters. If three states are sufficient for either axis separately but insufficient for both together, then the state budget may be binding for the paper's **joint** modeling goal. The present experiment cannot distinguish that case from a genuine objective-allocation effect.

**Required correction, minimal-computation path:** replace the mechanism language throughout with something equivalent to:

> ACF-targeted optimization shows that the valid three-state HMM class can attain median finite-band ACF error around 0.016, whereas likelihood-trained fits attain 0.050. Thus the fitted likelihood solutions do not exhaust the class's ACF capability. The ACF-targeted solutions found here have poor marginal kurtosis, which suggests—but does not establish—a marginal/dependence trade-off; joint attainability was not tested.

**Required evidence if the stronger mechanism claim is retained:** estimate a Pareto frontier. For example, minimize ACF error subject to explicit bounds on marginal log likelihood, analytic mixture-CDF distance, tail quantiles, or robust kurtosis; alternatively sweep a predeclared weighted objective. Save every nondominated fit. The needed evidence is that improving one axis forces deterioration on the other across the relevant solution set, not merely that one unconstrained ACF solution has a weak marginal.

### Major 2 — the `K=3` versus `K=18` result does not establish global non-binding or equivalence

**Locations:** `paper.tex:146`; `sections/results.tex:30`; `sections/sensitivity_appendix.tex:154,160`; model artifact `results/diagnostics/hmm_acf_capacity.csv`.

The comparison is between achieved heuristic optima, not class optima. The paired median gap is `+0.0019`, but no practical-equivalence margin was specified. More importantly, the artifact shows:

- `K=3`: 25/31 best-start runs early-stopped on a 300-iteration objective stall; 6/31 hit the cap.
- `K=18`: **0/31** early-stopped; all 31 hit the 4,000-iteration cap.
- the `K=18` stationary laws are often near-degenerate (median minimum stationary mass about `3.9e-5`).

The paper mentions a loose `K=18` certificate but understates this as “most” fits hitting the cap (`sensitivity_appendix.tex:154`); it is all of them. Also, the runner's `converged` flag means stalled objective improvement, not a gradient- or stationarity-based convergence test (`acf_capacity_common.jl:175-218`).

The valid `K=3` attainment result survives these limitations. The stronger comparison should be recast as **practical achieved accuracy under the declared optimizer**, not proof that the decay-mode budget is globally non-binding. If a near-equivalence claim is important, declare a tolerance and obtain adequately optimized `K=18` fits with gradient norms or another first-order diagnostic.

### High 3 — the shipped “attainability certificate” cannot be reconstructed from its artifact

**Locations:** `runners/spectral/run_hmm_acf_capacity.jl:124-157,169-240`; `results/diagnostics/hmm_acf_capacity.csv`; `hmm_acf_capacity.txt:35-36`.

The CSV stores summary errors, kurtosis, minimum stationary mass, and a few eigenvalue magnitudes. It does **not** store:

- the transition matrix `T`;
- stationary probabilities `pi`;
- emission means and scales;
- the full fitted population ACF;
- initial and final objective values for each start;
- per-start iteration counts or stop flags;
- `sse_mlseed`, although the runner computes it at `run_hmm_acf_capacity.jl:134-138`.

The text artifact nevertheless says “per-ticker per-start diagnostics in the CSV,” which is false. Because the parameters are discarded after the run, a reader cannot verify that a reported row is a valid HMM or reproduce its ACF from the shipped result. The code can rerun the expensive experiment, but the artifact itself is not a certificate in the ordinary reproducibility sense.

Persist a JLD2 or long-form CSV containing `T`, `pi`, `mu`, `sigma`, all 252 fitted ACF values, the target curve identifier/hash, and all start diagnostics. Add an artifact test that reloads each winning model and rechecks row sums, positivity, stationarity, population ACF, SSE, and band MAEs.

### High 4 — the “likelihood-fit seed” is not the converged multistart fit used in the comparison

**Locations:** `sections/results.tex:30`; `run_hmm_acf_capacity.jl:52,124-138`; `acf_capacity_common.jl:225-238`.

For each ticker and state count, the capacity runner creates a fresh, single quantile-initialized Baum-Welch fit capped at 1,000 iterations and uses it as start 2. The likelihood comparison rows reported in the paper come from the separate converged multistart spectral experiment. Therefore the seeded-start guarantee applies only to the internal single-start fit, not necessarily to the exact converged likelihood fit whose medians are shown next to the capacity result.

This does not invalidate the achieved ACF-targeted errors, but the prose “one start seeded at the likelihood fit” is ambiguous and the claimed no-worse guarantee is not linked to the published comparison fit. Load the saved converged multistart models as seeds, or label the current seed precisely and persist `sse_mlseed`.

### High 5 — the exploratory exponential diagnostic does not contain every HMM ACF curve

**Locations:** `sections/sensitivity_appendix.tex:156-157`; `runners/spectral/run_exp_mode_diagnostic.jl:13-23,142-151`; `runners/spectral/exp_mode_common.jl:14-45`.

The diagnostic uses seven fixed oscillation angles and a finite decay grid, with local refinement of `lambda` but not `theta`. HMMs can have complex eigenvalues with continuously varying angle. In addition, the manuscript's own theory notes that non-diagonalizable transition matrices produce polynomial-times-geometric Jordan terms (`sections/theory.tex:10`), which this dictionary omits. It is therefore incorrect to say that the fitted class “contains all `K`-state HMM ACF curves.”

The subsequent “little headroom is lost to HMM feasibility” inference is also unsupported: the heuristic unrestricted two-mode fit has median near-band error `0.0169`, which is worse than the supposedly nested valid-HMM result `0.0162`. That ordering demonstrates that the heuristic output is not a useful optimum-based bracket.

Keep the diagnostic exploratory, describe it as covering **representative signed real and fixed-angle oscillatory exponential shapes for diagonalizable chains**, and delete the containment and headroom claims. None of the central valid-HMM attainability evidence depends on this diagnostic.

### Moderate 6 — raw kurtosis alone cannot carry the marginal “cost” claim

**Locations:** `paper.tex:146`; `sections/results.tex:30`; `sections/sensitivity_appendix.tex:154`; `run_hmm_acf_capacity.jl:79-88,117-138`.

The exact model kurtosis calculation is fine, but the observed comparator is raw sample kurtosis, a noisy statistic that the manuscript elsewhere treats descriptively. A low kurtosis for the one selected ACF solution is useful evidence about that solution; it is not a robust characterization of the marginal frontier or even a complete marginal goodness-of-fit measure.

Report analytic mixture-CDF metrics, marginal log likelihood, tail exceedance/quantile errors, and preferably a robust tail statistic in addition to kurtosis. Most importantly, evaluate these measures across the nondominated ACF solutions rather than only the single lowest-SSE winner.

### Moderate 7 — “exact censored duration update” overstates the numerical maximization

**Locations:** `sections/results.tex:45`; `src/Compute.jl:537-600`; `test/test_hsmm_core.jl:125-154`.

With censored counts, the code explicitly says concavity is not guaranteed. It samples a 64-point log grid, brackets the best grid point, and applies golden-section search only within that local bracket. Without a proof of unimodality or an exhaustive global method, this is not an “exact” M-step. The tests validate one censored-count example against a fine grid and the observed EM traces are monotone, which is good empirical evidence but not a global guarantee for arbitrary expected counts.

Change the main text to “grid-bracketed censored duration update” or “numerically maximized censored duration block.” If exact EM is essential, prove the objective's relevant shape or use a globally certified one-dimensional maximizer and test it over randomized expected-count configurations.

### Moderate 8 — the HSMM sensitivity headline is numerically wrong and locally confounded

**Locations:** `sections/results.tex:45`; `sections/conclusion.tex:5`; `results/hsmm_ml/hsmm_ml_sensitivity.csv`; `run_hsmm_ml.jl:193-217`.

The full grid ranges from `0.038579` to `0.046037` in IS absolute-return ACF-MAE. At three decimals the range is `0.039-0.046`, not `0.039-0.045`. The latter is repeated in Results and Conclusion.

The grid also uses one canonical start per cell while the headline row is multistart. The appendix discloses this, but changes across `D_max` and the exponent floor remain partly confounded with local-optimum selection. The grid is acceptable as descriptive sensitivity; it should not be presented as isolating a causal duration-law effect unless each cell receives comparable multistart treatment or a common warm-start protocol.

### Minor 9 — state the initial-segment convention in the manuscript

`run_hsmm_ml.jl:31-33` states that the first sojourn begins at `t=1`, with no equilibrium left-censoring. This is a legitimate finite-window convention, but an arbitrary market-data window is not generally observed at a renewal boundary. Add the convention to the appendix near the terminal-censoring description. Its impact is probably small for the long in-sample series, but it belongs in the specification.

## Narrative flow and presentation

The revision has a clearer intellectual arc than the preceding draft: theory states the finite-mode restriction; fitted spectra show what likelihood estimation selected; the valid-HMM experiment tests finite-band ACF attainability; and the HSMM illustrates what changes under explicit durations. The held-out sign reversal and the far-band failure are also handled candidly.

The remaining narrative problem is concentration of too many logical steps into a few very long paragraphs and sentences:

- The abstract (`paper.tex:146`) combines method, several headline results, causal interpretation, scope bounds, VaR, copulas, and deployment advice in one paragraph. The unsupported mechanism claim is visually buried inside it.
- `sections/results.tex:30` combines experimental design, four median comparisons, held-out behavior, a mechanism claim, and the caveat that joint attainability is unknown. Split it into “ACF attainability,” “comparison with likelihood fits,” and “interpretation/limitations.”
- `sections/conclusion.tex:1` remains a page-scale paragraph. Separate supported findings from interpretations and open questions.
- The appendix is often more precise than the main text. In particular, its admission that simultaneous marginal/ACF attainability is untested should govern the abstract and conclusion, not merely qualify them later.

Suggested result order:

1. **Class attainability:** valid `K=3` HMMs achieve median ACF MAE around `0.016`.
2. **What likelihood selected:** converged likelihood fits have larger ACF error and changing `K` does not reliably improve it across windows.
3. **What is not identified:** the cause of that gap and joint marginal/ACF feasibility remain open.
4. **Exploratory clues:** the selected ACF-only solutions have weak marginal tails; this motivates a Pareto experiment.
5. **Structural boundary:** the far-band and non-geometric limitations remain.

This order preserves the genuine new result without turning a suggestive pattern into a causal conclusion.

## Code and artifact quality

### Positive observations

- The replacement HMM objective is compact, readable, and mathematically aligned with the paper.
- The code distinguishes achieved feasible values from certified global minima.
- The HSMM E-step tests are substantially stronger than ordinary smoke tests.
- HSMM headline models include parameters, traces, diagnostics, truncation, bounds, and the censoring convention in JLD2 artifacts.
- The artifact manifest contains no stale, untraced, pending, or defect statuses across its 54 entries.
- The paper-to-artifact gate passes all configured substring and keyed checks.

### Remaining quality improvements

- Promote HMM capacity outputs to the same artifact standard as the HSMM outputs.
- Replace the capacity runner's misleading `converged` name with `stalled` or store both `stop_reason` and a genuine first-order convergence diagnostic.
- Add a test that reloads every persisted HMM capacity winner and verifies its claimed certificate.
- Expand the artifact gate to test ranges/aggregates, not just selected values; it currently passes while missing the `0.045` versus `0.046` HSMM range error.
- Remove review-round metadata such as “seventh review” from scientific runner descriptions after stabilization; retain development history in `CHANGELOG.md` or commit history.

## Verification performed for this review

| Check | Result |
|---|---|
| Paper-to-artifact consistency gate | **PASS** — all configured checks pass; manifest clean across 54 rows |
| LaTeX rebuild (`make -B`) | **PASS** — 88-page PDF produced |
| Undefined references/citations | **None** |
| Overfull boxes | **None** |
| Layout warnings | Three underfull boxes in the Results table area; non-blocking |
| Full Julia package test suite | **PASS** — 7,221/7,221 tests in 8m44.7s; optional R-side MSGARCH MCMC tests were not enabled |

The rebuilt `paper.pdf` was used only for verification; the committed PDF should remain unchanged apart from an intentional manuscript rebuild.

## Prioritized revision checklist

### Submission blockers

1. Narrow or substantiate the joint marginal/ACF competition and ML-allocation claim.
2. Recast `K=3` versus `K=18` as achieved heuristic accuracy unless equivalence and convergence are established.
3. Persist the actual HMM capacity models, curves, and per-start diagnostics.
4. Remove the false full-span and headroom claims from the exploratory exponential diagnostic.

### Accuracy corrections

5. Change the HSMM grid range to `0.039-0.046` (or report `0.0386-0.0460`).
6. Replace “exact censored update” with “grid-bracketed numerical update,” unless global maximization is established.
7. Say explicitly that all 31 `K=18` ACF-targeted winners hit the iteration cap.
8. Clarify that the likelihood seed is a fresh single-start fit, or seed from the published converged fits.
9. Add the HSMM initial-segment/no-left-censoring convention to the paper.

### Narrative edits

10. Split the abstract, Results capacity paragraph, and first Conclusion paragraph by evidentiary function.
11. Make the main text no stronger than the appendix's joint-attainability caveat.
12. Present the poor marginal of the ACF-only winner as an exploratory clue, not an identified necessary cost.

## Bottom line

The revised repositories now contain a valid and valuable result: a properly parameterized three-state Gaussian HMM can fit the observed finite-band absolute-return ACF much better than the likelihood-trained models do. The censored HSMM correction is also technically credible and well tested. The remaining major revision is to align the story with those results. At present, the code proves **ACF attainability in isolation**, while the paper claims **a jointly binding trade-off and a causal objective-allocation mechanism**. Fixing that gap—by narrower prose or a genuine Pareto-frontier experiment—would leave a substantially more defensible paper.
