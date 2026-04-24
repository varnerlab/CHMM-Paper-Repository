# Paper

LaTeX source for the manuscript.

- `paper.tex` — manuscript shell (preamble + `\input{sections/*}`).
- `sections/` — one `.tex` per section (`introduction.tex`,
  `related_work.tex`, `methods.tex`, `results.tex`, `discussion.tex`,
  `conclusion.tex`, `supplemental.tex`).
- `references.bib` — bibliography.
- `figs/` — figure PDFs cited by the paper.

## Building

```bash
make
```

Or directly:

```bash
pdflatex -interaction=nonstopmode paper.tex
bibtex paper
pdflatex -interaction=nonstopmode paper.tex
pdflatex -interaction=nonstopmode paper.tex
```

`make clean` removes LaTeX auxiliary files; `make distclean` also removes `paper.pdf`.

## Figure Naming Convention

Figures are named `{Type}-K{N}.pdf` where `N` is the number of hidden states:

- `Fig-1-Stylized-Facts.pdf` — Empirical stylized facts (shared across all K)
- `Fig-3-IS-Comparison-K{N}.pdf` — In-sample density, ACF, Q-Q comparison
- `Fig-4-OoS-Validation-K{N}.pdf` — Out-of-sample KS p-values, density fan, ACF
- `Fig-Convergence-K{N}.pdf` — Baum-Welch EM convergence
- `Fig-Emission-PDFs-K{N}.pdf` — Learned Gaussian emission distributions
- `Fig-Transition-Matrix-K{N}.pdf` — Transition matrix heatmap
- `Fig-Residence-Times-K{N}.pdf` — Natural residence times per state
- `Fig-Grid-Search-K{N}.pdf` — Jump parameter grid search heatmap
- `Fig-ACF-Optimal-K{N}.pdf` — ACF at optimal jump parameters
- `Fig-ACF-Comparison-K{N}.pdf` — 4-panel ACF comparison (NJ vs WJ, raw vs absolute)
- `Fig-Trajectory-Example-K{N}.pdf` — Example simulated vs observed trajectory
- `Fig-Stationary-Distribution-K{N}.pdf` — Stationary distribution
