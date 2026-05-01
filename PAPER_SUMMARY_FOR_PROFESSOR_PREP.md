# Paper Summary: CHMM for Daily US-Equity Symmetric Stylized-Fact Reproduction

A from-scratch walkthrough for prepping the meeting with the professor. Assumes no prior background in finance, hidden Markov models, or time-series statistics.

Current title (post round-2 / round-3 review): *"A Continuous Hidden Markov Model for Daily US-Equity Symmetric Stylized-Fact Reproduction."* The "symmetric" qualifier is load-bearing: per-state emissions in this paper are symmetric (Gaussian, Laplace, Student-t, GED), so the body evaluates only the three symmetric Cont (2001) stylized facts. Leverage and gain-loss asymmetry are explicitly out of scope and require skew-emission extensions deferred as companion work.

Authors: Abdulrahman Alswaidan, Cade Jin, Jeffrey D. Varner.

---

## 1. The big picture in two sentences

We evaluate a continuous hidden Markov model (CHMM) trained by Baum-Welch as a synthetic-data generator for daily US-equity returns, where a single relatively simple model reproduces the three symmetric Cont stylized facts simultaneously across SPY, a 30-ticker sector-balanced panel, a 60-ticker sector expansion, a six-asset US-equity copula, and a CRSP cross-decade slice (1994-2006). The contribution is no longer "panel-leading raw KS"; the panel headlines on raw 1-day OoS KS are the i.i.d. block bootstrap (92.1%) and ML HSMM-N at K* = 3 (91.0%). The CHMM positioning is on three structural use cases the bootstrap cannot serve: regime-conditional Value-at-Risk built from the one-step-ahead state filter, multi-asset copula composition on parametric per-asset marginals, and parametric privacy / licensing where the bootstrap would ship literal IS observations.

---

## 2. Why anyone cares about synthetic equity returns

Banks, hedge funds, regulators, and risk teams need huge amounts of realistic-looking market data for several reasons:

1. **Stress testing.** What happens to a portfolio if the market behaves badly for two years? You need many plausible alternate histories to estimate that, but you only have one actual history.
2. **Regulatory backtesting.** Regulators (Basel III) require banks to demonstrate that their risk models are calibrated. Backtesting needs synthetic paths.
3. **Scenario design.** Designing trading strategies, allocations, hedges. You want to test on many possible futures.
4. **Training ML models on data you cannot release.** Privacy / licensing. You can release synthetic data with the same statistics as confidential data without leaking the actual data.

A "synthetic-data generator" is a market simulator. The bar for it being useful is that simulated returns should be statistically almost identical to real returns on the standard diagnostic tests, and that downstream risk-management constructions built on top of it should pass the regulator-style backtests.

---

## 3. The three symmetric Cont (2001) stylized facts the paper targets

These are universally observed empirical features of daily stock returns. Any good generator must reproduce them simultaneously.

### 3.1 Heavy-tailed marginals
The histogram of daily returns has fatter tails than a bell curve. Extreme moves happen more often than a Gaussian would predict. Numerically: SPY in-sample excess kurtosis 7.68, out-of-sample 5.29 (Jarque-Bera 6,416.6, p < 0.001 IS).

### 3.2 Negligible linear autocorrelation
If today's return was big, that does not predict the direction of tomorrow's return. Ljung-Box statistic on raw G_t at lag 20 is ~5.5 against a chi-squared(20) critical value of 31.4: linear ACF is essentially zero at all lags.

### 3.3 Slow decay of the absolute-return ACF (volatility clustering)
If today's absolute return was big, tomorrow is more likely to also be a big move. Volatile days cluster. Ljung-Box on |G_t| at lag 20 is 2,959.3, p < 0.001.

The two Cont facts the body does not target (leverage effect, gain-loss asymmetry) require asymmetric per-state emissions. The discussion paragraph in §5 of the paper documents that all four CHMM emission families produce a borderline-non-rejection of the IS observed leverage value through Markov state mixing alone but reject the OoS leverage value at the 5% level. Closing the OoS gap is deferred as companion-paper work.

---

## 4. The prior-work landscape

| Family | Strength | Weakness |
|---|---|---|
| **i.i.d. bootstrap** (Politis-Romano stationary) | Marginal exact; passes raw KS | Destroys volatility clustering; ships literal IS rows so cannot be released under privacy constraints |
| **GARCH(1,1) / GARCH(1,1)-t** (Bollerslev 1986/1987) | Volatility clustering captured | Marginal unimodal; fails KS |
| **MS-GARCH** (Haas et al. 2004; Ardia 2019 R package) | Multi-state regime-switching | Plateaus at 0-37% IS KS depending on estimator |
| **HMM (Rydén et al. 1998)** at K = 2 / 3 with Gaussian emissions | Standard regime-switching scaffold | Negative result: low-K HMMs were claimed to fail the slow-ACF axis. Killed regime-switching HMMs as a research direction for nearly two decades |
| **Hidden Semi-Markov (Bulla and Bulla 2006)** | Restores ACF fidelity by replacing geometric sojourn with explicit duration | More complex machinery; in our reproduction the explicit-duration scaffold has a K ≤ 6 practical limit on T_IS = 2,516 |
| **Deep generative (QuantGAN; TimeGAN)** | Visually realistic; expressive | Hard to interpret, hard to reproduce, our in-house WGAN re-implementations fail KS at 0% IS / 0% OoS in both 3-conv and 7-block TCN variants, with and without Lambert-W input pre-processing. We do not claim a faithful reference re-run would also fail; that is a deferred follow-up |

---

## 5. What we built

### 5.1 The model: a continuous HMM

Each day, the market is in one of K hidden states; the state evolves Markov-style via a K x K transition matrix T; conditional on state k, today's return G_t is drawn from a state-specific emission density f_k. "Continuous" means observations are real numbers, not binned.

Four emission families share the same forward-backward scaffold and quantile-based initialisation; only the M-step differs:

