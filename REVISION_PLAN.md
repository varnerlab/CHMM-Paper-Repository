# Revision Plan: Addressing Peer Review

This plan maps each peer-review item from [peer-review.md](peer-review.md) to a concrete change. Items are sorted by cost (Phase 1 = text-only, Phase 2 = pull existing computation into body, Phase 3 = new computation in [CHMM-Model](../CHMM-Model)). The aggregate panel recommended **Major Revision**; the priority numbering follows the consolidated list (P1–P7) at the bottom of the review.

## Phase 1 — Text-only revisions (no new computation)

These items can be addressed entirely in the paper repo. No new simulations are required.

| Item | Change | Files |
|------|--------|-------|
| **P1.1** Demote $K=18$ from headline | (a) Rewrite Table 1 caption to explicitly mark $K^\star=6$ as the held-out-clean default. (b) Add a "Headline operating point" preamble at top of [§5.1 / §5.2](sections/results.tex) stating the $K^\star=6$ choice. (c) Move the $K=18$ block under a clearly-labeled "Extended-state-resolution sensitivity reference" heading. (d) Update abstract to lead with $K^\star=6$ numbers (88.3–92.6% IS / 76.3–79.0% OoS KS). | `sections/results.tex`, `paper.tex` (abstract), `sections/conclusion.tex` |
| **P5.1** Pair IS off-diag MAE 0.027 with OoS MAE 0.209 in abstract/intro | Add "(OoS off-diagonal MAE 0.209 static, 0.185 quarterly refit)" to the abstract and to [intro.tex line 7](sections/introduction.tex#L7). | `paper.tex` (abstract), `sections/introduction.tex` |
| **P6.4a** Title fix | Drop redundant "Regime-Switching" qualifier per R3.M4 — every CHMM is regime-switching by construction. New title: "A Continuous Hidden Markov Model as a Reference Synthetic-Data Generator for Equity Returns." | `paper.tex` |
| **P6.4b** Table 1 bold convention | Use bold for column-best within $K=18$ block only; use a leading row marker (asterisk) for operational headlines. Update caption to match. | `sections/results.tex` |
| **P6.4c** Table 2 caption | Add explicit "OoS KS computed under IS-fixed parameters (no refit)" to caption per R1.M4. | `sections/results.tex` |
| **P7a** Break long intro paragraph | Split [introduction.tex line 7](sections/introduction.tex#L7) (single 750-word paragraph) into 2–3 paragraphs: problem statement, mechanism, main numerical result. | `sections/introduction.tex` |
| **P7b** Yu (2010) HSMM citation | Add formal Yu (2010) reference for the explicit-duration forward-backward and replace the informal text reference at [results.tex line 59](sections/results.tex#L59). | `references.bib`, `sections/results.tex` |
| **P7c** Complex-eigenvalue parenthetical | One-sentence parenthetical after [theory.tex eq. (5)](sections/theory.tex#L60) noting that complex-conjugate $\lambda_k$ pairs combine into damped oscillatory modes (already stated in supp; should appear in body). | `sections/theory.tex` |
| **R3.M1** "Empirical Rydén failure" qualifier | Specify "the SPY 2014–2024 instance" of the Rydén setup wherever the phrase appears (abstract, intro, conclusion). | `paper.tex`, `sections/introduction.tex`, `sections/conclusion.tex` |
| **R3.M2** Soften "within-CHMM equivalence" framing | Edit [results.tex line 56](sections/results.tex#L56) to acknowledge the four-family DM equivalence is consistent with interchangeability, not just a strength. | `sections/results.tex` |

**Cost:** ~2 hours of focused editing.

---

## Phase 2 — Pull existing computation into body

The following review items request material that **already exists** in [CHMM-Model results](../CHMM-Model/results) or in the paper's appendix. The fix is to surface it in the body, not to run new simulations.

| Item | Source (already computed) | Body change |
|------|---------------------------|-------------|
| **P2.3** Walk-forward summary in body | Table `tab_walkforward` in `sections/sensitivity_appendix.tex` (already 24-fold rolling-origin) | Add a 4-row body summary table to [§5.2](sections/results.tex) with median/min/max KS and stress-fold count, citing the full table in the appendix. |
| **P3.1** MS-GARCH at $K\in\{3,6\}$ in body | `results/msgarch_baselines/` — full panel exists; currently only $K=2$ in body Table 1. | Add MS-GARCH-$K{=}3$ and $K{=}6$ rows to body Table 1 under the benchmark block. |
| **P6.1** Per-state $\hat\nu_k$ histogram | `results/diagnostics/nu_diagnostics/` — figure already in appendix (Fig. nu_hist) | Pull the figure into the body §6 (Discussion) showing pre/post penalty $\hat\nu_k$ distribution at $K=18$. |
| **P6.2** Spectral decomposition contribution table | `results/diagnostics/spectral_rank.txt` — full per-mode contribution at $K=18$ already computed | Add a small body table at the end of [§3 Theory](sections/theory.tex) showing the top 5 non-unit eigenvalues' contributions and the cumulative lag-1 weight. |
| **P6.3** Pre-registered $K$-selection table | `results/k_selection_validation/` — held-out criteria for AIC/BIC/HQC/CAIC/held-out LL/held-out KS already computed on both held-out slices | Add a single body table to [§5.1](sections/results.tex) showing $K^\star$ chosen by each criterion on each slice. |
| **P5.1** (also Phase 1) Cross-asset OoS MAE pairing | `results/cross_asset/` — both static and quarterly-rolling MAE already in appendix | Already in Phase 1. |
| **R3.W6** ML HSMM is already a body row | `results/hsmm_ml/` — `tab_model_comparison` row already present | No change beyond P3.3 below; existing row is honest. Add a one-sentence caveat in body that higher-$K$ HSMM degeneracy is a deferred direction. |
| **R3 cross-asset broadening** | `results/non_equity_validation/` — GLD and SLV already computed with explicit OoS-KS=0% disclosure in appendix `sec:non_us_asset_supp` | Add a one-paragraph body acknowledgment that the cross-asset construction is scoped to US equities, citing the GLD/SLV appendix as the negative result. |

**Cost:** ~3 hours (mostly building two new body tables from existing CSV/txt files plus one figure inclusion).

---

## Phase 3 — New computation required (in CHMM-Model)

These items genuinely require new simulations. Each maps to a new or modified script under [`../CHMM-Model/run_*.jl`](../CHMM-Model). Estimated wall-time per item is rough.

| Item | Scope | Script (new or modified) | Wall-time est. |
|------|-------|-------------------------|----------------|
| **P1.3** Held-out CV of $\lambda$ | Refit penalised CHMM-t on strictly pre-2020 slice (2014–2019); sweep $\lambda \in \{0,5,20,50,100,200\}$; pick $\lambda^\star$ by held-out LL on 2018-07–2019-12; confirm whether $\lambda=20$ stands. | New: `run_lambda_cv_pre2020.jl` | 1–2 h |
| **P2.1** Cross-ticker spectral effective-rank | For each of the 30 tickers at $K=18$: compute the dominant non-unit eigenvalue's contribution to the lag-1 absolute-return ACF; report cross-ticker distribution. | Modify `run_diagnostics.jl` to loop over the panel | 30–60 min |
| **P3.2** MSSV (Carvalho–Lopes) baseline | Particle-MCMC fit of a 2-state Markov-switching stochastic volatility model on SPY IS; simulate 1,000 paths; compute KS / kurtosis / ACF-MAE for body Table 1. | New: `run_mssv_baseline.jl` (uses `Turing.jl` particle Gibbs or PMMH) | 4–8 h |
| **P3.3** Stabilized HSMM at $K\in\{6,9,12\}$ | Add an L2 ridge on transition logits + truncated-Pareto sojourn shape clipping to prevent the degenerate-optimum collapse documented at [results.tex line 59](sections/results.tex#L59); re-fit HSMM-N at intermediate $K$. | Modify `run_hsmm_ml.jl` | 2–4 h |
| **P4.1** Block-aware KS for body Table 1 | Already computed for GARCH/CHMM in `results/diagnostics/block_bootstrap/`; needs extension to all body rows at a single block length ($L=10$). | Modify `run_full_rebuild.jl` block-bootstrap section | 30 min |
| **P4.2** DM bandwidth sensitivity | Sweep Newey–West HAC bandwidth $h \in \{4,8,16,32\}$ on the existing CRPS DM tests. | Modify `run_crps_dm.jl` | 15 min |
| **P4.3** Exact-binomial Kupiec | Replace asymptotic-LR Kupiec with exact-binomial coverage tests at $T_\text{OoS}=572$; report alongside in [§5.4 Table tab_cond_var](sections/var_backtest.tex). | Modify `run_christoffersen_var.jl` | 15 min |
| **P4.4** Effective state distinctness | At $K=18$ on SPY: compute pairwise distance matrix between $(\hat\mu_k,\hat\sigma_k,\hat\nu_k)$ triples and report effective number of distinct states by single-linkage clustering. | New: short `run_state_distinctness.jl` (uses fitted CHMM checkpoint) | 15 min |
| **P5.2** Monthly refit row | Re-run cross-ticker panel with monthly (not quarterly) refit cadence. | Modify `run_cross_ticker_penalised.jl` to add monthly cadence | 1–2 h |

**Items deferred / not feasible without new data:**
- **P2.2** Independent-decade replication on **1994–2004** SPY. The `subdecade_validation.txt` already runs the in-window 5-year split (config A: 2014–2019 IS / 2019–2024 OoS, which spans COVID and 2022 rate-hike). The pre-2014 1994–2004 SPY data is not in the current data pipeline (Polygon coverage starts later). **Recommendation:** present the existing in-window 5-year split as the formal sub-decade replication; flag the pre-2014 cross-decade as a documented limitation rather than a deferred follow-up.
- **R3.Q4** Cross-asset universe broadening to rates/FX. Same data-availability constraint. **Recommendation:** keep the existing GLD/SLV negative result in the appendix and scope the cross-asset claim to "US equity universe" in the abstract.

**Cost:** ~1 day of computation if all items run sequentially; most can run in parallel.

---

## Execution order

1. **Phase 1** (now). Title, abstract, headline reframing, table captions, minor edits. These are all ready to commit.
2. **Phase 2** (after Phase 1). Body integration of existing appendix material — two new body tables, one figure relocation.
3. **Phase 3** (delegated). Requires running scripts in CHMM-Model. The cheap items (P4.1, P4.2, P4.3, P4.4, P2.1) can be run as a single batch; the expensive items (P3.2 MSSV, P1.3 λ CV, P3.3 stabilized HSMM, P5.2 monthly refit) will be the substantive work.

## Acceptance criteria

After Phase 1+2, the body table headline is at $K^\star=6$, the cross-asset OoS degradation is paired with the IS number in the abstract, the walk-forward summary is in the body, MS-GARCH at $K \in \{3,6\}$ appears in the body benchmark block, and the spectral effective-rank claim is supported by the cross-ticker distribution.

After Phase 3, the penalty hyperparameter is held-out-clean, an MSSV baseline exists, the HSMM comparison is no longer asymmetric in $K$, and statistical diagnostics (block-aware KS, DM bandwidth, exact-binomial Kupiec) are reported.

The combination addresses all P1–P5 priority items and the substantive R1/R2/R3 weaknesses; aggregate recommendation should move from Major Revision to Minor Revision.
