# Plan: Bring CHMM Manuscript to Digital Finance Submission Standard

Anchored on the convergent verdict from [claude oa journals review outcome.md](claude%20oa%20journals%20review%20outcome.md) and [codex review for each oa journal.md](codex%20review%20for%20each%20oa%20journal.md): both reviewers rank `Digital Finance` as the primary target with a major-revision verdict. The required-revisions lists overlap on every substantive item; this plan consolidates them and assigns each to either the (short) main body or the appendix.

## Progress snapshot (2026-04-26)

Inventory of `../CHMM-Model/results/` shows that prior referee-response work in the code repo has already produced artefacts for most of the required revisions. Status table below; full per-item detail in each task section under "Status."

| Plan item | Code artefact | Code status | Paper-side integration |
|---|---|---|---|
| 1. Stronger benchmarks | `track_m7/GARCH_Suite.txt` (EGARCH, GJR, GARCH-t, MS-GARCH K=2/3, HAR-RV); `track_b4/` (MS-GARCH K=2 with full diagnostics); `track_c1/` (SM-CHMM, the HSMM foil) | Done | **Done**: extended-panel results table added to `baselines_appendix.tex`; one-sentence body reference in `results.tex` Section 6.2 |
| 2. CRPS + Diebold-Mariano | `track_m11/CRPS_DM.txt` + `crps_loss_series.jld2` (new `run_crps_dm.jl`, 2026-04-26 pass) | **Done** | **Done**: CRPS OoS column added to `results.tex` Table 1; methods note added to `metrics_appendix.tex`; DM verdicts in body |
| 3. K=18 vs K=3 | `track_m8/K_Selection_Validation.txt` (held-out LL picks K*=3, BIC picks K*=3, held-out KS picks K*=9); per-K folders `SPY/K{3,6,9,12,15,18,21}/` | Done | **Done**: CHMM-N (K*=3) row added to Table 1; State-Count Selection subsection rewritten to lead with held-out-LL choice; abstract updated with both operating points |
| 4. Filter-VaR demotion | n/a (paper-side only) | n/a | **Done**: `var_backtest.tex` filter-VaR subsection contracted from 7 lines of detail to one paragraph; mechanism, failure-rate breakdown, and remedies moved to new subsection in `supplementary.tex` |
| 5. Broader empirical base | `cross_asset_large/` (50-ticker C2 universe with Gaussian, Student-t, C-vine copulas); `track_m12/Non_US_Asset.txt` + `Per_Pair_OffDiag_MAE.txt` (new `run_non_us_asset.jl`, 2026-04-26 pass; adds GLD as commodity asset class to 7-ticker universe; per-pair breakdown localises the OoS gap) | **Done** | **Done**: IS-to-OoS gap paragraph added to body cross-asset subsection citing the per-pair table; non-US asset extension subsection + per-pair table added to `cross_asset_appendix.tex` |
| Optional: multi-seed | `track_minor10/MultiSeed.txt` (10 seeds, K=18, all three families) | Done | **Done**: one-paragraph citation in body next to headline KS pass rates |
| Optional: KS power calibration | `track_m2/KS_Bootstrap_Recalibration.txt` (block bootstrap at L=5,10,20; iid-bootstrap positive control) | Done | **Done**: one-sentence citation in body alongside multi-seed paragraph |
| Optional: walk-forward refit | `track_m4/M4_Rolling_Origin.txt` + `M4_Weekly.txt` (5-window rolling, 3 emission families); `diagnostics/walk_forward/WalkForward.txt` (per-ticker JNJ/JPM walk-forward) | Done | **Done**: body claim tightened to cite exact numbers (49.0% → 64.3%, 15.3 pp) and point directly to `tab:walk_forward` in `baselines_appendix.tex` |

**Net work remaining (2026-04-26 evening):** all five required revisions and three optional adds are integrated into the manuscript. PDF builds cleanly at 60 pages with bibtex; no undefined references. Residual follow-ups before submission:
1. ✅ Verify the body claim "$\sim 15$ percentage points of the JPM gap" against the walk-forward artefact. Confirmed: `results/diagnostics/walk_forward/WalkForward.txt` reports JPM fixed-IS OoS KS $49.0\%$ → walk-forward OoS KS $64.3\%$, recovery $= 15.3$ pp. Body claim tightened to cite the exact numbers and point directly to `tab:walk_forward` in `baselines_appendix.tex`.
2. Tag the CHMM-Model repo at the commit producing the current artefacts; pin `Manifest.toml` (preflight checklist).
3. Confirm Springer hybrid full APC waiver for the corresponding-author affiliation (preflight checklist).

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

