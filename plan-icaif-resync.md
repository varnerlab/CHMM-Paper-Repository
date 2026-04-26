# ICAIF Repos Resync Plan

**Goal.** Bring `CHMM-icaif-Model` and `CHMM-icaif-paper` up to speed with the
current trunk (`CHMM-Model` + `CHMM-paper`) so that the conference submission
reflects the polished v10 numbers and content (or a directed cut of them).

**Plan written.** 2026-04-25.
**Working directory at write-time.** `CHMM-paper` (main).

---

## State of the ICAIF repos vs. current

The ICAIF repos were both initialized with a single commit on **2026-04-21**
as a snapshot of the main paper at the v9 stage. Since then the main paper
and `CHMM-Model` have undergone substantial changes (retitle, v10 content
additions, three tiers of polishing, several numerical corrections), so the
ICAIF repos are essentially frozen at a v9-era snapshot while the trunk is
at a polished v10 with corrected numbers and several new sections.

### What changed in the main paper since the ICAIF freeze

**Title / framing**

- Retitle: "A Continuous HMM as a Digital Twin..." →
  **"A Regime-Switching Continuous HMM as a Reference Synthetic-Data
  Generator for Equity Returns: Extended Evaluation, Semi-Markov Ablation,
  and Regime-Conditional VaR"**
- Three-author block (Alswaidan / Jin / Varner) confirmed and footnoted.

**New content in the main paper not in `Paper_v9-icaif.tex`**

- VaR/ES backtest section (`var_backtest.tex`, 224 lines) with Kupiec +
  Christoffersen.
- Semi-Markov Ablation subsection (Track C1, Pareto / NB / geom sojourn
  fits).
- Regime-Conditional VaR subsection: smoother diagnostic + filter-based
  one-step-ahead (with **honest negative finding**: filter fails Kupiec).
- Extended Evaluation subsection (Track A: MMD, signature-MMD,
  discriminator AUC, leverage, aggregational kurtosis, simulation
  p-values).
- New deep / regime baselines: QuantGAN (B1), window-diffusion (B3),
  MS-GARCH (B4).
- Twelve-Generator Comparison (was Seven / Nine).
- Three-way operational split in Discussion.
- Rolling-origin / weekly-frequency robustness subsection.
- OoS Equity Price Simulation subsection (Pipeline A).
- Pre-OoS validation $K$-selection table (`tab:m8_k_selection`).

**Numerical corrections (Tier 1 polishing) that MUST sync to ICAIF**

- Discrete NJ / WJ corrected to **prior-paper hyperparameters**
  $K_{\text{disc}} = 90$, $\epsilon = 5 \times 10^{-5}$, $\lambda = 67$
  (the v9-icaif snapshot still says $\epsilon = 0.01$, $\lambda = 3$ in
  §3.3).
- $K$-sweep numbers refreshed: IS KS at $K = 18$ is **95.6%** (was 95.2),
  OoS KS **81.7%** (was 84.0), ACF-MAE **0.0509**.
- Discrete WJ 5% breach rate is **1.7%** (not 1.75).
- AUC claim corrected: window-diffusion (0.565) is closer to 0.5 than
  CHMM-t (0.607).
- Rydén-Teräsvirta-Åsbrink (1998) attribution corrected: **S&P 500**, not
  Swedish equities.
- CHMM-t IS kurtosis overshoot is **~90%** (not 126%), arithmetic fix.
- "C-vine copula at fifty assets" claim removed; truncated C-vine reframed
  as a visual reference on the same six tickers.

**Code-side changes (`CHMM-Model` vs. `CHMM-icaif-Model`)**

- New `src` files: `GARCHFamily.jl`, `MSGARCH.jl`, `Metrics.jl`,
  `SemiMarkov.jl`, `SkewEmissions.jl`.
- New driver scripts (~14): `run_track_a_metrics.jl`,
  `run_track_a_utility.jl`, `run_track_b1_quantgan.jl`,
  `run_track_b3_diffusion.jl`, `run_track_b4_msgarch.jl`,
  `run_track_c1_smchmm.jl`, `run_track_c3_*` (4 scripts),
  `run_track_c4_leverage_emission.jl`, `run_equity_price_sim.jl`,
  `run_garch_suite.jl`, `run_kupiec_mc_ci.jl`,
  `run_lr_ind_bootstrap_null.jl`, `run_ks_block_bootstrap.jl`,
  `run_mmd_fixed_bandwidth.jl`, `run_nu_shrinkage_sweep.jl`,
  `run_kdisc13_centroid_ablation.jl`, `run_skew_emissions_ablation.jl`,
  `run_k_selection_validation.jl`, `run_multiseed_headline.jl`,
  `run_rolling_and_weekly.jl`, `run_figures_ksweep.jl`.
