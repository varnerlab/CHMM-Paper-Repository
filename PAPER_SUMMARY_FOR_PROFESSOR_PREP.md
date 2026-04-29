# Paper Summary: CHMM as a Synthetic-Data Generator for Equity Returns

A from-scratch walkthrough for prepping the meeting with the professor. Assumes no prior background in finance, hidden Markov models, or time-series statistics.

Full title: *"A Regime-Switching Continuous Hidden Markov Model as a Reference Synthetic-Data Generator for Equity Returns"*
Authors: Abdulrahman Alswaidan, Cade Jin, Jeffrey D. Varner.

---

## 1. The Big Picture in Two Sentences

We built a statistical model that takes a real history of daily stock returns and learns how to generate realistic *fake* (synthetic) return histories that look statistically indistinguishable from the real ones. The novelty is that a single relatively simple model (a continuous hidden Markov model, CHMM) reproduces all three of the well-known "stylized facts" of daily equity returns at the same time, and we explain *why* it works through a closed-form mixture-of-eigenvalues identity for the absolute-return ACF combined with an empirical effective-rank diagnostic showing that the historical Rydén low-K failure was a distributional bottleneck, not a temporal one.

---

## 2. Why Does Anyone Care About Synthetic Equity Returns?

Banks, hedge funds, regulators, and risk teams need huge amounts of realistic-looking market data for several reasons:

1. **Stress testing.** What happens to a portfolio if the market behaves badly for two years? You need many plausible "alternate histories" to estimate that, but you only have one actual history.
2. **Regulatory backtesting.** Regulators (Basel III, etc.) require banks to demonstrate their risk models are calibrated. Backtesting needs synthetic paths.
3. **Scenario design.** Designing trading strategies, allocations, hedges. You want to test on many possible futures.
4. **Training ML models on data you cannot release.** Privacy, licensing. You can release synthetic data that has the same statistics as confidential data without leaking the actual data.

So a "synthetic-data generator" is like a market simulator. The bar for it being useful is that the simulated returns should be statistically *almost identical* to real returns on the standard diagnostic tests.

---

## 3. What Are the "Stylized Facts" We Are Trying to Match?

These are three universally observed empirical features of daily stock returns. Any good generator must reproduce all three simultaneously:

### 3.1 Heavy-tailed marginals
The histogram of daily returns has fatter tails than a bell curve (Gaussian). Extreme moves (say, a 5% drop in one day) happen more often than a Gaussian would predict. Numerically this shows up as **excess kurtosis** above zero (Gaussian = 0; SPY in-sample = 7.68, out-of-sample = 5.29).

### 3.2 Negligible linear autocorrelation
If today's return was big, that does not predict the *direction* of tomorrow's return (otherwise easy money). The autocorrelation of the raw return series is essentially zero at all lags.

### 3.3 Slow decay of the absolute-return ACF (volatility clustering)
But if today's *absolute* return was big (a big move, in either direction), tomorrow is more likely to also be a big move. "Volatile days cluster together." This shows up as the autocorrelation function of `|return|` being positive and decaying *slowly* over many days. This is what people call "volatility clustering."

The stylized facts come from Mandelbrot (1963) and were canonized by Cont (2001). Any generator that misses any of the three is considered broken for serious risk work.

---

## 4. What Did Prior Work Do, and Why Was It Stuck?

There are roughly three prior families of generators:

| Family | What it does well | What it fails on |
|---|---|---|
| **i.i.d. bootstrap / sampling** (just resample real returns) | Marginal (kurtosis, KS) is exact | Destroys volatility clustering completely |
| **GARCH(1,1)** (Bollerslev 1986) | Volatility clustering captured cleanly | Marginal distribution is unimodal and fails KS decisively |
| **Deep generative models** (TimeGAN, QuantGAN) | Visually realistic | Hard to interpret, hard to reproduce, often still fail volatility tests |

There was also a famous *negative result* in this space:

**Rydén, Teräsvirta, and Asbrink (1998)** fit Gaussian-emission HMMs at K = 2 or 3 hidden states and concluded that HMMs cannot reproduce the slow ACF decay of absolute returns, because the implied "how long do we stay in a state" distribution (called the sojourn-time distribution) is geometric and decays too quickly. Their negative result killed regime-switching HMMs as a research direction for nearly two decades.

**Bulla and Bulla (2006)** restored ACF fidelity by replacing the Markov chain with a *semi-Markov* chain (where you model the sojourn time explicitly). This works but adds substantial complexity.

So before this paper, the field had a problem: no simple Markovian model jointly passed both diagnostics inside the standard HMM scaffold; semi-Markov fixes existed but added machinery.

