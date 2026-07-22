# Differences Between the arXiv Baseline and `professor-review`

## Comparison basis

| Version | Commit | Description |
|---|---|---|
| `main` | `21b2550a496fe41d5b88ef8fcf381f32e520cf02` | arXiv version corresponding to arXiv:2606.23492; 67-page manuscript |
| `professor-review` | `6cdf9c6` | Expanded review manuscript; 90-page manuscript |

The arXiv version remains on `main`. This branch contains the proposed revisions for review and has not been merged into `main`.

## Executive summary

The review branch preserves the original CHMM model, methodology, broad evaluation program, and application goals, but substantially revises the manuscript's central interpretation. The earlier version presented the low-state Gaussian limitation primarily as a distributional-versus-temporal conclusion from likelihood fits. The review version adds direct, realizable capacity evidence and a weighted-objective sweep to distinguish what the HMM class can achieve from what maximum likelihood selects.

The revised manuscript now argues that:

- a valid three-state Gaussian HMM can fit the finite in-sample absolute-return ACF much more closely than the likelihood fit;
- the marginal body and finite-band ACF are jointly attainable at the achieved levels under the sweep's in-sample CDF criterion;
- the unresolved joint-fit question is specifically the deep tail, not the marginal body in general;
- the fitted finite-state Markov model still does not reproduce genuinely long-horizon, non-geometric persistence; and
- all optimization, held-out, multiplicity, and stationarity limitations are stated explicitly.

## Main scientific differences

### 1. Title, abstract, and framing

- The title changes from **Continuous Hidden Markov Models for Equity Returns** to **Continuous-Emission Hidden Markov Models for Equity Returns**.
- The abstract is rewritten around the new capacity and frontier evidence rather than treating the likelihood fit as a direct test of the full HMM class.
- The categorical “the original failure is distributional” framing is narrowed to the achieved evidence: at moderate state counts, the fitted gap is more strongly associated with marginal shape than with additional likelihood-selected decay modes.
- The abstract now states the unresolved deep-tail limitation and the long-horizon persistence limitation.
- Application claims are qualified as non-rejections or suggestive evidence where the tests are power-limited; the revised text avoids presenting non-rejection as proof of correctness.

### 2. Realizable finite-band ACF capacity experiment

The review branch adds a direct optimization of actual stationary Gaussian-emission HMMs, with row-stochastic transition matrices, positive emission scales, recomputed stationary distributions, and persisted optimizer certificates.

Key reported comparison:

- At `K=3`, the achieved near-band ACF MAE is about `0.0162`, versus `0.0497` for the published converged multistart likelihood fits.
- The result is described as an attainability certificate for valid HMMs, not a global optimum or a proof of class-wide equivalence.
- The `K=18` comparison is explicitly labeled achieved accuracy because all capacity winners hit the iteration cap and have near-degenerate stationary mass.
- The ACF-only solutions have a poor marginal, which motivates the separate weighted-objective experiment rather than supporting a premature trade-off conclusion.

### 3. Weighted-objective ACF/marginal frontier sweep

The review branch adds a `K=3` sweep of

`ACF-SSE + lambda * s * CvM`,

where the Cramér--von Mises term measures the stationary-mixture CDF against the empirical CDF on a 500-point in-sample quantile grid.

The headline `lambda=0.1` arm reports:

- median near-band ACF MAE `0.0165`;
- median CDF criterion `7.2e-6`, better than the likelihood comparator's `5.2e-5` on that criterion;
- stationary-mixture marginal log density within `0.011` nats per observation of the likelihood comparator;
- median maximum per-ticker regret `1.17`; and
- `24/31` tickers within a `1.5` regret factor on both axes using the same fitted chain.

The manuscript also reports that `lambda=0.3` has the best primary joint statistic: median maximum regret `1.11`, with `25/31` tickers within threshold. The conclusion is deliberately scoped: the sweep finds no necessary marginal-body/ACF trade-off at the achieved levels under this in-sample criterion. It does not establish that the deep tail and ACF are jointly attainable.

### 4. Deep-tail interpretation

The revised Results and Conclusion separate the bulk marginal from the deep tail:

- ACF-competitive fits improve on the likelihood comparator at only `5/31` tickers at the 1% quantile and `6/31` at the 99% quantile.
- They improve at `21/31` tickers for the central 5% and 95% quantiles.
- The median 99% quantile error is about `0.83` for the ACF-competitive fit versus `0.23` for the likelihood fit.
- Excess kurtosis is retained as descriptive evidence, not treated as a stable inferential population target.

