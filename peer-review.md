# Simulated Peer Review

**Manuscript:** *A Continuous Hidden Markov Model for Daily US-Equity Stylized-Fact Reproduction* (Alswaidan, Jin, Varner)
**Target tier:** Mid-to-high-tier econometrics / quantitative-finance journal (e.g., *Journal of Empirical Finance*, *Quantitative Finance*, *Journal of Financial Econometrics*, *Studies in Nonlinear Dynamics & Econometrics*).

> **Note on reviewer expertise.** The manuscript is a financial-econometrics paper (CHMM as a synthetic-data generator for daily equity returns), not metabolic engineering. The skill-card personas have therefore been instantiated with the appropriate domain expertise: regime-switching econometrics, hidden Markov / hidden semi-Markov models, GARCH/MS-GARCH, copula methods, and VaR back-testing. The "moderate / hard / very hard" stance levels are preserved.

---

## Reviewer 1 — Moderate (senior researcher in regime-switching econometrics and HMM time-series methods)

### Summary

The authors evaluate four interchangeable continuous-emission HMM variants (Gaussian, Student-$t$, Laplace, GED) trained by Baum-Welch / ECM under a unified scaffold, on SPY 2014-2026 plus a 30-ticker sector-balanced panel and a six-asset Student-$t$ copula extension. They (i) recast the Rydén et al. (1998) low-$K$ failure as an effective-rank statement on the deflated transition matrix, (ii) demonstrate that the rank constraint is non-binding at $K\geq 3$ on equity-return data, and (iii) wrap the model in a regime-conditional Christoffersen-cc VaR back-test that passes cleanly at $\alpha=0.05$ on the headline OoS window and on $19/24$ walk-forward folds. The paper is unusually self-aware about its weaknesses (walk-forward stress folds, $K_{\text{eff}}$ vs $K_{\text{nom}}$, block-bootstrap KS recalibration, FDR correction), and the Julia code reproduces every numerical artefact under a documented seed policy. I think this is a publishable empirical study after revision; the substantive contribution is the unified four-emission scaffold plus the regime-conditional VaR application, not a theoretical advance.

### Strengths

1. **Honest reporting of the bootstrap and ML HSMM dominance on raw OoS KS.** The body explicitly states (sec:model_comparison) that the stationary block bootstrap attains $99.7$/$92.1\%$ IS/OoS KS and ML HSMM-N at $K^\star = 3$ attains $91.0\%$ OoS KS, both above every CHMM operating point. Many papers in this space would have buried this; the authors instead reposition the contribution as the "use-case decision" (regime-conditional VaR, parametric multi-asset coupling, privacy/licensing). I find this framing credible.

2. **The unified ECM scaffold across four emission families is a real architectural contribution.** Identical forward-backward recursions and quantile-based initialisation, with the M-step as the only architectural difference, including bracketed $\nu_k$ and $p_k$ updates with stated EM-monotonicity guarantees (Prop. 1, sec:supp_propositions). This is more rigorous than typical HMM-finance papers.

3. **Walk-forward stability is exercised at the right granularity.** Six rolling-origin folds (Table 6 / sec:supp_misc) at 5-year train / 1-year test, with stress-fold flags (W2 COVID, W4 2022 rate-hike). The authors then explicitly state that the single-window OoS sits at the upper tail of the walk-forward distribution and that "the walk-forward median is the operationally informative summary," rather than headlining the single-window result.

4. **Multiple-testing correction (Benjamini-Hochberg) on the Christoffersen-cc panel** (sec:var_backtest, "Multiple-testing correction" paragraph). Few applied papers in this area do this; the result that 37/40 rows survive BH at FDR 0.05 strengthens the conditional-VaR claim materially.

5. **The $K_{\text{eff}}$ correction to the IC sweep** (sec:k_selection_results, "$K_{\text{eff}}$-corrected information-criterion re-rank" paragraph) directly addresses the criticism that AIC/BIC at $K=18$ over-credits the model when 7/18 states collapse under single-linkage merge. The correction shifts AIC/HQC selection by 18 nominal states but leaves BIC/CAIC and the held-out criteria unchanged; this is the right diagnostic.

### Weaknesses

1. **The body headline at $K^\star = 6$ is held-out-clean but the strictly pre-2020 selection slice is only 4.5 years (1130 obs).** sec:supp_misc, "Pre-2020 held-out $K$-selection" paragraph: held-out per-observation log-lik picks $K^\star = 6$ but AIC/BIC/HQC/CAIC all pick $K^\star = 3$ on the same slice, with the authors attributing the IC-vs-likelihood gap to "the parameter-count penalty on a $4.5$-year estimation window." This concedes the core problem: the "held-out-clean" $K^\star = 6$ selection is supported by exactly one fold of one slice on a small estimation window, and the corresponding $K^\star = 6$ pre-2020 held-out KS pass rate of $96.8\%$ vs $K^\star = 3$ at $84.6\%$ is a single observation. *Suggested fix:* run a $k$-fold cross-validation (5 or 10-fold rolling-origin) on the strictly pre-2020 slice and report the mean $\pm$ s.d. held-out KS at each $K \in \{3, 6, 9, 12, 18\}$. If $K = 6$ remains preferred over $K = 3$ outside sampling error, the headline claim is supported; if not, the body should be rebuilt at $K^\star = 3$.

2. **The penalised CHMM-t at $\lambda = 20$ is reported as the headline kurtosis match but $\lambda$ is essentially a tuning knob.** sec:discussion, "Closing the kurtosis gap" paragraph: $\lambda = 20$ is "held-out-clean" via a single grid point on the same pre-2020 slice as item 1; the per-ticker sweep (Table per_ticker_lambda) shows $\hat\lambda^\star \in \{0, 10, 20\}$ across six tickers, so the body's uniform $\lambda = 20$ over-shrinks 3/6 tickers. *Suggested fix:* either drop $\lambda = 20$ from the body and report the $\nu_{\min} = 4$ bracket-lift ablation alongside CHMM-N as the kurtosis comparison (since the bracket lift is structurally cleaner than an exponential prior whose rate is selected on the same data), or report the per-ticker $\hat\lambda^\star$ recipe as the headline method and the uniform $\lambda = 20$ as a worked example.