To be precise about what that claim means (because the professor will push on it): prior simple models can each *qualitatively* produce all three. GARCH(1,1)-t, MS-GARCH, and stochastic-volatility models all generate heavy tails, near-zero linear autocorrelation, and slow `|G|` ACF decay. The point is *quantitative*: none of them simultaneously passes a strict goodness-of-fit test on the marginal (e.g., KS) *and* matches the absolute-return ACF at the level needed for synthetic-data work. Table 1 makes this concrete: GARCH(1,1) sits at IS KS 23.4% with ACF-MAE 0.0485; MS-GARCH at 27.7% with 0.0367; the bootstrap is at 99.7% KS but ACF-MAE 0.0628 (it destroys clustering). The CHMM rows are the only block at 88%+ IS KS *and* ~0.05 ACF-MAE simultaneously across multiple operating points. Bulla and Bulla (2006) did achieve this joint fit, but only by leaving the standard Markov scaffold for an explicit-duration semi-Markov model. We re-include the semi-Markov route in our panel and treat it as a complementary (not displaced) headline at K* = 3, where ML HSMM-N attains the highest single-window OoS KS (91.0%) but at the cost of an absolute-return ACF-MAE that matches the i.i.d. baseline level (0.0629).

---

## 5. What We Actually Built

### 5.1 The model: Continuous Hidden Markov Model (CHMM)

A hidden Markov model assumes the world goes through a sequence of unobserved "regimes" or "states" (think: calm market, jittery market, panicky market, etc.). Each day:

1. The market is in one of K hidden states $s_t \in \{1, \ldots, K\}$.
2. Tomorrow, it transitions to a new state with probabilities given by a $K \times K$ transition matrix $\mathbf{T}$ (each row sums to 1).
3. Conditional on being in state $k$, today's return $G_t$ is drawn from a state-specific probability distribution $b_k(\cdot)$ called the *emission density*.

"Continuous" means the observed returns are real-valued numbers (as opposed to discretized into bins, which is the older alternative).

We tested four flavors of the emission density, all sharing the same scaffold (transition matrix $\mathbf{T}$, initial distribution $\boldsymbol{\pi}$, log-space forward-backward, quantile-based init). Only the M-step differs across them.

- **CHMM-N (Gaussian)**: $b_k(x) = \mathcal{N}(x;\,\mu_k,\,\sigma_k^2)$. Two parameters per state.
- **CHMM-t (Student-t)**: $b_k(x) = t_{\nu_k}(x;\,\mu_k,\,\sigma_k)$. Three parameters per state. We also report a **penalised CHMM-t at $\lambda = 20$**, which adds an exponential $1/\nu_k$ shrinkage prior to suppress lower-bracket pinning.
- **CHMM-L (Laplace)**: $b_k(x) = \mathrm{Laplace}(x;\,\mu_k,\,b_k)$. Two parameters per state.
- **CHMM-GED (Generalized Error Distribution, also called the generalized Gaussian)**: $b_k(x) = \mathrm{GED}(x;\,\mu_k,\,\alpha_k,\,p_k)$. Three parameters per state. The GED nests Gaussian at $p = 2$ and Laplace at $p = 1$, so per-state $p_k$ is the structural analog of CHMM-t's $\nu_k$ on the Gaussian-to-Laplace shape axis.

#### Per-variant parameter cheat sheet

What each per-state parameter does, and how it is updated in the M-step:

| Variant | Parameter | Role | M-step update |
|---|---|---|---|
| **CHMM-N** | $\mu_k$ | location (mean) of state $k$'s Gaussian | closed form: $\gamma$-weighted sample mean |
|  | $\sigma_k^2$ | variance (spread); fully determines tails for a Gaussian | closed form: $\gamma$-weighted sample variance |
| **CHMM-t** | $\mu_k$ | location | closed form given $\nu_k$ ($u$-weighted mean, where $u_{t,k}$ is the latent precision from the $t$-mixture representation) |
|  | $\sigma_k$ | scale (not variance; for a $t$ the variance is $\nu_k \sigma_k^2/(\nu_k - 2)$ when $\nu_k > 2$) | closed form given $\nu_k$ |
|  | $\nu_k$ | degrees of freedom; controls tail heaviness. $\nu_k \to \infty$ recovers Gaussian; $\nu_k \to 2$ gives infinite variance and very heavy tails. **Bracket: $[2.1, 50]$.** Penalty $\lambda$ on $1/\nu_k$ optionally shrinks toward Gaussian. | 1-D golden-section search on the conditional $Q$-function (ECM step) |
| **CHMM-L** | $\mu_k$ | location (the Laplace MLE for location is the median, not the mean) | closed form: $\gamma$-weighted median |
|  | $b_k$ | scale; the Laplace tail is $\propto e^{-|x-\mu|/b}$, fatter than Gaussian but with no shape parameter | closed form: $\gamma$-weighted mean absolute deviation around $\mu_k$ |
| **CHMM-GED** | $\mu_k$ | location | bracketed golden-section minimizing $\sum_t \gamma_t(k)\,|O_t - \mu|^{p_k}$ |
|  | $\alpha_k$ | scale | closed form given $\mu_k, p_k$ |
|  | $p_k$ | shape on the Gaussian-Laplace axis: $p_k = 2$ Gaussian, $p_k = 1$ Laplace, $p_k < 1$ very heavy "spikier" tails. **Bracket: $[0.5, 3.0]$.** | bracketed golden-section maximizing $\sum_t \gamma_t(k) \log b_k(O_t; \mu_k, \alpha_k, p)$ |