- **CHMM-N (Gaussian)**: f_k(x) = N(x; μ_k, σ_k²).
- **CHMM-t (Student-t)**: f_k(x) = t_{ν_k}(x; μ_k, σ_k). Per-state ν_k by 1-D golden-section search on the conditional Q-function (ECM step), bracket [2.1, 50]. We also report a **penalised CHMM-t at λ = 20** with an exponential 1/ν_k shrinkage prior.
- **CHMM-L (Laplace)**: f_k(x) = Laplace(x; μ_k, b_k).
- **CHMM-GED (Generalized Error Distribution)**: f_k(x) = GED(x; μ_k, α_k, p_k). Three-stage ECM. The GED nests Gaussian at p = 2 and Laplace at p = 1.
- **CHMM-t shared-ν** (round-2 ablation): a single ν shared across all K states by aggregate-Q ECM. The structurally cleanest heavy-tail recipe; no penalty hyperparameter at all. At K = 18 it produces simulated kurtosis 6.25 IS / 5.00 OoS against observed 7.68 / 5.29, the cleanest single-row IS / OoS heavy-tail match in the entire panel.

### 5.2 How we train: Baum-Welch (EM)

- **E-step**: given current parameters, compute the posterior probability of each state at each time via forward-backward.
- **M-step**: given the posteriors, update transitions and emission parameters by weighted maximum likelihood.

Iterate until log-likelihood converges (tolerance 1e-4, typically 20-40 iterations).

Two specific design choices:

1. **Quantile-based initialisation.** Sort observed returns into K equal-size chunks; initialise each state from its corresponding chunk. This avoids the degenerate-local-optima problem that contributed to Rydén's pessimistic result. The K = 2 replication on SPY shows ACF-MAE is essentially constant at ~0.050 across quantile init and five random-seed initialisations.
2. **For CHMM-t and CHMM-GED**, ν_k and p_k use bracketed golden-section ECM steps. Each is a partial maximisation on a compact bracket, so EM monotonicity is preserved.

### 5.3 The theoretical core: the spectral identity for the |G| ACF

For any stationary CHMM, the autocorrelation of |G_t| at lag τ is

ρ(τ) = Σ_{k≥2} c_k · λ_k^τ / σ²,

where λ_2, ..., λ_K are the non-unit eigenvalues of T and the c_k weights are determined by per-state moments and the stationary distribution. The ACF is a mixture of geometric decays at the eigenvalues of T.

This identity is **folklore** in the regime-switching literature (Hamilton 1994, Krolzig 1997, Timmermann 2000). We are explicit that we are not claiming to re-derive it. The empirical contribution is the **effective-rank diagnostic** on the fitted T̂:

- The algebraic upper bound on distinct decay modes is K - 1.
- A single non-unit eigenvalue carries 96.8% of lag-1 absolute-return ACF at K = 3, and 93.6% at K = 18 on SPY.
- **Cross-ticker median dominant-mode share is 0.756, minimum 0.326 on NEM** (post round-2 30-ticker re-run). The SPY 94% is a right-tail value, not a representative central one. The abstract and §5.3 read at the cross-ticker median.

This reframes the Rydén low-K failure precisely: at K = 2 the rank constraint binds (one mode, two-component marginal). At K ≥ 3 the temporal axis decouples and the marginal-mixture component count drives the joint fit.

---

## 6. The data

- **Single-asset main study (SPY, the SPDR S&P 500 ETF)**: IS Jan 3 2014 to Jan 3 2024 (T_IS = 2,516); OoS Jan 4 2024 to Apr 20 2026 (T_OoS = 572).
- **30-ticker sector-balanced panel**: 10 GICS sectors x 3 large-caps each. Fitted independently per ticker.
- **60-ticker sector expansion**: 30 additional tickers (3 more large-caps per sector) added in round 2 to give the ANOVA adequate power.
- **Six-asset US-equity copula universe**: SPY, NVDA, JNJ, JPM, AAPL, QQQ.
- **CRSP cross-decade validation (added in round 2 via WRDS day-pass)**: 1994-2004 IS (T = 2,519) / 2004-2006 OoS (T = 583).
- **GLD / SLV non-equity stress test (added in round 2)**: confirms cross-asset scope is daily US-equity-only.

We work with annualised excess log returns G_t = (1/Δt) ln(P_t / P_{t-1}) - r_f at Δt = 1/252 and r_f = 0.

---

## 7. Empirical tests, what they measure, and how we fare

### 7.1 The four core distributional metrics

1. **Kolmogorov-Smirnov (KS) pass rate at α = 0.05.** Two-sample test for whether the simulated distribution of returns matches the observed distribution. We simulate 1,000 independent paths per fitted model and report the fraction that pass. Failing means the marginal distribution is wrong.
2. **Mean simulated excess kurtosis.** Direct measure of tail heaviness. Compare to observed (7.68 IS, 5.29 OoS). Bootstrap 95% CIs on observed kurtosis at L = 20 are [2.17, 12.40] IS and [0.90, 8.26] OoS; targets read against the joint envelope, not the point estimates.
3. **|G_t| ACF-MAE.** Mean absolute error between observed and simulated absolute-return ACF over 252 lags. The volatility-clustering diagnostic.
4. **CRPS (Continuous Ranked Probability Score).** A proper scoring rule for probabilistic forecasts. Lower is better. We use it because KS alone is not a proper scoring rule.

### 7.2 The benchmark generators

- **i.i.d. bootstrap (Politis-Romano stationary, L = 20)**: non-parametric distributional ceiling. **Wins on raw OoS KS at this single window (92.1%).**
- **Gaussian i.i.d.**: negative control.
- **Laplace i.i.d.**: heavier-tailed i.i.d. comparator.
- **GARCH(1,1)** and **GARCH(1,1)-t** (Bollerslev 1986/1987).
- **MS-GARCH** (Haas et al. 2004) at K ∈ {2, 3, 4, 6}: closest classical peer to CHMM.
- **MS-GARCH reference Bayesian re-run** via the MSGARCH R package of Ardia et al. (2019), driven from Julia via RCall, Bayesian DEMC sampler at 12,500 draws / 2,500 burn-in / thin 10. Posterior-predictive simulation integrates parameter uncertainty path-by-path.
- **ML HSMM-N (Pareto sojourn) at K* = 3**: Yu (2010) explicit-duration forward-backward. **Wins on raw OoS KS at K* = 3 with 91.0%, beating every CHMM operating point.**
- **ML HSMM-N (Gamma sojourn) at K = 18** (added in round 2): per-state Gamma sojourn updated by method of moments at each M-step. **Wins on |G_t| ACF-MAE at 0.0462, the panel-best |G_t| ACF match.**
- **QuantGAN TCN**: Wiese-style 7-block dilated WGAN-GP, with and without Lambert-W input pre-processing. Both fail KS at 0% IS / 0% OoS. Documented as in-house WGAN re-implementation result; faithful reference re-run is deferred.

