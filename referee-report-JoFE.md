# Referee Report — Journal of Financial Econometrics

**Manuscript:** "A Regime-Switching Continuous Hidden Markov Model as a Reference Synthetic-Data Generator for Equity Returns: Extended Evaluation, Semi-Markov Ablation, and Regime-Conditional Value-at-Risk"

**Recommendation:** **Major revision.**

---

## 1. Summary of the contribution

The authors propose a family of continuous hidden Markov models (CHMM-N / CHMM-t / CHMM-L) sharing a log-space forward–backward scaffold but differing in the per-state emission law. They argue that (i) at moderate state resolution (K = 18), a standard Baum-Welch CHMM reproduces the Cont (2001) stylized facts without jump augmentation or semi-Markov sojourn corrections, thereby "resolving" the Rydén et al. (1998) limitation; (ii) that flat CHMM-t wins distributional fidelity (MMD, discriminator AUC, aggregational kurtosis decay); (iii) that a semi-Markov plug-in variant improves unconditional VaR Kupiec calibration; and (iv) that a Viterbi-decoded regime-conditional VaR on flat CHMM-t passes Kupiec *and* Christoffersen independence simultaneously at 1% and 5% on a 2024–2026 holdout. The paper extends to cross-asset synthesis via SIM and Gaussian / Student-t copulas on six equities.

The manuscript is ambitious, technically competent, and reproducible. My concerns, below, are primarily about **scope of novelty**, **econometric rigor of the headline tests**, and **depth of empirical evidence** relative to the standard expected of a JoFE publication.

---

## 2. Major concerns

### (M1) Novelty is narrower than the framing suggests.

The three contributions the authors advertise against the prior literature — (i) continuous emissions in an HMM for equity returns, (ii) per-state Student-t with ECM ν-update, and (iii) moderate-K HMMs recovering slow |r| ACF decay — are each already present in the literature.

- Continuous-emission HMMs for long-memory volatility: Nystrup et al. (2017), cited.
- Student-t / GED emissions via ECM in switching models: Peel & McLachlan (2000), Liu & Rubin (1995), Abanto-Valle et al. (2017), all cited.
- The "higher K removes the geometric-sojourn artefact" observation appears implicitly in Bulla (2011) and Rossi & Gallo (2006), among others.

I recommend the authors either (a) reposition the contribution as an *integrative evaluation* (unified EM scaffold + rigorous twelve-generator panel + regime-conditional VaR test) rather than as a methodological innovation, or (b) supply a clean demonstration that the specific variant presented here (per-state ν-ECM within a multi-state CHMM, on daily equity returns) is either genuinely new, more accurate, or more efficient than the closest published alternative. The current framing around "the Rydén limitation is a low-K artefact" overclaims: it was an artefact of K = 2–3 Gaussian emissions, and three decades of subsequent work — including the authors' own HSMM and jump-augmented references — has moved past it.

### (M2) The in-sample KS / AD "pass rate" headline metric is problematic at T = 2,516.

The KS test at T = 2,516 has extreme power against any small distributional mismatch, so reporting that CHMM-N "achieves 93.8% IS KS pass rate" is hard to interpret. A 93.8% pass rate over 1,000 simulated paths means that roughly 6% of the simulated paths are statistically distinguishable from the observed series at α = 0.05 — effectively the nominal false-positive rate. The authors' own "power calibration" in Appendix (Appendix sec:ks_power) shows that 572-day i.i.d. resamples of the IS distribution itself pass at only 90%, which should weaken rather than support the headline claim; the test is clearly not at α = 0.05 in a well-defined sense.

For a JoFE audience, I would expect:
- Either a block-bootstrap or stationary-bootstrap recalibration of the KS test that accounts for volatility clustering in the simulated paths (the authors flag this as a limitation but do not resolve it);
- Or explicit reporting of the mean p-value and its distribution, rather than only a pass rate.

The paper's numerical contrasts across generators (e.g., CHMM-N at 93.8% vs. bootstrap at 99.9%) are then easier to read.

### (M3) The regime-conditional VaR construction is not a valid out-of-sample backtest as stated.

