# CONDENSE_PLAN — Trim Main Body to 15 Pages and Prune Supplementary

Date: 2026-05-03
Current state: `paper.pdf` is 76 pages total. Main body (Intro through Conclusion, before
bibliography) occupies pages 1–21. Bibliography is pages 22–27. Supplementary/appendix
runs pages 28–76 (49 pp).

Target: cut main body from 21 pp to 15 pp without altering the contribution narrative,
prune ~10–15 pp of supplementary that is either redundant with the main body, redundant
with another appendix, or weakly load-bearing for the paper's stated strengths.

---

## 1. Diagnosis: where the 21 pp goes

Per-section LaTeX line counts (after the recent rebuild) and approximate page footprint:

| Section | Lines | Floats | Approx pp | Notes |
|---|---|---|---|---|
| Introduction | 15 (one block of long paragraphs) | 0 | ~3.0 | Para 5 alone ~1 pp; Para 9 ~1 pp; Para 11 ~0.5 pp |
| Related Work | 20 (7 paragraphs) | 0 | ~1.5 | "Signature/diffusion" + "Online change-point" are recent additions |
| Methods (Model + Estimation + Theory) | 98 + 51 + 34 | 1 fig + 1 tab | ~5.0 | Architecture TikZ figure consumes ~0.5 pp; spectral_modes table ~0.4 pp |
| Results | 172 | 4 tabs | ~6.0 | Largest block; ML-HSMM, block-bootstrap, cross-decade narrative paragraphs add up |
| VaR backtest | 51 | 1 tab | ~2.0 | Power-caveat paragraph alone ~0.4 pp; cond_var table is wide |
| Discussion | 37 | 1 tab | ~2.0 | Several paragraphs paraphrase Results / Intro |
| Conclusion | 12 | 0 | ~1.0 | Mostly restates Intro paragraph 9 verbatim |
| **Sum** | | | **~20.5** | matches observed 21 pp |

The 6-pp deficit lives mostly in three places: long *narrative* paragraphs in
Introduction, near-duplicate *recap* paragraphs in Discussion / Conclusion, and a
results section that shoulders four tables plus four standalone "robustness" prose
paragraphs that belong in the appendix.

The contribution narrative is fixed across the paper as four points:
(i) spectral-rank empirical recasting of Rydén; (ii) unified ECM scaffold across four
emission families; (iii) regime-conditional VaR that passes Christoffersen-cc; (iv)
empirical scope along three orthogonal generalisation axes. Every cut below preserves
all four; the trims are to the *re-statements* of these claims, the *robustness
paragraphs* that already point to the appendix, and *defensive footnoting* that grew
across multiple revisions.

---

## 2. Main-body cuts (target: −6 pp, end at 15 pp)

Cuts are listed in order of confidence and ordered roughly by how much each one buys.
Total estimated savings: 6.5–7.5 pp (slight buffer to absorb post-edit reflow).

### 2.1 Introduction trim — target −1.5 pp

The introduction currently runs five very long paragraphs (4–11) plus a contribution
list (12) plus a roadmap (13). Several blocks pre-litigate findings before the reader
has seen any data.

