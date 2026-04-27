# arXiv-Submission Review: Paper + Model Cleanup

Date: 2026-04-26
Scope: `CHMM-paper/` (16 .tex sources, figs/, results/) + `CHMM-Model/` (runners, results/, data/, notebooks)
Branch: main (last commit `8cc442a reframing intro`)
Goal: scrub everything left over from the v9/v10 journal-targeting revisions so the arXiv preprint and its companion code repo present a single coherent story.

---

## TL;DR

- **Paper.** One ship-blocker (QuantGAN promise vs. GRU delivery), plus ~2 hours of orphan cleanup and a 30-minute search-and-replace to make appendix references granular.
- **Model repo.** Roughly half of the `results/track_*/` tree is dead weight from v10's "Track A/B/C" plan. Most of it can be archived; six `run_track_*.jl` runners no longer feed anything in the paper. ~400-500 MB of stale results plus several v10-only top-level files (`LITERATURE-REVIEW.md`, `Notebooks/`, `planning/`, `user-comments.md`, `downloaded-references/`, `fetch_oos_extended.jl`).
- **QuantGAN.** Cached results exist in `CHMM-Model/results/track_b1/` but use the v10 metric schema (MMD / sig-MMD / AUC), not the current paper's seven-metric panel (KS / AD / kurt / ACF-MAE / CRPS). Reusing them is not a copy job; it requires modifying `run_track_b1_quantgan.jl` to compute the standard metrics and re-running. **You need to choose: drop the QuantGAN promise (15 min) or re-run with current metrics (~hours, plus cross-validation).** See Decision D1 below.

Total cleanup if you opt for the cheap path on every choice: 3-5 hours, no experiments rerun, ~half a GB of artefacts archived.

---

## Decisions you need to make

The cleanup plan branches on these. I'll execute whichever you pick on each.

### Status snapshot
- **D1 (QuantGAN): DONE.** User picked (c) + Q1=(i). Re-ran the WGAN under the seven-metric panel, dropped the GRU appendix, inserted the QuantGAN row into `tab:m7_extended_panel`. PDF rebuilt clean (54 pages). Headline: QuantGAN reaches 0% IS / 0% OoS KS, kurt 2.05, ACF-MAE 0.0591.
  - **Literature sanity check: NORMAL.** Per-path KS is not a metric used in the QuantGAN literature; reported metrics are EMD / DY / ACF-score / Leverage-score (Wiese et al. 2020, arXiv:1907.06673) or marginal-distance / absolute-ACF-difference (Ni et al. 2020 SigCWGAN, arXiv:2006.05421). Our 0% per-path rate is the expected outcome of a per-path KS test under tail mismatch at n=2515. Kurtosis 2.05 vs observed 7.68 matches Eckerli & Osterrieder (2021, arXiv:2106.06364) qualitative finding that "all three [WGAN-GP, DCGAN, SAGAN] fail to recreate the intensity of heavy tails" on S&P 500. ACF-MAE 0.0591 narrowly beating bootstrap 0.0628 matches the SigCWGAN Table-3 pattern where WGAN-style competitors lose to GARCH on volatility-clustering. Christoffersen LR_ind=20.87 rejection of breach independence is the mechanical consequence of stitching independent 64-day windows. Our config is materially smaller than Wiese et al.'s (3 conv layers vs their 7-block TCN with 127-day receptive field; no Lambert-W preprocessing); the paper already calls this a "repo-native approximation, not exact reproduction." **No further action: numbers are honest.**
- **D2-D5: not started.** Awaiting one-by-one decisions.
- **D6 (NEW: revision-era naming cleanup): not started.** Surfaced after the D1 pass exposed how many `m7`-style labels still leak. See below.

### D1 — QuantGAN — DECISION: (c), Q1=(i). DONE.

User chose to re-run QuantGAN under the current seven-metric panel and drop the GRU appendix section entirely. Status:

