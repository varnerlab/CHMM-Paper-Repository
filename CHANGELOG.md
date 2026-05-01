# Paper Changelog

Accumulating record of substantive changes across paper versions.
Newest version on top. For the full paper content, see `Paper_vN.tex` and
the matching `sections/*_vN.tex` files.

---

## Round-2 Peer-Review Remediation Pass (2026-04-30)

Revision pass against the round-2 simulated peer review in `peer-review.md`
(R1 Minor / R2 Major / R3 Major; aggregate **Major Revision**). Plan tracked
in `PLAN_PEER_REVIEW_R2.md`. Final state: 126 pages, build clean, no
unresolved references or citations.

### Phase A — LaTeX-only framing fixes (no new computation)
- Title / abstract retitled with "symmetric" qualifier on stylized-fact scope.
- Abstract reframed: four CHMM emission families *interchangeable* on OoS
  (within-CHMM DM p > 0.45); spectral identity now leads with the cross-ticker
  median dominant-mode share (75.6%); SPY-specific 93.6% described as
  right-tail rather than canonical.
- Conditional VaR at α=0.01: DQ rejection at K=18 (p=0.017) reframed as the
  substantive α=0.01 finding rather than as a confirmation of the lower-power
  Christoffersen-cc pass.
- OoS block-bootstrap explicit body sentence: ~25pp drop from asymp to L=20.
- Bootstrap dominance on raw 1-day OoS KS: not "rebutted" by multi-day DM, just
  a column the bootstrap wins; Table 3 reading guide redirects to structural
  use cases.
- QuantGAN reframed: in-house WGAN re-implementation result, not a verdict on
  the deep-generative class.
- GLD/SLV strengthened to "hard rejection of cross-asset-class transfer".
- Cross-ticker ANOVA n=3-per-sector explicitly flagged as severely underpowered;
  "failures are ticker-specific" claim dropped.
- Cross-asset ν*=6 selection now stated as IS-only finding.
- `tab:variant_choice` CHMM-L row corrected.
- Leverage Q5-boundary claim replaced with one-sided percentile p-values.
- Stale K*=6 body-headline references updated to K*=3.
- Review-letter attributions cleaned out of body and appendix prose.

### Phase B — Computational analyses (CHMM-Model)
- B1 — Multi-day DM replication panel (`run_crps_dm_multiday_replication.jl`).
  Negative finding: the K=18 SPY h=20 result (p=0.003) does not replicate at
  K*=3 on SPY (p=0.244) or across the six-asset universe at K*=3.
- B2 — HAC-corrected K-selection (`run_k_selection_hac.jl`). K=6 vs K=3 robust
  under HAC (|z_HAC| < 1). K=18 vs K=6 jumps to |z_HAC|=3.56 / 5.00 (vs.
  independent-fold |z|=1.92 / 1.70), decisively below K=6.
- B3 — Bootstrap-CI placement (`run_kurtosis_ci_placement.jl`). 76.6%–89.9% of
  simulated IS paths fall inside the L=20 CI on observed; per-path median
  simulated IS kurtosis is essentially observed.
- B4 — Single-shared-ν ablation (`run_chmm_t_shared_nu.jl`). Major positive
  finding: shared-ν eliminates the IS kurtosis overshoot completely without
  any penalty; K=18 produces the cleanest IS/OoS heavy-tail match in the panel
  (sim 6.25 IS / 5.00 OoS vs obs 7.68 / 5.29).
- B6 — K=11 effective rebuild (`run_k_eff_rebuild.jl`). K=11 matches or slightly
  exceeds K=18 nominal on every metric axis. K=18 over-parameterisation is
  artefactual.
- B5 — Refit-cadence cond-VaR sweep deferred as documented follow-up.

### Phase C — Phase-B integration into LaTeX
- New appendix subsections: `sec:crps_dm_multiday_replication`,
  `sec:k_selection_hac`, `sec:kurtosis_ci_placement`, `sec:chmm_t_shared_nu`,
  `sec:k_eff_rebuild`. Body callouts in results.tex (table caption + bootstrap
  paragraph + K-selection paragraph + CHMM-t row), discussion.tex (CHMM-t
  bracket discussion + K_eff paragraph), and var_backtest.tex (α=0.01 DQ row).

### Substantive findings net of round 2
1. Multi-day DM is K=18-specific (B1): the body's strongest CHMM-vs-bootstrap
   differentiator does not generalise; the differentiation is on structural
   use cases (regime-conditional VaR, copula composition, privacy) rather than
   multi-day forecasting.