3. **The "regime-conditional VaR passes Christoffersen-cc cleanly" claim is power-bounded at $\alpha = 0.01$.** sec:var_backtest, "Power caveat" paragraph: the test reaches $\geq 80\%$ power against breach-clustering eigenvalues $\rho \geq 0.50$ at $\alpha = 0.01$ and $T_{\text{OoS}} = 572$, with rejection rate only $42.6\%$ at $\rho = 0.20$. The body table lists $\alpha = 0.01$ rows alongside $\alpha = 0.05$ rows without distinguishing them by power. *Suggested fix:* mark the $\alpha = 0.01$ rows with a footnote referencing the power calibration, or restrict the body table to $\alpha = 0.05$ and move $\alpha = 0.01$ to an appendix.

4. **The leverage-effect "partial capture via state-mixing" claim is at the lower 5% tail of the simulated distribution.** sec:discussion, "Stylized-fact scope" paragraph: at $K = 18$, the CHMM-N path-level median is $-0.087$ on OoS with $[Q_5, Q_{95}] = [-0.190, +0.015]$, and the OoS observed value sits "just below the $Q_5$ floor." This is on the borderline of bracketing; the IS observed value at $-0.135$ "sits at the $Q_5$ boundary." Calling this "partial capture" is generous. *Suggested fix:* report the per-path leverage distribution with one-sided test, or rephrase to "the simulated distribution does not reject the observed leverage at the 5\% level on either window" (a much weaker claim that is what the data support).

5. **The block-bootstrap KS recalibration drops the absolute pass rate by 20-30 pp** (sec:model_comparison, "Block-aware OoS KS" paragraph; Table 3). The cross-generator ranking is preserved but the absolute KS pass-rate in the abstract ($88.3$-$92.6\%$ IS / $76.3$-$79.0\%$ OoS) is the asymptotic-i.i.d.-null number. *Suggested fix:* report the block-aware pass rate alongside the asymptotic value in the abstract for the headline operating point, e.g. "$92.6\%$ IS / $78.3\%$ OoS at $\alpha = 0.05$ asymptotic, $\sim$60\% block-aware."

### Questions for Authors

1. The ML HSMM-N at $K^\star = 3$ row attains $91.0\%$ OoS KS in Table 2 but $|G_t|$ ACF-MAE 0.0629, "matches the i.i.d.\ baseline." The Bulla and Berzel (2008) HSMM result, on which the present comparison rests, used a Gamma sojourn distribution rather than truncated Pareto; would a Gamma-sojourn HSMM at the same $K$ recover non-trivial $|G_t|$ ACF, reopening the head-to-head comparison?

2. sec:cross_asset states the Student-$t$ and Gaussian copulas are statistically indistinguishable on OoS off-diagonal MAE ($0.209$ vs $0.202$), but the body still selects $\nu^\star = 6$ via IS profile MLE. Why headline the Student-$t$ copula rather than the simpler Gaussian copula, given the OoS equivalence?

3. The empirical effective-rank diagnostic on SPY (sec:theory, "Ryd\'{e}n separation as a $K$-rank statement") shows a single non-unit eigenvalue carries $93.6\%$ of the lag-1 ACF, but the cross-ticker median dominant-mode share is $0.76$ with minimum $0.33$ on NEM. Does the SPY-headline framing of the spectral mechanism remain operative on the tickers with low dominant-mode share, or do those tickers require a different decay structure (e.g., a second slow mode)?

4. The CHMM-t bracket choice $\nu_{\min} = 2.1$ lies below the kurtosis-finiteness threshold $\nu = 4$. Why was this bracket chosen rather than $\nu_{\min} = 4$ (which would avoid the lower-bracket pinning artefact in the first place and remove the need for the $\lambda = 20$ penalty)?

5. The $K = 18$ operating point has $K_{\text{eff}} = 11/18$ effective states by the standardized-distance single-linkage diagnostic. If the model is operationally an 11-state model in an 18-state parameterisation, why not report $K^\star = 11$ or $K^\star = 12$ as an additional headline point alongside the held-out-clean $K^\star = 6$?

### Requested Experiments / Analyses

1. **$k$-fold cross-validation of $K^\star$ on the strictly pre-2020 slice.** Report mean $\pm$ s.d. of held-out per-observation log-likelihood and held-out KS at $K \in \{3, 6, 9, 12, 18\}$ over 5 or 10 folds. This is the right diagnostic for the body claim that $K^\star = 6$ is preferred on the held-out criterion; the current single-fold result is one observation.

2. **$\nu_{\min} = 4$ bracket-lift CHMM-t as the body headline,** with the $\lambda = 20$ penalised version reported as a sensitivity. The bracket lift is structurally cleaner (no tuning knob, no "held-out-clean" claim required) and the existing $\dagger\dagger$ row in Table 2 already shows IS/OoS KS within 0.6 pp of the penalised version. This would simplify the body framing materially.

3. **Gamma-sojourn HSMM as a co-headline foil.** The truncated-Pareto HSMM in Table 2 is the natural foil to the Markov-chain CHMM; a Gamma-sojourn or Negative-Binomial-sojourn HSMM (closer to Bulla and Berzel 2008) is the historically-grounded foil and may close the $|G_t|$ ACF-MAE gap that the truncated-Pareto HSMM does not.

4. **Quarterly-refit version of the body single-window result.** The cross-ticker quarterly refit lifts the OoS KS distribution from $73.4 \to 83.0\%$ on the 30-ticker panel; the same refit on the SPY headline window would let the body claim a single operating point that survives both held-out clean (single-window OoS) and walk-forward (six folds) at the same KS level.

