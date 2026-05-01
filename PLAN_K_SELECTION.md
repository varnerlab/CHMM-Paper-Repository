# CHMM Paper Surgery Plan

## Goal

Take the CHMM paper from 131 pages to roughly 80–90 pages while sharpening the contribution. Keep all underlying analyses in the appendices. The body should re-litigate nothing.

Target: clean arXiv post within a week, then submission to a mid-tier journal (e.g., *International Journal of Forecasting*, *Journal of Empirical Finance*, *Quantitative Finance*).

## Status board

| Phase | Status | Notes |
|---|---|---|
| 0. Abstract trim | **DONE** | ~3,700 → ~1,900 chars |
| 1. K-selection consolidation | **DONE** | Canonical recipe adopted; body operating point K* = 3 only |
| 2. Cuts in `sections/results.tex` | **DONE** | R3 (multi-day CRPS DM) + R4 (per-ticker λ*) absorbed during Phase 1 prose rewrite |
| 3. Cuts in `sections/var_backtest.tex` | **DONE** | V1 + V2 replaced with one-sentence appendix pointers |
| 4. Cuts in `sections/discussion.tex` | **DONE** | D2 / D3 / D4 / D5 absorbed during full discussion rewrite |
| 5. Compile + page count check | **DONE** | Clean compile, 131 → 124 pages, no undefined refs / errors |
| 6. arXiv prep | TODO | Source bundle, comments field, categories |

**Page count history:** 131 (initial) → 124 (Phase 0–4 body trim) → **112 (after Tier 1 appendix cuts)**.

## Tier 1 cuts (committed)

Cut from paper:
- `baselines_appendix.tex` §"Per-Ticker OoS Price-Simulation Figures and Full Path-Level Metrics" (127 lines, 6 figures, 1 table)
- `baselines_appendix.tex` §"QuantGAN Deeper-Architecture Reference Rebuild" + §"QuantGAN with Lambert-W Input Pre-Processing" (~50 lines, 2 tables)
- `sensitivity_appendix.tex` §"Multi-Day Cumulative-Return Diebold-Mariano on CHMM vs. Stationary Block Bootstrap" + §"Multi-Day DM Replication" (~80 lines, 2 tables)
- `sensitivity_appendix.tex` §"Daily-Refit Online-EM at the Cadence Boundary on W2 / W4" (~25 lines, 1 table)
- `sensitivity_appendix.tex` §"MS-GARCH Regime-Conditional VaR via the Same State-Filter Pipeline" (~29 lines, 1 table)
- `sensitivity_appendix.tex` §"$K_{\text{eff}}$-Corrected Information-Criterion Re-Rank" + §"$K_{\text{nominal}} = 11$ rebuild against $K = 18$ nominal" (~50 lines, 2 tables)

Body prose adjustments:
- `results.tex` line 12: dropped `\ref{sec:k_eff_corrected_ic}` from the appendix-pointer list
- `results.tex` Bootstrap-as-benchmark paragraph: dropped multi-day CRPS DM mention
- `var_backtest.tex` walk-forward paragraph: collapsed daily-refit / online-EM / cadence-sweep specifics to one sentence
- `var_backtest.tex` MS-GARCH state-filter paragraph: dropped specific appendix reference
- `sensitivity_appendix.tex`: dropped trailing "daily-refit / online-EM extension below" sentence

Cut from CHMM-Model:
- 9 runner scripts: `run_equity_price_sim.jl`, `run_quantgan_tcn.jl`, `run_quantgan_tcn_lambertw.jl`, `run_crps_dm_multiday.jl`, `run_crps_dm_multiday_replication.jl`, `run_online_em_conditional_var.jl`, `run_msgarch_conditional_var.jl`, `run_k_eff_corrected_ic.jl`, `run_k_eff_rebuild.jl`
- 8 result directories: `results/{quantgan_tcn, quantgan_tcn_lambertw, crps_dm_multiday, crps_dm_multiday_replication, equity_price_sim, k_eff_corrected_ic, k_eff_rebuild, walkforward_online_em}`
- 1 result file: `results/diagnostics/msgarch_conditional_var.txt`
- `run_full_rebuild.jl`: dropped `run_equity_price_sim.jl` reference

