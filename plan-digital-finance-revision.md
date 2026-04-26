# Plan: Bring CHMM Manuscript to Digital Finance Submission Standard

Anchored on the convergent verdict from [claude oa journals review outcome.md](claude%20oa%20journals%20review%20outcome.md) and [codex review for each oa journal.md](codex%20review%20for%20each%20oa%20journal.md): both reviewers rank `Digital Finance` as the primary target with a major-revision verdict. The required-revisions lists overlap on every substantive item; this plan consolidates them and assigns each to either the (short) main body or the appendix.

## Editorial discipline (applies to every task below)

1. The main body stays short and direct. Every new headline number lives in main; every supporting panel, derivation, sensitivity sweep, and large table moves to the appendix.
2. No em dashes anywhere in prose (commas, colons, semicolons, parens, periods only).
3. Use existing numeric macros (`\pct`, `\Kdisc`, `\LRuc`, `\LRind`, `\NPaths`, `\TIS`, `\TOoS`) for any new figures cited in prose.
4. Mark any number that depends on a re-run with `\revtodo{...}` until the new artefacts land; remove the macro on the final pass.

## Section-by-section compression and placement targets (current main body)

The existing main-body sections are already small (`introduction.tex` 23 lines, `related_work.tex` 18, `model.tex` 194, `estimation.tex` 48, `theory.tex` 73, `results.tex` 146, `var_backtest.tex` 49, `discussion.tex` 42, `conclusion.tex` 20). The risk is that the revisions below balloon the main body. Defensive moves before adding anything:

- `model.tex`: keep the pipeline schematic and the high-level equations; push the full conditional density block, the rank-reordering construction details, and the metric definitions into the existing `metrics_appendix.tex` and `cross_asset_appendix.tex`.
- `estimation.tex`: reduce to the unified ECM scaffold sketch and a one-sentence pointer for each emission family. Algorithm-by-algorithm pseudocode lives in `algorithms_appendix.tex` (already 308 lines, the right home).
- `theory.tex`: keep the spectral identity statement and one paragraph of intuition; proofs and per-state moment expansions to `supplementary.tex`.
- `results.tex`: keep the headline six-generator table, the headline cross-ticker table, and the headline copula table only. Per-K sweeps, per-family panels, walk-forward refits, OoS correlation gap analysis, and the new benchmark comparators all move to appendices.
- `var_backtest.tex`: the unconditional envelope table stays; the filter-VaR subsection contracts to one paragraph that flags the failure and points to a single appendix subsection.

## Required revisions for Digital Finance

The five items below are the union of the `Digital Finance` revision lists from both reviews. Each one names the deliverable, where it lands (body vs appendix), and the acceptance criterion.

### 1. Strengthen the volatility-clustering benchmark panel

**Why:** Both reviewers flag GARCH(1,1) Gaussian as the only volatility-clustering competitor. A 2026 digital-finance paper needs at least skewed-t GARCH plus GJR/EGARCH, and ideally a regime-switching foil (MS-GARCH or HSMM).

**Deliverable:**
- Add four new fitted generators to the SPY Pipeline-A panel: skewed-t GARCH(1,1), GJR-GARCH(1,1), EGARCH(1,1), and one of MS-GARCH(2,1,1) or a Gaussian HSMM with geometric-tail dwell times.
- Headline panel ([sections/results.tex:22](sections/results.tex)) gains four rows. If the table starts to spill, shrink the body table to `Bootstrap | GARCH(1,1) | best-of-extended-GARCH | best-of-RS-foil | CHMM-{N,t,L}`, and put the full ten-row panel in `baselines_appendix.tex`.
- All four new fits get a one-paragraph methods note in `baselines_appendix.tex` (already exists at 345 lines; the right home).

**Acceptance criterion:** CHMM at moderate $K$ remains best-or-tied on the joint (KS, ACF-MAE) corner against every new benchmark. If MS-GARCH dominates on either axis, recast the spectral-identity narrative as an explanatory frame for the regime-switching family rather than a CHMM-exclusive claim.

