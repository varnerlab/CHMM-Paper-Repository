# Paper Summary: CHMM as a Synthetic-Data Generator for Equity Returns

A from-scratch walkthrough for prepping the meeting with the professor. Assumes no prior background in finance, hidden Markov models, or time-series statistics.

Full title: *"A Regime-Switching Continuous Hidden Markov Model as a Reference Synthetic-Data Generator for Equity Returns"*
Authors: Abdulrahman Alswaidan, Cade Jin, Jeffrey D. Varner.

---

## 1. The Big Picture in Two Sentences

We built a statistical model that takes a real history of daily stock returns and learns how to generate realistic *fake* (synthetic) return histories that look statistically indistinguishable from the real ones. The novelty is that a single relatively simple model (a continuous hidden Markov model, CHMM) reproduces all three of the well-known "stylized facts" of daily equity returns at the same time, something prior simple models could not do, and we explain mathematically *why* it works using the eigenvalue spectrum of the model's transition matrix.

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
The histogram of daily returns has fatter tails than a bell curve (Gaussian). Extreme moves (say, a 5% drop in one day) happen more often than a Gaussian would predict. Numerically this shows up as **excess kurtosis** above zero (Gaussian = 0; SPY in-sample = 7.68).

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

So before this paper, the field had a problem: no simple model reproduced all three stylized facts at once.

To be precise about what that claim means (because the professor will push on it): prior simple models can each *qualitatively* produce all three. GARCH(1,1)-t, MS-GARCH, and stochastic-volatility models all generate heavy tails, near-zero linear autocorrelation, and slow `|G|` ACF decay. The point is *quantitative*: none of them simultaneously passes a strict goodness-of-fit test on the marginal (e.g., KS) *and* matches the absolute-return ACF at the level needed for synthetic-data work. Table 1 makes this concrete: GARCH(1,1) sits at IS KS 25.9% with ACF-MAE 0.0484; MS-GARCH at 27.7% with 0.0367; the bootstrap is at 99.9% KS but ACF-MAE 0.0628 (it destroys clustering). The CHMM is the only row at 93%+ KS and ~0.05 ACF-MAE simultaneously. Bulla and Bulla (2006) did achieve this joint fit, but only by leaving the standard Markov scaffold for an explicit-duration semi-Markov model, which is the "added complexity" we avoid.

So the defensible version of the claim is: no simple *Markovian* model previously passed both diagnostics jointly inside the standard HMM scaffold; semi-Markov fixes existed but added machinery. Combined with the spectral identity in §5.3 (which explains *why* moderate K works and reframes the Rydén negative result as a rank statement on T), that is the contribution.

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
- **CHMM-t (Student-t)**: $b_k(x) = t_{\nu_k}(x;\,\mu_k,\,\sigma_k)$. Three parameters per state.
- **CHMM-L (Laplace)**: $b_k(x) = \mathrm{Laplace}(x;\,\mu_k,\,b_k)$. Two parameters per state.
- **CHMM-GED (Generalized Error Distribution, also called the generalized Gaussian)**: $b_k(x) = \mathrm{GED}(x;\,\mu_k,\,\alpha_k,\,p_k)$. Three parameters per state. The GED nests Gaussian at $p = 2$ and Laplace at $p = 1$, so per-state $p_k$ is the structural analog of CHMM-t's $\nu_k$ on the Gaussian-to-Laplace shape axis.

#### Per-variant parameter cheat sheet

What each per-state parameter does, and how it is updated in the M-step:

