# Paper II: arXiv version vs current repository version

Comparison of Paper II ("Continuous Hidden Markov Models for Equity Returns: Heavy-Tail
Emission Families and Regime-Conditional Value-at-Risk") as published on arXiv against the
current repository LaTeX source. This file supersedes the 2026-07-07 diff notes; it covers
both the pre-exam revision wave and the 2026-07-13 reconciliation pass.

- Version A (repo): `CHMM-Paper-Repository/paper.tex` + `sections/*.tex` at commit `c145c82`
  (2026-07-13). The thesis chapter `chapters/papers/paper-two/` is a verified word-level
  mirror of this version (differences are only US spelling, `_p2` label suffixes, and thesis
  caption style).
- Version B (arXiv): `arXiv:2606.23492v1 [q-fin.ST]`, 22 Jun 2026 (the only published
  version).

## Bottom line

The repo is a strictly later and more defensible revision. Changes fall into three groups:

1. **Precision and scope corrections** (pre-exam): terminology, softened claims, one
   corrected overclaim, and a new K = 2 analysis.
2. **One numeric erratum** (2026-07-13): the Median OoS KS column of the cross-asset
   summary table was stale in the arXiv version and has been corrected from the raw
   per-asset data. This is the only place the two versions now disagree on a number.
3. **One new analysis** (2026-07-13): a Hill tail-index table and paragraph that put the
   heavy-tail claim on a stable estimator instead of resting it on excess kurtosis alone.

Everything else that both versions report numerically is identical.

## 1. Numeric erratum: cross-asset Median OoS KS column

The arXiv version of the cross-asset dependence summary (`tab:cross_asset_supp_summary`)
carries a stale Median OoS KS column that does not reproduce from the authoritative
per-asset data (`CHMM-Model-Repository/results/cross_asset/Table-T3-Cross-Asset-Dependence.txt`,
K* = 3, 200 paths, seed 20260422). The repo corrects it:

| Model | arXiv (stale) | Repo (correct) |
|---|---|---|
| Single Index Model | 87.0 | 84.2 |
| Gaussian copula | 87.5 | 84.2 |
| Student-t copula (nu* = 6) | 85.8 | 81.5 |
| Truncated C-vine | 86.0 | 81.0 |

The Median IS KS column and both off-diagonal MAE columns reconcile exactly in both
versions, and every qualitative dependence claim rests on the MAE columns, so no conclusion
changes. Two related presentation fixes in the repo: the bold markers were removed from both
KS-median columns (the three copulas preserve the same CHMM-N marginals by rank reordering,
so their per-asset KS differences are Monte-Carlo path noise; the arXiv IS-column bold was
also on the wrong cell), and the caption now says the dependence ranking rests on the MAE
columns.

## 2. New analysis: Hill tail index (repo only)

The arXiv version argues the heavy-tail stylized fact through excess kurtosis alone. The
repo adds a Hill tail-index analysis, computed identically for the observed series and every
simulated family at K* = 3 (top 5% of |G_t| exceedances, 1,000 paths, seed 20260420):

- New results table `tab:tail_index` and accompanying paragraph: observed alpha = 3.15 IS /
  3.30 OoS (stationary block-bootstrap 95% CI [2.45, 4.25] on IS); shared-nu CHMM-t 3.67 on
  both windows (across-path band [3.11, 4.38], overlapping the observed CI); every emission
  family lands inside Cont's empirical (2, 5) band even though simulated excess kurtosis
  spans 3.83 to 18.87 across the same rows.
- New metrics-appendix paragraph defining the estimator (`eq:hill_supp`), the bootstrap CI,
  the across-path band, and the per-side (loss/gain) variant.
- The per-side split reproduces the direction of the observed gain/loss asymmetry (observed
  loss-minus-gain gap -0.55; every symmetric family recovers a negative gap from the regime
  means alone), stated as the static asymmetry channel, distinct from the dynamic leverage
  effect.
- New discussion caveat: the observed alpha sits below 4, so the population fourth moment is
  plausibly infinite and the sample excess kurtosis of 7.68 is a draw-sensitive statistic
  rather than a fixed target. This bounds how much of the "kurtosis gap" is real.
- New reference: Hill (1975), The Annals of Statistics.

Interpretive consequence, absent from arXiv: at the depths the estimator sees, the regime
mixture rather than the emission family carries the heavy tail; the emission shape governs
how far into the extreme tail the match extends.

## 3. Definitions and statements tightened (2026-07-13 pass)

| Location | Repo (current) | arXiv | Why |
|---|---|---|---|
| Results, first use of "lag-252 MAE tolerance" | New footnote: matched means the \|G_t\| ACF-MAE sits at the i.i.d.-baseline floor (0.0462 for CHMM-N against about 0.063 for the i.i.d. rows) and is essentially flat across K; a relative-to-floor criterion rather than a pre-registered numeric threshold | Phrase used but never defined | The word "tolerance" implied a threshold that was never stated; the footnote makes the criterion operational |
| Results + Conclusion, bootstrap/HSMM-N comparison | Added: the OoS-KS win of the i.i.d. bootstrap and the ML HSMM-N is confined to the marginal axis; both benchmark rows sit at the i.i.d. \|G_t\| ACF-MAE floor (0.0628 and 0.0629) while CHMM-N clusters below it at 0.0462 | Win reported; clustering counterpoint left implicit in the table | Prevents over-reading "HSMM-N is simply better"; the Gamma-sojourn K = 18 nuance in the conclusion is unchanged |
| Methods + metrics appendix, ACF-MAE definition | Per-path MAE averaged over the P paths (matches the code, `run_chmm_t_penalised_headline.jl`) | MAE against the path-averaged mean ACF | The published numbers were always computed per path; the equation now matches what was computed. No value changes |
| Methods, EM cost | New sentence: each EM iteration costs O(K^2 T) for the forward-backward recursions and transition update, plus per-family emission updates | Qualitative only | Standard cost statement, aids the compute discussion |
| Discussion, leverage effect | Not targeted; a partial effect emerges from the regime means (per-path envelope brackets the observed IS value of -0.135, `tab:leverage_effect`); the dynamic effect is not modelled | "symmetric emissions cannot reproduce a negative cross-correlation by construction" | The arXiv sentence contradicted the paper's own leverage appendix table |
| Sensitivity appendix, shared-nu reading | "14.4 for the unpenalised per-state nu_k fit at K = 18 (Table extended_baselines; consistent with the lambda = 0 entry of Table nu_shrinkage)" | "14.4 for the per-state nu_k unpenalised row in the main text" | The main text has no such row; the pointer was stale from the earlier K = 18 main-panel draft |
| Cross-asset table caption | States the dependence-metric convention explicitly: correlation computed per simulated path against the observed matrix, then averaged (full-matrix convention; off-diagonal MAE over the d(d-1)/2 unique upper-triangle entries) | Convention implicit | Makes the numbers reproducible without reading the code |
| Baselines appendix (internal fix) | `Table~\ref{tab:model_comparison}` | `Table~\ref{tab:model_comparison_p2}` (a thesis-only label; compiled as an undefined reference) | Sync leftover; the paper now builds with zero undefined references |

## 4. Pre-exam revision wave (already in the repo before 2026-07-13)

Condensed from the earlier diff notes; all still present.

- **Terminology**: "kurtosis" corrected to "excess kurtosis" throughout the body text,
  matching the tabulated quantity (arXiv compared "simulated excess kurtosis" against
  "observed kurtosis" in one sentence).
- **Ryden reframing**: the "Ryden failure" is presented as two possible failure channels of
  the low-K Gaussian limitation; two new sentences attribute the divergence to Ryden's
  outlier-reduced subseries (his data broke on the temporal channel, ours binds on the
  marginal channel); a full reconciliation paragraph concedes the in-principle finite-mode
  limit and names the semi-Markov chain as the structural fix for genuinely slow decay.
- **Softened ACF claims**: "reproduced" became "matched within our lag-252 MAE tolerance"
  (now defined, see section 3); "closed most of the gap" became "narrowed the gap but did
  not close it"; "cleanest heavy-tail match" became "closest heavy-tail approach".
- **Corrected baseline overclaim**: arXiv said the CHMM is differentiated "on use cases
  neither alternative can serve"; the repo scopes structural inability to the i.i.d.
  bootstrap only (no latent state) and defers HSMM-based heads to a companion paper.
- **New K = 2 analysis**: a third Table S5 panel (single mode, |lambda| = 0.942 carrying
  100% of the lag-1 ACF, rank bound tight), a K = 2 row in the held-out K-selection table,
  a quantified A.7.6 replication (IS KS 79.0% vs 91.5%, four-family K = 2 fit), and reworked
  K-selection prose (held-out KS nominally selected K = 2 on a structural-break slice, so
  its ranking is not discriminating; BIC, HQC, CAIC, and held-out log-likelihood all keep
  K* = 3).
- **New CVaR disambiguation footnote**: regime-conditional VaR vs CVaR/ES vs Christoffersen
  conditional coverage.
- **Conclusion broadened from four to five extensions**: the explicit-duration HSMM with
  heavy-tailed sojourns added as the primary out-of-class direction, supported by the
  Pareto-sojourn (17 of 18 states) and Gamma-sojourn evidence.

## 5. What did not change

- Every reported numeric result where both versions overlap, except the one erratum in
  section 1: KS pass rates, excess kurtosis point estimates, ACF-MAE values, eigenvalues,
  VaR breach rates and p-values, copula off-diagonal MAE, walk-forward figures, CRSP and
  sector-panel results.
- The contribution statement relative to Hamilton, Krolzig, and Timmermann (the spectral
  identity is textbook material; the contribution is the rank reading and the empirical
  demonstration that the bound was not active at moderate K).
- The formal statements (Assumptions 1 to 2, Propositions 1 to 2) and the appendix skeleton
  (A.1 to A.10; no subsection added or removed).
- All hedges and scope statements ("under the diagnostics used here", the no-privacy-claim
  sentence, the stationary-OoS dataset scope, the periodic-refit recommendation).
- No citation was removed; the only addition is Hill (1975).

## 6. Volatility-clustering evidence: decision note

A Ljung-Box / McLeod-Li formal clustering test was drafted for the paper on 2026-07-04 and
reverted the same day. Decision (2026-07-13): the paper's clustering evidence stays as the
ACF-MAE with the new operational floor definition (section 3) plus the Bartlett-band figure.
Deck-side Ljung-Box, DFA-Hurst, and power-law-decay diagnostics remain presentation
material and are not backported; the tolerance footnote makes the manuscript's clustering
criterion self-contained without them.