The Viterbi-decoded conditional VaR runs Viterbi *on the OoS series itself* (equation (9); §sec:conditional_var), using the full OoS sequence $(r_1, \ldots, r_T)$ to infer $(\hat s_1, \ldots, \hat s_T)$. Viterbi is a *smoother* (MAP of the joint state sequence given the whole observation), not a *filter*: $\hat s_t$ is a function of $r_{t+1}, \ldots, r_T$, so the "regime-conditional quantile" at time $t$ depends on future data. A Christoffersen independence test on the resulting breach sequence is therefore not a one-step-ahead backtest and does not correspond to any quantity a risk manager could deploy in real time.

The authors should either (a) replace the smoother with a filter (the standard forward-only posterior $P(s_t \mid r_{1:t})$ used with the IS-fitted parameters) and re-run Kupiec/Christoffersen, or (b) explicitly re-label this as an in-sample goodness-of-fit diagnostic for regime structure rather than a VaR backtest. The current framing — "flat CHMM-t with Viterbi-decoded conditional VaR is the best generator on regime-conditional VaR" — is misleading without this correction. This revision is, in my view, the single most important change to the paper.

### (M4) The empirical base is thin for JoFE.

One index (SPY) on 10 years plus five US large-caps, with a single 572-day OoS window, is the base for every headline claim. A JoFE paper making "synthetic-data generator for equity returns" claims should show robustness across:
- multiple indices (e.g., MSCI, DAX, Nikkei, FTSE) and multiple sample periods;
- rolling-origin or expanding-window OoS evaluation rather than a single split;
- at minimum two sampling frequencies (e.g., daily + weekly, or daily + 5-minute aggregated).

The NVDA/JPM OoS KS cliff (55.8% / 49.8%) is itself evidence that the IS-fit stationary CHMM does not generalize well under plausible structural change. The 15pp recovery from rolling refits on JPM leaves a 35pp residual gap, which is a significant caveat on the generalization claim.

### (M5) Kupiec / Christoffersen tests are underpowered on T_OoS = 572.

At α = 1%, expected breaches on 572 days ≈ 5.72. The independence test on a sequence with 5–7 breaches has negligible power; "flat CHMM-t passes Christoffersen at LR_ind = 0.09" reflects both (i) clean calibration and (ii) a test that is essentially asymptotic-theory off-manifold at this sample size. I would ask the authors to (a) report the bootstrap null distribution of LR_ind at n = 572, α = 0.01 and locate the CHMM-t statistic within it, and (b) temper the "passes cleanly" language throughout.

### (M6) The semi-Markov ablation is preliminary.

The SM variants are fit by a *plug-in* estimator (Viterbi decode + post-hoc sojourn fit), not by an explicit-duration forward–backward MLE (Yu 2010). The authors acknowledge that the conditional-VaR estimator for SM-CHMM "is non-trivial and we defer it." For JoFE this is a substantial deferral: the paper's three-way operational split (distribution / unconditional VaR / conditional VaR) rests on SM-CHMM being the unconditional-VaR row, but the unconditional calibration gain on SM-CHMM-N (LR_uc: 3.83 → 0.82) is numerically small relative to MC error on 572 days, and no MS-GARCH confidence interval is shown. A proper SM MLE, even on a subset of the panel, would substantiate the claim.

### (M7) Benchmark set omits standard econometric baselines.

GARCH(1,1) with Gaussian innovations is the sole classical volatility baseline in the main panel. Standard JoFE GARCH competitors that should be included:
- EGARCH and GJR-GARCH (asymmetric volatility, directly relevant to the leverage-effect metric);
- GARCH-t or Student-t innovations (tail-aware, direct competitor to CHMM-t);
- HAR-RV or Realized GARCH with intraday realized measures (would tighten the "temporal fidelity" discussion);
- FIGARCH (long-memory, directly relevant to the ACF-decay claim against Rydén et al.).

The MS-GARCH addition is welcome but a single two-regime specification is not sufficient to represent that family. The "deep-generative" baselines (GRU, QuantGAN, window diffusion) are explicitly described as "reproducible first-pass designs" and "negative controls" — the paper then uses this weakness to support the CHMM's ranking on MMD and AUC, which is circular.

### (M8) Model selection for K.

