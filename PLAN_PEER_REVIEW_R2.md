# Round-2 Peer-Review Remediation Plan

Source: [peer-review.md](peer-review.md) (R1 Minor / R2 Major / R3 Major; aggregate **Major Revision**).
Target: close every Priority-1 and Priority-2 item substantively before resubmission; deliver Priority-3 framing fixes in the same pass. Build clean.

The 18 actionable items in `peer-review.md` group into four execution phases below.

---

## Phase A — LaTeX-only framing fixes (no new computation)

These are wording changes that follow the conservative reading of data already in the paper. Do first; they're fast and unblock the rest.

| # | Item | Reviewer | Files |
|---|------|----------|-------|
| A1 | Lead Table 3 column-header / surrounding text with multi-day DM (where CHMM dominates), demote raw 1-day OoS KS to a context column. | R1#1, R3#1 | `sections/results.tex` |
| A2 | Body α=0.01 conditional-VaR text: report DQ rejection at K=18 (p=0.017) as the substantive α=0.01 finding, not as a confirmation of cc-pass at α=0.05. | R2#5 | `sections/var_backtest.tex` |
| A3 | OoS block-bootstrap recalibration: add explicit body sentence that asymp→L=20 drops ~25pp and that absolute level on OoS is materially weaker than the asymp panel suggests. | R2#7 | `sections/results.tex` (around `tab:ks_block_body`) |
| A4 | Four-family contribution: reframe in introduction so the claim matches what the data support — within-CHMM DM is null on OoS at p>0.45, so the four families are "interchangeable on this evaluation"; the contribution is a unified scaffold for emission-family swapping rather than four substantively-distinct models. | R3#1 | `sections/introduction.tex`, possibly `sections/conclusion.tex` |
| A5 | Leverage section: replace "envelope brackets observed at Q5 boundary" with explicit IS / OoS permutation p-values; let the p-values carry the framing. (No new computation needed if the per-path leverage distribution is already in `results/`; if not, defer to Phase B.) | R3#3, R1#6 | `sections/discussion.tex` |
| A6 | QuantGAN row: soften "deep-generative class as negative control" to "in-house WGAN re-implementation, with and without Lambert-W, fails on this dataset." Drop the architectural-class claim. | R3#5 | `sections/results.tex`, `sections/discussion.tex`, `sections/baselines_appendix.tex` |
| A7 | GLD/SLV: strengthen the conclusion sentence — 0% OoS KS on two non-equity ETFs is a hard rejection of cross-asset-class transfer under static IS-fit, not a soft limitation. | R3#4 | `sections/conclusion.tex`, `sections/discussion.tex` (limitations paragraph) |
| A8 | Lead abstract / introduction with cross-ticker median dominant-mode share (0.756) rather than SPY-specific 0.936. | R3#2, R1#minor | `paper.tex` (abstract), `sections/introduction.tex` |
| A9 | Drop the cross-ticker ANOVA conclusion or restate as "n=3-per-sector is severely underpowered; no test of sector effects is reported here." Don't both report ANOVA F=0.44 / p=0.90 and conclude "failures are ticker-specific." | R2#3 | `sections/results.tex` |
| A10 | Title / abstract scope alignment: add "symmetric" qualifier to "stylized-fact" wherever the body covers only the three symmetric Cont facts (heavy-tailed marginals, negligible linear ACF, slow \|G_t\| ACF). | R3#minor | `paper.tex` (title, abstract), `sections/introduction.tex`, `sections/conclusion.tex` |
| A11 | Cross-asset OoS off-diagonal MAE: drop the "ν*=6 substantive selection" framing on OoS; report only the IS distinction explicitly as IS-only and lead with the quarterly-refit result (0.185). | R1#4, R3#6 | `sections/results.tex` (Section 4.4), possibly `sections/discussion.tex` |
| A12 | `tab:variant_choice`: fix "CHMM-L: cleanest IS kurtosis match; no shape parameter" — CHMM-L IS sim kurt is 5.30/6.6 vs observed 7.68. Either reword to "closest IS kurtosis match without a shape parameter" or drop the row. | R3#minor | `sections/discussion.tex` |
| A13 | Cleanup: remove leftover "Reviewer 1 / Reviewer 2 / minor item" attributions from appendix prose (response-letter artefacts), verify all `\ref{}` resolve (specifically `tab:hsmm_sojourn_compare`, `sec:supp_hsmm_diagnostic`). | R1#minor, R2#minor | All `sections/*.tex` |
| A14 | Honesty edits: in Section 3.3 (theory), state cross-ticker dominant-mode-share statement up-front and de-emphasize the SPY-specific 0.936 in the introduction-level claim. | R3#2 | `sections/theory.tex`, `sections/introduction.tex` |

**Phase A success criterion:** paper builds clean; no `\ref{}` undefined; framing matches data.

---

## Phase B — Computational items (Julia / R runs in `~/Desktop/Project-Repos/CHMM-Model`)

These are new analyses. Each item produces a CSV / TXT artifact under `results/` that gets cited in the LaTeX in Phase C.

