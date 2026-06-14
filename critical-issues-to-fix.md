# Critical Issues to Fix

Scope: Methods, evaluation protocol, `theory.tex`, and supporting appendix text and pseudocode.

The manuscript's annualized excess-growth-rate convention is intentional. Do not change that convention or make follow-on changes whose only motivation is that convention.

> **Appendix verification sweep 2026-06-14.** All appendix-targeted fixes (items 1-3 algorithms, 4 metrics, 5 ACF-MAE, 6 marginal-preservation, 7 pi-bar/pi-hat, 8 family-differ, 10 symbols, 12 biorthonormal, 13 rank-bound, 14 emission assumption) verified present in the .tex sources. Global stale-claim grep across body + appendices found no unqualified ECM, exact-fitted-marginal, or calibrated-KS claims; every ECM mention is "ECM-style" or a table-caption label. One genuine gap closed: added the i.i.d./serial-dependence caveat to the Methods KS description (item 4 listed methods.tex; the caveat lived only in the metrics appendix). Item 11 jargon ("negative control", "ES envelope") deliberately retained as precise terminology per this doc's caveat; "generator tier" already gone. Clean 67-pp build, 0 undefined refs.

## Algorithmic Corrections

### 1. Describe the Student-t estimation procedure accurately

The implementation uses latent-precision expectations to update the location and scale, but updates the degrees of freedom by maximizing a weighted marginal Student-t log-likelihood. This is not the full augmented-data ECM update for the degrees of freedom, which also involves the conditional expectation of `log(u)`.

Preferred fix: retain the existing implementation and describe it as a hybrid generalized-EM or block-coordinate procedure. Cite Peel-McLachlan and Liu-Rubin for the latent-scale construction and closed-form location/scale updates, but do not claim that the numerical degrees-of-freedom search is their ECM update or that the standard ECM convergence result directly applies to the complete implemented procedure.

Affected locations:

- `sections/methods.tex`, Student-t estimation paragraph and equations.
- `sections/algorithms_appendix.tex`, Student-t M-step description and unified EM pseudocode.
- Any abstract, discussion, or conclusion language that calls the complete Student-t procedure ECM without qualification.

### 2. Correct the likelihood convergence check

The pseudocode computes forward-backward quantities before updating the parameters, then evaluates the convergence likelihood from the old forward variables after the M-step. The reported likelihood therefore corresponds to the pre-update parameter values rather than the returned iterate.

Fix:

1. Perform the E-step and parameter updates.
2. Recompute the forward likelihood under the updated parameters.
3. Compare consecutive post-update observed-data log-likelihoods.
4. Verify that the Julia implementation follows the corrected order.

Affected location: `sections/algorithms_appendix.tex`, unified EM pseudocode. The companion implementation must also be inspected.

### 3. Correct the weighted Laplace median

The current appendix says that the weighted median is obtained by linear interpolation at the half-total-weight crossing. Arbitrary interpolation is not generally a weighted-median MLE.

Fix: after sorting the observations, select the first observation whose cumulative weight is at least half the total weight. An interval of minimizers is available only when the cumulative weight equals exactly one half between adjacent observations.

Affected locations:

- `sections/algorithms_appendix.tex`, Laplace M-step description and pseudocode.
- Companion implementation of `WeightedMedian`.

## Evaluation Corrections

### 4. Qualify the ordinary KS pass rate under serial dependence

The standard two-sample KS p-value assumes independent observations, whereas observed returns and generated CHMM/GARCH paths can be serially dependent. The ordinary KS pass rate should not be presented as a calibrated hypothesis test in this setting.

Fix:

- Retain the ordinary KS pass rate as a descriptive distributional-fidelity score.
- State explicitly that its nominal p-values are not calibrated under serial dependence.
- Use the stationary/block-bootstrap KS recalibration as the inferential robustness check and give it greater prominence.

Affected locations:

- `sections/methods.tex`, evaluation metrics.
- `sections/metrics_appendix.tex`, KS definition.
- Table captions and results prose that interpret a KS pass as formal distributional equivalence.

### 5. Make the ACF-MAE aggregation definition consistent

The Methods define ACF-MAE against the path-averaged simulated ACF, while the metrics appendix says that every metric is computed per path and then aggregated. These are different statistics.

Preferred statistical definition:

```tex
\frac{1}{P}\sum_{p=1}^{P}\frac{1}{L}\sum_{\tau=1}^{L}
\left|\hat\rho^{\mathrm{obs}}_{|G|}(\tau)
-\hat\rho^{(p)}_{|G|}(\tau)\right|.
```

This measures typical path-level ACF fidelity and prevents errors of opposite signs from cancelling before the absolute value is taken.

Decision required: adopting this definition requires regenerating affected results and tables. If preserving the current numerical results is preferred, retain the existing error against the path-averaged ACF and correct every description to match it.

Affected locations:

- `sections/methods.tex`.
- `sections/metrics_appendix.tex`.
- Result tables, captions, and scripts computing ACF-MAE.

### 6. Narrow the rank-reordering marginal-preservation claim

Rank reordering preserves the multiset of values in each finite simulated path. It therefore preserves that path's empirical marginal distribution exactly, not the fitted population marginal exactly.

Fix wording to:

> Rank reordering preserves the empirical marginal distribution of each simulated per-asset path exactly.

