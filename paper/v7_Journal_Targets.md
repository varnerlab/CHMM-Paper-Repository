# Potential Journals for Paper v7

*Continuous Hidden Markov Models for Equity and Volatility Index Dynamics: Gaussian, Student-t, and Laplace Emissions Trained by EM, with Cross-Asset SIM and Copula Extensions*

---

## Paper snapshot (for editor-fit assessment)

- **Core contribution.** A three-family EM-trained continuous HMM (Gaussian / Student-t / Laplace emissions) for synthetic financial time series; shows that a moderate state resolution (K=18) reproduces all three canonical Cont stylized facts without jumps or HSMM machinery, overturning the Rydén–Teräsvirta–Åsbrink 1998 low-K verdict.
- **Secondary contributions.** (i) Seven-metric fidelity panel (KS, AD, W1, Hellinger, excess kurtosis, absolute-return ACF-MAE, quantile coverage). (ii) Head-to-head against the prior discrete-HMM paper (Alswaidan & Varner 2026), GARCH(1,1), Laplace / Gaussian iid, block bootstrap, and a GRU + Gaussian-head deep baseline. (iii) VaR / ES back-test as a downstream utility consumer. (iv) Cross-asset extension with SIM, Gaussian / Student-t copulas on six-asset SPY subset. (v) VIX generalisation under the same pipeline.
- **Scale.** SPY 2014-01-03 → 2026-04-20 (T_IS = 2,516 ten-year training; T_OoS = 572); 413-ticker cross-asset universe; 1,000 simulated paths per model.
- **Length.** 52 pages compiled (main body ≈ 20 pages, supplemental ≈ 20 pages, references + 8 algorithms + figures).
- **Field crossroads.** Statistics / econometrics (EM, HMM, copula); computational finance (VaR, ES, regime-switching); synthetic-data / data-quality (fidelity metrics); machine learning (GRU baseline, deep generative context).
- **Reproducibility.** Public code repos, deterministic seeds, Julia-based; real Alpaca / historical Polygon data.

---

## Recommendation summary (sorted by fit)

| Tier | Venue | Scope fit | Length fit | Effort to reformat |
|---|---|---|---|---|
| Primary target | **JDIQ — ACM Journal of Data and Information Quality** (special issue: *Quality of Synthetic Data*) | ⭐⭐⭐⭐⭐ | Main-body ≤ 23 pp; supplementary unlimited | **Low** (paper is already written for this issue) |
| Strong alternative | **Quantitative Finance** (Taylor & Francis) | ⭐⭐⭐⭐⭐ | ≤ 30 pp typical | Moderate (trim supplemental) |
| Strong alternative | **Journal of Empirical Finance** (Elsevier) | ⭐⭐⭐⭐ | ≤ 35 pp | Moderate |
| Strong alternative | **Applied Stochastic Models in Business and Industry** (Wiley) | ⭐⭐⭐⭐ | ≤ 25 pp | Moderate |
| Strong alternative | **Journal of Applied Econometrics** (Wiley) | ⭐⭐⭐⭐ | ≤ 35 pp | Moderate-high (Rydén 1998 venue ⇒ natural rebuttal) |
| Backup | **European Journal of Operational Research (EJOR)** (Elsevier) | ⭐⭐⭐ | ≤ 30 pp | Moderate |
| Backup | **Computational Statistics & Data Analysis** (Elsevier) | ⭐⭐⭐ | ≤ 30 pp | Moderate |
| Backup | **Journal of Time Series Analysis** (Wiley) | ⭐⭐⭐ | ≤ 30 pp | Moderate |
| Backup | **Journal of Risk** (Incisive Media / Risk.net) | ⭐⭐⭐ | ≤ 30 pp | Moderate (re-angle around VaR/ES) |
| Backup | **International Journal of Forecasting** (Elsevier) | ⭐⭐⭐ | ≤ 25 pp | Moderate (emphasise forecasting/utility) |
| Backup | **Statistics and Computing** (Springer) | ⭐⭐⭐ | ≤ 25 pp | Higher (frame around EM/ECM methodology) |
| Conference (alt route) | **ACM ICAIF** (International Conference on AI in Finance) | ⭐⭐⭐⭐ | ≤ 10 pp short paper | High (major trim) |
| Conference (alt route) | **NeurIPS Workshop on AI in Finance** | ⭐⭐⭐ | ≤ 8 pp | High |

---

## Detailed analysis by venue

### 1. JDIQ — ACM Journal of Data and Information Quality (PRIMARY TARGET)

