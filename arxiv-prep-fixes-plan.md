# arXiv-Prep Fixes Plan

Date: 2026-04-27
Source: derived from `arxiv-readiness-comparison.md` and `arxiv-prep-review.md` (S2/S3/D1/D6 already DONE).
Scope: paper-repo only. Model-repo cleanup (D2-D5) is already complete.

## TL;DR

Five remaining items, ~2 hours of work, all reversible (one commit per phase). No experiments rerun. Build must stay clean (`latexmk -pdf paper.tex`, no undefined refs, no missing citations) after each phase.

| Phase | Item | Est. | Risk |
|---|---|---|---|
| P1 | S7: replace 12 umbrella `\ref{sec:supplementary}` with granular subsection refs | 30 min | low |
| P2 | S4: cut/merge 4 orphan supplementary subsections | 30-45 min | medium (verify no body cite) |
| P3 | S5: remove or archive 14 unused figure PDFs | 10 min | low |
| P4 | S6: drop 2 never-referenced proposition labels | 5 min | low |
| P5 | Self-cite arXiv:2603.10202: bib entry + one intro sentence | 15 min | low |
| P6 | Final build + spot-check | 10 min | low |

Each phase commits independently. P3 and P4 are pure mechanical cleanup; P1, P2, P5 touch prose.

---

## P1 — S7: Granular appendix routing

Replace umbrella `Appendix~\ref{sec:supplementary}` with the matching subsection label. All target labels are verified to exist (see `grep -n "label{sec:" sections/supplementary.tex sections/algorithms_appendix.tex sections/baselines_appendix.tex sections/metrics_appendix.tex sections/cross_asset_appendix.tex sections/sensitivity_appendix.tex`).

Note: arxiv-prep-review.md S7 mentions `sec:m7_baselines` and `sec:gru_supp`; these were renamed in D6a/D1 to `sec:extended_baselines` and `sec:quantgan_supp` respectively. Use the renamed labels.

| File:line | Current | Should point to |
|---|---|---|
| `estimation.tex:16` | `\ref{sec:supplementary}` (algorithmic details) | `\ref{sec:supp_algorithms}` |
| `model.tex:170` | `\ref{sec:supplementary}` (extended GARCH + SM-CHMM + QuantGAN) | `\ref{sec:extended_baselines}` (and `\ref{sec:quantgan_supp}` for the deep-generative row) |
| `model.tex:177` | `\ref{sec:supplementary}` (SIM and Gaussian copula) | `\ref{sec:supp_cross_asset}` |
| `theory.tex:5` | `\ref{sec:supplementary}` (formal propositions) | `\ref{sec:supp_propositions}` |
| `theory.tex:78` | `\ref{sec:supplementary}` (formal statements) | `\ref{sec:supp_propositions}` |
| `results.tex:16` | `\ref{sec:supplementary}` (per-K panel + held-out sweep) | `\ref{sec:supp_sensitivity}` and `\ref{sec:supp_misc}` |
| `results.tex:21` | `\ref{sec:supplementary}` (extended GARCH + SM-CHMM + QuantGAN) | `\ref{sec:extended_baselines}` |
| `results.tex:57` | `\ref{sec:supplementary}` (per-pair DM verdicts) | `\ref{sec:crps_methods}` |
| `results.tex:74` | `\ref{sec:supplementary}` (per-family K + per-ticker price-level) | `\ref{sec:multi_emission_sensitivity}` (and `\ref{sec:price_sim_oos_appendix}` only if S4 keeps that subsection) |
| `results.tex:110` | `\ref{sec:supplementary}` (SIM + Gaussian copula) | `\ref{sec:supp_cross_asset}` |
| `results.tex:145` | `\ref{sec:supplementary}` (off-diag MAE comparison) | `\ref{sec:supp_cross_asset}` |
| `discussion.tex:5` | `\ref{sec:supplementary}` (K=2 replication) | `\ref{sec:ryden_replication}` |
| `discussion.tex:33` | `\ref{sec:supplementary}` (SIM + Gaussian copula panels) | `\ref{sec:supp_cross_asset}` |
| `discussion.tex:36` | `\ref{sec:supplementary}` (K-star=3 by held-out) | `\ref{sec:supp_misc}` |
| `related_work.tex:8` | `\ref{sec:supplementary}` (deep baseline appendix) | `\ref{sec:quantgan_supp}` |
| `conclusion.tex:11` | `\ref{sec:supplementary}` (public API) | `\ref{sec:supp_chmm_api}` |