### Minor Comments

1. Abstract: the phrase "single OoS window panel rankings are walk-forward-fragile" is awkward; consider "single-window rankings do not survive the rolling-origin walk-forward and the walk-forward median is the operational summary."
2. Table 2: "ML HSMM-N at $K^\star = 3$" appears as a separate block between the body headline and the sensitivity reference. Consider promoting it to a row inside the body block or adding a horizontal rule break for visual separation.
3. The $\dagger\dagger$ footnote on Table 2 explains the $\nu_{\min} = 4$ bracket-lift ablation but is squeezed into a long caption; consider promoting to a numbered remark in the text near sec:discussion.
4. The Cont (2001) stylized-fact list is referenced as having three symmetric facts plus leverage, but Cont's original list also includes gain/loss asymmetry and slow decay of cross-correlations of volatility; the scope statement in the abstract should explicitly enumerate which Cont facts are addressed and which are not.
5. The phrase "held-out-clean" is repeated 30+ times in the body; consider defining it once as a noun ("a held-out-clean operating point" with the criteria spelled out) and using it sparingly thereafter.

### Recommendation

**Major Revision.** The contribution is genuine (unified four-emission scaffold + regime-conditional VaR) and the empirical scope is appropriately bounded. The body headline at $K^\star = 6$ rests on a thinner held-out claim than the writing implies, and the leverage-effect and penalised-CHMM-t framing both overreach what the data support. Items 1, 2, 4 in "Weaknesses" and Experiments 1 and 2 are the priority revision items; the rest are secondary.

---

## Reviewer 2 — Hard (expert in MS-GARCH / regime-switching estimation, copula methods, and VaR back-testing)

### Summary

The manuscript presents a continuous-emission HMM as a synthetic-data generator and headlines a regime-conditional Value-at-Risk that passes Christoffersen-cc on a single OoS window. The methodology is implemented competently and the reproducibility infrastructure (Julia package, seed policy) is above field standard. However, the comparison panel is a self-implementation of every benchmark, the cross-asset claim does not survive the OoS window, and the spectral-mechanism contribution is essentially restating Hamilton (1994) §22.2. I have substantive concerns about (a) the choice of MS-GARCH benchmark, (b) the headline single-window framing, (c) the discrepancy between the abstract's "$76.3$-$79.0\%$ OoS KS" and the block-aware "$\sim$60\%" recalibration, and (d) the joint identification of the four-emission family in the cross-ticker regime. The paper is publishable but the headline claims need to be recalibrated against the controls already shown in the appendix.

### Strengths

1. **The spectral-rank diagnostic on $\hat{\mathbf{T}} - \mathbf 1\bar{\boldsymbol\pi}^\top$** (sec:theory and Table tab:spectral_modes) is the right object to compute. The dominant-mode-share number ($93.6\%$ on SPY at $K = 18$) is informative and the cross-ticker robustness check (median $0.76$, min $0.33$ on NEM) is the right scope statement.

2. **The numerical full-rank check on $\hat{\mathbf{T}}$ at $K = 18$** (Table 7, sec:supp_propositions) addressing the Allman-Matias-Rhodes (2009) identifiability prerequisite. The condition-number reporting ($63$ for CHMM-GED, $1{,}620$ for CHMM-t) is well-aligned with the $K_{\text{eff}}$ diagnostic.

3. **The block-bootstrap KS null distribution** (Table 3) at $L = 20$ is the right recalibration for autocorrelated daily returns; the result that the cross-generator ranking is preserved while absolute pass rates drop by 20-30 pp is a clean honesty check.

4. **The Diebold-Mariano panel with Newey-West HAC at bandwidth $h = \lfloor T_{\text{OoS}}^{1/3}\rfloor = 8$** (sec:model_comparison, end of paragraph 4) and the bandwidth sensitivity sweep over $h \in \{4, 8, 16, 32\}$ are textbook-correct. Many papers stop at $h = 8$; the sweep is worth keeping.

### Weaknesses

1. **The MS-GARCH benchmark is a Nelder-Mead self-implementation, not the Ardia et al. (2019) `MSGARCH` R package.** The authors flag this honestly in sec:discussion ("Baseline-implementation caveats" paragraph), but the body abstract and Table 2 footer still use the $34$-$36\%$ IS KS plateau as the comparison baseline, and the body sentence "the multi-state benefit is specific to the CHMM scaffold rather than to multi-state regime-switching per se" is not supported by the present panel. *Required fix:* either re-run MS-GARCH with the `MSGARCH` R package and report the result, or weaken the "multi-state benefit" claim to "in our re-implementation" wording throughout the body, not only in sec:discussion.

2. **The headline "$76.3$-$79.0\%$ OoS KS at $K^\star = 6$" in the abstract is an asymptotic-i.i.d.-null number that the block-aware recalibration cuts to $\sim$56-62\%.** sec:model_comparison, Table 3 reports the $K = 18$ block-aware values explicitly; the $K^\star = 6$ block-aware values are not reported. The reader who does not reach Table 3 will assume the $76$-$79\%$ figure is the operative pass rate. *Required fix:* report the block-aware value alongside the asymptotic value in the abstract for the headline operating point. If the block-aware value is not the right framing, the body should justify the asymptotic null on autocorrelated returns, which the authors themselves note is not the right null.

3. **The Christoffersen-cc test depends on a binary breach indicator that is sensitive to the choice of VaR threshold construction.** sec:var_backtest defines the conditional threshold via the predictive mixture CDF $F_t(\cdot) = \sum_k \Pr(s_t = k \mid \mathcal{F}_{t-1}) F_k(\cdot)$, but does not state whether the predictive density is evaluated under the IS-fixed parameters $(\mathbf{T}, \boldsymbol\theta)$ or whether the parameters are updated as the OoS window unfolds. The body footnote in Table 4 says "no refit," but it would be helpful to see a control variant where the parameters are refit at the start of every OoS quarter; if the conditional pass rate degrades materially under the parameter-refit variant, the "regime-switching value proposition" is partly an IS-specific artefact. *Required fix:* report a quarterly-refit conditional VaR back-test as an additional row in Table 4.