| Variant | Parameter | Role | M-step update |
|---|---|---|---|
| **CHMM-N** | $\mu_k$ | location (mean) of state $k$'s Gaussian | closed form: $\gamma$-weighted sample mean |
|  | $\sigma_k^2$ | variance (spread); fully determines tails for a Gaussian | closed form: $\gamma$-weighted sample variance |
| **CHMM-t** | $\mu_k$ | location | closed form given $\nu_k$ ($u$-weighted mean, where $u_{t,k}$ is the latent precision from eq. for $t$) |
|  | $\sigma_k$ | scale (not variance; for a $t$ the variance is $\nu_k \sigma_k^2/(\nu_k - 2)$ when $\nu_k > 2$) | closed form given $\nu_k$ |
|  | $\nu_k$ | degrees of freedom; controls tail heaviness. $\nu_k \to \infty$ recovers Gaussian; $\nu_k \to 2$ gives infinite variance and very heavy tails. **Bracket: $[2.1, 50]$.** | 1-D golden-section search on the conditional $Q$-function (ECM step) |
| **CHMM-L** | $\mu_k$ | location (the Laplace MLE for location is the median, not the mean) | closed form: $\gamma$-weighted median |
|  | $b_k$ | scale; the Laplace tail is $\propto e^{-|x-\mu|/b}$, fatter than Gaussian but with no shape parameter | closed form: $\gamma$-weighted mean absolute deviation around $\mu_k$ |
| **CHMM-GED** | $\mu_k$ | location | bracketed golden-section minimizing $\sum_t \gamma_t(k)\,|O_t - \mu|^{p_k}$ over $[\hat\mu_k - 5\alpha_k,\,\hat\mu_k + 5\alpha_k]$ |
|  | $\alpha_k$ | scale | closed form given $\mu_k, p_k$: $\alpha_k = \big[(p_k/W_k) \sum_t \gamma_t(k)\,|O_t - \mu_k|^{p_k}\big]^{1/p_k}$, with $W_k = \sum_t \gamma_t(k)$ |
|  | $p_k$ | **shape parameter on the Gaussian-Laplace axis**: $p_k = 2$ gives Gaussian, $p_k = 1$ gives Laplace, $p_k < 1$ gives very-heavy "spikier" tails, $p_k > 2$ gives sub-Gaussian platykurtic tails. **Bracket: $[0.5, 3.0]$.** | bracketed golden-section maximizing $\sum_t \gamma_t(k) \log b_k(O_t; \mu_k, \alpha_k, p)$ |

Plus the shared parameters that every variant carries: the $K \times K$ transition matrix $\mathbf{T}$ ($K(K-1)$ free parameters, since rows sum to 1) and the initial distribution $\boldsymbol\pi$ ($K - 1$ free parameters). At $K = 18$ that is 306 transition parameters + 17 initial-distribution parameters. The emission block adds $2K$ for CHMM-N and CHMM-L, $3K$ for CHMM-t and CHMM-GED.

The four variants land at four different points on the "how heavy are the tails" axis (Section 7.3 below). CHMM-GED is the most flexible: instead of *picking* a shape (Gaussian, Laplace, or Student-t), it lets each state's $p_k$ adapt to what that state's data wants. Empirically on SPY at $K = 18$, the $\hat p_k$ values split bimodally into 13 Gaussian-like states ($\hat p_k \approx 2$) and 4 Laplace-like states ($\hat p_k \in [0.86, 1.24]$), with the Laplace-like cluster concentrated in the high-volatility / crash tail of the state ordering. This is the data-driven analog of a hand-classified Gaussian-bulk / Laplace-tail hybrid, and it is structural rather than seed-dependent (replicates across 10 seeds and across all six SPY-member tickers).

### 5.2 How we train it: Baum-Welch (EM)

Baum-Welch is the standard algorithm for fitting HMMs. It is an instance of the EM (Expectation Maximization) algorithm. The intuition:

- We have observed data (returns) but not the hidden states.
- **E-step**: given current parameter estimates, compute the posterior probability of being in each state at each time, using forward-backward recursion (a dynamic programming algorithm).
- **M-step**: given those posterior probabilities, update the model parameters (transitions + emission parameters) by weighted maximum likelihood.

Iterate E and M until the log-likelihood stops moving (we use a tolerance of $10^{-4}$, typically converges in 20 to 40 iterations).

Two specific choices matter here:

1. **Quantile-based initialization.** Instead of starting the EM from random parameters (the 1990s default), we sort the observed returns and split them into K equal-size chunks; each state is initialized from its corresponding chunk. This avoids the "degenerate local optima" problem that contributed to Rydén et al.'s pessimistic conclusion.

2. **For CHMM-t and CHMM-GED**, some emission parameters are not closed-form. CHMM-t uses a 1-D golden-section search for $\nu_k$ on the conditional $Q$-function, an Expectation Conditional Maximization (ECM) step (Peel and McLachlan 2000, Liu and Rubin 1995). CHMM-GED uses a three-stage ECM per state: bracketed golden-section for $\mu_k$, closed-form $\alpha_k$, then bracketed golden-section for $p_k$. Each is a partial maximization on a compact bracket, so EM monotonicity is preserved.

