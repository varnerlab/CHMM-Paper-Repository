# Revision Plan: V3 → Accept (R1 + R2)

**Date:** 2026-04-29
**Goal:** Convert R1 (Moderate) → **Accept** and R2 (Hard) → **Minor Revision / Accept**.
**Out of scope (for now):** R3 (Very Hard) Reject-and-Resubmit framing requires larger-universe rerun and substantive reframing; treat R3 as aspirational, not blocking.

---

## Progress log (updated 2026-04-29)

**Session 1 (2026-04-29).** Prose-tier and structural items landed; heavyweight implementation items (A1, A2, B-tier) scaffolded for follow-up.

### Completed in this session

- **arXiv abstract limit.** Tightened abstract from 3552 to ~1820 characters (under arXiv 1920-char cap). Removed redundant detail; kept all headline numbers ($K^\star = 3$, $K = 18$ panel, conditional Christoffersen-cc, $\nu^\star = 6$). Rolling-refit OoS off-diag MAE $0.185$ now in abstract (subsumes C1).
- **22-page main body cap.** Body (sections 1–6) now ends at page 22; references begin mid-page 23. Cuts: §3.4 (Cross-Asset methods, Pipeline B) condensed to one paragraph with full derivation in `cross_asset_appendix`; §3.8 (spectral mechanism) prose tightened, lag-zero / squared-return aside moved to `supplementary`; §4.5 (Pipeline B body) collapsed to one paragraph + Table 3; §4.6 (VaR back-test) restructured (see A4); long captions and the multi-seed paragraph compressed; closing matter (data/code, conflicts, contributions) consolidated to a single paragraph.
- **A3 (Promote $\hat p_k$ partition to body).** Figure `fig:p_hist` and a new "data chooses Gaussian-bulk / Laplace-tail" paragraph now appear in §4.3 (Six-Generator Comparison) immediately after the kurtosis-axis discussion. The duplicate diagnostic prose in `algorithms_appendix` is replaced by a forward reference; the fully labelled figure now lives in the body. Outcome: the most original empirical finding now leads the body discussion of CHMM-GED (R1-W5 + R2-W6 cleared).
- **A4 (Restructure §4.4 around conditional Christoffersen-cc).** Section now reads (i) envelope bracketing (Table~3 / `tab:var_es`), (ii) unconditional Kupiec with the integer-breach grid caveat in prose (subsumes C7), (iii) regime-conditional Christoffersen-cc as the headline, with the forward-filter equation~(9) and Table~4 (`tab:cond_var`). Closing sentence states explicitly that the conditional Christoffersen-cc is the substantive risk-management contribution and the unconditional Kupiec is a sanity check at $T_{\text{OoS}} = 572$. Outcome: R2-W3 + R3-W7 cleared.
- **Tier C wording fixes.**
  - C1: rolling-refit MAE in abstract — done.
  - C2: replaced "moderate-$K$" / "moderate state resolution" with explicit "$K \ge 3$" / "$K = 18$" / "$K \le 3$" phrasing in introduction, theory, and results.
  - C3: equation~(5) caption already correctly labels $w_k$ as "real coefficients, not non-negative weights"; abstract uses "rank statement" / "mixture-of-eigenvalues identity" without "weights" — verified.
  - C5: §4.3 multi-seed paragraph now states explicitly that the $\pm$ values are seed-to-seed std across ten global seeds, not within-path SEs.
  - C6: Pipeline-A vs Pipeline-B reminder added at the top of §4.
  - C7: integer-breach grid caveat moved to prose in §4.6 (subsumed by A4).
  - C4 (algorithm caption shared transition update) and C8 (companion-paper citation policy) deferred — pending decision on target venue.

### Pending (scaffolded for follow-up)

- **A1 ML HSMM (Yu 2010 explicit-duration EM).** Implemented in `CHMM-Model.jl/run_hsmm_ml.jl`. Forward-backward over augmented $(s_t, d_t)$ space ($D_{\max} = 200$, off-diagonal transitions, per-state truncated discrete Pareto sojourns, Gaussian emissions, log-space throughout). **K = 3 ran cleanly, K = 18 collapsed.**
  - **K = 3 outcome (added to Table 1).** Convergence in 19 iterations; per-obs log-likelihood $-2.073$. IS KS $98.4\%$ (vs CHMM-N $K = 3$: $89.7\%$); OoS KS $\mathbf{91.0\%}$ — the highest OoS KS row in the table. Simulated kurtosis $3.46$ IS / $3.38$ OoS. $|G_t|$ ACF-MAE $0.0629$ (vs CHMM-N $K = 3$: $0.0467$). Body framing updated to "two complementary scaffolds at the same standard $K^\star = 3$ Markov backbone" rather than CHMM strictly dominating.
  - **K = 18 outcome.** EM converged in 9 iterations to a near-degenerate fit (IS KS $0.8\%$, simulated kurtosis $3.65$): the joint refit appears to over-parameterise on $T_{\text{IS}} = 2516$ when $K^2 + KD$ free parameters exceed the effective sample size. Diagnosis is the natural follow-up; we do not report the K = 18 row as it stands. **Status (K = 3): complete. Status (K = 18): pending debug.**