### 2. Add a proper scoring rule alongside KS

**Why:** Both reviewers note that KS pass rate is a fidelity score, not a predictive score. Digital Finance reviewers will ask for CRPS at minimum, ideally with a Diebold-Mariano-style pairwise comparison.

**Deliverable:**
- Compute CRPS per simulated path against the held-out OoS series for every generator in the headline panel; report median and `[5%, 95%]` envelope.
- Add a Diebold-Mariano test on the CRPS loss differential between CHMM and each benchmark.
- Headline placement: a single new column on Table 1 (`CRPS_med`) plus one sentence noting the DM verdicts.
- Appendix placement: full CRPS envelope table, the loss-differential time series, and the DM test details to `metrics_appendix.tex`. Add a one-paragraph methods note that justifies CRPS as the scoring rule of record (proper, strictly proper for continuous predictive distributions, monotone in distributional fidelity to the truth).

**Acceptance criterion:** CHMM-N or CHMM-L is best-or-tied on CRPS against GARCH(1,1) and at least one extended-GARCH variant. If CHMM is dominated on CRPS by a benchmark that it beats on KS, frame the result as a metric-tradeoff rather than as superiority.

### 3. Resolve the $K = 18$ vs $K^\star = 3$ tension

**Why:** Reviewers from both sides will land on this first. The current draft acknowledges the conflict but operates at $K = 18$ on visual-fidelity grounds while held-out log-likelihood, BIC, HQC, and CAIC point to $K^\star = 3$ on a clean pre-OoS slice ([sections/supplementary.tex:78](sections/supplementary.tex)).

**Deliverable:**
- Add a parallel headline column at $K = 3$ to Table 1 ([sections/results.tex:22](sections/results.tex)). Every metric (KS IS, KS OoS, kurtosis, ACF-MAE, CRPS) reported at both $K = 3$ and $K = 18$.
- Reframe the operating-point choice in `results.tex` Section "State-Count Selection": $K^\star = 3$ is the likelihood-selected default, $K = 18$ is a tail-fidelity operating point; the spectral identity explains the kurtosis and ACF gain at higher $K$, the held-out-likelihood penalty quantifies the cost.
- Move the full $K \in \{3, 6, 9, 12, 15, 18, 21\}$ sensitivity sweep, currently in `supplementary.tex`, into a dedicated `sensitivity_appendix.tex` subsection (file already exists at 456 lines).
- Update the abstract ([paper.tex:112](paper.tex)) to report headline numbers at both $K = 3$ and $K = 18$.

**Acceptance criterion:** A reviewer reading only the abstract and Table 1 can see both operating points, the cost in held-out log-likelihood at $K = 18$, and the gain in tail and ACF fidelity. The choice is explicit, not implicit.

### 4. Demote the filter-VaR section more aggressively

**Why:** Both reviewers note that the regime-conditional filter-VaR rule fails Kupiec OoS for all three emission families ([sections/var_backtest.tex:43](sections/var_backtest.tex)). In its current form it reads as half-finished operational content, not as a flagged limitation.

**Deliverable:**
- Contract `sections/var_backtest.tex` to its first subsection (the unconditional envelope, which works) plus a single closing paragraph that says: "We considered a filter-based regime-conditional VaR rule using the forward-filter posterior. It fails Kupiec OoS for all three emission families; we flag this as an open operational question and leave candidate remedies to future work." Point to the appendix.
- Move the mixture-quantile inequality, the failure-rate breakdown, and the candidate-remedy discussion to a new subsection in `supplementary.tex` titled "Filter-Based Regime-Conditional VaR: Open Question."
- Remove any framing in the abstract or introduction that suggests filter-VaR as a contribution. Recheck `introduction.tex` and the abstract for stray references.

**Acceptance criterion:** Main-body word count of the VaR section drops by at least 50%. The appendix subsection is self-contained: a finance reviewer who wants to re-attempt the rule can do so from the appendix alone.

