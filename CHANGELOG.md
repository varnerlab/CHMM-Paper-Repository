# Paper Changelog

Accumulating record of substantive changes across paper versions.
Newest version on top. For the full paper content, see `Paper_vN.tex` and
the matching `sections/*_vN.tex` files.

---

## v10 (in progress, scaffolded 2026-04-22)

**Scope.** Upgrade pass from v9 to top-tier synthetic-data-generator paper.
Scaffolded from v9 on 2026-04-22 by copying `Paper_v9.tex` to `Paper_v10.tex`,
duplicating all `sections/*_v9.tex` to `sections/*_v10.tex`, and copying
`References_v9.bib` to `References_v10.bib`. The v10 root now points at the
v10 section files and v10 bib. v9 joins the frozen reference snapshot set
alongside v7 and v8.

### Planned content additions (tracked in `CHMM-Model/plan-equity-paper.md`)

1. Retitle to the generator thesis: "A Regime-Switching Continuous HMM as
   a Reference Synthetic-Data Generator for Equity Returns."
2. New Extended Evaluation subsection covering Track A (MMD, signature-MMD,
   discriminator AUC, leverage effect, aggregational kurtosis, simulation
   p-values, Kupiec + Christoffersen LR).
3. New Semi-Markov Ablation subsection (Track C1) framed as a
   risk-calibration-not-marginal-fidelity upgrade.
4. New Conditional VaR subsection (Track C3a) where flat CHMM-t with
   Viterbi-decoded conditional VaR passes both Kupiec and Christoffersen
   cleanly at 1 % and 5 % on OoS.
5. New baselines paragraphs for QuantGAN (B1), diffusion (B3), and
   MS-GARCH (B4).
6. New three-way operational split in Discussion: flat CHMM-t for
   distributional fidelity, MS-GARCH / SM-CHMM for unconditional VaR,
   flat CHMM-t + Viterbi for conditional VaR.
7. Explicit DiscreteNJ / DiscreteWJ 5 % VaR Kupiec failure callout
   (LR_uc 16.81) against the `alswaidan2026hybrid` baseline.

### What is unchanged from v9 at scaffold time

- Author list: Alswaidan, Jin, Varner (fixed order from v4 onward).
- Abstract, Introduction, Methods, Results, Discussion, Conclusion, and
  Supplementary sections are byte-identical copies of v9; each will be
  modified in place under `*_v10.tex` as the plan items land.

---

## v9 (frozen 2026-04-22)

**Scope.** Recovery and consolidation pass after the 2026-04-22 VIX /
option-pricing strip that moved VIX and option-pricing content to the
sibling `CHMM-Vol-Model` / `CHMM-Vol-Paper` repos. Kept the v8 scaffold;
refocused narrative on equity-only synthetic-data generation.

### Changes vs v8

1. Rydén (1998) refutation framing (moderate $K$ closes the $\lvert r\rvert$
   ACF decay gap).
2. BIC / CAIC plus multi-metric score for state selection ($K = 18$ chosen).
3. Retained the seven-metric evaluation panel (KS %, AD %, kurtosis,
   ACF-MAE, Wasserstein-1, Hellinger, quantile coverage) on IS + OoS.
4. Retained the Pipeline A / Pipeline B split from v8 for cross-asset
   results.

### What is unchanged from v8

- Author list: Alswaidan, Jin, Varner.
- Experimental infrastructure inherited from v7 / v8 (`run_all_analysis.jl`
  harness and seven-metric panel).

---

## v8 (frozen)

**Scope.** Editorial clarity pass on `Paper_v8.tex`. No new experiments,
no changed numbers. Target output is a venue-agnostic preprint.

### Changes vs v7

1. **Explicit Pipeline A / Pipeline B labeling** throughout the paper.
   - Pipeline A: single-index trained CHMM (per-ticker independent Baum-Welch fit).
   - Pipeline B: cross-asset dependence (SIM, Gaussian copula, Student-t copula)
     on top of Pipeline A per-asset CHMM marginals.
   Every subsection header in `results_v8.tex` and every diagnostic subsection
   header in `supplemental_v8.tex` that depends on the pipeline distinction
   carries the pipeline tag (e.g., "Cross-Asset Univariate Generalization
   (Pipeline A)", "Cross-Asset Dependence: SIM and Copula Extensions
   (Pipeline B)", "Walk-Forward Rolling-Window Re-Estimation (Pipeline A)",
   "Student-t Copula Profile Log-Likelihood (Pipeline B)").

2. **Table T2 and Table T3 are now unambiguous.**
   - Table T2 = per-ticker marginal fidelity across three emission families
     (Pipeline A, six tickers). Label: `tab:cross_asset`.
   - Table T3 = cross-asset dependence extension (Pipeline B, SIM + Gaussian
     copula + Student-t copula on fixed CHMM-N marginals). Label:
     `tab:cross_asset_sim_copula`.
   In v7 both tables were written to files named `Table-T2-*.txt` on disk.
   v8 aligns the on-disk artifact names to the paper numbering:
   `results/SPY/Table-T2-Per-Ticker-Emission-Families.txt` and
   `results/cross_asset/Table-T3-Cross-Asset-Dependence.txt`.

3. **Self-contained figure and table captions.** Every caption now leads with
   a bolded subject line that states pipeline and scope, then explains
   ticker(s), K, emission family, IS vs OoS window, number of simulated paths,
   and the meaning of every plotted element (color, line style, band).

4. **Methods section flags Pipeline B explicitly.** Section on cross-asset
   dependence is titled "Cross-Asset Dependence (Pipeline B)" and opens with
   a one-paragraph orientation that names Pipeline A and explains how
   Pipeline B composes on top of it.

5. **Venue-agnostic framing in `Paper_v8.tex`.** Removed prior
   venue-specific framing (fidelity / utility / privacy triad paragraph)
   from the abstract and introduction so the paper is suitable for an
   arXiv preprint.

6. **v7-leftover cleanup.** Removed internal references to `V7_SEED`,
   `run_v7_revisions.jl`, the "Paper v7" rebuild log line, and the
   `Fig-v7-*.pdf` figure filename prefix (renamed those figures to drop the
   v7 prefix, paths updated throughout).

### What is unchanged

- Author list: Alswaidan, Jin, Varner (fixed order from v4 onward).
- Experimental numbers: byte-identical to v7 for every reported table and
  figure. All edits are textual.
- Figures in `sections/figs/`: unchanged PDFs. New plot-title strings and
  caption wordings live in the Julia analysis scripts and will take effect
  the next time those scripts are run.

---

## v7 (predecessor)

Substantive rebuild against the new 10-year training and out-of-sample
remainder split. Added VaR and ES back-test, walk-forward re-estimation
diagnostic, block-bootstrap and bin-T NJ baselines, GRU neural baseline,
Student-t copula profile-MLE degrees-of-freedom selection, Ryden K=2
reproduction, and extended out-of-sample equity price simulation across
six tickers and three emission families. Retained as the last stable
reference version.

---

## v1 through v6 (retired)

Exploratory drafts predating the v7 rebuild. Deleted on 2026-04-21 to
reduce repository noise; full history is available in git.
