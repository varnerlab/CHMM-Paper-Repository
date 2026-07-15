# CHMM Paper and Model Repository Technical Review

Review date: 2026-07-15

Repositories reviewed:

- Paper: `CHMM-Paper-Repository`, commit `18c6643`
- Model: `CHMM-Model-Repository`, commit `e04d0ee`

Scope: technical accuracy, mathematical and implementation consistency,
empirical-claim traceability, narrative flow, and reproducibility.

## Verdict

The paper and companion model repository are generally sound, and I found no
high-severity defect in the central CHMM construction, spectral identity,
reported headline results, or conditional-VaR filtering logic. Four
medium-priority and two low-priority corrections remain. The most important are
the residual mischaracterisation of the Student-t degrees-of-freedom update,
the inconsistent account of how the default state count was selected, an
overbroad conclusion about the effect of adding states on temporal persistence,
and an incomplete one-command rebuild claim.

## Findings

### 1. Medium: the Student-t degrees-of-freedom update is still mischaracterised as ECME

The implementation maximises, for each state,

```text
sum_t gamma_t(k) * log t_nu(O_t; mu_k, sigma_k)
```

with the smoothed state posteriors held fixed (`CHMM-Model-Repository/src/Compute.jl:459-489`).
This is neither the full HMM observed-data likelihood nor an ECME
actual-likelihood step. A true observed-likelihood update for a candidate
`nu_k` would require recomputing the HMM forward likelihood as `nu_k` changes.

The manuscript correctly acknowledges that the implemented update is a
surrogate and does not inherit an observed-likelihood ascent guarantee, but it
still says that the displayed posterior-weighted objective is the observed-data
likelihood in an "i.i.d. mixture" and presents it as following ECME
(`sections/methods.tex:89`; `sections/algorithms_appendix.tex:40`). The code
docstring is broader still, saying that the unpenalised version recovers the
standard Peel--McLachlan / Liu--Rubin ECME update and directly maximises the
observed-data Student-t likelihood (`src/Compute.jl:409-425`). Liu and Rubin
study the single multivariate-t likelihood; Peel and McLachlan describe ECM for
t mixtures and explicitly note that extending ECME to mixtures is not
straightforward.

Recommended correction: describe the implemented method consistently as a
hybrid generalised block-coordinate or surrogate update, retaining the
non-monotonicity caveat. Alternatively, implement a true ECME block that
evaluates the full forward observed-data likelihood for every candidate
`nu_k`. In either case, revise the code docstring as well as both manuscript
descriptions.

### 2. Medium: K-star = 3 is a defensible parsimony choice, but the selection narrative overstates the held-out evidence

The single-split selection runner declares held-out likelihood its primary
criterion (`CHMM-Model-Repository/run_k_selection_validation.jl:229-230`). Its
own results select:

- `K = 9` by held-out log-likelihood;
- `K = 2` by held-out KS pass rate; and
- `K = 3` by estimation-window BIC.

The rolling-origin designs do not separate `K = 3` and `K = 6`: the difference
changes sign between the four-fold and six-fold designs. The supplementary
discussion eventually gives the accurate interpretation, calling `K = 3` a
parsimony choice among empirically similar held-out scores rather than a
statistically established winner (`sections/supplementary.tex:166`).

That careful interpretation conflicts with several shorter claims:

- `sections/results.tex:1` says BIC selected `K = 3` on a "full-window held-out
  design," although the BIC is computed from the estimation-window likelihood;
- the main comparison table labels `K = 3` as selected by held-out criteria
  under rolling-origin CV (`sections/results.tex:33`); and
- the sensitivity appendix calls `K = 3` selected by pre-2020 k-fold CV while
  also denoting `K = 6` as a second `K^star` sensitivity reference
  (`sections/sensitivity_appendix.tex:140-146`).

Recommended correction: state one transparent rule throughout: BIC and CAIC
selected `K = 3`; rolling CV did not separate `K = 3` from `K = 6`; therefore
the smaller model was retained as the parsimony choice. Avoid calling `K = 3`
the held-out-likelihood winner, and reserve `K^star` for the single default
state count. Refer to `K = 6` simply as a sensitivity specification.

### 3. Medium: the conclusion overstates what adding states can do for temporal memory

The conclusion says that, within the hidden-Markov family, longer temporal
memory "cannot be bought by adding states" because the structural lever is the
sojourn-time law (`sections/conclusion.tex:3`). That is too broad. Adding states
can add non-unit eigenmodes, change the dominant eigenvalue, and introduce
eigenvalues closer to one, thereby extending geometric persistence. What a
finite-state HMM cannot produce is genuine non-geometric or power-law memory;
its ACF remains a finite combination of geometric, or polynomial-times-
geometric in the Jordan case, terms.