Plus the shared parameters that every variant carries: the $K \times K$ transition matrix $\mathbf{T}$ ($K(K-1)$ free parameters) and the initial distribution $\boldsymbol\pi$ ($K - 1$ free parameters).

CHMM-GED is the most flexible: instead of *picking* a shape (Gaussian, Laplace, or Student-t), it lets each state's $p_k$ adapt to what that state's data wants. Empirically on SPY at $K = 18$, the $\hat p_k$ values split bimodally into a Gaussian-like cluster ($\hat p_k \approx 2$) and a Laplace-like cluster ($\hat p_k$ near 1), with the Laplace-like cluster concentrated in the high-volatility / crash tail of the state ordering. This data-driven Gaussian-bulk / Laplace-tail partition replicates across 10 random seeds and across the cross-ticker panel.

### 5.2 How we train it: Baum-Welch (EM)

Baum-Welch is the standard algorithm for fitting HMMs. It is an instance of the EM (Expectation Maximization) algorithm. The intuition:

- We have observed data (returns) but not the hidden states.
- **E-step**: given current parameter estimates, compute the posterior probability of being in each state at each time, using forward-backward recursion (a dynamic programming algorithm).
- **M-step**: given those posterior probabilities, update the model parameters (transitions + emission parameters) by weighted maximum likelihood.

Iterate E and M until the log-likelihood stops moving (we use a tolerance of $10^{-4}$, typically converges in 20 to 40 iterations).

Two specific choices matter here:

1. **Quantile-based initialization.** Instead of starting EM from random parameters (the 1990s default), we sort the observed returns and split them into K equal-size chunks; each state is initialized from its corresponding chunk. This avoids the degenerate-local-optima problem that contributed to Rydén et al.'s pessimistic conclusion. A K = 2 replication on SPY (Appendix) shows ACF-MAE is essentially constant at ~0.050 across quantile and five random-seed initialisations: with modern initialisation the binding low-K constraint is *distributional*, not temporal.

2. **For CHMM-t and CHMM-GED**, some emission parameters are not closed-form. CHMM-t uses a 1-D golden-section search for $\nu_k$ on the conditional $Q$-function, an Expectation Conditional Maximization (ECM) step. CHMM-GED uses a three-stage ECM per state. Each is a partial maximization on a compact bracket, so EM monotonicity is preserved.

### 5.3 The theoretical core: spectral identity for the absolute-return ACF

For any stationary CHMM, the autocorrelation of `|G_t|` at lag $\tau$ is

$$\rho_{|G|}(\tau) = \sum_{k=2}^{K} c_k\, \lambda_k^{\tau} \,/\, \sigma_{|G|}^2,$$

where $\lambda_2, \ldots, \lambda_K$ are the non-unit eigenvalues of the transition matrix $\mathbf{T}$ and $c_k$ are weights determined by the per-state moments and stationary distribution. In plain English: the ACF is a *mixture* of geometric decays at the various eigenvalues of $\mathbf{T}$.

This identity is **folklore in the regime-switching literature** (Hamilton 1994, Krolzig 1997, Timmermann 2000), and we are explicit that we are not claiming to re-derive it. The substantive contribution is the **empirical effective-rank diagnostic** on the fitted $\hat{\mathbf{T}}$:

- The algebraic upper bound on the number of distinct decay modes is $K - 1$ (the rank of $\mathbf{T} - \mathbf{1}\bar{\boldsymbol\pi}^\top$).
- We measure the *effective* rank empirically and find it is non-binding at every $K \geq 3$ on equity-return data: a single non-unit eigenvalue carries **96.8% of the lag-1 absolute-return ACF at $K = 3$** and **93.6% at $K = 18$**.
- This reframes the Rydén low-K failure precisely. At $K = 2$ the rank constraint is binding (one mode, two-component marginal), and the empirical failure mode is *distributional* (KS on a Gaussian K = 2 mixture is 67-72% on SPY; ACF-MAE is essentially the same as at K = 18). At $K \geq 3$ the temporal axis decouples and the marginal-mixture component count drives the joint fit.
- The semi-Markov scaffold relaxes the temporal axis with an explicit sojourn distribution. But on equity-return data the temporal axis is *already non-binding* at $K \geq 3$ under standard Baum-Welch with quantile init. The operationally informative comparison between the CHMM and HSMM scaffolds therefore runs on the **distributional** axis.

This is the "why" behind why moderate $K$ works, and it is a precise statement we can defend.

---

## 6. The Data

- **Single-asset main study**: SPY (the SPDR S&P 500 ETF, which tracks the broad U.S. stock market).
  - In-sample (IS): Jan 3, 2014 to Jan 3, 2024, ten years, $T = 2{,}516$ trading days.
  - Out-of-sample (OoS): Jan 4, 2024 to Apr 20, 2026, $T = 572$ days.