2. K=18 is decisively worse than K=6 on held-out log-lik under HAC (B2);
   retained as kurtosis-fidelity sensitivity reference only.
3. Per-state ν_k is the binding constraint on the IS kurtosis overshoot (B4);
   shared-ν alternative documented in appendix as structurally cleaner.
4. K=11 nominal = K=18 nominal on every metric axis (B6); K=18 is a
   parameter-counting artefact.

### Post-round-2 follow-up: P10 closed (2026-04-30)

- 60-ticker sector expansion (`run_sector_panel_n6.jl` + post-processor).
  30 additional tickers (3 large-cap per sector) fit at K=18, λ=20 alongside
  the cached body 30. **ANOVA at adequate power**: F(9, 50) = 0.366, p = 0.946,
  η² = 0.062 (vs body n=3: F(9,20) = 0.44, p = 0.90, η² = 0.16). The effect-
  size estimate halves with adequate power; the no-sector-effect null is not
  rejected. Aggregate distribution at n=60 is statistically indistinguishable
  from n=30: median OoS KS 73.45% vs 73.4%, failure rate 22/60 = 36.7%
  identical to 11/30 = 36.7%. The body's "failures are ticker-specific" claim
  is now supported by an adequately-powered test. New appendix
  `sec:sector_panel_n6` + `tab:sector_panel_n6`; body callout in
  `sections/results.tex` cross-ticker paragraph.

### Post-round-2 follow-up: P7 closed (2026-04-30)

- B5 — Walk-forward refit-cadence sweep
  (`run_walkforward_cond_var_refit_cadence.jl`). Scoped at K=3 / α=0.05 across
  the six walk-forward folds at monthly (21d) and weekly (5d) cadence against
  the body fold-IS-fixed baseline. **Negative finding**: faster refit does
  NOT close the W2 (COVID) Christoffersen-cc rejection (p_cc = 0.011 → 0.017
  → 0.023 across cadences, all rejecting), and monthly refit *introduces*
  new failures on W3 (0.118 → 0.047) and W4 (0.120 → 0.022) from refit-cycle
  parameter drift. Weekly refit recovers W4 (back to 0.100) but still rejects
  W3 (0.025) and W2. Rejection counts: fold-IS-fixed 1/6, monthly 3/6, weekly
  2/6. The W2 failure is intrinsic regime-break; closing it requires a model
  class with explicit regime-introduction handling (skew-emission HMMs,
  online-EM constructions), not faster refit cadence on the symmetric
  scaffold. New appendix `sec:walkforward_refit_cadence` +
  `tab:walkforward_refit_cadence`; body callout in `sections/var_backtest.tex`.

Final state after P7 integration: 127 pages, build clean, no unresolved refs.

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
- **R3.W2 (abstract conditional-VaR W2/W4 callout)** (2026-04-30): closed.
  Added one sentence to the abstract stating the conditional-VaR rejects
  on the W2 / W4 walk-forward folds at $p < 10^{-3}$, per R3 W2's
  binding language.
- **R1.W4 (leverage-effect rephrase)** (2026-04-30): closed. Discussion
  paragraph header and closing sentence rewritten to drop the
  ``partially captured'' framing and use the accurate one-sided-test
  framing (envelope brackets IS observed, OoS observed sits below
  envelope). Reviewer 1 W4's specific phrasing demand satisfied.
- **R2.W3 (var\_backtest cross-ref fix)** (2026-04-30): closed.
  Body sentence at \texttt{sections/var\_backtest.tex} line 45 was
  citing the wrong tables for the quarterly-refit conditional VaR;
  fixed to point at \texttt{tab:cond\_var\_quarterly\_refit} (the
  actual quarterly-refit table in \texttt{sec:quarterly\_refit\_cond\_var}).
- **R1.RE1 (k-fold K-selection on pre-2020)** (2026-04-30): closed.
  Implemented two rolling-origin CV designs on the strictly pre-2020
  slice: four-fold full-year and six-fold half-year. Both fail to
  distinguish $K^\star = 6$ from $K^\star = 3$ on mean held-out
  per-observation log-likelihood at conventional levels (full-year
  $|z| = 0.07$, half-year $|z| = 0.04$, sign flips between designs;
  $K = 18$ borderline worse than $K^\star = 6$ at $|z| = 1.92$ /
  $1.70$). Triggers R1 W1's contingency for body rebuild at
  $K^\star = 3$. New runners: \texttt{run\_k\_selection\_kfold\_pre2020.jl},
  \texttt{run\_k\_selection\_kfold\_h12y\_pre2020.jl}. Artefacts under
  \texttt{results/robustness/k\_selection\_kfold\*}. New appendix
  paragraph at \texttt{sections/supplementary.tex:230} with label
  \texttt{sec:k\_selection\_kfold\_pre2020}.
