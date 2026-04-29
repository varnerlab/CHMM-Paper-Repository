# Revision Plan: V5 → Accept (R1 + R2 + R3)

**Date:** 2026-04-29
**Source review:** `peer-review.md` (current V5 simulated review).
**Goal:** Convert R1 (Moderate) → **Accept**, R2 (Hard) → **Accept**, R3 (Very Hard) → **Minor Revision / Accept**.

---

## Recommendation trajectory

| Reviewer        | V1             | V2     | V3     | V4              | V5 (current) | V5 → Accept target |
| --------------- | -------------- | ------ | ------ | --------------- | ------------ | ------------------ |
| R1 (Moderate)   | Minor          | Major  | Minor  | Minor (close A) | Minor        | **Accept**         |
| R2 (Hard)       | Major          | Major  | Major  | Minor           | Minor        | **Accept**         |
| R3 (Very Hard)  | Major / Reject | Reject | Major  | Major           | Major        | **Minor / Accept** |

V5 review reads as smaller deltas to V4: most V4 Tier-1 items were delivered (introduction reframing, ML HSMM K=18 collapse sentence, walk-forward median in body, ML HSMM K=3 trade-off framing). What remains is one hard bug, three V3/V4 carryovers, and a cluster of evidence-completing items.

---

## What V5 already delivers (acknowledged in the review)

- **Introduction paragraph 3 reframed around the binding axis.** Leads with temporal-vs-distributional axes; spectral identity in supporting role.
- **ML HSMM at $K = 18$ collapse sentence in §4.3.** "The same Yu (2010) construction at $K = 18$ collapses to a near-degenerate local optimum on $T_{\text{IS}} = 2{,}516$..."
- **Walk-forward median IQR in body §4.3 prose.** Single-window OoS sits at the upper end of the window distribution.
- **ML HSMM K=3 trade-off framing softened.** "Two complementary scaffolds at the same Markov backbone, with different trade-offs across the three Cont stylized facts."
- **Pre-2020 held-out $K^\star = 6$ paragraph in Appendix C.6.** Both held-out criteria on the strictly pre-COVID slice select $K = 6$.

---

## Outstanding from V5 (sorted by priority)

### Tier 0 — Hard Bugs (blocker for submission)

#### T0-1. Body Table 4 (`tab:cond_var`) `[runner]` placeholders

**Source:** R1-W1, R2-W1, R3-W1 (unanimous).
**Issue:** Body Table 4 ships with literal `\emph{[runner]}` placeholders in the four CHMM-t penalised $p_{\text{cc}}$ cells, with caption note "$p_{\text{cc}}$ values for the CHMM-t rows below should be filled in from the runner output."
**Fix:** Compute $p = 1 - F_{\chi^2_2}(\text{LR}_{\text{cc}})$ for the four cells; values map directly from Appendix Table `tab:cond_var_all_families`:
- $K = 3, \alpha = 0.01$: $\text{LR}_{\text{cc}} = 3.63 \Rightarrow p_{\text{cc}} \approx 0.163$.
- $K = 3, \alpha = 0.05$: $\text{LR}_{\text{cc}} = 1.19 \Rightarrow p_{\text{cc}} \approx 0.552$.
- $K = 18, \alpha = 0.01$: $\text{LR}_{\text{cc}} = 4.62 \Rightarrow p_{\text{cc}} \approx 0.099$.
- $K = 18, \alpha = 0.05$: $\text{LR}_{\text{cc}} = 1.40 \Rightarrow p_{\text{cc}} \approx 0.497$.

**Action:** Edit `sections/var_backtest.tex` Table 4: replace the four `[runner]` cells with the computed $p_{\text{cc}}$ values, remove the trailing caption sentence ("$p_{\text{cc}}$ values for the CHMM-t rows below..."). Verify against the runner output once the run is re-executed.
**Effort:** 5 minutes (filling-out work, no new computation).
**Owner:** A.A.
**Status:** ☐ pending.

---

### Tier 1 — Required for the Body Framing to Hold

#### T1-1. Replace $K = 18$ with $K^\star = 6$ as the synthetic-data-consumer reference operating point

