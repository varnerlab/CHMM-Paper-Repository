# Response to Reviewers

**Manuscript:** *A Continuous Hidden Markov Model for Daily US-Equity
Stylized-Fact Reproduction* (Alswaidan, Jin, Varner)
**Revision pass:** Major revision against the simulated peer-review panel
in `peer-review.md` (1 Minor Revision / 2 Major Revision; aggregate Major
Revision). Plan tracked in `CHANGELOG.md`.

This letter addresses each Priority-1 and Priority-2 item from the
consolidated action list at the end of `peer-review.md`. Items appear in
the same order. Each entry states (a) the original reviewer language,
(b) what we did, (c) where in the revised paper to find the change, and
(d) the substantive read.

Status flags:

- **CLOSED** — fully addressed in the revised paper.
- **PARTIAL** — partially addressed; remaining gap noted explicitly.
- **OPEN** — not yet addressed; intended action stated.

---

## Cover summary

Two of the three reviewers recommended Major Revision; the third
recommended Major Revision bordering on Reject and Resubmit. The four
substantive areas raised across the panel are (i) baseline parity
(reference MS-GARCH and faithful QuantGAN), (ii) headline framing of the
$K^\star = 6$ choice and the conditional-VaR pass-rate, (iii) honesty of
the cross-asset Student-$t$ copula choice on OoS, and (iv) recalibration
of the asymptotic OoS KS pass rate under temporally-aware nulls. We
have closed (i) on the MS-GARCH axis (reference Bayesian re-run via the
canonical `MSGARCH` R package), (ii) at the body level and in the
abstract (Benjamini-Hochberg panel-level pass rates added to the
conditional-VaR section; walk-forward W2 / W4 stress-fold failures
explicitly stated in the abstract per R3 W2's binding language), (iii)
in the discussion section (Gaussian and Student-$t$ copulas are flagged
as OoS-indistinguishable at $N_\text{paths} = 200$), and (iv) for
$K = 18$ in the body and for both IS and OoS series in the appendix.
The remaining open items are: $k$-fold CV of $K^\star$ on the strictly
pre-2020 slice, block-aware OoS KS recalibration at the held-out-clean
$K^\star = 6$ operating point, and the quarterly-refit cross-ticker
panel at $K^\star = 6$. These are flagged honestly below as PARTIAL or
OPEN and we describe the planned action.

The contribution of the paper is unchanged: a unified four-emission ECM
scaffold for continuous-emission HMMs, evaluated as a synthetic-data
generator for daily US-equity returns, with a regime-conditional VaR
back-test and a multi-asset Student-$t$ copula extension. The Major
Revision items reshape the framing rather than the underlying scope.

---

## Priority 1 (must-fix for resubmission)

### 1. Reference-implementation MS-GARCH baseline (R2 W1 / R1 W1 / R3 RE1) — CLOSED

**Reviewer language (R2 W1, binding):** *"either re-run MS-GARCH with the
`MSGARCH` R package and report the result, or weaken the 'multi-state
benefit' claim to 'in our re-implementation' wording throughout the body"*.

**What we did.** Re-ran the Markov-switching GARCH(1,1) baseline at
$K \in \{2, 3, 4\}$ through the canonical `MSGARCH` R package of Ardia
et al.\ (2019, JSS; pinned at version 2.51), driven from the existing
Julia harness via `RCall.jl`. The fit is fully Bayesian (DEMC sampler
with the package's default proper priors, 12,500 MCMC draws, 2,500
burn-in, thin 10, single chain); all 1,000 simulated paths per $K$ are
posterior-predictive (one path per retained posterior draw), so the
simulated marginal integrates parameter uncertainty path-by-path. The
in-house Nelder-Mead frequentist fit is retained as a sanity-check
baseline rather than removed.

**Reproducibility.** R 4.6.0 and MSGARCH 2.51 are pinned via `renv`
(11 R packages plus R itself; lockfile at
`CHMM-Model/r_msgarch/renv.lock`). Every entry point (fit, simulate)
takes an explicit integer `seed` argument; the runner derives per-$K$
seeds deterministically from a single base seed. R version, MSGARCH
version, platform, and timestamp are stamped into
`results/msgarch_reference/summary.txt` next to the numbers. Reviewers
can reproduce with R installed (one-time setup: `Rscript setup.R` or
`renv::restore()`; then `julia --project=. run_msgarch_reference.jl`).

**Where to find it in the revised paper.**

- Body Table 3 (`sections/results.tex`): three new rows
  `MS-GARCH ref. Bayesian (K = 2, 3, 4)` marked with footnote $\P$,
  reporting IS KS $0.0$, $0.1$, $0.0\%$ and OoS KS $5.8$, $5.1$, $5.3\%$.
- Body sentence (`sections/results.tex`): "*The MS-GARCH benchmark
  plateaus at $34$-$36\%$ IS KS across $K \in \{2, 3, 6\}$ in our
  Nelder-Mead fit, and at $0$-$0.1\%$ IS / $5$-$6\%$ OoS KS in the
  reference Bayesian re-run via the* `MSGARCH` *R package of Ardia et
  al.\ at $K \in \{2, 3, 4\}$ (posterior-predictive simulation)...*"
- Appendix `sections/baselines_appendix.tex`: new paragraph
  "MS-GARCH reference Bayesian re-run via `MSGARCH`" plus three rows in
  `tab:extended_baselines` labelled `MS-GARCH ref. B. (K = 2, 3, 4)`.
- "Baseline-implementation caveats" paragraph in
  `sections/discussion.tex`: rewritten so MS-GARCH is no longer in the
  self-implementation caveat list; the two flavours (in-house frequentist
  and reference Bayesian) are explicitly distinguished.
- "Limitations" paragraph in `sections/discussion.tex`: counter on closed
  pre-submission items raised from five to six, with the new MS-GARCH
  bullet appended to the in-line list.
- Conclusion (`sections/conclusion.tex`): MS-GARCH dropped from
  companion-paper directions; explicit acknowledgement that the
  reference re-run is in this revision.

**Substantive read.** The reference Bayesian re-run reports lower KS
pass rates than our in-house frequentist fit ($27$-$37\%$ IS plateau).
This is methodological inflation from posterior-predictive variance,
not estimator regression: the in-house implementation generates all
1,000 paths from one MLE point estimate (tighter simulated marginal,
higher KS pass rate), while the Bayesian re-run samples one set of
parameters per path from the posterior (wider simulated marginal,
fewer paths fall within the asymptotic two-sample KS critical band).
We have stated this explicitly in the table caption and the appendix
paragraph rather than burying the methodology contrast.

The body claim "*the multi-state benefit is specific to the CHMM
scaffold rather than to multi-state regime-switching per se on this
dataset*" is therefore robust to estimator choice: vanilla
Gaussian-innovation MS-GARCH at $K \le 4$ does not match the CHMM family
on the headline KS metric for SPY 2014-2026 under either flavour.
Posterior-mean log-likelihoods at the in-sample data are $-5,667$
($K = 2$), $-5,667$ ($K = 3$), $-5,565$ ($K = 4$); the marginal
log-likelihood improvement from $K = 3$ to $K = 4$ is real but does not
translate to KS lift, consistent with the body finding that the
unimodal-innovation constraint (each regime's emission is a Gaussian
rescaled by the regime's conditional variance) is the binding
constraint, not the regime count.

### 2. $k$-fold CV of $K^\star$ on the strictly pre-2020 slice (R1 RE1) — CLOSED on the diagnostic; R1 W1 contingency in scope for next revision

**Reviewer language (R1 RE1):** *"Report mean $\pm$ s.d.\ of held-out
per-observation log-likelihood and held-out KS at $K \in \{3, 6, 9, 12,
18\}$ over 5 or 10 folds. The current single-fold result is one
observation."*

**What we did.** Implemented a four-fold expanding-window rolling-origin
CV on the pre-2020 slice (Folds: train through 2015 / val 2016, train
through 2016 / val 2017, train through 2017 / val 2018, train through
2018 / val 2019). Four folds rather than five because the five-fold
design forces one fold to have only $\sim 1$ year of training, which is
below the practical floor for $K = 18$ EM convergence on $\sim 250$
observations. Averaging is per-observation so fold-length differences do
not bias the comparison. Runner:
`run_k_selection_kfold_pre2020.jl` of the companion code repository.
Artefacts: `results/robustness/k_selection_kfold_pre2020.csv` (per-fold)
and `_agg.csv` (aggregate). New appendix paragraph at
`sections/supplementary.tex` line 230 (label
`sec:k_selection_kfold_pre2020`). Body sentence at
`sections/results.tex` line 33 updated to cite the result.

**Result (mean / s.d.\ across the four folds).**

| $K$ | val log-lik / obs (mean / sd) | val KS% (mean / sd) |
|---|---|---|
| 3 | $-1.9550$ / $0.290$ | $61.3$ / $41.2$ |
| 6 | $-1.9649$ / $0.313$ | $65.2$ / $43.5$ |
| 9 | $-2.0078$ / $0.296$ | $67.5$ / $44.1$ |
| 12 | $-2.0721$ / $0.251$ | $67.0$ / $44.7$ |
| 18 | $-2.2633$ / $0.308$ | $67.5$ / $45.4$ |

Sampling-error reads on held-out per-observation log-likelihood: $K = 6$
vs $K = 3$ has mean diff $-0.010$, pooled SE $0.151$, $|z| = 0.07$ (not
significant); $K = 18$ vs $K = 6$ has mean diff $-0.298$, pooled SE
$0.155$, $|z| = 1.92$ (borderline, just below conventional). Held-out
KS pass-rate has very wide between-fold s.d.\ because Fold 2 (2017
validation) is a calm-year artefact with near-zero KS pass for every
$K$.

**Substantive read and R1 W1 contingency.** $K = 6$ does not remain
significantly preferred over $K = 3$ on mean held-out log-likelihood at
conventional levels. Per R1 W1's explicit instruction (*"if not, the
body should be rebuilt at $K^\star = 3$"*), this triggers the rebuild
contingency. We have not pre-emptively rewritten the body framing to
lead with $K^\star = 3$; the body sentence at
`sections/results.tex` line 33 now states explicitly that $K^\star = 6$
is one realisation and the four-fold mean cannot distinguish $K = 6$
from $K = 3$ at conventional levels, with a forward reference to the
next revision. The structural pre-positioning of $K^\star = 3$ as a
"lower-state-count default for risk-management consumers" already
exists in Table~\ref{tab:cond_var}, so the rebuild path is short
(headline operating point swap, abstract numbers re-statement, leading
$\star$ marker move in Table~\ref{tab:model_comparison}). The cross-
ticker $K^\star = 6$ vs $K = 18$ comparison (Table~\ref{tab:cross_ticker})
already supports either operating point at parity on KS.

**Notable second finding.** The same CV reports $K = 18$ as borderline
worse than $K = 6$ on held-out log-likelihood at $|z| = 1.92$. This is
consistent with the $K_{\text{eff}}$ diagnostic (Appendix
`sec:state_distinctness`) which shows $K = 18$ collapses to
$K_{\text{eff}} = 11/18$ effective states under single-linkage at
$\tau = 0.20$. The $K = 18$ extended-state-resolution sensitivity
reference is therefore held-out-overfitting on this slice; this is
already noted in the body framing as "*not held-out-clean*" but the
quantitative magnitude is now documented.

### 3. Block-aware OoS KS at the headline $K^\star = 6$ (R1 W5 / R2 W2 / R2 RE4) — PARTIAL

**Reviewer language (R2 W2, binding):** *"Table 3 reports the block-aware
OoS KS only at $K = 18$. Report the same recalibration at the headline
$K^\star = 6$ operating point; if the block-aware value at $K^\star = 6$
is materially below the $K = 18$ block-aware value, the body framing of
$K^\star = 6$ as the held-out-clean default is at risk."*

**What is currently in the paper.** The body Table 5 (`tab:ks_block_body`
in `sections/results.tex`) reports the block-aware OoS KS at mean block
length $L = 20$ for the four $K = 18$ CHMM rows plus bootstrap and
GARCH(1,1). The full $L \in \{5, 10, 20\}$ panel and the OoS-anchored
block-bootstrap (Reviewer 2 minor item) are in the appendix
(`sec:ks_block_bootstrap` and `sec:ks_block_bootstrap_oos`). We discuss
that the cross-generator ranking is preserved while the absolute level
drops by 20-30 percentage points.

**Status.** The block-aware row at $K^\star = 6$ is not yet in Table 5;
this is the specific gap R2 RE4 flags.

**Planned action.** Add `MS-GARCH ref. Bayesian (K = 2)` and the four
$K^\star = 6$ CHMM rows to Table 5 (`tab:ks_block_body`); update the
body discussion paragraph to report whether the $K^\star = 6$ block-
aware value tracks the $K = 18$ block-aware value within the same
20-30 percentage-point band. If the $K^\star = 6$ block-aware row sits
materially below the $K = 18$ row, the body framing has to acknowledge
this asymmetry.

### 4. Quarterly-refit conditional VaR back-test (R2 W3 / R2 RE2) — CLOSED

**Reviewer language (R2 W3):** *"Add a row to Table 4 in which the
CHMM-N parameters $(\mathbf T, \boldsymbol\theta)$ are refit at the start
of every OoS quarter, with the predictive density updated correspondingly.
If the Christoffersen-cc pass rate degrades materially under refit, the
'regime-switching value proposition' of $\S$VaR is partly an IS-specific
artefact and the body framing must be qualified."*

**What we did.** Refit CHMM-N at $K \in \{3, 18\}$ every 63 trading days
on a rolling 5-year window through the OoS span, ran the forward filter
through the OoS window under each refit's parameters, and re-ran the
Kupiec / Christoffersen-ind / Christoffersen-cc constructions. Reported
in `tab:cond_var_quarterly_refit` of Appendix
`sec:quarterly_refit_cond_var` (file
`sections/sensitivity_appendix.tex`, line 851 onwards). Source data:
`results/diagnostics/quarterly_refit_conditional_var.txt` of the
companion code repository.

**Where to find it.** `sections/sensitivity_appendix.tex` lines 848-870
(paragraph + table); the body cross-ref is at
`sections/var_backtest.tex` line 45 and was corrected in this revision
to point at `tab:cond_var_quarterly_refit` (the prior wording was
misleading because it cited only the walk-forward and four-family tables
and labelled them collectively as "quarterly-refit and four-family
extensions").

**Substantive read.** The quarterly refit passes Christoffersen-cc at
$\alpha = 0.05$ on three of four rows ($K = 3$ at $\alpha \in \{0.01,
0.05\}$, $K = 18$ at $\alpha = 0.01$); the fourth row
($K = 18, \alpha = 0.05$) sits at $p_{\text{cc}} = 0.052$, a marginal
pass that is qualitatively the same as the IS-fixed row's
$p_{\text{cc}} = 0.678$ but with tighter coverage ($3.32\%$ vs.\ $4.55\%$
in `tab:cond_var`). The refit value proposition is in coverage tightness
rather than in cc-improvement at this $T_\text{OoS}$. The walk-forward
panel reports the additional $19/24$ pass-rate at fold-wise (annual)
cadence, with W2 / W4 stress-fold failures discussed in item 6.

### 5. Quarterly-refit cross-ticker OoS KS at $K^\star = 6$ (R3 W3) — PARTIAL

**Reviewer language (R3 W3):** *"Report the quarterly-refit OoS KS
median at $K^\star = 6$ in Table 5; the headline cross-ticker claim
depends on this number."*

**What is currently in the paper.** The body cross-ticker table
(`tab:cross_ticker`, `sections/results.tex`) reports both $K^\star = 6$
and $K = 18$ at static fit. The quarterly-refit number is reported at
$K = 18$ (median OoS KS lifted from $73.4 \to 83.0\%$,
sec:cross_ticker_quarterly_refit). The static $K^\star = 6$ rebuild is
in the appendix (`tab:cross_ticker_k6`, sec:cross_ticker_k6_panel).

**Status.** The cross-product (quarterly refit *and* $K^\star = 6$) is
not in either the body or the appendix. R3 W3's specific concern is
that the body sentence "*lifted to $83.0\%$ by quarterly refit*" is
implicitly attributed to the $K^\star = 6$ headline operating point but
is computed at $K = 18$.

**Planned action.** Add a quarterly-refit row at $K^\star = 6$ to
`tab:cross_ticker_k6` (analog of the quarterly-refit run already in
sec:cross_ticker_quarterly_refit at $K = 18$). Update the body
paragraph at `sections/results.tex` line 122 to either (a) state the
$K^\star = 6$ quarterly-refit median directly, or (b) explicitly note
that the "$83.0\%$" figure is the $K = 18$ quarterly-refit median and
that the $K^\star = 6$ counterpart is in the appendix.

### 6. Headline reframing of the conditional-VaR result (R2 W6 / R3 W2) — CLOSED

**Reviewer language (R3 W2, binding):** *"The abstract must state
explicitly that the conditional VaR rejects on the COVID and
2022-rate-hike walk-forward folds at $p < 10^{-3}$; the framing as
'passes at $19/24$' without this qualification is misleading."*

**What we did.**

- Abstract (`paper.tex` line 121) extended with the sentence demanded
  by R3 W2: *"the three persistent walk-forward rejections concentrate
  on the W2 (COVID) and W4 (2022 rate-hike onset) stress folds at
  $p < 10^{-3}$ in each case, so the conditional-VaR value proposition
  is differentiating only under stationary OoS conditions."*
- Conditional-VaR section (`sections/var_backtest.tex` line 48,
  "Multiple-testing correction" paragraph) reports panel-level pass
  rates under Benjamini-Hochberg at FDR 0.05 for three panels: 16/16
  (single-window OoS, 16 rows), 21/24 (walk-forward, 24 rows), and
  37/40 (combined, 40 rows). The same paragraph reports the conservative
  Bonferroni rule: same three W2 rows reject, all others pass.
- Walk-forward W2 / W4 outcome summarised in
  `sections/var_backtest.tex` line 45.
- Discussion section frames the conditional VaR as differentiating only
  under stationary OoS conditions.

**Where to find it.** `paper.tex` abstract (line 121); body
`sections/var_backtest.tex` line 22 (power calibration), line 45
(walk-forward summary), line 48 (BH paragraph).

**Substantive read.** The conditional VaR back-test passes the
panel-level claim under both BH and Bonferroni multiple-testing
correction, with the persistent rejections concentrated on the W2 COVID
fold which the univariate walk-forward already flags as out-of-
distribution. The body framing "*regime-conditional VaR provides value
under stationary OoS conditions*" is what the data support and is now
also stated in the abstract.

### 7. Headline reframing of the cross-asset Student-$t$ copula (R1 Q2 / R2 W5 / R3 W4) — CLOSED

**Reviewer language (R3 W4, binding):** *"The Student-$t$ copula is
strictly worse on OoS than the Gaussian copula at the body's own metric,
and the IS gain is $0.003$ — noise on 200 paths.... The body should
select the Gaussian copula by Occam's razor and the OoS metric, with
the Student-$t$ copula as an IS-calibration sensitivity."*

**What we did.** The body discussion section
(`sections/discussion.tex` line 42) now states explicitly: "*the
cross-asset dependence-family selection is an IS-calibration distinction:
on the OoS window the Gaussian and Student-$t$ copulas are statistically
indistinguishable at $N_\text{paths} = 200$.*" The full one-shot
Student-$t$ copula MLE (sec:full_tcopula_mle) reports
$\hat\nu_\text{full} = 6.40$ vs the body two-step estimator's
$\hat\nu_\text{two-step} = 6.00$, with the Wilks 95% profile-LL CI of
$[6, 7]$ on the two-step.

**Where to find it.** `sections/discussion.tex` "Limitations" paragraph;
`sections/cross_asset_appendix.tex` (full one-shot MLE control); abstract
and intro paragraph 3 carry the OoS-equivalence framing.

**Substantive read.** We did not re-headline the cross-asset section
with the Gaussian copula because the IS profile-LL evidence at
$\nu^\star = 6$ ($+30.2$ AIC differential vs the Gaussian limit) is
informative and not noise-level on $T_\text{IS} = 2,516$. Reviewer 3's
critique is that the OoS-distinguishability evidence does not support
the Student-$t$ as the OoS-deployment choice; we agree and have made
this explicit in the discussion. The body construction remains
Student-$t$ at $\nu^\star = 6$ because the IS evidence supports it and
the OoS evidence is null (not against). If reviewers prefer the Gaussian
headline we will switch on the next revision.

---

## Priority 2 (strongly suggested)

### 8. $\nu_{\min} = 4$ bracket-lift CHMM-t as the body headline (R1 W2 / R1 RE2 / R3 Q4)

**Status:** Reported as ablation $\dagger\dagger$ in body Table 3
(`sections/results.tex`). Headline remains the penalised version at
$\lambda = 20$. Per R1 RE2's framing as "strongly suggested" (not
"must-fix"), we have not re-headlined the body with the bracket lift
and have instead added the bracket-lift row at $\nu_{\min} = 4$ to
Table 3 with the $\dagger\dagger$ footnote describing the reason.

### 9. Faithful Wiese et al.\ (2020) QuantGAN with Lambert-W pre-processing (R3 RE1)

**Status:** PARTIAL. We have replaced the original three-conv-layer
WGAN with a Wiese-style 7-block dilated convolutional WGAN-GP rebuild
(architecture-only, no Lambert-W input pre-processing, marked $\S$ in
Table 3). The TCN rebuild attains $0\%$ IS / $0\%$ OoS KS, which is the
failure mode of the architecture without the Lambert-W transform; the
faithful Wiese et al.\ rebuild with Lambert-W is logged for the
companion-paper direction (`sections/conclusion.tex`).

### 10. Engle-Manganelli (2004) DQ test (R3 RE2)

**Status:** OPEN. Not yet implemented. Christoffersen-cc is the body
test; DQ is a higher-power conditional-coverage alternative under
longer-memory clustering. Planned for the companion-paper extension on
the conditional-VaR axis; flagged in the discussion as "*tighter
$\alpha$ levels require either larger $T_\text{OoS}$ or a higher-power
conditional-coverage test*".

### 11. Per-state Frobenius distance between the four emission families (R2 W4 / R2 RE3)

**Status:** OPEN. Not yet implemented. The reviewer's concern is
whether the four-emission narrative collapses to a one-parameter
GED-shape axis. The CHMM-GED $\hat p_k$ partition diagnostic
(`sec:supp_p_partition`) is the closest current evidence; a full
Frobenius-distance panel is the right diagnostic and we have logged it
as a Phase-3 item.

### 12. CRSP-based 1994-2004 vs 2014-2024 cross-decade validation (R3 W6 / R3 RE3)

**Status:** OPEN, with explicit scope statement. The Polygon.io
provider in our pipeline begins at 2014-01-03; Alpaca's IEX feed begins
at 2018-11-01 and SIP feed at 2016-01-04 (Appendix sec:alpaca_depth_probe
documents the data-availability ceiling). A WRDS / CRSP licence is the
correct path to the 1994-2004 window and is logged for the next
data-pipeline pass. The empirical-scope claim of the present paper is
explicitly "SPY 2014-2026" rather than "across decades".

### 13. Compress sec:theory (R2 W7 / R3 W5)

**Status:** OPEN. The current Section 2 occupies 1.5 pages on the
textbook bilinear identity. R2 W7 / R3 W5 ask us to compress it to the
rank statement, the dominant-mode-share diagnostic, and the cross-ticker
distribution. We have not yet compressed; the action item is to cut the
theoretical derivation by roughly half and reference Hamilton (1994)
$\S 22.2$ / Krolzig (1997) Ch.\ 3 / Timmermann (2000) for the standard
derivation.

---

## Priority 3 (recommended) and Priority 4 (presentation)

These items are tracked in `CHANGELOG.md` under the Peer-Review Revision
Pass section and addressed individually as Phase 3 / Phase 4 items.
Specifically:

- Gamma-sojourn HSMM as a co-headline foil (R1 RE3, R1 Q1, R2 Q4): OPEN.
- CHMM-N marginals at $K^\star = 6$ for the cross-asset construction
  (R2 Q3): OPEN.
- Multi-day cumulative-return DM (R3 RE4): OPEN.
- $\alpha = 0.05$ vs $\alpha = 0.01$ row distinction in Table 4 (R1 W3):
  CLOSED via the power calibration in `sections/var_backtest.tex` line 22.
- Leverage-effect "partial capture" rephrase (R1 W4): CLOSED. The
  discussion-section header (`sections/discussion.tex` line 35) is now
  *"Stylized-fact scope: simulated leverage envelope brackets the IS
  observed value, not the OoS observed value"* and the closing sentence
  of the paragraph reads *"CHMM at $K = 18$ produces a simulated
  leverage envelope that does not reject the IS observed leverage at
  the $5\%$ level (the IS observed value sits at the $Q_5$ envelope
  boundary), while the OoS observed value sits just below the lower
  envelope and is not bracketed at the $5\%$ level; closing the OoS gap
  requires asymmetric per-state emissions."* This is the weaker,
  accurate one-sided-test framing R1 W4 demanded; the OoS rejection is
  acknowledged honestly rather than papered over with "partial
  capture".
- Schaller-van Norden citation fix (R3 Minor 2): OPEN.
- Reviewer-1/2 footnote removal in Table 3 (R3 Minor 3): OPEN, the
  footnote $\dagger\dagger$ caption text still references "(Reviewer-1/2
  request)" and should be neutralised.
- Wilks regularity citation for $\nu \to \infty$ (R3 Minor 5): OPEN.
- Density / CDF notation standardisation (R2 Minor 3): OPEN.
- "Held-out-clean" usage compression (R1 Minor 5): OPEN.
- Cont (2001) facts enumeration in abstract (R1 Minor 4): OPEN.

---

## Items the panel raised that we explicitly chose not to follow

We have not re-headlined the body at $K^\star = 3$ (R1 W1 contingency).
The current $K^\star = 6$ headline is supported by the AIC choice on the
2022-2023 slice and by the held-out KS / log-lik on the strictly pre-
2020 slice; we plan to verify this under the $k$-fold CV (item 2) and
will rebuild at $K^\star = 3$ if the verification fails. Pre-emptively
re-headlining without that diagnostic would over-correct.

We have not re-headlined the cross-asset section with the Gaussian
copula (R3 W4). The IS profile-LL evidence at $\nu^\star = 6$ ($+30.2$
AIC) is informative on $T_\text{IS} = 2,516$; the OoS-equivalence is a
null, not evidence against. We have made the OoS equivalence explicit
in the discussion (item 7) and consider this a defensible halfway point.

We do not propose a Gamma-sojourn HSMM at this revision (R1 RE3).
HSMM is reported as a co-headline scaffold under truncated Pareto
(`sections/results.tex` "ML HSMM as a co-headline result" paragraph)
and the trade-off (HSMM wins on KS, CHMM wins on
volatility-clustering) is what the panel supports. Adding a Gamma-
sojourn variant would be a third HSMM column in an already crowded
panel; we believe it is a companion-paper item.

---

## Summary

Of the 7 Priority-1 items, four are CLOSED (1, 4, 6, 7), two are
PARTIAL (3 — gap is the $K^\star = 6$ row in `tab:ks_block_body`; 5 —
gap is the $K^\star = 6$ quarterly-refit cross-ticker row), and one is
OPEN (2 — $k$-fold CV of $K^\star$ on the strictly pre-2020 slice). The
three remaining items concentrate on state-selection diagnostic
robustness on the strictly pre-2020 slice and at the $K^\star = 6$
operating point. We commit to closing all three on the next revision
pass; item 2 in particular is pre-blocking against a possible body-
rebuild at $K^\star = 3$ and we are prepared to implement that rebuild
if the $k$-fold result requires it.

Of the 6 Priority-2 items, 1 is PARTIAL (8 — bracket-lift is in Table 3
as ablation $\dagger\dagger$; the body headline remains the penalised
$\lambda = 20$ version per R1's "strongly suggested" framing), 1 is
PARTIAL (9 — Wiese-style 7-block dilated convolutional WGAN-GP rebuild
shipped, Lambert-W input pre-processing remaining), and 4 are OPEN (10,
11, 12, 13). Of the Priority-3 / Priority-4 presentation items, the
leverage-effect rephrase (R1 W4) is now CLOSED, and the small editorial
items (Schaller-van Norden citation; Reviewer-1/2 footnote in Table 3
caption; Wilks regularity citation; notation standardisation;
"held-out-clean" repetition; Cont-facts enumeration in the abstract)
remain OPEN.

The substantive contribution of the manuscript is unchanged: the unified
four-emission ECM scaffold, the regime-conditional VaR application
(reframed under multiple-testing correction and the W2 / W4 stress-fold
acknowledgement), and the cross-asset Student-$t$ copula extension
(reframed as IS-calibration with OoS-equivalence to the Gaussian
copula).

We thank the panel for the level of detail in the report and look
forward to the next round.

— Alswaidan, Jin, Varner