**Procedure.** Edit each file, replace ref, rebuild after each subsection (or batch by file). Verify zero `LaTeX Warning: Reference ... undefined`. Final search-PDF check: every "Appendix" mention should name a subsection, not the umbrella.

**Commit message.** `arxiv-prep S7: replace umbrella appendix refs with granular labels`

---

## P2 — S4: Orphan supplementary subsections

| Section | File | Decision |
|---|---|---|
| "Extended Evaluation: Detail Panels (leverage, agg-kurt, joint p-value)" `sec:extended_eval_detail` | `metrics_appendix.tex:54-121` | **CUT.** v10-Track-A residue, no body citation. |
| "Per-Ticker OoS Price-Simulation Figures and Path-Level Metrics" `sec:price_sim_oos_appendix` | `baselines_appendix.tex:120-240` | **CUT** (~6 figures, no body ref) **OR keep and wire one ref** in `results.tex:74`. Decision: cut, since the per-ticker price-level coverage already exists in `sec:multi_emission_sensitivity`. |
| Per-Asset KS Bar Chart `fig:cross_asset_ks` | `cross_asset_appendix.tex:127-136` | **CUT** the figure block, or wire one body ref. Default: cut, since `tab:cross_ticker` already carries the per-asset KS. |
| Duplicate $\nu_k$ diagnostics paragraph | `algorithms_appendix.tex:269-308` (table version) vs. `supplementary.tex:74-75` (text-only version) | **MERGE.** Keep the algorithms_appendix version (has the table), drop the redundant paragraph from `supplementary.tex`. |