4. **The four-emission family is not uniquely identified across the cross-ticker panel.** sec:supp_p_partition reports CHMM-GED $\hat{p}_k$ partitions bimodally into Gaussian and Laplace, but the fitted parameters across the four families are not reported in the body or appendix. If CHMM-N, CHMM-L, CHMM-GED, and the bracket-lifted CHMM-t produce statistically indistinguishable per-state $\mu_k, \sigma_k, \mathbf{T}$ on the cross-ticker panel up to the shape-axis difference, then the four-family choice is operationally a one-parameter family along the GED $p$ axis. The headline four-emission narrative should be tested. *Required fix:* report the per-state location/scale Frobenius distances $\|\mu_{\text{N}} - \mu_{\text{L}}\|, \|\sigma_{\text{N}} - \sigma_{\text{L}}\|, \|\mathbf{T}_{\text{N}} - \mathbf{T}_{\text{L}}\|$ on the SPY headline and on the 30-ticker panel; if these are below the per-state Monte Carlo standard errors, the four-family narrative collapses to a one-parameter axis.

5. **The Student-$t$ copula profile-MLE at $\nu^\star = 6$ rests on a Kendall's-$\tau$ inversion that is exact under the Gaussian copula and approximate under the Student-$t$.** The authors report a full one-shot MLE on the same six-asset universe (sec:full_tcopula_mle, $\hat\nu_{\text{full}} = 6.40$ vs $\hat\nu_{\text{two-step}} = 6.00$, $+5.55$ log-likelihood) and conclude the two-step is not detectably biased, but a $+5.55$ log-likelihood gap on $T_{\text{IS}} = 2{,}516$ is on the order of several standard errors of the profile likelihood. *Required fix:* report the Wilks 95\% profile-LL CI under the full one-shot MLE, not only under the two-step estimator; if the full-MLE CI excludes the body $\nu^\star = 6$, the body construction should be re-anchored on $\hat\nu_{\text{full}} = 6.40$.

6. **The walk-forward Christoffersen-cc panel reports $19/24$ pass rate at $\alpha = 0.05$, but the BH-corrected pass rate is $21/24$** (sec:var_backtest, "Multiple-testing correction" paragraph). The BH correction is doing real work here: two rows that fail the uncorrected test pass under BH because their $p$-values are individually marginal and the false-discovery threshold is more lenient. This is the right test for the panel-level claim, but the body sentence "passes at every $(K, \alpha)$" in the abstract is the per-row claim, not the panel-level one. The two should be distinguished. *Required fix:* state the panel-level pass-rate claim ($21/24$ or $37/40$ under BH at FDR 0.05) in the abstract instead of the per-row "passes at every $(K, \alpha)$" claim, which is true only on the headline single window.

7. **The contribution claim "(i) We apply the textbook bilinear identity ..." is not novel.** The authors are explicit about this in sec:theory and the introduction's contribution list, framing it as "the empirical effective-rank application." But the body of sec:theory occupies 1.5 pages on the standard derivation. *Required fix:* compress sec:theory by referring the reader to Hamilton (1994) §22.2 / Krolzig (1997) Ch. 3 / Timmermann (2000) for the derivation and present only the rank statement, the cross-ticker dominant-mode-share distribution, and the empirical effective-rank diagnostic. The current 1.5-page derivation is space that could host the missing controls (items 1, 3, 4).

### Questions for Authors

1. Why was the Kendall's-$\tau$ inversion ($\rho_{ij} = \sin(\pi \tau_{ij}/2)$) used as the IS correlation estimator rather than the Pearson correlation on the rank-transformed data, given that the latter has a known closed-form relationship to the Spearman $\rho_S$ and is also robust to the marginal distribution? Did the authors compare the two?

2. The $1/\nu_k$ shrinkage at rate $\lambda = 20$ is presented as the body-headline kurtosis match, but the corresponding Bayesian interpretation (an exponential prior on $1/\nu_k$) implies a specific prior mean of $1/20 = 0.05$ on $1/\nu_k$, i.e., a prior mean of $20$ on $\nu_k$. Is this a substantive prior choice or an empirical regularisation? If the latter, why not report a marginal-likelihood selection of $\lambda$ via grid search at the per-asset level?

3. The cross-asset extension uses CHMM-N marginals at $K = 18$ rather than the body-headline $K^\star = 6$. Why the inconsistency? Does the cross-asset off-diagonal MAE recover under $K^\star = 6$ marginals?

4. The $K = 18$ HSMM "collapses to near-degenerate optimum" at $0.8\%$ IS / $33.4\%$ OoS KS in 9 EM iterations (Table 2). Is this a fundamental limitation of the truncated-Pareto sojourn at this $K$, or an initialisation issue with the Yu (2010) explicit-duration EM? Did the authors try a different sojourn family or different initialisation?

5. The QuantGAN baseline is "a three-conv-layer convolutional WGAN that is materially smaller than the seven-block TCN of Wiese et al. (2020)" (sec:discussion, "Baseline-implementation caveats" paragraph), and the TCN rebuild reported at the bottom of Table 2 still attains $0\%$ IS / $0\%$ OoS KS. Is this credible? The original Wiese et al. paper reports $\sim 80\%$ KS pass rates on a similar SPY window with the full architecture and the Lambert-W input pre-processing. The authors' TCN rebuild does not include the Lambert-W transform; without it, what is being compared to what?

### Requested Experiments / Analyses