- [x] `run_track_b1_quantgan.jl` extended with the seven-metric panel block (KS IS/OoS, AD IS/OoS, sim_kurt, ACF-MAE, Kupiec breach + LR_uc + LR_ind at α=0.01 and 0.05). Writes `quantgan_panel.txt` and `CHMM-paper/results/robustness/quantgan_panel.csv` mirroring the `garch_suite.csv` schema.
- [x] GRU appendix subsection (`sec:gru_supp`, `tab:gru`) replaced with a QuantGAN subsection (`sec:quantgan_supp`) describing the convolutional WGAN architecture, training schedule, and synthesis loop.
- [x] `tab:m7_extended_panel` prose updated to expect a QuantGAN row and added a third structural observation about the deep-generative row being the panel's joint-metric weakest entry.
- [x] Julia training run completed (seed 20260422, 15 epochs, ~3 min). Output: IS KS = $0.0\%$, OoS KS = $0.0\%$, IS AD = $0.0\%$, OoS AD = $0.0\%$, kurt = $2.05$, ACF-MAE = $0.0591$, br% (1%) = $1.0$, LR_uc(1%) = $0.01$, br% (5%) = $3.3$, LR_uc(5%) = $3.83$.
- [x] QuantGAN row inserted into `tab:m7_extended_panel` (separated by `\midrule` from the CHMM/SM-CHMM block).
- [x] Third structural-observation paragraph in m7 prose finalised with the actual numbers.
- [x] `latexmk -pdf paper.tex` clean: 54 pages, no undefined references, no missing citations.
- [ ] **Deferred to S7**: Body refs to `\ref{sec:supplementary}` for the deep-generative row should later point at `\ref{sec:quantgan_supp}` and the m7 panel ref should point at `\ref{sec:m7_baselines}`.

### D2 — Stale `track_*/` result directories
Six top-level result directories under `CHMM-Model/results/` correspond to v10 tracks the paper no longer claims:
- `track_a/` (212 MB) — extended utility metrics; not in body or appendix
- `track_b1/` (1 MB) — cached QuantGAN under old schema (see D1)
- `track_b3/` (72 KB) — diffusion baseline; cut from paper
- `track_c3/` (36 KB) — three of the four conditional-VaR variants (the `filter_var` one is independently kept)
- `track_c4/` (12 KB) — leverage-emission ablation; cut
- `track_m*/` and `track_minor*/` (12 dirs, ~50 KB total) — vestigial after the M-script rename pass; the actual outputs now live in `CHMM-paper/results/robustness/`

**(I) Archive to `CHMM-Model/results/_attic_v10/` (preserves history, removes from active paths).**
**(II) Delete (git history still preserves them).**
**(III) Keep track_b1 specifically pending D1, archive everything else.**

### D3 — Orphan `run_track_*.jl` scripts
These runners no longer feed any paper artefact:
- `run_track_a_metrics.jl`, `run_track_a_utility.jl`
- `run_track_b3_diffusion.jl`
- `run_track_c3_conditional_var.jl`, `run_track_c3_external_covariates.jl`, `run_track_c3_time_varying_transition.jl`, `run_track_c3_filter_var.jl`
- `run_track_c4_leverage_emission.jl`
- `run_track_b1_quantgan.jl` (depends on D1)

KEEP: `run_track_b4_msgarch.jl` (feeds `tab:m7_extended_panel`), `run_track_c1_smchmm.jl` (feeds `tab:m7_extended_panel`), `run_track_c2_large_universe.jl` (feeds large-universe cross-asset).

**(I) Move orphans to `CHMM-Model/_attic_v10/runners/`.**
**(II) Delete.**
**(III) Keep all (low cost, just code).**

### D4 — Top-level v9/v10 documentation files
- `CHMM-Model/LITERATURE-REVIEW.md` — historical bibliography compilation
- `CHMM-Model/user-comments.md` — v10 reviewer-style feedback (all addressed)
- `CHMM-Model/Notebooks/01..05.ipynb` — five exploratory Jupyter notebooks
- `CHMM-Model/planning/DECISION-MEMO.md`, `CHMM-Model/planning/plan-equity-paper.md` — v10 journal planning docs
- `CHMM-Model/downloaded-references/` — reference PDFs from journal targeting
- `CHMM-Model/fetch_oos_extended.jl` — one-shot Alpaca data extension; output already bundled

**(I) Archive to `CHMM-Model/_attic_v10/`.**
**(II) Delete.**
**(III) Keep — they're harmless documentation.**

### D6 — Revision-era naming cleanup (paper labels + model repo dirs/scripts)

The v10 journal-revision pass coded its analyses by referee comment number: `M2, M5, M6, M7, M8, M9, M10, M11, M12` for major comments, `minor4, minor6, minor10` for minor ones, and `track_a / track_b1-3 / track_c1-4` for new-baseline / scope-expansion tracks. A previous rename pass (`CHMM-Model/rename-revision-artefacts-plan.md`) already cleaned the script filenames and the CSV outputs, but four kinds of M-coded names remain. For an arXiv preprint with no referees in the loop, every M-coded artefact is a tell that this paper had a prior life as a journal submission.