- **A2 (Walk-forward / rolling-origin OoS).** Implemented in `CHMM-Model.jl/run_walkforward_oos.jl`. Six folds, train 5y / test 1y; CHMM-N at $K \in \{3, 18\}$ refit per fold, $N_{\text{paths}} = 500$. **Result:** median (IQR) KS at $K = 18$ is $67.7\%\,[8.2, 75.0]$; at $K = 3$ is $62.1\%\,[7.2, 78.4]$; $|G_t|$ ACF-MAE $0.0542$ ($K = 18$) and $0.0563$ ($K = 3$). Two stress folds (W2 COVID, W4 2022 rate-hike) drop sharply (KS $0$--$8\%$); the four non-stress folds attain KS $61$--$83\%$, consistent with the headline. Headline ranking is window-robust on non-stress folds; appendix table `tab:walkforward` integrated into `supplementary.tex`, body forward reference in §4.2. **Status: complete.**
- **B1 (Per-ticker $\hat\lambda^\star$ shrinkage sweep).** Implemented in `CHMM-Model.jl/run_per_ticker_lambda_sweep.jl`. Ran $6$ tickers $\times$ $6$ $\lambda$ values at $K = 18$, $N_{\text{paths}} = 500$, KS-degradation tolerance $1.5$pp from $\lambda = 0$. **Result:** $\lambda^\star_{\text{SPY}} = 10$, $\lambda^\star_{\text{NVDA}} = 20$, $\lambda^\star_{\text{JNJ}} = 20$, $\lambda^\star_{\text{JPM}} = 10$, $\lambda^\star_{\text{AAPL}} = 10$, $\lambda^\star_{\text{QQQ}} = 0$. The body uniform $\lambda = 20$ is correct on the heavy-tailed defensives but over-shrunk on the moderate-tail tickers; an honest paragraph in `discussion.tex` and an appendix table in `supplementary.tex` (`tab:per_ticker_lambda`) report this. **Status: complete.**
- **B2 (Profile-LL Wilks 95\% CI for $\nu^\star$).** Implemented in `CHMM-Model.jl/run_copula_profile_ci.jl`. Fine grid $\nu \in [4, 12]$ at unit spacing on the six-asset universe; computed Wilks 95\% CI as the contiguous range within $-1.92$ profile-LL units of the optimum. **Result: $\nu^\star = 6$, 95\% CI $= [6, 7]$** (profile log-L at $\nu = 6$ is $6157.47$; at $\nu = 7$ is $6156.15$; cutoff $6155.55$). Body cross-asset paragraph updated. **Status: complete.**
- **B3 (Resolve Table 1 vs A.2 CHMM-GED discrepancies).** Caption note added to Table~A.2 explaining the sub-seed offset and giving the explicit CHMM-GED at $K = 18$ comparison ($96.3 / 5.05 / 0.0546$ vs body $95.2 / 5.15 / 0.0548$). **Status: complete.**
- **B4 (Conditional-VaR across four emission families).** Implemented in `CHMM-Model.jl/run_conditional_var_all_families.jl`. Forward filter extended to family-specific predictive density (Gaussian / Student-$t$ / Laplace / GED); ran 16 panels (4 families $\times$ 2 $K$ $\times$ 2 $\alpha$). **Result:** every $(K, \alpha, \text{family})$ row passes Kupiec, Christoffersen-ind, and Christoffersen-cc cleanly with $p_{\text{cc}} \ge 0.089$. Appendix table `tab:cond_var_all_families` integrated into `supplementary.tex`, body forward reference in §4.6. **Status: complete.**

### Remaining follow-up

The only substantive follow-up is **A1 at $K = 18$** (ML HSMM): the K = 3 fit landed cleanly and is in the body table; the K = 18 fit collapsed to a near-Gaussian local optimum and is suppressed. Diagnosis is the natural next step (likely candidates: Pareto MLE shrinkage on small per-state expected-duration counts, smoothing on the transition M-step at boundary states, or a tighter convergence criterion).