**Source:** R1-W4, R2-W3, R3-W2; carryover from V3 R3-W5 / V4 R3-W5 (third-revision unaddressed).
**Issue:** Both held-out criteria on the strictly pre-2020 slice select $K^\star = 6$ (held-out per-obs log-likelihood $-2.0606$ at $K = 6$ vs $-2.1921$ at $K = 18$, a 13-nat advantage on a 4.5-year window; held-out KS $96.8\%$). Body §4.2 closing parenthetical already states explicitly that "none of the six [held-out] criteria selects $K = 18$." The current operational story has one held-out-clean operating point ($K^\star = 3$) and one multi-objective-with-OoS-overlap point ($K = 18$).
**Decision required from authors:** Are we willing to demote the $K = 18$ panel?

Two paths:

**Path A — Promote $K^\star = 6$, demote $K = 18$ to extended-state-resolution reference.**
- Re-run Table 1, Table 2, Table 4, all body figures at $K = 6$.
- Update Section 4.2 ("State-Count Selection") to lead with the held-out-clean two-point story ($K^\star = 3$ and $K^\star = 6$).
- Demote $K = 18$ to an appendix "extended-state-resolution reference panel."
- Update the abstract: replace "$K = 18$ panel" with "$K^\star = 6$ panel."

**Path B — Argue empirically for $K = 18$ over $K = 6$ on a held-out-clean diagnostic.**
- Run a tail-fidelity diagnostic that does not use the OoS window (e.g., AD test on a separate validation slice; a cross-ticker fit-stability diagnostic).
- If the diagnostic favours $K = 18$, surface it in §4.2 as the empirical case for retaining $K = 18$.
- If the diagnostic favours $K = 6$ or is ambiguous, fall back to Path A.

**Recommended:** Path A. The empirical case for $K = 18$ over $K = 6$ that does not depend on the multi-objective rule is unlikely to be strong (Section 4.1 already reports ACF-MAE essentially flat across the sweep, and the kurtosis advantage at $K = 18$ rests on the multi-objective rule that overlaps the OoS window).
**Effort:** Path A is ~1 day of re-runs (Table 1, Table 2, Table 4, body figures) plus prose updates in §1, §4.1, §4.2, §4.3, §4.6, §5, §6 and the abstract; Path B is ~half a day if the diagnostic exists.
**Owner:** A.A. (re-runs); J.V. (sign-off on the demotion).
**Status:** ☐ pending decision.

#### T1-2. 30+ ticker sector-balanced cross-ticker panel

**Source:** R1-W2, R2-W2, R3-W3; carryover from V3 R2-W3 / V3 R3-W3 / V4 R3-W4 (third-revision unaddressed).
**Issue:** The cross-ticker "generalisation" framing rests on six tickers with two failures (NVDA OoS KS $53.8\%$, JPM OoS KS $53.8\%$). On six tickers with one-third failure rate the panel cannot support a "generalisation" claim, which is the wording in introduction paragraph 7 and conclusion paragraph 1.
**Fix:** Replace the 6-ticker spot-check with a 30–50 ticker sector-balanced S&P 500 panel. Report:
- Aggregate OoS KS pass-rate distribution: median, IQR, percentage below 60% threshold.
- Aggregate $|G_t|$ ACF-MAE (median, IQR).
- Aggregate kurtosis residual (median, IQR).
- Per-sector rollup (Energy, Financials, Health Care, Tech, Consumer, Industrials, Materials, Utilities, Real Estate, Communications): top-three-by-KS-failure tickers in the body to make the sector pattern visible.

**Implementation:** New runner `CHMM-Model.jl/run_30_ticker_panel.jl`. Pull a 30-ticker sector-balanced subset of the S&P 500 (e.g., top three by market cap per GICS sector) over the same $T_{\text{IS}} = 2{,}516$ window. Fit penalised CHMM-t at $K = 18$ (or $K^\star = 6$ if T1-1 Path A) under $\lambda = 20$.
**Body integration:** Replace Table 2 (`tab:cross_ticker`) with the 30+ ticker aggregate; move the 6-ticker spot-check to an appendix ("five named-ticker spot-check"). Update §1 and §6 prose to reflect the aggregate panel.
**Effort:** 1–2 days (data pull, 30 fits, aggregation, table re-write, prose). Most of the per-ticker fit time is already paid in `run_per_ticker_lambda_sweep.jl`.
**Owner:** A.A.
**Status:** ☐ pending.

#### T1-3. Promote penalised CHMM-t at $\lambda = 20$ into the headline-bold position