**Procedure.** For each cut, also drop the associated PDF figure references from `figs/` (these will fall into P3's unused-fig list automatically). After cuts, grep the repo for any surviving `\ref{sec:extended_eval_detail}`, `\ref{sec:price_sim_oos_appendix}`, `\ref{fig:cross_asset_ks}` and remove or rewire.

If the user prefers to keep one of these subsections, the alternative is wiring exactly one body ref. The cut path is cleaner.

**Commit message.** `arxiv-prep S4: cut orphan supplementary subsections (extended-eval-detail, price-sim-oos, cross-asset-ks-bar) and merge duplicate nu_k paragraph`

---

## P3 — S5: Unused figure files

14 PDFs in `figs/` are not referenced by any `.tex` (verified by grep on basenames). Some are pre-cuts from prior K choices, some are stylized-fact / per-state-summary figs that may have been reorganized.

```
Fig-1-Stylized-Facts.pdf
Fig-Emission-PDFs-K12.pdf
Fig-Emission-PDFs-K3.pdf
Fig-Emission-PDFs-K6.pdf
Fig-Residence-Times-K6.pdf
Fig-SPY-PriceFan-L.pdf
Fig-SPY-PriceFan-N.pdf
Fig-SPY-PriceFan-t.pdf
Fig-Stationary-Distribution-K18.pdf
Fig-Stationary-Distribution-K6.pdf
Fig-Trajectory-Example-K18.pdf
Fig-Trajectory-Example-K6.pdf
Fig-Transition-Matrix-K18.pdf
Fig-Transition-Matrix-K6.pdf
```

**Decision needed.** Two options:
- **(I) Move to `figs/_attic/`.** Preserves history, removes from arXiv tarball. Recommended.
- **(II) `git rm`.** Cleaner but irreversible without checkout.

**Caveat.** `Fig-1-Stylized-Facts.pdf` looks like it should be in the introduction. Before archiving, verify it is not loaded under a different `\includegraphics` path (search for `Stylized` keyword in section files). If it is genuinely unused, that is itself a bug worth noting in the discussion or fixing by adding a body reference.

**Commit message.** `arxiv-prep S5: archive 14 unused figure PDFs to figs/_attic/`

---

## P4 — S6: Unused proposition labels

```
sections/supplementary.tex:43:\label{prop:identifiability}
sections/supplementary.tex:49:\label{prop:consistency}
```

Neither label is `\ref`'d anywhere. Drop both `\label{}` lines (keep the proposition statements). Verified by grep.

**Commit message.** `arxiv-prep S6: drop unused proposition labels`

---

## P5 — Self-citation to arXiv:2603.10202

The prior preprint "Hybrid Hidden Markov Model for Modeling Equity Excess Growth Rate Dynamics" (Alswaidan and Varner, 2026) is the closest sibling; the new paper does not currently cite it. A reviewer arriving from the prior preprint expects a one-line situating sentence.

**Steps.**
1. Add bib entry to `references.bib`:
   ```
   @misc{alswaidan2026hybrid,
     title={Hybrid Hidden Markov Model for Modeling Equity Excess Growth Rate Dynamics: A Discrete-State Approach with Jump-Diffusion},
     author={Alswaidan, Abdulrahman and Varner, Jeffrey D.},
     year={2026},
     eprint={2603.10202},
     archivePrefix={arXiv},
     primaryClass={q-fin.ST},
     doi={10.48550/arXiv.2603.10202}
   }
   ```
2. Add one sentence to `related_work.tex` (currently 11 lines) positioning the present paper as a sibling: e.g., "Our prior preprint \citep{alswaidan2026hybrid} grafts a jump-diffusion layer onto an HMM scaffold to capture excess-growth-rate dynamics; the present paper isolates the regime-switching mechanism and shows that a vanilla CHMM at moderate $K$ already reproduces the three canonical stylized facts via the spectral identity in Section~\ref{sec:methods}."
3. Optional: add an introduction sentence noting the methodological delta (no jump component, single EM scaffold across three emission families).

**Commit message.** `arxiv-prep: cite prior preprint arXiv:2603.10202 and position the regime-switching delta`

---

## P6 — Final build + spot-check

1. `latexmk -C && latexmk -pdf paper.tex` — confirm zero `LaTeX Warning: Reference ... undefined` and zero missing citations.
2. Search PDF for "Appendix" — every mention should name a subsection (validates P1).
3. Search PDF for "Walk-Forward Summary," "MMD," "Christoffersen," "LRind" — all should be absent (already done in S2/S3, re-verify).
4. Confirm `paper.bbl` is present and committed (arXiv requires it).
5. Confirm no shadow source files (`*_v9.tex`, `*_old.tex`).
6. Build the arXiv tarball: `paper.tex`, `paper.bbl`, `sections/`, `figs/` (post-P3 attic excluded), `references.bib`. The repo `Makefile` likely has a target.
7. Verify the tarball compiles standalone in a clean directory.

**Commit message.** `arxiv-prep: final build verification`

---

## Execution order

P3 → P4 → P1 → P2 → P5 → P6.

Rationale:
- P3 and P4 are mechanical and reduce noise in subsequent diffs.
- P1 is the largest reviewer-visible improvement; do it before P2 so cuts in P2 do not break refs added in P1.
- P2 may delete labels referenced by P1's mapping (e.g., `sec:price_sim_oos_appendix`); P1's table notes the conditional.
- P5 last so the new bib entry does not interact with prose edits.
- P6 final verification.

If a phase fails its build check, stop and fix before proceeding. Do not amend across phases — each commit is a clean checkpoint.

## Acceptance criteria for posting

- `latexmk` clean, no undefined refs.
- Zero remaining `\ref{sec:supplementary}` in body sections (`introduction.tex`, `model.tex`, `estimation.tex`, `theory.tex`, `results.tex`, `var_backtest.tex`, `discussion.tex`, `conclusion.tex`, `related_work.tex`).
- Zero unused figure PDFs in `figs/` root (any survivors must be `\includegraphics`'d).
- Self-citation to `arXiv:2603.10202` present in `related_work.tex`.
- PDF metadata (title, authors, keywords) matches the paper.
- `paper.bbl` committed.