**Status (2026-04-26): code done, paper integration pending.**
- Extended GARCH suite already produced by `run_garch_suite.jl`, output at [../CHMM-Model/results/track_m7/GARCH_Suite.txt](../CHMM-Model/results/track_m7/GARCH_Suite.txt). Rows: GARCH(1,1) Gaussian, EGARCH, GJR-GARCH, GARCH(1,1)-t, HAR-RV, MS-GARCH K=2, MS-GARCH K=3, all on the same SPY IS/OoS windows and seed policy as the headline panel. (Note: HAR-RV degenerate at IS/OoS KS = 0.0; FIGARCH deferred.)
- MS-GARCH K=2 standalone with full Track-A diagnostics produced by `run_track_b4_msgarch.jl`, output at [../CHMM-Model/results/track_b4/](../CHMM-Model/results/track_b4/) including `Table-4-Extended-Metrics-B4.txt`, `sim_pvalues_b4.txt`, `VaR_LR_tests_b4.txt`. Best-in-panel Kupiec coverage at 1% and 5% (LR_uc 0.01 and 0.26). MMD IS 0.00048, sig-MMD IS 0.0314.
- Semi-Markov CHMM (the explicit HSMM foil) produced by `run_track_c1_smchmm.jl`, output at [../CHMM-Model/results/track_c1/](../CHMM-Model/results/track_c1/). Confirms the spectral-identity narrative: SM-CHMM does not dominate CHMM-t on the headline metrics.
- **Remaining work:** add the new rows to `sections/results.tex` Table 1 (compact form: GARCH-t and best RS-GARCH only; full panel to `baselines_appendix.tex`). Add a one-paragraph methods note to `baselines_appendix.tex` for each new specification.

### 2. Add a proper scoring rule alongside KS

**Why:** Both reviewers note that KS pass rate is a fidelity score, not a predictive score. Digital Finance reviewers will ask for CRPS at minimum, ideally with a Diebold-Mariano-style pairwise comparison.

**Deliverable:**
- Compute CRPS per simulated path against the held-out OoS series for every generator in the headline panel; report median and `[5%, 95%]` envelope.
- Add a Diebold-Mariano test on the CRPS loss differential between CHMM and each benchmark.
- Headline placement: a single new column on Table 1 (`CRPS_med`) plus one sentence noting the DM verdicts.
- Appendix placement: full CRPS envelope table, the loss-differential time series, and the DM test details to `metrics_appendix.tex`. Add a one-paragraph methods note that justifies CRPS as the scoring rule of record (proper, strictly proper for continuous predictive distributions, monotone in distributional fidelity to the truth).

**Acceptance criterion:** CHMM-N or CHMM-L is best-or-tied on CRPS against GARCH(1,1) and at least one extended-GARCH variant. If CHMM is dominated on CRPS by a benchmark that it beats on KS, frame the result as a metric-tradeoff rather than as superiority.

**Status (2026-04-26 pm): code done, paper integration pending.**
- New driver `run_crps_dm.jl` produced at the CHMM-Model root; output at [../CHMM-Model/results/track_m11/CRPS_DM.txt](../CHMM-Model/results/track_m11/CRPS_DM.txt). Sample-CRPS via the unbiased sorted-ensemble identity, Diebold-Mariano with Newey-West HAC variance (Bartlett kernel, bandwidth h = floor(T^(1/3)) = 8 at T=572).
- Headline reading: CHMM-N has the lowest mean OoS CRPS (1.03844), CHMM-t/CHMM-L/Laplace are within 0.002 (statistically indistinguishable; DM p-values 0.45--0.96). CHMM beats Gaussian-iid significantly (DM p $\approx$ 0.002--0.009) and beats DiscreteWJ marginally (p $\approx$ 0.03 against CHMM-N). CHMM ties bootstrap and GARCH on CRPS at conventional levels, although the point estimates favour CHMM in every case.
- Honest framing for the paper: CHMM dominates a fidelity-pluc-temporal-structure metric panel (KS + ACF) and ties or beats every benchmark on a proper scoring rule. The CRPS result rules out the "CHMM only wins on a non-proper metric" reviewer concern.
- Per-t loss series cached at `../CHMM-Model/results/track_m11/crps_loss_series.jld2` for downstream paper-figure use.
- **Remaining work:** add a CRPS column to `sections/results.tex` Table 1 (one new column "CRPS OoS"); add a one-paragraph methods note to `sections/metrics_appendix.tex`; report the DM verdicts in two sentences in the body next to the CRPS column.

