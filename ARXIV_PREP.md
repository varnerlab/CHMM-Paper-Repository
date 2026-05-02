# ARXIV_PREP — arXiv-readiness plan for the CHMM paper

Status target: trim from 112 pp to ~50–60 pp, reposition the contribution around the
spectral-rank recasting + regime-conditional VaR, sync the CHMM-Model repo with the
four-variant body, prune dead runners, ship to arXiv (q-fin.ST primary).

This file is a checklist, not a design doc. Each item names exactly what changes
and where. After execution it can be deleted (or left as a changelog).

---

## 1. Title, abstract, intro contribution paragraph

**Files:** `paper.tex` (title block + abstract), `sections/introduction.tex`.

- [ ] **Title.** Replace the descriptive current title with a punchier alternative
  that signals both contributions (spectral recasting + regime-conditional VaR).
  Pick:
  - **A.** *Revisiting the Rydén Low-K Failure: A Spectral-Rank View of Continuous
    Hidden Markov Models for Equity Returns, with Regime-Conditional VaR.*
  - **B.** *Continuous Hidden Markov Models for Equity Returns: Spectral Rank,
    Heavy-Tail Emission Families, and Regime-Conditional Value-at-Risk.*

  Going with **B** (slightly less polemical, more searchable on arXiv).

- [ ] **Abstract restructure.** Lead with the finding, not the mechanics. Target
  ordering:
  1. The Rydén-1998 verdict (HMM at K=2–3 cannot reproduce slow |G| ACF) is a
     marginal-mixture limit, not a temporal limit; we show this empirically.
  2. Method one-sentence: unified ECM scaffold, four emission families.
  3. Empirical scope (SPY 2014–2026, 30-ticker panel, CRSP 1994–2006,
     six-asset US-equity copula).
  4. Headline result: regime-conditional VaR passes Christoffersen-cc cleanly
     across emission families on OoS.
  5. Honest positioning: ML HSMM matches/exceeds CHMM on raw OoS KS; CHMM's
     value-add is the structural use cases (conditional VaR, copula composition,
     parametric privacy).

- [ ] **Intro contribution paragraph.** Recast `(i)` from
  *"we apply the textbook bilinear identity..."* to
  *"we provide empirical evidence that the algebraic rank bound is non-binding..."*
  Drop the preemptive defensiveness; the empirical recasting is the contribution.

## 2. Related work expansion

**File:** `sections/related_work.tex` (currently 11 lines, ~5 paragraphs).

Add paragraphs on:
- [ ] **State-space stochastic volatility.** Taylor 1982; Jacquier–Polson–Rossi
  1994; Kim–Shephard–Chib 1998. Position SV as the obvious continuous-latent
  alternative; CHMM is a discrete-latent counterpart.
- [ ] **Bayesian online change-point.** Adams–MacKay 2007; Fearnhead–Liu 2007.
  Relevant to the regime-introduction failure mode (W2 COVID, W4 2022 rate-hike).
- [ ] **Recent neural baselines beyond TimeGAN/QuantGAN.** Boursin et al.
  (signature-based market generators); diffusion-based market generators
  (Cont/Wiese et al. follow-ups).
- [ ] **Large-covariance / multi-asset VaR.** Engle–Sheppard DCC;
  Pakel–Brownlees–Engle composite likelihood. Relevant to the cross-asset
  copula framing.

Update `references.bib` accordingly. Keep total related-work length ≤ 1.5 pages.

## 3. Body additions (interpretability, compute cost, architecture diagram)

- [ ] **Architecture diagram in body (Fig 2 slot).** Promote
  `\label{fig:chmm_architecture}` from
  `sections/algorithms_appendix.tex:419–474` into `sections/model.tex` as a new
  Fig 2 directly after `\subsection{Continuous Hidden Markov Model}`. Strip
  the duplicate from the appendix (replace with a `\see{Fig~\ref{...}}`).
- [ ] **Per-state interpretability paragraph** in `sections/results.tex` after
  `\subsection{Six-Generator Comparison}`. One paragraph: which fitted state
  corresponds to which observed regime (calm pre-2020, COVID 2020, recovery
  2021, 2022 rate-hike onset). Pull from `results/SPY/diagnostics/` if a
  per-state-trajectory artefact exists; otherwise leave a TODO marker for the
  Julia side to produce one.
