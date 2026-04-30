# Paper Changelog

Accumulating record of substantive changes across paper versions.
Newest version on top. For the full paper content, see `Paper_vN.tex` and
the matching `sections/*_vN.tex` files.

---

## Peer-Review Revision Pass (2026-04-29)

Revision pass against the simulated peer review in `peer-review.md`. Reviewer
panel returned 1 Minor Revision / 2 Major Revision; aggregate **Major Revision**.
Plan tracked in `REVISION_PLAN.md`.

### Phase 1 (text-only)
- Title trimmed: "A Continuous Hidden Markov Model as a Reference Synthetic-
  Data Generator for Equity Returns" (dropped redundant "Regime-Switching"
  qualifier per R3.M4).
- Abstract reframed: $K^\star = 6$ leads as held-out-clean body headline;
  $K^\star = 3$ reported alongside as risk-management default; $K = 18$
  explicitly relabeled as a sensitivity reference.
- Cross-asset claim scoped to a US-equity universe; OoS off-diagonal MAE
  (0.209 static / 0.185 quarterly refit) paired with the IS value (0.027)
  in abstract and intro.
- Long single-paragraph intro broken into three paragraphs (problem
  statement / mechanism / cross-asset and cross-ticker).
- Yu (2010) HSMM citation formalised; complex-eigenvalue parenthetical
  added after equation (5).
- Diebold-Mariano within-CHMM equivalence reframed as interchangeability
  (R3.M2).
- Conclusion rewritten to lead with $K^\star = 6$.
- Table 2 (cond_var) caption clarified to state IS-fixed parameters.

### Phase 2 (pull existing computation into body)
- New body table `tab:k_selection`: pre-registered $K^\star$ across
  {AIC, BIC, HQC, CAIC, held-out LL, held-out KS} on both held-out slices.
- New body table `tab:walkforward_body`: 6-fold rolling-origin summary.
- New body table `tab:spectral_modes`: leading non-unit eigenvalue
  contributions to the lag-1 absolute-return ACF at $K = 18$ on SPY.
- Added MS-GARCH at $K \in \{3, 6\}$ rows to body Table 1
  (previously appendix-only).
- Body Table 1 leading $\star$ marker on $K^\star = 6$ block.

### Phase 3 (new computation in CHMM-Model)
- **P1.3 (held-out $\lambda$ CV)**: confirmed $\lambda^\star = 20$ on
  pre-2020 validation slice; matches body operating point. New appendix
  subsection `sec:lambda_cv_pre2020`.