- **R1.W1 (body rebuild at $K^\star = 3$)** (2026-04-30): closed.
  Computed four-emission rows at $K^\star = 3$ (CHMM-N, penalised
  CHMM-t at $\lambda = 20$, CHMM-L, CHMM-GED) on SPY IS / OoS via
  \texttt{run\_kstar3\_headline.jl}. Headline numbers: CHMM-N at
  $89.7\%$ IS / $80.5\%$ OoS, penalised CHMM-t at $90.6\%$ /
  $\mathbf{83.2\%}$ (cleanest IS/OoS heavy-tail match in headline
  block at $14.91 / 8.50$ vs observed $7.68 / 5.29$), CHMM-GED at
  $90.5\%$ / $77.4\%$, CHMM-L at $79.8\%$ / $63.1\%$. Cascading edits:
  Table~\ref{tab:model_comparison} now has new $K^\star = 3$ block
  with leading $\star$, $K^\star = 6$ demoted to held-out-clean
  sensitivity reference; abstract / introduction / conclusion / body
  intro paragraph all flipped to lead with $K^\star = 3$ numbers and
  cite the $k$-fold CV.
- **R1.W5 / R2.W2 / R2.RE4 (block-aware OoS KS at K* operating points)**
  (2026-04-30): closed. Computed block-aware OoS KS at the body
  headline $K^\star = 3$ and the $K^\star = 6$ sensitivity reference,
  alongside existing $K = 18$ rows in
  Table~\ref{tab:ks_block_body}. Eight new rows added; cross-generator
  ranking $K$-robust. Runner: \texttt{run\_ks\_block\_body\_kstar.jl}.
- **R3.W3 (cross-ticker rebuild at $K^\star = 3$)** (2026-04-30): closed
  in same pass as R1.W1. Ran 30-ticker sector-balanced panel at
  $K^\star = 3$ via \texttt{run\_sector\_panel\_k3.jl}; OoS KS
  median $69.1\%$ at identical $11/30$ failure count. Body
  Table~\ref{tab:cross_ticker} now reports three columns
  ($K^\star = 3$ / $K^\star = 6$ / $K = 18$).
- **R3.W3 (quarterly-refit cross-ticker at $K^\star = 6$)**
  (2026-04-30): closed. Ran the same protocol as the existing
  $K = 18$ quarterly-refit but at $K^\star = 6$ via
  \texttt{run\_sector\_panel\_quarterly\_refit\_k6.jl}; refit median
  OoS KS $\mathbf{85.8\%}$ ($+10.7$pp lift), in fact $2.8$pp above
  the $K = 18$ refit median of $83.0\%$. Appendix
  Table~\ref{tab:cross_ticker_quarterly_refit} extended from two
  columns to three; ``Reading'' paragraph rewritten to compare the
  two refit operating points.
- **R2.W4 / R2.RE3 (per-state Frobenius distances across emission
  families)** (2026-04-30): closed. Implemented
  \texttt{run\_emission\_family\_frobenius.jl}; fits all four families
  per ticker at $K^\star = 3$, canonicalises states by ascending
  $\sigma_k$, computes pairwise Frobenius distances on
  $(\boldsymbol\mu, \boldsymbol\sigma, \mathbf T)$ on SPY headline and
  the 30-ticker panel. New appendix subsection
  \texttt{sec:emission\_family\_frobenius} with Table~\ref{tab:emission_family_frobenius}.
  Substantive finding: the four-family narrative does NOT collapse to
  a one-parameter shape axis as R2 W4 hypothesised; CHMM-N stands
  apart from the heavy-tail trio $\{$t, L, GED$\}$ at SPY
  $\|\Delta\boldsymbol\mu\|_F \sim 2.0$, $\|\Delta\mathbf T\|_F \sim
  0.5$, but the heavy-tail families cluster tightly (t-GED on SPY:
  $\|\Delta\boldsymbol\mu\|_F = 0.21$, $\|\Delta\mathbf T\|_F = 0.04$).
  The structure is two-cluster (Gaussian vs heavy-tail) with within-
  cluster variation along the kurtosis axis.
