# Plan: Alternative Metrics for Selecting K in CHMM

Goal: move beyond information criteria (AIC, BIC, ICL) for selecting the number of hidden states K, by adding distance-based and predictive criteria that ground the choice in the stylized facts the CHMM is meant to reproduce.

## 1. Predictive / cross-validation criteria

- **Held-out log-likelihood** (k-fold or rolling-origin CV). Canonical reference: Celeux & Durand (2008), "Selecting hidden Markov model state number with cross-validated likelihood", Computational Statistics.
- **One-step-ahead predictive likelihood** / prequential score (Dawid). Natural for financial returns.
- **CRPS (Continuous Ranked Probability Score)**, Gneiting & Raftery (2007). Proper scoring rule; equals the 1-Wasserstein distance between predictive CDF and the point observation, integrated over the line. Selects K with best calibrated predictive densities.
- **Energy score / log score** as multivariate generalizations.

## 2. Distance / divergence-based goodness of fit

This is where Wasserstein lives.

- **Wasserstein distance W_p** between empirical return distribution and the model-implied stationary distribution, or between empirical and simulated sample paths. Reference: Bernton, Jacob, Gerber, Robert (2019, JRSS-B), "Approximate Bayesian computation with the Wasserstein distance".
- **Sliced-Wasserstein** (Bonneel et al., 2015) for tractability in higher dimensions.
- **Maximum Mean Discrepancy (MMD)**, Gretton et al. Kernel-based; used for model selection in generative models.
- **Kolmogorov-Smirnov, Cramer-von Mises, Anderson-Darling** on the marginal distribution of returns.
- **KL divergence** between empirical and model density (equivalent to log-likelihood up to a constant, so not really new).

## 3. Stylized-fact / moment-matching criteria

Common in econometrics and natural for CHMM, since the model is supposed to reproduce volatility clustering and fat tails.

- Distance between empirical and model ACF of |r_t| or r_t^2 (already plotted in Fig. 7).
- Distance in higher moments: kurtosis, leverage effect, tail index (Hill estimator).
- **Indirect inference** (Gourieroux, Monfort, Renault 1993): pick K that minimizes a weighted distance between auxiliary statistics from data vs. simulation. Formalizes what regime-switching papers often do informally.

## 4. Bayesian nonparametric (skip choosing K)

- **HDP-HMM** (Teh, Jordan, Beal, Blei 2006) and **sticky HDP-HMM** (Fox, Sudderth, Jordan, Willsky 2011): infinite-state HMM; K is inferred from data via a Dirichlet process prior.
- Reversible-jump MCMC over K (Robert, Ryden, Titterington 2000 for HMMs).

## 5. Posterior-clustering-aware criteria

- **ICL** (Biernacki, Celeux, Govaert 2000) penalizes entropy of the posterior; often preferred over BIC when state interpretability matters (it does, here).
- **Slope heuristic** (Birge-Massart; Baudry et al. 2012) for non-asymptotic penalty calibration.

## Recommended hybrid approach for the CHMM paper

A defensible procedure that is now standard in regime-switching work:

1. **Primary statistical criterion**: BIC or ICL (already in the paper).
2. **Predictive check**: held-out log-likelihood or CRPS on a rolling window.
3. **Stylized-fact check**: Wasserstein-1 distance between empirical returns and a long simulation from the fitted CHMM at each K, plus an L2 distance between empirical and model ACF of |r_t|.

## Implementation tasks (CHMM-Model repo)

- [ ] Add a script that, for each K in the candidate grid, simulates a long path from the fitted CHMM and computes:
  - W_1(empirical returns, simulated returns)
  - L2 distance between ACF of |r_t| (empirical vs simulated), out to some lag L
  - Optionally: MMD with a Gaussian or rational quadratic kernel
- [ ] Add rolling-origin CV log-likelihood and CRPS computation per K.
- [ ] Produce a comparison table: K vs {BIC, ICL, CV-loglik, CRPS, W_1, ACF-L2}.
- [ ] Add the table to the paper alongside the existing IC-based selection, with a short discussion of agreement/disagreement across criteria.

## Open questions

- Single-ticker or pooled-across-tickers evaluation?
- Window length and step for rolling CV.
- Whether to report sliced-Wasserstein for the joint (r_t, r_{t-1}) distribution to capture serial dependence, not just the marginal.