### 5.3 The theoretical core: spectral identity for the absolute-return ACF

This is the central technical contribution. We *prove* (in closed form) that for any stationary CHMM, the autocorrelation of `|G_t|` at lag $\tau$ is:

$$\rho_{|G|}(\tau) = \sum_{k=2}^{K} w_k\, \lambda_k^{\tau}$$

where $\lambda_2, \ldots, \lambda_K$ are the non-unit eigenvalues of the transition matrix $\mathbf{T}$ and $w_k$ are weights determined by the per-state moments and stationary distribution.

In plain English: the ACF is a *mixture* of geometric decays at the various eigenvalues of $\mathbf{T}$.

This identity reframes the Rydén et al. negative result. Their failure was not that "HMMs cannot do slow ACF decay"; it was that "an HMM with only $K = 2$ states has only one non-unit eigenvalue, so the ACF can only be a single exponential, and the binding constraint at $K = 2$ is actually the marginal (only two mixture components is not enough to match the heavy tail)." At $K \geq 3$ the model gets multiple non-unit eigenvalues, and the temporal constraint (slow ACF) and distributional constraint (heavy tail) decouple. The Rydén failure becomes a *rank statement on $\mathbf{T}$*, not a fundamental limit on HMMs.

This is the "why" behind why moderate $K$ (we use $K = 18$) works.

---

## 6. The Data

- **Single-asset main study**: SPY (the SPDR S&P 500 ETF, which tracks the broad U.S. stock market).
  - In-sample (IS): Jan 3, 2014 to Jan 3, 2024, ten years, $T = 2{,}516$ trading days.
  - Out-of-sample (OoS): Jan 4, 2024 to Apr 20, 2026, $T = 572$ days.
- **Cross-ticker generalization**: NVDA (NVIDIA), JNJ (Johnson & Johnson), JPM (JPMorgan Chase), AAPL (Apple), QQQ (Invesco Nasdaq-100 ETF). Each fit independently.
- **Cross-asset dependence study**: all six tickers above, modeled jointly.

We work with the *annualized excess log return* $G_t = (1/\Delta t) \ln(P_t / P_{t-1}) - r_f$ with $\Delta t = 1/252$ (252 trading days/year) and risk-free rate $r_f = 0$.

The IS / OoS split is critical: it tests whether the model trained on the past can produce data that still matches the future. This is how you guard against overfitting.

---

## 7. The Empirical Tests (and What They Mean)

### 7.1 The four core metrics

We simulate $P = 1{,}000$ independent paths from each fitted model and score them on:

1. **Kolmogorov-Smirnov (KS) test pass rate.** A statistical test that asks: "is the simulated distribution of returns the same as the observed distribution?" We run it on each of the 1,000 paths and report the percentage that pass at $\alpha = 0.05$. A truly correct generator should pass ~95% of the time; failing means the *marginal distribution* (the histogram of returns) is wrong.
2. **Mean simulated excess kurtosis.** Direct measure of tail heaviness. Compare simulated mean to observed (7.68 IS, 5.29 OoS). This is a sanity check on tails specifically.
3. **ACF-MAE on absolute returns.** The mean absolute error between the observed ACF of `|G|` and the simulated ACF, averaged over 252 lags. This is the *direct diagnostic* for volatility clustering, the thing Rydén et al. claimed HMMs could not match.
4. **CRPS (Continuous Ranked Probability Score).** A "proper scoring rule" measuring how well the simulated ensemble forecasts the OoS series. Lower is better. Used because KS alone is not a proper scoring rule, and we wanted to make sure the KS finding is not an artifact.

### 7.2 The benchmark generators (what we compare against)

- **i.i.d. bootstrap** (Politis-Romano stationary bootstrap): the non-parametric distributional ceiling.
- **Gaussian i.i.d.** (draws from $\mathcal{N}(\hat\mu, \hat\sigma^2)$): the negative control. Should fail KS dramatically.
- **Laplace i.i.d.**: heavier-tailed i.i.d. comparator.
- **GARCH(1,1)**: the workhorse volatility-clustering baseline.
- **GARCH(1,1)-t**: GARCH with Student-t innovations, heavier tails.
- **MS-GARCH** (Markov-switching GARCH, Haas et al. 2004): the closest peer to CHMM among classical baselines.