- **Sector-balanced 30-ticker generalization panel**: 10 GICS sectors $\times$ 3 large-cap representatives. Each fit independently.
- **Cross-asset dependence study**: a six-asset subset (SPY, NVDA, JNJ, JPM, AAPL, QQQ) modeled jointly through a Student-t copula on CHMM marginals.

We work with the *annualized excess log return* $G_t = (1/\Delta t) \ln(P_t / P_{t-1}) - r_f$ with $\Delta t = 1/252$ and $r_f = 0$.

The IS / OoS split is critical: it tests whether the model trained on the past can produce data that still matches the future. This is how you guard against overfitting.

---

## 7. The Empirical Tests (and What They Mean)

### 7.1 The four core metrics

We simulate $P = 1{,}000$ independent paths from each fitted model and score them on:

1. **Kolmogorov-Smirnov (KS) test pass rate.** Tests whether the simulated distribution of returns is the same as the observed distribution. Run on each of the 1,000 paths; reported as the percentage that pass at $\alpha = 0.05$. Failing means the *marginal distribution* is wrong.
2. **Mean simulated excess kurtosis.** Direct measure of tail heaviness. Compare simulated mean to observed (7.68 IS, 5.29 OoS).
3. **ACF-MAE on absolute returns.** Mean absolute error between observed and simulated ACF of `|G|`, averaged over 252 lags. Direct diagnostic for volatility clustering.
4. **CRPS (Continuous Ranked Probability Score).** A proper scoring rule for probabilistic forecasts. Lower is better. Used because KS alone is not a proper scoring rule.

### 7.2 The benchmark generators

- **i.i.d. bootstrap** (Politis-Romano stationary): non-parametric distributional ceiling.
- **Gaussian i.i.d.**: negative control.
- **Laplace i.i.d.**: heavier-tailed i.i.d. comparator.
- **GARCH(1,1)**: workhorse volatility-clustering baseline.
- **GARCH(1,1)-t** (Bollerslev 1987): GARCH with Student-t innovations.
- **MS-GARCH** (Haas et al. 2004) at K = 2, 3, 4, 6: closest classical peer to CHMM.
- **ML HSMM-N at $K^\star = 3$** (Yu 2010 explicit-duration forward-backward, truncated Pareto sojourn): the explicit-duration semi-Markov scaffold.
- **QuantGAN**: deep generative reference (appendix).

### 7.3 The headline result (Table 1 in the paper)

The paper now reports **three operating points** for the CHMM:

- **$K^\star = 3$**: held-out log-likelihood and BIC choice. Risk-management default.
- **$K^\star = 6$**: held-out log-likelihood and held-out KS choice on the strictly pre-2020 slice. Synthetic-data default.
- **$K = 18$**: extended-state-resolution reference. Multi-objective rule (uses the OoS window, so not held-out-clean).

| Generator | IS KS | OoS KS | IS Kurt | OoS Kurt | `|G|` ACF-MAE | CRPS OoS |
|---|---|---|---|---|---|---|
| Observed | -- | -- | 7.68 | 5.29 | -- | -- |
| Bootstrap | 99.7% | 92.1% | 7.24 | 6.81 | 0.0628 | 1.0398 |
| Gaussian iid | 0.0% | 1.0% | -0.01 | -0.03 | 0.0627 | 1.0611 |
| Laplace iid | 99.1% | 88.5% | 2.95 | 2.91 | 0.0628 | 1.0386 |
| GARCH(1,1) | 23.4% | 60.8% | 7.06 | 2.96 | 0.0485 | 1.0440 |
| GARCH(1,1)-t | 57.3% | 80.8% | 15.13 | -- | **0.0316** | -- |
| MS-GARCH (K=2) | 27.7% | 38.7% | 4.73 | -- | 0.0367 | -- |
| **CHMM-N ($K^\star = 3$)** | 89.7% | 80.1% | 3.86 | -- | 0.0467 | 1.0412 |
| **CHMM-N ($K^\star = 6$)** | 92.6% | 78.3% | 5.26 | **4.46** | 0.0502 | 1.0422 |
| **CHMM-L ($K^\star = 6$)** | 88.3% | 76.3% | 5.86 | -- | 0.0510 | 1.0399 |
| **CHMM-GED ($K^\star = 6$)** | 91.8% | 79.0% | 5.22 | -- | 0.0518 | 1.0393 |
| **ML HSMM-N ($K^\star = 3$)** | 98.4% | **91.0%** | 3.46 | 3.38 | 0.0629 | -- |
| **CHMM-N (K=18)** | 94.1% | 81.8% | 5.04 | 4.44 | 0.0509 | **1.0384** |
| **CHMM-t pen. ($\lambda{=}20$, K=18)** | 95.0% | **85.8%** | **8.56** | **7.07** | 0.0542 | 1.0392 |
| CHMM-t unpen. (K=18) | 95.6% | 85.7% | 14.35 | 10.71 | 0.0549 | 1.0399 |
| **CHMM-L (K=18)** | 93.6% | 80.8% | 6.63 | 6.18 | 0.0567 | 1.0400 |
| **CHMM-GED (K=18)** | **95.2%** | 84.3% | 5.15 | 4.80 | 0.0548 | 1.0406 |