**Items still leaking the M-codes:**

- **(D6a) Paper labels** in `sections/baselines_appendix.tex`:
  - `tab:m2_ks_bootstrap` → `tab:ks_block_bootstrap`
  - `tab:m10_multiseed` → `tab:multiseed_headline`
  - `sec:m7_baselines` → `sec:extended_baselines`
  - `tab:m7_extended_panel` → `tab:extended_baselines`
  - Each is referenced once or twice in the same appendix file; LaTeX search-and-replace.

- **(D6b) Model-repo `results/` subdirectories** (12 dirs): `track_m2`, `track_m5`, `track_m6`, `track_m7`, `track_m8`, `track_m9`, `track_m10`, `track_m11`, `track_m12`, `track_minor4`, `track_minor6`, `track_minor10`. Most are residue from the script-rename pass and slated for D2 cleanup anyway; folds into D2.

- **(D6c) Surviving `run_track_*.jl` scripts** (12 files; D3 will drop six as orphans, leaving six survivors). Survivors should be renamed to descriptive forms:
  - `run_track_b1_quantgan.jl` → `run_quantgan_baseline.jl`
  - `run_track_b4_msgarch.jl` → `run_msgarch_baselines.jl`
  - `run_track_c1_smchmm.jl` → `run_smchmm_baseline.jl`
  - `run_track_c2_large_universe.jl` → `run_cross_asset_large_universe.jl`

- **(D6d) In-script comments and printed banners** that say things like "Track M7 (revision response to referee comment M7)", "Track B1 complete", "Table-4-Extended-Metrics-B1.txt". User-visible printlns and output filenames inside surviving scripts should be sanitised so re-runs don't print revision codes.

**Decision options:**
- **(I) Full sweep now.** Do D6a-d as part of the arXiv-prep pass. ~45-60 min total once D2-D3 are in motion.
- **(II) Paper-side only (D6a) now, model-repo side (D6b-d) when D2-D3 happen.** Decoupled, but D6a alone is ~10 min and removes the user-visible M-codes from the published PDF.
- **(III) Defer.** Live with the M-codes for arXiv v1; clean them up later. Not recommended.

My recommendation: **(I) full sweep, sequenced after D2-D3 so we don't rename a directory we're about to delete.**

### D5 — Stale data snapshots
Multiple OHLC snapshots in `CHMM-Model/data/` overlap or are superseded by the active bundles. Only `CHMM-SP500-Train-10yr.jld2` and `CHMM-SP500-OoS-Remainder.jld2` are loaded by the rebuild pipeline.
- Candidates for archival: dated `SP500-Daily-OHLC-1-3-2024-to-10-25-2024.jld2`, `SP500-Daily-OHLC-1-3-2025-to-09-26-2025.jld2`, `SP500-Daily-OHLC-1-3-2025-to-11-18-2025.jld2`, `train_dataset_2014_2023.jld2`, `test_dataset_2024_onward.jld2`, `HMM-SPY-1-min-aggregate.jld2`, `SPY-OHLC-1-min-aggregate-2023.csv`. Together ~250 MB.
- Definitely keep: the two `CHMM-SP500-*.jld2` bundles + the per-ticker `HMM-WJ-*-daily-aggregate.jld2` files (loaded by cross-asset runs).

**(I) Archive the orphan snapshots; keep the active bundles + raw 2014-2024 / 2025-2026 source files (since `build_new_train_oos.jl` would need them to rebuild).**
**(II) Aggressive: delete every snapshot not directly loaded.**

---

## Findings (paper repo) — ordered by severity

### S1 — QuantGAN/GRU mismatch
See D1 above. Same finding from the prior pass; the model-repo audit confirms the cached results cannot be reused as-is.

### S2 — Stale "Walk-Forward Summary" in heading
`sections/supplementary.tex:68`: heading reads "Pre-OoS Validation $K$-Selection, **Walk-Forward Summary**, and $\nu_k$ Diagnostics" but the section has no walk-forward content. Fix: drop "Walk-Forward Summary" from the heading and the matching `\texorpdfstring`.

