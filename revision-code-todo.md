# Revision Code Work List (for `CHMM-Model`)

Every item below must be re-run in the companion code repository
[`CHMM-Model`](https://github.com/altashly1/CHMM-Model) and the results
re-imported into this paper. Each item gives (a) what to compute, (b) where
the output lands in the paper, (c) inputs and outputs, and (d) the
`\revtodo{}` placeholder it replaces where applicable.

Priority follows the referee's own ordering (M3 first, then M1/M4/M7/M8,
then M2/M5/M6/M9/M10, then minors 4/6/10).

Global conventions already set in the paper (do not change without
touching the relevant section):

- IS window: 2014-01-03 through 2024-01-03, $T_{\text{IS}} = 2{,}516$.
- OoS window: 2024-01-04 through 2026-04-20, $T_{\text{OoS}} = 572$.
- $K = 18$ operating point, quantile-based EM init, log-space forward-backward, $\text{max\_iter} = 60$, tol $10^{-4}$.
- Paths per scenario: $N_{\text{paths}} = 1{,}000$ unless otherwise noted.
- Global seed: `20260420` (already referenced in `sections/metrics_appendix.tex`).
- $G_t = (1/\Delta t) \ln(P_t/P_{t-1}) - r_f$ with $\Delta t = 1/252$ (drift-convention scaling; see Table 1 caption in `sections/results.tex`).

---

## Tier 1 — must-fix

### M3. Filter-based one-step-ahead regime-conditional VaR — **DONE (2026-04-24)**

**Implementation.** `CHMM-Model/run_track_c3_filter_var.jl`. Log-space rescaled
forward filter $\pi_t(k) = P(s_t = k \mid r_{1:t}, \hat\theta_{\text{IS}})$ +
bisection-based mixture-quantile. Writes `results/track_c3/VaR_filter_LR_tests.txt`
and `CHMM-paper/results/revision/M3_filter_var_backtest.csv`.

**Result (SPY OoS, $T_{\text{OoS}} = 572$, seed `20260422`).** All three
emission families fail Kupiec at both $\alpha$ levels:

| model | α | br% | LR_uc | LR_ind |
|-------|---|------|-------|--------|
| CHMM-N | 0.01 | 0.2 | 5.99 | 0.00 |
| CHMM-t | 0.01 | 0.2 | 5.99 | 0.00 |
| CHMM-L | 0.01 | 0.2 | 5.99 | 0.00 |
| CHMM-N | 0.05 | 1.4 | 21.59 | 2.81 |
| CHMM-t | 0.05 | 1.4 | 21.59 | 8.74 |
| CHMM-L | 0.05 | 1.2 | 24.34 | 9.95 |

Filter VaR is systematically over-conservative (breach rates
$\sim 1/5$ of target); mixture of heavy-tailed per-state emissions under
the filter posterior pulls the $\alpha$-quantile deep into the left tail.
Smoother-based Viterbi diagnostic continues to pass both tests for CHMM-t.

**Paper integration.** Real numbers swapped into Table~\ref{tab:conditional_var}
filter rows; all `\revtodo{pending}` on the filter rows resolved; abstract,
introduction, results, `var_backtest.tex`, and `discussion.tex` rewritten
to name the honest negative finding and the candidate remedies (adaptive
re-fit, state-conditional variance overlay, tail-emission shrinkage per M10).

### M1. Novelty repositioning

Paper-only; no code. Already done in Step 1 of the revision. No code-repo
work needed.

### M8. Pre-OoS validation K-selection — **DONE (2026-04-24)**

**Implementation.** `CHMM-Model/run_track_m8_k_selection.jl`. Estimation
slice 2014-01-03 through 2021-12-31 ($n = 2{,}013$); validation slice
2022-01-03 through 2024-01-03 ($n = 502$). Forward-algorithm held-out
log-likelihood on the validation slice is the primary criterion; BIC /
HQC / CAIC / AIC on the estimation slice plus held-out two-sample KS
pass rate at $\alpha = 0.05$ are reported for comparison.