- Discrete NJ / WJ baseline correction (V1 commit) — **affects the numbers
  in ICAIF Table 1**.
- Polishing of figure margins / generation, plus citation for the vol
  companion paper.

---

## Strategic decision before any work starts

The **arXiv-first → directed-ICAIF** plan implies the ICAIF version is a
redacted cut of the arXiv version, not a frozen v9 with numerical patches.
Two viable shapes:

| Option | Scope | Effort | When it makes sense |
| --- | --- | --- | --- |
| **A — v9-icaif sync** | Keep the existing 8-page scope; only propagate corrected numbers, retitle, attribution fixes, baseline-hyperparameter fix. | ~1-2 days | If you want a defensive backup conference submission and see ICAIF as a side channel. |
| **B — v10-icaif (directed cut)** | Re-derive the conference paper from the current arXiv draft, picking which v10 sections survive the 8-page cut. | ~1 week of focused work | If you want ICAIF to be the *flagship* short-form paper and the contribution is the three-axis evaluation, not the original digital-twin framing. |

**Recommendation.** **Option B** is the better fit for the stated arXiv-first
plan. The new content (semi-Markov, conditional-VaR with honest negative
finding, MS-GARCH baseline, three-way operational split) is exactly the
integrative-evaluation story that lands at a conference. But it is
meaningfully more work and forces a paper rewrite, not a patch.

---

## Proposed plan — `CHMM-icaif-paper`

### If Option A (sync-only)

1. **Number-patching pass** on `Paper_v9-icaif.tex`:
   - Table 1 (SPY model comparison): rerun against current
     `results/SPY/Table-T2-*` numbers; expect Discrete NJ / WJ row, IS KS
     at $K = 18$ row, ACF-MAE, $W_1$ to all shift slightly.
   - Discrete row caption / hyperparameters: replace
     $\epsilon = 0.01, \lambda = 3$ with $K_{\text{disc}} = 90$,
     $\epsilon = 5 \times 10^{-5}$, $\lambda = 67$.
   - WJ breach-rate footnote: 1.7%, not 1.75%.
2. **Attribution fixes**: Rydén 1998 → S&P 500 not Swedish; remove the v9
   phrasing of "fifty assets".
3. **Title / abstract sync**: drop "digital twin" if you want title parity
   with arXiv, or keep it and note the divergence — your call.
4. **Bib pruning** already covered in `plan-icaif-v9.md` step 2 / 3 (drop
   Cappé, add Hamilton / Bulla / Nystrup).
5. **Re-export Fig-1** and **Fig-Cross-Asset-Correlation.pdf** from current
   `CHMM-Model/run_figures.jl` (the bytes already differ between repos).
6. **Compile + page check** (8-page hard limit).

### If Option B (directed cut, recommended)

1. **Branch `paper-v10-icaif`** off the existing v9-icaif file; do not edit
   v9 in place. Plan doc supersedes `plan-icaif-v9.md`.
2. **New thesis sentence**: "A continuous HMM at $K = 18$ is a high-fidelity
   reference synthetic-data generator across three operational axes —
   distributional fidelity, unconditional VaR, and regime-conditional VaR —
   including an honest negative finding on the operational
   regime-conditional axis." This is the new spine; it is not the v9 spine.
3. **Section budget at 8 pages** (sigconf, two-column, anonymous):
   - §1 Intro: keep v9-icaif intro paras, but replace "digital twin"
     framing with reference-generator framing; add the Rydén attribution
     fix.
   - §2 Methods: keep CHMM definition + three families verbatim;
     **add 2.4 Evaluation axes** sentence introducing the three operational
     axes.
   - §3 Empirical study (compressed):
     - 3.1 Data + 3.2 $K = 18$ selection: keep v9-icaif.
     - 3.3 SPY comparison: re-do Table 1 with **current** numbers and
       **corrected discrete hyperparameters**; add MS-GARCH and one
       diffusion row (drop GRU only if space requires).
     - 3.4 Six-ticker generalization: keep, with corrected per-ticker
       numbers.
     - 3.5 Cross-asset (Pipeline B): keep verbatim, refresh numbers.
     - 3.6 **NEW — three-axis utility (~0.6 page)**: a single compact
       paragraph per axis: distributional (CHMM-t MMD), unconditional VaR
       (MS-GARCH / SM-CHMM Kupiec), conditional VaR (smoother passes,
       **filter fails — honest negative**).
   - §4 Discussion: include the three-way operational split paragraph from
     the main paper, scope, ethics.
4. **Tables**: 1 = SPY comparison (with MS-GARCH), 2 = six-ticker,
   3 = cross-asset, **new Table 4 = three-axis VaR / MMD summary**. Drop
   one only if 8-page budget breaks.
5. **Figures**: Fig-1 stylized facts + Fig-Cross-Asset Correlation, both
   regenerated. If a third figure is needed, the conditional-VaR
   breach-time strip plot is the highest-information add.
