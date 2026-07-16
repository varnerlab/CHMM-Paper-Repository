# Technical and Narrative Review

## Manuscript

**Continuous Hidden Markov Models for Equity Returns: Heavy-Tail Emission Families and Regime-Conditional Value-at-Risk**

Review date: 2026-07-16

## Overall assessment

**Recommendation: major revision before submission.**

The manuscript has a worthwhile empirical question, unusually extensive robustness work, a correct and useful spectral identity for positive lags, and commendably explicit caveats about finite-state memory, non-monotone numerical updates, cross-sectional copula composition, and non-stationarity. The compiled paper is visually clean and has no unresolved citations, references, or layout warnings.

The central problem is claim calibration. The paper repeatedly says that the CHMM *reproduces* the slow absolute-return ACF and that the spectral rank bound is non-binding at the typical ticker. The paper's own fitted eigenvalues and figures support a narrower conclusion: the CHMM improves the short- and medium-lag ACF error relative to an i.i.d. generator, but its mean ACF decays essentially to zero while the empirical curve remains positive. The cross-ticker rank diagnostic is performed at $K=18$ and does not establish that the bound is non-binding at $K=3$.

There is also a material selective-comparison problem in the VaR results. The repository contains a conditional MS-GARCH result at $K=4$ that passes both Christoffersen conditional coverage and the DQ test at both tail levels, including $p_{DQ}=0.588$ at 1%. That result is absent from the paper, while the conclusion says CHMM-N at $K=3$ was the only tested row not rejected at 1%. As written, that statement is false relative to the result bundle shipped with the manuscript.

The paper can become technically defensible without changing its basic contribution. The needed revision is to narrow the ACF and rank claims, incorporate the strongest conditional-risk comparator, standardize baseline fits, correct one identifiability citation, repair stale/internal inconsistencies, and substantially streamline the narrative.

## Highest-priority findings

### 1. The strict-tail VaR conclusion omits a stronger tested MS-GARCH result

**Severity: critical**

The conclusion states that CHMM-N at $K^\star=3$ was “the only tested row not rejected” by the DQ test at $\alpha=0.01$ (`sections/conclusion.tex:1`). The Results section similarly says that every other family/state-count row and both displayed contenders reject (`sections/results.tex:97-103`). That language is only true inside the selected CHMM/filtered-bootstrap/CAViaR panel.

The repository's `results/robustness/msgarch_conditional_var.csv` contains a directly relevant conditional-risk comparator:

| Model | K | α | Christoffersen-cc p | DQ p |
|---|---:|---:|---:|---:|
| MS-GARCH | 4 | 0.01 | 0.801 | 0.588 |
| MS-GARCH | 4 | 0.05 | 0.920 | 0.880 |

MS-GARCH $K=4$ therefore passes both reported conditional-coverage tests at both levels and is much farther from rejection than CHMM-N $K=3$ at $\alpha=0.01$ ($p_{DQ}=0.056$). The artifact also shows passing rows for other state counts/tests. MS-GARCH is the closest regime-switching risk comparator and is already part of the generator benchmark, so excluding its conditional VaR result materially biases the risk narrative.

**Required fix**

- Add the conditional MS-GARCH rows to the main VaR table or a clearly linked companion table.
- Replace “only tested row” with, at most, “only CHMM-family row in the displayed four-family panel.”
- Compare conditional-risk models on the same forecast origin, parameter-updating protocol, return convention, and test harness.
- Avoid a superiority claim unless a pairwise loss comparison (e.g. quantile loss with a valid forecast comparison test) supports it. Passing separate specification tests does not rank models.

### 2. “Reproduces the slow ACF decay” is contradicted by the fitted spectrum and figures

**Severity: critical**

The abstract, Results, Discussion, and Conclusion repeatedly use “reproduced,” “matched,” or “slow decay is already present” (`paper.tex:146`; `sections/results.tex:5`; `sections/discussion.tex:1`; `sections/theory.tex:10`; `sections/conclusion.tex:1`). The evidence supports improvement, not reproduction.

For SPY at $K=3$, Table S spectral diagnostics reports a dominant mode with $a\approx0.292$ and $\lambda=0.953$ (`sections/sensitivity_appendix.tex:75-108`). Its implied contribution is approximately:

| Lag | $0.292(0.953)^\tau$ |
|---:|---:|
| 20 | 0.1115 |
| 50 | 0.0263 |
| 100 | 0.00237 |
| 170 | 0.00008 |
| 252 | 0.0000016 |