**Result.** Six independent non-OoS criteria all select $K < 18$:
held-out log-lik, BIC, HQC, and CAIC pick $K^\star = 3$; AIC picks
$K^\star = 6$; held-out KS picks $K^\star = 9$. Held-out per-observation
log-lik gap between $K = 3$ ($-2.5345$) and $K = 18$ ($-2.5694$) is
$\sim 17$ log-lik units on the 502-point validation slice. CHMM-t /
CHMM-L at $K \in \{12, 15, 18, 21\}$ confirm the same monotone-decreasing
pattern, so the $K^\star < 18$ ordering is not an emission-family
artefact.

**Paper integration.** New paragraph + Table~\ref{tab:m8_k_selection} in
`sections/results.tex` §sec:model\_selection. Honest framing: the
referee's contamination concern is confirmed; $K = 18$ is kept as the
main-panel operating point because the paper's contribution is the
multi-metric evaluation (distributional + tail + VaR) rather than a pure
likelihood-optimal single-emission fit; a reader optimising for held-out
log-lik alone would pick $K = 3$. CSV at `M8_k_selection.csv`.

### M4. Broaden empirical base — **PARTIAL DONE (2026-04-24); multi-index follow-up pending**

**Implementation (done).** `CHMM-Model/run_track_m4_rolling_and_weekly.jl`
covers two of three M4 sub-asks on SPY (no new data fetch).

1. **Rolling-origin OoS (sub-ask 2).** Five rolling windows with 8-year
   IS and 1-year OoS spanning $2022$--$2026$. Produces the
   revision's most substantive negative finding: **2022 OoS fails
   catastrophically** (OoS KS $0.2$--$0.4\%$, Kupiec
   $\text{LR}_{\text{uc}}^{5\%} = 31$--$41$) because the rate-hike regime
   is a structural break outside the IS support; $2023$--$2026$ windows
   are in the $87$--$97\%$ OoS KS range consistent with the paper's
   single-window claim. CSV at `M4_rolling_origin.csv`.
2. **Weekly sampling frequency (sub-ask 3).** Five-day non-overlapping
   sum of daily log growth rates, $T_{\text{weekly}} = 503$, $K \in \{6,
   12\}$. All three emission families reach $98$--$99.6\%$ IS KS; CHMM-t
   at $K=6$ matches observed weekly kurtosis most closely. CSV at
   `M4_weekly.csv`.

**Paper integration (done).** New §sec:rolling\_and\_weekly in
`sections/results.tex` with tables `tab:m4_rolling` and `tab:m4_weekly`;
discussion limitations paragraph updated to cite the 2022 structural
break.

**Follow-up: multi-index (sub-ask 1) pending.** Alpaca credentials
available at `alpaca-markets-sdk/conf/apidata.toml`. Work list:

- Fetch daily OHLC bars for URTH (MSCI World), EWG (DAX), EWJ (Nikkei),
  EWU (FTSE) from Alpaca over $2014$-$01$-$03$ through $2026$-$04$-$20$;
  persist to `data/CHMM-Indices-IS-OoS.jld2` with the same schema as
  `CHMM-SP500-Train-10yr.jld2`.
- Per-index: fit CHMM-N / -t / -L at $K = 18$ on the index-specific IS
  ($2014$-$2024$), report the IS/OoS KS + AD + kurtosis + ACF-MAE panel
  plus Kupiec and Christoffersen on the index OoS window.
- Paper: expand `tab:m4_rolling` or add a new `tab:m4_indices` under
  §sec:rolling\_and\_weekly; cite all four indices in the empirical-base
  claim that the revision has broadened SPY + 5 US equities to include
  non-US equity indices.
- Output: CSV at `M4_index_panel.csv`.

### M7. GARCH competitor suite — **PARTIAL DONE (2026-04-24); FIGARCH pending**

**Implementation.** New `CHMM-Model/src/GARCHFamily.jl` module adds five
baselines, each with a `fit_*` / `simulate_*` pair in the same
grid-initialised Nelder-Mead style as the existing `_fit_garch11`:

1. **EGARCH(1,1) Gaussian** (Nelson 1991) — log-variance recursion with
   leverage term $\gamma z_{t-1}$.
2. **GJR-GARCH(1,1) Gaussian** (Glosten-Jagannathan-Runkle 1993 /
   Zakoïan 1994) — threshold asymmetry $\gamma \varepsilon_{t-1}^2
   \mathbf{1}\{\varepsilon_{t-1} < 0\}$.
3. **GARCH(1,1) Student-t** — heavy-tailed innovations $z_t \sim
   t_\nu$ standardised to unit variance.
4. **HAR-RV** (Corsi 2009) on daily squared returns; daily / weekly /
   monthly log-RV regressors.
5. **MS-GARCH $K = 3$** — extension of the existing `fit_msgarch_k2` in
   `src/MSGARCH.jl` via `fit_msgarch_k3`, with six off-diagonal logits
   for the transition-matrix rows.

`run_track_m7_garch_suite.jl` fits all five new baselines plus the
existing GARCH(1,1) and MS-GARCH K=2 references, simulates $N_{\text{paths}}
= 1{,}000$ IS and OoS paths, and scores the full panel (IS/OoS KS, AD,
simulated kurtosis, ACF-MAE on $|r|$, Kupiec / Christoffersen VaR).

**Result (SPY IS $= 2{,}516$, OoS $= 572$, seed `20260422`).** See
`CHMM-paper/results/revision/M7_garch_suite.csv`. Headline rows:
GARCH-t $\hat\nu = 6.89$ reaches IS KS $57.3\%$, OoS KS $80.8\%$,
kurtosis $15.13$; GJR-GARCH $\hat\gamma = 0.225$ quantifies leverage;
MS-GARCH K=3 attains the best panel ACF-MAE ($0.0284$). HAR-RV is
documented but is not a competitive return simulator (simulated kurtosis
$188.95$).

**Paper integration.** New table `tab:garch_suite` in
`sections/results.tex` with all five rows; new subsection
§sec:m7_baselines in `sections/baselines_appendix.tex` describing each
specification. Four citations added to `references.bib`:
`nelson1991conditional`, `glosten1993relation`, `zakoian1994threshold`,
`corsi2009simple`.

**Remaining: FIGARCH.** Deferred as a follow-up code pass. Requires a
truncated-lag FI polynomial (weights $\lambda_j$ such that
$\sigma_t^2 = \omega^* + \sum_{j=1}^{M} \lambda_j \varepsilon_{t-j}^2$
with $M \sim 10^3$, coefficients derived from $\Phi(L)(1 - L)^d$ under
the Baillie-Bollerslev-Mikkelsen (1996) parameterisation) plus Gaussian
log-likelihood over the recursion. Should be added in a separate session
and reported as an additional row in `tab:garch_suite`.

---

## Tier 2 — substantive but smaller

### M2. Block-bootstrap KS recalibration + mean p-value distribution — **DONE (2026-04-24)**

**Implementation.** `CHMM-Model/run_track_m2_ks_bootstrap.jl`. Stationary
block bootstrap (Politis-Romano 1994) of the SPY IS at mean block
lengths $L \in \{5, 10, 20\}$, $B = 1{,}000$ replications. Per
generator (CHMM-N/-t/-L, GARCH(1,1), iid bootstrap): asymptotic pass
rate, mean p-value, p-value quantiles ($q_5, q_{25}, q_{50}, q_{75},
q_{95}$), block-bootstrap pass rates.

**Result.** Block-bootstrap 95% KS critical values $\{0.0306, 0.0338,
0.0350\}$ are *stricter* than asymptotic $0.0383$. **GARCH(1,1) drops
from 25.4% asymp to 5.6-16.2% block-aware**, confirming the referee's
volatility-clustering concern. **CHMM family stays at 88-92%
block-aware** (94.8% asymp), so the asymp pass rates are not a
clustering artefact. Mean p-value scale (bootstrap $0.81$, CHMM-t
$0.57$, CHMM-N $0.55$, CHMM-L $0.50$, GARCH $0.04$) compresses the
cross-generator gap that the binary pass rate exaggerates.