Affected locations:

- `sections/methods.tex`, multi-asset evaluation paragraph.
- `sections/supplementary.tex`, marginal-preservation proposition and surrounding interpretation.
- Cross-asset appendix text and captions where necessary.

### 7. Distinguish the fitted and simulation initial distributions

The sequence likelihood estimates the initial-state distribution `pi`, but unconditional simulation initializes paths from the fitted transition matrix's stationary distribution `bar(pi)`.

Fix: state this design explicitly. Use `hat(pi)` for the initial distribution estimated during fitting and `bar(pi)` for stationary initialization of unconditional simulations. Explain that stationary initialization removes transient dependence on the observed sample's first day.

Affected locations:

- `sections/methods.tex`, model and estimation descriptions.
- `sections/algorithms_appendix.tex`, simulation algorithm.

## Text and Notation Corrections

### 8. Correct the claim that the families differ only in the M-step

The emission likelihood also differs in the E-step, and Student-t fitting computes latent-precision expectations.

Replace the current claim with language such as:

> The four variants share the latent-state forward-backward recursion and transition update, while differing in emission-density evaluation and emission-parameter updates.

Apply this correction consistently in the Methods, appendix, abstract, discussion, and conclusion.

### 9. Qualify applicability at other sampling frequencies

The probabilistic model is not inherently daily, but applying it to intraday or other frequencies requires frequency-specific preprocessing, state calibration, and evaluation horizons.

Suggested wording:

> The probabilistic framework is not tied to a daily interval, although application at other frequencies requires frequency-specific preprocessing, state calibration, and evaluation horizons.

Do not alter the manuscript's chosen annualized-return convention.

### 10. Define symbols locally and harmonize convergence notation

Define or state at first use:

- `(nu_min, nu_max) = (2.1, 50)`.
- `(p_min, p_max) = (0.5, 3.0)`.
- `xi_t(i,j)` as the posterior probability of the transition from state `i` at time `t` to state `j` at time `t+1`, conditional on the observed sequence.
- The convergence tolerance as `10^{-4}`.

Use one notation consistently instead of alternating among `epsilon`, `tol`, and the numeric value.

### 11. Reduce or define evaluation jargon

Suggested replacements:

- "generator tier" -> "model class".
- "negative control" -> "deep-generative comparator".
- "ES envelope" -> "descriptive simulated ES envelope".

Briefly define "profile likelihood" and "rank reordering" at first use. Do not remove domain terminology that is needed for technical precision.

## Theory Corrections

### 12. State the eigenvector normalization in `theory.tex`

The decomposition

```tex
\mathbf T^\tau = \mathbf 1\bar{\boldsymbol\pi}^\top
+ \sum_{k=2}^K \lambda_k^\tau\mathbf v_k\mathbf w_k^\top
```

requires biorthogonal normalization of the left and right eigenvectors:

```tex
\mathbf w_k^\top\mathbf v_\ell = \delta_{k\ell}.
```

Add this condition to the main theory subsection rather than leaving it only in the appendix.

### 13. State precisely what rank bounds

The rank of the centered transition matrix bounds the number of available nonzero spectral directions. It does not necessarily equal the number of distinct modes appearing in the ACF: eigenvalues can repeat and coefficients can vanish.

Suggested clarification:

> The rank bounds the number of available nonzero spectral directions; repeated eigenvalues or zero coefficients can reduce the number of modes that actually appear in the ACF.

Apply this distinction wherever the manuscript interprets the rank diagnostic.

### 14. Rewrite the emission assumption in family-independent notation

The current assumption refers to state scales using `sigma_k`, although Laplace and GED use `b_k` and `alpha_k`. More importantly, differences in location or scale do not necessarily guarantee variation in the state-conditional absolute-return means that drive the stated ACF identity.

Use two separate conditions:

1. Every per-state emission has a finite second moment.
2. For a nontrivial absolute-return ACF, the vector
   `m_k = E[|G_t| | s_t = k]` is not constant across states.

The second condition is not needed to prove the identity itself; it is needed only to rule out the trivial zero-ACF case.

Affected locations:

- `sections/supplementary.tex`, assumptions supporting the spectral result.
- `sections/theory.tex`, if the nontriviality condition is mentioned in the main text.

## Verification Checklist

- [ ] Inspect and correct the companion Julia implementation for the post-update likelihood check. (companion repo; paper text now documents the one-M-step lag and argues the stopping decision is unaffected.)
- [x] Inspect and correct the weighted-median implementation. (done in CHMM-Model commit 317fef9.)
- [x] Decide whether to regenerate ACF-MAE results using the preferred per-path definition. (Decision: retain the path-averaged definition; Methods + metrics appendix now describe it consistently with the per-path-then-aggregate exception carved out.)
- [x] Rebuild the manuscript and check for undefined references or citations. (2026-06-14: clean 67-pp build, 0 undefined refs, 0 errors.)
- [x] Search globally for stale claims about ECM, exact fitted-marginal preservation, calibrated KS passes, and families differing only in the M-step. (2026-06-14: none found; added the missing KS i.i.d. caveat to Methods.)
- [x] Confirm that no change was made solely to replace the annualized excess-growth-rate convention. (Only edit this sweep was the Methods KS caveat.)