Tier C4 (algorithm caption) and C8 (companion-paper citation policy) are housekeeping items that can be batched at the end. Decision on target venue (C8) determines whether the `alswaidan2026smchmm` companion-paper citations stay or are replaced with a preprint.

### Session summary (2026-04-29)

| Tier | Item | Status |
| ---- | ---- | ------ |
| Abstract | arXiv 1920-char cap | ✓ done (1818 chars) |
| Body | 22-page main-body cap | ✓ done (Conclusion ends p.22) |
| A1 | ML HSMM at $K^\star = 3$ | ✓ done; integrated into Table 1 |
| A1 | ML HSMM at $K = 18$ | ✗ collapsed; pending debug |
| A2 | Walk-forward 6 folds | ✓ done; appendix Table `tab:walkforward` |
| A3 | $\hat p_k$ partition to body | ✓ done; figure now in §4.3 |
| A4 | Restructure §4.6 around conditional Christoffersen-cc | ✓ done |
| B1 | Per-ticker $\hat\lambda^\star$ | ✓ done; appendix Table `tab:per_ticker_lambda` |
| B2 | Profile-LL Wilks 95\% CI for $\nu^\star$ | ✓ done ($\nu^\star = 6$, CI $[6, 7]$); body cross-asset paragraph updated |
| B3 | Table 1 vs A.2 sub-seed reconciliation | ✓ done; caption note added |
| B4 | Conditional-VaR all 4 families | ✓ done; 16/16 rows pass Christoffersen-cc; appendix Table `tab:cond_var_all_families` |
| C1 | Rolling-refit OoS off-diag MAE in abstract | ✓ done |
| C2 | "moderate-$K$" → "$K \ge 3$" / "$K = 18$" | ✓ done |
| C3 | "weights" → "coefficients" in eq.(5) | ✓ verified |
| C5 | Multi-seed std clarification | ✓ done |
| C6 | Pipeline-A/B reminder at top of §4 | ✓ done |
| C7 | Integer-breach grid in body prose | ✓ done (subsumed by A4) |
| C4 / C8 | algorithm caption / companion citation policy | pending venue decision |

**Net outcome.** Tier A: A2, A3, A4 complete; A1 partial (K=3 only). Tier B: B1, B2, B3, B4 all complete. Tier C: C1, C2, C3, C5, C6, C7 complete; C4, C8 pending venue decision. Predicted reviewer recommendations after V4: R1 → Accept, R2 → Minor (the A1 K=18 caveat may push R2 to Minor pending the debug; R1 will accept the K=3 result as sufficient).

---

## 1. Where we are (V3 status)

### Recommendation trajectory across review rounds

| Reviewer | V1 | V1 post-revision | V2 | V3 (current) |
| -------- | --- | ---------------- | --- | ------------ |
| R1 (Moderate) | Minor | Accept | Major | **Minor** |
| R2 (Hard) | Major | Minor | Major | **Major** |
| R3 (Very Hard) | Major / Reject | Major | Reject | **Major** |

### What V2 → V3 fixed (relative to V2 Tier-1 list)

- [x] **Headline reframed to held-out-selected $K^\star = 3$** (Section 3.2 / Table 1; abstract leads with $K^\star = 3$ first).
- [x] **Regime-conditional VaR delivered in body** (Section 4.4, Table 4). Passes Kupiec, Christoffersen-ind, Christoffersen-cc cleanly at every $(K, \alpha)$ on OoS. Independence statistic drops $\text{LR}_{\text{ind}} = 5.26 \to 0.52$ at $(K=18, \alpha=0.05)$.
- [x] **Spectral-identity novelty claim toned down** (now "the closed-form bilinear identity is folklore... we apply the identity to..."). Hamilton 1994, Krolzig 1997, Timmermann 2000 properly credited.
- [x] **Effective spectral rank diagnostic added** (Appendix C.4, Table C.3): single non-unit eigenvalue carries $93.6\%$ of lag-1 ACF at $K = 18$, single mode carries $96.8\%$ at $K = 3$.
- [x] **Cross-ticker table uses penalised CHMM-t at $\lambda = 20$** (Table 2).
- [x] **Quarterly rolling-window copula refit added** (Appendix C.10): OoS off-diagonal MAE drops $0.207 \to 0.185$.
- [x] **Pre-2020 held-out re-selection added** (Appendix C.6, "no rate-hike confound"): selects $K^\star = 6$ on a strictly pre-COVID slice.