| # | Item | Reviewer | Output artifact |
|---|------|----------|-----------------|
| B1 | **Multi-day DM replication panel.** Replicate the h=20 DM finding (CHMM-N beats bootstrap, p=0.003) on the six-asset universe (SPY, NVDA, JNJ, JPM, AAPL, QQQ) and across the six walk-forward folds. Sweep NW-HAC bandwidth at h ∈ {2, 4, 8, 16}. Sweep overlapping vs non-overlapping blocks. Report median Δ CRPS and median p across asset×fold and across bandwidths. | R1#2, R2#req-3, R3#1, R3#req-1 | `results/dm_multiday_replication/dm_panel.csv`, `results/dm_multiday_replication/dm_bandwidth_h20.csv` |
| B2 | **HAC-corrected K-selection inference.** Re-compute |z| (K=3 vs K=6, K=6 vs K=18) under a Diebold-Mariano-style Newey-West HAC variance over rolling-origin folds, not under independent folds. | R2#1, R2#req-1 | `results/k_selection_hac/k_selection_hac.csv` |
| B3 | **Bootstrap-CI placement of penalised CHMM-t IS kurtosis.** Cross-compare the simulated IS kurtosis distribution (1,000 paths) to the bootstrap CI on observed IS kurtosis [2.17, 12.40], report fraction of simulated paths inside the CI. | R2#req-2 | `results/kurtosis_ci_placement/kurt_ci_placement.csv` |
| B4 | **Single-ν shared-shape CHMM-t ablation.** Refit CHMM-t with a single shared ν across all states (one-parameter Student-t HMM). Headline metric panel against the per-state ν_k row. Test whether the IS kurtosis overshoot disappears under shared ν. | R2#req-4, R3#req-3 | `results/chmm_t_shared_nu/chmm_t_shared_nu.csv` |
| B5 | **Refit-cadence sweep on conditional-VaR walk-forward.** Monthly and weekly cadence across the six walk-forward folds. Report Christoffersen-cc statistic and pass-rate against quarterly. | R1#3 | `results/cond_var_refit_cadence/cond_var_refit_cadence.csv` |
| B6 | **K=11 effective rebuild.** Refit CHMM-N at K_nominal=11 (matching the K_eff collapse value at K=18). Headline metric panel against the K=18 nominal row. Report whether kurtosis fidelity holds at K_nominal=K_eff. | R1#5, R3#req-3 | `results/k_eff_rebuild/k_eff_rebuild.csv` |
| B7 | **Leverage-effect permutation p-value.** Permutation / parametric-bootstrap p-value on observed-vs-simulated Corr(G_t, \|G_{t+1}\|) under the simulated null at K=18, both windows. Replaces the current Q_5-boundary framing. | R3#3, R1#6 (Phase A may instead use existing path-level data here if cached.) | `results/leverage_permutation/leverage_permutation.csv` |

**Phase B deferral rules:**
- Items B1, B2, B4 are **must-have** before resubmission (highest reviewer weight).
- Items B3, B5, B6, B7 are **strongly recommended**; defer only if execution time exceeds budget.
- Item B6 (K=11 rebuild) and the 60-ticker panel expansion (R3#req-4) are deferred as **explicit follow-ups in the response letter** if they don't fit the resubmission window — they're framing-corroborative rather than headline-changing.

The 60-ticker expansion (R3#req-4) is excluded from Phase B due to scope: a 60-ticker panel doubles the CRSP/Polygon ingest and the cross-ticker simulation budget. Plan: report the n=3-per-sector ANOVA caveat (Phase A item A9) and defer the n=6-per-sector expansion as a documented follow-up.

---

## Phase C — Integrate computational results into LaTeX

Each Phase B artifact maps to a body or appendix subsection. Order chosen so the body changes (which gate Phase D rebuild) come first.

| # | Phase B input | LaTeX target |
|---|---------------|--------------|
| C1 | B1 (multi-day DM panel) | New body paragraph + `tab:dm_multiday_replication` in `sections/results.tex`; bandwidth/overlap appendix subsection in `sections/sensitivity_appendix.tex`. |
| C2 | B2 (HAC K-sel |z|) | Footnote / single-sentence amendment to the existing Section 4.1 K-selection paragraph in `sections/results.tex`. |
| C3 | B3 (kurt CI placement) | Single-sentence amendment to Section 4.1 CHMM-t prose; appendix table in `sections/sensitivity_appendix.tex`. |
| C4 | B4 (shared-ν ablation) | Body table or appendix subsection in `sections/sensitivity_appendix.tex`; one-sentence body callout in Section 4.1. |
| C5 | B5 (refit-cadence cond-VaR) | Appendix subsection `sec:cond_var_refit_cadence` in `sections/sensitivity_appendix.tex`; one-sentence body callout in Section 4.2. |
| C6 | B6 (K=11 rebuild) | Appendix subsection in `sections/sensitivity_appendix.tex`; one-sentence body callout in Section 5 K_eff paragraph. |
| C7 | B7 (leverage permutation) | Replaces the current Q_5-boundary prose in `sections/discussion.tex`. |

---

## Phase D — Final rebuild + audit trail

| # | Item | Files |
|---|------|-------|
| D1 | Build paper, verify zero `\ref{?}`, zero `\cite{?}`, page count matches expectation. | `paper.pdf` |
| D2 | Update `CHANGELOG.md` with one entry per Phase A / B / C closure. | `CHANGELOG.md` |
| D3 | Update `RESPONSE_TO_REVIEWERS.md` with R2 round response, item-by-item against `peer-review.md` Priority 1/2/3 list. | `RESPONSE_TO_REVIEWERS.md` |
| D4 | Tag any deferred items (60-ticker expansion, reference-implementation QuantGAN under Lambert-W) explicitly as follow-ups in the response letter. | `RESPONSE_TO_REVIEWERS.md` |

---

## Order of execution

1. Phase A: items A1–A14 in one pass (LaTeX edits across 6–8 files).
2. Phase B: items B1–B7 (Julia/R runs in `CHMM-Model`); B7 may be deliverable from cached path-level data without re-simulation.
3. Phase C: integrate B-artifacts into LaTeX.
4. Phase D: rebuild, verify, update audit trail.

Status tracked in the conversation TodoWrite list. Implementation begins with Phase A.
