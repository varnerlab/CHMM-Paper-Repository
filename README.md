# CHMM-paper

LaTeX sources for the working paper

> **Continuous Hidden Markov Models for Equity Returns: Spectral Rank,
> Heavy-Tail Emission Families, and Regime-Conditional Value-at-Risk**
> Alswaidan A, Jin C, Varner JD, Cornell University, 2026.

This repo holds only the paper sources (`paper.tex` as the shell,
`sections/*.tex` for each section body, `references.bib`, and the figure
PDFs and result CSVs referenced by the manuscript). The analysis code,
data-loading scripts, fitted models, and the Julia modules that produce
every figure and table live in the sibling repository
[`CHMM-Model`](https://github.com/altashly1/CHMM-Model).

## Authors

- **Abdulrahman Alswaidan** -- Robert Frederick Smith School of Chemical and Biomolecular Engineering, Cornell University, Ithaca, NY, USA. `aa2725@cornell.edu`
- **Cade Jin** -- Cornell Ann S. Bowers College of Computing and Information Science, Cornell University, Ithaca, NY, USA. `cj383@cornell.edu`
- **Jeffrey D. Varner** -- Robert Frederick Smith School of Chemical and Biomolecular Engineering, Cornell University, Ithaca, NY, USA. `jdv27@cornell.edu`

## Citation

```bibtex
@article{alswaidan2026chmm,
  title   = {Continuous Hidden Markov Models for Equity Returns:
             Spectral Rank, Heavy-Tail Emission Families,
             and Regime-Conditional Value-at-Risk},
  author  = {Alswaidan, Abdulrahman and Jin, Cade and Varner, Jeffrey D.},
  year    = {2026},
  institution = {Cornell University},
  note    = {Working paper}
}
```

## Build

Either:

```
make
```

or directly:

```
pdflatex -interaction=nonstopmode paper.tex
bibtex paper
pdflatex -interaction=nonstopmode paper.tex
pdflatex -interaction=nonstopmode paper.tex
```

Produces `paper.pdf`. The current draft compiles to 65 pages (body,
bibliography, and appendices).

`make clean` removes the usual LaTeX auxiliary files; `make distclean`
also removes `paper.pdf`.

### arXiv submission

arXiv does not run `bibtex` server-side, so the submission tarball must
include `paper.bbl` alongside `paper.tex`, `figs/`, `sections/`, and
(optionally) `references.bib`. Build locally once, then package the
tarball with the `.bbl` included -- `paper.bbl` is in `.gitignore` for
repo cleanliness but is a required submission artifact.

## Files

- `paper.tex` -- manuscript shell: preamble, title, abstract, and
  `\input{sections/*}` for each section body and the appendix.
- `sections/` -- one `.tex` per section (content-named, no version
  suffixes):
  - **Body**: `introduction.tex`, `related_work.tex`, `model.tex`,
    `estimation.tex`, `theory.tex`, `results.tex`, `var_backtest.tex`,
    `discussion.tex`, `conclusion.tex`, `walkforward_body_table.tex`.
  - **Appendix** (assembled by `supplementary.tex`):
    `algorithms_appendix.tex`, `metrics_appendix.tex`,
    `sensitivity_appendix.tex`, `baselines_appendix.tex`,
    `cross_asset_appendix.tex`.
- `references.bib` -- bibliography (110 entries).
- `figs/` -- figures referenced by the paper, copied from the companion
  code repo. Includes the four-panel stylized-facts figure, IS / OoS
  comparison panels at K in {3, 6, 12, 18, 21}, per-family ablation
  variants (CHMM-N, -t, -L, -GED), convergence traces, transition
  matrices, residence-time histograms, emission PDFs, the cross-asset
  correlation panel, the copula profile, and the VaR-ES panel.
- `results/robustness/` -- CSV result tables (k-selection, walk-forward,
  KS block-bootstrap, MS-GARCH conditional VaR, QuantGAN panels, leverage
  effect, etc.) referenced verbatim by the paper.

## Regenerating the figures and tables

All figures and tables in the paper are produced by the Julia scripts in
the sibling [`CHMM-Model`](https://github.com/altashly1/CHMM-Model) repo.
Entry points (run from that repo root with `julia --project=. <script>`):

| Script                                                    | Produces                                                              |
|-----------------------------------------------------------|-----------------------------------------------------------------------|
| `run_full_rebuild.jl`                                     | end-to-end rebuild of every paper artefact                            |
| `runners/headline/run_all_analysis.jl`                    | SPY-only stylized facts + per-K internals                             |
| `runners/headline/run_multi_emission_analysis.jl`         | CHMM-N / -t / -L / -GED at K* block                                   |
| `runners/headline/run_baselines_and_cross_asset.jl`       | Pipeline A baselines + Pipeline B setup                               |
| `runners/headline/run_cross_asset_sim_copula.jl`          | Pipeline B: SIM, Gaussian / Student-t copula                          |
| `runners/headline/run_msgarch_baselines.jl`               | MS-GARCH K in {2,3,6} rows (in-house Nelder-Mead)                     |
| `runners/headline/run_msgarch_reference.jl`               | MS-GARCH ref. Bayesian rows (CRAN MSGARCH)                            |
| `runners/headline/run_smchmm_baseline.jl`                 | semi-Markov CHMM at K* (ported from `SM-CHMM-AR-Model`)               |
| `runners/headline/run_quantgan_baseline.jl`               | QuantGAN deep-generative row                                          |
| `runners/headline/run_cross_ticker_penalised.jl`          | penalised CHMM-t cross-ticker headline                                |
| `runners/headline/run_sector_panel.jl`                    | 30-ticker sector rollup                                               |
| `runners/headline/run_chmm_t_shared_nu.jl`                | shared-nu sensitivity                                                 |
| `runners/headline/run_figures.jl`                         | Body Figures 1-4                                                      |
| `runners/var_backtest/*.jl`                               | regime-conditional VaR + Christoffersen + DQ tables                   |
| `runners/robustness/*.jl`                                 | walk-forward, cross-decade, k-selection HAC, kurtosis CI              |
| `runners/spectral/*.jl`                                   | spectral / rank diagnostics for Methods §3.3                          |
| `runners/cross_asset/*.jl`                                | half-unit copula CI, non-US stress test                               |
| `runners/baselines/*.jl`                                  | Appendix B: SV-AR(1), MSM, Merton-JD, HSMM-Gamma                      |

`CHMM-Model/RUNNERS.md` is the authoritative runner-to-paper-artefact
map. After regenerating, copy the PDFs from `CHMM-Model/figs/` and the
CSVs from `CHMM-Model/results/` into `CHMM-paper/figs/` and
`CHMM-paper/results/` respectively before rebuilding this paper.

## Status

- **2026-05-04** -- arXiv-submission-ready. Compiles cleanly to 65 pages
  with no LaTeX warnings (no overfull / underfull boxes, no
  float-too-large notices); `paper.bbl` is built and ready to bundle
  into the submission tarball.
- The paper is the headline equity-returns CHMM contribution; the
  companion VIX / semi-Markov extension lives in
  [`SM-CHMM-AR-Paper`](https://github.com/altashly1/SM-CHMM-AR-Paper)
  with its code in
  [`SM-CHMM-AR-Model`](https://github.com/altashly1/SM-CHMM-AR-Model).

## License

MIT. See [`LICENSE`](LICENSE).

## Related repositories

- [`CHMM-Model`](https://github.com/altashly1/CHMM-Model) -- companion
  Julia code repository (data loaders, fitted models, runners).
- [`SM-CHMM-AR-Model`](https://github.com/altashly1/SM-CHMM-AR-Model) /
  [`SM-CHMM-AR-Paper`](https://github.com/altashly1/SM-CHMM-AR-Paper) --
  semi-Markov CHMM-AR extension targeting the CBOE Volatility Index.
- [JumpHMM.jl](https://github.com/varnerlab/JumpHMM.jl) -- discrete HMM
  core package from an earlier paper in the same line of work.