1. **Reference-implementation MS-GARCH re-run.** Replace the self-implementation MS-GARCH rows in Table 2 with the Ardia et al. (2019) `MSGARCH` R package output at $K \in \{2, 3, 4\}$ on the same SPY IS / OoS window. Report at minimum IS / OoS KS, $|G_t|$ ACF-MAE, and CRPS. If the reference implementation closes the gap to CHMM, the body framing must shift; if not, the present claim is supported and the body need only cite the result.

2. **Quarterly-refit conditional VaR back-test.** Add a row to Table 4 in which the CHMM-N parameters $(\mathbf{T}, \boldsymbol\theta)$ are refit at the start of every OoS quarter, with the predictive density updated correspondingly. If the Christoffersen-cc pass rate degrades materially under refit, the "regime-switching value proposition" of sec:var_backtest is partly an IS-specific artefact and the body framing must be qualified.

3. **Per-state Frobenius distance between the four emission families on the cross-ticker panel.** Compute $\|\mathbf{T}_{\text{N}}^{(i)} - \mathbf{T}_{\text{L}}^{(i)}\|_F$, $\|\boldsymbol\mu_{\text{N}}^{(i)} - \boldsymbol\mu_{\text{L}}^{(i)}\|_F$, etc., for each ticker $i$ across the 30-ticker panel. Report the distribution. If the cross-family distances are within the per-ticker Monte Carlo s.e., the four-family narrative collapses to a one-parameter shape axis and the body should be reframed accordingly.

4. **Block-aware OoS KS at $K^\star = 6$.** Table 3 reports the block-aware OoS KS only at $K = 18$. Report the same recalibration at the headline $K^\star = 6$ operating point; if the block-aware value at $K^\star = 6$ is materially below the $K = 18$ block-aware value, the body framing of $K^\star = 6$ as the held-out-clean default is at risk.

### Minor Comments

1. sec:results, "Replicating the slow-ACF behaviour" paragraph in sec:discussion: "the random initialisations standard in the 1990s often converge to degenerate local optima." This is informal; cite Bilmes (1998) for the EM-initialisation analysis or remove the editorial claim.
2. Table 2 caption: "marked with leading $\star$" — the markings are easy to miss; consider boldface block headers.
3. sec:var_backtest, the equation for $\widehat{\text{VaR}}_t$ uses $F_k$ to denote the per-state CDF, but the previous sec:chmm_def used $b_k$ for the per-state density. The notation should be consistent ($f_k$ for density, $F_k$ for CDF).
4. Table 4: "median $\widehat{\text{VaR}}_t$" should be "mean $\widehat{\text{VaR}}_t$" or the median's role explained — for a time-varying threshold the median is one of several reasonable summaries.
5. References list: Bulla and Berzel (2008) is not in the bib but is the natural HSMM antecedent to bulla2006stylized; consider adding.

### Recommendation

**Major Revision.** The methodology is sound and the reproducibility is exemplary, but the body framing overstates several claims relative to what the controls already in the appendix support. Items 1, 2, 3, and 4 in Weaknesses are the priority revision items. After those are addressed, this is a publishable applied econometrics paper.

---

## Reviewer 3 — Very Hard (skeptical expert; has published competing methods on regime-switching synthetic-data generation)

### Summary

The authors apply Baum-Welch HMM with continuous emissions to daily SPY returns and claim that this is a useful synthetic-data generator. The methodology is standard, the spectral derivation is textbook, and the empirical claim that "the rank constraint is non-binding at $K \geq 3$" was already implicit in any HMM finance paper that fitted $K \geq 3$ Gaussian emissions and obtained any non-trivial absolute-return ACF. The headline OoS KS pass rates of $76$-$79\%$ at $K^\star = 6$ collapse to $\sim 60\%$ under the block-aware recalibration the authors themselves perform, the bootstrap dominates every CHMM row on the headline window, ML HSMM-N at $K^\star = 3$ also dominates, and the cross-ticker generalisation has $11/30$ tickers below $60\%$ OoS KS. The "regime-conditional Christoffersen-cc passes" headline is on a single OoS window with two stress folds explicitly excluded; the walk-forward result is $19/24$, not "passes at every $(K, \alpha)$." I do not see a substantive contribution here that is not already in Bulla and Berzel (2008), Nystrup et al. (2017), or the standard MS-GARCH literature, except for the unified four-emission scaffold, which is engineering. The paper is over-claimed and the comparisons are not at parity.

### Strengths

1. The Julia code-and-data release is exemplary for the field and the seed-derivation rule is more careful than in 95% of applied econometrics papers I have refereed.

2. The acknowledgement that the bootstrap dominates the panel on raw OoS KS (sec:model_comparison, "Bootstrap as a non-parametric synthetic-data benchmark" paragraph) is intellectually honest. So is the acknowledgement that ML HSMM-N at $K^\star = 3$ dominates the entire CHMM block on OoS KS.

3. The cross-ticker failure attribution to single-name regime introductions (LLY weight-loss-drug, NVDA AI rally, UNH 2024 healthcare-policy compression) is grounded in the empirical OoS slice and not handwaved.

### Weaknesses

1. **The novelty claim is thin.** The introduction lists three contributions; (i) is "we apply the textbook bilinear identity to recast the SPY 2014-2024 instance of the Rydén et al. low-$K$ failure as an effective-rank statement" with the authors themselves noting the identity is folklore in Hamilton (1994) §22.2 and Krolzig (1997) Ch. 3. (ii) is the unified four-emission scaffold with a shared M-step decomposition. (iii) is an empirical study on SPY plus a 30-ticker cross-section plus a six-asset copula. None of these are substantive theoretical contributions. The empirical study itself does not show that the CHMM dominates any natural baseline on any reported metric: the bootstrap dominates on OoS KS, ML HSMM-N dominates on OoS KS at $K^\star = 3$, GARCH(1,1)-$t$ dominates on $|G_t|$ ACF-MAE ($0.0316$ vs CHMM-N $0.0502$ at $K^\star = 6$), and the cross-asset copula choice is OoS-indistinguishable from Gaussian. The body sentence "CHMM is the joint-fit row in the panel under stationary OoS conditions" is not supported by Table 2 as constructed: there is no row of Table 2 in which CHMM is column-best on more than one metric simultaneously. *Required fix:* the body must either identify a row of Table 2 in which CHMM is jointly column-best on KS, kurtosis, and ACF-MAE simultaneously (it is not, as currently constructed), or reframe the claim as "the four CHMM emission variants land at distinct kurtosis points on a common scaffold," which is what the data support.

