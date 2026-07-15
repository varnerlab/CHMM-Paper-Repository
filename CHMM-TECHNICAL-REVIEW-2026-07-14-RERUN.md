# CHMM Paper and Model Repository Review: Rerun

Review date: 2026-07-14

Repositories reviewed:

- Paper: `CHMM-Paper-Repository`, commit `5fe78fa`
- Model: `CHMM-Model-Repository`, commit `8f92968`

This is a fresh review after the technical-review response commits. I checked
the revised manuscript against the new runners and result artifacts, rebuilt
the paper, inspected the BH calculation and non-overlapping basket outputs, and
attempted the repaired Julia package test path.

## Findings

### 1. Medium: the documented clean paper build needs one more LaTeX pass

`Makefile:14-17` runs three `pdflatex` passes with one `bibtex` pass between
them. A clean `make distclean && make` completed and produced a 76-page PDF,
but the final pass still emitted `Label(s) may have changed. Rerun to get
cross-references right.` A fourth standalone `pdflatex` pass removed that
warning; the resulting log had no undefined references, overfull boxes, or
underfull boxes.

Recommended correction: add a fourth `pdflatex` invocation or use `latexmk`
with an explicit rerun rule. This makes the documented build finish in the
same state as the verified PDF rather than requiring an undocumented command.

### 2. Medium: the Julia package entrypoint is empty and does not expose the framework

The response adds valid package metadata in `Project.toml` and an empty
`src/ContinuousHMM.jl` so that `Pkg.test()` can identify the project. However,
the module intentionally exports nothing; the actual API remains loaded by
the script-style `Include.jl`. Consequently, `using ContinuousHMM` succeeds
but does not provide `build`, `MyContinuousHiddenMarkovModel`, or the other
framework functions described by the repository.

Recommended correction: either turn `src/ContinuousHMM.jl` into the real module
and expose the public API, or document the repository explicitly as a
script-loaded research harness and avoid presenting the empty module as the
package interface. The current `Pkg.test()` metadata fix is useful, but it does
not by itself make the codebase a usable Julia package.

### 3. Low: the non-overlapping basket description should say "six selected sectors"

`sections/cross_asset_appendix.tex:151` describes MSFT, UNH, BAC, CAT, PG, and
XOM as "one per GICS sector." These are one representative from each of six
selected GICS sectors, not one representative from the full GICS sector set.
The runner and the numerical results are otherwise consistent: IS mean
absolute off-diagonal correlation is `0.3612` versus `0.5287` for the main
basket, Student-t/Gaussian IS MAE is `0.0307/0.0320`, and OoS MAE is
`0.2531/0.2476`.

Recommended correction: change the phrase to "one representative from each of
six selected GICS sectors" in the prose and table caption.

### 4. Low: "inside path-to-path noise" remains unquantified

The main cross-asset result at `sections/results.tex:70` says the Student-t
versus-Gaussian OoS MAE gap is inside path-to-path noise, while also stating
that no formal paired test was performed. The reported difference is only
`0.005` (`0.209` versus `0.204`), and the new non-overlapping panel has a
similar descriptive comparison, but neither panel reports a paired standard
error, confidence interval, or across-seed distribution.

Recommended correction: use the strictly measured wording "the observed MAE
difference was 0.005 and was not formally tested," or add paired path/seed
uncertainty before calling it noise.

### 5. Low: the new model-repository artifact fails whitespace validation

`git diff --check HEAD^ HEAD` reports trailing whitespace in
`results/cross_asset/nonoverlap_basket.txt:13`. This does not affect the
numbers, but it makes the response commit fail a standard repository hygiene
check.

Recommended correction: remove the trailing spaces from the formatted header
line and rerun `git diff --check`.

## Resolved findings from the prior review

The following prior findings were addressed and rechecked:

- The unsupported "every generator" stress-fold claim was replaced with the
  measured CHMM-N scope: all four W2 rows reject, and W4 has one tail-tier
  rejection.
- The unsupported quarterly-refit `0/6` KS claim was retired; the paper now
  limits that table to dependence-layer correlation MAE and explicitly says
  per-asset KS is not re-tested by that harness.
- The BH adjustment now has a runner, CSV/TXT artifacts, and appendix prose.
  The reported counts reconcile: 3/5 walk-forward cc rejections, 0/0
  four-family cc rejections, and 6/7 four-family DQ rejections survive at
  `q=0.05`.
- EM monotonicity is now scoped to exact Gaussian/Laplace updates, with the
  Student-t/GED ascent caveat retained.
- VaR filters now use `logpdf` and logsumexp normalization with an explicit
  fallback safeguard.
- The DQ statement now agrees with the all-family artifact: CHMM-N `K=3` is
  the only non-rejection at `alpha=0.01` among the 16 family/state rows.
- Repository dates, companion links, main state-count documentation, package
  metadata, and the non-overlapping basket artifacts were updated.

## Verification

`make distclean && make` succeeded and produced a 76-page PDF. A fourth
`pdflatex` pass was required to clear the final cross-reference rerun warning.

`Pkg.test()` now starts successfully with the repaired package metadata, but the
full plotting-inclusive suite produced no completion summary in this local
environment after extended execution and was interrupted. Therefore this rerun
does not claim a current full-suite pass. The prior direct source-loaded run
passed 89/89 tests before the response commits; the response changes should be
re-run with a bounded/headless test command once the plotting test behavior is
isolated.

## Overall assessment

The response commits materially improve technical accuracy and narrative scope.
The manuscript claims now mostly match the available code and artifacts, and
the added non-overlapping basket usefully weakens the dependence on the
overlapping ETF universe. The remaining work is primarily build/package
reproducibility and cautious wording around an unquantified simulation-noise
interpretation, not a substantive failure of the CHMM method or reported
results.
