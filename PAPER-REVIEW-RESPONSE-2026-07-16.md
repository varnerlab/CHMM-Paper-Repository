# Response to PAPER-REVIEW.md (2026-07-16)

Every checkable claim in the review was verified against the LaTeX sources, the vendored
`results/` artifacts, and the committed history of prior review/response cycles before this
response was written. The review is substantially accurate: its two critical findings are real,
and most of its numeric and quoted evidence checks out exactly. This document records, finding
by finding, what was accepted and changed in this revision, what is acknowledged but deferred to
the companion code repository, and where we push back on the review's framing.

## Accepted and implemented in this revision

### Finding 1 — MS-GARCH conditional-VaR omission (critical): accepted, with one scope correction

`results/robustness/msgarch_conditional_var.csv` exists with exactly the values the review
quotes, was never referenced in any `.tex` file, and no prior review cycle had flagged it. This
was the most serious issue in the review and it is now fixed:

- The six MS-GARCH conditional-VaR rows (K ∈ {2, 3, 4} × α ∈ {0.01, 0.05}) are added to the main
  VaR table (`tab:cond_var`) as a labelled regime-switching-contender block, with the artifact
  path cited in the caption.
- Results and Conclusion now state that MS-GARCH at K = 4 is a second strict-tail survivor
  (p_DQ = 0.59 at α = 0.01, a larger margin than CHMM-N's p = 0.06), that the K ∈ {2, 3} rows
  reject at the 1% tier, and that separate specification tests do not rank models — no pairwise
  quantile-loss comparison was conducted, so no superiority claim is made in either direction.
- "Only tested row" is re-scoped to "only row of the CHMM / filtered-bootstrap / CAViaR panel."
- Harness comparability is disclosed in the caption: the MS-GARCH rows are back-tested on the
  572-forecast OoS window (no boundary forecast), one forecast fewer than the CHMM rows; same
  Christoffersen/DQ harness otherwise.

Scope correction we stand on: the review's claim that the conclusion sentence was "false as
written" is too strong. The sentence read "the only **tested** row," and MS-GARCH was outside the
tested panel — a scoping already negotiated in the second-pass review cycle (commit 46dc674).
The defect was selective omission of a computed comparator, not a false sentence. We fixed the
omission; we do not accept the "false" characterization.

### Finding 3 — cross-ticker rank inference (major): accepted

Verified: the cross-ticker diagnostic exists only at K = 18, its median n95 = 6 cuts against
low-K slackness at the typical ticker, and the 1/17 uniform comparison is not a test of binding.
Changes: the abstract, Results, Conclusion, and the appendix "Reading" paragraph now (a) restrict
the low-K non-binding statement to the SPY spectrum, (b) state explicitly that the K = 18
diagnostic measures modal concentration and cannot establish that a K = 3 two-mode budget is
slack, (c) surface the median n95 = 6 in the main text, and (d) relabel the 1/17 comparison as a
descriptive reference, not a test. A K ∈ {3, 6} cross-ticker rerun is noted as the direct check
and deferred to the companion repository.

### Finding 5 — non-canonical GARCH baseline (major): accepted

Verified: the appendix's grid-initialised ML re-fit of the identical GARCH(1,1) specification on
the same data/window attains ACF-MAE 0.0309 vs the headline 0.0490, which flips "on par."
Changes: "on par with GARCH at 0.0490" is retired. The main text now states that the re-fits
(GARCH(1,1) 0.0309, GARCH-t 0.0316, MS-GARCH K=3 0.0284) are the representative conditional-
volatility figures, that a well-fit GARCH remains stronger than the CHMM on the volatility-
clustering axis, and that the CHMM's advantage over the GARCH family is on the marginal (KS)
axis. The main table's GARCH row carries a dagger footnote directing to the canonical re-fit.
The Conclusion's scope paragraph adds the same concession. A single canonical multi-start GARCH
fit propagated through every artifact requires a pipeline rerun and is deferred to the companion
repository; until then the manuscript consistently treats the re-fit as representative.

### Finding 6 — return definition (major): accepted in substance

The Methods now state explicitly that G_t is an annualised log **price**-growth rate (dividends
omitted, ex-dividend drops enter as negative growth, "excess" nominal at r_f = 0), that a
total-return sensitivity matters most for high-dividend sector-panel names and is left to future
work, and that annualised location/scale quantities convert to daily units by dividing by 252
(worked example: −4.56 annualised ≈ −1.8% daily). A full rename across ~80 pages and a CRSP
total-return rerun are deferred; the definitional transparency the review asked for is in place.

### Finding 7 — identifiability citation (major): accepted

Verified against the primary sources: the displayed full-rank + linearly-independent-emissions
condition for continuous-emission HMMs is the theorem of Gassiat, Cleynen & Robin (Statistics and
Computing, 2016), not Allman-Matias-Rhodes (2009), whose HMM theorem concerns finitely many
observed values. The proposition now cites Gassiat et al. (new bib entry `gassiat2016inference`),
states known K, stationarity, and identification from the law of three consecutive observations
up to label permutation, and keeps Allman et al. as the Kruskal-based antecedent. The existing
Scope paragraph (linear independence not proven for varying-shape t/GED families) is retained.

### Finding 10 — copula-noise contradiction (moderate): clarified

The two sentences are reconcilable — the paired common-random-numbers interval measures a
different quantity than the unpaired path-noise floor — but the review is right that a reader
will collide them. The half-unit-grid sentence now says the unpaired gap sits inside the
path-to-path noise floor **and** is resolved as a stable +0.0055 paired difference under CRN,
with the compatibility explained. We do not accept that "both cannot be true": the original
statements referenced different variance designs, both correctly hedged in place.

### Finding 11 — artifact paths (moderate): accepted

All paper-facing paths now resolve or are explicitly marked companion-repository:
`results/diagnostics/bh_fdr` → `results/robustness/bh_fdr.csv`;
`results/cross_asset/nonoverlap_basket.txt` → `results/robustness/nonoverlap_basket.csv`;
the missing sixteen-row DQ artifact is de-cited (the vendored `engle_manganelli_dq.csv` covers
the CHMM-N rows; the rest is marked as regenerated by the companion repository);
`seed_uncertainty.txt` is marked not vendored. A machine-readable table→artifact manifest is a
good suggestion and is deferred to the companion repository.

### Finding 12 — missing predictive-VaR equation (moderate): accepted

Methods now display the forecast propagation q_{t+1|t} = α_{t|t} T, the predictive mixture CDF,
and the inf-quantile VaR definition, plus the 573-forecast boundary convention, annualised sign
convention, and breach rule.

### Finding 13 — sector-effect inference (moderate): accepted

Both the Results sentence and the 60-ticker appendix paragraph now describe the ANOVA outcome as
a non-detection rather than a demonstration of absence; "at adequate power" is deleted and the
absence of a power analysis / equivalence margin is stated.

## Acknowledged, deferred to the companion code repository

### Finding 4 — hybrid t/GED stopping rule (major): structural concern confirmed, fix requires reruns

The review's structural reading of Algorithm 1 is correct and was already acknowledged in the
pseudocode's own comment: the convergence check uses the pre-M-step likelihood and the returned
parameters lag it by one M-step, which for the non-monotone t/GED blocks can return a final
update whose likelihood was never evaluated. The recommended fix (evaluate after every complete
update, track and return the best evaluated iterate, backtrack materially decreasing hybrid
updates) changes fitted output and therefore belongs in the companion code repository with a full
rerun; we will not alter the displayed pseudocode ahead of the code, since the pseudocode
documents the implementation as run. One pushback: the review attributes to the text a claim
that "the last finite-likelihood iterate is restored." No such sentence exists anywhere in the
sources; the manuscript claims only non-guaranteed monotonicity (supplementary "Numerical
optimisation scope"). The structural finding stands without that premise.

### Finding 8 — strict-tail DQ finite-sample calibration (major): agreed, deferred

Correct: the Christoffersen power calibration does not calibrate DQ finite-sample size at
T = 573 with ~5.7 expected breaches. The manuscript already frames the 1% tier as power-bounded
and, with the Finding 1 fix, no longer rests any comparative claim on the 0.056-vs-0.017
separation. A parametric-bootstrap DQ null and a quantile-loss comparison are queued for the
companion repository.

### Finding 9 — KS pass-rate as lead metric (moderate-major): partially accepted, deferred

The manuscript already labels KS descriptive, reports the block-bootstrap recalibration
(79.8% → 58.6% at L = 20), and reports the CRPS tie across families in the main text. Making
proper scores the lead axis is a restructuring decision we defer to the editor-facing revision
alongside the narrative restructuring (see below).

### Narrative restructuring (review §"What needs restructuring")

The structural suggestions (abstract compression, ACF figure into main text, Results
subsections, Discussion de-duplication, Conclusion shortening, caption trimming, "continuous-
emission HMM" terminology) are reasonable and deliberately not attempted in this pass, which was
scoped to claim-calibration and evidence fixes. One correction feeds this work: the review's
"Figure S3" does not exist in the manuscript — the compiled paper contains **no**
simulated-vs-empirical ACF comparison figure at all (the K = 3 comparison exists only as uncited
PDFs in `figs/`). That makes the review's underlying point stronger than stated, and moving that
figure into Results is the first item of the restructuring pass.

## Pushbacks

1. **Finding 2 ("reproduces the slow ACF") is overstated as charged.** The ACF-specific claims
   are hedged everywhere they appear ("matched … within our lag-252 MAE tolerance", with an
   explicit footnote that the tolerance is relative-to-floor and not pre-registered), and the
   theory section explicitly disclaims power-law/multi-scale decay. The strong verb "reproduced"
   attaches to the three-Cont-stylized-facts bundle. The GARCH re-anchoring of Finding 5 already
   removes the strongest overreach (parity on ACF-MAE); horizon-banded ACF errors are a good
   suggestion queued with the companion-repository reruns.
2. **Finding 1's "false as written"** — see above; scoping was accurate, omission was the defect.
3. **Finding 4's restoration quote** does not exist in the sources.
4. **Finding 14 (Bulla & Bulla squared vs absolute)**: the review asserts Bulla & Bulla's
   headline concerns squared returns. Bulla & Bulla (2006) work in the Rydén-Teräsvirta-Åsbrink /
   Granger-Ding stylized-fact frame, which is stated for absolute returns; our text cites them
   for the sojourn-time mechanism and does not misattribute a squared-return target. No change
   made; if a referee presses, one sentence distinguishing |r| from r² targets costs nothing.
5. **"Both cannot be true" (Finding 10)** — the two statements referenced different variance
   designs and each was hedged in place; clarified, not retracted.

## Verification of this revision

- `results/robustness/msgarch_conditional_var.csv` values transcribed into `tab:cond_var` were
  re-checked row by row (rounding to table conventions; breach rates recomputed on T = 572).
- All `\path{results/...}` references now resolve against the repository tree or are explicitly
  marked companion-repository.
- The paper recompiles with no unresolved references (see commit).