This overstatement also conflicts with the paper's own correct theoretical
description that `K >= 3` admits multiple non-unit eigenvalues
(`sections/theory.tex:10`). The empirical evidence supports a narrower claim:
additional states did not improve the fitted ACF persistence on the studied
datasets because a dominant mode already carried most of the decay.

Recommended wording: "Adding states did not buy additional persistence in
these fitted models; escaping finite geometric memory requires a different
duration law."

### 4. Medium: the advertised one-command full rebuild does not rebuild every reported artefact

The model README says that `run_full_rebuild.jl` regenerates every table and
figure in the paper in one pass (`CHMM-Model-Repository/README.md:85-90`). The
driver contains eight top-level stages, explicitly excludes the QuantGAN stage,
and states that standalone exploratory runners are invoked manually
(`run_full_rebuild.jl:19-24`, `:35-52`). The runner inventory contains 63 runner
scripts, including paper-consuming VaR, state-selection, spectral,
cross-asset, baseline, and robustness scripts that are not invoked by the
master driver. The reference Bayesian MSGARCH row also requires a separate
R/renv setup and standalone runner.

The `RUNNERS.md` artefact map is useful and substantially improves
traceability, but it does not make the advertised single command complete.
Additionally, the master driver catches stage failures and continues, yet
still prints `FULL REBUILD COMPLETE`, which can make a partial rebuild appear
successful unless the user inspects every per-stage status.

Recommended correction: either expand the orchestrator into explicit required
and optional stages, returning a non-zero exit status if any required stage
fails, or call it a "headline rebuild" and direct users to `RUNNERS.md` for the
complete artefact-by-artefact rebuild matrix.

### 5. Low: Gaussian and Laplace are GED special cases, not boundary cases

The manuscript repeatedly says that Gaussian and Laplace "sit at the boundary"
of CHMM-GED (`sections/methods.tex:18`; emission-family table caption in
`sections/supplementary.tex`). Under the implemented range `p in [0.5, 3.0]`,
both `p = 1` and `p = 2` are interior values. They are nested special cases:
`p = 1` gives Laplace with `b = alpha`, and `p = 2` gives Gaussian with
`sigma = alpha / sqrt(2)`.

Recommended correction: replace "sit at the boundary" with "are nested special
cases" or "are recovered at `p = 1` and `p = 2`."

### 6. Low: a VaR/ES simulation envelope does not confirm coverage

The VaR/ES figure caption says that every observed statistic falling inside
the simulated envelope confirms the coverage leg of the backtest
(`sections/metrics_appendix.tex:149`). An across-path envelope is a useful
visual predictive diagnostic, but it is not a statistical coverage backtest.
The actual coverage evidence comes from the Kupiec and Christoffersen tests.

Recommended correction: say that the observed statistic lies inside the
simulation envelope and is visually compatible with the fitted unconditional
distribution; reserve "coverage" for the formal likelihood-ratio backtests.

## Narrative flow

The high-level progression is coherent:

1. motivate the low-state Gaussian limitation;
2. separate the temporal and marginal failure channels;
3. introduce the spectral identity;
4. select a parsimonious operating state count;
5. compare emission families and baselines;
6. extend to cross-asset dependence and regime-conditional VaR; and
7. close with stationarity and regime-introduction limits.

The weakest narrative feature is density. Several main Results paragraphs mix
state selection, headline estimates, baseline qualifications, robustness
results, and interpretation in a single long block. Breaking the section into
short subsections for state selection, marginal/temporal fidelity, cross-asset
dependence, risk backtesting, and stationarity scope would make the inferential
chain easier to audit. A small decision table distinguishing the default
`K = 3`, the `K = 6` sensitivity, and the `K = 18` excess-kurtosis reference
would also eliminate repeated qualifications and the ambiguous use of
`K^star`.

## Verification

- `make distclean && make` completed successfully.
- Final paper output: 76 pages.
- Final `paper.log`: no warnings, undefined citations/references, box warnings,
  or label-rerun messages.
- Default no-R Julia test command completed with `116/116` tests passing in
  `1m41s`.
- The optional MSGARCH R-side MCMC path was not run.
- `git diff --check` was clean in both repositories before this review file was
  added.
- No model, manuscript, result, or generated-artifact source was changed during
  the review.

## Recommended disposition

The manuscript is technically close to submission-ready for the reviewed
scope. Correct the Student-t method label, state-count selection narrative, and
finite-memory conclusion before submission. The rebuild contract should be
fixed for reproducibility, while the GED and VaR-envelope wording can be
handled in the same editorial pass. None of these findings invalidates the
reported headline CHMM metrics, the spectral ACF identity, or the main-window
conditional-VaR arithmetic.