2. **The "regime-conditional Christoffersen-cc passes cleanly" headline does not survive walk-forward.** sec:var_backtest claims "passes Kupiec, Christoffersen-ind, and Christoffersen-cc cleanly at $\alpha = 0.05$ on OoS." This is the single-window OoS result. The walk-forward equivalent (sec:supp_misc, Table tab:walkforward_cond_var) passes only $19/24$ at $\alpha = 0.05$ uncorrected, with W2 and W4 stress folds rejecting at $p < 10^{-3}$. The body abstract repeats "passes the Christoffersen joint conditional-coverage test at $\alpha = 0.05$ on the headline OoS window and on $19/24$ walk-forward folds." This is technically correct but the omission of the W2 and W4 failure modes from the abstract framing is misleading: under regime introductions of the W2 / W4 magnitude (a market crash and a Fed rate-hike onset), the conditional VaR rejects at $p < 10^{-3}$, which is exactly the regime in which the conditional VaR is supposed to provide value. A risk-management consumer reading the abstract would conclude that the conditional VaR is robust to regime change; the underlying data show the opposite. *Required fix:* the abstract must state explicitly that the conditional VaR rejects on the COVID and 2022-rate-hike walk-forward folds at $p < 10^{-3}$; the framing as "passes at $19/24$" without this qualification is misleading.

3. **The cross-ticker panel claim is contradicted by the panel itself.** sec:cross_asset_univariate reports OoS KS median of $75.1\%$ at $K^\star = 6$ with $11/30$ tickers below $60\%$, but the body sentence is "Cross-ticker generalisation gives an OoS KS median of $75.1\%$ at $K^\star = 6$ ($11/30$ failures), lifted to $83.0\%$ by quarterly refit." The quarterly-refit claim is the body headline, but the quarterly-refit OoS KS median is reported in Table 5 only at $K = 18$, not at $K^\star = 6$. The reader is asked to combine the static $K^\star = 6$ result with the quarterly-refit $K = 18$ result and infer a quarterly-refit $K^\star = 6$ number that is not reported. *Required fix:* report the quarterly-refit OoS KS median at $K^\star = 6$ in Table 5; the headline cross-ticker claim depends on this number.

4. **The $\nu^\star = 6$ Student-$t$ copula choice is over-fit to IS.** sec:cross_asset reports IS off-diagonal MAE $0.027$ for Student-$t$ vs $0.030$ for Gaussian, and OoS off-diagonal MAE $0.209$ for Student-$t$ vs $0.202$ for Gaussian. The Student-$t$ copula is strictly worse on OoS than the Gaussian copula at the body's own metric, and the IS gain is $0.003$ — noise on 200 paths. The sentence "the dependence-family choice is therefore an IS-calibration distinction, not an OoS-deployment one" understates: the dependence-family choice is empirically incorrect on OoS. The body should select the Gaussian copula by Occam's razor and the OoS metric, with the Student-$t$ copula as an IS-calibration sensitivity. *Required fix:* re-headline the cross-asset section with the Gaussian copula. The current Student-$t$ headline is the IS over-fit choice on a metric that the same paper reports as 0.007-different from Gaussian on OoS, well below the 200-path simulation-noise floor.

5. **The "spectral mechanism" is overcredited.** sec:theory claims (correctly) that the bilinear identity for the absolute-return ACF is folklore from Hamilton (1994) §22.2. The empirical effective-rank application is novel (a single non-unit eigenvalue carries $93.6\%$ of the lag-1 ACF on SPY), but Timmermann (2000), Krolzig (1997), and Bulla and Berzel (2008) all apply the same identity to similar regime-switching specifications and report similar dominant-mode patterns. The contribution is therefore "empirical confirmation of a folklore mechanism on the SPY 2014-2024 window," which is a valid empirical contribution but not the headline framing of the paper. *Required fix:* the introduction's contribution (i) should be reframed as "we confirm empirically on the SPY 2014-2024 window that the dominant-mode share predicted by Hamilton (1994) §22.2 is non-binding at $K \geq 3$." The current framing reads as if the spectral identity itself is the contribution.

6. **The independent-decade validation is reported as "infeasible" but the alternatives are not exhausted.** sec:discussion, "Limitations" paragraph: the authors state that Polygon.io / Alpaca / IEX feeds do not cover the 1994-2004 window and that "Bloomberg, Refinitiv, or a CRSP licence" would be needed. CRSP is the standard reference data source for this kind of US-equity historical study and is accessible to most US academic institutions through WRDS. *Required fix:* either obtain CRSP data through a WRDS subscription and run the 1994-2004 vs 2014-2024 split, or restrict the empirical scope claim explicitly to "SPY 2014-2026" without the implication that the result generalises across decades. The current framing implies the latter while doing only the former.