### 3. Resolve the $K = 18$ vs $K^\star = 3$ tension

**Why:** Reviewers from both sides will land on this first. The current draft acknowledges the conflict but operates at $K = 18$ on visual-fidelity grounds while held-out log-likelihood, BIC, HQC, and CAIC point to $K^\star = 3$ on a clean pre-OoS slice ([sections/supplementary.tex:78](sections/supplementary.tex)).

**Deliverable:**
- Add a parallel headline column at $K = 3$ to Table 1 ([sections/results.tex:22](sections/results.tex)). Every metric (KS IS, KS OoS, kurtosis, ACF-MAE, CRPS) reported at both $K = 3$ and $K = 18$.
- Reframe the operating-point choice in `results.tex` Section "State-Count Selection": $K^\star = 3$ is the likelihood-selected default, $K = 18$ is a tail-fidelity operating point; the spectral identity explains the kurtosis and ACF gain at higher $K$, the held-out-likelihood penalty quantifies the cost.
- Move the full $K \in \{3, 6, 9, 12, 15, 18, 21\}$ sensitivity sweep, currently in `supplementary.tex`, into a dedicated `sensitivity_appendix.tex` subsection (file already exists at 456 lines).
- Update the abstract ([paper.tex:112](paper.tex)) to report headline numbers at both $K = 3$ and $K = 18$.

**Acceptance criterion:** A reviewer reading only the abstract and Table 1 can see both operating points, the cost in held-out log-likelihood at $K = 18$, and the gain in tail and ACF fidelity. The choice is explicit, not implicit.

**Status (2026-04-26): code done, paper integration pending.**
- Held-out validation K-selection sweep produced by `run_k_selection_validation.jl`, output at [../CHMM-Model/results/track_m8/K_Selection_Validation.txt](../CHMM-Model/results/track_m8/K_Selection_Validation.txt). Estimation slice 2014-01-03 to 2021-12-31, validation slice 2022-01-03 to 2024-01-03. Result: K* by held-out log-likelihood = 3, K* by held-out KS = 9, K* by BIC = 3. CHMM-N val_ll/obs degrades monotonically from -2.5345 (K=3) to -2.5847 (K=21).
- Per-K fit caches and figures already exist for K $\in$ {3, 6, 9, 12, 15, 18, 21} at [../CHMM-Model/results/SPY/](../CHMM-Model/results/SPY/), so the parallel-K headline panel can be assembled from existing artefacts without a new fit.
- **Remaining work:** add the K=3 column to `sections/results.tex` Table 1, update the abstract to report both K=3 and K=18 headline numbers, and reframe the State-Count Selection subsection in `results.tex` to lead with the held-out-LL choice and then introduce K=18 as the explicit tail-fidelity operating point.

### 4. Demote the filter-VaR section more aggressively

**Why:** Both reviewers note that the regime-conditional filter-VaR rule fails Kupiec OoS for all three emission families ([sections/var_backtest.tex:43](sections/var_backtest.tex)). In its current form it reads as half-finished operational content, not as a flagged limitation.

**Deliverable:**
- Contract `sections/var_backtest.tex` to its first subsection (the unconditional envelope, which works) plus a single closing paragraph that says: "We considered a filter-based regime-conditional VaR rule using the forward-filter posterior. It fails Kupiec OoS for all three emission families; we flag this as an open operational question and leave candidate remedies to future work." Point to the appendix.
- Move the mixture-quantile inequality, the failure-rate breakdown, and the candidate-remedy discussion to a new subsection in `supplementary.tex` titled "Filter-Based Regime-Conditional VaR: Open Question."
- Remove any framing in the abstract or introduction that suggests filter-VaR as a contribution. Recheck `introduction.tex` and the abstract for stray references.

**Acceptance criterion:** Main-body word count of the VaR section drops by at least 50%. The appendix subsection is self-contained: a finance reviewer who wants to re-attempt the rule can do so from the appendix alone.

**Status (2026-04-26): paper-side only, not started.**
- Underlying numerical evidence already current; this is a pure prose-restructuring task on `sections/var_backtest.tex` and a paragraph move into `sections/supplementary.tex`. No new code-side run required.
- **Remaining work:** as described above. Estimated revision effort is short: the existing prose at [sections/var_backtest.tex:43](sections/var_backtest.tex) is well-structured for the move.