**Three headline takeaways from this table:**

1. **The four CHMM variants at $K^\star = 6$ are the held-out-clean synthetic-data default.** CHMM-N's simulated kurtosis 5.26 matches observed OoS 5.29 within 0.03; ACF-MAE 0.0502 is on par with GARCH's 0.0485; KS 92.6% IS / 78.3% OoS sits well above every Gaussian-tailed peer.

2. **The penalised CHMM-t at $\lambda = 20$ in the $K = 18$ block is the cleanest single-row IS / OoS kurtosis match.** Simulated kurtosis 8.56 IS / 7.07 OoS bracket observed 7.68 / 5.29 cleanly. Without the shrinkage prior, unpenalised CHMM-t IS kurtosis is 14.35, an artefact of one or two states pinning to the lower $\nu_k$ bracket.

3. **ML HSMM-N at $K^\star = 3$ is a co-headline result, not a displaced one.** It posts the highest single-window OoS KS in the entire panel (91.0%), but its absolute-return ACF-MAE is 0.0629, indistinguishable from the i.i.d. baseline level, because the fitted Pareto sojourn concentrates probability mass on a single low-volatility state. The CHMM and HSMM scaffolds are best read as two complementary attacks on the same Markov backbone with different KS / ACF trade-offs.

The four CHMM variants land at four distinct kurtosis points on the same scaffold without retuning $K$ or the transition structure: CHMM-N undershoots, unpenalised CHMM-t overshoots, CHMM-L sits between the two, CHMM-GED adapts per state, and the penalised CHMM-t is the IS-tuned cleanest joint match.

### 7.4 Robustness checks

- **State-count selection.** $K^\star = 3$ by held-out log-likelihood and BIC; $K^\star = 6$ by AIC and by held-out KS on a strictly pre-2020 slice; $K^\star = 9$ by held-out KS on the full IS slice. The body reports $K^\star = 3$, $K^\star = 6$, and $K = 18$ as three operating points. ACF-MAE is essentially flat (0.047 to 0.053) across the entire $K \in \{3, 6, 9, 12, 15, 18, 21\}$ sweep, consistent with the spectral identity and the effective-rank diagnostic.
- **Multi-seed Monte Carlo.** Seed-to-seed standard deviations on OoS KS are small relative to between-model gaps. CHMM-GED's $\hat p_k$ partition is also seed-invariant.
- **K = 2 replication on SPY.** ACF-MAE essentially constant at ~0.050 across quantile init and five random-seed initialisations, matching the K = 18 CHMM-N. The binding low-K constraint is distributional (KS at K = 2 drops to 67-72%), not temporal: with modern initialisation the ACF is reproduced at any $K \geq 2$.
- **KS power-calibration positive control.** An i.i.d. resample of the IS series passes OoS KS at ~90%, not 100%, because $T_{\text{OoS}} = 572$ is finite. So the CHMM's 76 to 86% pass rates are *near the test-power ceiling*.
- **Six-fold rolling-origin walk-forward.** Median OoS KS 67.7% at $K = 18$ and 62.1% at $K^\star = 3$. The single-window OoS sits at the upper end, with two stress folds (W2 COVID, W4 2022 rate-hike onset) below 10% by KS for *every* generator under any refit cadence: these are regime introductions the IS distribution does not span.
- **Effective-rank diagnostic.** Single non-unit eigenvalue carries 93.6% of lag-1 absolute-return ACF at $K = 18$ and 96.8% at $K = 3$, confirming the rank constraint is non-binding at $K \geq 3$.

---

## 8. Downstream / Application Tests

### 8.1 Value-at-Risk (VaR) and Expected Shortfall (ES) backtesting

VaR at level $\alpha = 1\%$ is the loss you should not exceed more than 1% of the time. ES at $\alpha = 1\%$ is the average loss conditional on being in the worst 1% of days. Regulators require banks to backtest their VaR models.

We organise the diagnostics in three layers:

**(i) Envelope bracketing.** All four CHMM variants bracket observed historical VaR and ES at 1% and 5% within the [5, 95]% envelope on both windows. CHMM envelopes are roughly $1.7\times$ tighter than GARCH's.

**(ii) Unconditional Kupiec coverage.** All four CHMM rows pass on both windows. We treat unconditional Kupiec as a sanity check at $T_{\text{OoS}} = 572$ (the integer breach count makes the statistic pile against the critical value rather than spreading continuously).

**(iii) Regime-conditional Christoffersen-cc — the new headline.** At each OoS day $t$ we run the forward filter through $\mathcal F_{t-1}$ to get the one-step-ahead state forecast $\Prob(s_t = k \mid \mathcal F_{t-1})$, then define $\widehat{\text{VaR}}_t(\alpha) = F_t^{-1}(\alpha)$ where $F_t$ is the family-appropriate predictive mixture CDF. **Every $(K, \alpha, \text{family})$ row passes Kupiec, Christoffersen-ind, and Christoffersen-cc cleanly at $\alpha = 0.05$ on OoS.** The independence statistic improves from 5.26 (unconditional) to 0.52 (conditional) at $K = 18, \alpha = 0.05$: this is the regime-switching value proposition that the unconditional Kupiec headline did not exercise. Every constant-across-$t$ generator (CHMM unconditional, GARCH, bootstrap) rejects breach independence.