7. **The "use case differentiation" framing in sec:model_comparison is a way of avoiding the head-to-head comparison.** The body argues that bootstrap is the right choice for raw KS, ML HSMM is the right choice for KS-only consumers, and CHMM is the right choice for use cases that the bootstrap and HSMM cannot serve (regime-conditional VaR, parametric copula composition, privacy/licensing). The first two of these three differentiating use cases are valid; the third (privacy/licensing) is true of every parametric model, not specifically the CHMM. The first (regime-conditional VaR) is the only differentiator that is intrinsic to the latent-state forecast, and the walk-forward Christoffersen-cc result rejects on the very stress folds where the regime-conditional structure is supposed to help. The "use case differentiation" framing is therefore one valid use case (parametric multi-asset coupling, where the CHMM is genuinely required) plus one over-claimed use case (regime-conditional VaR, which fails under regime change) plus one tautological use case (parametric privacy, which is true of any parametric model). *Required fix:* drop the regime-conditional VaR from the differentiating-use-case list given the walk-forward W2/W4 result, or explicitly state that the conditional VaR is differentiating only under stationary OoS conditions.

### Questions for Authors

1. What does the headline change if Table 2 is rebuilt with the Ardia et al. (2019) `MSGARCH` R package and a faithful Wiese et al. (2020) QuantGAN with Lambert-W pre-processing? The current panel reports both as failing baselines, but both are self-implementations whose failure modes are not the literature consensus. If the headline conclusion changes when the comparison is at parity, the body framing must shift.

2. The discrete-state predecessor Alswaidan (2026) "hybrid" is cited as the predecessor of the present continuous-state model. What numerical claims does the present paper make that the predecessor did not? If the predecessor already reproduces the three Cont stylized facts on SPY (which the citation suggests), the contribution of the present paper relative to the predecessor needs to be stated explicitly in the introduction.

3. The Christoffersen independence test depends on a specific Markov-chain alternative for the breach indicator. What if the breach process is a longer-memory process (e.g., a renewal process with non-geometric inter-breach distribution)? Did the authors check the Engle-Manganelli (2004) DQ test as a higher-power alternative under longer-memory clustering?

4. The CHMM-t bracket-lift at $\nu_{\min} = 4$ row in Table 2 reports IS/OoS KS within 0.6 pp of the penalised CHMM-t at $\lambda = 20$. Why is the body headline the penalised version rather than the bracket-lifted version, given the latter has no tuning knob and a structurally cleaner relationship to the kurtosis-finiteness threshold?

5. The CHMM at $K = 18$ has $K_{\text{eff}} = 11/18$ effective states. If the model is operationally a 11-state model, why is the regime-conditional VaR forward filter run on the full 18-state predictive density rather than on the 11-state collapsed model? Does the conditional VaR pass-rate change under the 11-state collapse?

### Requested Experiments / Analyses

1. **At-parity baseline panel.** Replace MS-GARCH and QuantGAN rows in Table 2 with reference-implementation outputs (`MSGARCH` R package; faithful Wiese et al. 2020 TCN with Lambert-W). If the reference implementations close the gap to CHMM, the body conclusion must shift. This is the single most important control I am requesting.

2. **Engle-Manganelli (2004) DQ test as a higher-power conditional-coverage alternative.** Apply on the same OoS window and walk-forward folds. If the DQ test rejects on the headline window where Christoffersen-cc passes, the headline "regime-conditional VaR" claim is power-bounded and the body framing must be qualified.

3. **CRSP-based 1994-2004 vs 2014-2024 cross-decade validation.** Through WRDS if the institutional access is available. If the CHMM at $K^\star = 6$ trained on 1994-2004 fails to bracket OoS KS on 2014-2024 (or vice versa), the body's "stylized-fact reproduction" claim is decade-specific and must be stated as such.

4. **Direct Diebold-Mariano comparison of CHMM vs the stationary block bootstrap on a multi-day forecast horizon (5-day, 20-day cumulative returns).** The bootstrap at $L = 20$ already dominates the CHMM on raw 1-day OoS KS; the natural question is whether CHMM dominates at multi-day cumulative returns where the regime structure should provide value. If CHMM does not dominate the bootstrap at any forecast horizon on the headline OoS window, the body's "use-case differentiation" framing is vacuous.

### Minor Comments

1. Abstract: "The textbook bilinear ACF identity recasts the SPY instance of the Rydén et al. (1998) low-$K$ failure as an effective-rank statement on the deflated transition matrix." The verb "recasts" overclaims; the textbook identity has been recasting this since Hamilton (1994). Suggest "The textbook bilinear ACF identity, applied to the SPY instance, expresses the Rydén low-$K$ failure as an effective-rank statement..."
2. sec:related_work, "Schaller and van Norden (1997) showed monthly equity returns admit a two-state Markov-switching specification." This is not the canonical Schaller-van-Norden result; that paper is about predicting US stock returns from regime-switching, not about a two-state specification of the returns themselves. Verify and rewrite.
3. Table 2 footnote $\dagger\dagger$ refers to "Reviewer-1/2 request"; this is a holdover from a previous review cycle and should be removed in the resubmission.
4. The abstract's "$K^\star = 6$ (pre-2020 slice)" is parenthesised in a way that obscures that the held-out-clean criterion fixes $K^\star = 6$ on a specific 4.5-year subwindow. Consider "$K^\star = 6$ chosen on the strictly pre-2020 held-out slice."
5. sec:cross_asset, "Wilks 95\% profile-LL CI of $[6, 7]$" — Wilks's theorem requires the parameter to be in the interior of the parameter space and the model to be regular; for $\nu \to \infty$ as the Gaussian limit, regularity may fail. Cite or justify the Wilks application.

### Recommendation

**Major Revision bordering on Reject and Resubmit.** The methodology is competent but the body framing and abstract substantially overstate the empirical contribution relative to the controls already in the paper. The bootstrap and ML HSMM dominance, the Student-$t$ copula OoS underperformance, the walk-forward W2/W4 failures, and the cross-ticker $11/30$ failure rate together establish that the CHMM is one option in a panel of comparable methods, not the headline result. The contribution is the unified four-emission scaffold (engineering) plus the regime-conditional VaR application (which is itself walk-forward fragile). With the priority controls in Requested Experiments 1, 2, and the headline reframing in Weaknesses 1, 2, 3, and 4, this is a publishable applied paper. As written, the abstract overpromises.