K = 18 is selected by "winning or tying every IS and OoS distributional pass-rate metric" combined with IC rank. This is a data-dependent multi-objective selection using the OoS window, which is an evaluation contamination if that window is then used for the VaR backtest. The cleaner approach: select K on a pre-OoS validation window (e.g., 2022–2023 carved from IS), or by walk-forward log-likelihood, then evaluate 2024–2026 once. The authors acknowledge this under "Limitations" but should correct it.

### (M9) Symmetric emissions.

SPY's IS skewness is −0.75, but all three emission families are within-state symmetric. A single skew-t or skew-Laplace emission would be a natural ablation and is standard in the regime-switching literature (Chib & Greenberg, Fruhwirth-Schnatter). Given the paper's otherwise careful emission-family treatment, omitting it is a minor gap.

### (M10) CHMM-t kurtosis overshoot.

IS excess kurtosis of 14.57 vs. observed 7.68 is a ~90% overshoot. The authors diagnose via ν_k histogram and bracket sensitivity, concluding that only the ν → ∞ Gaussian limit cures it. This suggests an over-fitting diagnostic on the ECM search itself. A hierarchical or shrunk prior on ν_k, or a penalized-likelihood correction, would be the principled remedy and would materially strengthen the paper.

---

## 3. Minor comments

1. Abstract, l.113: "tie for the best-in-panel Kupiec likelihood-ratio statistic at 1% (LR_uc = 0.01)". LR_uc = 0.01 is ≈ the smallest possible achievable statistic on a coarse breach grid; this is close to point-mass identical, not a meaningful tie-ranking.
2. §sec:descriptive: the annualized Std Dev of 2.19 for SPY is unusual given SPY's IS daily std ≈ 1.1%, i.e. annualized ≈ 17%. Verify units of the reported annualized moments throughout the paper; the same may apply to the annualized excess growth-rate convention of §sec:data.
3. §sec:model_comparison, Table 3: "OoS AD for Bin-T NJ, Block-BS, and GRU is reported alongside OoS KS in the row" — actually missing from the tabulated cells; check layout.
4. Table 5 (extended metrics), GARCH IS MMD "0.0†": the bandwidth-heuristic footnote is correct, but using a median-heuristic bandwidth that depends on the generator makes the cross-model MMD ranking unreliable. Fix the bandwidth to that selected on the observed sample and recompute.
5. §sec:cross_asset, correlation "off-diagonal MAE": clarify whether this is averaged over the 15 unique off-diagonal entries or over 30 (counting both triangles).
6. The Bin-T NJ / K_disc = 13 ablation changes both the bin count and the emission family (acknowledged). For the ablation to isolate "emissions vs. bin count", a K_disc = 13 centroid variant should also be reported.
7. "Flat CHMM-t attains the smallest MMD of any row in the panel" — the SM-CHMM-L attains 4.0 × 10⁻⁵ per §sec:sm_ablation, smaller than flat CHMM-t's 2.0 × 10⁻⁵. Reconcile.
8. References: please add Timmermann (2000), Psaradakis & Sola (1998), Augustyniak (2014) on MS-GARCH MLE; Andersen & Bollerslev (1997) and Ding, Granger & Engle (1993) on long-memory volatility; Maheu & McCurdy (2004) on jump-diffusion with regime switching. All are squarely in the JoFE citation space.
9. Terminology: "Ryden et al." is consistently written "Rydén"; verify diacritics.
10. The paper reports a single global seed (20260420). A JoFE-audience reader will want a Monte Carlo robustness summary across at least 10–20 seed replicates for the headline pass-rate and VaR-LR statistics.

---

## 4. Final verdict

The manuscript is technically sound, carefully implemented, and reproducible, and it contains useful empirical contrasts. However:

- The single most important methodological issue (M3 — the Viterbi-smoothed conditional VaR is not a one-step-ahead backtest) must be resolved before publication;
- The novelty framing (M1) needs repositioning to match what is actually new;
- The empirical scope (M4) needs broadening beyond SPY + 5 US stocks + one OoS window for a JoFE contribution.

These are substantive but addressable. I therefore recommend **major revision**, with the expectation that a revised manuscript re-addressing (M1), (M3), (M4), (M7), and (M8) would be a strong JoFE contribution.

I would be willing to re-review.