- **R2.W7 / R3.W5 (compress sec:theory)** (2026-04-30): closed.
  Rewrote \texttt{sections/theory.tex} from $\sim 91$ lines to
  $\sim 26$ lines. Dropped the explicit assumption blocks (moved to
  appendix \texttt{sec:supp\_propositions}), the per-state moments
  definition, and the explicit derivation of the autocovariance /
  autocorrelation forms. Kept: the bilinear identity statement,
  equation~\eqref{eq:acf_normalised} (load-bearing cross-reference),
  the Rydén separation rank statement, the dominant-mode-share
  diagnostic, the spectral modes table, and the cross-ticker
  distribution summary. All external cross-references preserved
  (\texttt{eq:acf\_normalised}, \texttt{ass:irred},
  \texttt{ass:moments}, \texttt{tab:spectral\_modes}).
- **R3.RE2 (Engle-Manganelli DQ test)** (2026-04-30): closed.
  Implemented \texttt{run\_engle\_manganelli\_dq.jl}; standard four-
  lag specification. Result: at $\alpha = 0.05$ the DQ test passes
  cleanly at both $K = 3$ ($p = 0.156$) and $K = 18$ ($p = 0.678$);
  at $\alpha = 0.01$ the DQ test rejects conditional coverage at
  $K = 18$ ($p = 0.017$) where Christoffersen-cc does not
  ($p = 0.137$). New appendix subsection
  \texttt{sec:engle\_manganelli\_dq}; body
  \texttt{var\_backtest.tex} sentence updated to cite the DQ
  cross-check.
- **R3.Minor 2 (Schaller-van Norden citation)** (2026-04-30): closed.
  \texttt{related\_work.tex} rewritten to "estimated regime-switching
  specifications on US monthly stock returns".
- **R3.Minor 3 (Reviewer-1/2 footnote in Table 3)** (2026-04-30):
  closed. Removed.
- **R3.Minor 5 (Wilks regularity citation)** (2026-04-30): closed.
  Added \citet{wilks1938large, vandervaart1998asymptotic} citations
  and a regularity caveat for the Gaussian-copula limit
  $\nu \to \infty$.
- **R2.Minor 3 (notation $f_k$ for density, $F_k$ for CDF)**
  (2026-04-30): closed. Renamed $b_k \to f_k$ throughout
  \texttt{model.tex}, \texttt{estimation.tex},
  \texttt{algorithms\_appendix.tex}, \texttt{supplementary.tex};
  collection symbol $\mathbf{B} \to \mathbf{F}$.
- **R1.Minor 4 (Cont 2001 facts in abstract)** (2026-04-30):
  closed. Abstract now enumerates the three symmetric Cont stylized
  facts and acknowledges leverage / gain-loss asymmetry as out of
  scope.
- **R1.Minor 5 ("held-out-clean" repetition)** (2026-04-30): closed.
  Reduced from 23 occurrences across the paper to 1 canonical
  definition at \texttt{sections/results.tex:33}. All other
  occurrences replaced with ``sensitivity reference'', ``default'',
  ``held-out re-selection'', ``held-out-validated'', or dropped
  where context carried the meaning.
- **R3.RE1 / R3.Q5 (Lambert-W input pre-processing)** (2026-04-30):
  closed. Implemented \texttt{run\_quantgan\_tcn\_lambertw.jl}:
  Goerg (2011, 2015) Lambert-W $\times$ Gaussian heavy-tail
  transformation as input pre-processing on the QuantGAN TCN ($\hat
  \delta = 0.1016$ via IGMM-order-4; pre-Lambert-W IS raw kurtosis
  $7.68 \to$ post-Lambert-W $3.000$). Result: $0.0\%$ IS / $0.0\%$
  OoS KS, simulated kurtosis $0.40$ vs.\ observed $7.68$. Substantive
  finding: the Lambert-W transform succeeds at variance-stabilising
  but the WGAN-with-weight-clipping training collapses to the
  trivial Wasserstein equilibrium under the $\pm 0.01$ weight clip
  on this dataset, so the body's deep-generative \emph{negative-
  control} framing is robust to Lambert-W input pre-processing. New
  appendix subsection \texttt{sec:quantgan\_lambertw}.
- **R2.Q3 (cross-asset Pipeline B at $K^\star = 6$ marginals)**
  (2026-04-30): closed. Re-ran Pipeline B at $K = 6$ marginals via
  \texttt{run\_cross\_asset\_sim\_copula\_k6.jl}; off-diagonal MAE
  differences vs.\ body $K = 18$ are $\le 0.001$ on IS and OoS at
  every dependence model (Student-$t$ copula: IS $0.027$ vs $0.027$,
  OoS $0.209$ vs $0.209$). Dependence layer is marginal-resolution-
  independent on this universe. New appendix subsection
  \texttt{sec:cross\_asset\_kstar6}.