---

## Summary of Actionable Items (consolidated, deduplicated, prioritised)

### Priority 1 (must-fix for resubmission)

1. **Reference-implementation MS-GARCH baseline.** Run `MSGARCH` R package (Ardia et al. 2019) at $K \in \{2, 3, 4\}$ on the SPY IS / OoS window; replace the self-implementation rows in Table 2. *(R2 W1, R3 RE1.)*

2. **$k$-fold cross-validation of $K^\star$ on the strictly pre-2020 slice.** Mean $\pm$ s.d. of held-out per-observation log-likelihood and held-out KS over 5 or 10 rolling-origin folds. *(R1 RE1; supports R1 W1.)*

3. **Block-aware OoS KS at the headline $K^\star = 6$.** Add to Table 3 (currently only at $K = 18$). Report the block-aware value alongside the asymptotic value in the abstract. *(R1 W5, R2 W2, R2 RE4.)*

4. **Quarterly-refit conditional VaR back-test.** Add a row to Table 4 with parameters refit at the start of every OoS quarter. *(R2 W3, R2 RE2.)*

5. **Quarterly-refit cross-ticker OoS KS at $K^\star = 6$.** Add to Table 5 (currently only at $K = 18$). The headline "lifted to $83.0\%$" claim depends on this. *(R3 W3.)*

6. **Headline reframing of the conditional-VaR result.** State explicitly that the test rejects at $p < 10^{-3}$ on the COVID and 2022-rate-hike walk-forward folds, and that the BH panel-level pass rate is $21/24$, not the per-row "passes at every $(K, \alpha)$." *(R2 W6, R3 W2.)*

7. **Headline reframing of the cross-asset Student-$t$ copula.** Either reframe with the Gaussian copula as the body headline (since it is OoS-best on the body's own metric), or explicitly state that the Student-$t$ vs Gaussian distinction is OoS-indistinguishable at 200 paths. *(R1 Q2, R2 W5, R3 W4.)*

### Priority 2 (strongly suggested)

8. **$\nu_{\min} = 4$ bracket-lift CHMM-t as the body headline,** with $\lambda = 20$ penalised version moved to sensitivity. The bracket lift has no tuning knob and respects the kurtosis-finiteness threshold. *(R1 W2, R1 RE2, R3 Q4.)*

9. **Faithful Wiese et al. (2020) QuantGAN with Lambert-W pre-processing** as the deep-generative baseline, replacing the current 3-conv-layer rebuild in Table 2 footer. *(R3 RE1.)*

10. **Engle-Manganelli (2004) DQ test as a higher-power conditional-coverage check** on the OoS window and walk-forward folds. *(R3 RE2.)*

11. **Per-state Frobenius distance between the four emission families on the cross-ticker panel.** Test whether the four-family narrative collapses to a one-parameter shape axis. *(R2 W4, R2 RE3.)*

12. **CRSP-based 1994-2004 vs 2014-2024 cross-decade validation through WRDS,** if institutional access available. Otherwise restrict the empirical-scope claim explicitly to SPY 2014-2026. *(R3 W6, R3 RE3.)*

13. **Compress sec:theory** by referencing Hamilton (1994) §22.2 / Krolzig (1997) Ch. 3 / Timmermann (2000) for the textbook derivation; keep only the rank statement, the dominant-mode-share diagnostic, and the cross-ticker distribution. *(R2 W7, R3 W5.)*

### Priority 3 (recommended)

14. **Gamma-sojourn HSMM as a co-headline foil** in addition to or instead of the truncated-Pareto HSMM, to test whether the HSMM $|G_t|$ ACF-MAE matches the i.i.d. baseline because of the sojourn-family choice. *(R1 RE3, R1 Q1, R2 Q4.)*

15. **CHMM-N marginals at the body-headline $K^\star = 6$ for the cross-asset construction** (currently uses $K = 18$). Test whether the off-diagonal MAE recovers under $K^\star = 6$ marginals. *(R2 Q3.)*

16. **Multi-day cumulative-return Diebold-Mariano comparison** (5-day, 20-day) of CHMM vs the stationary block bootstrap. Test whether CHMM differentiates on any forecast horizon. *(R3 RE4.)*

17. **Distinguish $\alpha = 0.05$ and $\alpha = 0.01$ rows in Table 4** by power calibration; either restrict the body table to $\alpha = 0.05$ or footnote-mark the $\alpha = 0.01$ rows. *(R1 W3.)*

18. **Rephrase the leverage-effect "partial capture" claim** to "the simulated distribution does not reject the observed leverage at the 5\% level on either window," which is what the data actually support. *(R1 W4.)*

### Priority 4 (minor, presentation)

19. Fix Schaller-van-Norden (1997) citation (R3 Minor 2).
20. Remove "Reviewer-1/2 request" footnote in Table 2 (R3 Minor 3).
21. Add Wilks-theorem regularity citation for the $\nu \to \infty$ Gaussian-copula limit (R3 Minor 5).
22. Standardise notation: $f_k$ for density, $F_k$ for CDF, throughout (R2 Minor 3).
23. Promote the $\dagger\dagger$ bracket-lift footnote from Table 2 caption to a numbered remark (R1 Minor 3).
24. Compress repeated "held-out-clean" usage; define once and reuse (R1 Minor 5).
25. Spell out which Cont (2001) facts are addressed in the abstract scope statement (R1 Minor 4).

### Aggregate Recommendation

All three reviewers recommend **Major Revision**. R1 and R2 see a publishable empirical paper after items 1-7 are addressed; R3 sees the headline framing as substantially over-claimed and would also accept "reject and resubmit" if the priority controls are not run. The contribution is real (unified four-emission scaffold, regime-conditional VaR under stationary conditions, careful reproducibility), but the body framing currently overstates it relative to the controls the authors themselves have already run.
