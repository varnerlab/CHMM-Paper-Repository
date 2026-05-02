# CHMM Paper, Proof-Prep Summary

Last updated 2026-05-01 by automated review pass against arXiv:2603.10202 (the prior Hybrid-HMM paper by the same first author). Updated to add detailed method explanations and per-method "how it differs" notes.

This document is the single brief a non-specialist reviewer can read before opening the PDF. It records (a) what the paper claims and how to read it cold, (b) how the paper compares to the precursor Hybrid-HMM paper, (c) the acronym key, (d) **the model and each emission family explained from scratch, with the way each differs from the others called out explicitly**, (e) **the estimation machinery (EM, Baum-Welch, ECM, quantile init) explained**, (f) **the spectral mechanism in plain language**, (g) **each benchmark generator and how it differs from the CHMM**, (h) **the regime-conditional VaR construction explained step by step**, (i) the test menu with what each number means and how the tests differ from one another, (j) the model's position in the literature, (k) the pre-arXiv cleanup checklist, (l) the two analysis pipelines and the data timeline that feeds them. Section refs use the section-file basenames in `sections/`.

---

## 0. One-Paragraph Synopsis (for the reviewer who opens this file cold)

The paper trains a continuous Hidden Markov Model (CHMM) by Baum-Welch as a **synthetic-data generator for daily US-equity returns**. "Synthetic-data generator" means: given an observed return series, fit a model and then draw long simulated paths that look statistically like the original (same heavy tails, same volatility-clustering signature, same VaR breach behavior), so the paths can be used downstream in stress tests, regulatory backtests, copula composition, and privacy-preserving data sharing. The headline empirical claim is that the CHMM reproduces the three symmetric Cont-2001 stylized facts (heavy-tailed marginals, near-zero linear ACF, slow absolute-return ACF) at moderate state counts, on par with GARCH(1,1) on the volatility-clustering axis where simple HMMs are usually dismissed. The headline theoretical claim is that the textbook bilinear-ACF identity for HMMs implies a **rank constraint on the deflated transition matrix that is non-binding at K ≥ 3 on equity-return data**, which mathematically explains why the famous Rydén-Teräsvirta-Åsbrink (1998) low-K HMM failure was a low-K artefact and not an architectural ceiling on HMMs. The headline risk-management contribution is a **regime-conditional Value-at-Risk** that propagates the one-step-ahead state forecast through the predictive mixture and passes the Christoffersen joint conditional-coverage test at α = 0.05 across emission families and walk-forward folds (with a documented power caveat at α = 0.01). Scope: daily US equities; symmetric stylized facts only (leverage and gain-loss asymmetry are out-of-scope under symmetric per-state emissions); a non-equity stress test on GLD/SLV is included as a documented negative result (static-fit OoS KS collapses to 0%; periodic refit is the proposed remedy).

---

## 1. arXiv-Readiness Verdict

**Status: ready** with a short pre-submission punch list (see Section 11).

Build evidence: 112-page PDF, clean compile, zero undefined references or labels, zero `[CITE]/[TBD]/TODO` placeholders, 102 figure PDFs all 1-to-1 mapped to `\includegraphics`, 64 tables, 1 theorem with full proof, 4 propositions, 2 assumptions. Reproducibility scaffold complete: deterministic seed root 20260420 with documented sub-seed rule, Julia ≥ 1.12 with pinned `Manifest.toml`, R 4.6 + `renv` lockfile for the MSGARCH reference, public companion repos linked in the conclusion.

Two prose em-dash violations were patched during this review (sensitivity\_appendix.tex lines 185, 1002). Remaining LaTeX warnings (8 overfull hboxes, 19 `[h]→[ht]` automatic float promotions, hyperref bookmark-charset notes) are cosmetic and not arXiv-blocking.

---

## 2. Comparison vs. arXiv:2603.10202 (Alswaidan and Varner, "Hybrid HMM")

The Hybrid-HMM paper is the precursor on the same problem (synthetic generation of US-equity returns under stylized-fact constraints). Where it sits relative to the present work:

| Axis | Hybrid-HMM (2603.10202) | CHMM (this paper) |
|---|---|---|
| State construction | Discretized Laplace quantiles, Poisson jump-duration | Continuous emissions, four families (Gaussian, Student-t, Laplace, GED) |
| Estimator | Direct transition counting (bypasses Baum-Welch) | Full EM/ECM via Baum-Welch forward-backward |
| Universe | 424 US equities, 10 years daily | SPY 2014-2026, 30-ticker sector panel, 60-ticker n=6 expansion, 6-asset copula, CRSP cross-decade 1994-2006, GLD/SLV stress |
| Stylized facts | Heavy tails, low linear ACF, persistent vol clustering | Same three symmetric Cont (2001) facts; explicit out-of-scope statement on leverage and gain-loss asymmetry |
| Volatility-clustering parity | Inferior to GARCH(1,1) | On par with GARCH(1,1) on the absolute-return ACF axis at moderate K |
| Distribution-test parity | Below GARCH on tail tests | KS / AD pass rates documented panel-wide; HSMM ML matches or slightly exceeds CHMM on raw distributional fidelity, with the gap quantified |
| Risk back-test | Not run | Christoffersen joint conditional-coverage VaR test; six-fold rolling-origin walk-forward; quarterly-refit deployment recipe |
| Theoretical contribution | Empirical | Spectral mechanism: the textbook bilinear-ACF identity is recast as an effective-rank statement on the deflated transition matrix, with proof in supplementary |
| Code | Not specified in abstract | Two public repos (CHMM-paper, CHMM-Model), Julia and R reproducer with seed control |

Where the present paper is **strictly stronger**: estimator is principled (likelihood-monotone EM/ECM rather than counting), the spectral identity provides a falsifiable rank diagnostic that explains the Rydén low-K failure, and the risk-management story (conditional-VaR coverage, refit-cadence sweep) is a new dimension absent from the precursor. Reproducibility scaffolding is more explicit (deterministic seed tree, two-language replication).

Where the precursor is **broader**: 424-asset universe vs. 30-60 ticker panel here. The present paper trades breadth for depth (more tests, formal theory, conditional-VaR coverage, periodic-refit recipe). This is the intended positioning, stated in the abstract: "structural use cases (regime-conditional VaR, copula composition, parametric privacy) where multi-state regime-switching is required."

**Net assessment: the present paper is at least as good and arguably stronger on methodology and risk management; the precursor remains stronger on cross-sectional breadth.** The two are complementary rather than competing.

---

## 3. Acronym Key

Listed in approximate order of first use. Every acronym in the paper.

**Models and emission families.** CHMM continuous hidden Markov model. CHMM-N, CHMM-t, CHMM-L, CHMM-GED Gaussian, Student-t, Laplace, generalized-error-distribution emission variants. HMM hidden Markov model. HSMM hidden semi-Markov model. SM-CHMM Viterbi-AR(1) plug-in semi-Markov foil. GARCH generalized autoregressive conditional heteroskedasticity. EGARCH exponential GARCH. GJR-GARCH Glosten-Jagannathan-Runkle GARCH. MS-GARCH (also MSGARCH) Markov-switching GARCH. MSSV Markov-switching stochastic volatility. MSM Markov-switching multifractal. SV stochastic volatility. JD jump diffusion. HAR-RV heterogeneous autoregressive realized variance. SIM single-index model. GAN generative adversarial network. WGAN Wasserstein GAN. TCN temporal convolutional network.

**Estimation.** EM expectation maximization. ECM expectation conditional maximization. CM conditional maximization. MLE maximum likelihood estimator. BIC, AIC, HQC, CAIC standard information criteria. NW Newey-West. HAC heteroskedasticity and autocorrelation consistent.

**Statistical tests.** KS Kolmogorov-Smirnov. AD Anderson-Darling. LR likelihood ratio. LR\_uc, LR\_ind, LR\_cc unconditional, independence, conditional-coverage variants. DQ Engle-Manganelli dynamic-quantile. DM Diebold-Mariano. CRPS continuous ranked probability score. ANOVA analysis of variance. FDR false-discovery rate. BH Benjamini-Hochberg.

**Risk metrics.** VaR value at risk. ES expected shortfall.

**Data and series.** ACF autocorrelation function. MAE mean absolute error. MAD mean absolute deviation. CDF, PDF, PMF distribution / density / mass functions. RV realized variance. IS in-sample. OoS out-of-sample. CV cross-validation. CI confidence interval. IQR interquartile range.