Plus the four CHMM variants at $K = 18$ and a CHMM-N reference at $K^\star = 3$.

### 7.3 The headline result (Table 1 in the paper)

| Generator | IS KS | OoS KS | IS Kurt | ACF-MAE |
|---|---|---|---|---|
| Observed | -- | -- | 7.68 | -- |
| Bootstrap | 99.7% | 92.1% | 7.24 | 0.0628 |
| Gaussian iid | 0.0% | 1.0% | -0.01 | 0.0627 |
| GARCH(1,1) | 23.4% | 60.8% | 7.06 | 0.0485 |
| MS-GARCH | 27.7% | 38.7% | 4.73 | 0.0367 |
| **CHMM-N (K=18)** | **94.1%** | **81.8%** | 5.04 | 0.0509 |
| **CHMM-t (K=18)** | **95.6%** | **85.7%** | 14.35 | 0.0549 |
| **CHMM-L (K=18)** | **93.6%** | **80.8%** | **6.63** | 0.0567 |
| **CHMM-GED (K=18)** | **95.2%** | **84.3%** | 5.15 | 0.0548 |

**The point of this table:** no single benchmark wins on everything. The bootstrap wins on marginals but is the worst on temporal fidelity (it destroys volatility clustering). GARCH is best on temporal fidelity (low ACF-MAE) but fails distributional KS catastrophically. **The CHMM family is the only block that sits near the top on both axes simultaneously.** That is the paper's headline finding.

The four CHMM variants land at four different places on the kurtosis axis:
- CHMM-N undershoots (5.0 vs 7.7).
- CHMM-L matches almost perfectly (6.6).
- CHMM-t overshoots (14.4) but supplies per-state heavy tails for cases where you want the option to draw extreme tail events.
- CHMM-GED sits adaptively at 5.2; instead of fixing the shape, each state's $\hat p_k$ adapts. On SPY at $K = 18$ the partition splits bimodally into 13 Gaussian-like and 4 Laplace-like states (heavy-shape states concentrate in the high-volatility tail). CHMM-GED also attains the highest IS KS pass rate among the four (95.2%) at the same parameter count as CHMM-t.

### 7.4 Robustness checks

- **Multi-seed Monte Carlo**: 10 different random seeds. CHMM-N OoS KS = $82.6 \pm 1.79\%$, CHMM-t $85.6 \pm 1.92\%$, CHMM-L $80.8 \pm 3.59\%$, CHMM-GED $83.2 \pm 2.65\%$. The seed-to-seed std is small relative to between-model gaps, so the results are not lucky seeds. CHMM-GED's $\hat p_k$ partition is also seed-invariant: every one of the 10 seeds yields the identical bulk/tail split.
- **KS power-calibration positive control**: an i.i.d. resample of the IS series only passes the OoS KS at 90%, not 100%, because $T_{\text{OoS}} = 572$ is finite. So the CHMM's 79 to 86% pass rates are *near the test-power ceiling*, not artifacts of low power.
- **K-sweep**: we tried $K \in \{3, 6, 9, 12, 15, 18, 21\}$. ACF-MAE is essentially flat across all $K \geq 3$ (consistent with the spectral identity), while KS pass rate rises with $K$ until plateauing around 18.
- **State-count selection**: held-out log-likelihood and BIC pick $K^\star = 3$. We report two operating points:
  - $K = 3$: methodologically conservative, best by held-out likelihood.
  - $K = 18$: best by tail-fidelity / KS / kurtosis, the "synthetic data" operating point.

---

## 8. Downstream / Application Tests

These are tests that go beyond statistical fidelity and ask: "is this model actually useful for the things people use generators for?"

### 8.1 Value-at-Risk (VaR) and Expected Shortfall (ES) backtesting

VaR and ES are the canonical risk-management diagnostics. VaR at level $\alpha = 1\%$ is the loss you should not exceed more than 1% of the time. ES at level $\alpha = 1\%$ is the average loss conditional on being in the worst 1% of days. Regulators require banks to backtest their VaR models.

A synthetic generator passes if its envelope (5% to 95% across simulated paths) brackets the observed historical VaR / ES.

**Result**: All three CHMM variants bracket the observed VaR and ES at both 1% and 5% on both IS and OoS windows. CHMM envelopes are about 1.7x tighter than GARCH's. All three pass the **Kupiec unconditional coverage test** (a formal regulatory backtest, $\chi^2_1$ critical value 3.84) cleanly at both levels. This is the "yes, this generator is fit for risk-management use" check.

