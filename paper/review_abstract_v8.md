# Review: Paper_v8 Abstract

**File:** `Paper_v8.tex` (lines 51-62)
**Reviewer:** Abdulrahman Alswaidan (via review pass)
**Date:** 2026-04-21
**Decision:** CUT. The abstract is too long and should be reduced by roughly 45-55%.

## 1. Current State

- 12 sentences spanning ~520 words.
- Conference/journal abstracts typically target 150-250 words (ICAIF, JFE, QF all sit in this range).
- Current draft reads as a compressed introduction, not an abstract.

## 2. What Is Wrong (Sentence by Sentence)

| # | Content | Issue |
|---|---------|-------|
| S1 | CHMM family for synthetic series preserving stylized facts | Keep. Core framing. |
| S2 | CHMM-N, CHMM-t, CHMM-L with golden-section ECM, weighted-median, MAD | Too technical. Methodological minutiae belong in Section 3. |
| S3 | Shared log-space FB + quantile init | Marginal. Can be cut or folded into S2. |
| S4 | Comparison vs discrete baseline + K=18 selection logic | Keep the novelty claim. Cut the IC + seven-metric justification parenthetical. |
| S5 | SPY data + 8-baseline enumeration + 7-metric enumeration | Overloaded. Replace explicit list with a category summary. |
| S6 | Kurtosis numbers (5.02, 6.76, 7.68, 17.34, 10.24, 5.29) | Too many point estimates. Report one headline finding, not six. |
| S7 | Per-state nu_k diagnostic + VaR/ES back-test | Diagnostic depth does not belong in abstract. Keep the VaR/ES mention as a deliverable. |
| S8 | Cross-asset tickers + JPM walk-forward | Drop ticker list. Keep "cross-asset generalization" claim briefly. |
| S9 | SIM + Gaussian / Student-t copulas with citations | Keep but drop S9+S10+S11 citations from abstract (venue-dependent, but most strip refs). |
| S10 | Six-asset copula numbers (96.0-97.8, 78.5, 0.027, 0.031, 0.076, nu*=6) | Too numeric. Report one comparison. |
| S11 | "Option pricing is explicitly out of scope" | Delete. If it is out of scope, it should not appear in the abstract at all. |

## 3. Structural Issues

1. **Citations in the abstract.** `\citep{peel2000robust, liu1995ml, alswaidan2026hybrid, nguyen2018hidden, yoon2019timegan, sharpe1963simplified, sklar1959fonctions, demarta2005tcopula}`. Most conference abstracts (ICAIF included) recommend no citations, or at most one self-reference. This alone bloats the text.
2. **Acronym expansion.** ETF, SPY, GARCH, GRU, ECM, MAD, MLE, ACF-MAE, VaR, ES, SIM, KS, AD all defined inside the abstract. Many can be left as acronyms (GARCH, ETF, ACF, VaR, ES are standard) or deferred to main text.
3. **Number density.** S6 and S10 together contain 14 numeric values. Reader cannot retain these from an abstract. Report at most 3-4 headline numbers.
4. **Two-step narrative.** The abstract tries to tell the univariate story AND the multi-asset story at full depth. One of these must be compressed to a single sentence.

## 4. Optimization Plan

### 4.1 Target structure (5-6 sentences, ~220 words)

1. **Contribution sentence.** Introduce the CHMM family (N, t, L) and name what it eliminates vs the discrete baseline (jump mechanism, binning, two hyperparameters).
2. **Method sentence.** One line: EM-trained location-scale emissions with log-space forward-backward, no per-variant methodological detail.
3. **Evaluation sentence.** SPY, ten years, in-sample and out-of-sample, benchmarked against a suite of non-parametric, classical parametric, discrete-HMM, and deep-generative models under seven distributional and autocorrelation metrics. Drop the explicit 8-baseline roll call and the 7-metric roll call.
4. **Headline univariate result.** One sentence: heavy-tailed variants close the kurtosis gap that CHMM-N leaves open, at unchanged ACF and tail pass-rate fidelity. At most two numbers.
5. **Cross-asset + multi-asset result.** One sentence: generalization to other equities plus copula-based multi-asset synthesis that outperforms a single-index baseline on per-asset fit and correlation reproduction. Single comparison number acceptable.
6. **Optional deliverable sentence.** VaR/ES back-test as validation of tail behavior.