- **Paragraph 5 ("We identify the binding axis…")**: keep the first three sentences
  (the rank statement and the empirical effective-rank result). Drop the long
  "At $K = 2$ both axes bind…the operationally informative comparison…" block —
  this is a two-axis taxonomy that gets fully covered in §3.3 (Theory) and §5.1
  (Discussion's "Replicating the slow-ACF behaviour" paragraph). Estimated −0.4 pp.
- **Paragraph 9 (the headline-numbers paragraph)**: this is the single longest
  paragraph in the paper. It currently lists every cell of `tab:model_comparison`,
  the kurtosis points of all four variants, the per-state $\nu_k$ pinning artefact
  *and* its remedy, the walk-forward median, the $K^\star = 6$ sensitivity, and the
  VaR/ES envelope — all before the reader has seen any of these tables. Trim to:
  the body operating point ($K^\star = 3$, single sentence), one headline number
  per claim (CHMM-N OoS KS, $|G_t|$ ACF-MAE, conditional-VaR pass), a one-sentence
  walk-forward caveat, and one sentence pointing to Table 1. Move all variant-by-
  variant cells, the $K = 18$ sensitivity numbers, and the $\nu_k$ pinning artefact
  discussion to where they already live (§4.1 and §5). Estimated −0.8 pp.
- **Paragraph 11 (cross-asset / cross-ticker)**: tighten by half. Drop the
  parenthetical sample-design caveat ("the sample design is 10 GICS sectors × 3 …
  itself one design choice among many") and the per-sector ticker enumeration
  (Utilities, IT, Consumer Staples, Health Care). Both reappear verbatim in §4.4
  and §4.5. Estimated −0.3 pp.

### 2.2 Discussion trim — target −1.0 pp

Discussion is currently 6 paragraphs, of which 3 paraphrase Results.

- **Drop the opening paragraph** ("A continuous HMM trained by Baum-Welch reproduces
  the three Cont stylized facts…"). It is a summary of §4.1's headline that the
  reader has just read; the *next* paragraph ("Replicating the slow-ACF behaviour
  at $K \ge 3$") is the actual discussion. −0.3 pp.
- **"Closing the kurtosis gap with heavy-tailed emissions"**: keep the substantive
  content (the bracket-pinning story, the $\lambda = 20$ choice, the four
  variant-decision rows) but drop the bootstrap-CI sentence and the "bracket-lift
  ablation" pointer — both already pointed to from Results. −0.2 pp.
- **"Computational cost and parameter parsimony"**: keep one sentence (the
  parameter-count comparison vs. QuantGAN). Drop the wall-clock timing, the
  `run_full_rebuild.jl` reference (already in `\paragraph{Data and code
  availability}` of Conclusion), and the per-K iteration cost. −0.3 pp.
- **`tab:variant_choice`**: keep the table (it is the single artefact a practitioner
  reads from this section). Drop the "Caveat" line of the caption — the IS/OoS
  kurtosis-CI overlap is already in §4.1. −0.05 pp.

### 2.3 Conclusion compression — target −0.7 pp

The conclusion's first paragraph is essentially a verbatim copy of Introduction's
contribution paragraph plus headline numbers. The second paragraph (cross-ticker,
copula) restates §4.4–4.5. The third (companion-paper directions) restates §5
"Limitations". Conclusions reading like rebooted introductions is a real flaw at
arXiv triage.

- Compress to ~12–18 lines: one paragraph stating what the paper showed (≤6 lines,
  one headline per contribution), one paragraph on the deployment scope and limits,
  one paragraph on the Data/Code availability + author contributions block. Drop
  every per-cell number; readers who want them have just finished §4. −0.7 pp.

### 2.4 Move "robustness" paragraphs out of Results — target −1.5 pp

Four paragraphs in Results function as appendix forwarders that read appendix
content into the body before pointing to the appendix. They should be one-sentence
forwards.

- **"Block-aware OoS KS recalibration" subsection (§4.2)** including
  `tab:ks_block_body`: this is a robustness recalibration that does not change the
  cross-generator ranking; the substantive operating-point remains the asymptotic
  KS row of Table 1. Move the entire subsection (prose + table) to
  Appendix `\ref{sec:ks_block_bootstrap}` (it already lives there in extended form).
  Replace in body with one sentence in §4.2 immediately before
  `\subsection{Cross-Ticker Generalization}`: "A block-bootstrap KS recalibration at
  $L = 20$ preserves the cross-generator ordering and is reported in
  Appendix~\ref{sec:ks_block_bootstrap}." Estimated −1.0 pp (table + paragraph).
- **"Power caveat at $\alpha = 0.01$" paragraph (§4.6, var_backtest.tex)**: this is
  a very long footnote that interrupts the headline result. Compress to two
  sentences in body: "The Christoffersen-cc test is power-bounded at $\alpha = 0.01,
  T_{\text{OoS}} = 572$; the Engle–Manganelli DQ test rejects $K = 18$ at
  $\alpha = 0.01$ ($p = 0.017$); the substantive risk-management diagnostic is the
  $\alpha = 0.05$ row, which DQ also passes. Calibration in
  Appendix~\ref{sec:christoffersen_power}." Move the long-form discussion to the
  appendix (it is already in `sec:engle_manganelli_dq`). −0.4 pp.
- **"Per-state interpretability" + "Bootstrap as a non-parametric synthetic-data
  benchmark" + "ML HSMM as a co-headline result"**: these three paragraphs together
  span ~0.8 pp. Keep "ML HSMM as a co-headline result" (it is honest positioning
  that the paper depends on); compress "Per-state interpretability" to two
  sentences (the $\mu_k, \sigma_k$ table is at the conventional volatility axis;
  the bimodal $\hat p_k$ partition mirrors the same axis); compress "Bootstrap as
  a non-parametric synthetic-data benchmark" to two sentences (it is mostly a
  re-statement of the four-line "Methods notes for Table 1" paragraph that already
  precedes Table 1). −0.3 pp.

### 2.5 Cross-asset section (§4.5) trim — target −0.7 pp

The cross-asset paragraph (§4.5) is 30 lines, plus `tab:cross_asset` (large), plus
a follow-up "$2/6$ failure rate" paragraph.

- Drop the "One additional caveat on the dependence-layer estimator…full one-shot
  MLE" block — this is robustness against a specific reviewer concern; it is fully
  in `sec:full_tcopula_mle` and the body sentence pointing to it suffices. −0.2 pp.
- Drop the "non-equity stress test on GLD and SLV" prose sentence in the body
  paragraph (it appears verbatim already in Conclusion and in the Limitations
  paragraph of Discussion, plus in Introduction). Keep one mention only — Discussion
  is the right place. −0.15 pp.
- Compress `tab:cross_asset` to its top-half: the per-asset KS rows (6 tickers) and
  the Off-diag MAE summary. Drop the "Median / Tickers OoS KS < 60%" footer rows;
  they are computable from the rows above and the "tickers OoS < 60%" framing is
  already in the §4.4 cross-ticker table. −0.15 pp.
- Compress the closing paragraph ("The cross-asset median OoS KS of 85.8% obscures
  a bimodal distribution…") from 8 lines to 3. The NVDA/JPM specifics belong in
  the cross-asset appendix per-asset attribution. −0.2 pp.

### 2.6 Methods (Model / Estimation / Theory) compression — target −0.8 pp

- **`sec:benchmarks` paragraph in `model.tex`**: this paragraph reads as an
  expanded captioning of `tab:model_comparison`. It enumerates every benchmark
  twice (i.i.d. bootstrap, Gaussian/Laplace i.i.d., GARCH-Gaussian/-t, MS-GARCH,
  EGARCH/GJR-GARCH/HAR-RV/MS-GARCH-K, SM-CHMM, QuantGAN, SV, MSM, Merton-JD).
  Cut to two sentences naming only the body-table rows; the extended panel
  enumeration belongs in `sec:extended_baselines` (where it already is). −0.2 pp.
- **`sec:cross_asset_methods` paragraph in `model.tex`**: trim the rank-reordering
  derivation to a one-line summary plus a pointer to `sec:supp_cross_asset`. The
  Sklar/Iman-Conover/Embrechts-Lindskog-McNeil citations belong in the appendix
  derivation; the body needs only "rank-based Student-$t$ copula on the per-asset
  CHMM marginals; profile MLE selects $\nu^\star$." −0.2 pp.
- **CHMM architecture TikZ figure (`fig:chmm_architecture`)**: keep but shrink.
  Currently the figure occupies ~0.5 pp. The four-emission row at the bottom is
  redundant with the inline `\emph{CHMM-N}…\emph{CHMM-GED}` enumeration in the
  preceding paragraph; drop the four `emit` boxes and keep the Markov chain +
  emission glyphs + EM loop. −0.2 pp.
- **`tab:spectral_modes` in `theory.tex`**: this 6-row table illustrates the
  mode concentration on SPY at $K = 18$. Keep the body claim ("$93.6\%$ on the
  dominant mode"); move the table to `sec:spectral_rank` in the appendix
  (where it is already cited from). −0.2 pp.

### 2.7 Related Work tightening — target −0.3 pp

Related Work is already short (≤1.5 pp), but the "Signature- and diffusion-based
market generators" paragraph (added in the recent ARXIV_PREP pass) and the "Regime
breaks and online change-point detection" paragraph together occupy ~0.4 pp and are
the least-load-bearing for the paper's contribution. Keep one of the two; merge the
other into a single sentence inside the GAN/deep-generative paragraph. −0.3 pp.

### 2.8 Walk-forward body table — keep, but compress note

`walkforward_body_table.tex` is small (5 rows, headline summary). Keep as-is. The
caption can drop the second sentence ("the W2 (COVID) and W4 (2022 rate-hike onset)
folds are out-of-distribution by KS for every generator in the panel") which is a
substantive claim that already appears three times in the body. −0.05 pp.

### 2.9 Summary of cuts

| Cut | Estimated pp |
|---|---|
| Intro paragraphs 5, 9, 11 trim | −1.5 |
| Discussion: drop opening paragraph + compress kurtosis/computational paragraphs | −0.85 |
| Conclusion: rewrite to 12–18 lines | −0.7 |
| Move block-bootstrap KS recalibration table+prose to appendix | −1.0 |
| Compress VaR power-caveat paragraph | −0.4 |
| Compress per-state interp / bootstrap / HSMM paragraphs | −0.3 |
| Cross-asset section trims | −0.7 |
| Methods compression (benchmarks + copula derivation + figure shrink + spectral table move) | −0.8 |
| Related Work tightening | −0.3 |
| Walk-forward caption note | −0.05 |
| **Total** | **−6.6 pp** |

This delivers ~14.4 pp of body, leaving ~0.6 pp of buffer for post-edit reflow.

---

## 3. Supplementary pruning

Current supplementary spans pages 28–76 = 49 pp across the following sub-files:

| Sub-file | Lines | Approx pp | Substantive content |
|---|---|---|---|
| supplementary.tex (the wrapper) | 428 | ~13 | API + propositions + spectral derivation + walk-forward / per-ticker tables |
| algorithms_appendix.tex | 256 | ~6 | EM forward-backward derivation, M-step pseudocode, $\nu_k / p_k$ diagnostics, pipeline schematic |
| metrics_appendix.tex | 141 | ~4 | KS/AD/Kurt/ACF-MAE/W1/Hellinger/Quantile/cross-asset definitions, CRPS-DM, Christoffersen panel, VaR/ES viz |
| sensitivity_appendix.tex | 555 | ~16 | $K$-sweep, sector panel, spectral effective-rank, Rydén $K=2$, $K^\star$ panels, kurtosis CI, shared-$\nu$, Christoffersen power, DQ test, refit-cadence sweeps, GED $\hat p_k$, HSMM, VaR/ES envelope, $\lambda$-CV, distinctness, DM bandwidth, monthly-refit, cross-decade |
| baselines_appendix.tex | 234 | ~7 | KS power, block-bootstrap, QuantGAN, expanded GARCH+SM-CHMM panel, SV/MSM/Merton-JD, leverage, full t-copula MLE |
| cross_asset_appendix.tex | 211 | ~5 | Sklar/Kendall derivation, profile-LL, heat maps, C-vine, quarterly refit, GLD/SLV, half-unit grid |

Total: 49 pp. Below are recommended drops/merges, ordered by load-bearing rank
(strongly drop → consider drop). Estimated savings: 10–15 pp.

### 3.1 Strong drop candidates (~7–9 pp)

These are appendices that exist either as redundant restatements of the body, or as
defensive material for findings that the body now downplays.

1. **`sec:supp_chmm_api` (CHMM-Model.jl Public API and Reproducer)** — *drop*.
   The Conclusion already carries a "Data and code availability" paragraph with the
   GitHub URLs. The eight-line Julia code block, the seed-derivation prose, and the
   `Manifest.toml` mention belong in the companion repository's README, not in the
   paper appendix. (~1 pp). Replace with a one-line pointer in `\paragraph{Data
   and code availability}`.

2. **`sec:supp_propositions` numerical full-rank check on $\hat{\mathbf T}$** —
   *drop the table* (`tab:t_singular_values`), keep the surrounding propositions.
   The numerical-rank values are not cited from the body except for the
   `rank(\hat T - 1\bar\pi^\top) = K - 1` claim, which is a one-sentence assertion
   that does not need a table. (~0.4 pp).

3. **`sec:supp_spectral_acf` extended derivation** — *condense*.
   The six-step proof of the bilinear identity is folklore (the appendix even cites
   Hamilton 1994 §22.2, Krolzig 1997 Ch. 3, Timmermann 2000 as the original
   sources). For an arXiv paper that recasts a classical result, a half-page
   restatement of the identity with citation suffices; the six numbered steps,
   the lag-zero remark, the squared-return analogue, the complex-eigenvalue
   remark, and the non-diagonalisable remark are textbook material. Keep the
   theorem statement and one-paragraph "spectral-projector" derivation; drop
   Steps 2, 4, 5, 6 detail and the four post-theorem remarks. (~2 pp savings).

4. **`sec:supp_cross_asset` C-vine subsection (cross_asset_appendix.tex L108–130)** —
   *drop*. The body §4.5 already establishes that on OoS the dependence-family
   choice is statistically null at $N_{\text{paths}} = 200$; the C-vine row in
   `tab:cross_asset_supp_summary` already provides one number for completeness.
   The full C-vine edge enumeration table, sequential-fit description, and
   first-order vs. truncation discussion are not cited from anywhere outside this
   subsection. (~1 pp).

5. **`sec:full_tcopula_mle` (baselines_appendix.tex L209–234)** — *drop*.
   This was added to defend the body two-step copula estimator against a specific
   reviewer concern. The result ("$\hat\nu_{\text{full}} = 6.40$ vs body $6.00$,
   all $|\Delta\rho_{ij}| \le 0.025$") is one sentence that fits in the body
   §4.5 cross-asset paragraph or in the cross-asset appendix's profile-LL
   subsection. (~0.5 pp).

6. **`sec:hsmm_gamma_sojourn` (Gamma-Sojourn HSMM)** — *consider drop or merge*.
   The body now positions ML HSMM as a co-headline (Pareto sojourn at $K^\star=3$,
   $91\%$ OoS KS); the Gamma-sojourn extension at $K = 18$ is companion-paper
   territory. One sentence in §4.1's "ML HSMM as a co-headline" paragraph —
   "Gamma-sojourn variants at higher $K$ are deferred to companion work" —
   covers the same ground. (~0.5 pp).

7. **`sec:cross_ticker_monthly_refit` (Monthly-Refit Cross-Ticker Panel)** —
   *drop*. The body and the quarterly-refit appendix already establish the
   refit-cadence trade-off; the monthly row adds a single $86.7\% / 5/30$ data
   point that does not change any qualitative reading and that the body's
   "approximately linear in log(cadence)" footnote already covers. (~0.4 pp).

8. **`sec:walkforward_refit_cadence` (Walk-Forward Refit-Cadence Sweep,
   sensitivity_appendix.tex L313–355)** — *condense to a paragraph*.
   The substantive finding is that "monthly and weekly refits do not close the
   W2 stress-fold rejection." That is a one-sentence claim the body Conclusion
   already states. The full per-cadence table is companion-paper detail. (~0.6 pp).

9. **`sec:supp_misc` per-ticker $\hat\lambda^\star$ sweep table
   (`tab:per_ticker_lambda`)** — *consider drop*.
   The body's recommendation is "uniform $\lambda = 20$ is a reasonable default;
   per-ticker tuning is recommended." The six-row table illustrates this with one
   ticker's worth of variation across the bracket. The result ($\lambda^\star \in
   \{0, 10, 10, 20, 10, 20\}$) is not used downstream; either replace with one
   sentence or drop entirely. (~0.4 pp).

### 3.2 Consider-drop candidates (~3–5 pp, lower confidence)

These are defensible to keep, but if a reviewer asks why the appendix is 49 pp,
they are the next tranche.

10. **`sec:k_selection_hac` (HAC-corrected $K$-selection inference)** —
    *condense the table*. The substantive read is that the $K = 6$ vs $K = 3$
    statistic stays insignificant under HAC correction; the $K = 18$ vs $K = 6$
    moves from borderline to decisive. Two sentences plus the two HAC $|z|$
    numbers replace the 6-row table. (~0.3 pp).

11. **`sec:dm_bandwidth` (Diebold–Mariano Bandwidth Sensitivity)** —
    *consider drop*. The body §4.1 cites this as "the within-CHMM family
    equivalence is not bandwidth-fragile" — a one-sentence claim. The appendix
    paragraph adds three $p$-value ranges; if the reader believes the body
    claim, the appendix isn't needed. (~0.2 pp).

12. **`sec:state_distinctness` (Effective State Distinctness at $K = 18$)** —
    *consider drop*. Two sentences in the body / discussion already cite the
    $K_{\text{eff}}$ bound; the standalone subsection adds the construction
    detail (single-linkage clustering on standardized parameter triples). The
    construction is one method choice among many. (~0.2 pp).

13. **`sec:supp_var_envelope` (Unconditional VaR / ES Envelope Panel)** —
    *consider keeping but slim the table*. The 7-row × 4-column unconditional
    VaR/ES table for SPY is the supporting artefact for the body's
    "(i) Envelope bracketing" paragraph in §4.6. The IS-block versus OoS-block
    duplication (each with VaR$_{0.01}$, ES$_{0.01}$, VaR$_{0.05}$, ES$_{0.05}$)
    can be folded into a single block with a "win/loss" coding. (~0.4 pp).

14. **`sec:cross_decade_validation` (CRSP 1994–2006)** —
    *consider keeping but trim*. The body cites this as a third generalisation
    axis. The full table is large; the 5-row "this is the cross-decade
    pattern" claim could be one short table plus one paragraph instead of the
    current ~30-line subsection with two tables. (~0.5 pp).

15. **`sec:non_us_asset_supp` (GLD / SLV non-equity stress test)** —
    *keep*. This is one of the paper's honest-positioning anchors and the body
    explicitly invokes it ("scope claim does not extend to other asset classes").
    Do not cut; trim the GLD-specific Pipeline-A descriptive numbers paragraph by
    half if needed. (savings: minor).

### 3.3 Keep without modification

These appendices are load-bearing and should not be touched in a 15-pp reduction:

- `sec:supp_algorithms` (forward-backward + M-step pseudocode) — necessary for
  reproducibility; the body relies on these recursions.
- `sec:supp_metrics` (KS/AD/Kurt/ACF-MAE/W1/Hellinger/CRPS definitions) — referenced
  by every body table.
- `sec:supp_propositions` (formal Assumptions 1–2, identifiability, MLE
  consistency, marginal preservation) — needed for §3.3 (Theory) to be self-
  contained.
- `sec:supp_sensitivity` $K$-sweep table, sector-balanced 30-ticker rollup,
  spectral effective-rank diagnostic, cross-ticker spectral diagnostic, Rydén
  $K = 2$ replication — these underwrite four distinct body claims and are
  individually small.
- `sec:christoffersen_power` (Monte Carlo power calibration) and
  `sec:engle_manganelli_dq` (DQ test) — both load-bearing for the
  conditional-VaR headline; the body proposed cut to the power-caveat paragraph
  *increases* the appendix's load-bearing weight, not decreases it.
- `sec:supp_p_partition` (CHMM-GED $\hat p_k$ partition) — the most distinctive
  empirical finding of the four-emission scaffold, cited from §4.1 and §5.2.
- `sec:cross_ticker_quarterly_refit` (the quarterly-refit recipe) — the body
  recommends quarterly refit as the deployment recipe; this is the supporting
  data.
- `sec:extended_baselines` (GARCH family + SM-CHMM + QuantGAN) — referenced as
  the extended panel in the body table caption.

### 3.4 Summary of supplementary cuts

| Cut | Estimated pp |
|---|---|
| §3.1 strong drops 1–9 | −7 to −9 |
| §3.2 consider-drops 10–14 | −2 to −3 |
| **Total** | **−10 to −12 pp** |

End state: supplementary at ~37–39 pp, main body at 14–15 pp, bibliography 6 pp,
total paper ~57–60 pp. Hits the ARXIV_PREP target ("trim to ~50–60 pp").

---

## 4. Implementation order

Recommend executing in this order — each step independently buildable, so progress
can be measured against page count after each commit.

**Phase 1 — quick wins, high confidence (one editing pass each):**
1. Conclusion rewrite (§2.3) — single file, pure prose. Verify body still reads.
2. Discussion: drop opening paragraph + compress kurtosis/cost paragraphs (§2.2).
3. Move `tab:ks_block_body` and the surrounding subsection from `results.tex` to
   the corresponding appendix subsection (§2.4 first item).
4. Compress VaR power-caveat paragraph (§2.4 second item).
5. Drop `sec:supp_chmm_api` (§3.1 item 1).

**Build, measure: should be at 17–18 pp after Phase 1.**

**Phase 2 — Introduction and Methods (medium-effort prose pass):**
6. Introduction trims (§2.1).
7. Methods compression: benchmarks paragraph + cross-asset paragraph + figure
   shrink + move `tab:spectral_modes` to appendix (§2.6).
8. Related Work tightening (§2.7).

**Build, measure: should be at 15–16 pp after Phase 2.**

**Phase 3 — Results polish:**
9. Cross-asset section trims (§2.5).
10. Per-state interpretability + bootstrap + HSMM paragraph compression
    (§2.4 third item).

**Build, measure: should be at 14–15 pp after Phase 3.**

**Phase 4 — Supplementary pruning (if main body is at target):**
11. §3.1 items 2–9 in order. Each is a self-contained subsection drop or condense.
12. §3.2 items 10–14 only if Phase 4 doesn't get the supplementary into target.

**Verification at every phase:**
- Run `make` (or `latexmk paper.tex`) after each commit. Watch `paper.log` for
  the "Output written on paper.pdf (NN pages, …)" line.
- Search for newly-broken `\ref{}` after every move (`grep -rn '\ref{sec:label}'`
  on any sec-label that was relocated).
- The cuts should not change a single number in any table; only remove text and
  relocate floats. If a reviewer questions a removed claim, the body pointer + the
  appendix preserves the underlying data.

## 5. What the cuts do *not* touch

The four contributions are preserved verbatim:
- The spectral-rank empirical recasting (§3.3 Theory keeps the identity, the
  $K$-rank statement, and the empirical effective-rank claim).
- The unified ECM scaffold across four emission families (§3.1–3.2 Model and
  Estimation keep the four M-step paragraphs and the architecture figure,
  shrunk).
- The regime-conditional Christoffersen-cc VaR (§4.6 keeps Eq. (filter), the
  conditional-VaR construction, and `tab:cond_var`).
- The three-axis empirical scope (§4.4 cross-ticker, §4.5 cross-asset, the
  walk-forward body table all kept).

The honest-positioning anchors are preserved:
- "ML HSMM matches/exceeds CHMM on raw OoS KS" (kept in §4.1).
- "i.i.d. bootstrap is the non-parametric ceiling" (kept in §4.1, just compressed).
- "GLD/SLV non-equity collapses to 0% OoS KS without refit" (kept in Discussion).
- "Walk-forward W2/W4 stress folds reject regardless of refit cadence" (kept in
  Discussion).