### 8.2 Cross-ticker generalization (Pipeline A)

We refit the model independently on five additional tickers (NVDA, JNJ, JPM, AAPL, QQQ) at $K = 18$. The point: does the method work on individual stocks too, or only on the broad-market index?

Result: IS KS is very high on every ticker (95 to 99%). OoS, JNJ, AAPL, and QQQ generalize well (90 to 95%), but NVDA (57%) and JPM (53%) degrade substantially. We diagnose this honestly as a *stationarity-scope limitation*: NVDA's 2024 to 2026 was an AI-driven boom unlike anything in the IS window, and JPM's window included a financial sector rate-repricing cycle. The IS-fixed model cannot anticipate regime changes that lie outside its training data. Operational fix: refit periodically (quarterly cadence is standard).

### 8.3 Cross-asset dependence (Pipeline B): the Student-t copula

A separate problem from "model one stock well": if you want to simulate a *portfolio*, the simulated stocks need to be correlated with each other in the right way (when SPY drops, AAPL also drops, on average). Capturing the *cross-sectional dependence* is its own challenge.

We use **Sklar's theorem**: any joint distribution can be decomposed into (marginals) + (a copula that captures dependence). So we can keep the per-asset CHMM marginals (which we already validated) and just fit a copula on top.

Pipeline:
1. Fit CHMM independently on each asset (Pipeline A output).
2. Compute ranks of the observed returns (probability integral transform).
3. Estimate the copula correlation matrix via Kendall's tau inversion ($\rho_{ij} = \sin(\pi \tau_{ij}/2)$).
4. Fit the degrees-of-freedom $\nu$ by profile maximum likelihood; we find $\nu^\star = 6$.
5. Simulate by **rank reordering** (Iman-Conover): draw paths from each marginal CHMM, draw a sample from the copula, reorder each marginal sample so its ranks match the copula. This *exactly preserves* each marginal while injecting the cross-asset dependence.

We compare against:
- **Single Index Model (SIM)**: $G_j = \alpha_j + \beta_j G_{\text{market}} + \epsilon_j$. Standard but distorts each non-market marginal.
- **Gaussian copula**: same construction but with a Gaussian copula (no tail dependence).

**Result**: Off-diagonal correlation MAE on the six-asset universe IS is **0.027 (Student-t copula)**, vs 0.031 (Gaussian copula), vs 0.076 (SIM). The Student-t copula wins on every metric.

OoS off-diag MAE jumps to 0.208, again attributable to a stationarity break (concentrated in JNJ-equity pairs in the 2024 to 2026 window), not a methodology failure.

### 8.4 CRPS (proper scoring rule)

CHMM-N at $K = 18$ has the lowest mean OoS CRPS in the panel (1.0384). CHMM-t, CHMM-L, and Laplace-iid are within 0.002 and statistically tied (Diebold-Mariano test). Significantly better than Gaussian iid. **Point**: the headline KS finding is corroborated by a proper scoring rule, not an artifact of a non-proper metric.

---

## 9. What Are the Conclusions?

Stated plainly:

1. **A standard continuous HMM, trained by Baum-Welch with quantile-based initialization, at moderate K (≈ 18 states), reproduces all three stylized facts of equity returns simultaneously.** Prior work claimed this was impossible without more complex semi-Markov machinery; we show it works inside the standard scaffold once you stop using K = 2 or 3 states and stop using random initialization.

2. **The mechanism is spectral.** The absolute-return ACF is a closed-form mixture of geometric decays at the non-unit eigenvalues of the transition matrix. K = 2 fails because the model only has one non-unit eigenvalue and only two marginal mixture components. K ≥ 3 makes both axes flexible enough.

3. **Four emission flavors give a clean tail-heaviness slider** (CHMM-N undershoots, CHMM-L matches cleanly, CHMM-t overshoots and is per-state heavy-tailed, CHMM-GED lets each state pick its own shape on the Gaussian-Laplace axis via $p_k$ and discovers a bulk/tail partition on its own). Same EM scaffold; only the M-step changes.

4. **The model passes downstream risk-management checks.** VaR / ES envelopes bracket observed values cleanly on both IS and OoS; Kupiec test passes; CRPS is competitive with the best benchmark.

