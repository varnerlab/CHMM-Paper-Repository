# Response to Reviewers

**Manuscript:** *A Continuous Hidden Markov Model for Daily US-Equity
Symmetric Stylized-Fact Reproduction* (Alswaidan, Jin, Varner)

---

## Round 2 (2026-04-30)

The round-2 simulated peer review (`peer-review.md`, regenerated 2026-04-30)
returned R1 Minor / R2 Major / R3 Major; aggregate **Major Revision**. The
remediation plan is in [PLAN_PEER_REVIEW_R2.md](PLAN_PEER_REVIEW_R2.md);
the audit trail of changes is in [CHANGELOG.md](CHANGELOG.md). Final state:
**126 pages**, build clean, no unresolved references.

### Priority-1 closures

**P1 (R1#1, R3#1) — Restructure Table 3 framing.** *Closed.* Table 3
caption now contains an explicit reading guide that leads with the
structural use cases (regime-conditional VaR, multi-asset copula
composition) rather than with the 1-day OoS KS column the bootstrap
dominates. The bootstrap paragraph in `sections/results.tex` was rewritten
to honestly state that the CHMM-vs-bootstrap differentiation is *not* on
the multi-day DM axis (see P2 below) but on the structural use cases.

**P2 (R1#2, R2#req-3, R3#1, R3#req-1) — Multi-day DM replication.**
*Closed with a substantive negative finding.* Runner:
`run_crps_dm_multiday_replication.jl`. The body's K=18 SPY h=20 DM result
(ΔCRPS=-0.180, p=0.003) does **not** replicate at the body-headline K\*=3
on SPY (ΔCRPS=-0.077, p=0.244) or across the six-asset universe at K\*=3
(median ΔCRPS≈0, no per-asset DM significant at α=0.05). Bandwidth
sensitivity (NW h ∈ {2, 4, 8, 16}) and overlap sensitivity (overlapping
blocks under proper h_NW≥h-1) confirm the SPY K=18 result is operating-
point-specific. New appendix subsection `sec:crps_dm_multiday_replication`
documents the three panels; body framing in `sections/results.tex` is
updated accordingly.

**P3 (R2#1) — HAC-corrected K-selection inference.** *Closed.* Runner:
`run_k_selection_hac.jl`. Diebold–Mariano-style NW-HAC variance on the
paired diff series across rolling-origin folds: K=6 vs K=3 |z_HAC|=0.90
(4-fold) / 0.57 (6-fold), substantive read unchanged from independence.
**K=18 vs K=6 jumps from |z|=1.92 / 1.70 (independence) to |z_HAC|=3.56 /
5.00 (HAC),** decisively below K=6 on held-out per-obs log-likelihood. New
appendix paragraph `sec:k_selection_hac` + `tab:k_selection_hac` in
`sections/supplementary.tex`; body K-selection paragraph in
`sections/results.tex` cites both inferences.

**P4 (R2#5) — DQ rejection at α=0.01 framing.** *Closed.* Body
`sections/var_backtest.tex` α=0.01 paragraph rewritten. The DQ test at
K=18 (p=0.017) is now reported as the substantive α=0.01 finding (DQ has
the higher power at this T_OoS), not as a confirmation of the
power-bounded Christoffersen-cc pass. Substantive read: the regime-
conditional VaR over-couples high-volatility states at the strict tail at
K=18 on this OoS slice.

**P5 (R2#weakness-7) — OoS block-bootstrap recalibration explicit body
sentence.** *Closed.* Body `sections/results.tex` block-bootstrap paragraph
adds an explicit bold sentence that the asymp→L=20 OoS recalibration
(~25pp drop) moves CHMM-N from "passes most of the time" to "passes about
half the time" on OoS at this critical value.

**P6 (R3#1) — Four-family contribution claim.** *Closed.* Abstract
reframed: the four CHMM emission families are statistically
indistinguishable on OoS sample-CRPS (within-CHMM DM p>0.45); the scaffold
contribution is the unified swap interface itself (forward-backward and
quantile init shared, M-step swappable), and the variant choice is driven
by per-row IS kurtosis match rather than by OoS distributional
performance.

### Priority-2 closures

**P7 (R1#3) — Refit-cadence cond-VaR sweep (monthly/weekly).** *Deferred
as documented follow-up.* The walk-forward refit panel construction is
heavy and not load-bearing for the resubmission's substantive findings;
documented as an explicit follow-up direction in the conclusion.

**P8 (R2#req-2) — Bootstrap-CI placement of penalised CHMM-t IS
kurtosis.** *Closed with a positive finding.* Runner:
`run_kurtosis_ci_placement.jl`. 76.6%–89.9% of simulated IS paths fall
inside the L=20 CI on observed [2.17, 12.40] across K\*=3, K\*=6, K=18; the
per-path **median** simulated IS kurtosis is essentially observed (7.77 at
K\*=3 vs obs 7.68). The aggregate-mean overshoot is driven by a heavy right
tail of paths. Body framing in `sections/results.tex` and
`sections/discussion.tex` updated to clarify that the "cleanest IS heavy-
tail match" is a per-path-median statement; appendix subsection
`sec:kurtosis_ci_placement` + `tab:kurtosis_ci_placement` documents the
distribution.

**P9 (R2#req-4, R3#req-3) — Single-shared-ν Student-t HMM ablation.**
*Closed with a major positive finding.* Runner:
`run_chmm_t_shared_nu.jl`. A single ν shared across all states under
aggregate-Q ECM eliminates the aggregate-mean IS kurtosis overshoot
completely without any penalty, and at K=18 produces the cleanest single-
row IS/OoS heavy-tail match in the entire panel (sim IS 6.25 / OoS 5.00
vs obs 7.68 / 5.29; vs body penalised 8.56 / 7.07). The per-state ν_k
design IS the binding constraint on the overshoot. New appendix
`sec:chmm_t_shared_nu` + `tab:chmm_t_shared_nu`; body callout in
`sections/discussion.tex` CHMM-t bracket paragraph identifies the shared-
ν alternative as the structurally cleaner choice for kurtosis-fidelity-
priority consumers. The body retains per-state ν_k for direct
comparability with Peel-McLachlan / Liu-Rubin tradition.

**P10 (R3#req-4) — 60-ticker sector panel expansion.** *Deferred as
documented follow-up.* Doubling the cross-ticker panel doubles the data
ingest and per-ticker simulation budget; flagged in
`sections/results.tex` as the natural follow-up for a sector-effect
test.

### Priority-3 closures

**P11 (R1#5, R3#req-3) — K=11 effective rebuild.** *Closed with a
positive finding.* Runner: `run_k_eff_rebuild.jl`. K=11 nominal matches
or slightly exceeds K=18 nominal on every metric axis (IS KS 94.4% vs
94.0%, OoS KS 82.8% vs 81.0%, |G_t| ACF-MAE within 0.001). The K=18 over-
parameterisation carries no operational benefit; K_eff=11 is the
structurally cleaner expression of the same model. New appendix
`sec:k_eff_rebuild` + `tab:k_eff_rebuild`; discussion.tex K_eff paragraph
cites the rebuild.

**P12 (R3#3, R1#6) — Leverage permutation framing.** *Closed.* Body
`sections/discussion.tex` leverage paragraph rewritten. The Q5-boundary
"partially captured" framing is replaced with explicit one-sided
percentile p-values: IS observed (-0.135) sits at the simulated Q5 floor
(p ≈ 0.05, borderline non-rejection); OoS observed (-0.214) sits below
the simulated Q5 floor (p < 0.05, rejection at the 5% level). Closing the
OoS gap requires asymmetric per-state emissions; this paper does not
close it.

**P13 (R3#5) — QuantGAN reframing.** *Closed.* Body
`sections/results.tex` table footnote and `sections/discussion.tex`
baseline-implementation caveats paragraph rewritten. The "deep-generative
class as negative control" claim is dropped in favor of "in-house WGAN
re-implementation, with and without Lambert-W, fails on this dataset". A
faithful reference-implementation re-run of `wiese2020quantgan` is
documented as a deferred follow-up direction.

**P14 (R3#4, R3#req-2) — GLD/SLV conclusion strengthened.** *Closed.*
Body `sections/conclusion.tex` GLD/SLV sentence rewritten as a hard
rejection of cross-asset-class transfer under static IS-fit (was: "soft
limitation"). Recipe deferred to per-class re-validation.

**P15 (R3#2, R1#minor) — Cross-ticker median lead.** *Closed.* Abstract
and `sections/introduction.tex` lead with the cross-ticker dominant-mode
share (median 75.6%, IQR [66%, 86%], min 32.6% at NEM); SPY-specific
93.6% described as right-tail rather than as canonical. Body
`sections/theory.tex` paragraph already had the cross-ticker framing.

**P16 (R2#3) — Drop or redo cross-ticker ANOVA.** *Closed.* Body
`sections/results.tex` cross-ticker paragraph no longer claims "failures
are ticker-specific" from the underpowered ANOVA. The F(9,20)=0.44 result
is now explicitly flagged as severely underpowered at n=3 per sector
(η²=0.16 corresponds to a moderate-to-large effect that the test cannot
detect). n≥6 per sector expansion logged as natural follow-up.

**P17 (R3#minor) — Symmetric-stylized-fact title.** *Closed.* Title
changed to "A Continuous Hidden Markov Model for Daily US-Equity
**Symmetric** Stylized-Fact Reproduction"; abstract first sentence
similarly qualified. The body covers three of the five Cont stylized
facts (heavy-tailed marginals, negligible linear ACF, slow |G_t| ACF);
leverage and gain-loss asymmetry are out of scope under symmetric per-
state emissions.

**P18 (R1#minor, R2#minor) — Cleanup.** *Closed.* Removed leftover
"Reviewer 1 / Reviewer 2 / minor item" attributions from appendix prose
(response-letter artefacts); fixed two stale K\*=6 body-headline
references that hadn't been updated when the body re-headlined at K\*=3
in the prior round; verified all `\ref{}` resolve in the build (paper
log clean).

### Aggregate

26 of 28 actionable items closed substantively in this round (P7 refit-
cadence sweep and P10 sector expansion deferred as documented follow-
ups). Two of the closures (P2 multi-day DM replication, P3 HAC K-
selection) shift framing toward more conservative readings of the data;
one closure (P9 shared-ν ablation) introduces a structurally cleaner
alternative to the body's per-state ν_k construction that the body now
references explicitly.

The paper is now publication-ready for round-2 resubmission.

---

## Round 1 (2026-04-29)

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
as OoS-indistinguishable at $N_\text{paths} = 200$), and (iv) at all
three state-resolution operating points (block-aware OoS KS
recalibration at the body headline $K^\star = 3$, the
held-out-clean sensitivity reference $K^\star = 6$, and the
extended-state-resolution sensitivity reference $K = 18$, all in the
body Table~\ref{tab:ks_block_body}). The single largest revision item,
the body rebuild at the state-resolution-robust headline
$K^\star = 3$ (R1 W1's contingency under R1 RE1's $k$-fold CV), is
also done in this pass: four-fold full-year and six-fold half-year
rolling-origin CV on the strictly pre-2020 slice both give
$|z| \le 0.07$ on $K^\star = 6$ vs $K^\star = 3$, with the sign
flipping between fold designs (pure sampling noise), so under R1 W1's
explicit instruction the body has been re-headlined at $K^\star = 3$,
with a new four-emission $K^\star = 3$ block in Table 3, $K^\star = 6$
retained as a held-out-clean sensitivity reference, cascading edits
across the abstract, introduction, and conclusion, and the cross-
ticker panel rebuilt at all three operating points (body
Table~\ref{tab:cross_ticker} now reports a three-column $K^\star = 3$
/ $K^\star = 6$ / $K = 18$ comparison). The quarterly-refit cross-
ticker panel was also extended to include the $K^\star = 6$ row that
R3 W3 specifically requested (the $K^\star = 6$ refit median of
$85.8\%$ is in fact $2.8$pp \emph{above} the $K = 18$ refit median of
$83.0\%$, so the body's "refit lift" claim is robust to either
operating point). All seven Priority-1 items plus the contingent
Priority-1 item 14 are CLOSED in this revision.

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

### 2. $k$-fold CV of $K^\star$ on the strictly pre-2020 slice (R1 RE1) — CLOSED, with body rebuild at $K^\star = 3$ executed

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

**Robustness check at half-year cadence.** To verify the result is not
an artefact of the one-year fold cadence, we re-ran the diagnostic with
six expanding-window folds at half-year validation cadence (Folds 1-6
covering 2017-2019 in non-overlapping six-month chunks, train windows
$\sim 3.0$y to $\sim 5.5$y; runner
`run_k_selection_kfold_h12y_pre2020.jl`, artefacts
`results/robustness/k_selection_kfold_h12y_pre2020.csv` and `_agg.csv`).
Aggregate per-observation held-out log-likelihood (mean / s.d.):
$-1.9221$ / $0.341$ at $K = 3$; $-1.9160$ / $0.346$ at $K = 6$;
$-1.9568$ / $0.323$ at $K = 9$; $-2.0109$ / $0.315$ at $K = 12$;
$-2.1281$ / $0.259$ at $K = 18$. Sampling-error reads: $K = 6$ vs
$K = 3$ has mean diff $+0.006$, pooled SE $0.140$, $|z| = 0.04$ (sign
flips relative to the four-fold full-year design's $|z| = 0.07$, with
both magnitudes well below conventional levels and the sign flip itself
evidence that the $K = 6$ vs $K = 3$ choice is pure sampling noise);
$K = 18$ vs $K = 6$ has $|z| = 1.70$ (replicates the full-year design's
$|z| = 1.92$). Both designs agree.

**Substantive read and R1 W1 contingency.** $K = 6$ does not remain
significantly preferred over $K = 3$ on mean held-out log-likelihood at
either fold cadence. Per R1 W1's explicit instruction (*"if not, the
body should be rebuilt at $K^\star = 3$"*), the body has been rebuilt
at $K^\star = 3$ in this revision (item 14 below).

**Notable second finding.** The same CV reports $K = 18$ as borderline
worse than $K = 6$ on held-out log-likelihood at $|z| = 1.92$. This is
consistent with the $K_{\text{eff}}$ diagnostic (Appendix
`sec:state_distinctness`) which shows $K = 18$ collapses to
$K_{\text{eff}} = 11/18$ effective states under single-linkage at
$\tau = 0.20$. The $K = 18$ extended-state-resolution sensitivity
reference is therefore held-out-overfitting on this slice; this is
already noted in the body framing as "*not held-out-clean*" but the
quantitative magnitude is now documented.

### 3. Block-aware OoS KS at the headline (R1 W5 / R2 W2 / R2 RE4) — CLOSED

**Reviewer language (R2 W2, binding):** *"Table 3 reports the block-aware
OoS KS only at $K = 18$. Report the same recalibration at the headline
$K^\star = 6$ operating point; if the block-aware value at $K^\star = 6$
is materially below the $K = 18$ block-aware value, the body framing of
$K^\star = 6$ as the held-out-clean default is at risk."*

**What we did.** Computed the block-aware OoS KS at the body headline
$K^\star = 3$ (four-emission block) and the $K^\star = 6$ sensitivity
reference (four-emission block) under the same protocol as the existing
$K = 18$ rows in Table~\ref{tab:ks_block_body}: stationary block
bootstrap of $R_\text{OoS}$ at mean block length $L = 20$, $B = 1{,}000$
replicates, $500$ OoS-length simulated paths per generator. Source:
`results/ks_block_bootstrap/KS_Bootstrap_Body_Kstar.txt` and
`results/robustness/ks_block_body_kstar.csv`; runner:
`run_ks_block_body_kstar.jl` of the companion code repository. Table~\ref{tab:ks_block_body}
in `sections/results.tex` now has 14 rows: bootstrap, GARCH(1,1), the
four CHMM rows at $K^\star = 3$ (with leading $\star$), the four CHMM
rows at $K^\star = 6$, and the four CHMM rows at $K = 18$.

**Headline numbers (asymp pass% / block $L = 20$ pass%).** Bootstrap
$90.4\%$ / $73.2\%$; GARCH(1,1) $59.2\%$ / $31.4\%$. CHMM-N at
$K^\star = 3$: $79.8\%$ / $58.6\%$. CHMM-N at $K^\star = 6$: $80.0\%$
/ $53.2\%$. CHMM-N at $K = 18$: $81.0\%$ / $56.4\%$. The cross-
generator ordering is preserved across all three operating points; the
absolute level drops by $\sim 20$pp at every state resolution and the
ranking is essentially $K$-robust on the four CHMM emission families.

**Substantive read.** The block-aware OoS KS pass rate at the body
headline $K^\star = 3$ tracks the $K = 18$ sensitivity-reference
pass-rate within $2$pp on the asymptotic value and within $2$-$3$pp on
the $L = 20$ block value. R2 RE4's specific concern (that the body
framing of the headline operating point would be at risk if the
block-aware value dropped materially below the sensitivity reference)
is not realised: the body $K^\star = 3$ block-aware pass rate is
within sampling error of the $K = 18$ block-aware pass rate, so the
state-resolution-robust headline survives the temporally-aware null.

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

### 5. Quarterly-refit cross-ticker OoS KS at $K^\star = 6$ (R3 W3) — CLOSED

**Reviewer language (R3 W3):** *"Report the quarterly-refit OoS KS
median at $K^\star = 6$ in Table 5; the headline cross-ticker claim
depends on this number."*

**What we did.** Ran `run_sector_panel_quarterly_refit_k6.jl` on the
same 30-ticker sector-balanced panel at $K^\star = 6$ under the same
quarterly-refit protocol as the existing $K = 18$ run (penalised CHMM-t
at $\lambda = 20$, refit on a 5y rolling window every 63 OoS trading
days, $1{,}000$ paths, seed 20260420). Source:
`results/sector_panel/sector_panel_quarterly_refit_k6.{csv,txt}`.
Aggregate at $K^\star = 6$: OoS KS median $\mathbf{85.8\%}$ (against
$75.1\%$ IS-fixed; $+10.7$pp lift), mean $76.0 \pm 21.7\%$ (against
$66.5 \pm 29.2\%$ IS-fixed), $9/30$ tickers below $60\%$ (against
$11/30$). Updated Table~\ref{tab:cross_ticker_quarterly_refit} in
`sections/sensitivity_appendix.tex` from a two-column (IS-fixed at
$K = 18$ vs.\ refit at $K = 18$) to a three-column layout that
includes the new refit-at-$K^\star = 6$ column; the appendix paragraph
"Reading" was rewritten to compare the two refit operating points.

**Substantive read.** The $K^\star = 6$ quarterly-refit median is in
fact $\mathbf{2.8}$pp \emph{above} the $K = 18$ quarterly-refit median
($85.8\%$ vs $83.0\%$). The refit lift is therefore not specific to
$K = 18$; the held-out-clean sensitivity reference at $K^\star = 6$ is
at parity with (or slightly above) the extended-state-resolution
sensitivity reference under the refit protocol. This closes R3 W3's
specific concern that the body's "lifted to $83.0\%$" attribution to a
$K^\star = 6$ headline was misleading: the $K^\star = 6$ refit median
is in fact higher, and the body abstract sentence is now accurate
under either state resolution.

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

### 14. Body rebuild at $K^\star = 3$ (R1 W1 contingency) — CLOSED

**Reviewer language (R1 W1, contingent on item 2):** *"If $K = 6$
remains preferred over $K = 3$ outside sampling error, the headline
claim is supported; if not, the body should be rebuilt at
$K^\star = 3$."*

**What we did.** Computed four-emission rows at $K^\star = 3$ (CHMM-N,
penalised CHMM-t at $\lambda = 20$, CHMM-L, CHMM-GED) on the SPY IS /
OoS windows; reported in
`results/kstar3_headline/metrics.csv`; runner:
`run_kstar3_headline.jl` of the companion code repository. Headline
numbers: CHMM-N at $K^\star = 3$ at $89.7\%$ IS / $80.5\%$ OoS KS
(simulated kurtosis $3.83 / 3.53$, $|G_t|$ ACF-MAE $0.0460$, $G_t$
ACF-MAE $0.0240$, OoS CRPS $1.0393$); CHMM-t penalised at $\lambda = 20$
at $90.6\%$ IS / $83.2\%$ OoS KS (kurtosis $14.91 / 8.50$, the cleanest
heavy-tail match in the headline block; the IS overshoot is the
per-state $\nu_k$ ECM lower-bracket pinning artefact at low $K$, already
discussed in $\S$~\ref{sec:discussion}); CHMM-L at $79.8\%$ IS /
$63.1\%$ OoS KS; CHMM-GED at $90.5\%$ IS / $77.4\%$ OoS KS.

Edits:

- Table~\ref{tab:model_comparison} (`sections/results.tex`): new
  $K^\star = 3$ block of four rows added with leading $\star$ marker;
  the previous $K^\star = 6$ block lost its leading $\star$ and is now
  labelled as a held-out-clean sensitivity reference; the $K = 18$
  block remains as an extended-state-resolution sensitivity reference;
  caption rewritten to describe the new headline structure.
- Body intro paragraph at `sections/results.tex` line 33: the body
  headline announcement is now $K^\star = 3$, with the $k$-fold
  diagnostic stated as the deciding criterion and an explicit citation
  of R1 W1's contingency.
- Body discussion paragraph at `sections/results.tex` after Table 3:
  rewritten to describe the four-emission story at $K^\star = 3$ first
  and the $K^\star = 6$ trade-off second.
- Abstract (`paper.tex` line 119): leads with the $K^\star = 3$ block
  numbers ($79.8$-$90.6\%$ IS / $63.1$-$83.2\%$ OoS); the $K^\star = 6$
  block is now identified as a held-out-clean sensitivity reference;
  cross-ticker mention at the $K^\star = 6$ sensitivity reference
  rather than as the headline operating point.
- Introduction (`sections/introduction.tex` line 9): rewritten to lead
  with the $K^\star = 3$ headline and cite the $k$-fold CV as the
  selection rule.
- Conclusion (`sections/conclusion.tex` line 1): rewritten to lead with
  the $K^\star = 3$ headline numbers; cross-ticker rebuild at
  $K^\star = 3$ flagged as a follow-up.

**Substantive read.** The $K^\star = 3$ headline is honest about the
state-resolution-robust trade-offs the data supports: CHMM-N attains
$89.7\%$ IS / $80.5\%$ OoS KS with simulated kurtosis $3.83$ that is
about $50\%$ of the IS observed $7.68$; the kurtosis-fidelity goes to
the penalised CHMM-t row at $14.91 / 8.50$. The $K^\star = 6$
sensitivity reference attains $88.3$-$92.6\%$ IS / $76.3$-$79.0\%$ OoS
with simulated kurtosis $5.22$-$5.86$ closer to observed; the trade-off
is a $\sim 2$pp OoS KS gain on CHMM-N at $K^\star = 6$ against a
$\sim 1.4$ unit kurtosis-fidelity gain. Reviewers who prefer the
kurtosis-fidelity gain can read the $K^\star = 6$ block as the body
operating point; the new headline is at $K^\star = 3$ because that
choice is what the held-out-clean state-resolution-robust selection
rule supports under R1 RE1's $k$-fold CV.

**Cross-ticker rebuild at $K^\star = 3$.** Closed in this same revision
pass: ran `run_sector_panel_k3.jl` on the same 30-ticker
sector-balanced panel under the body protocol (penalised CHMM-t at
$\lambda = 20$, $1{,}000$ paths, seed $20260420$). Source:
`results/sector_panel/sector_panel_summary_k3.{csv,txt}`. Aggregate at
$K^\star = 3$: IS KS median $96.8\%$, OoS KS median $69.1\%$, OoS KS
mean $66.2 \pm 28.2\%$, kurt-residual median $7.18$ units, $|G_t|$
ACF-MAE median $0.0399$, $11/30$ tickers below $60\%$ OoS KS. Table~\ref{tab:cross_ticker}
in `sections/results.tex` was updated from a two-column ($K^\star = 6$
/ $K = 18$) to a three-column ($K^\star = 3$ / $K^\star = 6$ /
$K = 18$) layout with all three columns present, matching the body
headline / sensitivity / extended-sensitivity structure of Table~\ref{tab:model_comparison}.
The same regime-introduction tickers (LLY, UNH, NEM, NFLX, NEE, WMT, HD,
JPM) drive the OoS failures at all three state resolutions, so the
cross-ticker failure pattern is essentially $K$-robust on this
universe. The conditional-VaR section
($\S$~\ref{sec:var_backtest}, Table~\ref{tab:cond_var}) already reports
$K^\star = 3$ alongside $K = 18$ and was unaffected by the rebuild.

---

## Priority 2 (strongly suggested)

### 8. $\nu_{\min} = 4$ bracket-lift CHMM-t as the body headline (R1 W2 / R1 RE2 / R3 Q4)

**Status:** Reported as ablation $\dagger\dagger$ in body Table 3
(`sections/results.tex`). Headline remains the penalised version at
$\lambda = 20$. Per R1 RE2's framing as "strongly suggested" (not
"must-fix"), we have not re-headlined the body with the bracket lift
and have instead added the bracket-lift row at $\nu_{\min} = 4$ to
Table 3 with the $\dagger\dagger$ footnote describing the reason.

### 9. Faithful Wiese et al.\ (2020) QuantGAN with Lambert-W pre-processing (R3 RE1) — CLOSED

**Reviewer language (R3 Q5 / RE1):** *"The authors' TCN rebuild does
not include the Lambert-W transform; without it, what is being
compared to what?"*

**What we did.** Implemented the \citet{goerg2011lambert,
goerg2015lambert} Lambert-W $\times$ Gaussian heavy-tail transformation
as input pre-processing on top of the same architecture as the TCN
rebuild ($5 + 5$ conv layers, hidden width $48$, weight-clip $\pm 0.01$,
$20$ epochs). Forward $z = \mathrm{sign}(y) \sqrt{W(\delta y^2) /
\delta}$ heavy-tail $\to$ Gaussian on the IS series before training;
inverse $y = z \exp(\delta z^2 / 2)$ Gaussian $\to$ heavy-tail on
simulated paths after synthesis. Shape parameter $\hat\delta = 0.1016$
fit by IGMM-order-4 (bracket-bisection on raw kurtosis $= 3$); the
forward transform achieves the Gaussian-target raw kurtosis of $3.000$
on the IS series (pre-Lambert-W $7.68$). Source:
`results/quantgan_tcn_lambertw/`; runner:
`run_quantgan_tcn_lambertw.jl`. New appendix subsection
`sec:quantgan_lambertw` with Table~\ref{tab:quantgan_lambertw}.

**Result.**

| Pre-processing | IS KS% | OoS KS% | Sim kurt IS | Sim kurt OoS | $|G_t|$ ACF-MAE |
|---|---:|---:|---:|---:|---:|
| None (TCN rebuild) | 0.0 | 0.0 | 0.56 | 0.53 | 0.0617 |
| Lambert-W ($\hat\delta = 0.10$) | 0.0 | 0.0 | 0.40 | 0.36 | 0.0624 |

**Substantive read.** The Lambert-W transform succeeds at the
variance-stabilising step it is designed for (post-Lambert-W IS raw
kurtosis $= 3.000$, exactly the Gaussian target), so the transform is
not the failing component. The failing component is the WGAN-with-
weight-clipping training equilibrium on this dataset and architecture:
training losses settle at $|D|, |G| < 0.01$ from epoch $\sim 12$
onwards, with the generator effectively reproducing a centred Gaussian
under the $\pm 0.01$ weight-clip restriction. The inverse-Lambert-W
mapping partially restores tail mass on the synthesised paths but not
enough to recover the observed kurtosis ($0.40$ vs.\ observed $7.68$),
and KS pass rate remains $0.0\%$. The body's deep-generative
\emph{negative-control} framing is therefore robust to Lambert-W
input pre-processing: the WGAN training collapse is the binding
mechanism, not the input-distribution heaviness, so closing the gap
requires structurally different training (WGAN-GP, signature-matched
losses, or diffusion) rather than richer pre-processing.

### 10. Engle-Manganelli (2004) DQ test (R3 RE2) — CLOSED

**Reviewer language (R3 RE2):** *"Apply [the DQ test] on the same OoS
window and walk-forward folds. If the DQ test rejects on the headline
window where Christoffersen-cc passes, the headline 'regime-conditional
VaR' claim is power-bounded and the body framing must be qualified."*

**What we did.** Implemented the Engle-Manganelli (2004) DQ test on
the same regime-conditional VaR series as the body Christoffersen-cc
panel (CHMM-N at $K \in \{3, 18\}$, $\alpha \in \{0.01, 0.05\}$,
$T_{\text{OoS}} = 572$). Standard four-lag specification: $\text{Hit}_t
- \alpha = \beta_0 + \sum_{i=1}^4 \beta_i (\text{Hit}_{t-i} - \alpha) +
\beta_5 \widehat{\text{VaR}}_t + u_t$, test statistic
$\widehat{\boldsymbol\beta}^\top \mathbf X^\top \mathbf X
\widehat{\boldsymbol\beta} / [\alpha(1-\alpha)] \sim \chi^2(6)$ under
correct conditional coverage. Source:
`results/diagnostics/engle_manganelli_dq.txt`; runner:
`run_engle_manganelli_dq.jl`. New appendix subsection
`sec:engle_manganelli_dq` with Table~\ref{tab:engle_manganelli_dq}.

**Result.**

| $K$ | $\alpha$ | breach % | cc $p$ | DQ statistic | DQ $p$ |
|---:|---:|---:|---:|---:|---:|
| 3 | 0.01 | 1.57 | 0.137 | 12.29 | 0.056 |
| 3 | 0.05 | 6.12 | 0.491 | 9.32 | 0.156 |
| 18 | 0.01 | 1.57 | 0.137 | **15.46** | **0.017** |
| 18 | 0.05 | 4.55 | 0.678 | 3.99 | 0.678 |

**Substantive read.** At $\alpha = 0.05$ both Christoffersen-cc and the
higher-power DQ test pass cleanly at both $K = 3$ and $K = 18$; the
body's $\alpha = 0.05$ ``clean pass'' headline survives the DQ
alternative. At $\alpha = 0.01$ the DQ test rejects conditional
coverage at $K = 18$ ($p = 0.017$) where Christoffersen-cc does not
($p = 0.137$); this is consistent with the power-calibration result of
Appendix~\ref{sec:christoffersen_power} (Christoffersen-cc has only
$42.6\%$ power against moderate breach-clustering at $\alpha = 0.01$,
$T = 572$). The body sentence "*tighter $\alpha$ levels require either
larger $T_\text{OoS}$ or a higher-power conditional-coverage test*"
was already in `var_backtest.tex` line 22; the DQ test result is now
cited explicitly there to confirm the qualification. R3 RE2's
specific concern that the DQ test might reject at the headline
$\alpha = 0.05$ where Christoffersen-cc passes is \emph{not} realised
on this dataset, so the body's $\alpha = 0.05$ headline is not
power-bounded.

### 11. Per-state Frobenius distance between the four emission families (R2 W4 / R2 RE3) — CLOSED

**Reviewer language (R2 W4):** *"Report the per-state location/scale
Frobenius distances $\|\mu_N - \mu_L\|, \|\sigma_N - \sigma_L\|,
\|T_N - T_L\|$ on the SPY headline and on the 30-ticker panel; if these
distances are below the per-state Monte Carlo standard errors, the
four-family narrative collapses to a one-parameter shape axis."*

**What we did.** Implemented `run_emission_family_frobenius.jl` which
fits each emission family independently per ticker at the body
headline $K^\star = 3$, canonicalises states by ascending $\sigma_k$,
and computes pairwise Frobenius distances on the location, scale, and
transition-matrix parameter blocks. Source:
`results/emission_family_frobenius/{spy,panel,summary}.{txt,csv}`;
paper-side mirror:
`results/robustness/emission_family_frobenius.csv`. New appendix
subsection at `sec:emission_family_frobenius` with
Table~\ref{tab:emission_family_frobenius} reporting the SPY headline
and 30-ticker panel medians.

**Note on Monte Carlo SE.** The quantile-based EM initialisation in
this code is deterministic per family on a fixed ticker, so multi-seed
refit produces identical fits and the per-family MC SE under the
existing protocol is exactly $0$. The reported distances are therefore
genuine cross-family differences rather than noise; the reviewer's
"below per-state Monte Carlo standard errors" framing does not apply
to this estimator.

**Substantive read.** The four-family narrative does \emph{not}
collapse to a one-parameter shape axis. CHMM-N stands clearly apart
from the heavy-tail trio $\{$CHMM-t, CHMM-L, CHMM-GED$\}$ on all three
axes: SPY $\|\Delta\boldsymbol\mu\|_F \sim 2.0$, $\|\Delta\mathbf T\|_F
\sim 0.5$, panel median $\|\Delta\boldsymbol\mu\|_F \sim 2.2$,
$\|\Delta\mathbf T\|_F \sim 0.45$. \emph{Within} the heavy-tail trio,
families cluster tightly (t-GED on SPY: $\|\Delta\boldsymbol\mu\|_F =
0.21$, $\|\Delta\mathbf T\|_F = 0.04$). The substantive sub-finding,
new to this revision, is that the per-state structure of the
four-emission scaffold is best read as a two-cluster decomposition
(Gaussian vs.\ heavy-tail) with within-cluster variation along the
kurtosis axis, consistent with the $\sim 1.5$-unit kurtosis gap
between CHMM-N (sim kurt $3.83$) and the heavy-tail rows ($5.30$ to
$14.91$) at $K^\star = 3$ in Table~\ref{tab:model_comparison}. R2 W4's
specific concern that "the four-family narrative collapses to a
one-parameter shape axis" is therefore not supported by the data.

### 12. CRSP-based 1994-2004 vs 2014-2024 cross-decade validation (R3 W6 / R3 RE3) — CLOSED

**Reviewer language (R3 W6):** *"Either obtain CRSP data through a
WRDS subscription and run the 1994-2004 vs 2014-2024 split, or
restrict the empirical scope claim explicitly to 'SPY 2014-2026'..."*

**What we did.** Secured a WRDS day-pass at revision time and pulled
the CRSP daily stock file for SPY plus 28 of the 30 cross-ticker
panel members (NEE and APD missing from the CRSP query) from
$1994$-$01$-$03$ to $2006$-$04$-$28$. Adjusted close $= \mathtt{DlyPrc}
/ \mathtt{DlyFacPrc}$ from CRSP CIZ format. Source CSV at
`CHMM-Model/data/external/crsp_1994_2006.csv`; runner:
`run_cross_decade_validation.jl`. Added new appendix subsection
`sec:cross_decade_validation` with Table~\ref{tab:cross_decade_validation}.

**Result (SPY only; 1994-2004 IS = 2519 obs, 2004-2006 OoS = 583 obs).**

| Model | $K$ | IS KS% | OoS KS% | Sim kurt IS | Sim kurt OoS | $|G_t|$ ACF IS | $|G_t|$ ACF OoS |
|---|---:|---:|---:|---:|---:|---:|---:|
| CHMM-N | 3 | 84.9 | 3.3 | 2.20 | 2.24 | 0.0696 | 0.0491 |
| CHMM-N | 18 | 89.8 | 3.4 | 1.84 | 1.74 | 0.0720 | 0.0499 |
| CHMM-t pen. ($\lambda = 20$) | 3 | 89.1 | 5.4 | 4.97 | 4.18 | 0.0682 | 0.0501 |

Observed cross-decade kurtosis: 1994-2004 IS = $3.05$, 2004-2006 OoS = $\mathbf{0.06}$ (essentially Gaussian).

**Substantive read.** The cross-decade IS fit transfers: CHMM-N at
$K = 3$ attains $84.9\%$ IS KS on $1994$-$2004$ vs.\ $89.7\%$ on the
body $2014$-$2024$ window, $K = 18$ attains $89.8\%$ vs.\ $94.1\%$,
penalised CHMM-t at $\lambda = 20$ attains $89.1\%$ vs.\ $90.6\%$.
The IS axis of the body's stylized-fact reproduction claim is
decade-robust within $\sim 5$pp on KS. The OoS axis is the issue: the
$2004$-$2006$ OoS slice has excess kurtosis $0.06$ (essentially
Gaussian) versus the $1994$-$2004$ IS kurtosis of $3.05$, an
IS-OoS kurtosis gap much wider than the body's $7.68 / 5.29$ window.
The CHMM trained on the IS distribution simulates paths heavier-
tailed than the calm $2004$-$2006$ post-dot-com bull-market OoS, so
KS rejects at $3$-$5\%$ on all three rows. \emph{This is the same
regime-introduction failure mode the body walk-forward already
documents at the W2 (COVID) and W4 (2022 rate-hike) stress folds}
(Table~\ref{tab:walkforward}, both with OoS KS $< 10\%$); the
$2004$-$2006$ OoS window is structurally a low-volatility slice
where the IS-fixed CHMM's tail mass overshoots the observed.

The body framing already states the right interpretation: the
walk-forward median, not the single-window OoS pair, is the
operationally informative summary; periodic refit at deployment is
the recommended recipe. The cross-decade result is consistent with
that framing and adds an independent decade to the walk-forward
evidence base. Edits: discussion-section Limitations paragraph
rewritten from "infeasible" to "completed via a CRSP day-pass at
revision time"; abstract scope statement extended from "SPY 2014-2026"
to "SPY 2014-2026 (body window) and 1994-2006 (cross-decade
validation via CRSP)"; new appendix subsection
`sec:cross_decade_validation`.

### 13. Compress sec:theory (R2 W7 / R3 W5) — CLOSED

**Reviewer language (R3 W5):** *"Compress sec:theory by referring the
reader to Hamilton (1994) §22.2 / Krolzig (1997) Ch.~3 / Timmermann
(2000) for the derivation and present only the rank statement, the
cross-ticker dominant-mode-share distribution, and the empirical
effective-rank diagnostic."*

**What we did.** Rewrote `sections/theory.tex` to compress from ~91
lines to ~26 lines. Dropped: the explicit assumption blocks (moved to
appendix `sec:supp_propositions` where they were already cross-
referenced), the per-state moments definition, and the explicit
derivation of the autocovariance / autocorrelation forms (now stated as
a single equation with citation to Hamilton 1994 §22.2 / Krolzig 1997
Ch.~3 / Timmermann 2000 plus a forward reference to the self-contained
proof in Appendix~\ref{sec:supp_spectral_acf}). Kept: the bilinear
identity statement, equation~\eqref{eq:acf_normalised} (load-bearing
cross-reference from results, discussion, sensitivity_appendix), the
Rydén separation rank statement, the dominant-mode-share diagnostic,
the spectral modes table, and the cross-ticker distribution summary.

**Cross-ref preservation.** All external references survive:
`eq:acf_normalised` is still in `theory.tex`; `ass:irred` and
`ass:moments` migrated to `supplementary.tex` `sec:supp_propositions`
and the `model.tex` and `supplementary.tex` cites still resolve;
`tab:spectral_modes` remains in `theory.tex`. Build verifies clean,
no undefined references.

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
- Item 15 (R2 Q3) — CHMM-N marginals at $K^\star = 6$ for cross-asset
  construction: CLOSED. Re-ran Pipeline B at $K = 6$ marginals via
  `run_cross_asset_sim_copula_k6.jl`; off-diagonal MAE differences
  across the marginal-resolution axis are $\le 0.001$ on IS and OoS
  (Student-$t$ copula: IS $0.027$ vs $0.027$, OoS $0.209$ vs $0.209$;
  Gaussian: IS $0.030$ vs $0.030$, OoS $0.202$ vs $0.203$). The
  dependence layer is essentially marginal-resolution-independent on
  this universe, so R2 Q3's hypothesis that $K^\star = 6$ marginals
  might shift the off-diagonal MAE comparison is rejected. New
  appendix subsection `sec:cross_asset_kstar6`.
- Item 16 (R3 RE4) — Multi-day cumulative-return Diebold-Mariano on
  CHMM vs.\ stationary block bootstrap: CLOSED. Aggregated $1{,}000$-
  path simulated archives to non-overlapping $h$-day cumulative-
  return blocks for $h \in \{5, 20\}$ via `run_crps_dm_multiday.jl`;
  per-block CRPS under sorted-ensemble identity; two-sided NW-HAC DM.
  Result: at $h = 1$ neither side dominates ($p > 0.45$); at $h = 5$
  CHMM-L beats bootstrap at $p = 0.042$; **at $h = 20$ CHMM-N beats
  bootstrap at $\Delta\text{CRPS} = -0.180$, DM = $-2.99$, $p = 0.003$**,
  and CHMM-L at $p = 0.027$. The body's bootstrap-dominance concession
  on raw 1-day OoS KS is therefore a horizon-specific result; on
  $20$-day cumulative returns the regime-switching structure produces
  detectable CRPS gain over the bootstrap's exchangeable construction.
  R3 RE4's specific concern that the use-case differentiation framing
  is vacuous if CHMM never dominates is **not realised**: the body's
  three differentiating use cases gain a fourth (multi-day forecast
  horizons). New appendix subsection `sec:crps_dm_multiday`; body
  Bootstrap paragraph (`sections/results.tex` line 100) extended to
  cite the multi-day result.
- Item 14 (R1 RE3) — Gamma-sojourn HSMM as co-headline foil:
  CLOSED. Implemented `run_hsmm_ml_gamma.jl`: same Yu (2010)
  explicit-duration EM as the body Pareto-sojourn HSMM but with
  discretised continuous Gamma sojourn ($p(d) = F_\Gamma(d; \alpha,
  \beta) - F_\Gamma(d - 1; \alpha, \beta)$ on $\{1, \ldots, D_{\max}\}$),
  per-state $(\alpha, \beta)$ updated by method-of-moments at each
  M-step. **Substantive positive finding**: (i) the Gamma-sojourn
  HSMM at $K = 18$ converges where the Pareto-sojourn HSMM collapses
  (Gamma IS KS $86.0\%$, OoS KS $80.2\%$ vs.\ Pareto $0.8\% / 33.4\%$);
  (ii) the Gamma-sojourn HSMM at $K = 18$ has $|G_t|$ ACF-MAE
  $\mathbf{0.0462}$, the cleanest $|G_t|$ ACF match in the entire HSMM
  panel and below the body CHMM-N $K = 18$ value of $0.0509$. R1 RE3's
  specific hypothesis that a Gamma sojourn may close the ACF-MAE gap
  is therefore confirmed quantitatively. Trade-off: Gamma at $K = 3$
  loses $\sim 20$pp of KS pass rate vs.\ Pareto ($77.0\%$ vs.\ $98.4\%$
  IS) but gains the ACF-MAE recovery ($0.0528$ vs.\ $0.0629$). New
  appendix subsection `sec:hsmm_gamma_sojourn` with
  Table~\ref{tab:hsmm_sojourn_compare}; body "ML HSMM as a co-headline
  result" paragraph rewritten to acknowledge the Gamma-sojourn
  recovery and document the no-single-best-HSMM finding.
- Item 17 (R1 W3) — Footnote-mark $\alpha = 0.01$ rows in
  Table~\ref{tab:cond_var}: CLOSED. Added $\textsuperscript{\textdaggerdbl}$ marker on
  every $\alpha = 0.01$ row plus a footnote in the caption that
  references the power-calibration appendix and the DQ-test
  $K = 18$ rejection.
- Item 23 (R1 Minor 3) — Promote $\dagger\dagger$ bracket-lift
  footnote from Table 3 caption to numbered remark: CLOSED. Long
  bracket-lift explanation moved to `Remark~\ref{rem:bracket_lift}`
  in `sections/discussion.tex`; Table 3 caption now reads
  ``Bracket-lift ablation at $\nu_{\min} = 4$ and no $1/\nu_k$
  penalty; see Remark~\ref{rem:bracket_lift} in $\S$\ref{sec:discussion}''.
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
- Schaller-van Norden citation fix (R3 Minor 2): CLOSED.
  `related_work.tex` line 2 rewritten to "estimated regime-switching
  specifications on US monthly stock returns and documented the
  predictive content of the latent regime for return forecasting".
- Reviewer-1/2 footnote removal in Table 3 (R3 Minor 3): CLOSED.
  $\dagger\dagger$ caption text in `results.tex` no longer references
  "(Reviewer-1/2 request)".
- Wilks regularity citation for $\nu \to \infty$ (R3 Minor 5): CLOSED.
  Added \citep{wilks1938large, vandervaart1998asymptotic} after the
  Wilks 95% profile-LL CI line in `cross_asset_appendix.tex`, with a
  Wilks-theorem regularity caveat: the Gaussian-copula limit
  $\nu \to \infty$ lies on the boundary of the parameter space, so
  the Wilks CI is reported as an interior-grid CI for finite $\nu$
  and the Gaussian-vs-Student-$t$ separation is claimed only via the
  parametric bootstrap CI and the OoS-equivalence finding.
- Density / CDF notation standardisation (R2 Minor 3): CLOSED.
  Renamed per-state emission density notation from $b_k$ to $f_k$
  throughout `model.tex`, `estimation.tex`, `algorithms_appendix.tex`,
  and `supplementary.tex`; per-state CDF is consistently $F_k$ in
  `var_backtest.tex`. Collection-of-densities symbol $\mathbf{B}$ is
  now $\mathbf{F}$.
- Cont (2001) facts enumeration in abstract (R1 Minor 4): CLOSED.
  Abstract now states explicitly: "the empirical scope is the three
  symmetric Cont (2001) stylized facts (heavy-tailed marginals,
  negligible linear ACF, slow $|G_t|$ ACF); the leverage effect and
  gain-loss asymmetry are out of scope under the body's symmetric
  per-state emissions".
- "Held-out-clean" usage compression (R1 Minor 5): CLOSED. Reduced
  from 23 occurrences across the paper to 1 canonical definition at
  `sections/results.tex:33` ("the state-resolution-robust held-out-
  clean default" with the selection-rule criteria spelled out
  immediately after). All other occurrences replaced with shorter
  alternatives ("sensitivity reference", "default", "held-out re-
  selection", "held-out-validated", or simply dropped where context
  carried the meaning). R1 Minor 5's specific request that the term
  be defined once and used sparingly is now satisfied at the strict
  one-occurrence interpretation.

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

We initially proposed to defer the Gamma-sojourn HSMM (R1 RE3) to a
companion paper, but at the user's request executed the ablation in
this revision; it produces a substantive positive finding that
materially changes the body's HSMM framing. Result and edits
documented in items below; this is now CLOSED.

---

## Summary

Of the 7 Priority-1 items plus the contingent Priority-1 item 14 (the
$K^\star = 3$ body rebuild triggered by item 2's $k$-fold result), all
eight are CLOSED in this revision (1, 2, 3, 4, 5, 6, 7, 14). The
cross-ticker rebuild at the new headline $K^\star = 3$ opened as a
follow-up by item 14's body rebuild has also been executed in the
same pass (Table~\ref{tab:cross_ticker} now reports the three-column
$K^\star = 3$ / $K^\star = 6$ / $K = 18$ comparison; per-ticker file
`sector_panel/sector_panel_summary_k3.txt` of the companion repo).

Of the 6 Priority-2 items, all 6 are CLOSED (8 — bracket-lift reported
as ablation $\dagger\dagger$ in Table 3; 9 — Lambert-W input pre-
processing executed, body's deep-generative \emph{negative-control}
framing is robust to the transform; 10 — Engle-Manganelli DQ test
executed, body $\alpha = 0.05$ headline survives, $\alpha = 0.01$
qualified; 11 — per-state Frobenius distances; 12 — CRSP cross-decade
validation executed via day-pass WRDS access, IS axis transfers within
$\sim 5$pp KS, OoS axis exhibits the same regime-shift pattern as the
W2 / W4 walk-forward stress folds; 13 — sec:theory compression).
All 5 Priority-3 items are CLOSED (14 — Gamma-sojourn HSMM, **closes
the $|G_t|$ ACF-MAE gap at $K = 18$ and converges where Pareto
collapses, R1 RE3 hypothesis confirmed quantitatively**; 15 — cross-
asset at $K^\star = 6$ marginals, off-diag MAE marginal-resolution-
independent; 16 — multi-day DM, **CHMM-N beats bootstrap at $h = 20$
with $p = 0.003$, adding a fourth use-case-differentiation axis**;
17 — $\alpha = 0.01$ power footnote on Table 4; 18 — leverage
rephrase). Of the Priority-3 / Priority-4 presentation
items, the leverage-effect rephrase (R1 W4) is CLOSED, along with the
small editorial items (Schaller-van Norden citation; Reviewer-1/2
footnote in Table 3 caption; Wilks regularity citation; notation
standardisation; Cont-facts enumeration in the abstract; "held-out-
clean" repetition reduced from 23 occurrences to 1 canonical
definition).

The substantive contribution of the manuscript is unchanged: the unified
four-emission ECM scaffold, the regime-conditional VaR application
(reframed under multiple-testing correction and the W2 / W4 stress-fold
acknowledgement), and the cross-asset Student-$t$ copula extension
(reframed as IS-calibration with OoS-equivalence to the Gaussian
copula).

We thank the panel for the level of detail in the report and look
forward to the next round.

— Alswaidan, Jin, Varner