**Paper integration.** New §sec:ks\_block\_bootstrap in
`sections/baselines_appendix.tex` after the existing KS power
calibration subsection, with Table~\ref{tab:m2_ks_bootstrap}. CSV at
`M2_ks_bootstrap.csv`.

### M5. Christoffersen LR_ind bootstrap null at $n = 572$ — **DONE (2026-04-24)**

**Implementation.** `CHMM-Model/run_track_m5_lr_ind_null.jl`. B = 10,000
i.i.d. Bernoulli$(\alpha)$ breach sequences of length 572 at each $\alpha
\in \{0.01, 0.05\}$; Christoffersen LR_ind computed on each; observed
CHMM smoother and filter LR_ind statistics from M3 located within the
empirical null.

**Result.**
- $\alpha = 0.01$: asymptotic $\chi^2_1 = 3.84$ cutoff has empirical size
  $2.07\%$ (test is conservative at n = 572). Bootstrap 95% quantile:
  $1.65$.
- $\alpha = 0.05$: empirical size $4.20\%$; bootstrap 95% quantile $3.80$
  (close to asymptotic).
- Smoother CHMM-t at $\alpha = 0.01$: $p_{\text{boot}} = 0.52$ (firmly
  consistent with independence).
- Filter CHMM-t at $\alpha = 0.05$: $p_{\text{boot}} = 0.002$ (decisive
  rejection; confirms M3 clustering failure is not a small-sample
  artefact).
- Filter rows at $\alpha = 0.01$: $\text{LR}_{\text{ind}} = 0$ is a
  degeneracy (single observed breach) and the corresponding $p = 1.0$
  should be read as "test uninformative" not "Christoffersen pass."

**Paper integration.** New paragraph inside
`sections/var_backtest.tex` §sec:conditional\_var with bootstrap
quantiles, per-construction p-values, and the degeneracy caveat. CSV at
`M5_lr_ind_null.csv`.

### M6. Sub-ask (b): MC CI on the Kupiec gain — **DONE (2026-04-24)**

**Implementation.** `CHMM-Model/run_track_m6_var_ci.jl` parametric-
bootstraps LR_uc at $n = 572$, $\alpha = 0.05$ under each (model,
observed breach rate $\hat p$) pair, $B = 10{,}000$.

**Result.** MC band $\sigma \approx 2$-$4$. Pairwise overlap (independent
draws under flat vs. SM rate): SM produces a strictly smaller LR_uc in
**76% of MC replications for CHMM-N**, **65% for CHMM-t**, 47% for
CHMM-L (the L breach rate did not move). The unconditional-VaR
calibration gain is genuine in the majority of MC replications for the
N and t variants but smaller in magnitude than the point-estimate alone
suggests.

**Paper integration.** New "MC confidence band on the Kupiec gain"
paragraph in `sections/var_backtest.tex` §sm_ablation, immediately after
the existing tab:sm_var. CSV at `M6_var_ci.csv`.

### M6. Sub-ask (a): Yu 2010 explicit-duration MLE — **PENDING**

**Compute.** Replace the current plug-in SM estimator (Viterbi decode
+ post-hoc sojourn fit per `sections/var_backtest.tex` §sm_ablation)
with a proper explicit-duration forward-backward MLE as in Yu (2010),
at minimum for SM-CHMM-N on SPY. Recursions: forward $\alpha_t(j, d) =
P(\text{obs}_{1:t}, \text{state } j \text{ with duration } d \text{ at }
t)$; backward $\beta$ analogous; M-step re-estimates transitions,
sojourn distributions, and emissions. Computational complexity O(T K²
D) where D is max duration.

**Estimated scope.** ~300-400 lines of new HSMM EM code in a new
`src/HSMM_MLE.jl` module. Should be tested on a smaller K=2 or K=3
synthetic case before deploying to K=18 SPY.