The likelihood explanation is also corrected: the log score does not assign explicit extra weight to tail observations, but it strongly penalizes very low fitted density at observed extremes.

### 5. Long-horizon and out-of-sample limits

The review version distinguishes finite-band success from asymptotic memory:

- The fitted models improve the absolute-return ACF over the i.i.d. baseline at lags 1--63 but do not beat the i.i.d. floor at lags 64--252.
- The finite-state Markov model is not claimed to reproduce general power-law or multi-scale decay.
- At the median single-name ticker, likelihood-fitted `K=3` and `K=18` models trail the out-of-sample zero-curve reference; SPY is an exception.
- Stress folds and regime drift are treated as stationarity-scope limits, with periodic refitting recommended rather than presented as a demonstrated cure.

## Method and implementation alignment

The review branch expands the algorithm appendix and methods text to match the Julia implementation more precisely:

- Forward-backward likelihood evaluation is described as occurring before an update can mutate the current parameters.
- Gaussian and Laplace fits return the last evaluated iterate; Student-`t` and GED fits return the best evaluated finite iterate because numerical block updates are not guaranteed to improve the observed-data likelihood monotonically.
- The Gaussian implementation keeps the initial uniform `pi` fixed, while Student-`t`, Laplace, and GED update `pi` from `gamma_1`; parameter counts and BIC penalties reflect this distinction.
- The Student-`t` degrees-of-freedom step is identified as a posterior-weighted surrogate block update rather than being overstated as a full observed-likelihood ECME step for an HMM.
- The GED location-search interval is documented to match the Julia implementation: centered at the current `mu`, with width based on `alpha` and widened to include the observed data range.
- The shared multistart comparator configuration is centralized and certificate checks tie stored frontier comparators to the published spectral rows by start index, iteration count, likelihood, and cross-start spread.

## Results, robustness, and appendix changes

The branch adds or revises supporting evidence across the manuscript and `results/robustness/`:

- conditional-VaR evaluation now covers 573 held-out forecasts, including the boundary return, and adds an MS-GARCH comparison on the same origin set;
- the four-family conditional-VaR appendix reports the Engle--Manganelli DQ panel and its power limitations;
- Benjamini--Hochberg false-discovery-rate adjustments are reported for the back-test panels;
- block-bootstrap KS recalibration uses a two-sample dependence-aware null and corrects the interpretation from “stricter” to a wider, less conservative null distribution;
- walk-forward and stress-fold discussion is updated, with the COVID fold identified as the robust failure after multiplicity adjustment;
- cross-asset and copula summaries are resynchronized, including the refit-effect comparison and corrected winner labeling;
- K-selection, CRPS/DM, Gaussian-copula LR, HSMM, non-overlapping-basket, GARCH, and rolling-copula robustness artifacts are added or refreshed;
- the QuantGAN discussion distinguishes the expanded-panel result from the main comparison row and keeps the implementation caveat explicit; and
- a new observed-versus-simulated ACF figure and additional references are included.

## Reproducibility and presentation changes

- `PAPER-CODE-REVIEW.md` records the technical review and verification findings.
- The README documents the expanded manuscript, current 90-page build, updated title, and revised artifact map.
- The Makefile includes the convergent four-pass LaTeX build.
- The generated `paper.pdf` is rebuilt on the review branch.
- The review build was verified with no undefined references or citations and no overfull boxes; three non-blocking underfull boxes remain in the Results table area.
- The branch retains extensive artifact paths, seeds, optimizer diagnostics, and implementation caveats so the professor can inspect individual changes before deciding whether to merge.

## Review status

The technical review recorded in `PAPER-CODE-REVIEW.md` found no blocking or moderate correctness issue. The later `professor-review` commits also resolve the two residual manuscript wording findings identified there and align the GED search description with the implementation.

Remaining items are optional submission polish rather than scientific corrections:

1. Check whether the target venue imposes a 250-word abstract limit.
2. Optionally rename remaining code-output headings that say “Pareto frontier” to “weighted-objective frontier sweep over achieved feasible HMMs.”
3. Consider moving the important `lambda=0.1` rationale out of parentheses in the Results prose.