**URL.** [jdiq.acm.org](https://dl.acm.org/journal/jdiq)

**Fit rationale.**
- The paper is already oriented around JDIQ's special issue on *Quality of Synthetic Data* (editorial scope: "innovative quality metrics, relevant case studies, and novel SDG and DA methods that include quality guarantees by design"; fidelity / utility / privacy triad).
- The seven-metric panel maps directly onto JDIQ's "univariate / bivariate / multivariate / longitudinal similarity" taxonomy.
- VaR/ES utility back-test addresses the utility dimension.
- Explicitly scoped to note that privacy is not applicable (public market data).
- Already structured with main body (~20 pp) + supplementary material (~20 pp appendix), compatible with JDIQ's format.

**Fit caveats.**
- 52 pages total; must confirm with guest editors whether appendix can travel as supplementary PDF.
- Code availability (MIT-licensed Julia) is a direct positive.

**Status.** Under active preparation for this venue per `Review_v6_JDIQ.md`.

---

### 2. Quantitative Finance (Taylor & Francis)

**URL.** [tandfonline.com/journals/rquf20](https://www.tandfonline.com/journals/rquf20)

**Fit rationale.**
- Published Cont (2001) — the canonical reference for the stylized facts that this paper reproduces.
- Strong history of HMM / regime-switching / GARCH / jump-diffusion methodology papers.
- Welcomes computational-finance methodology with empirical evaluation.
- Accepts papers with a mix of theory and applied evaluation.
- Impact factor ≈ 1.8.

**Why this is a strong fit.**
- The paper's headline contribution (resolving Rydén et al.'s low-K verdict on Cont stylized facts) is directly aligned with QF's editorial scope.
- The three-emission-family comparison and copula extension are in scope.
- VaR / ES back-test speaks to QF's quantitative-finance readership.

**Reformat effort.**
- Trim supplemental to fit 25–30 page main body limit.
- Possibly split the VIX and copula sub-stories if the reviewers think the main contribution should be sharper.

---

### 3. Journal of Empirical Finance (Elsevier)

**URL.** [sciencedirect.com/journal/journal-of-empirical-finance](https://www.sciencedirect.com/journal/journal-of-empirical-finance)

**Fit rationale.**
- Empirical finance venue; fits the seven-metric panel + 10-year SPY evaluation + cross-asset extension.
- Regularly publishes regime-switching / HMM / GARCH variants on equity data.
- Open to time-series-model method papers with rigorous empirical evaluation.

**Fit caveats.**
- May prefer papers with stronger economic interpretation than pure distributional fidelity.
- Would recommend emphasising the VaR/ES downstream-utility section and adding one-paragraph economic framing in the introduction.

---

### 4. Applied Stochastic Models in Business and Industry (ASMBI, Wiley)

**URL.** [onlinelibrary.wiley.com/journal/15264025](https://onlinelibrary.wiley.com/journal/15264025)

**Fit rationale.**
- Published Abanto-Valle, Langrock, Chen & Cardoso (2017) on heavy-tailed SV-in-mean, which is explicitly cited in the paper's Related Work as the non-HMM analog of the emission-family choice.
- Specifically welcomes applied stochastic-modelling papers with real-data case studies.
- Langrock is on the editorial board and specialises in HMM / HSMM methodology — direct review-chain fit.

**Fit caveats.**
- Often requires tightening to ~25 pages main body.

---

### 5. Journal of Applied Econometrics (Wiley)

**URL.** [onlinelibrary.wiley.com/journal/10991255](https://onlinelibrary.wiley.com/journal/10991255)

**Fit rationale.**
- Published the original Rydén–Teräsvirta–Åsbrink (1998) paper whose low-K verdict the CHMM paper directly overturns.
- Publishing a structured rebuttal in the same venue has strong narrative value.
- Solid empirical-econometrics reputation with interest in regime-switching, HMM, and stylized facts.

**Fit caveats.**
- Slower turnaround.
- Reviewers tend to prefer stronger economic interpretation.

---

### 6. European Journal of Operational Research (EJOR, Elsevier)

**URL.** [sciencedirect.com/journal/european-journal-of-operational-research](https://www.sciencedirect.com/journal/european-journal-of-operational-research)

**Fit rationale.**
- Published Bae, Kim & Mulvey (2014) on regime-switching dynamic asset allocation, which the paper cites as the immediate downstream application.
- Broad acceptance of methodological papers with OR / finance applications.
- Impact factor ≈ 6.

**Fit caveats.**
- EJOR prefers papers with a clearer decision-making / optimisation angle; the paper would need to emphasise the utility-for-allocation story more prominently.

---

### 7. Computational Statistics & Data Analysis (CSDA, Elsevier)

**URL.** [sciencedirect.com/journal/computational-statistics-and-data-analysis](https://www.sciencedirect.com/journal/computational-statistics-and-data-analysis)

**Fit rationale.**
- Published Bulla & Bulla (2006) on HSMMs for stylized facts — another direct precedent the paper engages with.
- Broad statistical-computing audience; EM / ECM methodology is in scope.
- Interest in synthetic data quality is expanding.

**Fit caveats.**
- Would expect more methodological novelty on the EM algorithm side; the ECM + golden-section combination is known, so the framing would need to lean on the three-family unification + fidelity panel rather than on algorithmic novelty.

---

### 8. Journal of Time Series Analysis (JTSA, Wiley)

**URL.** [onlinelibrary.wiley.com/journal/14679892](https://onlinelibrary.wiley.com/journal/14679892)

**Fit rationale.**
- Time-series methodology venue.
- Accepts HMM / HSMM / regime-switching papers with rigorous statistical treatment.
- Could emphasize the sum-of-exponentials decay argument as the core time-series contribution.

**Fit caveats.**
- Prefers theoretical / asymptotic contributions over empirical evaluations; would need to strengthen theoretical section.

---

### 9. Journal of Risk (Incisive Media)

**URL.** [risk.net/journal-of-risk](https://www.risk.net/journal-of-risk)

**Fit rationale.**
- Directly scoped to VaR / ES / tail-risk methodology.
- Strong practitioner reach in risk management.
- Would highlight the paper's VaR/ES back-test as the headline contribution.

**Fit caveats.**
- Would require re-angling the abstract and introduction around the risk-measurement consumer rather than distributional fidelity.
- The seven-metric panel may be seen as secondary material.

---

### 10. International Journal of Forecasting (IJF, Elsevier)

**URL.** [sciencedirect.com/journal/international-journal-of-forecasting](https://www.sciencedirect.com/journal/international-journal-of-forecasting)

**Fit rationale.**
- Strong in time-series methodology with evaluation benchmarks.
- Published evaluations of TimeGAN and other synthetic-data generators.
- Quantile-coverage and ACF-MAE align with IJF's interest in calibration metrics.

**Fit caveats.**
- Prefers frameworks with explicit forecasting tasks; the paper is primarily generative rather than predictive.
- Would require adding a short forecasting-style validation (e.g., one-step-ahead density evaluation).

---

### 11. Statistics and Computing (Springer)

**URL.** [link.springer.com/journal/11222](https://link.springer.com/journal/11222)

**Fit rationale.**
- Published Peel & McLachlan (2000) on the robust mixture-modelling Student-t methodology that the paper builds on for CHMM-t.
- Liu & Rubin (1995) on ECM was published in Statistica Sinica, so this venue has a close methodological neighbourhood.

**Fit caveats.**
- Paper would need to lead with the unified EM scaffold (three M-step branches) as the primary algorithmic contribution and downplay the finance-application framing.

---

### 12. ACM ICAIF — International Conference on AI in Finance (alternative route)

**URL.** [ai-finance.org](https://ai-finance.org/)

**Fit rationale.**
- Published Assefa et al. (2020) and Kwon & Lee (2024), both cited in the paper.
- Synthetic-data-for-finance is directly in scope.
- Good conference-to-visibility ratio for the specific research community.

**Fit caveats.**
- 8–10 page short-paper format — would need very aggressive trim.
- Best used as a complementary "short version" with a journal paper at the primary target.

---

## Tiered submission strategy (recommended)

```
Primary:   JDIQ special issue (deadline 2026-03-01 per review file)
             ↓ if not accepted
Second:    Quantitative Finance
             ↓ if not accepted
Third:     Journal of Empirical Finance  OR
           Applied Stochastic Models in Business and Industry
             ↓ if not accepted
Fourth:    Journal of Applied Econometrics (structured rebuttal to Rydén 1998)
             ↓
Conf. option: ACM ICAIF short paper alongside the journal submission
```

**Parallel visibility option:** Post an arXiv preprint at submission time (Quantitative Finance category `q-fin.ST` or statistics category `stat.AP`) to lock priority. The prior paper (`arXiv:2603.10202`) already used this pattern.

---

## Venue-independent checklist before submission

- [ ] Confirm acronym definitions on first use (done in v7).
- [ ] Verify page-count policy against the target venue.
- [ ] Move appendix material to a supplementary file if the venue requires.
- [ ] Update references' DOIs if the venue's style requires.
- [ ] Include the reproducibility statement (seed, Manifest.toml pin) in a form the venue accepts (often a separate "Data and Code Availability" section).
- [ ] Check author-contributions statement format for the target venue.
- [ ] Check whether the venue accepts the `unsrtnat` bibliography style or requires its own.

## Summary

For this paper's specific combination of synthetic-data framework + financial application + utility evaluation, **JDIQ is the sharpest fit and the one that motivated the current framing**. The closest alternatives from the finance/econometrics side are **Quantitative Finance** and **Journal of Empirical Finance**; the closest from the statistics-methodology side are **Applied Stochastic Models in Business and Industry** and **Statistics and Computing**. The most strategic alternative is **Journal of Applied Econometrics** as a structured rebuttal to the Rydén (1998) verdict.