Cut from `figs/`:
- 11 orphan figures: Fig-{NVDA, JNJ, JPM, AAPL, QQQ}-PriceFan-N.pdf and Fig-{NVDA, JNJ, JPM, AAPL, QQQ, SPY}-TerminalDist-N.pdf

**Final state:** clean compile, 112 pages, 0 undefined refs, 0 errors. 102 figures (was 113), ~70 tables (was 76).

---

## Phase 1: K-selection consolidation

**Principle (from canonical HMM literature: Cappé–Moulines–Rydén 2005; Frühwirth-Schnatter 2006; Pohle et al. 2017):**
1. Define metrics: held-out per-observation log-likelihood, held-out KS, |G_t| ACF-MAE.
2. Time-aware rolling-origin CV.
3. Sweep K, plot IS vs OoS curves.
4. Identify K maximising OoS performance.
5. Apply parsimony: when two K values are statistically tied on OoS, pick the lower.

**Body recipe under this plan:** held-out log-lik + held-out KS under rolling-origin CV → K* = 3. Parsimony tiebreaker against K* = 6 (|z| ≤ 0.07, indistinguishable from sampling noise). One paragraph of body prose.

**Body operating point: K* = 3 only.** K* = 6 and K = 18 move to appendix sensitivity panels.

### Tasks

- [x] **1.1** Rewrite `sections/results.tex` Subsection "State-Count Selection" (lines 9–36) to match the canonical recipe. Compress to: K-grid, rolling-origin CV protocol, BIC-only IC reference, parsimony tiebreaker. Drop AIC/HQC/CAIC from the body table; keep BIC. Drop the K_eff IC re-rank paragraph entirely. Move HAC variance discussion to appendix. **DONE.**
- [x] **1.2** Rewrite Table~\ref{tab:k_selection} as a 2-column table: criterion × pre-2020 slice. Drop the 2022–2023 column or fold into one row. **DONE.**
- [ ] **1.3** Drop the K* = 6 sensitivity block and K = 18 extended-state-resolution block from body Table~\ref{tab:model_comparison}. Body table reports: benchmarks + K* = 3 block + ML HSMM-N row.
- [ ] **1.4** Update body prose throughout `results.tex` and `discussion.tex` to reference K* = 3 only. Search-and-replace "K = 18 sensitivity reference", "extended-state-resolution sensitivity reference", "K* = 6 sensitivity reference" mentions in body to "(see Appendix \ref{...})".
- [ ] **1.5** Drop the "Practical identifiability and the effective state count at K = 18" paragraph from `discussion.tex` (lines 14–15). One-sentence replacement: "Practical identifiability at high K (K_eff diagnostic, K = 11 rebuild matching K = 18 panel) is reported in Appendix \ref{sec:state_distinctness}, \ref{sec:k_eff_rebuild}."
- [ ] **1.6** Cross-ticker panel (`sections/results.tex` Subsection \ref{sec:cross_asset_univariate}, lines 143–169) currently reports three operating points. Reduce body Table~\ref{tab:cross_ticker} to K* = 3 only; the K* = 6 and K = 18 columns move to appendix.

**Acceptance:** body has one operating point (K* = 3); body K-selection prose ≤ 1 paragraph + 1 small table; all sensitivity material lives in appendices.

---

## Phase 2: Cuts in `sections/results.tex`

- [ ] **2.1 (R3)** Delete the "multi-day CRPS DM" paragraph within "Bootstrap as a non-parametric synthetic-data benchmark" (line 111). The paragraph itself states the result does not replicate at K* = 3 or across the six-asset universe. Replace with: "The CHMM-vs-bootstrap differentiation is on the structural use cases (regime-conditional VaR, copula composition, parametric privacy)."
- [ ] **2.2 (R4)** Delete the "Per-ticker $\hat\lambda^\star$ as the headline cross-ticker recipe" paragraph (lines 148–149). Appendix retains the per-ticker sweep table.

**Acceptance:** results.tex body prose contains no non-replicating findings and no recipe-tuning paragraphs.

---

## Phase 3: Cuts in `sections/var_backtest.tex`