- [ ] **Computational-cost paragraph** in `sections/discussion.tex` (new
  paragraph between *Stationarity scope* and *Limitations*). Two short bullets:
  per-K wall-clock training time on the SPY panel, parameter-count comparison
  against QuantGAN (CHMM K=18 ≈ 360 params vs QuantGAN tens of thousands).

## 4. Conclusion broader implication

**File:** `sections/conclusion.tex`.
- [ ] Add a closing sentence: *"The spectral-rank diagnostic generalises beyond
  the Rydén instance: any regime-switching 'failure' result attributing limits
  to temporal structure can be re-litigated as a marginal-mixture vs.
  effective-rank decomposition."*

## 5. Appendix trim — sensitivity_appendix.tex (1592 → ~400 lines)

**File:** `sections/sensitivity_appendix.tex`.

Keep (these are referenced from body or carry standalone substantive content):
- `sec:sensitivity_table` (headline K-sweep)
- `sec:multi_emission_sensitivity` (K x family panel)
- `sec:cross_ticker_sector_panel` (30-ticker per-ticker rollup)
- `sec:spectral_rank` + `sec:spectral_rank_xticker` (the empirical
  effective-rank diagnostic — this is the body theory's evidence)
- `sec:cross_ticker_quarterly_refit`
- `sec:kurtosis_bootstrap_ci` + `sec:kurtosis_ci_placement`
- `sec:chmm_t_shared_nu`
- `sec:christoffersen_power` + `sec:engle_manganelli_dq` (VaR power calibration)
- `sec:lambda_cv_pre2020`
- `sec:supp_p_partition` (CHMM-GED bimodal partition)
- `sec:supp_var_envelope`
- `sec:cross_decade_validation` (cross-decade IS transfer test)

Move to `_attic_v10/` in the model repo (NOT deleted — these are real results,
just moved out of the appendix; the paper appendix retains a one-line pointer
"Full panel and additional sensitivity rows in
`CHMM-Model/results/<artefact>` and the `_attic_v10/` archive."):
- `sec:sector_panel_n6` (60-ticker confirmatory; the n=3 version makes the
  body point already)
- `sec:cross_ticker_named_spot_check`
- `sec:cross_asset_kstar6` (K=6 cross-asset is in the K=3/K=18 sandwich; one
  cell of the sandwich is fine)
- `sec:emission_family_frobenius`
- `sec:convergence` + `sec:k_sweep_panels` + `sec:multi_emission_figs`
  (all the per-K visual sweeps — these are diagnostic figures, not headline)
- `sec:ryden_replication` (the K=2 replication; one paragraph in the body's
  spectral-mechanism section is enough)
- `sec:cross_ticker_anova` (already negative result; one body sentence)
- `sec:walkforward_w7` (W7 extension — superseded by main walk-forward)
- `sec:oos_regime_trajectory` (state-trajectory figure goes to body
  interpretability paragraph; the appendix table is redundant)
- `sec:walkforward_refit_cadence` + `sec:cross_ticker_monthly_refit`
  (refit-cadence sweeps — the quarterly-refit row carries the body claim)
- `sec:non_equity_validation` (kept in `cross_asset_appendix` as
  `sec:non_us_asset_supp` already)
- `sec:subdecade_validation` (the cross-decade test already does this work)
- `sec:supp_stylized_facts` (figure — keep one combined panel in body
  if not already)
- `sec:supp_validation_figures` (per-K validation figure grids)
- `sec:supp_hsmm_diagnostic` + `sec:hsmm_gamma_sojourn` (HSMM ablations —
  keep one summary table in baselines appendix)
- `sec:state_distinctness`, `sec:exact_binomial_kupiec`, `sec:dm_bandwidth`,
  `sec:hsmm_intermediate`, `sec:mssv_baseline`, `sec:alpaca_depth_probe`
  (auxiliary diagnostics)
- `sec:quarterly_refit_cond_var` (one reference table from body is enough)

Target: ~400 lines after trim.

## 6. Appendix trim — algorithms_appendix.tex (474 → ~150 lines)

**File:** `sections/algorithms_appendix.tex`.

- [ ] Consolidate the four near-identical ECM pseudocode blocks into ONE
  parameterised algorithm with a per-family M-step "card" (3–5 lines each).
- [ ] Drop the Pipeline Schematic figure (already implicit from §2.1 "two
  pipelines" mention).
- [ ] Strip the architecture-diagram block (now promoted to body).
- [ ] Keep the per-state shape diagnostics summary as a single table.

## 7. Appendix trim — baselines_appendix.tex (334 → ~100 lines)

**File:** `sections/baselines_appendix.tex`.

- [ ] Keep MS-GARCH reference Bayesian (in-house Nelder-Mead row already in
  body), QuantGAN.
- [ ] Move HAR-RV, EGARCH, GJR-GARCH, SV (Taylor-Harvey-Ruiz-Shephard), MSM
  (Calvet-Fisher), Merton-JD into a single ~12-row comparison table with
  point estimates, replacing the per-baseline narrative paragraphs. Cite the
  model repo runner that produces each row.

## 8. Model repo sync

**Directory:** `~/Desktop/Project-Repos/CHMM-Model/`.

- [ ] **README.md.** Add CHMM-GED as a fourth emission. Update §"Three-Model
  Comparison" → "Four-Model Comparison" (currently lists Discrete HMM + Jumps,
  Continuous HMM, GARCH(1,1) — should add CHMM-{N,t,L,GED} disambiguation).
  Update §"Quick Start" if needed.
- [ ] **SPECIFICATION.md.** Line 7 says *"each hidden state emits from a
  Gaussian distribution"* — generalise to *"each hidden state emits from a
  per-state density (Gaussian, Student-t with per-state $\nu_k$, Laplace, or
  GED with per-state shape $p_k$)"*. Update §"Three-Model Comparison" table
  to match.

## 9. Add RUNNERS.md index in model repo

**New file:** `~/Desktop/Project-Repos/CHMM-Model/RUNNERS.md`.

Two-column markdown table mapping every active runner to:
- the artefact it produces under `results/<subdir>/`
- the paper table/figure/section that consumes it

Goal: a reproducibility audit can be done by reading one file. Sort runners
roughly by paper-section order (descriptive → K-selection → headline panel →
walk-forward → cross-ticker → cross-asset → VaR → sensitivity).

## 10. Runner cleanup

**Directory:** `~/Desktop/Project-Repos/CHMM-Model/`.

Audit the 52 `run_*.jl` runners. Move to `_attic_v10/runners/` any runner
whose results are no longer cited in the trimmed paper:
- [ ] `run_sector_panel_n6.jl` — 60-ticker sensitivity now in `_attic_v10/`
- [ ] `run_sector_panel_n6_postprocess.jl` — companion to above
- [ ] `run_cross_ticker_anova.jl` — negative result now in body sentence only
- [ ] `run_walkforward_w7.jl` — W7 extension superseded by main walk-forward
- [ ] `run_hsmm_ml_intermediate_K.jl` — intermediate-K HSMM no longer reported
- [ ] `run_walkforward_cond_var_refit_cadence.jl` — refit-cadence sweep
  (quarterly-refit body row carries the claim)
- [ ] `run_sector_panel_quarterly_refit_k6.jl` — K=6 panel row
- [ ] `run_oos_regime_trajectory.jl` — table replaced by body figure pull
- [ ] `run_figures_ksweep.jl` — per-K visual-sweep figures cut from appendix

Keep ALL other runners. They underpin the body claims directly or feed the
trimmed-but-retained appendix sections.

After moves, update:
- [ ] `run_full_rebuild.jl` so it doesn't reference moved runners
- [ ] `_attic_v10/runners/README.md` (or create) — one-line note per moved
  runner explaining why it's archived

## 11. Memory hygiene

- [x] `project_chmm_ged_variant.md` — already updated (CHMM-GED is in paper).

## 12. Build + verify

- [ ] `make` (paper repo) → check PDF builds cleanly, no `??` undefined refs.
- [ ] Verify page count is in the 50–60 range.
- [ ] `git status` on both repos for sanity.

---

## Out of scope (intentionally deferred to a future revision)

- Skew-emission CHMM (the leverage-effect coverage gap) — companion paper.
- Untruncated regular vine / factor copulas at larger d — companion paper.
- Wiese et al. reference-implementation QuantGAN re-run with Lambert-W
  pre-processing — companion paper.

These are already flagged as such in the body "Limitations" paragraph; we
don't add them in the arXiv-prep pass.