### 7.3 The headline result (Table 3 in the paper)

The paper reports the K* = 3 block as the body headline (state-resolution-robust under k-fold rolling-origin CV on the strictly pre-2020 slice), with K* = 6 as a single-fold sensitivity reference and K = 18 as an extended-state-resolution sensitivity reference (selected by a multi-objective rule that uses the OoS window).

| Generator | IS KS | OoS KS | IS Kurt | OoS Kurt | \|G\| ACF-MAE | CRPS OoS |
|---|---|---|---|---|---|---|
| Observed | -- | -- | 7.68 | 5.29 | -- | -- |
| Bootstrap | 99.7% | **92.1%** | 7.24 | 6.81 | 0.0628 | 1.0398 |
| Gaussian iid | 0.0% | 1.0% | -0.01 | -0.03 | 0.0627 | 1.0611 |
| Laplace iid | 99.1% | 88.5% | 2.95 | 2.91 | 0.0628 | 1.0386 |
| GARCH(1,1) | 23.4% | 60.8% | 7.06 | 2.96 | 0.0485 | 1.0440 |
| GARCH(1,1)-t | 57.3% | 80.8% | 15.13 | -- | **0.0316** | -- |
| MS-GARCH (in-house) | 27-37% | 33-39% | 4-5 | -- | 0.028-0.043 | -- |
| MS-GARCH ref Bayesian (R-pkg) | 0-0.1% | 5-6% | 4-6 | 2.5-3.5 | 0.043-0.046 | -- |
| **CHMM-N (K* = 3)** | **89.7%** | **80.5%** | 3.83 | 3.53 | 0.0460 | 1.0393 |
| **CHMM-t pen. (λ=20, K* = 3)** | 90.6% | **83.2%** | 14.91 | 8.50 | 0.0537 | **1.0373** |
| **CHMM-GED (K* = 3)** | 90.5% | 77.4% | 5.48 | 5.12 | 0.0526 | 1.0389 |
| **CHMM-L (K* = 3)** | 79.8% | 63.1% | 5.30 | 4.85 | 0.0532 | 1.0405 |
| **CHMM-t shared-ν (K* = 3)** | 91.9% | 82.1% | 4.68 | 4.46 | 0.0531 | -- |
| ML HSMM-N (Pareto, K* = 3) | 98.4% | **91.0%** | 3.46 | 3.38 | 0.0629 | -- |
| CHMM-N (K* = 6) | 92.6% | 78.3% | 5.26 | **4.46** | 0.0502 | 1.0422 |
| CHMM-N (K = 18) | 94.1% | 81.8% | 5.04 | 4.44 | 0.0509 | **1.0384** |
| CHMM-t pen. (λ=20, K = 18) | 95.0% | **85.8%** | 8.56 | 7.07 | 0.0542 | 1.0392 |
| **CHMM-t shared-ν (K = 18)** | **95.8%** | **88.0%** | **6.25** | **5.00** | 0.0542 | -- |
| ML HSMM-N (Gamma, K = 18) | 86.0% | 80.2% | -- | -- | **0.0462** | -- |

**Five takeaways.**