**Universes / instruments.** SPY SPDR S&P 500 ETF. QQQ Invesco Nasdaq-100 ETF. GLD SPDR Gold Trust. SLV iShares Silver Trust. NVDA, JNJ, JPM, AAPL, MSFT, etc. listed equities. ETF exchange-traded fund. GICS Global Industry Classification Standard. CRSP Center for Research in Security Prices. IEX Investors Exchange.

**Software.** SDK software development kit. API application programming interface. PSD positive semidefinite. OLS ordinary least squares. TikZ LaTeX graphics package.

---

## 4. The Model, From the Ground Up

### 4.1 What an HMM is, in three sentences

A **Hidden Markov Model** has two layers: a hidden discrete state $s_t \in \{1, \dots, K\}$ that evolves Markov-ly through time according to a $K \times K$ transition matrix $\mathbf T$ (so $\mathbf T_{ij} = \Pr(s_t = j \mid s_{t-1} = i)$), and an observed series $G_t$ whose distribution depends only on the current state ($G_t \mid s_t = k \sim f_k(\cdot; \boldsymbol\theta_k)$). The state is **hidden**: the analyst sees only $G_t$, not $s_t$, and has to infer the state distribution from data. The state is **Markov**: tomorrow's state depends only on today's state, not on any earlier state, which is what makes the forward-backward inference tractable.