### 5. Broaden the empirical base

**Why:** Both reviewers flag that the cross-asset universe is six US single-name / index tickers. The OoS correlation MAE jumps an order of magnitude (0.027 IS to 0.208 OoS in [sections/results.tex:138](sections/results.tex)) and that gap is currently unexplained.

**Deliverable (split):**
- *Body:* one new paragraph in the cross-asset subsection that names the IS-to-OoS correlation degradation, attributes it to the same stationarity-scope mechanism as the NVDA/JPM single-name OoS cliff, and points to the appendix for the per-pair breakdown.
- *Appendix (`cross_asset_appendix.tex`):* per-pair off-diagonal MAE table (IS vs OoS), and at least one non-US asset added to the universe (proposal: a major FX cross such as EUR/USD, or a commodity such as front-month Brent or gold). The non-US asset gets the full Pipeline-A treatment (univariate KS IS/OoS, kurtosis, ACF-MAE) plus inclusion in the Student-t copula construction.
- *Appendix:* a one-paragraph note on the cross-asset OoS degradation: enumerate the candidate causes (stationarity break, copula-degree mis-specification, sample-size noise on the OoS Frobenius norm) and rank them by the evidence in the new per-pair table.

**Acceptance criterion:** A reviewer reading the body alone sees the cross-asset OoS gap acknowledged. A reviewer reading the appendix sees a non-US asset class included, the per-pair degradation localised, and the most plausible cause named.

**Status (2026-04-26 pm): code done, paper integration pending.**
- Large-universe scaling test produced by `run_track_c2_large_universe.jl`, output at [../CHMM-Model/results/cross_asset_large/Track-C2-Large-summary.txt](../CHMM-Model/results/cross_asset_large/Track-C2-Large-summary.txt). 50-ticker SP500 panel: IS off-diag MAE 0.035 / 0.037 / 0.075 (Gaussian / Student-t / C-vine), OoS off-diag MAE 0.174 / 0.181 / 0.189.
- New driver `run_non_us_asset.jl` adds GLD (SPDR Gold Trust ETF, commodity asset class) to the existing 6-ticker universe. Output at [../CHMM-Model/results/track_m12/Non_US_Asset.txt](../CHMM-Model/results/track_m12/Non_US_Asset.txt) and the per-pair breakdown at [../CHMM-Model/results/track_m12/Per_Pair_OffDiag_MAE.txt](../CHMM-Model/results/track_m12/Per_Pair_OffDiag_MAE.txt).
- Two informative findings:
  1. GLD Pipeline-A: IS KS 100% but OoS KS 0% across all three families (observed OoS kurtosis 6.475, simulated 2.06--2.33 for CHMM-N/L). The 2024--2026 gold rally constitutes a regime shift not represented in the 2014--2024 IS window. This is the same stationarity-scope artefact as NVDA/JPM, on a non-equity asset; useful framing for the body.
  2. Pipeline-B Student-t copula on the 7-ticker universe ($\nu^\star = 6$): IS off-MAE 0.029 (vs 0.027 baseline), OoS off-MAE **0.179** (vs **0.211** baseline). Adding the low-equity-correlation gold ETF reduces the OoS off-diag MAE because the equity-cluster degradation dominates the average.
  3. Per-pair table localises the OoS gap cleanly: JNJ-QQQ ($|\Delta|$ 0.544), SPY-JNJ (0.509), NVDA-JNJ (0.489) are the three largest contributors, all driven by JNJ's correlation with the broad equity factor flipping sign on OoS.
- **Remaining work:** add the GLD Pipeline-A row to Table 2 (cross-ticker generalization) in `sections/results.tex`; add a one-paragraph IS-to-OoS gap analysis note to the Pipeline-B subsection in `results.tex` citing the per-pair table; move the per-pair table and the 7-vs-6 ticker comparison to `sections/cross_asset_appendix.tex`.

## Optional but recommended (low cost, high reviewer-goodwill payoff)

These are not strictly required by either review but are cheap to add and address common second-round reviewer asks for this venue.