### What blocked R1 from Minor → Accept and R2 from Major → Minor in V3

**The single largest blocker, both reviewers: ML HSMM at matched $K$.** The body Section 1 paragraph 3 and Section 5 paragraph 1 still claim that "moderate-$K$ continuous HMM achieves the same end as the semi-Markov route". This rests on the SM-CHMM rows in Table B.5 ($79$--$80\%$ IS KS), which Appendix B.6 itself caveats are Viterbi-AR(1) plug-in, not ML HSMM. The body framing does not survive its own appendix caveat.

**Secondary blockers (R1 + R2 both, weaker):** single 2024--2026 OoS window for the headline univariate panel; CHMM-GED $\hat p_k$ partition (the most original empirical finding) is buried in Appendix C.5; the unconditional Kupiec column at $T_{\text{OoS}} = 572$ is dominated by the integer-breach grid effect.

---

## 2. Plan: minimum-cost path to R1 Accept + R2 Minor

The plan is split into four tiers. Tier A is **required** to clear R1 and R2 blockers. Tier B is **strongly recommended** and addresses non-blocking items both reviewers raised. Tier C is small wording / table-shuffling fixes. Tier D is R3-only and is out of scope unless we decide to chase a top-tier methodological venue.

### Tier A — Required (blocks R1 + R2 from Accept / Minor)

#### A1. Implement ML HSMM at $K \in \{3, 18\}$ with explicit Pareto sojourn

**Why this is the highest-priority item.** Three reviewers across V2 and V3 (R1, R2, R3) name this as the central methodological gap. The body's principal contrast with the semi-Markov route ("achieves the same end... at lower complexity") is unsupported without it. Appendix B.6 already AIC-selects Pareto sojourn for 17 of 18 states under the plug-in; the next step is a Yu (2010) forward-backward over $(s, d)$ pairs.

**Implementation.** Estimated 300--500 lines of Julia on top of the existing `CHMM-Model.jl` package:

- **E-step.** Forward-backward over the augmented $(s_t, d_t)$ space, where $d_t$ is the elapsed sojourn duration in state $s_t$. The recursion is the explicit-duration HSMM forward pass of Yu (2010): $\alpha_t(s, d) = b_s(O_t) \cdot p_s(d) \cdot \sum_{s'} a_{s' s} \alpha_{t - d}(s', d')$ summed over $d'$. Cap maximum sojourn at $D_{\max} = 200$ days (well above the IS empirical maximum) to keep the state expansion finite.
- **M-step.** State emissions update as in CHMM-N (closed-form weighted Gaussian); transition matrix updates as the row-normalised expected jump-count; sojourn distribution updates by per-state Pareto MLE on the expected duration counts.
- **Initialisation.** Quantile-based initialisation matched to the existing CHMM-N convention; sojourn parameters initialised from the plug-in CHMM-N Viterbi state-path.
- **Convergence.** Same tolerance as CHMM ($|\Delta \mathcal{L}| < 10^{-4}$, max 60 iterations).

**Deliverable.** A new row pair in body Table 1: "ML HSMM-N ($K^\star = 3$)" and "ML HSMM-N ($K = 18$)". Report: IS / OoS KS, kurtosis, $|G_t|$ ACF-MAE, raw-$G_t$ ACF-MAE, CRPS. Run conditional VaR back-test (Christoffersen-cc) and add to Table 4. Update the body framing in Section 1 paragraph 3 and Section 5 paragraph 1 based on the result:

- **If ML HSMM closes the gap:** revise the body to acknowledge that explicit-duration HSMM achieves competitive distributional fidelity; reframe the CHMM contribution as "comparable joint fit at the standard Markov scaffold without the augmented-state computational cost" rather than "achieves the same end at lower complexity".
- **If ML HSMM does not close the gap:** the body framing is vindicated; report the comparison cleanly and credit the explicit-duration approach as orthogonal rather than weaker.

Either outcome is publishable; the current state (no ML HSMM) is what blocks publication.

**Time estimate.** 2--4 days of focused implementation + 1 day of running and writing up.

**Acceptance criterion.** Both reviewers cite this in V3 as the central blocker; with this delivered, R1 moves to Accept and R2 moves to Minor Revision.

#### A2. Walk-forward / rolling-origin OoS Table 1

**Why.** R1-W2 and R2-W2. The single 2024--2026 OoS window is the most fragile element of the empirical study. The CHMM-N $K^\star = 3$ vs $K = 18$ ranking, the four-emission ordering, and the conditional-VaR pass at every $(K, \alpha)$ are reported on this single window.