6. **References**: prune online (Cappé, Delyon), add Hamilton / Bulla /
   Nystrup, add Yu (semi-Markov), Haas-Mittnik-Paolella (MS-GARCH).
7. **Two-pass page check** at end.

---

## Proposed plan — `CHMM-icaif-Model`

The model repo is more mechanical to update because `CHMM-Model` is
canonical.

### Common to both options

1. **Hard reset of the snapshot**: rather than try to merge dozens of
   touched files, the simplest approach is to **rsync the canonical
   `CHMM-Model` over `CHMM-icaif-Model`** then prune the out-of-scope
   tracks. Concretely:
   - Sync `src/`, `test/`, `Notebooks/`, `Project.toml`, `Manifest.toml`,
     `Include.jl`, `build_new_train_oos.jl`, `fetch_oos_extended.jl`,
     `run_all_analysis.jl`, `run_baselines_and_cross_asset.jl`,
     `run_cross_asset_sim_copula.jl`, `run_diagnostics.jl`,
     `run_figures.jl`, `run_full_rebuild.jl`, `run_gru_baseline.jl`,
     `run_multi_emission_analysis.jl` from `CHMM-Model`.
   - Decide what additional `run_track_*` scripts to keep based on the
     paper option chosen.
2. **Drop `src/Pricing.jl`** (already gone in canonical; was kept "for
   compatibility" in v9-icaif and is dead weight).
3. **Update `run_full_rebuild.jl` SCRIPTS list** to match the included
   drivers.
4. **Update `README.md`**: scope section needs to reflect what is actually
   in scope for the chosen paper option; the in / out tables are currently
   lying about what's there.
5. **`plan-icaif-v9.md` → `plan-icaif-v10.md`** (Option B) or **delete**
   (Option A; the v9 plan is satisfied).

### Option-A-only

- Keep the v9-icaif track set: only the seven scripts already listed in the
  v9 README's table.
- Prune **all** `run_track_*` scripts even if rsynced; the 8-page paper does
  not cite them.

### Option-B-only

- **Keep**: `run_track_a_metrics.jl`, `run_track_a_utility.jl`,
  `run_track_b4_msgarch.jl`, `run_track_c1_smchmm.jl`,
  `run_track_c3_conditional_var.jl`. These are the drivers the v10-icaif
  paper will cite.
- **Drop**: `run_track_b1_quantgan.jl`, `run_track_b3_diffusion.jl`,
  `run_track_c2_large_universe.jl`, `run_track_c3_external_covariates.jl`,
  `run_track_c3_filter_var.jl`, `run_track_c3_time_varying_transition.jl`,
  `run_track_c4_leverage_emission.jl`, `run_equity_price_sim.jl`,
  `run_garch_suite.jl`, `run_kdisc13_centroid_ablation.jl`,
  `run_kupiec_mc_ci.jl`, `run_lr_ind_bootstrap_null.jl`,
  `run_ks_block_bootstrap.jl`, `run_mmd_fixed_bandwidth.jl`,
  `run_multiseed_headline.jl`, `run_nu_shrinkage_sweep.jl`,
  `run_rolling_and_weekly.jl`, `run_skew_emissions_ablation.jl`,
  `run_k_selection_validation.jl`, `run_figures_ksweep.jl`. These are
  full-paper-only.
- **Companion `src` files** to drop with them: `SkewEmissions.jl`. Keep
  `GARCHFamily.jl`, `MSGARCH.jl`, `Metrics.jl`, `SemiMarkov.jl`.

### Sequence (independent of option)

1. Branch `icaif-resync` in both ICAIF repos.
2. Rebuild model repo first (paper depends on regenerated figures).
3. Run `run_full_rebuild.jl` once and verify it green-passes — this
   validates that the pruned set is self-contained and surfaces any
   cross-script dependency we missed.
4. Re-export Fig-1 + Fig-Cross-Asset; copy into
   `CHMM-icaif-paper/sections/figs/`.
5. Patch / rewrite paper LaTeX per chosen option.
6. Compile, page-check, anonymity-check (no author tags, no GitHub links to
   non-anonymous repos).
7. Single squashed commit per repo with a clear message; merge to `main`.

---

## What I'd need from you to start

1. **Option A or B?** This is the load-bearing decision.
2. **Title for the conference variant** — keep v9-icaif's "digital twin" or
   move to a v10-aligned title.
3. **Anonymity policy** — current v9-icaif uses `\anonymous`; do you want
   me to also strip the cross-references to `CHMM-paper` / `CHMM-Model`
   from the ICAIF repo READMEs for the submission window?
4. **ICAIF deadline** — drives whether we can fit Option B.

Once you pick, I can lay out a tight task list and execute.
