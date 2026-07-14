# Technical correctness and narrative audit

Audit date: 2026-07-14

Manuscript audited: paper.tex, sections/*.tex, and the compiled 71-page paper.pdf.

Companion implementation audited: varnerlab/CHMM-Model-Repository, commit c3eb08d320a5ab6a9d8b9977898d7d093e97ea13 (cloned 2026-07-14).

## Executive assessment

The paper has a defensible central empirical observation: on the reported SPY fits, increasing the number of HMM decay modes beyond a small state count contributes less than changing the emission family. The spectral ACF identity used to frame that observation is correct for positive lags under the assumptions stated. The manuscript also does a better-than-usual job of acknowledging stationarity limits, poor stress-window results, the descriptive nature of the serially dependent KS score, and the finite-mode limitation of an HMM.

The draft is not yet technically ready for submission without revision. Four issues affect central claims:

1. The copula rank-reordering construction destroys the temporal ordering of each simulated CHMM path. It preserves the empirical univariate distribution but is not shown to preserve CHMM ACF or regime dynamics.
2. The claim that a three-Gaussian mixture cannot attain the observed heavy tail “no matter how the state weights or means are tuned” is mathematically false.
3. The state-count selection runners use close-to-close growth rates, whereas the headline model and data definition use VWAP-to-VWAP growth rates. The evidence selecting K*=3 is therefore not a like-for-like validation.
4. The claimed Gaussian-versus-Student-t copula distinction is not established by the reported bootstrap. It simulates from the fitted Student-t copula and refits only on a finite nu in [3,12] grid, so it cannot test the Gaussian limit nu -> infinity.

The paper can likely be repaired without abandoning its univariate empirical result. The multi-asset claim needs either a different construction or a sharply narrower description as a cross-sectional dependence experiment rather than a multivariate time-series generator.

## Priority findings

### P0. Copula rank reordering preserves values but destroys CHMM time dependence

**Evidence.** Algorithm 3 in sections/algorithms_appendix.tex:194-211 independently simulates a CHMM path for asset j, sorts it into order statistics, then assigns the sorted values to the time ranks of an i.i.d. copula sample. The implementation does the same in src/CrossAsset.jl:483-517 of the companion repository. Because copula ranks are i.i.d. over time, this is a random temporal permutation of the CHMM values, subject to contemporaneous cross-asset ranks.

**Why this matters.** A temporal permutation preserves the finite-sample empirical CDF exactly, as Proposition 2 correctly states, but generally removes the original path's serial ACF, regime residence pattern, and volatility clustering. The output supports contemporaneous correlation and per-asset KS comparisons; it is not demonstrated to retain the univariate CHMM dynamics. This undercuts “cross-asset path tensor,” “multi-asset version,” and “copula composition” when read as preserving both temporal and contemporaneous dependence.

**Required correction.**

- Replace rank reordering with a joint dynamic construction, such as a copula on filtered innovations/PIT residuals while each marginal filter advances in time, a coupled latent-state process, or another method explicitly preserving serial dependence; or
- narrow the claim to a cross-sectional distribution/dependence experiment and state that temporal dependence is not preserved after reordering.

In either case, report post-composition per-asset |G| ACF-MAE and raw-return ACF-MAE.

### P0. The finite-Gaussian-mixture impossibility claim is false

**Evidence.** sections/discussion.tex:1 says a mixture of three Gaussians “cannot reach the observed heavy tail no matter how the state weights or means are tuned.” Similar structural language appears elsewhere.

**Why this matters.** Even a two-component Gaussian scale mixture can have arbitrarily large kurtosis: place a small positive weight on a component with sufficiently large variance. Separated means can also raise fourth moments. A finite Gaussian mixture is asymptotically light-tailed, but its kurtosis is not bounded at the reported value. The fitted three-state ML model failed to attain the observed sample kurtosis; that is an empirical result, not a mathematical impossibility.

**Required correction.** Say: “Under the fitted maximum-likelihood three-state specification, CHMM-N underestimates the observed sample excess kurtosis.” If the intended claim concerns regular variation, say that every finite Gaussian mixture remains asymptotically light-tailed and cannot reproduce a genuine power-law tail.

### P0. The reported bootstrap does not test the Gaussian-copula limit

**Evidence.** runners/cross_asset/run_copula_profile_ci_halfunit.jl:47-48 restricts refits to nu = 3:0.5:12. Lines 71-101 simulate every bootstrap sample under the fitted Student-t copula and take a percentile interval of the grid maximizer. sections/cross_asset_appendix.tex:195 then says [6,7] makes the Student-t copula statistically distinguishable from the Gaussian limit.

**Why this matters.** The Gaussian limit is absent from the refit grid. A percentile bootstrap generated under nu=6.5 estimates sampling variability around that finite fitted value; it is not a null bootstrap under the Gaussian copula. The phrase “lower bound at 6.0 sat well above the Gaussian limit” also reverses the parameter ordering: infinity is above every finite bound.

**Required correction.** Remove the significance claim, or conduct a boundary-appropriate comparison: include a Gaussian likelihood, define a likelihood-ratio or other statistic, simulate its null distribution under the fitted Gaussian copula, and compare the observed statistic with that distribution. The finite-nu profile interval can remain as uncertainty conditional on the Student-t family.

### P1. State-count selection uses a different price field from the headline analysis

**Evidence.** The manuscript defines session-VWAP growth rates (sections/methods.tex:4-9), and headline runners use log_growth_matrix with its default volume_weighted_average_price field (src/Compute.jl:1278-1353). The central K-selection runners instead load spy_is.close:

- runners/robustness/run_k_selection_kfold_pre2020.jl:70-91;
- runners/robustness/run_k_selection_kfold_h12y_pre2020.jl:69-90;
- runners/robustness/run_k_selection_validation_pre2020.jl:54-78;
- root run_k_selection_validation.jl:59-82.

**Why this matters.** The chosen state count is justified by held-out likelihood and BIC from close returns, while fitted parameters, tables, VaR, and spectral diagnostics use VWAP returns. Close and VWAP returns differ especially on volatile days relevant to state resolution and tails. The manuscript presents the selection as if it used the headline series.

**Required correction.** Re-run every state-count selection design on the VWAP series, including the boundary price needed to form the first validation return. If K*=3 remains selected or indistinguishable from K=6, update CSVs and text. Otherwise revise the chosen count and sensitivity framing.

### P1. The Student-t degrees-of-freedom update is not the ECME step claimed

**Evidence.** The manuscript describes the nu_k update as maximizing observed-data likelihood directly (sections/methods.tex:77-89; sections/algorithms_appendix.tex:28-47). The code instead maximizes sum_t gamma_t(k) log t_nu(O_t; mu_k, sigma_k), holding gamma fixed (src/Compute.jl:459-489).

**Why this matters.** This weighted component objective is neither the full observed HMM likelihood, which requires recomputing the forward likelihood as nu changes, nor the standard augmented complete-data Q function containing E[u] and E[log u]. Calling it an ECME observed-likelihood maximization is inaccurate. Exact ascent would not follow even with an exact one-dimensional optimizer.

**Required correction.** Implement a true ECME block that evaluates the full forward observed-data likelihood for each candidate nu_k, or relabel the method as a generalized/approximate block-coordinate update and remove claims tying it to ECME ascent. Report the final forward likelihood after the returned post-update parameters.

### P1. Gaussian Baum-Welch does not update the initial distribution described in the paper

**Evidence.** Algorithm 1 specifies pi_new = gamma_1 (sections/algorithms_appendix.tex:20-24,127), and Methods says (T, theta, pi) are learned jointly. The Gaussian fitter initializes curr_pi uniformly and never updates it (src/Compute.jl:306-401). Student-t, Laplace, and GED do update it (src/Compute.jl:553,687,878).

**Why this matters.** The unified algorithm is not the implemented Gaussian algorithm. It also creates a parameter-count inconsistency: sections/discussion.tex:7 counts 12 free CHMM-N parameters at K=3, correct if pi is fixed but 14 if the stated pi is estimated. BIC depends on that choice.

**Required correction.** Choose one specification and make code, algorithm, and BIC counts agree. For a stationary series, fixing pi to the stationary distribution is cleaner than estimating a separate initial vector; fixed uniform pi is a different restriction and should be stated if retained.

### P1. The OoS construction omits the return into the first held-out date

**Evidence.** Stored SPY data contain 2,517 IS prices from 2014-01-03 through 2024-01-03 and 573 OoS prices from 2024-01-04 through 2026-04-20. log_growth_matrix differences each dataset separately, producing 2,516 and 572 returns. Thus the OoS vector begins with the 2024-01-04-to-2024-01-05 return; the 2024-01-03-to-2024-01-04 return is omitted. The VaR runner concatenates these already-differenced vectors (run_conditional_var_all_families.jl:146-155), so its first forecast skips one observation.

**Why this matters.** Sample sizes are reproducible, but the text says evaluation begins January 4, 2024. It actually begins with the return dated January 5 if returns are assigned to their ending date. Only the first VaR forecast is directly misaligned, but boundary handling should be exact.

**Required correction.** Prepend the last IS price to the OoS price vector and difference once. Decide whether T_OoS counts dates or returns. Re-run OoS tables if the boundary return changes a breach count or tail statistic.

### P1. “Full one-shot MLE” is not a joint maximum-likelihood estimator

**Evidence.** sections/baselines_appendix.tex:231-248 calls the procedure a coordinate-ascent MLE jointly maximizing over (Sigma,nu). In code, the nu step maximizes likelihood but the Sigma step is a method-of-moments correlation update with PSD projection (run_full_tcopula_mle.jl:81-100,129-143). The code itself calls this pseudo-likelihood.

**Why this matters.** A moment replacement is not an argmax over Sigma and need not increase likelihood. The output cannot validate the two-step estimator by comparison with a claimed joint MLE.

**Required correction.** Rename it “iterated pseudo-likelihood/moment estimator,” report whether each iteration increases likelihood, and remove “full one-shot MLE.” Alternatively optimize a valid unconstrained correlation-matrix parameterization jointly with nu.

## Statistical interpretation findings

### P1. Non-rejection is repeatedly written as validation or a “pass”

The abstract, results, and conclusion say the VaR “passed” conditional coverage. A non-rejected Christoffersen or DQ test does not establish correct calibration; it means the data did not reject at the chosen level. This matters at alpha=0.01, where only about 5.7 breaches are expected and power is low.

Use “was not rejected” throughout, retain breach counts and p-values, and keep the power caveat adjacent to each 1% VaR claim. Avoid “survived” for the borderline DQ p=0.06 result. Treat the 16-row family and 24-row walk-forward panels as multiplicity-aware descriptive evidence, not repeated confirmations.

### P1. The Hill diagnostic is overinterpreted for light-tailed mixtures

The manuscript correctly notes that a finite Gaussian/Laplace/GED mixture can look Pareto-like over a finite threshold range while remaining asymptotically light-tailed. However, sections/discussion.tex:1 says the regime mixture supplies the heavy tail even under Gaussian emissions, and Results says the shared-nu tail “is matched” because finite-sample Hill bands overlap.

For CHMM-N, CHMM-L, and exponential-type GED cases, the Hill estimator is not estimating a finite asymptotic regular-variation index. An in-band top-5% estimate is a threshold-local shape diagnostic, not evidence of a genuine power law. The observed interval [2.45,4.25] also crosses 4, so an infinite fourth moment is possible but unresolved.

Rename the table “threshold-local Hill estimates,” reserve “tail index” for regular-varying models, and show a Hill plot/stability region. State that data are compatible with, rather than demonstrate, an infinite fourth moment.

### P1. State-count uncertainty is too weak for formal significance language

The rolling-origin designs have only four and six aggregate differences. The initial runners use an unpaired pooled-SD approximation despite paired folds (run_k_selection_kfold_pre2020.jl:194-206); the later Newey-West calculation applies asymptotic HAC inference to n=4 or n=6. The appendix eventually concedes that these samples are too small for formal significance, but the main text still says “inside sampling noise.”

Treat K=3 as a parsimony choice under empirically similar scores, not a statistically established winner or equivalence result. Report paired fold differences directly and avoid conventional significance language. Re-running on VWAP is required first.

### P2. Some causal attributions exceed the diagnostics

Passages attribute failures to a “regime introduction,” state that shifts are the “dominant cause,” or say refitting “closed” a gap. These readings are plausible but associational. Prefer “coincided with,” “is consistent with,” or “error was concentrated in.” The cross-decade claim that a later slice lies outside the earlier “regime range” needs a defined distance/coverage diagnostic rather than KS alone.

### P2. Benchmark comparisons are not fully symmetric

The main table leaves OoS kurtosis blank for several GARCH/MS-GARCH rows while using kurtosis proximity to select among CHMM emissions. The QuantGAN row is explicitly a smaller negative-control reimplementation, so it cannot support broad deep-generator claims. The empirical bootstrap is advantaged on in-window marginal KS by construction.

Complete missing metrics where feasible, separate “not computed” from “undefined,” and restrict model-class conclusions to the implementations tested.

## Narrative flow and clarity

### What works

- The paper says the CHMM is established and the contribution is comparative/diagnostic.
- The spectral derivation is self-contained and correctly limits the identity to positive lags, with separate treatment of lag zero, complex modes, and Jordan blocks.
- Strong baselines, stress-window failures, static-fit limitations, and absence of a privacy guarantee are reported openly.
- The main progression—problem, model, spectral mechanism, evaluation, limitations—is sensible.

### What should change

1. **Use “continuous-emission HMM” as the primary term.** “Continuous HMM” can mean continuous-time or continuous-state; this model has a discrete latent chain and continuous emissions.
2. **Stop calling three diagnostics “all standard stylized facts.”** The paper later concedes leverage/asymmetry are not targeted. Say “the three selected symmetric diagnostics” from the start.
3. **Shorten the abstract.** Lead with one question, one result, and one bounded implication. Move secondary baselines and qualifications to the body.
4. **Break up Results paragraphs.** sections/results.tex contains page-scale paragraphs mixing setup, numbers, interpretation, caveats, and appendix pointers. Use one paragraph per claim.
5. **Reduce Results/Discussion/Conclusion repetition.** Discussion should interpret mechanisms and limitations; Conclusion should give the bounded answer in roughly three short paragraphs.
6. **Do not justify inferior marginal results by which heads were implemented.** Saying CHMM is the only model “equipped” with VaR/copula is an implementation choice, not evidence alternatives are incapable. Frame these as demonstrations built here.
7. **Reorganize the 44-page supplement.** Group it as algorithms/theory; metric definitions; headline robustness; baselines; VaR; cross-asset. Add an appendix map. Move development-history/reviewer-item prose out of the archival manuscript.
8. **Simplify captions.** Several captions combine results, caveats, selection rationales, seeds, and cross-references. Keep captions sufficient to interpret the artifact and move argument into prose.

## Reproducibility and artifact integrity

1. Pin the companion repository commit in Data Availability and provide artifact checksums.
2. The paper repository has 56 result files while the companion has 387. Several matching files differ: companion K-selection CSVs include K=2 rows absent from paper copies, and the leverage-effect CSV differs for CHMM-L Monte Carlo summaries.
3. Several runners write paper CSVs to a hard-coded sibling path ../CHMM-paper, which does not match this repository name. Make output paths configurable or manifest-driven.
4. Data Availability says reproduction code is in the paper repository, while README says code is in the companion. Distinguish manuscript sources, derived results, executable code, and restricted CRSP inputs.
5. The Julia test suite passes 89/89 available tests, but MSGARCH reference tests were skipped because R was not on PATH. This audit did not fully regenerate all results, validate restricted CRSP inputs, or rerun R/MSGARCH and QuantGAN. State runtime requirements in a reproducibility checklist.
6. Add tests for post-M-step likelihood, pi policy, price-field consistency, boundary returns, post-copula marginal ACF, and Gaussian-limit testing.

## Recommended revision order

1. Decide whether the multi-asset section becomes a cross-sectional dependence experiment or uses a temporal-dependence-preserving construction.
2. Correct the Gaussian-mixture and copula-significance claims.
3. Re-run K selection on VWAP returns with correct train/validation boundaries.
4. Align EM code and paper: Gaussian pi, Student-t objective/label, final likelihood, and BIC counts.
5. Rebuild OoS results with the boundary return and verify VaR breach counts.
6. Regenerate and pin all artifacts from one companion commit, then checksum every reported table.
7. Compress the narrative after technical conclusions stabilize.

## Bottom line

The univariate spectral identity and empirical observation that one persistent mode dominates the fitted SPY absolute-return ACF are technically sound. The strongest defensible conclusion is narrower than the current one: for the fitted VWAP SPY models and reported diagnostics, a small-state CHMM captures more absolute-return persistence than i.i.d. baselines, while emission choice materially affects finite-sample marginal-tail diagnostics. Claims about an intrinsic three-Gaussian kurtosis ceiling, statistically proven Student-t copula superiority, and a multi-asset CHMM time-series generator are not supported by the current mathematics or code.
