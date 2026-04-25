# Rename revision artefacts plan

Goal: scrub the `results/revision/M*_*.csv` and `minor*_*.csv` paths from the rendered paper. These paths still surface in `\texttt{...}` captions even after the prose pass, so they read as the same internal-jargon leak we just removed.

## Scope decision

- Rename the directory `results/revision/` → `results/robustness/`. One path-segment change covers every reference; a generic descriptor matches the contents (block-bootstrap, rolling-origin, multi-seed, ablations, expanded baselines).
- Rename each CSV to a descriptive name (mapping table below).
- Use `git mv` to preserve file history.
- Leave internal LaTeX `\label{tab:m4_rolling}` etc. untouched (cross-refs render as "Table N", not the label string).
- Leave the historical devnotes `revision-plan-JoFE.md` and `revision-code-todo.md` referencing M-codes in their prose (that is what those files document), but update path strings to match disk reality.

## Filename mapping

| Old path | New path |
|---|---|
| results/revision/M2_ks_bootstrap.csv | results/robustness/ks_block_bootstrap.csv |
| results/revision/M3_filter_var_backtest.csv | results/robustness/filter_var_backtest.csv |
| results/revision/M4_rolling_origin.csv | results/robustness/rolling_origin_oos.csv |
| results/revision/M4_weekly.csv | results/robustness/weekly_frequency.csv |
| results/revision/M5_lr_ind_null.csv | results/robustness/lr_ind_bootstrap_null.csv |
| results/revision/M6_var_ci.csv | results/robustness/kupiec_mc_ci.csv |
| results/revision/M7_garch_suite.csv | results/robustness/garch_suite.csv |
| results/revision/M8_k_selection.csv | results/robustness/k_selection_validation.csv |
| results/revision/M9_skew_emissions.csv | results/robustness/skew_emissions_ablation.csv |
| results/revision/M10_nu_shrinkage.csv | results/robustness/nu_shrinkage_sweep.csv |
| results/revision/minor4_mmd_bandwidth.csv | results/robustness/mmd_fixed_bandwidth.csv |
| results/revision/minor6_kdisc13_centroid.csv | results/robustness/kdisc13_centroid_ablation.csv |
| results/revision/minor10_multiseed.csv | results/robustness/multiseed_headline.csv |

## Reference inventory (from grep before edits)

Paper `\texttt{...}` references (must update — render in the PDF):

- sections/results.tex:57 → M8_k_selection.csv
- sections/results.tex:544 → M4_rolling_origin.csv
- sections/results.tex:583 → M4_weekly.csv
- sections/var_backtest.tex:115 → M6_var_ci.csv
- sections/var_backtest.tex:191 → M5_lr_ind_null.csv
- sections/baselines_appendix.tex:37 → M2_ks_bootstrap.csv
- sections/baselines_appendix.tex:58 → minor4_mmd_bandwidth.csv
- sections/baselines_appendix.tex:61 → minor6_kdisc13_centroid.csv
- sections/baselines_appendix.tex:64 → minor10_multiseed.csv

Devnote references (update path strings, leave M-code prose alone):

- revision-code-todo.md: 18 lines — 31, 85, 99, 104, 152, 199, 227, 245, 304, 345, 360, 371, 383, 389, 392, 393, 394, 395, 396, 397, 399, 400, 401, 402, 403 (some are path-only, some bare filenames in a checklist)
- revision-plan-JoFE.md: 12 lines — 80, 90, 94, 105, 113, 120, 125, 131, 135, 138, 139, 140
- Planned-but-undelivered file `M4_index_panel.csv` (mentioned in planning docs only, not on disk) → update its references to `index_panel.csv` for consistency

External code/scripts: none found in the repo (`results/` only appears under the paper directory).

External code/scripts: none found in the repo (`results/` only appears under the paper directory).

## Execution steps

1. **Write this plan** — done.
2. **Verify the grep above is exhaustive** — re-run grep on the broader pattern to catch any reference I missed (e.g., bare filename without directory prefix, or unusual whitespace).
3. **`git mv` directory and files** — rename `results/revision/` → `results/robustness/`, then `git mv` each CSV to its new name. Use `git mv` (not `mv`) so git tracks renames cleanly.
4. **Update paper `\texttt{...}` references** — 9 caption sites across 3 files. Each is a one-line `Edit` per site.
5. **Update devnote path strings** — 13 sites across 2 .md files. The M-code identifiers in prose stay (they are the subject of those documents); only the trailing `path/to/file.csv` strings change.
6. **Rebuild PDF** — `make`, then check log for undefined refs.
7. **Final grep verification** — confirm zero remaining `results/revision/` references anywhere.
8. **Update this plan** — tick boxes off as each step completes; record any deviation.

## Status

- [x] Step 1 — Plan written.
- [x] Step 2 — Re-run exhaustive grep (found 18 extra devnote refs missed in first inventory; plan updated).
- [x] Step 3 — `git mv` directory and files (13 file renames + directory rename) complete; `ls results/robustness/` confirms all 13 descriptive names present.
- [x] Step 4 — Updated 9 caption `\texttt{...}` references in paper; verified by grep.
- [x] Step 5 — Updated 26 devnote path strings (13 in revision-code-todo.md, 12 in revision-plan-JoFE.md, plus the 13-line checklist block at the bottom of revision-code-todo.md). Sister-repo script filenames (e.g. `run_track_minor4_mmd_bandwidth.jl`) intentionally left alone — they live in `CHMM-Model/`, not this repo.
- [x] Step 6 — Rebuilt PDF: 82 pages, 3.99 MB, zero undefined references / errors.
- [x] Step 7 — Final grep for `results/revision` returns zero matches outside build artefacts and this plan file.

## Deviations / notes

- First grep undercounted by 18 devnote lines (15 in revision-code-todo.md including the bottom checklist, 3 extra in revision-plan-JoFE.md). Fixed in Step 2 before any renames.
- Sister-repo Julia script names like `run_track_minor4_mmd_bandwidth.jl` still contain "minor4" / "minor6" / "minor10" tokens; these are filenames in the `CHMM-Model/` repo (sibling, not in this repo) and are out of scope for this paper-side rename.
- Internal LaTeX labels (`tab:m4_rolling`, `tab:m8_k_selection`, `tab:m10_multiseed`, `\label{sec:m7_baselines}`) deliberately left untouched: they only render as "Table N" / "Section N" cross-refs, never as the label string itself.