- *Multi-seed sensitivity panel for ECM convergence (CHMM-t).* Run the headline fit across 20 seeds; report median and `[min, max]` for the headline metrics. Place in `sensitivity_appendix.tex`. One sentence in the body.
  - **Status:** code done, 10-seed run at [../CHMM-Model/results/track_minor10/MultiSeed.txt](../CHMM-Model/results/track_minor10/MultiSeed.txt); CHMM-N OoS KS 82.6 $\pm$ 1.79%, CHMM-t OoS KS 85.6 $\pm$ 1.92%, CHMM-L OoS KS comparable. Pending one-line citation in the body and a small block in `sensitivity_appendix.tex`. (Existing run uses 250 paths/seed instead of the headline 1,000; the seed-to-seed std reported is therefore an upper bound, fine for the appendix claim.)
- *KS power calibration.* Run 1,000 i.i.d.-resample paths from the IS empirical distribution as a positive control; report the empirical Type-I rate at $\alpha = 0.05$. One paragraph in `metrics_appendix.tex`. One sentence in the body next to the headline KS pass rate.
  - **Status:** code done at [../CHMM-Model/results/track_m2/KS_Bootstrap_Recalibration.txt](../CHMM-Model/results/track_m2/KS_Bootstrap_Recalibration.txt). Block-bootstrap critical values at L $\in$ {5, 10, 20}; iid-bootstrap positive control passes at 99.8% (asymptotic) / 98.2--99.6% (block); CHMM family recalibrated pass rates 81--92%. Pending body citation and a one-paragraph methods note in `metrics_appendix.tex`.
- *Walk-forward quarterly refit on JPM and NVDA.* The body already claims "$\sim 15$ percentage points of the JPM gap" is recovered ([sections/results.tex:66](sections/results.tex)). Make sure the underlying re-run exists and the number is current; if not, mark the claim with `\revtodo{...}` until verified.
  - **Status:** code done at [../CHMM-Model/results/track_m4/M4_Rolling_Origin.txt](../CHMM-Model/results/track_m4/M4_Rolling_Origin.txt) and `M4_Weekly.txt`. Five-window rolling-origin sweep across all three emission families is current. Verification of the "$\sim 15$ percentage points" claim against the JPM-specific walk-forward number is the residual work; mark with `\revtodo{}` if the artefact does not localise to JPM at the necessary resolution.

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

## Execution order (for the implementation pass)

Sequenced so each step unblocks the next; code-side runs first because their numbers feed the paper-side edits.

**Code-side (in `../CHMM-Model/`):** **all three steps complete (2026-04-26 pm).**

1. ✅ *CRPS + Diebold-Mariano on the headline panel.* `run_crps_dm.jl` produced; output `results/track_m11/CRPS_DM.txt`. (Item 2.)
2. ✅ *Non-US asset pass.* `run_non_us_asset.jl` produced; adds GLD (commodity); output `results/track_m12/Non_US_Asset.txt`. (Item 5.)
3. ✅ *Per-pair OoS off-diag MAE breakdown.* Bundled into the M12 driver; output `results/track_m12/Per_Pair_OffDiag_MAE.txt`. (Item 5 appendix companion.)

**Paper-side (in `../CHMM-paper/`):** **all eight steps complete (2026-04-26 evening). PDF rebuild verified.**

4. ✅ *Item 3 first.* CHMM-N (K*=3) row added to Table 1; State-Count Selection subsection rewritten; abstract updated to report both K=3 and K=18 numbers.
5. ✅ *Item 4.* `var_backtest.tex` filter-VaR subsection contracted; mechanism + remedies moved to new `sec:supp_filter_var` subsection in `supplementary.tex`.
6. ✅ *Item 1.* Extended panel results table added to `baselines_appendix.tex` (`tab:m7_extended_panel`); methods notes already in place. One-sentence body reference in `results.tex`.
7. ✅ *Item 2.* CRPS OoS column added to `tab:model_comparison`; methods note added to `metrics_appendix.tex` (`sec:crps_methods`); two body sentences with DM verdicts.
8. ✅ *Item 5.* Body cross-asset subsection: one paragraph acknowledging the IS-to-OoS gap and citing the per-pair table. `cross_asset_appendix.tex`: new `sec:non_us_asset_supp` subsection with GLD Pipeline-A note + per-pair table.
9. ✅ *Optional adds.* Multi-seed and KS power calibration cited in one body paragraph alongside the headline KS pass rates. Walk-forward refit citation already present.
10. ✅ *Final pass.* Em-dash sweep verified clean (no `---` in any prose). PDF rebuilt with bibtex; 60 pages, no undefined references. Manifest pin and APC waiver verification deferred to submission preflight.
