# Paper v8 revision notes

Scope: editorial clarity pass. No new experiments, no table numbers removed, no
authors changed (the fixed three-author block Alswaidan, Jin, Varner is preserved).

## What changed vs v7

1. **Explicit Pipeline A / Pipeline B labeling** throughout the paper.
   - Pipeline A: single-index trained CHMM (per-ticker independent Baum-Welch fit).
   - Pipeline B: cross-asset dependence (SIM, Gaussian copula, Student-t copula)
     on top of Pipeline A per-asset CHMM marginals.
   Every subsection header in `results_v8.tex` and every diagnostic subsection
   header in `supplemental_v8.tex` that depends on the pipeline distinction now
   carries the pipeline tag (e.g., "Cross-Asset Univariate Generalization (Pipeline A)",
   "Cross-Asset Dependence: SIM and Copula Extensions (Pipeline B)",
   "Walk-Forward Rolling-Window Re-Estimation (Pipeline A)",
   "Student-t Copula Profile Log-Likelihood (Pipeline B)").

2. **Table T2 and Table T3 are now unambiguous.**
   - Table T2 = per-ticker marginal fidelity across three emission families
     (Pipeline A, six tickers). Label: `tab:cross_asset`.
   - Table T3 = cross-asset dependence extension (Pipeline B, SIM + Gaussian
     copula + Student-t copula on fixed CHMM-N marginals). Label:
     `tab:cross_asset_sim_copula`.
   In v7 both tables were written to files named `Table-T2-*.txt` on disk.
   v8 aligns the on-disk names to the paper numbering:
   `results/SPY/Table-T2-Per-Ticker-Emission-Families.txt` and
   `results/cross_asset/Table-T3-Cross-Asset-Dependence.txt`.

3. **Self-contained figure and table captions.** Every caption now leads with a
   bolded subject line that states pipeline and scope, then explains pipeline,
   ticker(s), K, emission family, IS vs OoS window, number of simulated paths,
   and the meaning of every plotted element (color, line style, band).

4. **Methods section flags Pipeline B explicitly.** Section 3.x "Cross-Asset
   Dependence" is now titled "Cross-Asset Dependence (Pipeline B)" and opens
   with a one-paragraph orientation that names Pipeline A and explains how
   Pipeline B composes on top of it.

## Files produced

- `Paper_v8.tex`                 (master, wired to v8 sections and References_v8.bib)
- `References_v8.bib`            (exact copy of v7 bib; no citation changes)
- `sections/introduction_v8.tex`
- `sections/related_v8.tex`
- `sections/methods_v8.tex`      (cross-asset subsection retagged Pipeline B)
- `sections/results_v8.tex`      (four subsections now pipeline-tagged; captions self-contained)
- `sections/discussion_v8.tex`   (cross-asset paragraphs pipeline-tagged)
- `sections/conclusion_v8.tex`
- `sections/supplemental_v8.tex` (cross-asset, walk-forward, copula-profile subsections tagged)

## What is unchanged

- Author list: Alswaidan, Jin, Varner. Order preserved from v4 onward.
- Experimental results: all numbers identical to v7 (Table 2, Table T1a, T1b,
  Table T2/T3 contents unchanged). The edits are textual clarifications.
- Citation list: `References_v8.bib` is byte-identical to `References_v7.bib`.
- Figure PDFs in `sections/figs/`: unchanged. New plot-title strings live in
  the Julia scripts and will take effect the next time those scripts are run.
