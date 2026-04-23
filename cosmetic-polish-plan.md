# Cosmetic Polish Plan — Paper_v10

Scope: visual / typographic fixes flagged in the 2026-04-23 review pass. No
changes to prose, numbers, or methodology. Document class stays `article`
(Varner ACM style rejected — journal-specific).

## Issues

1. **Fig 1 (Pipeline A / B schematic)** — "marginals" brace label was sitting
   at the same vertical height as the bold "Pipeline B (cross-asset...)"
   title, looking crowded. Fix: widen the title-to-nodes gap; leave the
   brace arc shape alone.
2. **Fig 2 (CHMM architecture)** — EM loop was anchored to the last emission
   box (bottom-right), leaving the entire top-right quadrant empty beside
   the Markov chain.
3. **Figs 20 / 21 / 22 (IS comparison at K=9, 12, 15)** — x-axis labels
   missing. Root cause: `CHMM-Model/run_all_analysis.jl` sets `xlabel=...`
   per subplot but never sets a `bottom_margin`, so `size=(1400,400)` with
   `plot_title` crops the bottom strip and silently drops the x-labels.
   Same risk on Fig 1 Stylized Facts (2×2) and Fig 4 OoS Validation (1×3)
   in the same file.
4. **Paper-wide typographic polish** — `microtype` (character-level
   protrusion/expansion, tighter justified text) and `placeins` with
   `[section]` (prevents figures from floating past section boundaries).
   Zero-risk additions.

## Ordered Execution

| # | Task                                                                | File(s)                                                          | Status |
|---|---------------------------------------------------------------------|------------------------------------------------------------------|--------|
| 1 | Widen Pipeline B title / nodes gap                                  | `paper/sections/methods_v10.tex:41-42`                           | done   |
| 2 | Re-anchor CHMM architecture EM loop to top-right of Markov chain    | `paper/sections/methods_v10.tex:139-145`                         | done   |
| 3 | Add `bottom_margin` + `left_margin` to fig1 / fig3 / fig4 assemblies | `CHMM-Model/run_all_analysis.jl:147,429,465`                     | done   |
| 4 | Add `microtype` + `\usepackage[section]{placeins}` to preamble      | `paper/Paper_v10.tex`                                            | done   |
| 5 | Regenerate supplemental figures via Julia pipeline                  | `cd CHMM-Model && julia --project=. run_all_analysis.jl`         | done   |
| 6 | Copy refreshed PDFs into paper fig tree                             | `CHMM-Model/results/SPY/K{3,6,9,12,15,18,21}/Fig-3-*.pdf, Fig-4-*.pdf` → `paper/sections/figs/Fig-3-IS-Comparison-K<N>.pdf`, `Fig-4-OoS-Validation-K<N>.pdf` | done   |
| 7 | Rebuild paper to verify                                             | `cd paper && latexmk -pdf Paper_v10.tex`                         | done (74pp, clean)    |

Step 5 is the long one — full Julia pipeline over K ∈ {3,6,9,12,15,18,21};
run in background, notify on completion.

Step 6 touches multiple files; use a small shell loop keyed by K value.