- **R3.RE4 (multi-day cumulative-return DM)** (2026-04-30): closed.
  Implemented \texttt{run\_crps\_dm\_multiday.jl}; aggregated existing
  archive to non-overlapping $h$-day cumulative-return blocks; per-
  block CRPS, two-sided NW-HAC DM. Substantive positive finding:
  CHMM-N beats stationary block bootstrap at $h = 20$ with
  $\Delta\text{CRPS} = -0.180$, $\text{DM} = -2.99$, $p = 0.003$;
  CHMM-L at $p = 0.027$. R3 RE4's vacuity concern not realised; body
  Bootstrap paragraph extended to cite the multi-day result; new
  appendix subsection \texttt{sec:crps\_dm\_multiday}.
- **R1.W3 ($\alpha = 0.01$ power footnote on Table 4)** (2026-04-30):
  closed. Added $\textdaggerdbl$ marker on every $\alpha = 0.01$ row
  of \texttt{tab:cond\_var}; caption footnote cites the power
  calibration and the DQ-test $K = 18$ rejection.
- **R1.Minor 3 ($\dagger\dagger$ bracket-lift footnote promoted to
  remark)** (2026-04-30): closed. Long bracket-lift explanation moved
  from Table 3 caption to \texttt{Remark~\ref{rem:bracket\_lift}} in
  \texttt{sections/discussion.tex}; caption now points at the remark.
- **R1.RE3 (Gamma-sojourn HSMM)** (2026-04-30): closed. Implemented
  \texttt{run\_hsmm\_ml\_gamma.jl}: same Yu (2010) explicit-duration
  EM scaffold as the body Pareto-sojourn HSMM but with discretised
  continuous Gamma sojourn ($p(d) = F_\Gamma(d; \alpha, \beta) -
  F_\Gamma(d - 1; \alpha, \beta)$), per-state $(\alpha, \beta)$
  updated by method-of-moments at each M-step. Substantive positive
  finding: (i) the Gamma-sojourn HSMM at $K = 18$ converges (IS KS
  $86.0\%$, OoS KS $80.2\%$) where the Pareto-sojourn HSMM collapses
  ($0.8\% / 33.4\%$); (ii) the Gamma-sojourn HSMM at $K = 18$ has
  $|G_t|$ ACF-MAE $\mathbf{0.0462}$, the cleanest $|G_t|$ ACF match
  in the entire HSMM panel and below the body CHMM-N $K = 18$ value
  of $0.0509$. R1 RE3's specific hypothesis that a Gamma sojourn may
  close the ACF-MAE gap is therefore confirmed. Trade-off at $K = 3$:
  $\sim 20$pp KS-pass-rate loss for the ACF-MAE recovery ($0.0528$
  Gamma vs.\ $0.0629$ Pareto). New appendix subsection
  \texttt{sec:hsmm\_gamma\_sojourn} with
  Table~\ref{tab:hsmm\_sojourn\_compare}; body ``ML HSMM as a
  co-headline result'' paragraph rewritten to acknowledge the Gamma-
  sojourn recovery and document the no-single-best-HSMM finding.
- **R3.W6 / R3.RE3 (CRSP cross-decade validation)** (2026-04-30):
  closed. Secured a WRDS day-pass at revision time; CRSP CIZ-format
  daily stock file at \texttt{data/external/crsp\_1994\_2006.csv}
  covers SPY plus 28 of 30 cross-ticker panel members (NEE, APD
  missing) from $1994$-$01$-$03$ to $2006$-$04$-$28$. Implemented
  \texttt{run\_cross\_decade\_validation.jl}: SPY IS $1994$-$2004$
  ($2{,}519$ obs) / OoS $2004$-$2006$ ($583$ obs). Result: IS axis
  transfers within $\sim 5$pp KS at $K \in \{3, 18\}$ ($84.9$/$89.8\%$
  vs.\ body $89.7$/$94.1\%$), confirming the four-emission ECM
  scaffold is decade-robust on the IS-fitting side. OoS pass-rate
  collapses to $3$-$5\%$ because the $2004$-$2006$ post-dot-com
  bull-market OoS slice has excess kurtosis $0.06$ (essentially
  Gaussian) versus the $1994$-$2004$ IS kurtosis of $3.05$, the same
  low-stress / low-kurtosis pattern as the W2 / W4 walk-forward
  stress folds. Discussion-section Limitations paragraph rewritten
  from "infeasible" to "completed via CRSP day-pass"; abstract scope
  extended to include $1994$-$2006$. New appendix subsection
  \texttt{sec:cross\_decade\_validation}.

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