**Paper integration once implemented.** `sections/var_backtest.tex`
§sm_ablation §"Plug-in estimator and per-state sojourn family selection"
replaced with the MLE derivation; `tab:sm_var` cells recomputed;
`sections/algorithms_appendix.tex` expanded with the Yu 2010 recursion.
Additionally, implement an SM-aware decoder (filter preferred for the
operational claim) so the SM conditional VaR row in
`tab:conditional_var` can be populated rather than deferred.

**Inputs.** IS SPY series; flat-CHMM emission parameters as MLE
initialisation.

**Outputs.** SM-CHMM-N MLE parameters; updated `tab:sm_var` cells;
SM-aware filter VaR rows for `tab:conditional_var`.

### M9. Skew-t / skew-Laplace emission ablation — **DONE (2026-04-24)**

**Implementation.** New `CHMM-Model/src/SkewEmissions.jl` adds
Fernandez-Steel skew-t and skew-Laplace log-densities, samplers, and a
weighted-MLE fitter for the skew parameter $\gamma$ via golden-section
on $\log \gamma$. `run_track_m9_skew_emissions.jl` runs two ablations:

1. **K = 1 single-emission MLE:** symmetric t vs skew-t MLE on the full
   SPY IS. The skew $\gamma$ is fit by 1D MLE with $(\mu, \sigma, \nu)$
   held at the symmetric-t MLE. Confirms the Fernandez-Steel
   parameterisation picks up SPY's left-skew at $\gamma < 1$.
2. **K = 18 plug-in skew-CHMM-{t, L}:** symmetric CHMM fit is reused
   for transitions and per-state $(\mu_k, \sigma_k, \nu_k)$ or
   $(\mu_k, b_k)$, then per-state $\gamma_k$ fit by weighted MLE on the
   EM posteriors $\gamma_t(k)$. Simulate; report simulated IS skewness,
   kurtosis, KS pass rate.

**Result.** Symmetric CHMM-t at K=18 produces simulated IS skewness
$-0.667$ against observed $-0.752$; plug-in skew brings it to $-0.728$
at a small IS KS cost ($96.4\% \to 95.0\%$). Per-state $\gamma_k$
values cluster tightly around 1 (range $0.96$-$1.02$; median $1.00$;
zero of 18 states with $|\gamma_k - 1| > 0.05$). The within-state-skew
gap that the referee flagged is genuinely small because asymmetric
state occupancy of symmetric emissions already absorbs most of SPY's
skewness.

**Paper integration.** Limitations bullet in
`sections/discussion.tex` rewritten to report the ablation. CSV at
`M9_skew_emissions.csv`.

### M10. $\nu_k$ shrinkage via penalised ECM — **DONE (2026-04-24)**

**Implementation.** `CHMM-Model/run_track_m10_nu_shrinkage.jl` implements
the exponential shrinkage prior on $1/\nu_k$, corresponding to the
penalised objective $Q_k^{\text{pen}}(\nu) = Q_k(\nu) - \lambda / \nu$
maximised by the existing golden-section search. The penalty is threaded
through `src/Compute.jl` (`baum_welch_student_t`) and `src/Factory.jl`
(`build(MyStudentTHiddenMarkovModel, ...)`) as a new kwarg
`ν_shrink_rate`; default $0$ is backward-compatible with the unpenalised
ECM.

**Result (SPY IS, $T_{\text{IS}} = 2516$).** Rate sweep outcome:

| $\lambda$ | $\nu_{\min}$ | $\nu_{\text{med}}$ | sim kurt | IS KS% | filter VaR 1% LR_uc |
|-----------|--------------|--------------------|----------|--------|---------------------|
| 0 | 2.1 | 50.0 | 14.30 | 95.7 | 5.99 |
| 5 | 3.3 | 50.0 | 11.19 | 95.8 | 5.99 |
| 20 | 4.89 | 50.0 | 8.43 | 94.7 | 5.99 |
| 50 | 6.46 | 50.0 | 5.41 | 96.3 | 5.99 |
| 100 | 9.9 | 50.0 | 3.96 | 95.6 | 5.99 |
| 200 | 50.0 | 50.0 | 3.67 | 95.7 | 5.99 |