- **P2.1 (cross-ticker spectral rank)**: 30-ticker re-run gives median
  dominant-mode share 0.756 (SPY's 0.94 is right-tail). Abstract,
  intro, and theory section now read at the cross-ticker median rather
  than the SPY headline. New appendix subsection `sec:spectral_rank_xticker`.
- **P3.2 (MSSV baseline)**: 2-state Hamilton-Kim-Nelson quasi-MLE
  collapses to near-absorbing regime structure (documented negative
  result; full PMMH deferred). New appendix subsection `sec:mssv_baseline`.
- **P3.3 (stabilized HSMM at intermediate $K$)**: $K = 6$ clean
  (95.9% IS / 89.8% OoS KS); $K = 9, 12$ degenerate. HSMM scaffold
  has a $K \le 6$ practical limit on $T_\text{IS} = 2,516$. New appendix
  subsection `sec:hsmm_intermediate`.
- **P4.2 (DM bandwidth sensitivity)**: within-CHMM equivalence robust
  across $h \in \{4, 8, 16, 32\}$. New appendix subsection
  `sec:dm_bandwidth`.
- **P4.3 (exact-binomial Kupiec)**: exact and asymptotic $p$-values
  agree within 0.07 on all rows. New appendix subsection
  `sec:exact_binomial_kupiec`.
- **P4.4 (state distinctness)**: at $K = 18$, CHMM-N collapses to
  $11/18$ effective states; CHMM-t to $12/18$ with $13/18$ pinned at
  $\nu_\text{max}$. Honest concession in body discussion. New appendix
  subsection `sec:state_distinctness`.
- **P5.2 (monthly refit)**: in progress at writing.
- **P2.2 (1994-2004 SPY)**: deferred (data not in pipeline); existing
  in-window 5-year sub-decade split covers cross-decade transfer.
- **R2.W1 / R1.W1 / R3.RE1 (reference MS-GARCH)** (2026-04-30): closed.
  Re-run the Markov-switching GARCH(1,1) baseline at $K \in \{2, 3, 4\}$
  through the canonical \texttt{MSGARCH} R package (Ardia et al.\ 2019, JSS;
  version $2.51$), driven from the Julia harness via \texttt{RCall.jl}.
  Fully Bayesian DEMC sampler, $12{,}500$ MCMC draws, $2{,}500$ burn-in,
  thin $10$, single chain; $1{,}000$ posterior-predictive paths per $K$
  (one path per retained posterior draw) so the simulated marginal
  integrates parameter uncertainty path-by-path. Reproducibility pinned
  via \texttt{renv} (\texttt{r\_msgarch/renv.lock}, $11$ R packages plus
  R $4.6.0$); explicit seed at every entry point.
  Headline numbers (\texttt{results/msgarch\_reference/metrics.csv} of
  the companion code repository): IS KS $0.0\%$ ($K = 2$), $0.1\%$
  ($K = 3$), $0.0\%$ ($K = 4$); OoS KS $5.8\%, 5.1\%, 5.3\%$;
  posterior-mean LL $-5{,}667, -5{,}667, -5{,}565$. Lower KS than our
  in-house frequentist Nelder-Mead fit ($27$--$37\%$ IS plateau) is
  methodological inflation from posterior-predictive variance, not
  estimator regression: the in-house simulates $1{,}000$ paths from one
  MLE point estimate, while the Bayesian re-run samples one set of
  parameters per path from the posterior. The body conclusion ``the
  multi-state benefit is specific to the CHMM scaffold rather than to
  multi-state regime-switching per se'' is therefore robust to estimator
  choice on this dataset under either flavour.
  Paper edits: three new rows in body Table~\ref{tab:model_comparison}
  (\texttt{sections/results.tex}, marked $\P$); body sentence at
  \texttt{sections/results.tex} extended to cite both estimators; new
  paragraph + three rows in \texttt{sections/baselines_appendix.tex}
  under \texttt{tab:extended_baselines}; ``Baseline-implementation
  caveats'' paragraph in \texttt{sections/discussion.tex} reframed (MS-
  GARCH dropped from self-implementation caveat list, replaced with
  ``two flavours'' framing); ``six items closed'' counter in the
  Limitations paragraph updated from five; \texttt{sections/conclusion.tex}
  no longer lists MS-GARCH in companion-paper directions. Plan
  artefact: \texttt{PLAN\_MSGARCH\_RCALL.md} (supersedes
  \texttt{PLAN\_MSGARCH\_JULIA.md} and \texttt{PLAN\_MSGARCH\_PUBLIC\_PACKAGE.md}
  for the resubmission timeline). Companion-repo additions:
  \texttt{src/MSGARCHReference.jl} (Julia bridge),
  \texttt{run\_msgarch\_reference.jl} (runner),
  \texttt{r\_msgarch/} (R-side scaffolding under \texttt{renv}),
  \texttt{test/test\_msgarch\_reference.jl} (smoke test, skips cleanly
  without R).

---

## v10 (in progress, scaffolded 2026-04-22)

**Scope.** Upgrade pass from v9 to top-tier synthetic-data-generator paper.
Scaffolded from v9 on 2026-04-22 by copying `Paper_v9.tex` to `Paper_v10.tex`,
duplicating all `sections/*_v9.tex` to `sections/*_v10.tex`, and copying
`References_v9.bib` to `References_v10.bib`. The v10 root now points at the
v10 section files and v10 bib. v9 joins the frozen reference snapshot set
alongside v7 and v8.

### Planned content additions (tracked in `CHMM-Model/plan-equity-paper.md`)

1. Retitle to the generator thesis: "A Regime-Switching Continuous HMM as
   a Reference Synthetic-Data Generator for Equity Returns."
2. New Extended Evaluation subsection covering Track A (MMD, signature-MMD,
   discriminator AUC, leverage effect, aggregational kurtosis, simulation
   p-values, Kupiec + Christoffersen LR).
3. New Semi-Markov Ablation subsection (Track C1) framed as a
   risk-calibration-not-marginal-fidelity upgrade.
4. New Conditional VaR subsection (Track C3a) where flat CHMM-t with
   Viterbi-decoded conditional VaR passes both Kupiec and Christoffersen
   cleanly at 1 % and 5 % on OoS.
5. New baselines paragraphs for QuantGAN (B1), diffusion (B3), and
   MS-GARCH (B4).
6. New three-way operational split in Discussion: flat CHMM-t for
   distributional fidelity, MS-GARCH / SM-CHMM for unconditional VaR,
   flat CHMM-t + Viterbi for conditional VaR.
7. Explicit DiscreteNJ / DiscreteWJ 5 % VaR Kupiec failure callout
   (LR_uc 16.81) against the `alswaidan2026hybrid` baseline.

### What is unchanged from v9 at scaffold time

- Author list: Alswaidan, Jin, Varner (fixed order from v4 onward).
- Abstract, Introduction, Methods, Results, Discussion, Conclusion, and
  Supplementary sections are byte-identical copies of v9; each will be
  modified in place under `*_v10.tex` as the plan items land.

---

## v9 (frozen 2026-04-22)

**Scope.** Recovery and consolidation pass after the 2026-04-22 VIX /
option-pricing strip that moved VIX and option-pricing content to the
sibling `CHMM-Vol-Model` / `CHMM-Vol-Paper` repos. Kept the v8 scaffold;
refocused narrative on equity-only synthetic-data generation.

### Changes vs v8

1. Rydén (1998) refutation framing (moderate $K$ closes the $\lvert r\rvert$
   ACF decay gap).
2. BIC / CAIC plus multi-metric score for state selection ($K = 18$ chosen).
3. Retained the seven-metric evaluation panel (KS %, AD %, kurtosis,
   ACF-MAE, Wasserstein-1, Hellinger, quantile coverage) on IS + OoS.
4. Retained the Pipeline A / Pipeline B split from v8 for cross-asset
   results.

### What is unchanged from v8

- Author list: Alswaidan, Jin, Varner.
- Experimental infrastructure inherited from v7 / v8 (`run_all_analysis.jl`
  harness and seven-metric panel).

---

## v8 (frozen)

**Scope.** Editorial clarity pass on `Paper_v8.tex`. No new experiments,
no changed numbers. Target output is a venue-agnostic preprint.

### Changes vs v7

1. **Explicit Pipeline A / Pipeline B labeling** throughout the paper.
   - Pipeline A: single-index trained CHMM (per-ticker independent Baum-Welch fit).
   - Pipeline B: cross-asset dependence (SIM, Gaussian copula, Student-t copula)
     on top of Pipeline A per-asset CHMM marginals.
   Every subsection header in `results_v8.tex` and every diagnostic subsection
   header in `supplemental_v8.tex` that depends on the pipeline distinction
   carries the pipeline tag (e.g., "Cross-Asset Univariate Generalization
   (Pipeline A)", "Cross-Asset Dependence: SIM and Copula Extensions
   (Pipeline B)", "Walk-Forward Rolling-Window Re-Estimation (Pipeline A)",
   "Student-t Copula Profile Log-Likelihood (Pipeline B)").

2. **Table T2 and Table T3 are now unambiguous.**
   - Table T2 = per-ticker marginal fidelity across three emission families
     (Pipeline A, six tickers). Label: `tab:cross_asset`.
   - Table T3 = cross-asset dependence extension (Pipeline B, SIM + Gaussian
     copula + Student-t copula on fixed CHMM-N marginals). Label:
     `tab:cross_asset_sim_copula`.
   In v7 both tables were written to files named `Table-T2-*.txt` on disk.
   v8 aligns the on-disk artifact names to the paper numbering:
   `results/SPY/Table-T2-Per-Ticker-Emission-Families.txt` and
   `results/cross_asset/Table-T3-Cross-Asset-Dependence.txt`.

3. **Self-contained figure and table captions.** Every caption now leads with
   a bolded subject line that states pipeline and scope, then explains
   ticker(s), K, emission family, IS vs OoS window, number of simulated paths,
   and the meaning of every plotted element (color, line style, band).

4. **Methods section flags Pipeline B explicitly.** Section on cross-asset
   dependence is titled "Cross-Asset Dependence (Pipeline B)" and opens with
   a one-paragraph orientation that names Pipeline A and explains how
   Pipeline B composes on top of it.

5. **Venue-agnostic framing in `Paper_v8.tex`.** Removed prior
   venue-specific framing (fidelity / utility / privacy triad paragraph)
   from the abstract and introduction so the paper is suitable for an
   arXiv preprint.

6. **v7-leftover cleanup.** Removed internal references to `V7_SEED`,
   `run_v7_revisions.jl`, the "Paper v7" rebuild log line, and the
   `Fig-v7-*.pdf` figure filename prefix (renamed those figures to drop the
   v7 prefix, paths updated throughout).

### What is unchanged

- Author list: Alswaidan, Jin, Varner (fixed order from v4 onward).
- Experimental numbers: byte-identical to v7 for every reported table and
  figure. All edits are textual.
- Figures in `sections/figs/`: unchanged PDFs. New plot-title strings and
  caption wordings live in the Julia analysis scripts and will take effect
  the next time those scripts are run.

---

## v7 (predecessor)

Substantive rebuild against the new 10-year training and out-of-sample
remainder split. Added VaR and ES back-test, walk-forward re-estimation
diagnostic, block-bootstrap and bin-T NJ baselines, GRU neural baseline,
Student-t copula profile-MLE degrees-of-freedom selection, Ryden K=2
reproduction, and extended out-of-sample equity price simulation across
six tickers and three emission families. Retained as the last stable
reference version.

---

## v1 through v6 (retired)

Exploratory drafts predating the v7 rebuild. Deleted on 2026-04-21 to
reduce repository noise; full history is available in git.