5. **Cross-asset extension is clean.** Plug in a Student-t copula on top of the per-asset CHMM marginals, get cross-asset off-diagonal correlation MAE of 0.027 (vs 0.076 for Single Index Model on the same marginals).

6. **OoS degradation on individual stocks (NVDA, JPM) is honest.** It is a stationarity-scope artifact, not a model failure; the recommended fix is periodic refit, which is standard practice for time-series generators.

7. **Practical contribution**: this is a single, reproducible (Julia package `CHMM-Model.jl`, MIT license), interpretable model that lives in the joint-fit corner where prior baselines could not. The earlier work (Alswaidan 2026 hybrid) achieved a similar goal via *discrete* quantile binning + Poisson jumps; this paper shows the same outcome through a continuous emission scaffold and explains *why* it works analytically.

---

## 10. Vocabulary Cheat Sheet (for the meeting)

| Term | Plain meaning |
|---|---|
| HMM (hidden Markov model) | A model with unobserved states that evolve via a Markov chain, and observations that depend on the current state. |
| Continuous HMM (CHMM) | An HMM where the observations are real-valued, not discrete bins. |
| Emission density | The probability distribution of the observation given the hidden state. |
| Transition matrix $\mathbf{T}$ | The $K \times K$ matrix of state-to-state transition probabilities. |
| Stationary distribution $\bar\pi$ | The long-run fraction of time the chain spends in each state. |
| Baum-Welch | Standard EM algorithm to fit HMMs. |
| EM (Expectation-Maximization) | Iterative algorithm: alternate computing posteriors (E) and updating parameters (M). |
| ECM | EM where the M-step is broken into multiple conditional steps (used for $\nu_k$). |
| KS (Kolmogorov-Smirnov) test | Two-sample test for whether two empirical distributions are the same. |
| ACF (autocorrelation function) | Correlation of a time series with its own lagged values. |
| Stylized facts | Empirical regularities of financial returns (heavy tails, no linear autocorr, slow `|return|` ACF). |
| GARCH | Econometric volatility-clustering model: variance of today's return depends on yesterday's variance and yesterday's squared return. |
| VaR / ES | Tail-loss risk measures (Value-at-Risk, Expected Shortfall). |
| Kupiec test | Regulatory backtest for VaR coverage. |
| Copula | Function that couples multiple marginals into a joint distribution; captures dependence only. |
| Sklar's theorem | Any joint CDF = (copula) ∘ (marginals). |
| Rank reordering (Iman-Conover) | A simulation trick that injects copula dependence while preserving each marginal exactly. |
| CRPS | Proper scoring rule for probabilistic forecasts. |
| Stationarity | Statistical properties don't change over time (the assumption financial models routinely violate over long enough horizons). |

---

## 11. Likely Questions to Be Ready For

- *"Why K = 18 specifically?"* It sits at the top of the IS KS plateau and inside the CAIC-minimizing band. Held-out likelihood would prefer K = 3, so we explicitly report both as operating points: K = 3 if you prioritize parsimony, K = 18 if you prioritize tail and KS fidelity.
- *"Isn't this overfitting?"* OoS KS of 84.2% sits just below the test-power ceiling of ~90% (length-matched). The Gaussian negative control is rejected at 0% OoS, so the test is discriminating, not generous.
- *"Why not just use a deep generator?"* We do include QuantGAN in the appendix; the main paper benchmarks against parametric baselines because the contribution is interpretability + a closed-form mechanism (the spectral identity), which deep generators cannot supply.
- *"Why does CHMM-t overshoot on kurtosis?"* It's a single-state artifact, only 2 of 18 states sit near the lower $\nu$ bracket. A mild $1/\nu$ shrinkage prior (rate 20) brings simulated kurtosis to ~8 with a 1pp KS cost. We report this in the appendix.
- *"What about NVDA and JPM?"* Honest stationarity-scope limitation, not model failure. Pattern persists at every K. The fix is periodic refit (quarterly), standard practice in the literature (Pesaran-Timmermann 2007).
- *"What would scaling up look like?"* Skew-heavy-tailed emissions (skew-t, skew-Laplace), explicit-duration semi-Markov sojourns, regime-conditional VaR, and vine or factor copulas for larger universes are all flagged as companion-paper directions.