At $K=18$, the dominant mode decays even faster $\lambda=0.929$. Figure S3(d) shows the empirical absolute-growth ACF staying around 0.03-0.06 through much of the 100-170 lag region. The $K=3$ comparison figure shows the mean simulated ACF reaching roughly zero by about lag 80 while the observed curve remains positive for long stretches. Much of the observed curve is above the simulation envelope at early and intermediate lags.

The reported ACF-MAE improves from roughly 0.063 for i.i.d. rows to 0.0462 for CHMM-N, a useful but modest reduction. The manuscript explicitly admits that its “tolerance” is not pre-registered and is defined relative to the i.i.d. floor (`sections/results.tex:5`). A lower average error does not establish that the slow-decay shape has been reproduced, especially when averaging equally over 252 noisy lags hides systematic underfit at economically important ranges.

**Required fix**

- Replace “reproduces/matches the slow decay” with “improves short- and medium-lag ACF fidelity relative to i.i.d. baselines but does not reproduce the long-lag empirical persistence.”
- Make the empirical-versus-simulated absolute-return ACF figure a main-text figure.
- Report horizon-specific errors (e.g. lags 1-20, 21-60, 61-126, 127-252), integrated signed bias, and confidence/envelope coverage, not only one 252-lag MAE.
- If “reproduction” is retained, state a pre-specified acceptance rule and show that it is satisfied out of sample and across tickers.
- Reframe the Rydén comparison as a partial improvement, not a reversal of the classical limitation.

### 3. The cross-ticker spectral result does not establish non-binding rank at $K=3$

**Severity: major**

The abstract says the rank bound “was not active at the typical ticker once a few states were used” (`paper.tex:146`). The conclusion makes this explicit as “not empirically active at the cross-ticker median once $K\ge3$” (`sections/conclusion.tex:1`). The evidence does not support that threshold.

The cross-ticker effective-rank diagnostic is computed at $K=18$. It reports a median dominant-mode share of 0.756, but also a median $n_{95}=6$ and $n_{99}=11$ (`sections/sensitivity_appendix.tex:110-133`). A $K=3$ model has only two non-unit modes. Thus the $K=18$ diagnostic cannot establish that a two-mode limit is non-binding; indeed, its own $n_{95}=6$ summary points in the opposite direction if interpreted literally. Comparing the dominant share with a “uniform null” of $1/17$ is not a test of whether the rank constraint binds.

The SPY-only $K=3$ result does show one dominant fitted mode, and the reported cross-ticker ACF-MAE is fairly flat across state counts. Those facts justify an SPY-specific or metric-specific statement, not the present cross-ticker rank conclusion.

**Required fix**

- Restrict the spectral conclusion to SPY unless the cross-ticker analysis is rerun at $K\in\{3,6,18\}$.
- At each $K$, report effective modal count, horizon-specific ACF error, and whether an additional allowed mode has non-negligible coefficient and improves held-out ACF fit.
- Do not use dominant-share-versus-uniform as evidence that a rank bound is slack.

### 4. The hybrid Student-t/GED stopping rule can return an unevaluated, lower-likelihood update

**Severity: major**

Algorithm 1 computes the observed-data likelihood from the forward pass **before** the current M-step, performs the M-step, checks convergence using the pre-M-step likelihood, and then returns the post-M-step parameters (`sections/algorithms_appendix.tex:103-151`). The appendix acknowledges that the returned parameters lag the likelihood by one M-step (`sections/algorithms_appendix.tex:26`).

For exact Gaussian/Laplace EM, the final M-step is monotone, so this is mostly bookkeeping. For Student-t and GED, monotonicity is explicitly not guaranteed. The procedure can therefore:

1. see a small pre-M-step likelihood change,
2. perform a harmful hybrid update,
3. stop, and
4. return parameters whose likelihood was never evaluated.

The text says that the “last finite-likelihood iterate” is restored, but the displayed algorithm does not track a best/evaluated iterate or show restoration.

**Required fix**

- Recompute the observed-data likelihood after every complete parameter update.
- Track and return the best evaluated finite-likelihood iterate.
- For hybrid blocks, reject/backtrack materially decreasing updates or clearly define a generalized-EM acceptance condition.
- Stop on relative likelihood change (or a scale-aware criterion), parameter change, and maximum-gradient/block improvement, rather than an absolute $10^{-4}$ likelihood difference alone.
- Update the pseudocode and convergence claims together.

### 5. The GARCH baseline is not canonical and changes the temporal ranking

**Severity: major**