### 5. Broaden the empirical base

**Why:** Both reviewers flag that the cross-asset universe is six US single-name / index tickers. The OoS correlation MAE jumps an order of magnitude (0.027 IS to 0.208 OoS in [sections/results.tex:138](sections/results.tex)) and that gap is currently unexplained.

**Deliverable (split):**
- *Body:* one new paragraph in the cross-asset subsection that names the IS-to-OoS correlation degradation, attributes it to the same stationarity-scope mechanism as the NVDA/JPM single-name OoS cliff, and points to the appendix for the per-pair breakdown.
- *Appendix (`cross_asset_appendix.tex`):* per-pair off-diagonal MAE table (IS vs OoS), and at least one non-US asset added to the universe (proposal: a major FX cross such as EUR/USD, or a commodity such as front-month Brent or gold). The non-US asset gets the full Pipeline-A treatment (univariate KS IS/OoS, kurtosis, ACF-MAE) plus inclusion in the Student-t copula construction.
- *Appendix:* a one-paragraph note on the cross-asset OoS degradation: enumerate the candidate causes (stationarity break, copula-degree mis-specification, sample-size noise on the OoS Frobenius norm) and rank them by the evidence in the new per-pair table.

**Acceptance criterion:** A reviewer reading the body alone sees the cross-asset OoS gap acknowledged. A reviewer reading the appendix sees a non-US asset class included, the per-pair degradation localised, and the most plausible cause named.

## Optional but recommended (low cost, high reviewer-goodwill payoff)

These are not strictly required by either review but are cheap to add and address common second-round reviewer asks for this venue.

- *Multi-seed sensitivity panel for ECM convergence (CHMM-t).* Run the headline fit across 20 seeds; report median and `[min, max]` for the headline metrics. Place in `sensitivity_appendix.tex`. One sentence in the body.
- *KS power calibration.* Run 1,000 i.i.d.-resample paths from the IS empirical distribution as a positive control; report the empirical Type-I rate at $\alpha = 0.05$. One paragraph in `metrics_appendix.tex`. One sentence in the body next to the headline KS pass rate.
- *Walk-forward quarterly refit on JPM and NVDA.* The body already claims "$\sim 15$ percentage points of the JPM gap" is recovered ([sections/results.tex:66](sections/results.tex)). Make sure the underlying re-run exists and the number is current; if not, mark the claim with `\revtodo{...}` until verified.

## Submission preflight

Before submission to Digital Finance:
- Confirm Springer hybrid full APC waiver for the corresponding-author affiliation.
- Confirm `CHMM-Model.jl` repository public, tagged at the commit that produced the manuscript figures, and `Manifest.toml` pinned.
- Confirm the seed-policy reproducer (currently documented at [sections/supplementary.tex:6](sections/supplementary.tex)) reproduces every body table and figure end-to-end on a clean machine.
- Run a final pass for em dashes (`grep -n "---" sections/*.tex paper.tex` should return only LaTeX comment dividers).

## Cross-venue contingency

If `Digital Finance` rejects, the second submission depends on the reviewer comments (both reviews agree on the routing):
- Reviewers fault the empirical base or finance benchmarks: escalate to `Computational Economics` after adding MS-GARCH and a downstream economic exercise (simulated portfolio backtest, simulated SR/Sortino confidence intervals against bootstrap, or a simulated stress-test calibration).
- Reviewers fault statistical rigour or methodology depth: redirect to `Statistical Methods & Applications` after adding multi-seed Monte Carlo on parameter recovery and tightening the identifiability statement to address bracketed-$\nu$ Student-t directly.
- Reviewers fault generality or scope: redirect to `Royal Society Open Science` (lowest revision burden, soundness-only review criterion).

Do not target `Annals of Finance`, `Statistics and Computing`, `Journal of Financial Econometrics`, `Econometric Theory`, or `Macroeconomic Dynamics` with this draft.