**Source:** R2-Q2, R3-W4, R3-Q2; carryover from V4 R3-Q5.
**Issue:** Headline-bold $K = 18$ block in Table 1 reports unpenalised CHMM-t at IS kurtosis $14.35$ (lower-bracket-pinning artefact); the penalised CHMM-t at $\lambda = 20$ ($8.56$ IS, $7.07$ OoS, the cleanest single-row match to observed $7.68$ IS / $5.29$ OoS) sits one line below as a separate row. The body Discussion identifies the unpenalised version as a pathology and the penalised version as the operational recommendation. The headline panel and the operational recommendation should match.
**Fix:**
- Promote `CHMM-t pen.\ ($\lambda = 20$)` to the headline-bold $K = 18$ position.
- Demote the unpenalised `CHMM-t ($K = 18$)` row to a footnote or an "unpenalised reference" sub-row.
- Update the abstract: replace "unpenalised CHMM-t $14.4$" with "penalised CHMM-t at $\lambda = 20$ at $8.56$ IS / $7.07$ OoS."
- Update introduction paragraph 8 ("CHMM-N $5.0$, CHMM-L $6.6$, ..., unpenalised CHMM-t $14.4$") to reference the penalised variant in the kurtosis-axis enumeration; keep the unpenalised number in a parenthetical noting the lower-bracket-pinning artefact.

**Effort:** 30 minutes (table re-bold; abstract + introduction prose). No re-runs needed.
**Owner:** A.A.
**Status:** ☐ pending.

---

### Tier 2 — Required Additional Evidence

#### T2-1. Walk-forward extension of the regime-conditional VaR back-test