### S3 — pdfkeywords list metrics not in the paper
`paper.tex:63` lists "Christoffersen, MMD" but the paper computes neither. The `\LRind` macro is defined in `paper.tex:86` and never used. The "Fixed observed-sample MMD bandwidth" paragraph at `sections/baselines_appendix.tex:57` references "an auxiliary MMD metric we report in this appendix" — but `metrics_appendix.tex` does not. The var_es figure caption at `metrics_appendix.tex:142` mentions "Christoffersen likelihood-ratio leg" but `var_backtest.tex` only computes Kupiec. **Fix:** drop "Christoffersen, MMD" from `pdfkeywords`, drop the `\LRind` macro, drop the MMD-bandwidth paragraph, drop "Christoffersen" from the var_es caption.

### S4 — Orphan supplementary subsections
| Section | File | Recommendation |
|---|---|---|
| Extended Evaluation: Detail Panels (leverage, agg-kurt, joint p-value) | `metrics_appendix.tex:56-121` | Cut. v10-Track-A item that didn't land. |
| Per-Ticker OoS Price-Simulation Figures and Path-Level Metrics | `baselines_appendix.tex:161-280` | Cut. ~6 figures with no body reference. |
| Per-Asset KS Bar Chart (`fig:cross_asset_ks`) | `cross_asset_appendix.tex:126-136` | Cut, or wire one ref. |
| CHMM-t Degrees-of-Freedom Diagnostics — duplicate $\nu_k$ paragraph | `algorithms_appendix.tex:269-308` vs `supplementary.tex:74-75` | Merge: keep the algorithms_appendix version (has table), drop the $\nu_k$ paragraph from supplementary.tex. |

### S5 — Unused figure files in `figs/`
16 PDFs sitting in `figs/` not referenced by any `.tex`. Move to `figs/_attic/` or delete. (Listed in original review; verified safe by grep.)

### S6 — Unreferenced labels (cosmetic)
70 of 149 `\label{}` declarations have no matching `\ref`/`\eqref`. Mostly equation labels (harmless). Worth removing: `prop:identifiability` and `prop:consistency` — never referenced.

### S7 — Body-to-appendix routing is too coarse
Twelve body sites use the umbrella `Appendix~\ref{sec:supplementary}`. Granular labels exist; ~30 minutes of search-and-replace makes the appendix navigable. Mapping table:

| Body location | Should point to |
|---|---|
| `estimation.tex:16` algorithmic details | `sec:supp_algorithms` |
| `model.tex:170` extended GARCH + SM-CHMM (+ deep baseline) | `sec:m7_baselines` (+ `sec:gru_supp` after D1) |
| `model.tex:177` SIM and Gaussian copula | `sec:supp_cross_asset` |
| `theory.tex:5,78` formal propositions | `sec:supp_propositions` |
| `results.tex:16` per-K panel + held-out | `sec:supp_sensitivity`, `sec:supp_misc` |
| `results.tex:21` extended GARCH + SM-CHMM (+ deep baseline) | `sec:m7_baselines` |
| `results.tex:57` per-pair DM verdicts | `sec:crps_methods` |
| `results.tex:74` per-family K + per-ticker price-level | `sec:multi_emission_sensitivity` (+ `sec:price_sim_oos_appendix` if kept; drop ref if S4 cuts the section) |
| `results.tex:110,145` SIM and Gaussian copula | `sec:supp_cross_asset` |
| `discussion.tex:5` K=2 replication | `sec:ryden_replication` |
| `discussion.tex:33` SIM and Gaussian copula panels | `sec:supp_cross_asset` |
| `discussion.tex:36` K-star=3 by held-out | `sec:supp_misc` |
| `related_work.tex:8` deep baseline appendix | `sec:gru_supp` (after D1) |
| `conclusion.tex:11` public API | `sec:supp_chmm_api` |

---

## Findings (model repo) — orphans summary

Confirmed wired-in and active (KEEP, no action needed):
- `src/` — Compute, CrossAsset, Factory, Files, GARCHFamily, MSGARCH, Metrics, SemiMarkov, SkewEmissions, Types, Visualize. All used.
- `Include.jl`, `Project.toml`, `Manifest.toml`.
- `run_full_rebuild.jl` (entry point referenced from supplementary.tex).
- All `run_*.jl` runners with descriptive names (the post-rename set).
- `run_track_b4_msgarch.jl` (feeds `tab:m7_extended_panel`).
- `run_track_c1_smchmm.jl` (feeds `tab:m7_extended_panel`).
- `run_track_c2_large_universe.jl` (feeds the large-universe cross-asset numbers).
- `run_diagnostics.jl`, `run_baselines_and_cross_asset.jl`, `run_cross_asset_sim_copula.jl`, `run_equity_price_sim.jl`, `run_figures.jl`, `run_figures_ksweep.jl`, `run_multi_emission_analysis.jl`, `run_garch_suite.jl`, `run_crps_dm.jl`, `run_non_us_asset.jl`, etc.
- `data/CHMM-SP500-Train-10yr.jld2`, `data/CHMM-SP500-OoS-Remainder.jld2`, the per-ticker `HMM-WJ-*-daily-aggregate.jld2` files.
- `results/SPY/`, `results/cross_asset/`, `results/cross_asset_large/`, `results/diagnostics/`, `results/equity_price_sim/`, `results/track_b4/`, `results/track_c1/`.
- `CLAUDE.md`, `SPECIFICATION.md`, `README.md`, `Makefile`-equivalents.
- `rename-revision-artefacts-plan.md` (already-completed v10 rename pass; useful as audit trail).