### 4.2 Cuts (definite)

- S3 (fold into S2).
- Parenthetical K=18 selection justification in S4 (move to methods).
- Explicit baseline list in S5 (replace with categories).
- Numeric kurtosis detail in S6 (keep qualitative closure of the gap).
- Per-state nu_k diagnostic in S7 (move to empirical study).
- Ticker list in S8 (replace with "five additional equities").
- All point estimates in S10 except one headline comparison.
- S11 entirely ("option pricing out of scope" does not belong).
- All eight `\citep{...}` references from within the abstract.

### 4.3 Cuts (consider)

- CHMM-L vs CHMM-t split at abstract level: could say "heavy-tailed variants" and defer the Student-t / Laplace distinction to the body. Recommendation: keep the split, it is a core contribution, but describe it in one clause not two sentences.
- Walk-forward re-estimation detail on JPM: move to empirical section. Abstract reader cannot evaluate "15 percentage points" without knowing the baseline.

### 4.4 Keeps (non-negotiable)

- The three-variant framing (N, t, L).
- The "no jump mechanism needed" claim vs the discrete HMM baseline.
- In-sample and out-of-sample distinction.
- Multi-asset extension as a second contribution.
- VaR/ES mention as tail validation (but trimmed).

## 5. Proposed Rewrite (Draft, ~215 words)

> We present a family of continuous hidden Markov models (CHMMs) for synthetic financial time series that preserve the canonical stylized facts of asset returns. Three variants share log-space Expectation-Maximization training over a common quantile-initialized transition matrix and differ only in their per-state emission law: Gaussian (CHMM-N), Student-t with data-selected degrees of freedom (CHMM-t), and Laplace (CHMM-L). At a single moderate state resolution the continuous models reproduce heavy tails, negligible linear autocorrelation, and persistent volatility clustering without the Laplace quantile binning or the Poisson jump-duration mechanism required by the prior discrete-state framework, eliminating two tunable hyperparameters.
>
> On ten years of daily SPY data, we benchmark the three variants against a suite of non-parametric, classical parametric, discrete-HMM, and deep-generative alternatives under seven distributional and autocorrelation metrics, in both in-sample and out-of-sample windows. The heavy-tailed variants close the residual kurtosis gap left by CHMM-N while retaining its autocorrelation and tail-pass-rate fidelity, and a Value-at-Risk and Expected Shortfall back-test validates the improvement at the $1\%$ and $5\%$ levels. We extend the framework to multi-asset synthesis through Single Index Model and Gaussian / Student-t copula generators; on six equities the copulas substantially outperform the single-index baseline on both per-asset fit and correlation reproduction.

Word count: ~215.
Citations: 0.
Numeric values: 2 (the two VaR/ES confidence levels).
Acronyms requiring definition: CHMM (defined), SPY (standard ticker), VaR and ES (standard).

## 6. Summary of Recommendation

| Element | Current | Proposed |
|---------|---------|----------|
| Word count | ~520 | ~215 |
| Sentences | 12 | 6 |
| Citations | 8 | 0 |
| Numeric point estimates | 14 | 2 |
| Scope disclaimer | Present | Removed |
| Baseline enumeration | Explicit list | Category summary |
| Metric enumeration | Explicit list | Category summary |

The abstract should state what the paper contributes, what was measured, and what was found, at a level of detail a reader can retain in one pass. Everything cut here is preserved in the main text where it has room to breathe.