$\lambda \approx 20$ is the recommended operating point (simulated IS
kurtosis $8.43$ against observed $7.69$; KS pass rate essentially
unchanged). The kurtosis overshoot is therefore fixable within the
Student-t family.

**Cross-finding with M3.** Across the entire rate sweep, the filter-based
one-step-ahead VaR remains mis-calibrated at $\alpha = 0.01$ (breach rate
$0.17\%$, LR_uc $5.99$), so the over-conservatism is a mixture-over-states
property of the filter rather than a heavy-tails property of any one
emission. The remedy for the M3 failure lies elsewhere (adaptive re-fit
on a rolling window, state-conditional variance overlay, or
concentration-constrained posterior).

**Paper integration.** `sections/discussion.tex` §kurtosis overshoot
rewritten around the rate sweep; `sections/var_backtest.tex` §sec:conditional_var
filter paragraph adds the shrinkage-does-not-rescue observation;
`sections/algorithms_appendix.tex` adds the penalised objective as
`eq:nu_pen`. CSV at `CHMM-paper/results/revision/M10_nu_shrinkage.csv`.

---

## Tier 3 minors requiring code

### Minor 4. MMD bandwidth fix — **DONE (2026-04-24)**

**Implementation.** `CHMM-Model/run_track_minor4_mmd_bandwidth.jl`
recomputes MMD across the M7 generator panel under a fixed $\gamma_{\text{obs}}$
from observed 20-day windows. Legacy and fixed MMDs differ in the
3rd-4th decimal; cross-generator ranking preserved.

**Paper integration.** New paragraph in §sec:tier3\_robustness (`sections/baselines_appendix.tex`).

**Output.** `minor4_mmd_bandwidth.csv`.

### Minor 6. $K_{\text{disc}} = 13$ centroid ablation — **DONE (2026-04-24)**

**Implementation.** `CHMM-Model/run_track_minor6_kdisc13_centroid.jl`
fits Discrete NJ at $K_{\text{disc}} = 13$ with centroid emissions. IS KS
$0.0\%$ vs Bin-T NJ's $95.4\%$ at the same bin count, cleanly isolating
the within-bin emission-family contribution.

**Paper integration.** New paragraph in §sec:tier3\_robustness.

**Output.** `minor6_kdisc13_centroid.csv`.

### Minor 10. Multi-seed Monte Carlo — **DONE (2026-04-24)**

**Implementation.** `CHMM-Model/run_track_minor10_multiseed.jl` re-runs
CHMM-N/-t/-L at K=18 across 10 alternative seeds. Seed-to-seed std:
IS KS ±1.2-1.8%; OoS KS ±1.8-3.6%; CHMM-N kurt ±0.06; CHMM-t kurt ±1.95.
Headline single-seed numbers sit comfortably within multi-seed bands.

**Paper integration.** New paragraph + Table~\ref{tab:m10_multiseed} in
§sec:tier3\_robustness.

**Output.** `minor10_multiseed.csv`.

---

## Deliverable format (per item, when re-imported)

Place every output CSV in `CHMM-paper/results/revision/` (create if it
does not exist) with filenames matching the referee item:

- `M3_filter_var_backtest.csv`
- `M4_index_panel.csv`, `M4_rolling_origin.csv`, `M4_weekly.csv`
- `M7_garch_suite.csv`
- `M8_k_selection.csv`
- `M2_ks_bootstrap.csv`
- `M5_lr_ind_null.csv`
- `M6_sm_mle.csv`
- `M9_skew_emissions.csv`
- `M10_nu_shrinkage.csv`
- `minor4_mmd_bandwidth.csv`
- `minor6_kdisc13_centroid.csv`
- `minor10_multiseed.csv`

When swapping numbers into LaTeX, remove every corresponding
`\revtodo{...}` marker so the final build has zero `[TODO (revision):
...]` cells.
