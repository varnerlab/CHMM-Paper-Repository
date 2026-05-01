# Simulated Peer Review

**Manuscript:** "A Continuous Hidden Markov Model for Daily US-Equity Stylized-Fact Reproduction"
**Authors:** Alswaidan, Jin, Varner
**Round:** 2 (post major-revision resubmission)
**Generated:** 2026-04-30
**Reviewer template:** financial-econometrics adaptation of the project peer-review skill (the manuscript's domain is daily-US-equity time-series modeling; reviewer expertise reframed accordingly).

---

## Reviewer 1 (Moderate) — applied financial econometrics, regime-switching specialist

### Summary
The paper presents a continuous HMM trained by Baum-Welch with a unified scaffold across four emission families (Gaussian, Student-t, Laplace, GED), evaluated as a synthetic-data generator for daily US-equity returns. The headline operating point is now K*=3 (selected by held-out per-observation log-likelihood and held-out KS on a strictly pre-2020 slice under both single-fold and four-fold / six-fold rolling-origin CV), with K*=6 and K=18 as sensitivity references. The empirical scope covers SPY 2014-2026, a CRSP 1994-2006 cross-decade validation, a 30-ticker sector-balanced panel, and a six-asset Student-t copula. The revision has materially strengthened the manuscript over what I infer was the prior round: K-selection is now defended on a held-out criterion under k-fold CV, the MS-GARCH reference Bayesian rerun closes a long-standing implementation question, ML HSMM is presented as a complementary scaffold rather than as a competitor, and the multi-day DM result on cumulative returns is a substantive positive finding. I recommend Minor Revision.

### Strengths

1. **Unified ECM scaffold across four emission families is genuinely novel and clean.** Section 3.2 (`sections/estimation.tex`) shows that all four families share the same forward-backward recursion, the same quantile-based initialization, and the same weighting of the M-step; only the per-state location/scale/shape updates differ. The CHMM-GED variant nesting both CHMM-N (p_k=2) and CHMM-L (p_k=1) as boundary cases is the right construction for an interpretable shape-adaptive HMM. The four families landing at four distinct kurtosis points without retuning K is a useful demonstration of how the M-step alone shapes the marginal.

2. **K-selection is now defended on a held-out criterion under proper CV.** The four-fold and six-fold rolling-origin CV on the strictly pre-2020 slice (Appendix `sec:k_selection_kfold_pre2020`) shows |z|=0.07 between K=3 and K=6 mean held-out log-likelihood with the sign flipping between fold designs. Re-headlining at K*=3 as the state-resolution-robust default is the right call, and the K*=6 and K=18 sensitivity references frame the trade-offs honestly.

3. **The MS-GARCH reference Bayesian rerun is a substantive close-out.** The added rows from the `MSGARCH` R package of Ardia (2019) at K∈{2,3,4} (Table 3 ¶ rows) sit at 0--0.1% IS / 5--6% OoS KS under posterior-predictive simulation, confirming that the multi-state-benefit plateau is robust to estimator choice. The renv.lock pin (R 4.6.0, MSGARCH 2.51) makes this reproducible.

4. **ML HSMM as co-headline is intellectually honest framing.** Pareto-sojourn HSMM-N at K*=3 leads single-window OoS KS at 91.0% but its |G_t| ACF-MAE matches the i.i.d. baseline (0.0629). The Gamma-sojourn variant at K=18 (Appendix `sec:hsmm_gamma_sojourn`) drops the ACF-MAE to 0.0462, the cleanest in the HSMM panel. Framing this as "CHMM and ML HSMM are complementary scaffolds with different KS / ACF / kurtosis trade-offs" rather than declaring one a winner is the right read of the data.

5. **The regime-conditional VaR (Section 4.2) is the right operational use-case.** Propagating the one-step-ahead state forecast through the predictive mixture and passing Christoffersen-cc on 19/24 walk-forward folds at α=0.05, with three persistent rejections concentrated on the W2 (COVID) and W4 (2022 rate-hike) stress folds, is a honest delivery of where the value is and where it isn't.

### Weaknesses

1. **Bootstrap dominance on raw 1-day OoS KS undermines the framing of Table 3.** At 99.7% IS / 92.1% OoS KS, the stationary block bootstrap wins the headline distributional axis on both windows, ahead of every CHMM operating point. The body acknowledges this and pivots to "use cases the bootstrap cannot serve" (regime-conditional VaR, copula composition, privacy/licensing), and the multi-day DM finding (n=28 blocks at h=20, p=0.003) is a substantive differentiator. But Table 3 still leads with 1-day KS as the column-best metric, which is exactly the column the bootstrap wins. *Suggestion:* either lead Table 3 with a metric where CHMM dominates (e.g., a multi-horizon CRPS or the conditional-VaR Christoffersen-cc statistic), or restructure the table by use-case (raw KS / multi-day forecast / VaR / copula composition) so the row-headline-comparison is honest.

2. **The single positive multi-day DM result is from one asset, one window, n=28 blocks.** The Δ CRPS = -0.180 at h=20 with p=0.003 (Appendix `sec:crps_dm_multiday`) is the strongest single finding for CHMM-over-bootstrap on this dataset, but it is a single SPY OoS window at one cumulative-return horizon. *Suggestion:* replicate the multi-day DM panel on at least the six-asset universe of Section 5 (where the per-asset CHMM marginals are already fitted) and on the walk-forward folds (where the IS/OoS pairs are already aligned). Even if the result attenuates, the readers need to know whether the headline differentiation is a single-asset / single-window finding or a stable property of the CHMM scaffold.

3. **The conditional VaR passes 19/24 walk-forward folds, with the five failures concentrated on the periods when risk management actually matters.** The W2 (COVID) and W4 (2022 rate-hike onset) folds are exactly the windows a deployed VaR system needs to cover. The body acknowledges the IS-fixed-parameter limitation and points at periodic refit, but the quarterly-refit table (`tab:cond_var_quarterly_refit`) tightens coverage rather than improving the cc-statistic. *Suggestion:* a more aggressive refit cadence (monthly, weekly) or an online-EM construction (the Cappé 2011 reference is already cited) would test whether faster adaptation closes the W2/W4 gap. If it doesn't, that's a useful negative result; if it does, that is the production recipe.

4. **Cross-asset OoS off-diagonal MAE of 0.209 (t-copula) vs 0.202 (Gaussian) is a meaningless distinction at N_paths=200.** The body honestly flags this, but Section 5 still highlights ν*=6 as a substantive choice. The IS calibration distinction (0.027 vs 0.030) is one order of magnitude smaller than the OoS gap. *Suggestion:* report only the IS calibration distinction explicitly as IS-only, and note that the OoS dependence-family decision is empirically null at this N. The quarterly-refit improvement to 0.185 OoS is the operational story; lead with that.

5. **The K=18 effective-state-count collapse is acknowledged but not factored into headline framing.** The standardized-distance single-linkage diagnostic (Appendix `sec:state_distinctness`) collapses CHMM-N to 11/18 and CHMM-t to 12/18 effective states. Table 3 reports K=18 as the kurtosis-fidelity sensitivity reference, and the discussion correctly points out that the parameter count claimed against the data is 11 effective states in an 18-state parameterization. But the body kurtosis-fidelity recommendation (the variant decision guide, `tab:variant_choice`) still suggests "K=18" rather than "K=11 effective". *Suggestion:* in `tab:variant_choice` and the conclusion, replace "K=18" with "K=18 nominal / K=11 effective" or refit at K=11 directly and report whether the kurtosis fidelity holds. The latter is the cleaner closure.

6. **The leverage-effect "partial capture" claim is on the boundary.** The body now says: "CHMM-N at K=18 produces a simulated leverage envelope that does not reject the IS observed leverage at the 5% level (the IS observed value sits at the Q5 envelope boundary), while the OoS observed value sits just below the lower envelope and is not bracketed at the 5% level." Sitting *at* the Q5 boundary is essentially a borderline non-rejection at conventional levels; calling this "partially captures" is a generous read. *Suggestion:* report a permutation/bootstrap p-value on Corr(G_t, |G_{t+1}|) under the simulated-vs-observed null rather than relying on envelope inclusion, and let the p-value carry the framing.

### Questions for Authors

1. The body bracket on CHMM-t is ν_min = 2.1 and the bracket-lift ablation at ν_min = 4 (Remark `rem:bracket_lift`) reduces simulated IS kurtosis only ~1 unit (14.35 → 13.25). The penalised CHMM-t at λ=20 reduces it much further (to ~8). Yet the per-ticker table in Appendix `tab:per_ticker_lambda` shows uniform λ=20 is over-shrunk on 3/6 tickers. Why not just use CHMM-GED as the default heavy-tailed family (which doesn't have the bracket-pinning artefact and adapts the per-state shape automatically) and demote CHMM-t to a sensitivity reference?

2. The cross-ticker panel reports identical 11/30 failure counts at K*∈{3, 6} and K=18 with the same regime-introduction tickers driving each (LLY, UNH, NEM). Does this mean the failure mode is purely a stationarity-scope issue rather than a state-resolution issue? If so, what is the diagnostic that distinguishes "state-resolution-bound failure" from "stationarity-scope failure" on a new ticker the analyst has not seen?

3. The Cont stylized-fact list has five items; the paper covers three (heavy-tailed marginals, negligible linear ACF, slow |G_t| ACF) and treats leverage and gain-loss asymmetry as out of scope by construction. The title and abstract say "stylized-fact reproduction." Would you consider rewording the title/abstract to "symmetric stylized-fact reproduction" to align scope and claim?

### Requested Experiments / Analyses

1. **Multi-asset / multi-window multi-day DM panel.** Replicate the `tab:crps_dm_multiday` finding (CHMM-N beats bootstrap at h=20, p=0.003) on the six-asset universe of Section 5 and on at least three walk-forward folds. Report median Δ CRPS and median p-value across asset×fold; this is the single strongest CHMM-over-bootstrap result and it deserves replication.

2. **Refit-cadence sweep on conditional VaR walk-forward.** Extend the quarterly-refit conditional-VaR table to monthly and weekly refits across the six walk-forward folds. The body finding "5 failures concentrate on W2 and W4" should be revisited under faster adaptation; if monthly or weekly refit closes 2-3 of those, that is the production recipe and should be in the body.

3. **K=11 effective rebuild.** Refit CHMM-N at K_nominal=11 (matching the K_eff collapse value at K=18) and report the headline metric panel against the K=18 nominal row. The clean version of the practical-identifiability discussion is to show the K_eff parameterization works.

### Minor Comments

- Abstract: "...a sector-balanced 30-ticker panel, and a six-asset US-equity copula extension" — consider noting in the abstract that the cross-asset off-diagonal MAE distinction collapses on OoS, since the body presents this as a notable IS finding.
- Section 4.1 (`sections/results.tex`) "ML HSMM as a co-headline result" paragraph: the prose alternates between "Pareto sojourn" and "discrete Gamma sojourn" cases without a single sentence at the top of the paragraph that names the two flavours. A one-sentence preamble would orient the reader.
- Table 3 footnote ¶ rows about MS-GARCH ref Bayesian: "...one path per retained posterior draw" — clarify whether the 1,000 paths are 1,000 independent posterior draws or whether they oversample from the retained set (you state 1,000 retained draws after thin 10, which is consistent, but the connection should be explicit).
- Remark `rem:bracket_lift`: minor LaTeX issue — the closing `\end{remark}` is on the same line as the next sentence. The PDF renders correctly but the source is awkward.
- Some appendix labels point at `sec:supp_hsmm_diagnostic` which I did not see explicitly defined in the parts of the appendix I reviewed; verify all `\ref{}` resolve.

### Recommendation
**Minor Revision.** The substantive concerns are about framing (bootstrap dominance leading the column-best comparison) and about replication (multi-day DM finding on a single asset/window) rather than about correctness or honesty. The honesty has materially improved over the prior round.

---

## Reviewer 2 (Hard) — statistical methodology and time-series asymptotics

### Summary
This is a careful empirical paper that delivers what its abstract promises and admits what it does not. The methodology is standard (Baum-Welch + ECM extensions), the contribution is empirical-architectural (the unified four-family scaffold and the application of the textbook spectral identity to the SPY instance of Rydén et al. 1998), and the evaluation is broader than typical for this class of paper. My concerns are concentrated on three axes: the statistical rigour of the K-selection conclusion, the multiple-testing surface area of the entire panel, and several places where the manuscript leans on borderline results to anchor the headline. Major Revision.

### Strengths

1. **The spectral mechanism in Section 3.3 (`sections/theory.tex`) is correctly framed as not novel.** The textbook bilinear identity ρ_|G|(τ) = Σ_k w_k λ_k^τ is folklore (Hamilton 1994 §22.2; Krolzig 1997 Ch. 3; Timmermann 2000), and the manuscript's contribution on this axis is exclusively empirical: applying the identity to the SPY 2014-2024 instance and showing the K-1 rank bound is non-binding at K≥3. That framing is correct and should be retained.

2. **The k-fold CV result on K-selection (`sec:k_selection_kfold_pre2020`) is the right test.** Reporting |z|=0.07 between K=3 and K=6 mean held-out log-likelihood, with the sign flipping between four-fold and six-fold designs, is the rigorous form of "indistinguishable from sampling noise" and the right basis for re-headlining the body at K*=3.

3. **The K_eff diagnostic (Appendix `sec:state_distinctness`) and the IC re-rank under p_eff (Section 4.1) are an unusually careful treatment of identifiability.** Reporting that AIC/HQC under p_eff select K*=21 while BIC/CAIC continue to select K*=3 across both penalties, and concluding that the K_nom IC sweep's monotonic preference for K=3 is partly a parameter-counting artefact, is the kind of analysis I see omitted from most HMM papers in this area.

4. **The Benjamini-Hochberg correction on the 40-test conditional-VaR panel (Section 4.2) is correct and the substantive read survives it.** 37/40 BH-passes at FDR=0.05 with the three rejections all on W2 COVID is a clean result.

5. **Reproducibility infrastructure is genuinely strong.** Deterministic global seed root, public Julia package with pinned `Manifest.toml`, R reproducer with `renv.lock` for the MS-GARCH reference rerun, sub-seed derivation rule explicit in the appendix. This is the right standard for a paper of this type.

### Weaknesses

1. **The spectral identity's "K-1 rank bound is non-binding at K≥3" claim relies on a single-asset diagnostic and is then weakened for the cross-section.** The body claims a single non-unit eigenvalue carries 93.6% of the lag-1 ACF on SPY at K=18. The cross-ticker median is 75.6% with minimum 32.6% (NEM). The body now correctly notes "the SPY headline overstates the universality and the body framing is at the cross-ticker median" but still introduces the claim with the SPY number in the abstract and intro. *Suggestion:* lead the abstract / introduction with the cross-ticker median (0.756) and treat the SPY 0.936 as a single-asset reference, not as the lead claim. The empirical effective-rank statement is robust at the median but not at the tail (NEM).

2. **The "k-fold CV cannot distinguish K=3 from K=6 at conventional levels" framing assumes |z| has the conventional Gaussian interpretation, but the underlying held-out log-likelihood differences are themselves dependent across folds.** Mean held-out log-lik comparisons across rolling-origin folds inherit autocorrelation from the underlying data. The standardised |z| reported in `sec:k_selection_kfold_pre2020` should be computed under a fold-correlated null, not under independent folds. *Suggestion:* either report the |z| under a Diebold-Mariano-style HAC variance, or state explicitly that the |z| is computed under independence and acknowledge that the actual evidence may be weaker still. Either way the substantive conclusion (re-headline at K*=3) survives, but the reported statistic should match the dependence structure.

3. **The cross-ticker ANOVA F(9,20)=0.44, p=0.90, η²=0.16 with n=3 per sector is severely underpowered, and the body's framing — "failures are ticker-specific" rather than "we cannot detect sector effects" — is begging the question.** η²=0.16 corresponds to a moderate-to-large sector effect on the conventional Cohen scale; the test simply doesn't have the power to detect it at n=3. *Suggestion:* drop the ANOVA conclusion altogether or expand the panel to n≥6 per sector. The current "failures are ticker-specific" claim is supported only by the visual concentration of failures on LLY/UNH/NEM, not by the ANOVA, and the manuscript should not present an underpowered ANOVA as evidence either way.

4. **The CHMM-t bracket-pinning artefact at ν_min=2.1 is a misspecification, not a calibration choice, and the λ=20 penalty is a partial fix.** The IS kurtosis overshoot from 7.68 (observed) to 14.91 (penalised) to 14.4 (unpenalised) is one or two orders of magnitude beyond what a well-specified Student-t mixture should produce. The bracket-lift ablation at ν_min=4 reduces the overshoot only by ~1 unit (14.35→13.25), which means the lower bracket is not the binding constraint — it's the per-state ECM concentrating mass on a small subset of tail states regardless of the lower bracket. *Suggestion:* either constrain the per-state ν_k to a single shared ν (a one-parameter Student-t mixture) and report it as a fifth variant, or add a Bayesian shrinkage on ν_k around a panel-level prior rather than a 1/ν shrinkage at λ=20. The current penalty is over-shrunk on 3/6 tickers per `tab:per_ticker_lambda` and is not a resolution.

5. **The DQ test rejects K=18 at α=0.01 with p=0.017 (Appendix `sec:engle_manganelli_dq`), and the body's "α=0.01 is power-bounded under Christoffersen-cc" framing fails to acknowledge that DQ has the power and reaches the opposite conclusion.** If DQ is the higher-power conditional-coverage alternative (the body claims it), then a clean DQ pass at α=0.01 is the substantive result; a DQ rejection at α=0.01 is also the substantive result, in the other direction. The body text currently positions DQ as a confirmation of the α=0.05 result, which is not what the data say. *Suggestion:* report the DQ result as the substantive finding at α=0.01 ("DQ rejects K=18 at α=0.01 with p=0.017, indicating the regime-conditional VaR over-couples high-volatility states at the strict tail") and revise the body's α=0.01 framing accordingly.

6. **The body claim that the multi-day DM result (Δ CRPS = -0.180, p=0.003 at h=20) is robust across bandwidths is not demonstrated for the multi-day DM specifically.** The body's bandwidth sensitivity (`tab:dm_bandwidth`) covers the within-CHMM family DMs at h=1, not the CHMM-vs-bootstrap multi-day DM at h=20. *Suggestion:* report the bandwidth sensitivity for the h=20 CHMM-N-vs-bootstrap DM at h ∈ {2, 4, 8, 16}; if p is stable across bandwidths, the result is robust; if p moves, it should be flagged.

7. **The block-bootstrap KS recalibration on OoS shows a ~25pp drop from asymp to block-aware (`tab:ks_block_bootstrap_oos`), which is much larger than the IS drop (~5pp), and the body's "cross-generator ranking is window-robust under block-aware recalibration" framing buries this.** A 25pp drop in absolute pass rate is a substantial qualitative change, not just an absolute-level recalibration: it moves CHMM-N from a "passes most of the time" generator to a "passes about half the time" generator on OoS at L=20. *Suggestion:* add an explicit sentence in the body OoS interpretation that the absolute level on OoS, when corrected for autocorrelation, is materially weaker than the IS panel suggests, and that the cross-generator ordering is the robust comparison rather than the absolute level.

### Questions for Authors

1. The kurtosis bootstrap CI on observed (Appendix `sec:kurtosis_bootstrap_ci`) at L=20 gives [2.17, 12.40] IS / [0.90, 8.26] OoS. The IS overshoot from 14.91 to 8.50 (penalised CHMM-t at λ=20, K*=3) sits *above* the IS bootstrap CI upper bound of 12.40. By the body's own bootstrap envelope, the penalised CHMM-t IS kurtosis is statistically distinguishable from observed at the 5% level. Should the headline framing change?

2. The K=18 sensitivity reference is selected by a "multi-objective rule that uses the OoS window." This is double-dipping on the held-out. Why is the K=18 panel even kept, given the K*=3 panel passes the held-out criterion cleanly and the K=18 advantage is acknowledged to be on a metric (kurtosis) that depends on the held-out window?

3. The full one-shot Student-t copula MLE (Appendix `sec:full_tcopula_mle`) returns ν_full = 6.40 vs ν_two-step = 6.00, a +5.55 log-likelihood improvement. What is the bootstrap CI on the LL improvement? At one degree of freedom the +5.55 LL is comfortably above the χ²_1(0.05) = 3.841 critical value but the body claims "the body ν*=6 choice is robust to the estimator switch." Is +5.55 LL really inside sampling error of the two-step estimator, or is the two-step estimator biased toward the integer grid by the unit-spaced ν grid?

### Requested Experiments / Analyses

1. **HAC-corrected K-selection inference.** Re-compute the |z| = 0.07 (K=3 vs K=6) and |z| = 1.92 (K=6 vs K=18) statistics under a Diebold-Mariano-style Newey-West HAC variance over rolling-origin folds. Report the HAC-corrected statistic alongside the independent-fold statistic.

2. **Bootstrap-CI placement of the penalised CHMM-t IS kurtosis.** Cross-compare the simulated IS kurtosis distribution (across the 1,000 simulated paths) to the bootstrap CI on observed IS kurtosis [2.17, 12.40], and report the fraction of simulated paths falling inside the CI. If <50%, the penalised CHMM-t at λ=20 is not in the right kurtosis-distribution band; a different penalty rate or a different family should carry the heavy-tail headline.

3. **Multi-day DM bandwidth and replication panel.** As R1 also notes (R1#2), replicate the h=20 DM finding across the six-asset universe and across walk-forward folds; in the same panel, sweep the NW-HAC bandwidth at h ∈ {2, 4, 8, 16} on the SPY single-window result.

4. **Single-shape CHMM-t1 ablation.** Refit CHMM-t with a single shared ν across all states (the standard Student-t HMM in the time-series literature, not a per-state ν_k). Report whether the kurtosis overshoot disappears under shared ν, which would establish that the per-state ν_k is the binding constraint and the bracket / penalty story is downstream of that choice.

### Minor Comments

- `\ref{tab:walkforward}` in the abstract: the K=18 walk-forward median CHMM-N OoS KS = 67.7% and K*=3 = 62.1% are substantively close. Lead the walk-forward summary in the body with both, not just the K=18 number.
- Section 3.2 (`sec:mstep`): the CHMM-GED M-step is "three-stage CM" but `\eqref{eq:ged_mu}--\eqref{eq:ged_p}` appears in `\ref{prop:ecm_monotone}` without the equation labels actually being in that section. Either add the labelled equations or remove the cross-reference.
- The Wilks (1938) reference in `references.bib` is now cited (the prior round noted it was missing). Verify it's used in the body where the χ² profile-LL CI is invoked rather than only in the appendix.
- The "Reviewer 1 / Reviewer 2 / minor item" attributions in some appendix paragraphs are leftover from the response-to-reviewers letter and should be removed in the manuscript text. The paper is not a response document.
- `tab:hsmm_sojourn_compare` is referenced in the body but I could not confirm its label is defined in the appendix. Verify.

### Recommendation
**Major Revision.** The substantive concerns (HAC for the K-selection statistic, the CHMM-t per-state vs shared ν question, the DQ-rejection-vs-Christoffersen-cc-pass framing at α=0.01, the multi-day DM replication) require new analysis rather than rewording, and at least two of them have the potential to change the headline framing. The methodology is correct; the framing needs to follow the methodology more conservatively.

---

## Reviewer 3 (Very Hard) — has published in HMM and regime-switching evaluation

### Summary
The paper is honest, the empirical work is broad, the reproducibility is real, and the prior-round revision pass appears to have closed many genuine issues. That said, I have substantive concerns about two questions the paper does not answer and one piece of framing that I think is overclaim. The paper claims architectural novelty (the unified four-family scaffold) and an empirical contribution (the spectral-rank application to the SPY Rydén instance plus the broad evaluation). The architectural piece is real, but the four families do not deliver four substantively different points on the trade-off frontier; on the held-out KS axis they cluster within sampling noise (`tab:dm_bandwidth` confirms within-CHMM DM is null on OoS at p > 0.45). The empirical piece runs into the bootstrap-dominance problem that the paper now acknowledges. I recommend Major Revision.

### Strengths

1. The honesty in the bootstrap section ("on raw OoS KS at this single window, the simplest non-parametric benchmark dominates the parametric panel") is unusual and welcome. Most papers in this area would have hidden this.

2. The MS-GARCH reference Bayesian rerun via the `MSGARCH` R package settles a decade-long question about whether the in-house Nelder-Mead frequentist fit is doing the heavy lifting in the panel. It isn't; both flavours fail (0--0.1% IS / 5--6% OoS for the Bayesian, 27--37% IS plateau for the in-house). The dataset just isn't friendly to MS-GARCH.

3. The walk-forward distribution as the "operationally informative summary for production deployment" rather than the single-window OoS pair is the right framing and matches what practitioners actually need.

4. The Cappé (2011) online-EM citation as the deferred follow-up direction is the right reference for the periodic-refit limitation. Many papers in this area cite Pesaran-Timmermann (2007) without mentioning the online-EM literature.

### Weaknesses

1. **The four CHMM emission families are not statistically distinguishable on OoS, which weakens the architectural claim.** The body reports within-CHMM DM tests on sample CRPS at T_OoS=572 with p > 0.45 across all three pairs (`results.tex`, end of Section 4.1) and concludes "the four families are interchangeable on this evaluation." If they're interchangeable on the headline OoS metric, then the architectural contribution of "four interchangeable emission families" reduces to a software-engineering convenience: same forward-backward, same initialization, swappable M-step. That is useful but it is not a methodological contribution at the level the introduction claims. *Suggestion:* either (a) demonstrate a setting (asset class, evaluation metric, regime) where the four families do produce statistically distinguishable behavior, or (b) reframe the contribution as "a unified software scaffold for HMM emission-family swapping" and adjust the introduction accordingly.

2. **The "applies the textbook bilinear identity to the SPY 2014-2024 instance of the Rydén failure" empirical contribution is a spectral diagnostic on a single asset.** The cross-ticker version (Appendix `sec:spectral_rank_xticker`) shows median 0.756 dominant-mode share with minimum 0.326 (NEM), so the SPY 0.936 is in the right tail of the distribution. The introduction claims this as a substantive contribution; in fact, it is a single observation on a single asset, with the property the paper highlights (rank-non-binding at K≥3) holding at the cross-ticker median but not at the tail. *Suggestion:* the introduction should not claim "the K-1 rank bound is non-binding at K≥3 on equity-return data" as a generic statement; it should claim "on the SPY 2014-2024 instance, and at the cross-ticker median of a 30-ticker panel, the K-1 rank bound is non-binding at K≥3, but the cross-ticker minimum (NEM) sits below 0.5, so the property is not universal." The current introduction overstates.

3. **The K=18 leverage-effect claim is weaker than the body framing.** Section 5 (`sections/discussion.tex`) reports CHMM-N at K=18 has a median path-level Corr(G_t, |G_{t+1}|) = -0.089 IS / -0.087 OoS with [Q_5, Q_95] envelopes [-0.138, -0.037] IS and [-0.190, +0.015] OoS, and the IS observed value (-0.135) sits at the Q_5 boundary. Sitting *at* the Q_5 boundary is a nominal pass at α=0.05, but it's a one-sided test of "envelope brackets observed" with the observed value at the boundary. The OoS observed value (-0.214) sits outside the lower envelope. The body framing — "CHMM at K=18 produces a simulated leverage envelope that does not reject the IS observed leverage at the 5% level" — is technically accurate but reports a borderline result as a positive finding. *Suggestion:* either report a permutation p-value on the difference (path median minus observed) or drop the leverage section to a one-paragraph-with-CI statement: "the CHMM family at K=18 covers about 65% of the observed IS leverage magnitude; closing the rest requires asymmetric per-state emissions."

4. **The non-equity stress test at GLD/SLV (Appendix `sec:non_us_asset_supp`) collapses to 0% OoS KS, which is the strongest empirical result in the paper for the *opposite* direction.** A 0% OoS KS on two non-equity ETFs under static IS-fit is a hard rejection, not a "documented limitation." The introduction calls the paper's scope "daily US-equity stylized-fact reproduction"; the GLD/SLV result confirms that scope is a hard boundary, not a soft preference. *Suggestion:* the conclusion should explicitly state: "the static IS-fitted CHMM does not transfer outside daily US-equity asset classes; non-equity asset classes require periodic refit at a cadence that scales with the asset's regime structure." Currently the conclusion mentions GLD/SLV in passing.

5. **The QuantGAN TCN row at 0% IS / OoS KS is positioned as a deep-generative negative control, but the architecture is the standard architecture in the literature; what's missing is the Lambert-W input pre-processing.** The body discusses this and the prior round reportedly attempted Lambert-W (the response letter mentions the WGAN training collapses regardless). If the WGAN training collapses regardless of Lambert-W, that is the finding to report. The current body framing — "deep-generative class functions as a negative control on this dataset under WGAN training" — is borderline polemical against an entire architectural class on the basis of one in-house WGAN training run. *Suggestion:* either run a published reference implementation of QuantGAN (e.g., the GitHub repo of Wiese et al.) and include its KS pass rate, or soften the framing to "in-house QuantGAN re-implementation, including the Lambert-W variant of Appendix X, fails IS / OoS KS." The current "deep-generative class functions as a negative control" claim is not supported on the basis of one in-house WGAN run.

6. **The cross-asset OoS off-diagonal MAE distinction (0.209 t vs 0.202 Gaussian, 0.007 difference) is reported as inside the simulation-noise floor, but the IS distinction (0.027 vs 0.030) is reported as a substantive selection of ν*=6.** Both are essentially inside their sampling-error envelopes at N_paths=200. Why is one taken as substantive and the other not? Either (a) increase N_paths to a level where 0.003 is statistically resolvable on IS and 0.007 is statistically resolvable on OoS, or (b) report both as IS-noise / OoS-noise and reframe the dependence-family selection as practically meaningless on this universe at this N. The body cannot have it both ways.

### Questions for Authors

1. The paper's strongest claim against the bootstrap is on multi-day DM at h=20 (p=0.003, n=28 blocks). Is the result robust to choosing non-overlapping vs overlapping blocks (the latter would give n≈552 with the standard HAC adjustment)? If the result attenuates with overlapping blocks at the same NW-HAC bandwidth, the n=28 finding is sample-size-dependent.

2. The Christoffersen-cc passes 19/24 walk-forward folds at α=0.05 with 5 failures concentrated on W2 and W4. The W3 (Q1 2021), W5 (mid-2022 to mid-2023), and W6 (mid-2023 onward) folds presumably pass. Are there other folds within W2/W4 (e.g. W2 split into pre-COVID, COVID acute, post-COVID) that would show whether the failure is the regime introduction itself or the initial state-mixing instability after a regime introduction? A finer-grained fold structure on the stress windows would clarify what the model is and isn't doing.

3. The K_eff diagnostic gives K_eff = 11/18 for CHMM-N at K=18 on SPY. What is the K_eff value at the headline K*=3 and K*=6 operating points? If K_eff = K_nominal at low K (which the appendix table suggests), the K=18 over-parameterization is purely a high-K artefact and the body framing should be: "the K=18 sensitivity reference reports a K_eff=11 model in K=18-state parameterization; at K=3 and K=6 there is no K_eff/K_nominal distinction." The current discussion of K_eff across the K-grid is lengthy and the punchline is buried.

### Requested Experiments / Analyses

1. **Block-overlap sensitivity for the multi-day DM finding.** Re-run the h=20 DM test with overlapping blocks at standard HAC adjustment (n_eff ≈ 552 with NW bandwidth scaled by overlap) and compare against the n=28 non-overlapping result. The non-overlapping n=28 result is the cleanest under iid block assumptions; the overlapping result is the more powerful test under correct HAC. If both agree, the headline is robust.

2. **Reference-implementation QuantGAN, not in-house TCN.** Either run the GitHub reference implementation of Wiese et al. (2020) on the same SPY IS / OoS windows or remove the "deep-generative class as negative control" framing. The current panel does not support the claim.

3. **Single-ν shared-shape CHMM-t ablation.** As R2 also notes (R2#4), refit CHMM-t with a single shared ν across all states. If the IS kurtosis overshoot disappears, the per-state ν_k is the binding constraint and the body's λ-shrinkage and bracket-lift discussion is downstream of the wrong choice.

4. **Sector-balanced cross-ticker panel at n=6 per sector.** Expand the 30-ticker panel to 60 tickers with n=6 per sector. The current n=3-per-sector ANOVA is severely underpowered (η²=0.16 with F(9,20)=0.44, p=0.90); n=6 per sector with the same evaluation pipeline would give the ANOVA F(9,50) the power to actually detect or rule out moderate sector effects.

### Minor Comments

- Title: "A Continuous Hidden Markov Model for Daily US-Equity Stylized-Fact Reproduction." The empirical scope is the three symmetric Cont stylized facts (heavy-tailed marginals, negligible linear ACF, slow |G_t| ACF), which is half of the standard list (leverage and gain-loss asymmetry are explicitly out of scope under symmetric per-state emissions). Either retitle to "Symmetric Stylized-Fact Reproduction" or reframe in the abstract that "stylized-fact" in the title means three of the five.
- The "companion-paper directions" in the conclusion (skew-emission extensions, vine copulas, Wiese-style TCN with Lambert-W) are extensive and would benefit from a one-line ranking by which is most likely to close which gap. Currently they read as a list of follow-ups without prioritization.
- In `tab:variant_choice`: "Cleanest IS kurtosis match; no shape parameter — CHMM-L" is borderline misleading. CHMM-L's IS simulated kurtosis (5.30 at K=3, 6.6 at K=18) does not match observed (7.68); CHMM-t penalised at λ=20 matches IS more cleanly. *Suggestion:* "Closest IS kurtosis match without a shape parameter" or restate the row entirely.

### Recommendation
**Major Revision.** Three changes are substantive (the four-family interchangeability framing, the leverage Q5-boundary claim, the QuantGAN negative-control framing) and at least two more should change the headline framing if the requested experiments confirm what I expect them to. The paper is honest and well-motivated; it just needs to commit to the conservative reading of its own data.

---

## Summary of Actionable Items (Deduplicated, Prioritized)

### Priority 1 (recommended for resubmission)

1. **(R1#1, R3#1)** Restructure Table 3 (or its surrounding text) so the column-best comparison is on a metric where the parametric class wins. Lead with the multi-day DM (Δ CRPS at h=20) or with the conditional-VaR Christoffersen-cc statistic; demote raw 1-day OoS KS to a context column, since the bootstrap dominates that axis.
2. **(R1#2, R2#3 & R2#requested-3, R3#1 & R3#requested-1)** Replicate the h=20 multi-day DM finding (CHMM-N beats bootstrap, p=0.003) on the six-asset universe and across walk-forward folds, with NW-HAC bandwidth sensitivity at h ∈ {2, 4, 8, 16}, and with overlapping vs non-overlapping blocks. Report median Δ CRPS and median p across asset×fold.
3. **(R2#1)** Re-compute the K-selection |z| (K=3 vs K=6, K=6 vs K=18) under a Diebold-Mariano-style HAC variance over rolling-origin folds, not under independent folds.
4. **(R2#5)** Reframe the body α=0.01 conditional-VaR text so the DQ rejection at K=18 (p=0.017) is reported as the substantive result, not as a confirmation of the Christoffersen-cc pass at α=0.05.
5. **(R2#weakness-7)** Add an explicit body sentence on the OoS block-bootstrap KS recalibration that the absolute level drops ~25pp from asymp to L=20, materially changing the qualitative read of the OoS panel.
6. **(R3#1)** Expand the four-emission-family contribution claim. Either demonstrate a setting where the four families are statistically distinguishable on a held-out metric, or reframe the contribution as a software-engineering scaffold rather than a methodological contribution.

### Priority 2 (recommended; if a Priority 1 result is not as expected, may move to Priority 1)

7. **(R1#3)** Refit-cadence sweep on the conditional-VaR walk-forward at monthly and weekly cadence. If faster refit closes 2-3 of the 5 W2/W4 failures, this is the production recipe.
8. **(R2#requested-2)** Compute the simulated IS kurtosis distribution against the bootstrap CI on observed IS kurtosis [2.17, 12.40] for the penalised CHMM-t at λ=20. If <50% of paths fall inside, the headline heavy-tail row is statistically distinguishable from observed.
9. **(R2#requested-4, R3#requested-3)** Single-ν shared-shape CHMM-t ablation. If the IS kurtosis overshoot disappears under shared ν, the per-state ν_k bracket / penalty discussion is downstream of the wrong design choice.
10. **(R3#requested-4)** Expand the sector-balanced 30-ticker panel to 60 tickers (n=6 per sector). The current n=3-per-sector ANOVA is severely underpowered.

### Priority 3 (framing and exposition; mostly local edits)

11. **(R1#5, R3#requested-3)** K=11 effective rebuild: refit CHMM-N at K_nominal=11 (matching the K_eff collapse value) and report against the K=18 nominal row. Use this as the substantive K_eff demonstration.
12. **(R3#3, R1#6)** Revise the leverage-effect framing: replace "envelope brackets observed at Q_5 boundary" with a permutation/bootstrap p-value, and let the p-value carry the framing. The current framing reports a borderline result as a positive finding.
13. **(R3#5)** Reframe the QuantGAN TCN row: either run a reference implementation or soften "deep-generative class as negative control" to "in-house WGAN re-implementation, with and without Lambert-W, fails on this dataset." The negative-control claim against an architectural class is not supported by one in-house run.
14. **(R3#4, R3#requested-2)** Strengthen the conclusion's GLD/SLV statement: 0% OoS KS on two non-equity ETFs is a hard rejection of cross-asset-class transfer, not a soft limitation.
15. **(R3#2, R1#minor)** Lead the abstract / introduction with the cross-ticker median dominant-mode share (0.756) rather than the SPY-specific 0.936; SPY sits in the right tail of the cross-ticker distribution and the headline framing should not generalize the SPY value.
16. **(R2#3)** Drop or re-do the cross-ticker ANOVA with adequate power; the current n=3-per-sector result is uninformative.
17. **(R3#minor)** Title and abstract: align "stylized-fact reproduction" scope with what the paper actually evaluates (three of five Cont facts). Either retitle to "Symmetric Stylized-Fact Reproduction" or note the scope explicitly in the first sentence of the abstract.
18. **(R1#minor, R2#minor)** Cleanup: remove leftover "Reviewer 1 / Reviewer 2 / minor item" attributions from appendix prose (these are response-letter artefacts), verify all `\ref{}` resolve (specifically `tab:hsmm_sojourn_compare`, `sec:supp_hsmm_diagnostic`), and standardize sub-seed conventions across tables (the ≤1pp drift footnotes should not be necessary in a published manuscript).

### Aggregate Recommendation Across Reviewers

- R1: Minor Revision
- R2: Major Revision
- R3: Major Revision
- **Aggregate: Major Revision.** The substantive items (Priority 1 and 2) include experiments that require new computation, not just rewording; at least three of them have the potential to change the headline framing. The methodology is correct and the honesty has materially improved; the framing needs to follow the methodology more conservatively, and the requested replications need to be done before a final acceptance.
