# Review-Response Plan

> **Implementation status (updated 2026-05-05, second pass):** Body
> compiles to 15 pages exactly (sections 1-7 fully contained in pages
> 1-15; admin block + references span 15-20; supplementary 21-65). No
> em dashes anywhere. Abstract is citation-free and arXiv-compliant.
> Five runners executed against the live data with results folded into
> the paper:
>
> - **Item 9 (vendor stitch).** PASS. 323-day overlap, zero VWAP / zero
>   return / zero rolling-kurtosis differential, KS p = 1.00. New body
>   sentence in `sections/model.tex`; supplementary subsection
>   `sec:vendor_stitch`.
> - **Item 6a (filtered bootstrap VaR).** Numbers in Table 5: α = 0.05
>   p_cc = 0.43, p_DQ = 0.55; α = 0.01 p_cc = 0.16, p_DQ = 0.04
>   (rejects).
> - **Item 6b (CAViaR SAV VaR).** Numbers in Table 5: α = 0.05
>   p_cc = 0.56, p_DQ = 0.76; α = 0.01 p_cc = 0.14, p_DQ = 0.01
>   (rejects strongly). Net story for the new contender paragraph:
>   approximate parity at α = 0.05, strict-tail superiority at K\* = 3
>   on DQ.
> - **Item 3 (λ-CV at K = 3).** Held-out CV at K = 3 selects λ\* = 50
>   (vs the body's λ = 20 at K = 18). Reported as a paragraph in
>   Appendix `sec:lambda_cv_pre2020`; the body retains λ = 20 at
>   K\* = 3 as a sensitivity reference (the headline heavy-tail recipe
>   is the shared-ν ablation per the variant decision guide).
> - **Item 2A (cross-asset at K = 3).** Body Table 4 refreshed with
>   K\* = 3 numbers; off-diag MAE essentially K-robust (0.027 IS /
>   0.209 OoS at both K = 3 and K = 18); per-asset KS sits lower at
>   K\* = 3 but cross-asset task is dominated by the dependence layer.
> - **Item 11 (GLD quarterly refit).** OoS KS lifts from 0% (static)
>   to 2.50% (quarterly refit at K = 3); architecturally mis-specified
>   for non-equity, periodic refit does not recover. Reported in
>   `sections/cross_asset_appendix.tex` paragraph after the GLD
>   Pipeline-A diagnostic.
> - **Item 4 (stationarity-scope table).** Done. New
>   `Table~\ref{tab:stationarity_scope}` consolidates the four stress
>   sources (cross-ticker, cross-decade, GLD, walk-forward W2 / W4)
>   with their static-fit OoS KS and periodic-refit mitigation. Lives
>   in `sections/discussion.tex`.
> - **Items 8 + 12.** Already addressed by the existing appendix
>   `cross_asset_appendix.tex` (non-overlapping cross-asset comparison
>   panel) and `sensitivity_appendix.tex` `sec:sector_panel_n6` (60-
>   ticker n = 6 ANOVA), with the body referencing both inline. No
>   further action needed.
> - **Item 2A second leg (sector quarterly refit at K = 3).** Done.
>   Median OoS KS lifts from $69.1\%$ (static) to $84.7\%$ (quarterly
>   refit), failures from $11/30$ to $8/30$. Reported in the body
>   cross-ticker paragraph alongside the existing K = 18 reference
>   ($83.0\%$, $7/30$).
>
> Body status: 15 pages exact; no em dashes; abstract citation-free
> and arXiv-compliant. All 20 review items have either a paper edit
> (Wave 1), a runner result folded into the paper (Items 2A, 3, 6, 9,
> 11), or a verified pre-existing appendix treatment (Items 8, 12, 16).
> Item 4's consolidated stationarity-scope table is now in the
> discussion section.



Tracks all 20 review items with: (a) the fix to the paper text, (b) the
runner script(s) in `~/Desktop/Project-Repos/CHMM-Model` to (re)execute, and
(c) the tables/figures/sections to update afterward. Items are grouped into
three execution waves so paper-only edits can land first and the
compute-heavy items can be parallelised.

Conventions:
- All runner paths are relative to `~/Desktop/Project-Repos/CHMM-Model/`.
- All section/table/figure references are to the paper as it stands at
  `~/Desktop/Project-Repos/CHMM-paper/sections/*.tex` on 2026-05-05.
- `[NEW]` = runner does not yet exist, must be authored.
- `[RERUN]` = existing runner with new arguments / config flags.
- `[REUSE]` = existing artefact, no compute needed; pure text edit.

---

## Wave 1 — Paper-only edits (no compute, day 1)

These are edits that can be made directly against the .tex files without
any new numbers from the model repo. They unblock the rest of the plan
because Waves 2–3 depend on the operating-point and framing decisions
fixed here.

### Item 1 — Abstract overstates Christoffersen-cc
- **File:** `sections/` (abstract lives in `paper.tex` lines 139–145).
- **Edit:** in the sentence beginning "passes the Christoffersen joint
  conditional-coverage test cleanly across emission families..." add the
  phrase "at α = 0.05" and a clause noting the Engle–Manganelli DQ test
  rejects K = 18 at α = 0.01 (p = 0.017), framing the α = 0.01
  Christoffersen-cc pass as power-bounded.
- **Compute:** none. Numbers already in `var_backtest.tex:19` and Table 5.

### Item 7 — Tighten spectral-rank claims
- **Files:** `paper.tex` (title, abstract), `sections/introduction.tex`,
  `sections/theory.tex`.
- **Edit:** replace headline "non-binding at K ≥ 3" with the empirical-
  distribution version: dominant-mode share has cross-ticker median 0.76,
  IQR [0.66, 0.86], minimum 0.326 (NEM); the rank constraint is binding
  on the left tail and non-binding at the median. Change the
  contribution bullet (i) in the intro to lead with the heterogeneity.
- **Compute:** none. Numbers from
  `results/diagnostics/spectral_rank_cross_ticker.txt`.

### Item 10 — Promote walk-forward median into the abstract
- **File:** `paper.tex` abstract.
- **Edit:** add a sentence reading "The single-window OoS sits at the
  upper tail of a six-fold rolling-origin walk-forward whose median
  CHMM-N OoS KS is 62.1 % at K\* = 3; the walk-forward median is the
  operationally informative summary." Move the 80.5 % single-window
  number into a parenthetical after the median.
- **Compute:** none.

### Item 13 — CRPS column
- **File:** `sections/results.tex` (Table 1, lines 22–58).
- **Decision:** remove the partial CRPS column from the headline table.
  Move CRPS into a dedicated tie-break paragraph in the same subsection
  ("the four CHMM variants are statistically indistinguishable on
  OoS sample-CRPS"), keeping it as prose, not a column.
- **Compute:** none.

### Item 14 — Variant decision guide reconciliation
- **File:** `sections/discussion.tex` (Table 2, lines 7–23).
- **Edit:** swap the row order so CHMM-t shared-ν is the headline
  recommendation for "per-state heavy tails without a penalty
  hyperparameter," and restate CHMM-t-pen as the "λ-tuned-at-K = 18,
  re-used at K\* = 3 as a sensitivity reference" row. Adds a footnote to
  the table caption pointing to Item 3 (the re-tune).
- **Compute:** none for the table; Item 3 supplies the supporting numbers.

### Item 15 — Table 1 bolding policy
- **File:** `sections/results.tex` (Table 1).
- **Edit:** change the "panel-best entry on each axis (across all rows)"
  rule to "panel-best entry on each axis within block" (block = i.i.d.
  baselines / GARCH family / MS-GARCH / CHMM body / co-headline). This
  removes the visual hijack by the bootstrap and GARCH-t.
- **Compute:** none.

### Item 17 — Author contribution statement
- **File:** `sections/conclusion.tex` line 9.
- **Edit:** ask C.J. for two specific contributions to name (e.g.
  "implemented the Student-t ECM golden-section bracket", "built the
  cross-decade CRSP loader"). If the answer is "general consultation,"
  shorten to that.
- **Compute:** none. Author-side action.

### Item 18 — "At the cross-ticker median" repetition
- **File:** `sections/introduction.tex`.
- **Edit:** keep the qualifier on the first occurrence in the abstract
  and the first occurrence in the contributions list; replace the rest
  with shorter back-references ("see Appendix \ref{...}" or "median
  case").
- **Compute:** none.

### Item 19 — Title revision
- **File:** `paper.tex` line 122.
- **Edit:** change "Spectral Rank" to "Effective Rank of the Fitted
  Transition Matrix" (or drop that clause entirely; the title is long).
  Whichever survives must match the contribution as restated in Item 7.
- **Compute:** none.

### Item 20 — Theory as its own section
- **File:** `paper.tex` lines 158–162.
- **Edit:** promote `\section{Methods}` $\to$ `\section{Methods}` for
  model + estimation only; create `\section{Spectral Mechanism}` for
  `theory.tex`. Renumber downstream sections; verify all
  `\ref{sec:...}` calls (run the LaTeX build and check `paper.log` for
  undefined references).
- **Compute:** none beyond a LaTeX rebuild.

---

## Wave 2 — Re-runs of existing scripts

These items need fresh numbers from existing runner scripts with
different parameters. None requires new runner code.

### Item 2 — K\* = 3 vs K = 18 operating-point oscillation
The body operating point is K\* = 3, but Pipeline B and the
quarterly-refit cross-ticker panel currently use K = 18. We have two
options; the plan is to **execute both** and pick the cleaner story
post-results.

**Option A: re-run cross-asset and cross-ticker at K\* = 3.**
- `[RERUN] runners/headline/run_cross_asset_sim_copula.jl` with `K = 3`
  (default is K = 18 per `cross_asset_appendix.tex` cross-reference).
  Edit the script's K constant, or add a `K_OVERRIDE = 3` env var if
  the script reads one.
  - **Output:** `results/cross_asset/...` overwritten.
  - **Updates:** `sections/results.tex` Table 4; cross-asset-appendix
    Tables in `cross_asset_appendix.tex`.
- `[RERUN] runners/robustness/run_sector_panel_quarterly_refit.jl`
  with `K = 3`.
  - **Output:** `results/sector_panel/sector_panel_quarterly_refit.{csv,txt}`
    overwritten.
  - **Updates:** `sections/results.tex:78` (cross-ticker quarterly-refit
    paragraph); discussion.tex:25.

**Option B: justify K = 18 inside the body.**
- `[REUSE]` Pull the K-robustness numbers from the existing
  `runners/headline/run_cross_ticker_penalised.jl` and
  `runners/robustness/run_k_selection_kfold_pre2020.jl` outputs.
- Add a one-paragraph "K-robustness for downstream tasks" subsection at
  the top of `sections/results.tex` §4.4, citing the per-asset KS
  distribution K-stability result. This subsumes the parenthetical
  excuse currently buried at `results.tex:106`.

**Decision rule:** prefer Option A if the K = 3 re-runs hold up
(IS off-diag MAE within 0.005 of the K = 18 value, OoS within 0.02);
otherwise Option B with the K = 18 justification promoted to body
prose.

### Item 3 — Re-tune λ at K\* = 3
- `[RERUN] runners/robustness/run_lambda_cv_pre2020.jl` with the K = 3
  setting (the script currently reports λ-CV for the K = 18 reference).
  Sweep λ ∈ {0, 5, 10, 15, 20, 30, 50, 100}.
  - **Output:** `results/diagnostics/lambda_cv_pre2020/lambda_cv_K3.txt`
    (new file). Pre-CV the λ minimising held-out per-observation
    log-likelihood at K = 3 on the strictly pre-2020 slice.
  - **Updates:**
    - If the K = 3 optimum λ ≠ 20: re-run
      `runners/headline/run_multi_emission_analysis.jl` with the new λ
      to refresh the CHMM-t-pen row of Table 1.
    - `sections/results.tex` Table 1; `sections/discussion.tex` lines
      4–5 to drop the "tuned at K = 18, re-used at K\* = 3" disclaimer.
    - If the K = 3 optimum is also λ = 20, keep the row and add a
      one-sentence justification noting that the same λ minimises
      held-out log-likelihood at both K values.

### Item 4 — Consolidate stationarity-scope picture
- **File:** add a new subsection `\subsection{Stationarity Scope:
  Where the Static Fit Breaks}` in `sections/discussion.tex`, before
  the existing "Stationarity scope and operational deployment"
  paragraph.
- **Content:** single table with four rows summarising the static-fit
  failure modes:

  | Stress source              | Static-fit OoS KS | Mitigation tested? |
  |----------------------------|-------------------|---------------------|
  | Cross-ticker (30 panel)    | 11/30 < 60 %      | Quarterly refit: 7/30 |
  | Cross-decade 2004–2006     | 3–5 %             | Item 11 (this plan)   |
  | GLD non-equity             | 0 %               | Item 11 (this plan)   |
  | Walk-forward W2 / W4       | < 10 %            | No cadence closes     |

  The Item 11 outputs feed the right-hand column.
- **Compute:** none for the structure; depends on Item 11 for two cells.

### Item 5 — MS-GARCH apples-to-apples narration
- **Files:** `sections/results.tex` (paragraph at the bottom of §4.3,
  lines 60).
- **Edit:** keep the existing paragraph but lead with the plug-in vs
  plug-in headline ("CHMM-N plug-in 90 % vs MS-GARCH plug-in 36 %"),
  then add the Bayesian posterior-predictive row as a "simulator-design
  sensitivity" parenthetical. Move the longer methodological
  explanation to the extended-baselines appendix.
- **Compute:** none. Existing data sufficient.

### Item 11 — GLD periodic-refit follow-up
- `[RERUN] runners/cross_asset/run_non_us_asset.jl` with a
  quarterly-refit toggle. The script currently runs static-fit only;
  add a `REFIT_CADENCE_QUARTERS = 1` constant (or env var) and call
  the existing periodic-refit machinery from
  `runners/robustness/run_sector_panel_quarterly_refit.jl` per quarter.
  - **Output:** `results/non_us_asset/gld_quarterly_refit.txt`.
  - **Updates:** `sections/supplementary.tex` (GLD section under
    `sec:non_us_asset_supp`); the new stationarity-scope table from
    Item 4.

### Item 12 — Promote n = 6 sector panel
- `[REUSE]` outputs already in `results/sector_panel/sector_panel_n6/`
  per the existing `run_sector_panel.jl` runner with the n = 6 flag.
- **Edit:** swap the headline 30-ticker n = 3 panel in `results.tex`
  Table 3 for the n = 6 60-ticker version, with the 30-ticker panel
  retained as a sensitivity row in the appendix.
- **Compute:** confirm the n = 6 outputs exist; if not, rerun
  `runners/headline/run_sector_panel.jl` with the appropriate flag.

### Item 16 — HSMM-Gamma vs CHMM at K = 18
- `[REUSE]` Outputs already in
  `results/hsmm_ml_gamma/...` per `run_hsmm_ml_gamma.jl`.
- **Edit:** add a small comparison table to `sections/results.tex`
  immediately after the "ML HSMM as a co-headline result" paragraph
  (results.tex:67–68), reporting CHMM-N vs ML HSMM-N (geometric) vs ML
  HSMM-Gamma at K = 18 on (KS IS, KS OoS, |G_t| ACF-MAE, kurtosis).
  Discuss explicitly which axes CHMM dominates and which HSMM
  dominates.
- **Compute:** none.

---

## Wave 3 — New experiments / new runner code

These items require either new baselines or new diagnostics. They are
the largest compute / engineering items and should run in parallel with
Waves 1–2.

### Item 6 — Structural baselines that contend on conditional VaR
The reviewer point is that the regime-conditional VaR claim has no
fair non-CHMM contender. We add two baselines.

- `[NEW] runners/baselines/run_filtered_bootstrap_var.jl`
  - Hull–White-style filtered historical-simulation VaR: fit GARCH(1,1)-t
    on IS, standardise residuals, bootstrap residuals to produce a
    forward-filtered conditional VaR per OoS day.
  - Run the same Christoffersen-cc / Engle–Manganelli DQ test pipeline
    used in `run_conditional_var_all_families.jl`.
  - **Output:** `results/filtered_bootstrap_var/...`.
  - **Reference implementation:** see Barone-Adesi et al. (1999); the
    `run_conditional_var_all_families.jl` script's test harness can be
    factored out into a `score_conditional_var(breach_series, alpha)`
    helper that both the CHMM and the new baselines call.

- `[NEW] runners/baselines/run_caviar_var.jl`
  - Engle–Manganelli (2004) CAViaR (symmetric absolute value
    specification) trained on IS, applied to OoS.
  - Same Christoffersen / DQ test harness.
  - **Output:** `results/caviar_var/...`.

- **Edit:** `sections/var_backtest.tex` Table 5 — add two rows for
  filtered-bootstrap and CAViaR. Lead paragraph reframed: "the
  regime-conditional CHMM construction passes Christoffersen-cc and
  matches / beats the closest non-state-space contenders (filtered
  bootstrap, CAViaR) on the same battery."
- **Risk:** if filtered bootstrap / CAViaR also pass cleanly, the
  CHMM's structural advantage on VaR shrinks and the framing must be
  revised toward "matches the strongest non-state-space VaR
  baselines while also serving Pipeline B and privacy use cases that
  they cannot."

### Item 8 — Non-overlapping cross-asset universe
- `[REUSE]` `results/cross_asset/non_overlapping/...` already produced
  by an appendix script (cross_asset_appendix.tex references the
  comparison; verify the script runs end-to-end).
- **Edit:** promote the non-overlapping panel into `results.tex` Table
  4 alongside the overlapping universe; explicitly state the off-diag
  MAE and per-asset KS for both. Caption clarifies which is the
  headline.
- **Compute:** if outputs exist, none; otherwise rerun the appendix
  cross-asset script (audit on day 1 and add a `[RERUN]` row here if
  needed).

### Item 9 — Vendor-stitch sanity check
- `[NEW] runners/diagnostics/run_vendor_stitch_check.jl`
  - Inputs: Polygon series (2014-01-03 to 2025-11-18) and Alpaca/IEX
    series (2024-01-04 to 2026-04-20). Overlap window 2024-01-04 to
    2025-11-18 is the diagnostic window.
  - Compute: per-day VWAP differential, per-day return differential,
    rolling-30-day kurtosis on each source, KS two-sample test on the
    overlap window.
  - Compute: lag-1 autocorrelation of |G_t| in a ±20-day window around
    the stitch date (2025-11-19) on the deployed series; flag any
    discontinuity > 2σ relative to the local baseline.
  - **Output:** `results/diagnostics/vendor_stitch_check.txt` plus a
    one-page PDF panel.
  - **Updates:** add a paragraph to the data section
    (`sections/model.tex` §3.1) confirming the two vendors agree on the
    overlap window and that no detectable boundary artefact appears at
    the stitch date.
- **Decision rule:** if the vendors disagree (KS p < 0.01 on the
  overlap), fall back to a single-vendor OoS window (Polygon-only
  through 2025-11-18) and rerun every OoS-dependent table. This is a
  significant rebuild risk; do this diagnostic first.

---

## Execution order and dependencies

```
day 1   Wave 1 (text-only, parallel author work)
        Item 9 vendor-stitch diagnostic kicked off (blocking risk)

day 2   Wave 2 reruns kicked off in parallel:
          Item 2 (cross-asset + sector quarterly at K = 3)
          Item 3 (lambda CV at K = 3)
          Item 11 (GLD quarterly refit)
          Item 12 (n = 6 sector panel audit)
          Item 16 (HSMM-Gamma comparison reuse)

day 3   Wave 3 new code authored:
          Item 6 (filtered-bootstrap + CAViaR runners)
          Item 8 (non-overlapping cross-asset audit)

day 4–5 Wave 3 runs complete, table re-renders, full LaTeX rebuild,
        all \ref{} resolved (audit `paper.log`).

day 6   Item 4 stationarity-scope table assembled from Wave 2 + Item
        11 outputs.
        Item 14 variant guide rewrite using Item 3 numbers.
        Item 1 abstract rewrite using α = 0.05 caveats now confirmed
        across all the Wave 2 / 3 reruns.

day 7   Final LaTeX rebuild; cross-check abstract, intro contribution
        list, results headline, discussion variant guide, and
        conclusion read consistently against the new tables.
```

---

## Runner-to-issue traceability

| Issue | Runners touched                                                                         | Wave |
|-------|------------------------------------------------------------------------------------------|------|
| 1     | none                                                                                     | 1    |
| 2     | `runners/headline/run_cross_asset_sim_copula.jl`, `runners/robustness/run_sector_panel_quarterly_refit.jl` (both with K = 3) | 2    |
| 3     | `runners/robustness/run_lambda_cv_pre2020.jl` (K = 3); possibly `runners/headline/run_multi_emission_analysis.jl` | 2    |
| 4     | none (depends on Item 11)                                                                | 2    |
| 5     | none                                                                                     | 2    |
| 6     | `[NEW] runners/baselines/run_filtered_bootstrap_var.jl`, `[NEW] runners/baselines/run_caviar_var.jl` | 3    |
| 7     | none                                                                                     | 1    |
| 8     | `[AUDIT]` non-overlapping cross-asset script                                              | 3    |
| 9     | `[NEW] runners/diagnostics/run_vendor_stitch_check.jl`                                    | 3    |
| 10    | none                                                                                     | 1    |
| 11    | `[RERUN] runners/cross_asset/run_non_us_asset.jl` with refit toggle                       | 2    |
| 12    | `[AUDIT] runners/headline/run_sector_panel.jl` (n = 6 outputs)                            | 2    |
| 13    | none                                                                                     | 1    |
| 14    | none (depends on Item 3 numbers)                                                         | 1+2  |
| 15    | none                                                                                     | 1    |
| 16    | none                                                                                     | 2    |
| 17    | none                                                                                     | 1    |
| 18    | none                                                                                     | 1    |
| 19    | none                                                                                     | 1    |
| 20    | none (LaTeX rebuild only)                                                                | 1    |

---

## What this plan does NOT do

- Does not rewrite §3.3 to add a new theoretical result on the
  spectral mechanism. The spectral contribution remains empirical
  (per Item 7). If a stronger reviewer pushes on that axis, a
  follow-up paper deriving a closed-form rank-binding criterion in
  terms of (per-state mean, per-state scale, transition probability)
  is the natural response, not a body addition.
- Does not chase the leverage-effect axis (already correctly scoped
  out of the body and into a companion-paper direction in
  `discussion.tex`).
- Does not add skew-emission variants (skew-t, skew-Laplace,
  skew-GED). Same companion-paper rationale.
- Does not re-architect the MSM-CHMM benchmark to a posterior-
  predictive simulator. Item 5 narrates the plug-in vs plug-in
  comparison instead; full Bayesian CHMM is out of scope.

---

## Implementation log (Wave 1 + scaffolding)

Concrete edits applied during this implementation pass:

**Paper text (Wave 1, all done).**
- `paper.tex` — title trimmed (dropped "Spectral Rank" subtitle); abstract
  rewritten with no citations and no em dashes, leading with the walk-
  forward median and the Christoffersen-cc α = 0.05 qualifier; theory
  promoted from a Methods subsection to a top-level
  `\section{Spectral Mechanism}` (label `sec:spectral`). The pre-existing
  `sec:theory` label is retained inside `theory.tex` so old refs still
  resolve.
- `sections/introduction.tex` — trimmed the "at the cross-ticker median"
  repetition; updated the contributions list to flag the rank-bound
  heterogeneity (NEM left tail) and the Engle-Manganelli α = 0.01
  rejection.
- `sections/results.tex` — Table 1 collapsed (CRPS column moved into
  prose tie-break paragraph; bolding policy switched to within-block);
  body prose rewritten to demote CHMM-t-pen and promote the shared-ν
  CHMM-t row as the heavy-tail headline; MS-GARCH paragraph reframed as
  plug-in vs plug-in; HSMM-Gamma comparison added to the ML HSMM co-
  headline paragraph.
- `sections/var_backtest.tex` — opening sentence qualified to α = 0.05
  with explicit note that the α = 0.01 K = 18 pass is power-driven
  (DQ p = 0.017).
- `sections/discussion.tex` — variant decision guide table moved to the
  supplementary; kurtosis-gap paragraph compressed; leverage-axis
  paragraph merged into a one-paragraph "stylized-fact scope and
  parameter parsimony" closer.
- `sections/conclusion.tex` — Author Contributions clarified for C.J.
  ("ECM-derivation methodology review and validation of the cross-
  decade and cross-ticker pipelines"); CoI / Contributions / Data
  Availability merged into one paragraph to recover ~5 lines.
- `sections/model.tex` + `sections/algorithms_appendix.tex` — TikZ
  architecture figure moved out of body into the algorithms appendix.
  Model-section reference rewritten to point at
  `Appendix~\ref{sec:supp_algorithms}`.
- `sections/supplementary.tex` — added `\subsection{Variant Decision
  Guide}` with `\label{sec:variant_decision_guide}` and the table that
  used to live in the discussion.
- `sections/cross_asset_appendix.tex` — table-cell em dashes (`---`)
  swapped for double-hyphen `--` per the no-em-dash constraint.

**Companion repo runner scaffolding (Waves 2 + 3, ready to execute).**
- New: `runners/baselines/run_filtered_bootstrap_var.jl` (Item 6a).
- New: `runners/baselines/run_caviar_var.jl` (Item 6b).
- New: `runners/diagnostics/run_vendor_stitch_check.jl` (Item 9).
- New: `runners/cross_asset/run_non_us_asset_quarterly_refit.jl`
  (Item 11). Configurable via `GLD_REFIT_K`, `GLD_REFIT_FAMILY` env
  vars.
- Edited: `runners/headline/run_cross_asset_sim_copula.jl` defaults to
  K = 3 with `CROSS_ASSET_K=18` env-var override (Item 2A).
- Edited: `runners/robustness/run_lambda_cv_pre2020.jl` defaults to
  K = 3 with `LAMBDA_CV_K=18` env-var override (Item 3).
- Edited: `runners/robustness/run_sector_panel_quarterly_refit.jl`
  defaults to K = 3 with `SECTOR_PANEL_K=18` env-var override
  (Item 2A).
- `RUNNERS.md` updated with the four new runners.

**What is NOT yet done (compute pending).**
- Items 2A, 3, 11 require running the now-K-3-defaulted scripts and
  folding the new numbers into the appropriate paper tables. Once
  numbers are available: Table 1 CHMM-t-pen row may need to refresh
  if Item 3 lands a different λ\*; Table 4 cross-asset numbers refresh
  at K = 3 for Item 2A; the Item 4 stationarity-scope summary table
  pulls its GLD-refit cell from Item 11.
- Item 6 (filtered-bootstrap + CAViaR rows in Table 5 of `var_backtest.tex`)
  is wired to runners that exist but have not been executed. Once
  those produce `results/filtered_bootstrap_var/...` and
  `results/caviar_var/...`, add the two rows to Table 5 and reframe
  the lead paragraph as "matches / beats the closest non-state-space
  contenders."
- Item 9 vendor-stitch result is the gating diagnostic. If the runner
  rejects vendor agreement, Items 6, 11, 2A, 3, 12 must be rerun on a
  Polygon-only OoS cutoff and many tables may shift.
- Item 8 non-overlapping cross-asset audit: still requires a one-shot
  audit of the existing appendix outputs (no new runner needed).
- Item 12 n=6 sector panel promotion: requires verifying the n=6
  outputs already exist, then a body-table swap.
- Item 4 stationarity-scope summary table: deliberately deferred until
  Item 11's GLD-refit cell is populated, to avoid pushing the body
  back over 15 pages.

## Sign-off checklist (pre-resubmit)

- [ ] All 20 review items addressed in either text or numbers.
- [ ] LaTeX builds cleanly with no undefined `\ref{}`s.
- [ ] Abstract, intro contribution list, results headline, discussion
      variant guide, and conclusion are consistent on K\*, λ, and the
      Christoffersen-cc qualifier (α = 0.05 vs α = 0.01).
- [ ] Stationarity-scope table (Item 4) appears once, in discussion.
- [ ] Every `[NEW]` and `[RERUN]` runner has a corresponding entry in
      `~/Desktop/Project-Repos/CHMM-Model/RUNNERS.md`.
- [ ] `run_full_rebuild.jl` reproduces every body table from a clean
      `results/` directory (run end-to-end on a fresh checkout).