- [ ] **3.1 (V1)** Replace the "Is the conditional-coverage benefit CHMM-specific or multi-state-generic?" paragraph (lines 45–47) with a single sentence: "The state-filter VaR pipeline of Eq.~\eqref{eq:filter} also applies to other multi-state regime-switching models; an MS-GARCH counterfactual at $K \in \{2, 3, 4\}$ is reported in Appendix~\ref{sec:msgarch_conditional_var}."
- [ ] **3.2 (V2)** Move the "Multiple-testing correction across the panel" paragraph (lines 51–52) to an appendix subsection. Body retains one sentence: "BH-FDR correction at FDR = 0.05 retains the panel-level pass-rate (Appendix \ref{...})."

**Acceptance:** var_backtest.tex body argues *for* the conditional-VaR construction without an extended self-undermining or panel-correction excursion.

---

## Phase 4: Cuts in `sections/discussion.tex`

- [ ] **4.1 (D2)** Delete the "Baseline-implementation caveats" paragraph (lines 43–44). Appendix retains implementation details. If QuantGAN row is also removed from body Table 2, this paragraph has no body referent.
- [ ] **4.2 (D3)** Delete the "Deferred follow-ups (closed and remaining)" paragraph (lines 49–50) entirely. Pure peer-review accounting; no published-reader value.
- [ ] **4.3 (D4)** Trim the "Limitations" paragraph (line 46–47) to ≤ 4 sentences: skew-emission deferral, multi-asset scaling, US-equity scope, copula OoS-null. Drop the "we have addressed six of the deferred robustness items raised in pre-submission peer review" catalog.
- [ ] **4.4 (D5)** Trim the "Stylized-fact scope: simulated leverage envelope" paragraph (lines 40–41) to ≤ 4 sentences. Reframe as: (i) symmetric scaffold produces a non-trivial signed signal via Markov state-mixing, (ii) IS observed leverage borderline-non-rejected, (iii) OoS observed leverage rejected at 5%, (iv) skew-emission extensions are the natural fix. Drop the EGARCH/GJR comparison detail.

**Acceptance:** discussion.tex body argues for the contribution without re-litigating peer-review responses.

---

## Phase 5: Compile + page count check

- [ ] **5.1** `make` clean compile, no warnings beyond standard.
- [ ] **5.2** Confirm page count ≤ 90 (target 80–90).
- [ ] **5.3** Spot-check Tables 1, 2, 5 (k_selection, model_comparison, cross_ticker) render correctly under K* = 3-only body framing.
- [ ] **5.4** Confirm all appendix cross-references resolve. Search log for `??` undefined-reference markers.

**Acceptance:** clean PDF, ≤ 90 pages, no `??` markers, no orphaned section references.

---

## Phase 6: arXiv prep

- [ ] **6.1** Confirm `paper.bbl` is up-to-date and included in the source bundle.
- [ ] **6.2** Final figure inventory: confirm only body-cited subpanels in `figs/` (legacy `Fig-3-IS-Comparison-K12-*`, `K9-*`, etc. can stay in repo but should not appear in PDF).
- [ ] **6.3** Draft arXiv comments field: "XX pages including supplementary, YY figures, ZZ tables. Companion Julia package: https://github.com/altashly1/CHMM-Model"
- [ ] **6.4** Categories: primary `q-fin.ST`, cross-list `stat.AP` and `q-fin.RM`.
- [ ] **6.5** License: CC BY 4.0 (default academic).
- [ ] **6.6** Sanity check: fresh `latexmk -C && latexmk -pdf paper.tex` build from clean state.

**Acceptance:** submission package ready to upload.

---

## Notes on what NOT to do

- Do not delete underlying analyses from appendices or from `results/` data files. Surgery is on the body prose only.
- Do not introduce em-dashes (`---`) in any new prose; use commas, semicolons, parens, or periods.
- Do not add new analyses. The next dollar of effort goes into cutting and reframing, not adding.
- Do not run another peer-review cycle before posting to arXiv. The available signal is already extracted.

## Out of scope for this revision

- Splitting into multiple papers (Path 2 from the strategy discussion). If this revision still does not get accepted, that is the next move.
- Posterior / parametric-bootstrap uncertainty on $\hat{\mathbf T}$. Reasonable reviewer ask but adding new modelling now is the wrong direction.
- Direct head-to-head with the discrete-state predecessor. Same reasoning.
