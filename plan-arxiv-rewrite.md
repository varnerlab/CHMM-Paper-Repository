# Plan: arXiv Rewrite of the CHMM Paper

## Goal

Restructure the CHMM paper for an arXiv preprint, mimicking the framing style of the Varner-group papers ([Wheeler-Varner 2023](https://arxiv.org/abs/2312.14903), [Alswaidan-Varner 2026](https://arxiv.org/pdf/2603.10202), [Wheeler-Varner 2024](https://arxiv.org/abs/2411.16585)). Main body capped at 20 pages. Static 10y IS / 2.5y OoS protocol throughout. No specific journal target.

## Framing style to mimic (Alswaidan-Varner 2026, arXiv:2603.10202)

Abstract recipe:
1. Operational motivation (stress testing, risk model validation, scenario design).
2. Gap (existing methods cannot *simultaneously* reproduce all three Cont stylized facts).
3. Contribution (one mechanism, named).
4. Estimation (one sentence).
5. Headline result (SPY, 10y data, IS + OoS distributional pass rates, named benchmarks).
6. Honest accounting ("no single model was best at everything"; name what each benchmark does well).
7. Multi-asset extension (copula vs factor model).

Body arc: stake the three stylized facts up front, derive the mechanism, evaluate honestly, name limitations cleanly. Tables compact and joint. Heavy emphasis on **stylized-fact reproduction** as the unifying axis.

## Section-by-section plan

Target ~17 pages main body, ~3 pages headroom under the 20-page cap.

### Abstract (~250 words)

Follow the recipe above. Drop the rolling-origin sentence. Replace with the honest-accounting sentence on emission-family kurtosis trade-offs (CHMM-N undershoots, CHMM-t overshoots, CHMM-L matches cleanly).

### §1 Introduction (~1.5 pages, 5 paragraphs)

1. Operational motivation. Cite `alswaidan2026hybrid`, `jordon2022synthetic`, `assefa2020generating`.
2. The three stylized facts (`mandelbrot1963variation`, `cont2001empirical`).
3. The Rydén-Teräsvirta-Åsbrink (1998) negative result + Bulla-Bulla (2006) HSMM fix; state as the stake.
4. Thesis: spectral identity, K-rank statement on T, moderate-K continuous HMM closes the ACF gap.
5. Contributions (5 bullets): spectral identity; three emission families under unified ECM; SPY 10y empirical study; multi-asset Student-t copula extension; companion Julia package.

### §2 Related Work (~1 page, 4 short paragraphs)

- HMM in finance (`hamilton1989new`, `ryden1998stylized`, `bulla2006stylized`, `nystrup2017long`).
- GARCH family (`engle1982autoregressive`, `bollerslev1986generalized`, `nelson1991conditional`, `glosten1993relation`, `corsi2009simple`).
- Deep generative for finance (`yoon2019timegan`, `wiese2020quantgan`, `rasul2021autoregressive`).
- Synthetic-data evaluation (`stenger2024thinking`, `gretton2012kernel`, `chevyrev2016primer`, `ni2020conditional`, `gneiting2007strictly`).

### §3 Data and Model (~3 pages)

1. Data and excess growth rates. SPY 2014-01-03 → 2024-01-03 IS (T=2516); OoS 2024-01-04 → 2026-04-20 (T=572). State explicitly: returns assumed locally stationary over the 10y IS window.
2. CHMM definition (existing TikZ figure).
3. Benchmark generators (golden-standards list, see below).
4. Pipeline A / Pipeline B (existing schematic).
5. Evaluation protocol and metrics (named with citation).

### §4 Estimation (~1.5 pages)

Forward-backward in log space, quantile-based initialization, per-family M-step (Gaussian closed-form, Student-t ECM with golden-section, Laplace closed-form weighted-median). Pseudocode pointer to appendix.

### §5 Theoretical Mechanism (~1.5 pages)

Spectral identity ρ_|G|(τ) = Σ w_k λ_k^τ. K=2 mono-exponential, K≥3 decouples. Identifiability proposition (`allman2009identifiability`); MLE consistency reference (`bickel1998asymptotic`, `doucmoulinesryden2004`).

### §6 Empirical Study (~6 pages, 6 subsections)

- 6.1 Headline single-asset panel (SPY). Table 1: 7-9 generators, 4-5 metric columns. KS IS/OoS, kurtosis, ACF-MAE, CRPS+DM. Honest-accounting paragraph.
- 6.2 State-count selection. K=3 (held-out-LL) vs K=18 (tail-fidelity), two operating points.
- 6.3 Cross-ticker generalization. Table 2, CHMM-t at K=18 across 6 tickers. JPM/NVDA OoS cliff flagged as limitation, not remediated.
- 6.4 VaR + Expected-Shortfall envelope (downstream utility). Kupiec UC + Christoffersen IND.
- 6.5 Multi-asset cross-asset dependence. Student-t copula on CHMM-N marginals.
- 6.6 Price simulation (nice-to-have, optional in main; push to appendix if page-tight).

### §7 Discussion (~2 pages, 6 paragraphs)

1. Mechanism summary.
2. Replicating slow-ACF at moderate K (refutes Rydén).
3. KS power ceiling.
4. Closing the kurtosis gap with heavy-tailed emissions.
5. Stationarity scope. Cite `pastorstambaugh2001equity`, `andreouhgysels2002breaks`, `angtimmermann2012regime`, `pesarantimmermann2007window`, `cappe2011online`. Recommend periodic refit for deployment without claiming new evidence.
6. Why Student-t copula beats SIM. Limitations.

### §8 Conclusion (~0.5 pages)

Mechanism summary, headline numbers, multi-asset, future work, code-and-data availability.

### Appendix

Algorithm pseudocode, sensitivity sweeps, KS power calibration, MMD/AUC/sig-MMD, full Pipeline-B SIM panel, full extended GARCH panel, full price-simulation panels.

## Golden-standard benchmarks for a 2026 synthetic-return-generator paper

| Tier | Generator | Citation | Main panel? |
|---|---|---|---|
| 1 Classical (must) | iid bootstrap | `politis1994stationary` | yes |
| | Gaussian iid | n/a | yes |
| | GARCH(1,1) Gaussian | `bollerslev1986generalized` | yes |
| 2 Extended volatility | GARCH(1,1)-t | `bollerslev1987conditionally` | yes |
| | EGARCH | `nelson1991conditional` | appendix |
| | GJR-GARCH | `glosten1993relation` | appendix |
| | HAR-RV | `corsi2009simple` | appendix |
| 3 Regime-switching foil | MS-GARCH | `haas2004new` | yes |
| | HSMM | `bulla2006stylized` | appendix |
| 4 Deep generative | QuantGAN | `wiese2020quantgan` | appendix (only MMD/AUC computed) |
| | TimeGAN | `yoon2019timegan` | appendix |
| | TimeGrad | `rasul2021autoregressive` | appendix |
| | Sig-WGAN | `ni2020conditional` | appendix |
| Contribution | CHMM-N, CHMM-t, CHMM-L | this paper | yes |

## Statistical fidelity tests (main body)

- Two-sample Kolmogorov-Smirnov (`kolmogorov1933`, `smirnov1948`).
- Anderson-Darling (`anderson1952ad`).
- ACF-MAE on |G_t| over 252 lags.
- Mean simulated excess kurtosis vs observed.
- MMD with fixed Gaussian-kernel bandwidth (`gretton2012kernel`).
- CRPS + Diebold-Mariano (`gneiting2007strictly`, `gneiting2014probabilistic`, `diebold1995comparing`).

Drop sig-MMD and discriminator AUC from main; appendix only.

## Downstream utility tests (main body, §6.4)

- VaR + Kupiec UC at α ∈ {1%, 5%} (`kupiec1995techniques`).
- VaR + Christoffersen IND (`christoffersen1998evaluating`).
- Expected-Shortfall envelope (median + 5/95%) (`mcneil2015quantitative`).

Bonuses (push to appendix or skip): TSTR HAR-RV QLIKE, discriminator AUC, simulated-strategy Sharpe.

## Price simulation (nice-to-have)

Terminal-price distribution coverage at multiple horizons. One figure max in main, full panels in appendix.

## Execution order

1. Strip rolling-origin and walk-forward from both repos (Option A from prior conversation).
2. Promote one extended-GARCH and one MS-GARCH row to the headline panel (data already exists).
3. Restructure abstract per Varner recipe.
4. Restructure introduction into 5 paragraphs per recipe.
5. Restructure related work into 4 short paragraphs per recipe.
6. Add evaluation-protocol-only intro paragraph at top of §6.
7. Tighten discussion stationarity paragraph with `pesarantimmermann2007window`, `pastorstambaugh2001equity`, `angtimmermann2012regime`, `cappe2011online`.
8. Add new references to references.bib.
9. Build PDF and verify ≤ 20 pages main body.