The main table reports Gaussian GARCH(1,1) absolute-ACF MAE of 0.0490 and describes CHMM-N at 0.0462 as “on par” (`sections/results.tex:3`, Table 1). The extended appendix refits the same GARCH(1,1) on the same data/window and obtains 0.0309, while GARCH-t obtains 0.0316 (`sections/baselines_appendix.tex:129-145`). The appendix attributes the difference to optimizer and simulation draw.

A change from 0.0490 to 0.0309 is not Monte Carlo noise; it changes the substantive ranking on the paper's central temporal metric. The better GARCH fits materially outperform CHMM-N's 0.0462 on ACF-MAE. A benchmark should be represented by its strongest reproducible, converged fit, not by a weaker “headline pipeline” fit while a better fit is relegated to the appendix.

**Required fix**

- Select one canonical estimation procedure per baseline, use multi-start optimization, and report the best valid likelihood under a pre-declared rule.
- Use the same canonical fit in every table and artifact.
- Report parameter estimates, likelihood, stationarity constraints, and convergence status so the two GARCH results can be reconciled.
- Rewrite any statement implying CHMM is at parity on ACF after the canonical rerun.

### 6. The observed object is not an “excess return” and excludes dividends

**Severity: major**

The Methods define

\[
G_t=252\log(P_t/P_{t-1})-r_f
\]

and set $r_f=0$, using split-adjusted but not dividend-adjusted VWAP prices (`sections/methods.tex:4-9`). This is an annualized log **price** growth rate, not an excess return and not a total equity return. Setting the risk-free rate to zero does not make the series excess returns. Omitting dividends introduces ex-dividend price drops and creates cross-sectional differences tied to dividend policy, potentially affecting tails, state assignment, sector comparisons, and VaR.

The unusual 252x scaling also makes daily VaR values such as -4.56 look like -456% unless the reader remembers to divide by 252. The scaling does not affect kurtosis or ACF, but it does affect the interpretation of location, scale, VaR, and ES.

**Required fix**

- Rename $G_t$ “annualized log price growth” throughout, or use a genuine risk-free series and total-return-adjusted prices.
- Prefer unannualized daily log returns for daily VaR/ES, or report both daily percentage and annualized-log units.
- Run a dividend-adjusted/CRSP-total-return sensitivity, particularly for the sector panel and high-dividend names.
- State whether VWAP adjustment factors are applied consistently across vendors and corporate actions.

### 7. The identifiability proposition cites the wrong theorem

**Severity: major**

The appendix attributes the condition “full-rank transition matrix + linearly independent emission densities” for continuous-emission HMM identifiability to Allman, Matias, and Rhodes (`sections/supplementary.tex:32-38`). Their HMM theorem concerns **discrete observed states** and establishes generic identifiability. The same paper notes that a separate result is needed for parametric HMMs with possibly continuous observations.

The stated full-rank/linear-independence result for real-valued nonparametric emissions is directly associated with Gassiat, Cleynen, and Robin, who identify the model from three consecutive observations when the number of states is known.

**Required fix**

- Cite Gassiat, Cleynen, and Robin for the displayed continuous-emission proposition.
- State all needed conditions explicitly: known $K$, stationarity/initial-law setup, full-rank transition matrix, linearly independent emission measures, and label swapping.
- Keep Allman et al. as background for the tensor/Kruskal argument or discrete generic-identifiability result, not as the direct theorem citation.

Primary sources checked:

- [Allman, Matias, and Rhodes (2009)](https://www.cs.uaf.edu/~jrhodes/papers/Latent.pdf)
- [Gassiat, Cleynen, and Robin, arXiv:1306.4657](https://arxiv.org/abs/1306.4657)

## Statistical and internal-correctness findings

### 8. Strict-tail DQ inference is too confident for the event count

**Severity: major**

At $\alpha=0.01$ and $T=573$, only 5.7 breaches are expected. The DQ regression uses six coefficients (constant, four lagged hits, VaR) and asymptotic $\chi^2$ calibration (`sections/sensitivity_appendix.tex:255-278`). Some walk-forward rows contain zero, one, or two breaches. Calling this test categorically “higher power” and interpreting $p=0.056$ versus $p=0.017$ as separation is fragile without finite-sample calibration for the DQ statistic itself.

The manuscript calibrates Christoffersen power, not the DQ finite-sample size/power under the fitted forecast process. BH adjustment addresses multiplicity, not low-event asymptotics.

**Fix:** use a parametric/bootstrap DQ null, report exact or simulation-based coverage tests, emphasize quantile loss, and treat 1% results as exploratory. If BH is retained, discuss dependence among p-values generated from the same returns and nested model forecasts.

### 9. The KS “pass rate” is a weak headline metric and mechanically favors the empirical bootstrap

**Severity: moderate-major**

The paper correctly admits that the two-sample KS p-values are not calibrated under serial dependence (`sections/methods.tex:100-105`). Nevertheless, the pass rate is the dominant selection and comparison axis throughout. A pass rate is thresholded, depends heavily on sample size, reuses the same observed path for every simulated-path test, and does not quantify effect size. The empirical bootstrap is designed from the empirical distribution and therefore mechanically dominates this marginal test. The block-bootstrap correction changes absolute pass rates substantially (e.g. CHMM-N OoS from about 80% asymptotic to 58.6% at $L=20$).

The proper-score result is more sobering: the CHMM families, bootstrap, and GARCH are statistically indistinguishable on one-day marginal CRPS. That should be central to the interpretation.

**Fix:** lead with continuous effect-size/proper-score metrics and uncertainty; keep KS pass rate descriptive. Use held-out energy/Wasserstein/AD distances with bootstrap confidence intervals, and separate marginal fidelity from path/conditional fidelity.

### 10. There is a stale, direct contradiction about copula simulation noise

**Severity: moderate**

The current Results and cross-asset appendix say the Student-t minus Gaussian OoS MAE gap is stable over 20 paired seeds and not path-to-path noise (`sections/results.tex:70`; `sections/cross_asset_appendix.tex:176-177`). Later, the half-unit-grid paragraph says the same 0.209 versus 0.204 comparison is “inside the simulation-noise floor at $N_{\text{paths}}=200$” (`sections/cross_asset_appendix.tex:226`). Both cannot be true under the reported paired interval $[0.0050,0.0060]$.

**Fix:** delete or update the stale “inside the simulation-noise floor” sentence. Keep the important distinction that the paired interval measures Monte Carlo precision conditional on fixed fitted parameters, not sampling/generalization uncertainty.

### 11. Reproducibility paths and shipped artifacts are inconsistent

**Severity: moderate**

The paper references paths such as `results/diagnostics/engle_manganelli_dq_all_families.csv`, `results/diagnostics/bh_fdr`, and several `results/cross_asset/...` artifacts. Those paths do not exist in this repository; related files are under `results/robustness/`, and several headline artifacts (shared-$\nu$ results, full $K$-sweep, spectral raw outputs, all-family DQ rows) are absent. The README says the paper repository contains derived result tables referenced by the manuscript, which is not fully true.

**Fix:** either vendor every paper-facing artifact at the exact cited path or point to immutable URLs/commit paths in the companion repository. Add a machine-readable manifest mapping every table/figure to source artifact, runner, model-repository commit, data checksum, and seed.

### 12. The regime-conditional VaR construction needs an explicit equation

**Severity: moderate**

The paper describes the filter in prose but never prominently writes the predictive mixture and quantile that define its title contribution. Add, in Methods,

\[
\boldsymbol q_{t+1|t}=\boldsymbol\alpha_{t|t}\mathbf T,
\qquad
F_{t+1|t}(x)=\sum_{k=1}^K q_{t+1|t,k}F_k(x;\theta_k),
\]

\[
\operatorname{VaR}_{t+1|t}(\alpha)
=\inf\{x:F_{t+1|t}(x)\ge\alpha\}.
\]

Define the initialization at the IS/OoS boundary, the timing of the first forecast, the sign convention, root-finding tolerance, and whether equality counts as a breach.

### 13. “No sector effect” is inferred from non-significance

**Severity: moderate**

The text treats a non-significant ANOVA, including the 60-ticker expansion, as confirmation that there is no sector effect and that the result has “adequate power” (`sections/results.tex:68`; `sections/sensitivity_appendix.tex:67-70`). No power analysis, equivalence margin, or confidence interval on sector variance is reported. Failure to reject does not demonstrate absence.

**Fix:** report effect sizes and confidence intervals, use a hierarchical/random-effects model, or state simply that the study did not detect a sector effect.

### 14. The Bulla comparison should distinguish squared from absolute returns

**Severity: minor-moderate**

Bulla and Bulla's headline result concerns slow decay in the ACF of **squared** returns, while this manuscript evaluates **absolute** returns. The mechanisms are related, and the appendix correctly notes the fourth-moment condition for squared returns, but the Related Work/Introduction sometimes reads as if the exact target were identical.

**Fix:** explicitly say that Bulla and Bulla improve the squared-return ACF and explain why the paper uses absolute returns instead. The distinction matters for Student-t states with ν ≤ 4.

Primary sources checked:

- [Rydén, Teräsvirta, and Åsbrink (1998)](https://onlinelibrary.wiley.com/doi/abs/10.1002/%28SICI%291099-1255%28199805/06%2913%3A3%3C217%3A%3AAID-JAE476%3E3.0.CO%3B2-V)
- [Bulla and Bulla (2006), DOI 10.1016/j.csda.2006.07.021](https://doi.org/10.1016/j.csda.2006.07.021)

## Narrative flow and presentation

### What works

- The paper is candid that the CHMM is not a new model class.
- The split between temporal modes and marginal emission flexibility is a clear organizing idea.
- The appendix's τ ≥ 1 spectral derivation, lag-zero caveat, complex-eigenvalue discussion, and fourth-moment condition are technically careful.
- The cross-asset section clearly admits that rank reordering destroys serial dependence and yields a cross-sectional construction, not a multivariate time-series generator.
- The walk-forward stress failures and stationarity limits are reported rather than hidden.
- The compiled 77-page PDF is typographically clean, with readable tables and no unresolved references or LaTeX warnings.

### What needs restructuring

1. **The abstract is overloaded.** It contains the historical claim, framework, theorem, four evaluation universes, spectral diagnosis, emission result, VaR result, copula result, two stronger baselines, and scope caveat in one dense block. Reduce it to question, method, two quantitative results, and the main limitation. Do not claim ACF reproduction.

2. **The core ACF evidence is buried.** The manuscript's defining empirical claim depends on Figure S3 and the $K=3$ ACF comparison, yet neither is in the main body. Move the empirical and fitted absolute-ACF figure into Results, adjacent to the claim.

3. **Results mix four papers.** State selection, emission-family comparison, spectral diagnosis, cross-ticker transfer, copula construction, and conditional VaR each receive a compressed paragraph. Use explicit subsections with one question and one takeaway each.

4. **Discussion repeats Results.** The first Discussion paragraph re-lists most table values. Replace numerical recap with interpretation: what the data support, what remains unresolved, and how the finding differs from Rydén/Bulla.

5. **The Conclusion is too long and introduces new analysis/future work.** It currently functions as another discussion section. End with three bounded conclusions and move the five extension proposals to a separate “Limitations and future work” subsection.

6. **The modular model story is unclear.** The preferred marginal generator is shared-$\nu$ CHMM-t, the cross-asset head uses CHMM-N marginals, and the risk panel emphasizes CHMM-N plus penalized per-state CHMM-t. Make clear that these are separate module demonstrations, not one end-to-end fitted specification that wins every task.

7. **Captions are too long.** Table 1's caption is nearly a methods paragraph. Move estimator caveats and baseline descriptions into surrounding prose or footnotes.

8. **Related Work is encyclopedic rather than argumentative.** Organize it around the three decisions the paper studies: duration/memory, emission tails, and downstream risk/dependence. Cut architecture lists that are not used in the empirical comparison.

9. **Use “continuous-emission HMM” consistently.** “Continuous HMM” can be read as a continuous-state latent model; the manuscript's hidden state is finite and discrete.

## Suggested defensible headline after revision

> On SPY and a US-equity panel, low-state continuous-emission HMMs improved marginal and short-to-medium-horizon volatility-clustering fidelity relative to i.i.d. generators, while heavy-tailed emissions reduced the Gaussian mixture's tail mismatch. The models did not reproduce the full long-lag absolute-return ACF and degraded under regime introductions. A filtered CHMM VaR achieved acceptable 5% conditional coverage in stable windows, but did not dominate the strongest MS-GARCH conditional-risk comparator.

That is still a meaningful paper. It is also much closer to what the present evidence actually establishes.

## Proposed revision order

1. Incorporate the conditional MS-GARCH VaR rows and rewrite all “only tested row” language.
2. Narrow the ACF reproduction claim and move the ACF comparison into the main text.
3. Correct the cross-ticker rank inference or rerun the modal diagnostic at $K=3,6,18$.
4. Fix and rerun the Student-t/GED likelihood acceptance and stopping logic.
5. Canonicalize the GARCH fits and rebuild all comparison tables from one artifact manifest.
6. Correct the return/excess-return/dividend definition and run a total-return sensitivity.
7. Correct the identifiability citation and delete stale copula-noise wording.
8. Add explicit predictive-VaR equations and finite-sample strict-tail calibration.
9. Restructure and shorten the paper.

## Review scope

This review checked the LaTeX source, compiled PDF, visible figures, bibliography linkage, and CSV artifacts shipped in this repository. It verified internal numerical consistency where the relevant artifacts were present. It did **not** rerun the companion `CHMM-Model-Repository`, inspect proprietary source data, or independently reproduce model fits; claims depending on absent companion artifacts remain reproducibility risks rather than independently verified results.