The conditional construction extends to a **six-fold rolling-origin walk-forward with a 19/24 aggregate pass-rate** at $\alpha = 0.05$. The two failures concentrate on the COVID and 2022 rate-hike-onset stress folds, which the univariate walk-forward already flags as out-of-distribution by KS.

### 8.2 Cross-ticker generalization (Pipeline A): sector-balanced 30-ticker panel

We refit the model independently on a **sector-balanced 30-ticker panel** (10 GICS sectors $\times$ 3 large-cap representatives) at $K = 18$ with the penalised CHMM-t at $\lambda = 20$.

| Metric | median | $[Q_1, Q_3]$ | mean $\pm$ s.d. |
|---|---|---|---|
| IS KS (%) | 99.5 | [99.3, 99.6] | 99.3 $\pm$ 0.6 |
| OoS KS (%) | 73.4 | [49.1, 94.3] | 66.8 $\pm$ 29.5 |
| OoS KS, quarterly refit (%) | **83.0** | [62.0, 95.4] | 77.2 $\pm$ 21.2 |
| Tickers OoS KS < 60% (IS-fixed / refit) | 11/30 | / | 7/30 |

**The IS distribution is tight; the OoS distribution is sector-stratified.** Utilities, Information Technology, and Consumer Staples cluster above 90% median OoS KS; Health Care collapses (LLY 7.6% on the weight-loss-drug regime introduction; UNH 14.5% on 2024 healthcare-policy compression). A one-way ANOVA on OoS KS by sector returns $F(9, 20) = 0.44$ at $p = 0.90$: failures are *ticker-specific* rather than sector-specific.

**Quarterly refit fixes most of this.** OoS KS distribution shifts from median 73.4% to 83.0%, failures drop from 11/30 to 7/30, and the largest gains are exactly on regime-introduction tickers (LLY 7.6% → 83.7%, HD 41.4% → 82.2%). This is the well-known stationarity-scope limit on financial time series; the operational fix is periodic refit, standard practice in the literature.

### 8.3 Cross-asset dependence (Pipeline B): the Student-t copula

A separate problem from "model one stock well": if you want to simulate a *portfolio*, the simulated stocks need to be correlated with each other in the right way. **Sklar's theorem**: any joint distribution decomposes into (marginals) + (a copula that captures dependence), so we keep the per-asset CHMM marginals and fit a copula on top.

Pipeline:
1. Fit CHMM independently on each asset.
2. Compute ranks of observed returns (probability integral transform).
3. Estimate the copula correlation matrix via Kendall's tau inversion.
4. Fit degrees-of-freedom $\nu$ by profile MLE on a six-asset universe (SPY, NVDA, JNJ, JPM, AAPL, QQQ); selection picks $\nu^\star = 6$ with Wilks 95% profile-LL CI of [6, 7] (parametric bootstrap CI agrees, excluding the Gaussian limit).
5. Simulate by **rank reordering** (Iman-Conover): draw paths from each marginal CHMM, draw a sample from the copula, reorder each marginal sample so its ranks match the copula. This *exactly preserves* each marginal while injecting cross-asset dependence.

Comparators: Single Index Model, Gaussian copula, truncated C-vine.

**Result**: Off-diagonal correlation MAE on the six-asset universe IS is **0.027 (Student-t)**, vs 0.030 (Gaussian), 0.068 (truncated C-vine), 0.076 (SIM). The Student-t copula wins on IS. On OoS the off-diagonal MAE rises to 0.209 (Student-t) and 0.202 (Gaussian); the 0.007 difference is below the simulation-noise floor at $N_{\text{paths}} = 200$ and the Gaussian and Student-t copulas are statistically indistinguishable on OoS. **A quarterly-rolling refit reduces the OoS off-diagonal MAE from 0.209 to 0.185.**

### 8.4 CRPS (proper scoring rule)

CHMM-N at $K = 18$ has the lowest mean OoS CRPS in the panel (1.0384). The four CHMM variants tie or beat every benchmark on a proper scoring rule (Diebold-Mariano two-sided $p > 0.45$ for within-CHMM differences). **Point**: the headline KS finding is corroborated by a proper scoring rule, not an artifact of a non-proper metric.

---

## 9. What Are the Conclusions?

Stated plainly:

1. **A standard continuous HMM, trained by Baum-Welch with quantile-based initialization, reproduces all three Cont stylized facts simultaneously on SPY at three operating points: $K^\star = 3$ (held-out-LL/BIC, risk-management default), $K^\star = 6$ (held-out-LL/held-out-KS on the pre-2020 slice, synthetic-data default), and $K = 18$ (extended-state-resolution reference).** At $K^\star = 6$, CHMM-N delivers 92.6% IS / 78.3% OoS KS at simulated kurtosis 5.26 (essentially the OoS observed 5.29) and ACF-MAE 0.0502 (on par with GARCH's 0.0485).

2. **The mechanism is spectral, but the substantive contribution is the empirical effective-rank diagnostic, not a re-derivation of the identity.** The mixture-of-eigenvalues identity is folklore (Hamilton 1994, Krolzig 1997, Timmermann 2000). What we add is the empirical observation that the rank bound is non-binding at $K \geq 3$ on equity-return data: a single non-unit eigenvalue carries 93.6% of lag-1 absolute-return ACF at $K = 18$ and 96.8% at $K = 3$. The Rydén low-K failure was therefore a distributional bottleneck (only two mixture components at $K = 2$), not a temporal one. The K = 2 replication on SPY confirms ACF-MAE is essentially constant at ~0.050 with modern initialisation.

3. **Four emission flavors give a clean tail-heaviness slider.** CHMM-N undershoots, CHMM-L matches at 6.6, unpenalised CHMM-t overshoots at 14.4 (lower-bracket pinning artefact), the **penalised CHMM-t at $\lambda = 20$ is the cleanest IS / OoS kurtosis joint match (8.56 / 7.07 vs observed 7.68 / 5.29)**, and CHMM-GED's per-state shape $p_k$ produces a bulk/tail partition that replicates across seeds and tickers. Same EM scaffold; only the M-step changes.

4. **The model passes downstream risk-management checks at every layer.** Envelope bracketing at 1% and 5% on both windows; unconditional Kupiec passes; **the regime-conditional Christoffersen-cc, built from the CHMM one-step-ahead state forecast, passes Kupiec, Christoffersen-ind, and Christoffersen-cc cleanly at every $(K, \alpha)$ on OoS** and extends to a six-fold rolling-origin walk-forward with a 19/24 aggregate pass-rate at $\alpha = 0.05$. CRPS is competitive with the best benchmark.

5. **ML HSMM-N at $K^\star = 3$ is a co-headline, not a displaced result.** Highest single-window OoS KS in the panel (91.0%), but ACF-MAE matches the i.i.d. baseline (0.0629) because the fitted Pareto sojourn concentrates probability mass on a single low-volatility state. CHMM and HSMM are two complementary attacks on the same Markov backbone with different KS / ACF trade-offs.

6. **Cross-ticker generalisation runs on a sector-balanced 30-ticker panel** (10 GICS sectors $\times$ 3 large-caps): IS KS distribution is tight (median 99.5%), OoS distribution is sector-stratified with 11/30 below 60% concentrated in single-name regime introductions. **A quarterly refit shifts the OoS KS distribution from median 73.4% to 83.0% and reduces failures from 11/30 to 7/30**; failures are ticker-specific not sector-specific (ANOVA $p = 0.90$).

7. **Cross-asset extension is clean.** Plug a Student-t copula at $\nu^\star = 6$ on top of the per-asset CHMM marginals, get six-asset IS off-diagonal correlation MAE 0.027. Quarterly rolling refit reduces OoS MAE from 0.209 to 0.185.

8. **OoS degradation on stress folds and individual stocks is honest.** It is a stationarity-scope artifact, not a model failure; the recommended fix is periodic refit, standard practice for time-series generators. The W2 (COVID) and W4 (2022 rate-hike onset) folds remain out-of-distribution for *every* generator under any refit cadence.

9. **Practical contribution**: a single, reproducible (Julia package `CHMM-Model.jl`, MIT license), interpretable model that lives in the joint-fit corner where prior baselines could not, with three operating points calibrated to different consumer use-cases and a regime-conditional VaR construction that exercises the latent-state forecast directly.

---

## 10. Vocabulary Cheat Sheet (for the meeting)

| Term | Plain meaning |
|---|---|
| HMM (hidden Markov model) | A model with unobserved states that evolve via a Markov chain, and observations that depend on the current state. |
| Continuous HMM (CHMM) | An HMM where the observations are real-valued, not discrete bins. |
| Emission density | The probability distribution of the observation given the hidden state. |
| Transition matrix $\mathbf{T}$ | The $K \times K$ matrix of state-to-state transition probabilities. |
| Stationary distribution $\bar\pi$ | The long-run fraction of time the chain spends in each state. |
| Effective rank of $\mathbf{T} - \mathbf{1}\bar\pi^\top$ | How many non-unit eigenvalues actually carry meaningful weight in the absolute-return ACF mixture. |
| Baum-Welch | Standard EM algorithm to fit HMMs. |
| EM (Expectation-Maximization) | Iterative algorithm: alternate computing posteriors (E) and updating parameters (M). |
| ECM | EM where the M-step is broken into multiple conditional steps (used for $\nu_k$ and $p_k$). |
| HSMM (hidden semi-Markov model) | Like HMM but with an explicit sojourn distribution (not geometric). |
| KS (Kolmogorov-Smirnov) test | Two-sample test for whether two empirical distributions are the same. |
| ACF (autocorrelation function) | Correlation of a time series with its own lagged values. |
| Stylized facts | Empirical regularities of financial returns (heavy tails, no linear autocorr, slow `|return|` ACF). |
| GARCH | Econometric volatility-clustering model. |
| MS-GARCH | Markov-switching GARCH (Haas et al. 2004). |
| VaR / ES | Tail-loss risk measures (Value-at-Risk, Expected Shortfall). |
| Kupiec test | Unconditional regulatory backtest for VaR coverage. |
| Christoffersen-ind / cc | Conditional VaR backtests; cc is the joint coverage + independence test. |
| Regime-conditional VaR | $\widehat{\text{VaR}}_t$ built from the one-step-ahead filtered state forecast through the CHMM mixture CDF. |
| Walk-forward | Rolling-origin OoS evaluation across multiple folds. |
| Copula | Function that couples multiple marginals into a joint distribution; captures dependence only. |
| Sklar's theorem | Any joint CDF = (copula) ∘ (marginals). |
| Rank reordering (Iman-Conover) | A simulation trick that injects copula dependence while preserving each marginal exactly. |
| CRPS | Proper scoring rule for probabilistic forecasts. |
| Stationarity | Statistical properties don't change over time. |

---

## 11. Likely Questions to Be Ready For

- *"Why three operating points?"* Different consumers want different things. $K^\star = 3$ wins by held-out log-likelihood and BIC and is the parsimonious risk-management default. $K^\star = 6$ wins by AIC and by held-out KS on a strictly pre-2020 slice (held-out-clean) and is the synthetic-data default. $K = 18$ is the extended-state-resolution reference for kurtosis fidelity, used for the cross-ticker and regime-conditional VaR panels; it sits on a multi-objective rule that uses the OoS window and is therefore not held-out-clean. We are explicit that the body $K^\star = 6$ block is the held-out-clean default and $K = 18$ is a complementary reference.
- *"Why is the spectral identity not the contribution?"* Because it is folklore (Hamilton 1994, Krolzig 1997, Timmermann 2000). The substantive content is the *empirical effective-rank diagnostic* on the fitted $\hat{\mathbf{T}}$: a single non-unit eigenvalue carries ~94-97% of the lag-1 absolute-return ACF at every $K \geq 3$ in the sweep. That is what reframes the Rydén low-K failure as distributional rather than temporal, and that is the precise statement we defend.
- *"Isn't this overfitting?"* OoS KS at the held-out-clean $K^\star = 6$ panel is 76-79% in a regime where i.i.d. resampling tops out at ~90% by finite-sample power. The Gaussian negative control is rejected at 0% OoS, so the test is discriminating. The K = 2 replication shows ACF behaviour is robust to initialisation.
- *"Why not just use a deep generator?"* QuantGAN is in the appendix; the main paper benchmarks against parametric baselines because the contribution is interpretability + a closed-form mechanism (the spectral identity + effective-rank diagnostic), which deep generators cannot supply.
- *"Why does unpenalised CHMM-t overshoot kurtosis?"* It's a single-state ECM lower-bracket pinning artefact: only 2 of 18 states sit near the lower $\nu_k$ bracket. The penalised CHMM-t at $\lambda = 20$ adds an exponential $1/\nu_k$ shrinkage, and that row is what we present as the IS / OoS kurtosis headline (8.56 / 7.07 vs observed 7.68 / 5.29).
- *"Why is HSMM a co-headline if its OoS KS beats CHMM?"* Because HSMM-N's absolute-return ACF-MAE at $K^\star = 3$ is 0.0629, indistinguishable from the i.i.d. baseline level. The fitted Pareto sojourn concentrates probability mass on a single low-volatility state, so the volatility-clustering diagnostic is essentially lost. CHMM and HSMM are two complementary points on the KS / ACF trade-off curve, not a winner-loser pair.
- *"What about the OoS failures on the 30-ticker panel?"* Honest stationarity-scope limitation, not a model failure. 11/30 below 60% OoS KS at the IS-fixed univariate scale, concentrated in single-name regime introductions (LLY weight-loss-drug, UNH 2024 healthcare-policy compression). Quarterly refit shifts the median from 73.4% to 83.0% and reduces failures to 7/30. Failures are ticker-specific not sector-specific (ANOVA $F(9,20) = 0.44$, $p = 0.90$).
- *"What about W2 COVID and W4 2022-rate-hike-onset failing the walk-forward?"* Those are the two stress folds where the IS distribution genuinely does not span the realised regime. Every constant-across-$t$ generator under any refit cadence fails KS on those folds. The regime-conditional Christoffersen-cc still passes 19/24 across the rolling-origin walk-forward.
- *"What would scaling up look like?"* Skew-heavy-tailed emissions (skew-t, skew-Laplace), explicit-duration semi-Markov sojourns at higher $K$, untruncated regular vines or factor copulas for larger $d$, and an independent-decade validation (1994-2004 vs 2014-2024) are flagged as companion-paper directions.