**Source:** R1-Q3, R1-W5, R2-Q4, R3-Q5, R3-R3; carryover from V4 R1-Q3 / R2-R4.
**Issue:** Body Section 4.6 conditional-VaR result rests on a single OoS window. Walk-forward Table `tab:walkforward` shows two stress folds (W2 COVID, W4 2022 rate-hike) drop to KS $\le 8\%$. Does the regime-conditional Christoffersen-cc continue to pass on those folds, or does it fail? The body claim "the construction reuses IS-fixed CHMM-N parameters, requires no retuning of $K$ on a stress slice" is currently extrapolated from one window.
**Fix:** New appendix table. One row per fold $\times K \in \{3, 18\}$ (or $\{3, 6\}$ if T1-1 Path A) $\times \alpha \in \{0.01, 0.05\}$ for CHMM-N: 24 rows. Per row report breaches, breach rate, median VaR, $\text{LR}_{\text{uc}}$, $\text{LR}_{\text{ind}}$, $\text{LR}_{\text{cc}}$, $p_{\text{cc}}$.
**Implementation:** Extend `CHMM-Model.jl/run_walkforward_oos.jl` with the conditional-VaR construction (forward filter under fold-IS-fixed parameters); per-fold conditional VaR threshold; standard Christoffersen-cc decomposition.
**Body integration:** Body §4.6 closing paragraph ("the conditional pass on the headline OoS window holds across the walk-forward distribution including the two stress folds" or, if it doesn't, "passes on the four non-stress folds; fails on the two stress folds — the construction is window-conditional under regime shifts of this magnitude"). The latter framing is the honest one if the stress folds fail and is not weaker than the current single-window claim.
**Effort:** 1 day (extend the runner, run the 24 panels, integrate the table).
**Owner:** A.A.
**Status:** ☐ pending.

#### T2-2. Complete the CRPS column on all twelve Table 1 rows

**Source:** R1-Q4, R2-W5, R3-W6.
**Issue:** Table 1 CRPS column has missing entries on five of twelve rows (GARCH(1,1)-$t$, MS-GARCH ($K = 2$), CHMM-N at $K^\star = 3$, ML HSMM-N at $K^\star = 3$, CHMM-t pen., CHMM-GED). The proper-scoring-rule diagnostic in §4.3 ("ruling out the concern that the headline KS finding is a non-proper-metric artefact") supports the body claim only when complete; the "no material expected difference" caption claim cannot be verified without the run.
**Fix:** Run sample-CRPS on the missing five rows (extend `CHMM-Model.jl/run_crps.jl` or whichever runner produced the existing CHMM-N / CHMM-t / CHMM-L cells). Re-render Table 1 with the complete column. Update §4.3 prose: the Diebold-Mariano test now runs on per-row pairwise comparisons rather than a five-row cluster.
**Effort:** Half a day (5 simulate-and-CRPS runs at $1{,}000$ paths each, plus table re-render).
**Owner:** A.A.
**Status:** ☐ pending.

#### T2-3. Numerical full-rank check on $\hat{\mathbf T}_{\text{HSMM}}$ at $K = 3$

**Source:** R1-Q1, R2-Q1, R3-Q3.
**Issue:** ML HSMM-N at $K^\star = 3$ has $|G_t|$ ACF-MAE $0.0629$, identical within rounding to the i.i.d.\ bootstrap and Laplace i.i.d.\ baselines. Body §4.3 offers "a natural diagnosis" (Pareto sojourn concentrates probability mass in long-sojourn states) but does not test it.
**Fix:** Numerical check on $\hat{\mathbf T}_{\text{HSMM}}$ at $K = 3$: smallest singular value, $|\lambda_2|$, deflated rank, parallel to Table `tab:t_singular_values`. Plus state-occupancy fractions (fraction of IS time in each of three states) for the ML HSMM at $K = 3$ versus CHMM-N at $K = 3$.
**Body integration:** A sentence or two in §4.3 reporting either (a) $|\lambda_2| \approx 0$ and the spectral mechanism collapses (clean diagnosis), or (b) $|\lambda_2|$ comparable to CHMM-N's and the regression has a different cause (sojourn-distribution support, perhaps). Short appendix sub-table for the state-occupancy comparison.
**Effort:** Half a day (post-fit numerical analysis on the existing ML HSMM K=3 fit; no re-fitting).
**Owner:** A.A.
**Status:** ☐ pending.

---

### Tier 3 — Reframings and Reporting

#### T3-1. Re-order the abstract to lead with the walk-forward median IQR alongside the single-window pass rate

**Source:** R1-W3, R3-W5.
**Issue:** Current abstract sentence: "...$93.6$–$95.6\%$ IS and $80.8$–$85.7\%$ OoS KS, with CHMM-N's $|G|$ ACF-MAE within $0.003$ of GARCH(1,1). A six-fold rolling-origin walk-forward attains median OoS KS $67.7\%$ at $K = 18$ and $62.1\%$ at $K^\star = 3$, with the single-window pass rate at the upper end of the window distribution." The single-window number leads; the walk-forward median follows.
**Fix:** Two phrasings either work; pick one:
- (i) "...$80.8$–$85.7\%$ OoS KS at $K = 18$ on the headline window, sitting at the upper end of a six-fold walk-forward distribution with median $67.7\%$ (IQR $[8.2, 75.0]$)."
- (ii) "...with the single-window OoS KS at the upper end of a six-fold walk-forward distribution (median $67.7\%$ at $K = 18$, $62.1\%$ at $K^\star = 3$)."

**Effort:** 5 minutes.
**Owner:** A.A.
**Status:** ☐ pending.

#### T3-2. Drop "passes Kupiec" from the abstract or add the integer-grid caveat

**Source:** R2-W4.
**Issue:** Abstract says "passes Kupiec and Christoffersen-cc cleanly at every $(K, \alpha)$ on OoS." Body §4.6 explicitly treats unconditional Kupiec as a sanity check at $T_{\text{OoS}} = 572$ (integer-breach grid behaviour). The abstract should match.
**Fix:** Replace "passes Kupiec and Christoffersen-cc" with "passes Christoffersen-cc" (drop Kupiec); or add "(unconditional Kupiec passes as a sanity check; the substantive test at $T_{\text{OoS}} = 572$ is Christoffersen-cc)."
**Effort:** 5 minutes.
**Owner:** A.A.
**Status:** ☐ pending.

#### T3-3. Per-pair OoS off-diagonal heatmap or top-three-pairs-by-$|\Delta|$ table in body §4.5

**Source:** R2-W7.
**Issue:** Body §4.5 prose claims OoS off-diagonal MAE rise localises to JNJ pairs ("three JNJ pairs with $|\Delta| > 0.48$ on OoS"); the body Table 3 reports only the aggregate Frobenius and off-diag MAE. The localisation claim is supported only by the appendix.
**Fix:** Either (a) a small heatmap figure showing per-pair $|\Delta|$ on the 6 × 6 correlation off-diagonal, or (b) a 3-row top-three-by-$|\Delta|$ subtable inside Table 3.
**Effort:** Half a day (the per-pair $|\Delta|$ values are already computed; rendering is the bulk of the work).
**Owner:** A.A.
**Status:** ☐ pending.

---

### Tier 4 — Smaller Items

#### T4-1. Quintos-Fan-Phillips structural-break test on the rolling $\hat\nu^\star$ sequence

**Source:** R1-Q2, R2-Q5, R3-W7; carryover from V4 R1-Q5 / R2-Q3.
**Issue:** IS Wilks 95% CI $[6, 7]$; rolling sequence wanders across $\{5, 6, 10, 15\}$. Tension is unresolved.
**Fix:** Either (a) a Quintos-Fan-Phillips structural-break statistic on the rolling sequence (formal), or (b) a simple stationary block-bootstrap CI around each rolling estimate (informal but cheaper). Either settles small-sample-noise vs non-stationarity.
**Body integration:** A sentence or two in §4.5 reporting the test result and committing to a reading.
**Effort:** Half a day.
**Owner:** A.A.
**Status:** ☐ pending (lowest-priority Tier 4).

#### T4-2. Walk-forward stress-fold reading: W4 vs headline OoS

**Source:** R1-Q3, R3-Q5.
**Issue:** Why is the rate-cycle *onset* (W4 KS $\le 1\%$) catastrophically harder than the rate-cycle *reversal* (headline OoS KS $\sim 82\%$)?
**Fix:** A short paragraph in §4.3 (or §5 stationarity-scope discussion) reading the difference. Candidate explanations: (a) the IS window 2014–2019 saw only one mild rate-hike cycle (2015–2018), so the IS-fitted volatility regime distribution does not include the 2022 magnitude; the 2024–2026 window includes the *aftermath* of the 2022 hike, which IS-period regimes can partially span. (b) The 2022 hike was structurally a regime *introduction*; the 2024–2026 reversal was a regime *attenuation*, which is closer to IS volatility levels.
**Effort:** 30 minutes (prose; no re-runs).
**Owner:** A.A.
**Status:** ☐ pending.

#### T4-3. Body diagnostic on the per-ticker $\hat\lambda^\star$ rule

**Source:** R1-Q5.
**Issue:** Discussion paragraph hints at a rule ("per-ticker tuning is recommended whenever the ticker's residual kurtosis at $\lambda = 0$ is within $\sim 1$ unit of observed") but does not commit.
**Fix:** Either (a) commit to the rule as stated and report the per-ticker decision under the rule (NVDA, JNJ above the 1-unit threshold use $\lambda = 20$; SPY, JPM, AAPL below threshold use $\lambda \in \{0, 10\}$; QQQ uses $\lambda = 0$), or (b) acknowledge the per-ticker sweep is the right operational protocol and the body uniform $\lambda = 20$ is a default.
**Effort:** 15 minutes.
**Owner:** A.A.
**Status:** ☐ pending.

#### T4-4. Block-bootstrap KS recalibration sensitivity to block length $L$

**Source:** R2-Minor 2.
**Issue:** §5 paragraph "OoS KS pass rates against the test-power ceiling" uses $L = 10$ without sensitivity.
**Fix:** Run the block-bootstrap KS at $L \in \{5, 10, 20\}$ and report a one-line sensitivity in the body or appendix.
**Effort:** Half a day if the runner exists; otherwise skip (Tier 4 lowest-priority).
**Owner:** A.A.
**Status:** ☐ pending.

---

### Tier 5 — Presentation and Cosmetic

| Item                                                                                | Source                            | Effort     |
| ----------------------------------------------------------------------------------- | --------------------------------- | ---------- |
| T5-1 Separate ML HSMM-N row from CHMM family rows in Table 1 (`\midrule` or sub-header) | R1-Minor 2, R3-Minor 5            | 5 min      |
| T5-2 Table `tab:walkforward` IQR caption clarification ($Q_1, Q_3$ rather than scalar IQR) | R1-Minor 5, R3-Minor 1            | 2 min      |
| T5-3 VWAP-to-VWAP return choice flagged in abstract or §1 data paragraph            | R2-Minor 5, R3-Minor 4            | 5 min      |
| T5-4 Companion paper `alswaidan2026hybrid` citation policy (venue dependent)        | R1-Minor 3, R2-Minor 3, R3-Minor 3 | venue dep. |
| T5-5 Section §4.6 opens with conditional-Christoffersen-cc headline, not envelope-bracketing | R3-Minor 2                        | 10 min     |
| T5-6 Forward reference from §4.5 to Appendix C.10 quarterly rolling refit table     | R1-Minor 4                        | 2 min      |

---

## Net effort summary

| Tier | Items | Aggregate effort | Blocks |
| ---- | ----- | --------------- | ------ |
| Tier 0 (hard bug)         | 1 | 5 min                 | submission |
| Tier 1 (framing)          | 3 | 1.5–3 days            | R3 → Minor; R1, R2 → Accept |
| Tier 2 (evidence)         | 3 | 2 days                | abstract framing |
| Tier 3 (re-framings)      | 3 | ~1 day                | abstract / §4.5 |
| Tier 4 (smaller items)    | 4 | ~1 day                | nothing critical |
| Tier 5 (cosmetic)         | 6 | ~30 min               | nothing critical |
| **Total**                 | **20** | **~6 days of work** | |

---

## Recommended sequencing

**Day 1.** T0-1 (Table 4 placeholder fix, 5 min). T1-3 (penalised CHMM-t into headline, 30 min). T3-1, T3-2 (abstract re-order + Kupiec wording, 10 min). T5-1 to T5-6 cosmetic batch (~30 min). **End of day:** Tier 0 closed; Tier 3 partial; Tier 5 closed. R1 and R2 read close to Accept.

**Days 2–3.** T1-1 decision. If Path A: re-run Table 1 / Table 2 / Table 4 / body figures at $K = 6$, prose updates across §1, §4.1, §4.2, §4.3, §4.6, §5, §6, abstract. If Path B: tail-fidelity diagnostic, decide per outcome. **End of day 3:** R3 either at Minor (Path A) or pending the cross-ticker panel (Path B).

**Days 4–5.** T1-2 (30+ ticker panel). New runner, 30 fits, aggregation, table re-write, prose updates in §1, §4.4, §6. **End of day 5:** R3 at Minor.

**Day 6.** T2-1 (walk-forward conditional-VaR), T2-2 (complete CRPS column), T2-3 ($\hat{\mathbf T}_{\text{HSMM}}$ rank check), T3-3 (per-pair OoS heatmap), T4-2 (W4 vs headline reading), T4-3 (per-ticker $\hat\lambda^\star$ rule), T4-1 (Quintos-Fan-Phillips test, optional). **End of day 6:** All Tier 0–4 items closed. R3 at Accept.

---

## Decision points for the authors

1. **T1-1 Path A vs Path B.** Promote $K^\star = 6$ over $K = 18$, or argue for $K = 18$ on a held-out-clean diagnostic? (Recommended: Path A.)
2. **T1-2 universe size.** 30 tickers is the floor; 50 is comfortable; the S&P 500 itself (with sector balancing) is the ceiling. (Recommended: 30 sector-balanced.)
3. **T1-3 unpenalised CHMM-t fate.** Demote to footnote, or remove from Table 1 entirely? (Recommended: footnote with a one-sentence pathology note.)
4. **T2-1 fold scope.** Six folds for CHMM-N only (24 rows), or extend to all four families (96 rows)? (Recommended: six folds CHMM-N only; the four-family extension is in `tab:cond_var_all_families` already.)
5. **T4-1 priority.** Run the QFP structural-break test, or skip? (Recommended: run if half a day is available; otherwise the simple bootstrap-CI alternative is sufficient.)

---

## Predicted outcome after V5 → Accept revision

| Reviewer        | V5 → Accept (with Tier 0 + Tier 1)        | V5 → Accept (with Tier 0 + Tier 1 + Tier 2) |
| --------------- | ----------------------------------------- | ------------------------------------------- |
| R1 (Moderate)   | **Accept**                                | **Accept**                                  |
| R2 (Hard)       | **Accept**                                | **Accept**                                  |
| R3 (Very Hard)  | **Minor Revision** (close to Accept)      | **Accept**                                  |

Tier 0 plus Tier 1 items 1–3 (placeholder fix; $K^\star = 6$ promotion; penalised CHMM-t headline) plus Tier 1 item 2 (30+ ticker panel) is the minimal set that converts all three reviewers to Accept. Tier 2 items strengthen the evidence base but are not strictly blocking once the framing is right. Tier 3–5 items are polish and should ride along with the Tier 0–2 work.