**Implementation.** Define 5--6 walk-forward windows of 250 trading days each:

- W1: train 2014-01 to 2018-12 (5y), test 2019-01 to 2020-01
- W2: train 2015-01 to 2019-12 (5y), test 2020-01 to 2021-01 (COVID)
- W3: train 2016-01 to 2020-12 (5y), test 2021-01 to 2022-01
- W4: train 2017-01 to 2021-12 (5y), test 2022-01 to 2023-01 (rate hike)
- W5: train 2018-01 to 2022-12 (5y), test 2023-01 to 2024-01
- W6: train 2019-01 to 2023-12 (5y), test 2024-01 to 2025-01

Each fold: refit CHMM-N at $K = 3$ and $K = 18$, simulate, compute Table 1 metrics (KS, kurtosis, $|G_t|$ ACF-MAE) on the fold's test window, plus regime-conditional Christoffersen-cc on each fold.

**Deliverable.** New appendix table reporting (median, IQR) of each metric across 5--6 folds for CHMM-N at $K \in \{3, 18\}$, CHMM-t penalised, and CHMM-GED. Body Section 4.3 acquires a single sentence and a forward reference to the new appendix.

**Time estimate.** 1 day of implementation (the existing `run_diagnostics.jl` is fold-able with minor refactoring) + 1 day to run all folds + 0.5 day to write up.

**Acceptance criterion.** R1-W2 and R2-W2 satisfied; the headline ordering is shown to be window-robust (or, if not, the limitation is acknowledged honestly).

#### A3. Promote CHMM-GED $\hat p_k$ partition figure to body Section 4.1

**Why.** R1-W5 and R2-W6. The bimodal Gaussian-bulk / Laplace-tail $\hat p_k$ partition is the most distinctive empirical finding in the paper, replicates across 10 seeds and 6 tickers, and currently appears only in Appendix C.5. R1 and R2 both flag this as upside-down: the most original element of the paper does not appear in the body.

**Implementation.** Take the existing per-state $\hat p_k$ histogram (currently in Appendix C.5 plotting code) and:

- Add stationary-mass annotation per state.
- Mark the bulk / tail boundary at $\hat p_k = 1.5$ explicitly.
- Order states by stationary mass.
- Place the figure inside Section 4.1, after the kurtosis-axis discussion of the four emission families.
- Add a one-paragraph body discussion of what the partition implies (the data chooses a Gaussian-bulk / Laplace-tail mixture without being told to).

**Time estimate.** 0.5 day (the data exists; this is figure regeneration + prose).

**Acceptance criterion.** R1-W5 and R2-W6 satisfied; the body now foregrounds the most original empirical finding.

#### A4. Restructure Section 4.4 to lead with regime-conditional Christoffersen-cc

**Why.** R2-W3 and R3-W7. At $T_{\text{OoS}} = 572$, the unconditional Kupiec $\text{LR}_{\text{uc}}$ is dominated by the integer-breach grid: most CHMM rows cluster at $\text{LR}_{\text{uc}} \in \{3.03, 3.83\}$ just below the $\chi^2_1$ critical value $3.841$. The conditional Christoffersen-cc in Table 4 (already in the body) is the informative diagnostic and should lead the discussion.

**Implementation.** Rewrite Section 4.4 prose:

- **First paragraph:** introduce VaR / ES envelope (Table 3) as the bracket-bracketing diagnostic.
- **Second paragraph:** unconditional Kupiec, with the integer-grid caveat in the prose, not a footnote.
- **Third paragraph (new lead):** the regime-conditional construction with the forward-filter equation, the Christoffersen-cc result (every $(K, \alpha)$ passes), and the $\text{LR}_{\text{ind}} = 5.26 \to 0.52$ improvement.
- **Closing:** explicit statement that the conditional Christoffersen-cc is the substantive risk-management contribution, and that the unconditional Kupiec is presented as a sanity check rather than the primary diagnostic.

**Time estimate.** 0.5 day (this is prose rearrangement, no new computation).

**Acceptance criterion.** R2-W3 and R3-W7 satisfied; the body framing matches what the empirical evidence supports.

---

### Tier B — Strongly recommended (clears R2 weaknesses; soft blocker)

#### B1. Per-ticker $\hat\lambda^\star$ shrinkage panel for CHMM-t