1. **CHMM at K* = 3 reproduces all three symmetric stylized facts simultaneously.** CHMM-N is at 89.7% IS / 80.5% OoS KS, simulated kurtosis 3.83 IS / 3.53 OoS, |G_t| ACF-MAE 0.0460 (on par with GARCH's 0.0485). The penalised CHMM-t at λ = 20 provides the cleanest IS / OoS heavy-tail match in the K* = 3 block.
2. **Shared-ν Student-t at K = 18 is the cleanest single-row IS / OoS heavy-tail match in the entire panel** (6.25 IS / 5.00 OoS against observed 7.68 / 5.29) without any penalty hyperparameter. Round-2 ablation; structurally cleaner than the per-state ν_k + λ-shrinkage construction the body retains for direct comparability with Peel-Liu (2000) and Liu-Rubin (1995).
3. **The bootstrap and ML HSMM beat CHMM on raw 1-day OoS KS.** We say so plainly. The CHMM-vs-bootstrap differentiation is on the structural use cases of §3.6 (regime-conditional VaR), §3.5 (cross-asset copula composition), and §1 (parametric privacy / licensing), not on the per-day distributional axis.
4. **Gamma-sojourn HSMM-N at K = 18 is the panel-best |G_t| ACF match** (0.0462). The Pareto-sojourn HSMM at K* = 3 wins KS but loses the volatility-clustering diagnostic (ACF-MAE 0.0629, indistinguishable from the i.i.d. baseline). No single HSMM operating point dominates both axes.
5. **Multi-day differentiation does not survive operating-point replication.** At K = 18 on SPY at h = 20-day cumulative-return blocks, CHMM-N beats the bootstrap with ΔCRPS = -0.180, p = 0.003. At the body-headline K* = 3, ΔCRPS = -0.077, p = 0.244, and across the six-asset universe at K* = 3 the median ΔCRPS is essentially zero. The K = 18 multi-day result is K = 18-specific. The body framing therefore lands on structural use cases, not multi-day forecasting.

### 7.4 Block-aware OoS KS recalibration (the round-2 framing fix)

The asymptotic two-sample KS critical value 1.36 sqrt(2/T_OoS) = 0.0804 used for the Table 3 OoS KS column assumes i.i.d. samples. Under autocorrelated daily returns the appropriate null is the stationary block-bootstrap KS distribution at mean block length L = 20 (critical value 0.0647 instead of 0.0804). **Recalibration drops every OoS row by roughly 25 percentage points**:

| Model | OoS KS asymp | OoS KS block L=20 |
|---|---|---|
| Bootstrap | 90.4% | 73.2% |
| GARCH(1,1) | 59.2% | 31.4% |
| CHMM-N (K* = 3) | 79.8% | 58.6% |
| CHMM-t pen. (K = 18) | 84.8% | 61.6% |

Cross-generator ordering is preserved. The absolute-level numbers in the asymp column overstate where a temporally-aware null places the generators. **Read together with Table 3, CHMM-N moves from a "passes most of the time" generator to a "passes about half the time" generator at L = 20.** This is the defensible reading; the asymp pass-rate is reported only because it is the standard convention in the literature and we want column-comparability with prior work.

### 7.5 Robustness checks

- **K-selection.** Pre-registered across {AIC, BIC, HQC, CAIC, held-out LL, held-out KS} on two slices (2022-2023 and pre-2020). No held-out criterion picks K = 18. K = 6 vs K = 3 is indistinguishable under k-fold CV (|z| ≤ 0.07 with the sign flipping between fold designs); under HAC the same statistic moves to |z_HAC| = 0.90 / 0.57. The headline is therefore K* = 3, the state-resolution-robust default. K = 18 vs K = 6 is decisively worse on held-out LL under HAC (|z_HAC| = 3.56 / 5.00); K = 18 is retained as a kurtosis-fidelity sensitivity reference, not a held-out-clean default.
- **K_eff diagnostic.** At K = 18, CHMM-N collapses to 11/18 effective states under a single-linkage standardised-distance criterion; CHMM-t to 12/18, with 13/18 of CHMM-t's states pinned at the upper ν bracket on SPY. **A direct K_nominal = 11 rebuild matches the K = 18 row on every axis** (IS KS 94.4%, OoS KS 82.8%, |G| ACF-MAE 0.0505). The K = 18 over-parameterisation is a parameter-counting artefact, not information-bearing extra resolution. The K_eff-corrected IC re-rank moves AIC / HQC selections at K ≥ 12 but does not affect the K* = 3 body headline.
- **Multi-seed Monte Carlo.** Seed-to-seed standard deviations on OoS KS are small relative to between-model gaps. CHMM-GED's p̂_k partition is seed-invariant.
- **K = 2 replication on SPY.** ACF-MAE essentially constant at ~0.050 across quantile init and five random-seed initialisations, matching the K = 18 CHMM-N. The binding low-K constraint is distributional (KS at K = 2 drops to 67-72%), not temporal: with modern initialisation the ACF is reproduced at any K ≥ 2.
- **KS power-calibration positive control.** An i.i.d. resample of the IS series passes OoS KS at ~90%, not 100%, because T_OoS = 572 is finite. CHMM's 76-86% asymp pass rates are therefore near the test-power ceiling on the asymptotic critical value (and roughly half on the block-bootstrap critical value).
- **Six-fold rolling-origin walk-forward.** Median OoS KS 67.7% at K = 18 and 62.1% at K* = 3. The single-window OoS sits at the upper end. Two stress folds (W2 COVID, W4 2022 rate-hike onset) below 10% by KS for every generator under any refit cadence: regime introductions the IS distribution does not span.
- **Cross-decade CRSP 1994-2006.** The IS axis transfers within ~5pp KS (84-90% at K ∈ {3, 18}); the calm 2004-2006 OoS slice has observed kurtosis 0.06 (essentially Gaussian), so OoS KS collapses to 3-5%. Same low-stress / low-kurtosis pattern as the W2 / W4 walk-forward stress folds, not a generator failure.
- **GLD / SLV non-equity stress test.** Static IS-fitted CHMM hits 0% OoS KS on both ETFs. Confirms cross-asset claim is daily-US-equity-only without periodic refit.
- **n = 60 sector ANOVA.** Underpowered n = 3-per-sector test gave F(9, 20) = 0.44, p = 0.90, η² = 0.16. The n = 6-per-sector adequately-powered test gives F(9, 50) = 0.37, p = 0.946, η² = 0.062. The effect-size estimate halves; the no-sector-effect null is not rejected and the failures-are-ticker-specific reading is now supported by an adequately-powered test.

---

## 8. Downstream / application tests

### 8.1 Value-at-Risk (VaR) and Expected Shortfall (ES) backtesting

VaR at level α is the loss you should not exceed more than α fraction of the time. ES is the average loss conditional on being in the worst α fraction of days. Regulators require banks to backtest VaR. We organise diagnostics in three layers:

**(i) Envelope bracketing.** All four CHMM variants bracket observed historical VaR and ES at 1% and 5% within the [5, 95]% envelope on both windows; CHMM envelopes are roughly 1.7x tighter than GARCH's.

**(ii) Unconditional Kupiec coverage.** The four CHMM rows pass on both windows. We treat this as a sanity check at T_OoS = 572 (the integer breach count makes the statistic pile against the critical value). Exact-binomial Kupiec p-values agree with asymptotic within 0.07 at every row.

**(iii) Regime-conditional Christoffersen-cc — the substantive headline.**

At each OoS day t we run the forward filter through F_{t-1} (= IS observations ∪ OoS_{1:t-1}) to get the one-step-ahead state forecast P(s_t = k | F_{t-1}), then define VaR-hat_t(α) = F_t^{-1}(α) where F_t is the family-appropriate predictive mixture CDF under IS-fixed (T̂, θ̂_k). **Every (K, α, family) row passes Kupiec, Christoffersen-ind, and Christoffersen-cc cleanly at α = 0.05** on the headline OoS window. The independence statistic improves from 5.26 (unconditional) to 0.52 (conditional) at K = 18, α = 0.05: this is the regime-switching value proposition that the unconditional Kupiec headline did not exercise.

**Power caveat at α = 0.01 (round-2 framing fix).** A Monte Carlo power calibration at T_OoS = 572 shows Christoffersen-cc reaches ≥ 80% power at α = 0.05 against breach-clustering eigenvalues ρ ≥ 0.20, but at α = 0.01 only at ρ ≥ 0.50. The α = 0.05 rows therefore carry strong power; the α = 0.01 rows are power-bounded. The **Engle-Manganelli (2004) Dynamic Quantile (DQ) test** is the higher-power conditional-coverage alternative and is the test we trust at α = 0.01. **At α = 0.01 the DQ test rejects K = 18 conditional coverage on the stationary OoS slice (p = 0.017)**, while Christoffersen-cc does not reject (p = 0.137). **The strict-tail conditional-VaR property is therefore not supported at T_OoS = 572.** Tighter α requires either larger T_OoS or a model class with explicit regime-introduction handling. We say this plainly in the abstract.

**Walk-forward extension.** Christoffersen-cc passes 19/24 rolling-origin walk-forward folds at α = 0.05. The 5/24 failures concentrate on the W2 (COVID) and W4 (2022 rate-hike onset) stress folds.

**Faster refit cadences do not close W2.** A within-fold refit-cadence sweep (fold-IS-fixed, monthly, weekly, daily) shows W2 still rejects at every cadence. **Daily refit (the cadence-boundary equivalent of a Cappé 2011 stochastic-recursion online-EM) makes W2 strictly worse**: under a rolling 5y daily-refit window at K* = 3, α = 0.05, W2 attains 21/253 breaches (8.30% vs 5% nominal), p_cc = 0.023, p_DQ = 0.001. The rolling train picks up rising COVID volatility and tightens the threshold, producing more breaches in the catastrophic March 2020 days, not fewer. **The "intrinsic regime-break" reading of W2 is strengthened, not qualified, at the cadence boundary**; closing W2 / W4 requires asymmetric per-state emissions or change-point / Bayesian online-changepoint constructions on T, not faster refit cadence.

**Multiple-testing correction.** Benjamini-Hochberg at FDR = 0.05 over the 40 Christoffersen-cc tests (16 headline + 24 walk-forward): 37/40 pass (vs 35/40 uncorrected). Bonferroni at 0.05/40: same 3 W2 rejections. Excluding W2 and W4, every row passes both corrections.

**Conditional-VaR is multi-state-generic, not CHMM-specific (round-3 result).** The same state-filter pipeline of Eq. (filter) was applied to the IS-fitted reference Bayesian MS-GARCH(1,1)-Gaussian models at K ∈ {2, 3, 4} via the Haas et al. (2004) state filter. At α = 0.05, all three MS-GARCH operating points pass Christoffersen-cc and DQ cleanly; at α = 0.01, MS-GARCH-4 passes both tests cleanly. **The conditional-coverage value proposition of the body conditional-VaR construction is therefore not CHMM-specific.** Any multi-state regime-switching model with sufficient state resolution and a state-filter pipeline produces the same regime-conditional VaR. The CHMM-vs-MS-GARCH choice is dominated by the marginal-distribution column (CHMM 89.7% IS KS vs MS-GARCH 0-37%), not the conditional-coverage column.

### 8.2 Cross-ticker generalisation (Pipeline A): 30-ticker panel

Refit independently on a sector-balanced 30-ticker panel (10 GICS sectors x 3 large-caps) under penalised CHMM-t at λ = 20. Three operating points reported (K* = 3, K* = 6, K = 18); within ~6pp of each other on KS.

| Metric (K = 18) | median | mean ± s.d. |
|---|---|---|
| IS KS | 99.5% | 99.3 ± 0.6% |
| OoS KS, IS-fixed | 73.4% | 66.8 ± 29.5% |
| OoS KS, quarterly refit | **83.0%** | 77.2 ± 21.2% |
| OoS KS, monthly refit | **86.7%** | 78.8% |
| Tickers OoS KS < 60% (IS-fixed / quarterly / monthly) | 11/30 / 7/30 / 5/30 |

**The IS distribution is tight; the OoS distribution is sector-stratified.** Failures concentrate on regime-introduction tickers (LLY 7.6% on weight-loss-drug, UNH 14.5% on 2024 healthcare-policy compression, NEM 5.6%). **Quarterly refit shifts the median from 73.4% to 83.0% and reduces failures from 11/30 to 7/30**; monthly refit further to 5/30. Failures are ticker-specific not sector-specific (n = 60 ANOVA F(9, 50) = 0.37, p = 0.946, η² = 0.062).

**Per-ticker λ-hat-star is the body cross-ticker recipe.** A sweep λ ∈ {0, 5, 10, 20, 50, 100} on the six body tickers under a 1.5pp KS-degradation tolerance selects λ* ∈ {0, 10, 20}. Uniform λ = 20 is right on heavy-tailed defensives (NVDA, JNJ) but over-shrunk on SPY / JPM / AAPL / QQQ. The shared-ν alternative side-steps the λ choice entirely.

### 8.3 Cross-asset dependence (Pipeline B): Student-t copula

A separate problem from "model one stock well": for a portfolio you need correlated stocks. **Sklar's theorem**: any joint distribution decomposes into (marginals) + (copula). Keep the per-asset CHMM marginals; fit a copula on top.

Pipeline:
1. Fit CHMM independently on each asset.
2. Compute ranks (probability integral transform).
3. Estimate copula correlation via Kendall's tau inversion (rho_ij = sin(π τ_ij / 2)).
4. Fit ν by profile MLE on the six-asset US-equity universe; selection picks ν* = 6 with Wilks 95% profile-LL CI [6, 7] (parametric bootstrap CI agrees, excluding the Gaussian limit). The full one-shot MLE returns ν̂_full = 6.40 against ν̂_two-step = 6.00, a +5.55 LL improvement and within the Wilks 95% CI: the two-step estimator is not biased toward the Gaussian limit on this universe.
5. Simulate by Iman-Conover rank reordering.

**Result.** Off-diagonal correlation MAE on IS: **0.027 (Student-t)**, 0.030 (Gaussian), 0.068 (truncated C-vine), 0.076 (SIM). Student-t wins on IS. **On OoS the dependence-family choice is empirically null at this N_paths**: 0.209 Student-t vs 0.202 Gaussian, a 0.007 difference below the simulation-noise floor. **The IS finding is IS-only; on OoS the dependence-family selection is not supported.** The operational story on OoS is the quarterly-rolling refit, which reduces OoS off-diagonal MAE from 0.209 to 0.185.

The body cross-asset construction is **scoped to a US-equity universe**. The non-equity GLD / SLV stress test confirms 0% OoS KS under static IS-fitted CHMM: the cross-asset claim does not extend without periodic refit.

### 8.4 CRPS (proper scoring rule)

CHMM-N at K = 18 has the lowest mean OoS CRPS in the panel (1.0384). The four CHMM variants tie on a proper scoring rule (within-CHMM Diebold-Mariano two-sided p > 0.45, robust across NW-HAC bandwidth h ∈ {4, 8, 16, 32}). The four families are interchangeable on this evaluation rather than per-family-strength differentiated.

---

## 9. Conclusions

1. **CHMM trained by Baum-Welch with quantile init reproduces the three symmetric Cont stylized facts simultaneously on SPY at K* = 3** (state-resolution-robust under k-fold rolling-origin CV on the strictly pre-2020 slice), with K* = 6 as a single-fold sensitivity reference and K = 18 as an extended-state-resolution sensitivity reference. K = 18 carries K_eff = 11; the K_nominal = 11 rebuild matches the K = 18 row on every axis. The K = 18 over-parameterisation is a parameter-counting artefact.

2. **The mechanism is spectral, but the substantive contribution is the empirical effective-rank diagnostic, not a re-derivation of the identity.** The mixture-of-eigenvalues identity is folklore (Hamilton 1994, Krolzig 1997, Timmermann 2000). What we add is the empirical observation that the rank constraint is non-binding at the cross-ticker median (75.6%, vs SPY's 94% which is a right-tail value).

3. **Five emission flavours give a clean tail-heaviness slider on the same scaffold.** Same EM scaffold; only the M-step changes. The shared-ν Student-t at K = 18 is the structurally cleanest IS / OoS heavy-tail match in the entire panel without any penalty hyperparameter (6.25 IS / 5.00 OoS against observed 7.68 / 5.29). The body retains the per-state ν_k + λ = 20 construction for direct comparability with the Peel-Liu (2000) tradition; CHMM-GED's data-driven Gaussian-bulk / Laplace-tail partition replicates across seeds and tickers.

4. **The model passes downstream risk-management checks at every layer except the strict tail at K = 18.** Envelope bracketing on both windows; unconditional Kupiec passes; the regime-conditional Christoffersen-cc passes Kupiec / Christoffersen-ind / Christoffersen-cc cleanly at α = 0.05 on the headline OoS window and on 19/24 walk-forward folds. **At α = 0.01 the higher-power Engle-Manganelli DQ test rejects K = 18 (p = 0.017) on the stationary OoS slice**: the strict-tail conditional-VaR property is not supported at T_OoS = 572. CRPS is competitive with the best benchmark.

5. **The conditional-VaR benefit is multi-state-generic, not CHMM-specific.** The same state-filter pipeline applied to MS-GARCH at K ∈ {2, 3, 4} also passes conditional coverage cleanly. The CHMM-vs-MS-GARCH choice is dominated by the marginal-distribution axis, not the conditional-coverage axis.

6. **ML HSMM is a co-headline scaffold, not a displaced result, with no single best operating point.** The Pareto-sojourn HSMM-N at K* = 3 wins raw OoS KS at 91.0% but its |G_t| ACF-MAE matches the i.i.d. baseline. The Gamma-sojourn HSMM-N at K = 18 wins |G_t| ACF-MAE at 0.0462 (panel-best) but loses 11pp on KS relative to the Pareto K* = 3 row. CHMM at moderate K is the right choice when the structural use cases are in scope.

7. **Cross-ticker generalisation runs on a sector-balanced 30-ticker panel and a 60-ticker n = 6 expansion**: IS KS distribution tight (median 99.5%), OoS distribution sector-stratified with 11/30 below 60% concentrated in single-name regime introductions. Quarterly refit shifts the OoS KS distribution from median 73.4% to 83.0% and reduces failures to 7/30; monthly to 5/30. Failures are ticker-specific not sector-specific (n = 60 ANOVA p = 0.946, η² = 0.062).

8. **Cross-asset extension is clean on IS but null on OoS at this N_paths.** Student-t copula at ν* = 6 attains six-asset IS off-diagonal MAE 0.027 (vs 0.030 Gaussian); on OoS the 0.007 family gap is below the noise floor. Quarterly rolling refit reduces OoS MAE from 0.209 to 0.185. The body cross-asset claim is scoped to a US-equity universe; GLD / SLV confirms.

9. **Cross-decade CRSP 1994-2006 transfer.** IS axis decade-robust (84-90% IS KS); 2004-2006 OoS slice collapses to 3-5% under static IS fit. Same low-stress / low-kurtosis pattern as W2 / W4 walk-forward stress folds; same operational fix (periodic refit).

10. **OoS degradation on stress folds and individual stocks is honest.** Stationarity-scope artefact, not a model failure; periodic refit is the standard fix. W2 / W4 remain out-of-distribution for every generator under any refit cadence.

11. **Practical contribution.** A single, reproducible (Julia package CHMM-Model.jl, MIT license), interpretable model. The contribution after all framing fixes lands on the structural use cases (regime-conditional VaR, copula composition, parametric privacy / licensing) that the i.i.d. bootstrap cannot serve, and on the empirical effective-rank diagnostic that explains why moderate K works.

---

## 10. Vocabulary cheat sheet

| Term | Plain meaning |
|---|---|
| HMM (hidden Markov model) | Model with unobserved states evolving Markov-style and observations depending on the current state |
| Continuous HMM (CHMM) | An HMM with real-valued (not binned) observations |
| Emission density | Probability distribution of the observation given the state |
| Transition matrix T | K x K matrix of state-to-state transition probabilities |
| Stationary distribution π̄ | Long-run fraction of time the chain spends in each state |
| Effective rank of T - 1 π̄' | How many non-unit eigenvalues actually carry meaningful weight in the |G| ACF mixture |
| Baum-Welch | Standard EM for HMMs |
| EM (Expectation-Maximization) | Iterative alternation of E (posteriors) and M (parameter updates) |
| ECM | EM with the M-step broken into multiple conditional steps |
| HSMM | HMM with explicit (non-geometric) sojourn distribution |
| KS (Kolmogorov-Smirnov) | Two-sample test for whether two empirical distributions are the same |
| ACF | Autocorrelation function |
| Stylized facts | Empirical regularities of financial returns |
| GARCH / MS-GARCH | Volatility-clustering econometric model / Markov-switching variant |
| VaR / ES | Value-at-Risk / Expected Shortfall |
| Kupiec test | Unconditional regulatory backtest for VaR coverage |
| Christoffersen-ind / cc | Conditional VaR backtests; cc is the joint coverage + independence test |
| Engle-Manganelli (2004) DQ | Higher-power conditional-coverage test based on a hit regression |
| Regime-conditional VaR | VaR-hat_t built from the one-step-ahead filtered state forecast through the CHMM mixture CDF |
| Walk-forward | Rolling-origin OoS evaluation across multiple folds |
| Block-bootstrap KS recalibration | KS critical value under a temporally-aware (autocorrelated) null at mean block length L = 20 |
| Copula | Function coupling marginals into a joint distribution; captures dependence only |
| Sklar's theorem | Joint CDF = (copula) ∘ (marginals) |
| Iman-Conover rank reordering | Simulation trick that injects copula dependence while preserving each marginal exactly |
| CRPS | Proper scoring rule for probabilistic forecasts |
| K_eff | Effective state count under a single-linkage state-distinctness criterion |

---

## 11. Likely questions to be ready for

- **"Why K* = 3 now? The earlier draft headlined K* = 6."** Round-2 reviewer pressure: under k-fold rolling-origin CV on the strictly pre-2020 slice, K = 6 vs K = 3 is indistinguishable on mean held-out per-observation log-likelihood (|z| ≤ 0.07 with the sign flipping between fold designs) and under HAC (|z_HAC| = 0.90 / 0.57). The state-resolution-robust default is therefore K* = 3; K* = 6 is retained as a single-fold sensitivity reference.
- **"Why is the spectral identity not the contribution?"** Folklore (Hamilton 1994, Krolzig 1997, Timmermann 2000). The substantive content is the empirical effective-rank diagnostic on the fitted T̂. The cross-ticker median dominant-mode share is 0.756, minimum 0.326 on NEM. The SPY 94% is a right-tail value; the rank-non-binding claim reads at the median.
- **"Isn't this overfitting?"** OoS KS at K* = 3 is 80% asymp / 58% block-recalibrated. The Gaussian negative control is rejected at 1% OoS, so the test is discriminating. The K = 2 replication shows ACF behaviour is robust to initialisation. The cross-decade CRSP slice shows the IS axis is decade-robust within ~5pp.
- **"The bootstrap beats every CHMM operating point on raw OoS KS (92.1% vs 80.5%). Why is this not the headline?"** It is, on raw 1-day OoS KS at this single window, and the body says so plainly. The CHMM contribution is reframed around three use cases the bootstrap cannot serve: (i) regime-conditional VaR, since the bootstrap has no latent state forecast; (ii) multi-asset copula composition, since rank-reordering needs an analytic CDF per asset; (iii) privacy / licensing, since the bootstrap ships actual rows of the original data. On raw KS at this T_OoS the bootstrap is the simpler choice.
- **"Why not just use a deep generator?"** QuantGAN TCN is in the panel. Both 3-conv and 7-block TCN variants, with and without Lambert-W input pre-processing, fail KS at 0% IS / 0% OoS. We are explicit: this is an in-house WGAN re-implementation result, not a verdict on the deep-generative class. A faithful Wiese et al. (2020) reference re-run is a deferred follow-up.
- **"Why does unpenalised CHMM-t overshoot kurtosis?"** Per-state ν_k ECM lower-bracket pinning. The body retains the penalised λ = 20 construction for direct comparability with Peel-Liu (2000). The shared-ν ablation eliminates the overshoot completely without any penalty (6.25 IS / 5.00 OoS at K = 18 against observed 7.68 / 5.29). The bracket-lift ablation (ν_min = 4) drops kurtosis by ~1 unit but does not bring it inside the bootstrap CI on observed; the shrinkage is doing real work the bracket alone cannot replicate.
- **"Why is HSMM a co-headline if its OoS KS beats CHMM at K* = 3?"** Two reasons. First, the Pareto-sojourn HSMM at K* = 3 wins KS but its |G_t| ACF-MAE matches the i.i.d. baseline (0.0629), so the volatility-clustering diagnostic is essentially lost. The Gamma-sojourn HSMM at K = 18 wins |G_t| ACF-MAE (0.0462, panel-best) but loses 11pp on KS. There is no single best HSMM operating point. Second, the Pareto-sojourn HSMM collapses at K = 18 (0.8% IS / 33.4% OoS) and the explicit-duration scaffold has a K ≤ 6 practical limit on T_IS = 2,516 unless the sojourn family is changed.
- **"What about the OoS failures on the 30-ticker panel?"** Honest stationarity-scope limitation. 11/30 below 60% OoS KS at the IS-fixed univariate scale, concentrated in single-name regime introductions (LLY weight-loss-drug, UNH 2024 healthcare-policy, NEM). Quarterly refit shifts the median from 73.4% to 83.0% and reduces failures to 7/30; monthly to 5/30. Failures are ticker-specific not sector-specific (adequately-powered n = 60 ANOVA, p = 0.946, η² = 0.062).
- **"What about W2 COVID and W4 2022 rate-hike onset failing the walk-forward?"** Stress folds where the IS distribution genuinely does not span the realised regime. Every constant-across-t generator under any refit cadence fails KS on these folds. **Daily refit makes W2 strictly worse** (the rolling train picks up rising COVID volatility and tightens the threshold, producing more breaches in March 2020). Closing W2 / W4 requires asymmetric per-state emissions or change-point constructions on T, not faster refit.
- **"You admit K_eff ≈ 11 at K = 18. Doesn't that invalidate the K = 18 row?"** Honest concession in body and abstract. The K_eff-corrected IC re-rank moves AIC / HQC selections at K ≥ 12 but does not affect the K* = 3 body headline. A direct K_nominal = 11 rebuild matches the K = 18 row on every axis. The K = 18 over-parameterisation is therefore a parameter-counting artefact rather than information-bearing extra resolution; we report K = 11 alongside as the structurally cleaner expression.
- **"Did the multiple-testing correction kill the conditional-VaR claim?"** No. BH at FDR 0.05 over 40 tests rejects 3/40 (vs 5/40 uncorrected); Bonferroni rejects the same 3 rows. Excluding W2 (COVID) every row passes under both corrections. **The α = 0.01 K = 18 DQ rejection on the stationary OoS slice (p = 0.017) is the substantive caveat now**, not the multiple-testing exposure. We say so plainly.
- **"Is the conditional-VaR construction a CHMM contribution or a generic multi-state recipe?"** Generic. The same state-filter pipeline applied to MS-GARCH at K ∈ {2, 3, 4} passes Christoffersen-cc and DQ cleanly at α = 0.05; MS-GARCH-4 also passes both at α = 0.01. The body now reframes the conditional-VaR construction as a multi-state state-filter recipe that the CHMM scaffold instantiates cleanly; the CHMM-vs-MS-GARCH choice is dominated by the marginal-distribution column.
- **"Did the multi-day CRPS-DM result survive replication?"** No. The K = 18 SPY h = 20 result (p = 0.003) does not replicate at K* = 3 on SPY (p = 0.244) or across the six-asset universe at K* = 3. The body's strongest CHMM-vs-bootstrap differentiator on multi-day forecast horizons is K = 18-specific. Differentiation lands on structural use cases, not multi-day forecasting.
- **"What about the block-aware OoS KS recalibration?"** Substantial: ~25pp drop on every OoS row at L = 20. Cross-generator ordering preserved; the absolute-level numbers in the asymp column should be read against the L = 20 panel. CHMM-N at K* = 3 moves from 80% (asymp) to 59% (block) on OoS.
- **"What scope does the paper actually claim?"** Daily US equities on stationary OoS windows. The headline IS / OoS slice is 2014-2024 / 2024-2026. The cross-decade slice is 1994-2006. The non-equity GLD / SLV stress test confirms the static-fit claim does not extend to non-equity classes without periodic refit. We say this scope explicitly in the abstract.
- **"What would scaling up look like?"** Skew-emission CHMM (skew-t, skew-Laplace) for the leverage / gain-loss-asymmetry axis, change-point / Bayesian online-changepoint constructions on T for regime-introduction stress folds, untruncated regular vines or factor copulas for larger d, faithful Wiese et al. QuantGAN reference re-run, post-QuantGAN deep generators (diffusion, normalising flows). Flagged as companion-paper directions.

---

## 12. Bottom-line summary for the meeting

Read this aloud if cornered.

### One-sentence pitch

A reproducible Julia-package CHMM scaffold that lives in the joint-fit corner where prior simple Markov-backbone baselines could not, framed honestly relative to two stronger-on-one-axis alternatives (i.i.d. bootstrap on raw 1-day OoS KS, ML HSMM on raw OoS KS at K* ∈ {3, 6} or on |G_t| ACF-MAE at K = 18 under Gamma sojourn), with an empirical effective-rank diagnostic that explains why moderate K works and a regime-conditional VaR construction that survives multiple-testing correction at α = 0.05 and rejects strict-tail coverage at α = 0.01 on K = 18.

### What the paper does well

1. Reproduces all three symmetric Cont stylized facts simultaneously on SPY at the held-out-clean K* = 3 default, on a 30-ticker (and 60-ticker) sector panel, on a six-asset US-equity copula, and on a CRSP cross-decade slice.
2. Five emission families on the same scaffold give a clean tail-heaviness slider; the **shared-ν Student-t at K = 18 is the cleanest IS / OoS heavy-tail match in the panel without any penalty hyperparameter**.
3. Regime-conditional VaR built from the one-step-ahead state filter passes Christoffersen-cc + DQ + Kupiec cleanly at α = 0.05 on 19/24 walk-forward folds, surviving BH and Bonferroni multiple-testing correction.
4. Empirical effective-rank diagnostic explains the Rydén low-K failure as distributional rather than temporal at the cross-ticker median (75.6%).
5. Cross-asset Student-t copula attains six-asset IS off-diagonal MAE 0.027 (best in panel); cross-asset OoS gap is sample-size-bound, not estimator-bound.

### What the paper concedes openly (round-3 framing)

1. The i.i.d. block bootstrap beats every CHMM operating point on raw 1-day OoS KS at this single window (92.1% vs 80.5%). Block-aware recalibration at L = 20 drops every row by ~25pp; CHMM-N at K* = 3 lands at 59% block-recalibrated.
2. ML HSMM-N (Pareto, K* = 3) beats every CHMM row on raw OoS KS at 91.0%; ML HSMM-N (Gamma, K = 18) beats every CHMM row on |G_t| ACF-MAE at 0.0462. CHMM positioning is on structural use cases, not raw single-axis dominance.
3. The α = 0.01 K = 18 DQ test rejects conditional coverage on the stationary OoS slice (p = 0.017). The strict-tail conditional-VaR property is not supported at T_OoS = 572.
4. The regime-conditional VaR benefit is multi-state-generic. The same state-filter recipe applied to MS-GARCH passes Christoffersen-cc and DQ cleanly. The CHMM-vs-MS-GARCH choice is dominated by the marginal-distribution column, not the conditional-coverage column.
5. K = 18 nominal carries K_eff = 11 under a single-linkage state-distinctness criterion. A K_nominal = 11 rebuild matches K = 18 on every axis; the K = 18 over-parameterisation is a parameter-counting artefact.
6. The K = 18 multi-day CRPS-DM win over the bootstrap (p = 0.003) does not replicate at K* = 3 or across the six-asset universe at K* = 3. The K = 18 multi-day result is K = 18-specific.
7. Cross-asset dependence-family selection is an IS-only finding; on OoS at N_paths = 200 the Gaussian and Student-t copulas are statistically indistinguishable (0.007 difference, below the simulation-noise floor).
8. W2 (COVID) and W4 (2022 rate-hike onset) walk-forward stress folds remain out-of-distribution for every generator under any refit cadence; daily refit makes W2 strictly worse. Closing W2 / W4 requires asymmetric per-state emissions or change-point constructions, not faster refit.
9. The cross-asset claim is scoped to daily US equities. GLD / SLV non-equity stress test collapses to 0% OoS KS under static IS fit.
10. The QuantGAN TCN row is an in-house WGAN re-implementation result, not a verdict on the deep-generative class. Faithful Wiese et al. reference re-run is a deferred follow-up.

### The three messages to land in the meeting

1. **The contribution is the joint-fit corner plus the structural use cases**, not panel-leading raw KS. CHMM is the right choice when you need parametric per-asset marginals (copula composition), a one-step-ahead state filter (regime-conditional VaR), or a parametric synthetic-data generator that does not ship literal IS rows (privacy / licensing). It is not the right choice if you only need raw 1-day OoS KS on this single window.
2. **The framing is now honest about the limits**: K_eff < K_nom at K = 18; α = 0.01 strict-tail conditional-VaR rejected; multi-day differentiation K = 18-specific; cross-asset OoS family-null; cross-asset scope US-equity-only; W2 / W4 intrinsic regime-break. Each of these landed in the abstract or §5 limitations after round-2 / round-3 review pressure. The empirical conclusions survive every framing fix.
3. **The shared-ν Student-t row is the single most important post-review addition.** It eliminates the per-state ν_k IS-kurtosis-overshoot artefact entirely without any penalty hyperparameter and produces the cleanest single-row IS / OoS heavy-tail match in the entire panel (6.25 IS / 5.00 OoS against observed 7.68 / 5.29). This is the structurally clean recipe to lead with if asked to recommend a single CHMM-t variant.