In this paper $G_t$ is the daily annualised excess log return on a US equity, computed as $G_t = (1/\Delta t) \ln(P_t / P_{t-1}) - r_f$ with $\Delta t = 1/252$ and $r_f = 0$, on session VWAP prices ([sections/model.tex:4-9](sections/model.tex#L4-L9)).

### 4.2 What "continuous" means in CHMM (vs. the precursor discrete HMM)

The "C" in **CHMM** is for **continuous emissions**. The state is still discrete (integer-valued $s_t$), but each per-state emission density $f_k$ is a continuous distribution on $\mathbb R$ (the daily return is a real number). This is the key difference from the precursor "Hybrid-HMM" of Alswaidan-Varner 2603.10202, where each state emitted a discretized return drawn from a Laplace-quantile bin (so the simulated return was constrained to a finite set of values). Continuous emissions: (i) eliminate the discretization-grid hyperparameter; (ii) make the density-fit objective principled (likelihood is well-defined); (iii) let downstream constructions like the regime-conditional VaR (see §8 below) use the per-state CDF $F_k$ to take exact quantiles instead of binned approximations.

### 4.3 What is fitted, exactly

The full parameter vector estimated from data is $(\mathbf T, \boldsymbol\pi, \boldsymbol\theta_{1:K})$:
- $\mathbf T \in \mathbb R^{K \times K}$ is the transition matrix; row sums are 1 (each row is a probability distribution over next-state conditional on current state).
- $\boldsymbol\pi \in \Delta^{K-1}$ is the initial-state distribution (probability of starting in each state at $t = 0$). Under irreducibility and aperiodicity of $\mathbf T$, the unique stationary distribution $\bar{\boldsymbol\pi}$ satisfies $\bar{\boldsymbol\pi} = \bar{\boldsymbol\pi} \mathbf T$ and the observed-marginal density is the mixture $f(x) = \sum_k \bar\pi_k f_k(x; \boldsymbol\theta_k)$ ([sections/model.tex:14-19](sections/model.tex#L14-L19)).
- $\boldsymbol\theta_k$ is the family-specific parameter vector for state $k$'s emission density (location, scale, optionally shape).

$K$ is fixed by the analyst before fitting. The paper selects $K^\star = 3$ as the body operating point by held-out per-observation log-likelihood and held-out KS under rolling-origin cross-validation on the strictly pre-2020 slice ([sections/results.tex:9-12](sections/results.tex#L9-L12)). $K = 18$ is reported as a kurtosis-fidelity sensitivity reference.

### 4.4 The four emission families, and how each differs

All four families share the same forward-backward scaffold and quantile-based initialization. The **only architectural difference between them is the M-step** (which family-specific weighted MLE is run inside each EM iteration). Definitions and detailed comparison:

#### 4.4.1 CHMM-N (Gaussian)
- Density: $f_k(x) = \mathcal N(x; \mu_k, \sigma_k^2)$.
- Per-state parameters: 2 (location $\mu_k$, scale $\sigma_k$).
- Tail behavior: light, exponential-quadratic decay. Excess kurtosis of a single Gaussian = 0; excess kurtosis of a $K$-mixture is bounded by the variance of $\mu_k$'s relative to the variances $\sigma_k^2$. On SPY at $K = 3$ this maxes out around 3.83 against observed 7.68, so CHMM-N **cannot match the marginal kurtosis target on its own at low $K$**; the gap is what motivates the heavy-tailed variants below.
- M-step: closed-form, the textbook Baum-Welch result $\mu_k \leftarrow \sum_t \gamma_t(k) O_t / \sum_t \gamma_t(k)$ and $\sigma_k^2 \leftarrow \sum_t \gamma_t(k)(O_t - \mu_k)^2 / \sum_t \gamma_t(k)$ where $\gamma_t(k) = \Pr(s_t = k \mid \mathcal F_T)$ is the smoothed posterior. Fastest, most familiar.

#### 4.4.2 CHMM-t (Student-t)
- Density: $f_k(x) = t_{\nu_k}(x; \mu_k, \sigma_k)$.
- Per-state parameters: 3 (location $\mu_k$, scale $\sigma_k$, degrees of freedom $\nu_k \in [2.1, 50]$).
- Tail behavior: power-law. As $\nu_k \to \infty$ the Student-$t$ converges to the Gaussian; as $\nu_k \to 2$ the variance diverges. Kurtosis is finite only for $\nu > 4$. Heavy enough that even at $K = 3$ the simulated kurtosis can hit or overshoot the observed 7.68; the body uses an exponential $1/\nu_k$ shrinkage penalty at rate $\lambda = 20$ to prevent the per-state $\nu_k$ ECM from pinning at the lower bracket on small-sample states.
- M-step: **ECM** (no closed-form joint M-step). Conditional on $\nu_k$, the location and scale updates are weighted versions of the Gaussian formulas with weights $u_{t,k} = (\nu_k + 1) / (\nu_k + ((O_t - \mu_k)/\sigma_k)^2)$ (latent-precision representation, [sections/estimation.tex:28-39](sections/estimation.tex#L28-L39)). Then $\nu_k$ is updated by golden-section search on the per-state $Q$-function. Two-block CM step preserves the EM monotonicity guarantee.
- **How it differs from CHMM-N**: extra shape parameter; heavier tails; needs a one-dimensional bracketed search inside each iteration; more sensitive to the lambda shrinkage hyperparameter. The shared-$\nu$ ablation collapses all $\nu_k$ to a single $\nu$ across states (the standard one-parameter Student-$t$ HMM in the time-series literature) and gets the heavy-tail target without the penalty hyperparameter ([sections/discussion.tex:7](sections/discussion.tex#L7)).

#### 4.4.3 CHMM-L (Laplace)
- Density: $f_k(x) = \mathrm{Laplace}(x; \mu_k, \beta_k) = (1/2\beta_k) \exp(-|x - \mu_k|/\beta_k)$.
- Per-state parameters: 2 (location $\mu_k$, scale $\beta_k$). Notation: scale denoted $\beta_k$ to avoid collision with the canonical Laplace symbol $b$.
- Tail behavior: exponential decay (heavier than Gaussian, lighter than Student-$t$ with small $\nu$). Excess kurtosis of a single Laplace = 3 (already heavier than Gaussian's 0 by construction).
- M-step: closed-form via weighted MLE. $\mu_k$ is the **posterior-weighted median** of observations (computed by cumulative-weight bracketing with linear interpolation between neighbouring order statistics); $\beta_k$ is the weighted MAD, $\sum_t \gamma_t(k)|O_t - \mu_k|/\sum_t \gamma_t(k)$.
- **How it differs from CHMM-N**: same parameter count, but the loss function is $L_1$ (median, MAD) rather than $L_2$ (mean, variance). Closed-form like Gaussian, no bracketed search. Kurtosis at $K = 3$ on SPY: 5.30 IS / 4.85 OoS, intermediate between Gaussian and Student-$t$.
- **How it differs from CHMM-t**: no shape parameter, much faster (no ECM bracketing), but no per-state tail-thickness adaptation.

#### 4.4.4 CHMM-GED (Generalized Error Distribution)
- Density: $f_k(x) = \mathrm{GED}(x; \mu_k, \alpha_k, p_k)$, the $p$-generalized Gaussian. The shape parameter $p_k$ controls tail heaviness: $p = 2$ is Gaussian, $p = 1$ is Laplace, $p < 1$ is super-heavy.
- Per-state parameters: 3 (location $\mu_k$, scale $\alpha_k$, shape $p_k \in [0.5, 3.0]$).
- Tail behavior: $\exp(-|x - \mu|^p/\text{const})$. **CHMM-N is the boundary case at $p_k = 2$**; **CHMM-L is the boundary case at $p_k = 1$**. So CHMM-GED literally nests both other symmetric families and lets the data choose the per-state shape.
- M-step: **three-stage ECM** ([sections/estimation.tex:50-51](sections/estimation.tex#L50-L51)). Per state: (1) $\mu_k \leftarrow \arg\min_\mu \sum_t \gamma_t(k)|O_t - \mu|^{p_k}$ via golden-section over $[\hat\mu_k - 5\alpha_k, \hat\mu_k + 5\alpha_k]$; (2) closed-form scale $\alpha_k \leftarrow [(p_k/W_k) \sum_t \gamma_t(k)|O_t - \mu_k|^{p_k}]^{1/p_k}$; (3) $p_k \leftarrow \arg\max_{p \in [0.5, 3.0]} \sum_t \gamma_t(k) \log f_k(O_t; \mu_k, \alpha_k, p)$ via golden-section over $[p_{\min}, p_{\max}]$.
- **How it differs from the other three**: per-state adaptive shape that interpolates continuously between the Laplace boundary and the Gaussian boundary (and beyond). The fitted $\hat p_k$ on SPY partitions bimodally into a Gaussian-bulk / Laplace-tail structure that replicates across seeds and tickers ([sections/results.tex:76](sections/results.tex#L76)) — the data-driven analog of a hand-classified bulk/tail hybrid. Highest CHMM family on the OoS block-aware KS at $L = 20$ ([sections/baselines_appendix.tex:48](sections/baselines_appendix.tex#L48)).

#### 4.4.5 At-a-glance comparison

| Variant | Per-state params | Tail | M-step | Kurtosis (SPY IS, $K^\star = 3$) | Use-case priority |
|---|---|---|---|---|---|
| CHMM-N | 2 ($\mu, \sigma$) | Light, $e^{-x^2}$ | Closed-form (mean, variance) | 3.83 | Simplest fit; kurtosis fidelity secondary |
| CHMM-L | 2 ($\mu, \beta$) | Exponential, $e^{-\lvert x \rvert}$ | Closed-form (median, MAD) | 5.30 | Closest IS kurtosis match without a shape parameter |
| CHMM-t | 3 ($\mu, \sigma, \nu$) | Power-law, $\nu$-dependent | ECM (golden-section on $\nu$) | 14.91 (penalised $\lambda = 20$); 4.68 (shared-$\nu$) | Per-state heavy tails, IS-calibrated |
| CHMM-GED | 3 ($\mu, \alpha, p$) | Adaptive, $e^{-\lvert x \rvert^p}$ | Three-stage ECM ($\mu$ then $\alpha$ then $p$) | 5.48 | Adaptive per-state shape; data-chosen Gaussian-bulk / Laplace-tail mixture |

Source: ([sections/discussion.tex:9-25](sections/discussion.tex#L9-L25), Table `tab:variant_choice`).

---

## 5. Estimation: EM, Baum-Welch, ECM, Quantile Init

### 5.1 EM in one paragraph
**Expectation-Maximization** is an iterative algorithm for MLE in the presence of latent variables (here: the hidden state sequence $s_{1:T}$). Each iteration alternates an **E-step** that computes the conditional distribution of the latents given the data and the current parameter estimate, and an **M-step** that re-estimates the parameters by maximizing the expected complete-data log-likelihood under those posteriors. EM is **likelihood-monotone**: each full iteration increases the incomplete-data log-likelihood (or leaves it unchanged at a fixed point). Convergence is to a local maximum, not a global maximum, which is why initialization matters.

### 5.2 Baum-Welch
**Baum-Welch** (Baum 1970) is just EM specialized to HMMs, where the E-step is computed efficiently via the **forward-backward** algorithm. The forward variables $\alpha_t(k) = \Pr(O_{1:t}, s_t = k)$ and backward variables $\beta_t(k) = \Pr(O_{t+1:T} \mid s_t = k)$ recurse in $O(K^2 T)$ time and combine to give the smoothed posteriors $\gamma_t(k) = \Pr(s_t = k \mid O_{1:T})$ and pair-posteriors $\xi_t(j, k) = \Pr(s_{t-1} = j, s_t = k \mid O_{1:T})$. The M-step then re-estimates $\mathbf T$ from the $\xi$'s (closed-form) and $\boldsymbol\theta_k$ from the $\gamma$'s (closed-form for some emission families, ECM for others). The paper runs forward-backward in **log-space** for numerical stability ([sections/estimation.tex:1-2](sections/estimation.tex#L1-L2)). Convergence: $|\mathcal L^{(n)} - \mathcal L^{(n-1)}| < 10^{-4}$, max 60 iterations, typically reached in 20-40 ([sections/estimation.tex:11-14](sections/estimation.tex#L11-L14)).

### 5.3 ECM (Expectation Conditional Maximization)
When the M-step has no closed-form joint maximizer (CHMM-t, CHMM-GED), **ECM** of Meng-Rubin (1993) breaks the M-step into a sequence of **conditional** maximizations. CHMM-t uses a two-block CM step (location/scale then $\nu$); CHMM-GED uses a three-block CM step ($\mu$ then $\alpha$ then $p$). Each CM step is a partial maximization, so the EM monotonicity guarantee is preserved on the compact bracket. **How ECM differs from full M-step EM**: in vanilla EM the M-step finds the joint argmax of the expected complete-data log-likelihood; in ECM the M-step finds a sequence of conditional argmaxes that together still increase the objective. The bracketed golden-section searches inside CHMM-t and CHMM-GED are why these variants are slower per iteration than CHMM-N and CHMM-L.

### 5.4 Quantile-based initialization (the unsung hero)
The standard 1990s practice was to initialize the EM either randomly or with a single round of $K$-means. The paper uses a **quantile-based initialization**: sort observations, partition into $K$ equal-sized chunks, seed each state's location and scale from the corresponding chunk; transitions and initial probabilities all $1/K$ ([sections/estimation.tex:7-15](sections/estimation.tex#L7-L15)). Why this matters: the random initializations standard in the 1990s often converged to overlapping local optima where two states had near-identical $(\mu_k, \sigma_k)$ and the transition matrix collapsed to effectively a smaller $K$. **This is one of the two compounding sources of the Rydén-Teräsvirta-Åsbrink low-K failure**; the other is the spectral one of §6. The replication in [sections/discussion.tex:3-4](sections/discussion.tex#L3-L4) confirms that with modern initialization the absolute-return ACF is reproduced at any $K \ge 2$ on SPY; the binding low-K constraint is then purely distributional (kurtosis), not temporal.

---

## 6. The Spectral Mechanism, in Plain Language

This is the paper's principal theoretical contribution and the single most-likely-to-be-misread section if a reviewer skims.

### 6.1 The textbook identity
For a stationary CHMM, the population-level absolute-return autocorrelation at lag $\tau$ admits the closed-form **bilinear identity**
$$\mathbb{E}[|G_t|\,|G_{t+\tau}|] = \mathbf m^\top \mathrm{diag}(\bar{\boldsymbol\pi})\, \mathbf T^\tau\, \mathbf m, \qquad m_k = \mathbb{E}[|G_t| \mid s_t = k]$$
([sections/theory.tex:4](sections/theory.tex#L4)). This is folklore in the regime-switching literature (Hamilton 1994 §22.2; Krolzig 1997 Ch.~3; Timmermann 2000). **The paper does not claim this identity as a contribution.**

### 6.2 The eigendecomposition
Under irreducibility and aperiodicity of $\mathbf T$, $\mathbf T^\tau = \mathbf 1 \bar{\boldsymbol\pi}^\top + \sum_{k=2}^K \lambda_k^\tau \mathbf v_k \mathbf w_k^\top$, where $\lambda_1 = 1$ is the dominant eigenvalue (with right eigenvector $\mathbf 1$ and left eigenvector $\bar{\boldsymbol\pi}$) and $\lambda_2, \dots, \lambda_K$ are the **non-unit eigenvalues** with $|\lambda_k| < 1$. Subtracting the marginal product $\mathbb{E}[|G_t|]^2$ from the bilinear identity gives the **normalised ACF** as a sum of geometric decays:
$$\rho_{|G|}(\tau) = \sum_{k=2}^K w_k\, \lambda_k^\tau$$
where $w_k$ is a fixed scalar weight that depends on the emission means and the eigenvectors. This is **at most $K - 1$ decay modes**: complex-conjugate $\lambda_k$ pairs combine into damped oscillatory modes; non-diagonalisable $\mathbf T$ adds polynomial-times-geometric prefactors via Jordan blocks.

### 6.3 Why this matters for the Rydén failure
At $K = 2$ the formula reduces to $\rho_{|G|}(\tau) = \lambda_2^\tau$ with $\lambda_2 = T_{11} + T_{22} - 1$: a **single exponential mode**. You can tune $T_{11} + T_{22}$ to make decay slow, but you only get one mode and the marginal mixture has only two components, which cannot match the empirical kurtosis. So both axes (temporal and distributional) bind simultaneously at $K = 2$, and the empirical Rydén failure was on the distributional axis ([sections/introduction.tex:5](sections/introduction.tex#L5)).

At $K \ge 3$ the matrix admits multiple non-unit eigenvalues, **but the algebraic upper bound of $K - 1$ modes is just an upper bound**. Whether the bound is binding depends on the **effective rank** of the deflated transition matrix $\mathbf T - \mathbf 1 \bar{\boldsymbol\pi}^\top$: if a single mode carries almost all the lag-1 ACF mass, the rest of the spectrum is unused.

### 6.4 The paper's empirical contribution
On SPY at $K = 18$, the dominant non-unit mode at $|\lambda_2| = 0.929$ carries **93.6%** of the lag-1 absolute-return ACF; three modes carry $\ge 95\%$, twelve modes carry $\ge 99\%$ ([sections/theory.tex Table tab:spectral_modes](sections/theory.tex#L16-L34)). On the 30-ticker cross-section the dominant-mode share has **median 0.756 with IQR [0.66, 0.86] and minimum 0.33 (NEM)**. So the SPY value sits in the right tail of the cross-ticker distribution; the paper's framing is **rank-non-binding at the cross-ticker median**, not as a universal property. The framing decision is important: it prevents reviewers from over-reading the SPY headline as a generic claim about HMMs on equity data.

### 6.5 What this is not
The paper does not claim the bilinear identity itself, the eigendecomposition, or the K-1 rank bound as theoretical contributions; all are textbook. The **substantive contribution** is the empirical effective-rank application that recasts the Rydén low-K failure as a rank diagnostic ([sections/introduction.tex:13](sections/introduction.tex#L13)).

---

## 7. Benchmark Generators, and How Each Differs from CHMM

The paper benchmarks the four CHMM variants against eight reference generators. Each is summarised here with **what it is**, **how it differs from CHMM**, and **its role in the panel**.

### 7.1 i.i.d. stationary block bootstrap (Politis-Romano 1994)
- **What it is**: resample the observed series in random-length blocks (geometric block lengths around mean $L$) and concatenate; each simulated path is a permutation of literal IS observations.
- **How it differs from CHMM**: non-parametric; no fitted parameters; no notion of latent state; cannot extrapolate beyond observed values; cannot serve copula composition or privacy-preserving applications because every path is a permutation of literal IS samples.
- **Role**: the **non-parametric distributional ceiling** for KS pass rate. At 99.7% IS / 92.1% OoS KS it beats every CHMM operating point and ties with ML HSMM-N at $K^\star = 3$ on raw OoS KS ([sections/results.tex:51, 84](sections/results.tex#L84)). The paper is explicit that "CHMM beats bootstrap on KS" is the wrong framing; the differentiation is on the structural use cases (regime-conditional VaR, multi-asset copula, parametric privacy) that the bootstrap cannot serve.

### 7.2 Gaussian i.i.d.
- **What it is**: draw daily returns iid from $\mathcal N(\hat\mu, \hat\sigma^2)$ fitted on the IS window.
- **How it differs from CHMM**: no temporal structure (no autocorrelation in $|G_t|$); no heavy tails (zero excess kurtosis by construction).
- **Role**: negative control. KS = 0% on IS, 1% on OoS. Confirms that the KS test has power to reject clearly wrong generators.

### 7.3 Laplace i.i.d.
- **What it is**: same as 7.2 but with a single Laplace fit instead of Gaussian.
- **How it differs from CHMM**: still no temporal structure, but the Laplace single-component fit gets enough kurtosis (2.95 simulated vs observed 7.68) to pass KS at 99.1% IS / 88.5% OoS.
- **Role**: distributional-only fit upper bound. The fact that this single-component model passes KS so high underlines that **OoS KS is a weak distributional metric on this $T$ and the cross-generator differentiation has to come from elsewhere** (the structural use cases).

### 7.4 GARCH(1,1) (Bollerslev 1986)
- **What it is**: $G_t = \sigma_t \varepsilon_t$ with $\sigma_t^2 = \omega + \alpha G_{t-1}^2 + \beta \sigma_{t-1}^2$ and $\varepsilon_t \sim \mathcal N(0, 1)$. Conditional variance evolves with a single decay rate $\beta$; the innovation $\varepsilon_t$ is standard Gaussian.
- **How it differs from CHMM**: continuous-state (the latent state is the continuous $\sigma_t$, not a discrete regime); single-mode innovation distribution; no concept of an interpretable latent regime; cannot serve regime-conditional constructions.
- **Role**: the **historical bar** for volatility-clustering reproduction. The paper's claim is that CHMM **matches** GARCH(1,1) on $|G_t|$ ACF-MAE (CHMM-N: 0.0460, GARCH(1,1): 0.0485) at $K^\star = 3$, the exact axis where simple HMMs are usually dismissed. CHMM-N's 89.7% IS / 80.5% OoS KS vs GARCH(1,1)'s 23.4% / 60.8% reflects GARCH's failure on the marginal axis.

### 7.5 GARCH(1,1)-t (Bollerslev 1987)
- **What it is**: GARCH(1,1) with Student-$t$ innovations.
- **How it differs from CHMM**: same conditional-variance dynamics as 7.4 but heavier-tailed innovation; still no latent regime; still single-mode innovation.
- **Role**: heavy-tailed GARCH baseline. Best $|G_t|$ ACF-MAE in the panel (0.0316) and respectable KS (57.3% IS / 80.8% OoS).

### 7.6 MS-GARCH (Haas-Mittnik-Paolella 2004)
- **What it is**: Markov-switching GARCH. $K$ regimes, each with its own GARCH(1,1) parameterization, with regime governed by a Markov chain.
- **How it differs from CHMM**: GARCH-style conditional variance **inside each state** (so the per-state distribution is itself a stochastic process, not a simple parametric density); the marginal is therefore mixed over both regimes and the GARCH-driven $\sigma_t$. Much richer per-state dynamics than CHMM.
- **Role**: the strongest regime-switching benchmark in the panel. In the in-house Nelder-Mead fit it plateaus at 27.7-36.1% IS KS across $K \in \{2, 3, 6\}$; the reference Bayesian re-run via the `MSGARCH` R package of Ardia et al. 2019 plateaus at 0-0.1% IS KS across $K \in \{2, 3, 4\}$ ([sections/results.tex:56-61](sections/results.tex#L56-L61)). Either way the multi-state benefit on this dataset is **specific to the CHMM scaffold**, not to multi-state regime-switching per se.

### 7.7 HSMM (Hidden Semi-Markov Model)
- **What it is**: relaxes the geometric-sojourn assumption of the standard HMM. In an HMM the time spent in state $k$ before switching is geometrically distributed (a property of any Markov chain); in an HSMM the sojourn distribution is replaced with an explicit duration distribution (Pareto, truncated Pareto, Gamma).
- **How it differs from CHMM**: extra sojourn-distribution machinery; explicit-duration forward-backward of Yu-Kobayashi 2010 instead of plain forward-backward; $O(K^2 T D)$ cost instead of $O(K^2 T)$ where $D$ is max duration. Lets the model match richer sojourn behaviour at the cost of additional parameters.
- **Role**: the **co-headline result**. ML HSMM-N at $K^\star = 3$ attains 98.4% IS / **91.0% OoS** KS, the strongest single-window OoS row in the panel. **But** the fitted Pareto sojourn concentrates on a single low-volatility state, which mutes the regime-driven slow-ACF mechanism that CHMM exploits ($|G_t|$ ACF-MAE matches the i.i.d. baseline at 0.0629 vs CHMM-N's 0.0460). So CHMM and HSMM are **complementary scaffolds with different KS / ACF / kurtosis trade-offs**, not competitors. ([sections/results.tex:80-81](sections/results.tex#L80-L81))

### 7.8 SM-CHMM Viterbi-AR(1)
- **What it is**: take the Viterbi-decoded state sequence from the fitted CHMM (single most-likely state path), then fit a per-state AR(1) on the residuals. A "plug-in semi-Markov foil".
- **How it differs from CHMM**: introduces per-state autoregressive structure on top of the regime, but uses a hard state assignment instead of the soft posterior-weighted updates EM uses internally.
- **Role**: foil; demonstrates that the CHMM's gains aren't trivially reproducible by adding AR(1) noise to a Viterbi decoding.

### 7.9 QuantGAN (Wiese et al. 2020)
- **What it is**: Wasserstein-GAN with a temporal convolutional network (TCN) architecture, trained on lagged-return windows.
- **How it differs from CHMM**: deep generative; no parametric structure; no interpretable latent state; no analytic form for the marginal CDF (so cannot serve quantile-based constructions like the regime-conditional VaR).
- **Role**: the deep-generative reference row. The in-house WGAN re-implementation fails KS (0.0% on both windows); a faithful reference-implementation re-run with Lambert-W input pre-processing is a deferred follow-up.

### 7.10 Other rows (SV, MSM, JD, EGARCH, GJR-GARCH, HAR-RV, MSSV)
The extended GARCH-family panel and stochastic-volatility / multifractal / jump-diffusion baselines are reported in the appendix for completeness. None changes the headline cross-generator ranking. EGARCH, GJR-GARCH would address the leverage-effect axis (which the symmetric CHMM does not), but leverage is explicitly out of scope in the body.

---

## 8. The Regime-Conditional VaR Construction (Pipeline A Risk-Management Headline)

This is the paper's headline risk-management contribution and the construction that distinguishes CHMM from the bootstrap and from any iid generator.

### 8.1 What VaR and ES are
- **Value-at-Risk** at level $\alpha$ on day $t$: the $\alpha$-quantile of the predictive return distribution, $\widehat{\text{VaR}}_t(\alpha) = F_t^{-1}(\alpha)$. Interpretation: the threshold such that a loss exceeding it on day $t$ should occur with probability $\alpha$.
- **Expected Shortfall** at level $\alpha$: $\mathbb{E}[G_t \mid G_t \le \widehat{\text{VaR}}_t(\alpha)]$. The expected loss conditional on a breach. Strictly more informative than VaR for tail risk because it integrates the tail rather than just clipping at a quantile.

### 8.2 Three layers of the VaR diagnostic
The paper layers the VaR diagnostic into three stacked tests, each strictly more demanding than the last ([sections/var_backtest.tex:5-6](sections/var_backtest.tex#L5-L6)):

1. **Envelope bracketing** (sanity check). Are the simulated VaR/ES quantiles tight enough that the observed historical VaR/ES values fall inside the [5%, 95%] simulation envelope? All four CHMM variants pass on both windows.

2. **Unconditional Kupiec coverage** (basic backtest). Count breaches (days where $G_t < \widehat{\text{VaR}}_t(\alpha)$); ask whether the empirical breach rate matches the nominal coverage. $\text{LR}_{\text{uc}} \sim \chi^2_1$ asymptotically. All four CHMM variants pass at $\alpha = 0.05$ on OoS.

3. **Regime-conditional Christoffersen-cc** (the headline). The substantive risk-management diagnostic.

### 8.3 The regime-conditional construction, step by step
At each OoS day $t$:
1. Run the forward filter through $\mathcal F_{t-1} = R_{\text{IS}} \cup R_{\text{oos}}[1:t-1]$ to compute the smoothed posterior $\Pr(s_{t-1} = i \mid \mathcal F_{t-1})$.
2. Push it through the (frozen, IS-fixed) transition matrix to get the **one-step-ahead state forecast**: $\Pr(s_t = k \mid \mathcal F_{t-1}) = \sum_i \Pr(s_{t-1} = i \mid \mathcal F_{t-1}) \mathbf T_{ik}$ ([sections/var_backtest.tex Eq.~(eq:filter)](sections/var_backtest.tex#L15-L18)).
3. Form the **predictive mixture CDF** $F_t(x) = \sum_k \Pr(s_t = k \mid \mathcal F_{t-1}) F_k(x; \boldsymbol\theta_k)$ where $F_k$ is the per-state Gaussian, Student-$t$, Laplace, or GED CDF.
4. Take the $\alpha$-quantile $\widehat{\text{VaR}}_t(\alpha) = F_t^{-1}(\alpha)$.

The crucial point: only the one-step-ahead state probability vector is updated through the OoS observations; the parameters $(\mathbf T, \{\boldsymbol\theta_k\})$ remain frozen at their IS estimates (no refit). This is what makes the construction a **clean OoS test** rather than an in-sample fit.

### 8.4 Why "conditional" matters
The unconditional Kupiec test asks only whether the marginal breach rate matches; it is silent about clustering. A model can pass Kupiec while producing breaches that arrive in batches (a clustered-violations failure mode). The Christoffersen LR_ind statistic tests for breach independence; LR_cc is the joint test (coverage AND independence). The regime-conditional construction sees its independence improvement from $\text{LR}_{\text{ind}} = 5.26$ (unconditional) to $\text{LR}_{\text{ind}} = 0.52$ (conditional) at $K = 18, \alpha = 0.05$ ([sections/var_backtest.tex:19](sections/var_backtest.tex#L19)) — this is the regime-switching value proposition that the unconditional Kupiec did not exercise.

### 8.5 What can pass this construction, and what cannot
- **What can**: any multi-state regime-switching model with a forward-filter and a per-state predictive density (CHMM, HSMM, MS-GARCH).
- **What cannot**: i.i.d. generators (no state filter), bootstrap (no parametric per-state density), GARCH (single conditional variance, single innovation distribution).
- This is the structural-use-case argument made in [sections/results.tex:84](sections/results.tex#L84) — CHMM offers parametric controls and the state-filter forecasting machinery that the bootstrap cannot serve, even though the bootstrap beats CHMM on raw KS.

### 8.6 The α = 0.01 power caveat
At $T_{\text{OoS}} = 572$ and $\alpha = 0.01$ the expected breach count is only ~5.7. The Christoffersen-cc test reaches $\ge 80\%$ power against breach-clustering eigenvalues only at $\rho \ge 0.50$, with rejection rate just 42.6% at $\rho = 0.20$ ([sections/var_backtest.tex:21-22](sections/var_backtest.tex#L21-L22)). The paper resolves this by reporting the higher-power **Engle-Manganelli Dynamic Quantile (DQ)** test alongside Christoffersen-cc; DQ rejects $K = 18$ at $\alpha = 0.01$ ($p = 0.017$) while Christoffersen-cc does not ($p = 0.137$). Substantive read: the regime-conditional VaR over-couples high-volatility states at the strict tail at $K = 18$ on this OoS slice. The body diagnostic is therefore the $\alpha = 0.05$ row under both tests.

---

## 9. Statistical Tests, in One Paragraph Each (with How They Differ)

### 9.1 Distributional tests (where the marginal lives)

**Kolmogorov-Smirnov (KS)** measures the maximum gap between empirical CDFs of simulated and observed returns. Sensitive to mismatches in the **bulk** of the distribution. Two-sample KS at $\alpha = 0.05$ is the headline marginal-fidelity metric. Numbers like "OoS KS pass rate = 73%" mean 73% of simulated paths cleared the per-path null at $\alpha = 0.05$. The paper reports both **asymptotic** critical values and **stationary-block-bootstrap recalibrated** values at $L \in \{5, 10, 20\}$, both IS-anchored and OoS-anchored, because the asymptotic test assumes iid samples and daily returns are autocorrelated.

**Anderson-Darling (AD)**, sister of KS, is **tail-weighted** (gives more weight to tail mismatches). Run as a robustness check alongside KS; cross-generator ranking is preserved.

**Wasserstein-1 ($W_1$)** is a transport distance between two distributions; **Hellinger** is an $L^2$-style distance between $\sqrt{f}$ densities. Different geometric / functional structures than KS but the cross-generator ordering is preserved (appendix). Reported because the choice of distributional metric is itself a robustness axis.

**Jarque-Bera** tests joint normality (skewness and kurtosis simultaneously). Cited in the descriptive-statistics block as evidence that observed SPY is heavy-tailed and not Gaussian.

**Stationary block bootstrap (Politis-Romano 1994)** is the resampling scheme used for kurtosis CIs, KS recalibration, and the dependence on temporal structure. **Differs from iid bootstrap** in that it preserves serial dependence (resamples random-length blocks rather than individual observations); iid bootstrap destroys autocorrelation by construction.

### 9.2 Temporal tests (where the autocorrelation lives)

**Ljung-Box (LB)** tests joint autocorrelation across multiple lags. The paper cites $\text{LB}_G \approx 5.5$ at lag 20 (linear ACF, near zero, expected for daily equity returns) and $\text{LB}_{|G|} = 2{,}959.3$ (absolute-return ACF, large, the volatility-clustering smoking gun).

**ACF-MAE** is not a hypothesis test but a distance metric: the mean absolute error between the observed absolute-return ACF and the simulated absolute-return ACF over $L = 252$ lags. Reported as the volatility-clustering numerical headline. CHMM-N at 0.0460 vs GARCH(1,1) at 0.0485: the on-par-with-GARCH claim.

### 9.3 VaR backtests (where the conditional risk-management lives)

**Kupiec LR_uc** (unconditional coverage). Count breaches; compare empirical breach rate to nominal $\alpha$. Asymptotically $\chi^2_1$; the paper also reports the exact-binomial complement so reviewers see both finite-sample and asymptotic answers.

**Christoffersen LR_ind** (independence). Tests whether the breach-indicator series shows lag-1 dependence. **Differs from Kupiec** by being silent about marginal coverage and looking only at clustering. A model can pass Kupiec but fail LR_ind if breaches arrive in batches.

**Christoffersen LR_cc** (joint conditional coverage). $\text{LR}_{\text{cc}} = \text{LR}_{\text{uc}} + \text{LR}_{\text{ind}}$, asymptotically $\chi^2_2$. The headline conditional-coverage statistic.

**Engle-Manganelli Dynamic Quantile (DQ)**. Higher-power conditional-coverage backtest based on regressing the breach indicator on lagged information (4 lags is standard). **Differs from Christoffersen-cc** by using a regression-style construction rather than a transition-count construction; can detect mis-specifications that LR_cc misses on small breach counts. Used as the second-opinion test at $\alpha = 0.01$.

### 9.4 Forecast-comparison tests (where the model-vs-model lives)

**Diebold-Mariano (DM)** compares predictive accuracy of two forecasters on the same series; here applied to **CRPS losses** (continuous ranked probability score, the proper-scoring-rule analog of squared error for probabilistic forecasts) with a Newey-West HAC variance estimator under the Bartlett kernel. **Bandwidth-sweep robustness** is reported because DM is famously sensitive to bandwidth choice. **Differs from KS / AD** in that it compares two simulators against each other rather than each against the observed series.

### 9.5 Aggregation / multiple-testing corrections

**One-way ANOVA by GICS sector** (parametric F + 5{,}000-replicate permutation). Tests whether OoS KS varies systematically by sector. The paper reports $F(9, 50) = 0.37$, $p = 0.946$, $\eta^2 = 0.062$ on the $n = 6$ expansion, so the no-sector-effect null is not rejected at adequate power.

**Wilks profile-LL CI plus parametric bootstrap CI** for the Student-$t$ copula's degrees-of-freedom $\nu^\star$. Both reported because Wilks is asymptotic and the bootstrap is finite-sample; agreement between them is the headline.

**BH-FDR at 0.05** (Benjamini-Hochberg false-discovery-rate correction) controls the false-discovery rate across the 40-test conditional-coverage panel; without it, running 40 individual $\alpha = 0.05$ tests would expect ~2 spurious rejections.

---

## 10. What the Numbers Mean

The headline numerical claims and what they encode for a reviewer skimming the abstract.

- **Three symmetric Cont (2001) stylized facts reproduced.** (a) Heavy-tailed marginal: kurtosis CIs cover or exceed observed SPY value; the simulator is not Gaussian. (b) Negligible linear ACF: the lag-1 autocorrelation of returns is near zero, matching efficient-market behavior. (c) Slow $|G_t|$ ACF decay: the autocorrelation of absolute returns decays slowly (volatility clustering). The paper says CHMM matches GARCH(1,1) on (c), the historical bar that simple HMMs fail.

- **Spectral effective-rank claim.** At $K = 18$ on SPY the dominant transition-matrix mode carries 93.6% of the deflated trace; cross-ticker median is 0.756. This is the falsifiable, mathematical version of the Rydén low-K failure: a $K$-state HMM cannot reproduce slow ACF decay if the effective rank of its deflated transition matrix is 1; CHMM at $K \ge 3$ has effective rank $> 1$ on the cross-ticker median.

- **Christoffersen-cc passes on the headline window** at the conventional $\alpha = 0.05$ (regime-conditional VaR, propagating one-step-ahead state forecasts through the predictive mixture). Six-fold rolling-origin walk-forward: pass on the bulk, rejections concentrated on out-of-distribution stress folds (W2, W4 mid-COVID and 2022 inflation regime introductions). Periodic refit (quarterly cadence) is the deployment recipe.

- **Non-equity stress test (GLD, SLV) collapses under static fitting.** Reported as a negative result; it is the boundary of the headline claim. Periodic refit is again the proposed remedy.

- **HSMM ML matches or slightly exceeds CHMM on raw distributional fidelity.** Positioning sentence: CHMM does not claim distributional dominance. The paper's proposition is that CHMM is preferable when the downstream use case is regime-conditional VaR, copula composition, or parametric privacy, all of which require state semantics that an HSMM with non-geometric sojourns does not naturally provide.

---

## 11. Position vs. Existing Models, and Why It Is Worth Working On

**Where the field stands.** Daily equity return generation is a 30-year-old problem with three strong lineages: GARCH-family (Bollerslev 1986; Nelson 1991; Glosten-Jagannathan-Runkle 1993; Engle 1982; Bollerslev 1987), regime-switching variants (Hamilton 1989; Haas-Mittnik-Paolella 2004 MS-GARCH; Calvet-Fisher 2004 MSM; So 1998 / Carvalho-Lopes 2007 MSSV), and deep generative methods (Wiese et al. 2020 QuantGAN; Yoon 2019 TimeGAN; Rasul 2021 autoregressive diffusion). Hidden Markov models in particular have a known low-K failure (Rydén-Teräsvirta-Åsbrink 1998) on the absolute-return ACF axis.

**Existing weaknesses the paper addresses.**
- HMMs are routinely dismissed for stylized-fact reproduction because of the Rydén K=2 result. The paper recasts that failure as an effective-rank statement and shows the rank constraint is non-binding at $K \ge 3$ for the cross-ticker median; HMMs are not architecturally limited, they were limited by misspecified low $K$.
- GARCH-family and deep generative methods do not produce semantically interpretable latent states. CHMM does. This is the structural-use-case argument: regime-conditional VaR, copula composition, parametric privacy guarantees, scenario stress-testing.
- The unified ECM scaffold across four emission families with identical forward-backward recursions is a methodological contribution: only the M-step changes between families, so practitioners can swap distributional assumptions without re-implementing the algorithm.
- The risk-management evaluation (Christoffersen-cc, DQ, walk-forward refit cadence) is more rigorous than the typical generative-model evaluation, which stops at marginal-distribution KS.

**Why it is worth working on.**
- Synthetic financial data is in active demand for backtesting, stress testing, and privacy-preserving data sharing under regulatory constraints. The structural-use-case framing maps onto deployment problems regulators and risk desks actually face.
- The spectral identity is a textbook tool, but its application as an effective-rank diagnostic is novel and falsifiable; it sharpens what the field thought it knew about HMM expressiveness.
- The reproducer is fully open: two public repos (CHMM-paper, CHMM-Model), Julia $\ge 1.12$ + R 4.6, deterministic seed tree, R `renv` lockfile, CRSP slice for an out-of-decade independence test. Other groups can pick this up and extend it without reimplementation cost.

---

## 12. Cleanup Checklist (pre-arXiv tarball)

Findings from the cleanup audit, ordered by impact.

### CHMM-Model repo
1. **Drop the `Alpaca` dependency from `Project.toml`** after deleting the two probe scripts (`run_probe_alpaca_history.jl`, `run_fetch_spy_independent_decade.jl`). `Alpaca` is a non-registered git-URL dep and the most likely cause of `Pkg.instantiate()` failures for outside readers. Single highest-leverage change.
2. **Delete `_attic_v10/data/`** (~298 MB of pre-final-split snapshots; superseded by `data/CHMM-SP500-Train-10yr.jld2` and `data/CHMM-SP500-OoS-Remainder.jld2`).
3. **Delete `_attic_v10/runners/`** (9 archived `track_*.jl` scripts; zero references from active code).
4. **Delete `_attic_v10/docs/`** (planning notes, downloaded references; not part of public release).
5. **Gitignore raw OHLC bundles** (`data/SP500-Daily-OHLC-*.jld2`, ~99 MB) plus `data/external/` (regenerated by `build_new_train_oos.jl`).
6. **Prune dead K-variant runners** identified in the audit:
   - Sector panel: `run_sector_panel_k3.jl`, `run_sector_panel_k6.jl`, `run_sector_panel_monthly_refit.jl` (outputs not cited).
   - K-selection: `run_k_selection_validation.jl`, `run_k_selection_validation_pre2020.jl` (superseded by k-fold variants).
   - VaR: `run_christoffersen_var.jl`, `run_conditional_var.jl` (superseded by `_all_families` and `_power` variants).
   - Walk-forward: `run_walkforward_oos.jl`, `run_walkforward_conditional_var.jl` (superseded by W7 + refit-cadence).
   - Copula: `run_cross_asset_rolling_copula.jl`, `run_full_tcopula_mle.jl` (outputs not cited).
   - KS bootstrap: `run_ks_block_bootstrap.jl`, `run_ks_block_body_kstar.jl` (only `_oos` cited).
   - MS-GARCH: `run_msgarch_higher_k.jl` (uncited).
   - Misc: `run_chmm_t_penalised_headline.jl`, `run_t_singular_values.jl`, `run_per_ticker_lambda_sweep.jl`, `run_kstar3_headline.jl`, `run_garch_suite.jl`, `run_nu_shrinkage_sweep.jl`.
7. **Archive (move to `_attic_v10/runners/`)**: `regen_var_es_fig.jl`, `run_copula_profile_ci.jl`, `run_crps_dm.jl`, `run_crps_extra_rows.jl`, `run_ged_bracket_sensitivity.jl`, `run_ged_robustness.jl`, `run_hsmm_ml.jl`, `run_multiseed_headline.jl`.
8. Rough disk savings: ~400 MB; rough script-count reduction: 80 → ~40-45 active.

### CHMM-paper repo
1. [x] **Delete `figs/_attic/`** (15 superseded PDFs, ~700 KB, zero references) - completed in commit b299cab.
2. [x] **Delete the working-tree `.DS_Store`** - already removed.
3. **Decide policy on `results/robustness/`**: 21 of 27 CSVs have no LaTeX reference. Suggested split: keep in the public repo as a data archive, exclude from the arXiv tarball.
4. Run `make clean` before tarballing for arXiv (drops local `.aux/.bbl/.log/.out`; they are gitignored, but if you copy the working tree, they ship).
5. No `.tex` cleanup needed: all 17 section files are wired into the build via `\input`.

### Pre-submission punch list
- [x] Two prose em-dash violations (sensitivity\_appendix.tex 185, 1002) replaced with semicolons.
- [x] Five overfull hboxes in sensitivity\_appendix.tex (lines ~1111, 1378, 1454, 1484, 1510) fixed by wrapping each tabular in `\resizebox{\textwidth}{!}{...}`. Remaining hboxes: 3, all $\le 5.7$pt (cosmetic).
- [x] Replaced `\begin{table}[h]` with `\begin{table}[!ht]` on every table across the section files (43 instances spanning 8 files). All `[h]→[ht]` auto-promotion warnings cleared.
- [x] Added `\texorpdfstring{...}{...}` wrappers on the 12 math-bearing subsubsection titles (11 in sensitivity\_appendix.tex, 1 in cross\_asset\_appendix.tex). Hyperref bookmark-charset warnings reduced from many to zero.
- [x] Verified `figs/_attic/` removal does not break the build (commit b299cab); `make` produces a clean 112-page PDF, no undefined references.
- [ ] User-facing: add the two repo links (CHMM-paper, CHMM-Model) and the seed-root statement (`20260420`) to the arXiv \emph{submission metadata page} at upload time. Both are already in the LaTeX (conclusion §Data and code availability and model.tex respectively).
- [ ] User-facing: model-repo cleanup (drop `Alpaca` dep, delete `_attic_v10/` subtrees, prune dead K-variant runners) — see "CHMM-Model repo" subsection above. Destructive operations on the sibling repo, deferred for the user to execute.

---

## 13. Analysis Pipelines and Data Timeline

The empirical study is organised along **two named pipelines**, both defined in `model.tex` line 9 and diagrammed in `algorithms_appendix.tex:366` (`\label{sec:supp_pipeline_schematic}`, Fig.~`fig:pipeline_schematic`). The single-asset CHMM scaffold is shared across both. The driver `CHMM-Model/run_full_rebuild.jl` chains them end-to-end (stages 3 and 4 of the rebuild dispatcher).

### 13.1 Pipeline A, single-asset (no cross-asset coupling)

**What it does.** Fit one CHMM per ticker, independently; simulate; score per-asset metrics (KS, AD, kurtosis, $|G_t|$ ACF-MAE, raw-return ACF-MAE, Wasserstein-1, Hellinger, quantile-envelope coverage, CRPS); also drives the regime-conditional VaR back-test in `var_backtest.tex` (state filter on a single ticker).

**Owning runners (CHMM-Model).**
- `run_baselines_and_cross_asset.jl`: headline single-window panel, six-generator comparison on SPY (Table~2, `tab:model_comparison`); per-ticker emission-family panel (Table~T2).
- `run_multi_emission_analysis.jl`: K-sweep across $\{3, 6, 9, 12, 15, 18, 21\}$ for all four emission families on SPY; produces Table~T1 and per-(K, family) figures.
- `run_all_analysis.jl`: SPY-only K-sweep, stylized-fact figures, per-K internals.
- `run_sector_panel.jl`, `run_sector_panel_n6.jl`, `run_sector_panel_quarterly_refit.jl`: 30- and 60-ticker sector panels with quarterly-refit recipe.
- `run_walkforward_w7.jl`, `run_walkforward_cond_var_refit_cadence.jl`: rolling-origin walk-forward folds W1..W7, refit-cadence sweep.
- `run_christoffersen_power.jl`, `run_conditional_var_all_families.jl`, `run_engle_manganelli_dq.jl`, `run_exact_binomial_kupiec.jl`, `run_quarterly_refit_conditional_var.jl`: VaR back-test (Christoffersen LR_uc / LR_ind / LR_cc, DQ, exact-binomial Kupiec, quarterly-refit variant).
- `run_cross_decade_validation.jl`: 1994-2004 IS / 2004-2006 OoS CRSP cross-decade rebuild at $K^\star = 3$ and $K = 18$.
- `run_non_equity_validation.jl`: GLD / SLV stress test on the same body windows.
- `run_chmm_t_shared_nu.jl`: shared-$\nu$ Student-$t$ ablation row.
- Baseline rows used in the same Table~2 panel: `run_msgarch_baselines.jl` (in-house Nelder-Mead MS-GARCH K=2/3), `run_msgarch_reference.jl` (R + RCall, CRAN MSGARCH 2.51, K=2/3/4), `run_smchmm_baseline.jl` (SM-CHMM Viterbi-AR(1) plug-in foil), `run_hsmm_ml_gamma.jl` / `run_hsmm_ml_intermediate_K.jl` (HSMM-N ML reference), `run_quantgan_baseline.jl` (in-house WGAN, deferred follow-up), `run_sv_msm_jd_baselines.jl`, `run_mssv_baseline.jl`, `run_leverage_effect.jl`.

**Paper sections that depend on Pipeline A.** `results.tex` §descriptive--§cross_asset_univariate, `var_backtest.tex`, `walkforward_body_table.tex`, plus the bulk of `sensitivity_appendix.tex`, `baselines_appendix.tex`, and `metrics_appendix.tex`.

### 13.2 Pipeline B, cross-asset dependence

**What it does.** Reuse the per-asset CHMM-N marginals from Pipeline A, then inject cross-asset dependence through a rank-based copula. Sklar's-theorem rank reordering preserves each fitted CHMM marginal exactly while coupling the asset ranks to the copula sample (Iman-Conover 1982). Profile MLE selects the Student-$t$ copula degrees-of-freedom $\nu^\star = 6$ on the body universe.

**The construction in detail**, since this is the most-likely-to-be-misread part of Pipeline B:
1. Per-asset CHMM-N marginal fitted (from Pipeline A).
2. Pseudo-uniform observations $u_{j,t} = \mathrm{rank}(g_{j,t}) / (T + 1)$ for each asset $j$ and day $t$.
3. Estimate the dependence-matrix entries via Kendall's-$\tau$ inversion: $\hat\rho_{ij} = \sin(\pi \hat\tau_{ij}/2)$. This is **exact under the Gaussian copula and approximate under the Student-$t$ copula**; the body uses it as a two-step plug-in. A full one-shot $(\Sigma, \nu)$ MLE is reported as a robustness check (returns $\hat\nu_{\text{full}} = 6.40$ vs $\hat\nu_{\text{two-step}} = 6.00$, agreeing within the Wilks 95% CI).
4. Profile MLE selects $\nu^\star$ on a unit-spaced grid; a half-unit-grid refinement plus parametric bootstrap CI confirms.
5. Sample the chosen copula to get joint pseudo-uniforms; **rank-reorder** (Iman-Conover 1982) so each asset's marginal samples stay pinned to its CHMM fit but the ranks couple to the copula sample. Sklar's theorem guarantees that this preserves each fitted CHMM marginal exactly.

**Owning runners (CHMM-Model).**
- `run_cross_asset_sim_copula.jl`: body Pipeline B at $K = 18$, six-asset US-equity universe (SPY, NVDA, JNJ, JPM, AAPL, QQQ), produces Table~T3 (`tab:cross_asset`) and Fig.~7.
- `run_cross_asset_sim_copula_k6.jl`: $K^\star = 6$ marginals sensitivity rebuild.
- `run_copula_profile_ci_halfunit.jl`: half-unit-grid refinement and parametric-bootstrap CI on $\nu^\star$.
- `run_non_us_asset.jl`: GLD / SLV non-equity stress test under the cross-asset construction.

**Comparators inside Pipeline B.**
- **Single Index Model (SIM)**: SPY as the market factor, then per-asset linear regression on SPY. Rank-one structure; distorts each non-market marginal.
- **Gaussian copula**: same construction as Student-$t$ copula but with a Gaussian dependence layer (no degrees-of-freedom; lighter-tailed joint dependence).
- **Truncated level-1 C-vine** with edge-wise AIC family selection: a vine copula constrained to a single tree level; richer structural flexibility than a single elliptical copula.
- **Full one-shot $(\Sigma, \nu)$ MLE**: robustness check on the Kendall's-$\tau$ two-step estimator.

On the body OoS axis, **the dependence-family choice is empirically null at this $N_{\text{paths}}$**: off-diagonal correlation MAE is 0.209 (Student-$t$) vs 0.202 (Gaussian), a $0.007$ gap below the simulation-noise floor. The IS calibration distinction ($0.027$ vs $0.030$) is IS-only; the OoS-deployment dependence-family selection is dominated by the refit-cadence choice (quarterly refit drops MAE to $0.185$).

**Paper sections that depend on Pipeline B.** `results.tex` §cross_asset, `model.tex` §cross_asset_methods, `cross_asset_appendix.tex`.

### 13.3 Data timeline (single source of truth)

The IS / OoS split is built by `CHMM-Model/build_new_train_oos.jl`. The 10-year boundary is anchored on AAPL's first continuous trading day (2014-01-03) plus 10 years; the OoS slice is everything after that boundary through 2026-04-20. Tickers are kept only if they have full AAPL-matched coverage. The split is reproducible from the two raw OHLC bundles in `data/`.

| Slice | Window | Trading days | Universe | Source | Used by |
|---|---|---|---|---|---|
| **Body IS (training)** | 2014-01-03 to 2024-01-02 | 2,516 | SPY headline; 6-ticker copula universe (SPY, NVDA, JNJ, JPM, AAPL, QQQ); 30-ticker sector panel ($10$ GICS $\times 3$); 60-ticker $n = 6$ expansion | Polygon.io / Alpaca / IEX, packed into `data/CHMM-SP500-Train-10yr.jld2` | Both pipelines, all body tables |
| **Body OoS (held-out)** | 2024-01-04 to 2026-04-20 | 573 (572 in some panels) | Same universes as IS | `data/CHMM-SP500-OoS-Remainder.jld2` | Both pipelines, all OoS columns |
| **K-selection pre-2020 slice** | est.\ 2014-01 to 2018-06; val.\ 2018-07 to 2019-12 | sub-slice of body IS | SPY | Carved from body IS by `run_k_selection_kfold_pre2020.jl` | Pipeline A, K-selection (pre-2020 to avoid COVID leakage) |
| **Walk-forward folds W1..W7** | rolling 5y train + 1y test, body window | 7 folds | SPY | Carved from body IS+OoS by `run_walkforward_w7.jl` and friends | Pipeline A; W2 = COVID, W4 = 2022 rate-hike, W7 = 2017--2018 + 2019 trade-war |
| **Quarterly refit window** | every 63 trading days, rolling | varies | SPY (univariate) and 6-asset (Pipeline B) | `run_quarterly_refit_conditional_var.jl`, `run_sector_panel_quarterly_refit.jl` | Both pipelines, deployment recipe |
| **Cross-decade IS / OoS (CRSP)** | IS 1994-01-03 to 2004-01-02 (~2520); OoS 2004-01-05 to 2006-04-28 (~585) | ~3,100 | SPY plus 28 of the 30 sector-panel tickers (NEE and APD missing from CRSP query) | WRDS day-pass, `data/external/crsp_1994_2006.csv` | Pipeline A, cross-decade independence test (`run_cross_decade_validation.jl`) |
| **Non-equity stress** | same as body windows | 2,516 IS / 573 OoS | GLD, SLV | Same Polygon/Alpaca bundles | Both pipelines, scope-boundary test |
| **Independent-decade fetch (probe)** | not yet in paper | -- | -- | `data/independent_decade/fetch_log.txt` (probe artefact, slated for cleanup) | None; flagged for removal |

**Returns convention.** Annualised excess log returns $G_t = (1/\Delta t) \ln(P_t / P_{t-1}) - r_f$, with $\Delta t = 1/252$ and $r_f = 0$. Prices are session VWAP ([model.tex:9](sections/model.tex#L9)).

### 13.4 End-to-end reproducer

```bash
julia --project=. -e 'using Pkg; Pkg.instantiate()'
julia --project=. build_new_train_oos.jl    # rebuilds the IS / OoS JLD2 split
julia --project=. run_full_rebuild.jl       # chains both pipelines + figures
```

`run_full_rebuild.jl` runs `run_all_analysis.jl` → `run_multi_emission_analysis.jl` → `run_baselines_and_cross_asset.jl` (Pipeline A core) → `run_cross_asset_sim_copula.jl` (Pipeline B core) → diagnostics, MS-GARCH baselines, SM-CHMM baseline, figures. QuantGAN is excluded by default (slowest stage, deterministic at the global seed) and is run standalone when the row needs refreshing. The MS-GARCH reference row additionally requires `R >= 4.2` and a one-time `Rscript r_msgarch/setup.R`; everything else runs with Julia alone.

---

## 14. CHMM-GED Variant (memory note)

A fourth emission family, per-state GED with state-specific shape parameter $p_k$, is implemented and validated in the model repo (multiseed and cross-ticker) and **is** in the paper as a body row at $K^\star = 3$ ([results.tex Table tab:model_comparison row "CHMM-GED"](sections/results.tex#L68)). The earlier "not yet in paper" note on this variant is superseded; it is now folded into the headline `tab:model_comparison`, the variant-decision guide ([discussion.tex Table tab:variant_choice](sections/discussion.tex#L9-L25)), and the multi-emission K-sweep tables in `sensitivity_appendix.tex`. The bimodal Gaussian-bulk / Laplace-tail $\hat p_k$ partition appendix at `sec:supp_p_partition` documents the cross-seed and cross-ticker replication.