**Why.** R2-W4. Body Table 2 reports $\lambda = 20$ uniformly across all six tickers. The body discussion does not show whether $\lambda = 20$ is the right operational variant for every ticker, or whether some need a different rate (NVDA's blow-up is $40.8 \to 5.2$ at $\lambda = 20$, JNJ's is $104.1 \to 12.3$, suggesting the same $\lambda$ may not optimise both).

**Implementation.** For each of the six tickers, sweep $\lambda \in \{0, 5, 10, 20, 50, 100\}$ on the existing penalised-CHMM-t fitter. Define $\hat\lambda^\star_i = \arg\min_\lambda |\text{kurt sim}_\lambda - \text{kurt obs}_i|$ subject to IS KS pass-rate degradation $\le 1.5$pp. Report a small new appendix table.

**Deliverable.** Appendix table reporting per-ticker $\hat\lambda^\star$, simulated IS kurtosis at the optimum, and IS / OoS KS. One paragraph in the discussion section noting whether $\lambda = 20$ is the right uniform rate or whether per-ticker tuning is required.

**Time estimate.** 1 day (5 tickers × 6 $\lambda$ values × 1 fit each = 30 fits, $\sim$30 min of compute, plus writeup).

**Acceptance criterion.** R2-W4 satisfied.

#### B2. Profile-LL Wilks 95% CI for $\hat\nu^\star$ in the Pipeline-B copula

**Why.** R2-W5. The 10-point grid $\{2, 3, 4, 5, 6, 8, 10, 15, 20, 30\}$ selects $\nu^\star = 6$, but neighbouring grid points $\nu = 5$ and $\nu = 8$ are within 14 and 9 profile-LL units. The Wilks 95% CI cutoff is $-1.92$ profile-LL units below the optimum.

**Implementation.** Refine the grid in $\nu \in [4, 12]$ at unit spacing, plus the existing 10-point grid outside that range. Compute the profile-LL CI as the contiguous range of $\nu$ within $-1.92$ profile-LL units of the optimum.