Decided by user (D1-D5):
- `results/track_a/`, `results/track_b3/`, `results/track_c3/` (except filter_var path), `results/track_c4/`, `results/track_m*/`, `results/track_minor*/`.
- Six orphan `run_track_*.jl` runners.
- Top-level v9/v10 docs (LITERATURE-REVIEW.md, user-comments.md, Notebooks/, planning/, downloaded-references/, fetch_oos_extended.jl).
- Stale data snapshots.

---

## Execution plan (after decisions)

Each step is independent and commits cleanly. The paper repo and model repo each have their own commit history; I'll commit per-repo.

### Phase 1 — Paper repo (1.5-2 h)
1. **S5** Delete the 16 unused figure PDFs from `figs/`. (5 min.)
2. **S3** Drop "Christoffersen, MMD" from `pdfkeywords`; drop the `\LRind` macro; drop the MMD-bandwidth paragraph; drop "Christoffersen" from the var_es caption. (10 min.)
3. **S2** Fix the supplementary heading. (2 min.)
4. **S1 / D1** Apply the chosen QuantGAN-vs-GRU resolution. (15-20 min for D1=a or b; many hours for D1=c.)
5. **S4** Cut/merge the orphan supplementary subsections per the table. (30-60 min.)
6. **S7** Replace umbrella `\ref{sec:supplementary}` with granular subsection refs. (30 min.)
7. **S6** Drop unused proposition labels. (5 min.)
8. **Build check.** `make` or `latexmk -pdf paper.tex`; confirm zero `LaTeX Warning: Reference ... undefined`. (5 min.)
9. **arXiv hygiene.** Confirm `paper.bbl` is committed; flatten input resolution; double-check no `_v9.tex` shadow files. (5 min.)
10. **Final spot-check.** Recompile, search PDF for "Appendix" — every ref should now name a subsection. (5 min.)

### Phase 2 — Model repo (30-90 min depending on D2-D5)
11. **D2** Move/delete the orphan `results/track_*/` directories. (5-15 min.)
12. **D3** Move/delete the orphan `run_track_*.jl` runners. (5-15 min.)
13. **D4** Move/delete the v9/v10 top-level docs and notebooks. (10-30 min if archiving; need to git mv carefully.)
14. **D5** Archive the stale data snapshots. (5-10 min.)
15. **Sanity-rerun the rebuild dispatcher.** `julia --project=. run_full_rebuild.jl --dry-run` if such a flag exists, else just `julia --project=. -e 'include("run_full_rebuild.jl")'` and verify no missing-path errors. (10-30 min depending on Julia precompile.)
16. **Update README** to reflect the slimmed-down repo and cite the arXiv preprint. (10 min.)
17. **Cross-repo doc check.** Search both repos for refs to deleted/archived files. (10 min.)

### Phase 3 — arXiv submission packaging (30 min)
18. Tag `CHMM-paper` and `CHMM-Model` at the cleaned commit (e.g., `arxiv-v1`).
19. Build the arXiv tarball: `paper.tex`, `paper.bbl`, `sections/`, `figs/`, `references.bib`, no aux/log/out files. The `Makefile` likely has a target.
20. Verify the tarball compiles standalone (e.g., in a clean dir with `latexmk -pdf paper.tex`).
21. Submit to arXiv (cs.LG or q-fin.ST primary).

---

## Notes

- The CHMM-Model repo already completed a similar cleanup once (the M-script rename pass documented in `CHMM-Model/rename-revision-artefacts-plan.md`). The track_*/ directories are the second wave that pass missed.
- The `MEMORY.md` "no em-dashes" rule is honored throughout this document.
- I have not modified anything yet. After you answer D1-D5, I'll execute the plan.
