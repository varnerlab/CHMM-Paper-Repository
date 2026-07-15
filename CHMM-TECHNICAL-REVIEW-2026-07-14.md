# CHMM Paper and Model Repository Review

Review date: 2026-07-14

Repositories reviewed:

- Paper: `CHMM-Paper-Repository`, commit `065f89e`
- Model: `CHMM-Model-Repository`, commit `70182a6`

Scope: technical correctness, agreement between manuscript claims and the
implementation/results, narrative flow, and reproducibility of the reported
analysis. The paper was rebuilt with `make distclean && make` and produced a
74-page PDF without unresolved-reference or overfull/underfull-box messages in
the final log. The model tests were run through `include("test/runtests.jl")`:
89/89 tests passed. The MS-GARCH reference test was skipped because the local R
`renv` environment is not installed.

## Findings

### 1. High: the "every generator" stress-fold claim is not supported

The manuscript states that every generator was rejected on W2 and W4 in
`sections/results.tex:5,97,127` and `sections/conclusion.tex:1`. The available
conditional-VaR walk-forward runner,
`runners/var_backtest/run_walkforward_conditional_var.jl`, evaluates only
CHMM-N at `K=3` and `K=18`, yielding 24 rows. It does not evaluate a panel of
alternative generators. The result file also does not support the exact wording:
all four W2 rows reject Christoffersen-cc, but on W4 only CHMM-N `K=18`,
`alpha=0.01` rejects (`p=0.022`); the other W4 rows do not reject at 5%.

Recommended correction: replace the universal statement with the measured
scope, for example: "The tested CHMM-N walk-forward configurations all failed
on W2, while W4 produced a tail-tier rejection for `K=18`." If an
all-generator comparison exists outside this repository, add its runner,
inputs, and result table before retaining the broader claim.

### 2. High: the quarterly-refit copula `0/6` failure count is not reproducible

`sections/results.tex:70` says that quarterly refitting reduced the cross-asset
KS failure count to `0/6` and cites `Table~\ref{tab:rolling_copula}`. That table
(`sections/cross_asset_appendix.tex:123`) contains only quarter/window dates,
forecast length, fitted `nu`, off-diagonal correlation MAE, and Frobenius error.
The model artifact `results/cross_asset/Rolling_Copula_OoS.txt` likewise reports
correlation errors, not six per-asset KS tests or a pass/fail count. The claim
therefore cannot be checked from the cited evidence.

Recommended correction: either remove the `0/6` statement and limit the claim
to the reported correlation-MAE improvement, or add the per-asset rolling KS
calculations, definitions, and result artifact that produce the count.

### 3. Medium: the claimed Benjamini-Hochberg correction is absent from the paper

`sections/results.tex:97` says that a Benjamini-Hochberg false-discovery-rate
correction is reported in the appendix. A source audit finds that this is the
only occurrence of `Benjamini`, `BH`, `FDR`, or `false-discovery` in the paper
source; no corrected p-value table or calculation is present. This conflicts
with the manuscript's multiplicity-aware framing.

Recommended correction: include the tested hypotheses, raw p-values, adjusted
q-values, and correction family in an appendix artifact, or remove the sentence
claiming that the correction is reported and describe the results as unadjusted
descriptive tests.

### 4. Medium: EM monotonicity is stated too broadly

`sections/algorithms_appendix.tex:26` says that the observed-data likelihood
"is monotone across iterations." That is not valid for all four implemented
families. The manuscript itself correctly states in `sections/methods.tex:89`
and `sections/supplementary.tex:30` that the Student-t and GED updates use
approximate bounded searches/surrogate objectives and do not guarantee
observed-likelihood ascent. The model code reflects this: Student-t updates
`nu` with fixed posteriors, and GED uses approximate coordinate searches.

Recommended correction: restrict the monotonicity statement to the exact
Gaussian/Laplace conditional-maximization cases, or state that the likelihood
trace is monitored but is not guaranteed to be monotone for Student-t/GED.
Keep the useful existing caveat that the recorded likelihood is evaluated
before the returned M-step parameters.

### 5. Medium: "all probability computations" are not log-space

`sections/methods.tex:68` says that all probability computations use log-space.
The EM forward/backward code does use log-space, but the conditional-VaR
filter in `runners/var_backtest/run_conditional_var_all_families.jl` and the
walk-forward runner compute component probabilities with direct `pdf` calls,
normalize their products, and fall back to the prior when the normalization is
zero. This can underflow in extreme tails and is especially relevant to a VaR
paper.

Recommended correction: narrow the manuscript statement to the EM
forward/backward recursion, or change the VaR filters to `logpdf` plus
`logsumexp` normalization and add a tail-underflow test. The fallback should be
reported as a numerical safeguard, not presented as equivalent to log-space
evaluation.

### 6. Medium: the DQ comparison needs an explicit family scope

The main text at `sections/results.tex:97` says that only CHMM-N at `K=3` was
not rejected by DQ at `alpha=0.01`, immediately after discussing four CHMM
rows. The all-family model artifact
`results/diagnostics/engle_manganelli_dq_all_families.txt` contains DQ results
for all 16 family/state/tail combinations, including additional rejections for
CHMM-t, CHMM-L, and CHMM-GED. The sentence is defensible only if "only" means
only among the CHMM-N rows and the two comparator rows shown in the main table.

Recommended correction: say "among the CHMM-N rows and the two comparators
shown in Table ..." or promote the all-family DQ panel to the appendix and
interpret the emission-family results consistently.

### 7. Low: repository documentation is stale or prevents the documented test command

Several documentation mismatches reduce reproducibility:

- Paper `README.md:133` says the draft is 67 pages; the current source rebuild
  produces 74 pages.
- Model `src/Files.jl:13-39` documents old training/OoS dates, while the model
  README and paper use 2014-01-03 to 2024-01-03 for IS and 2024-01-04 to
  2026-04-20 for OoS.
- Model `README.md:3,178` links to the older `CHMM-paper` repository rather
  than the current `CHMM-Paper-Repository` companion.
- Model `results/README.md:19` still labels `K=18` as the main K, whereas the
  current paper's default is `K*=3`.
- `Pkg.test()` fails before running tests because `Project.toml` has no package
  `name` or `uuid`. Direct inclusion of `test/runtests.jl` passes 89/89 tests,
  but the documented package-test path should either be repaired by adding
  package metadata or documented accurately.

## Narrative and technical assessment

The paper's main methodological narrative is generally coherent and unusually
careful about scope. The spectral identity states its stationarity,
finite-moment, and diagonalizability assumptions; the copula section clearly
states that rank reordering preserves marginals but destroys per-asset serial
dependence; and the supplementary material distinguishes exact Gaussian/Laplace
updates from approximate Student-t/GED updates. The implementation inspected in
`src/Compute.jl` and `src/CrossAsset.jl` is consistent with those core model
descriptions.

The flow becomes less reliable when the paper moves from measured artifacts to
general conclusions. The stress-fold universal claim and the quarterly-refit
`0/6` claim overstate what the runners and tables establish. Removing those
sentences or adding the missing analyses would materially improve the paper's
credibility. The remaining changes are mostly scope corrections and repository
maintenance, not a need to redesign the CHMM model.

## Priority action list

1. Correct or substantiate the two unsupported result claims.
2. Add the promised BH correction or remove the promise.
3. Fix the EM monotonicity and log-space wording; ideally harden the VaR filter
   numerics with log-density normalization.
4. Clarify the DQ family scope and include the all-family DQ artifact if it is a
   claimed comparison.
5. Synchronize README/API documentation and make `Pkg.test()` runnable.