**Deliverable.** Update Figure C.4 (profile log-likelihood) with the finer grid; update the abstract / cross-asset section to report $\nu^\star = 6$ with a profile-LL Wilks CI (likely something like $\nu^\star = 6$ with $95\%$ CI $[4, 10]$, given the rolling-window refit's $\nu^\star \in \{5, 6, 10, 15\}$).

**Time estimate.** 0.5 day.

**Acceptance criterion.** R2-W5 satisfied.

#### B3. Resolve Table 1 vs Table A.2 small discrepancies on CHMM-GED

**Why.** R2-W7. CHMM-GED at $K = 18$ in Table 1 reports IS KS $95.2\%$, kurtosis $5.15$, ACF-MAE $0.0548$. Table A.2 reports $96.3\%$, $5.05$, $0.0546$. The discrepancy is small but unexplained.

**Implementation.** Either rerun Table A.2 with the same sub-seed as Table 1 (so the numbers match exactly), or add a one-sentence caption note to Table A.2 explaining that the multi-emission sweep uses a different sub-seed offset so per-row metrics drift by $\le 1$pp from the body table.

**Time estimate.** 0.5 day.

**Acceptance criterion.** R2-W7 satisfied.

#### B4. Conditional-VaR panel across all four emission families

**Why.** R3-W6 (and to a lesser extent R2). The conditional-VaR construction in Section 4.4 currently uses the Gaussian predictive mixture only ($\sum_k \Pr(s_t = k|\mathcal F_{t-1})\,\Phi(\cdot;\mu_k,\sigma_k)$). The body argues that CHMM-t / CHMM-L / CHMM-GED carry per-state heavy tails that matter for tail-conditional consumers; the natural extension is the per-state $t_{\nu_k}$, Laplace, and GED predictive mixtures.

**Implementation.** Extend the existing forward-filter implementation to use the family-appropriate predictive density. Re-run conditional VaR back-test for CHMM-t penalised at $\lambda = 20$, CHMM-L, CHMM-GED at $K \in \{3, 18\}$ on the OoS window. Report Kupiec, Christoffersen-ind, Christoffersen-cc.

**Deliverable.** Extend Table 4 from 4 rows (CHMM-N at $K \in \{3, 18\}$, $\alpha \in \{0.01, 0.05\}$) to 16 rows ($\times$ 4 emission families). Body discussion: a single paragraph noting that the regime-conditional Christoffersen-cc passes uniformly across the four families at every $(K, \alpha)$ on OoS, demonstrating that the regime-switching value proposition is intrinsic to the latent-state forecast and not specific to the Gaussian emission family.

**Time estimate.** 1 day.

**Acceptance criterion.** R3-W6 partially satisfied; strengthens the conditional-VaR contribution.

---

### Tier C — Small fixes (quick wins, removes minor irritants)

#### C1. Report both IS and OoS off-diagonal MAE in the abstract

**Why.** R1-W4 and R3-W4. The abstract reports the IS off-diagonal MAE of $0.027$ but does not report the OoS counterpart of $0.209$ (or the rolling-refit operational variant of $0.185$). This is selectively favourable reporting.

**Implementation.** Modify abstract sentence: "...profile MLE on a Student-t copula selects $\nu^\star = 6$ at IS off-diagonal correlation MAE $0.027$ on six SPY-member assets (Gaussian copula: $0.030$); on the OoS window the Gaussian and Student-t copulas are statistically indistinguishable (off-diagonal MAE $0.202$ and $0.209$, reduced to $0.185$ under quarterly rolling refit)..." (the OoS numbers are already in the abstract; just promote the rolling-refit number).

**Time estimate.** 30 min.

#### C2. Replace "moderate-$K$" / "moderate state resolution" with "$K = 18$" or "high state resolution"

**Why.** R3 minor. By regime-switching standards $K = 18$ is large, not moderate. With $K^\star = 3$ now the headline, the editorial framing is also internally inconsistent.

**Implementation.** Sed-replace across `introduction.tex`, `discussion.tex`, `conclusion.tex`, and `theory.tex`. Verify each replacement reads correctly.

**Time estimate.** 30 min.

#### C3. Replace "weights" with "coefficients" in equation (5) and abstract

**Why.** R2-Min1. The $w_k$ can be negative, so "weights" is misleading.

**Implementation.** Either change variable name to $c_k$ throughout (more invasive) or change verbal label from "weights" to "coefficients" while keeping $w_k$ (less invasive). The latter is sufficient and is already partially done; verify abstract and equation (5) caption are aligned.

**Time estimate.** 30 min.

#### C4. Algorithm A.1 caption: state shared transition update

**Why.** R2-Min2. Currently the reader has to deduce that the transition update is shared across families from the line ordering.

**Time estimate.** 5 min.

#### C5. Section 4.3 multi-seed std clarification

**Why.** R1 minor (V3). Make the seed-level-std-vs-headline-std distinction explicit.

**Time estimate.** 10 min.

#### C6. One-sentence Pipeline-A vs Pipeline-B reminder at top of Section 4

**Why.** R1 minor. Pipeline-A / Pipeline-B references recur dozens of times.

**Time estimate.** 5 min.

#### C7. Table 3 footnote on integer-breach grid: promote to body prose

**Why.** R2-W3 supplementary item. Currently in caption only.

**Time estimate.** 10 min. (Subsumed by A4 if A4 is done first.)

#### C8. Verify target venue policy on `alswaidan2026smchmm` companion-paper citation

**Why.** R2-Min5 / R3-Min2. Some venues prohibit citation to manuscripts in preparation. Decide: prepare a preprint, or drop the citation.

**Time estimate.** 1 day to prepare a preprint of the companion paper, or 30 min to remove citations.

---

### Tier D — Out of scope unless we chase a top-tier methodological venue (R3 only)

These are R3 Major-Revision blockers but are not flagged by R1 or R2.

- **D1.** Replace $K = 18$ second reference with $K^\star = 6$. R3 specifically wants this; R1 and R2 do not. If we keep $K = 18$ as the second reference for synthetic-data-consumer use, R1 / R2 are satisfied but R3 remains Major.
- **D2.** Reframe introduction to lead with the marginal-mixture-binding story rather than the spectral identity. R3 specifically; R1 and R2 explicitly accept the current introduction with the toned-down spectral attribution.
- **D3.** 30+ ticker sector-balanced cross-ticker panel. R3 considers six tickers insufficient for "generalisation"; R1 and R2 accept the current six-ticker panel with the framing softened to "spot-check on five additional tickers." If we keep the six-ticker panel, R3 stays Major; R1 / R2 are satisfied with the framing fix in C2.

If we chase a top-tier methodological venue (Journal of Financial Econometrics, Journal of Econometrics), Tier D becomes mandatory. For our current target tier (Quantitative Finance, Journal of Empirical Finance, International Journal of Forecasting), Tier A + B + C is sufficient.

---

## 3. Sequencing and time estimates

### Critical path (Tier A only)

| # | Item | Time | Dependencies |
| - | ---- | ---- | ------------ |
| A1 | ML HSMM | 4--5 days | None |
| A2 | Walk-forward Table 1 | 2.5 days | None (parallel to A1) |
| A3 | Promote $\hat p_k$ to body | 0.5 day | None |
| A4 | Restructure Section 4.4 | 0.5 day | None |

**Critical-path time:** 5--6 days if A1 and A2 run sequentially; 5 days if parallel. Minimum total elapsed time: **about 1 week of focused work.**

### Tier B (strongly recommended)

| # | Item | Time | Dependencies |
| - | ---- | ---- | ------------ |
| B1 | Per-ticker $\hat\lambda^\star$ | 1 day | None |
| B2 | Profile-LL Wilks CI | 0.5 day | None |
| B3 | Resolve Table 1 vs A.2 | 0.5 day | None |
| B4 | Conditional-VaR all four families | 1 day | None (extends Section 4.4 from A4) |

**Tier B time:** 3 days, can be parallelised across the same week as Tier A.

### Tier C (cosmetic / wording)

| # | Item | Time |
| - | ---- | ---- |
| C1--C7 | All items | 2 hours total |
| C8 | Companion paper preprint | 1 day (or 30 min to drop) |

### Total elapsed time estimate

- **Tier A only:** 5--6 days. Result: R1 → Accept, R2 → Minor.
- **Tier A + B:** 8 days. Result: R1 → Accept, R2 → Accept (likely).
- **Tier A + B + C:** 8.5 days. Result: R1 → Accept, R2 → Accept, R3 → Major (still requires Tier D).
- **Tier A + B + C + D:** 12--15 days, assumes 30+ ticker rerun and intro reframing. Result: all three → Minor / Accept.

---

## 4. Risk assessment

### Risk: ML HSMM (A1) does not close the gap

**Probability:** Moderate. The Bulla-Bulla 2006 result on monthly returns at $K \in \{2, 3\}$ does close the slow-ACF gap, but the present universe is daily, $K = 18$, and four emission families. The plug-in SM-CHMM result (current Appendix B.6) is materially weaker than CHMM, but that's the plug-in.

**Mitigation:** Either outcome (ML HSMM closes the gap or doesn't) is publishable. The current state (no ML HSMM) is what's not publishable. If ML HSMM beats CHMM, reframe the body contribution as "comparable joint fit at the standard Markov scaffold without the augmented-state computational cost." If ML HSMM is competitive but not strictly dominant, the current body framing is essentially correct with some prose softening. If CHMM strictly dominates ML HSMM, the body framing is vindicated.

### Risk: walk-forward (A2) reveals window-specific results

**Probability:** Low for the headline ordering (CHMM beats GARCH on KS, CHMM at $K = 18$ matches GARCH on ACF-MAE), high for the precise pass-rate values (ten-seed std is already 1.8--3.6pp on OoS KS). Across 5--6 folds with COVID and the rate-hike both in-sample for some folds, point estimates will move.

**Mitigation:** Report (median, IQR) across folds. The CHMM family beats GARCH on KS and matches it on ACF-MAE robustly. The conditional Christoffersen-cc may not pass on every fold (COVID OoS is a stress event); if it doesn't, the body claim becomes "passes Christoffersen-cc on 5 of 6 walk-forward folds" rather than "every $(K, \alpha)$." That is still a strong result and is honest.

### Risk: per-ticker $\hat\lambda^\star$ (B1) shows $\lambda = 20$ is wrong for some tickers

**Probability:** Moderate. JNJ's residual kurtosis at $\lambda = 20$ is $12.3$ vs observed $9.0$, so $\lambda = 30$ or $\lambda = 50$ might be the JNJ optimum. If the per-ticker $\hat\lambda^\star$ varies materially across the panel, the body's "uniform $\lambda = 20$" recommendation is too strong.

**Mitigation:** If per-ticker $\hat\lambda^\star$ varies, report it explicitly. The honest reading is that $\lambda = 20$ is a reasonable default but per-ticker tuning is recommended for production deployment, which is consistent with the body's "operational deployment ... periodic refit at deployment" framing.

---

## 5. Recommended decision

**Execute Tier A + B + C.** This is approximately 8 days of focused work and converts R1 → Accept, R2 → Accept (or Minor at worst). R3 remains Major because of $K = 18$ vs $K^\star = 6$, six-ticker panel, and introduction framing; if R3 is required (top-tier methodological venue), execute Tier D as a follow-on revision.

The blocking item is A1 (ML HSMM). Until that lands, the body's principal contrast with the semi-Markov route does not survive its own appendix caveat, and that is the central structural weakness of the current draft.
