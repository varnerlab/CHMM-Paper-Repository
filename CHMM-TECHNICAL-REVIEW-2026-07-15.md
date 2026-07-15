# CHMM Technical Review: 2026-07-15

Date: 2026-07-15

Scope: `CHMM-Paper-Repository` at `6c72fd0` and `CHMM-Model-Repository` at `bd15899`

Focus: technical accuracy, narrative flow, cross-repository consistency, and reproducibility after the CRN-regression-test response.

## Verdict

The previous review findings are resolved. The strict-CRN implementation now has regression coverage, the artifact smoke test passes, and the MSGARCH test is explicitly opt-in. The paper’s cross-asset narrative is technically and statistically scoped correctly. I found no high- or medium-severity correctness issue.

One low-priority maintenance issue remains: the Student-t copula likelihood emits a Julia deprecation warning for `lgamma` during the new cross-asset tests.

## Finding

### Low: deprecated `lgamma` call in the copula likelihood

The no-R test suite passes, but emits three warnings from `src/CrossAsset.jl:205`, where `_tcopula_profile_loglik` calls `lgamma(...)`. The current Julia runtime recommends `logabsgamma(x)[1]` instead. This does not change the present numerical result, but it adds test noise and creates avoidable forward-compatibility risk.

Replace the three `lgamma` calls with the supported API, add or retain a finite-value likelihood test, and rerun the copula artifact check. This is maintenance work, not a finding against the paper’s reported estimates.

## Technical accuracy

The strict-CRN response is now supported by both implementation and tests:

- `src/CrossAsset.jl:552-598` provides deterministic CRN overloads for Gaussian and Student-t copulas.
- `test/test_crossasset.jl` checks bitwise reproducibility, tensor shape, finite output, shared marginal multisets under a common seed, rank isolation from the Student-t mixing stream, seed sensitivity, and one stored non-overlap artifact row.
- The no-R suite completed with `113/113` passing tests in `1m47s` with headless GR enabled.
- Recomputing the stored 20-replicate CSV gives main mean gap `+0.005484` with interval `[+0.004953, +0.006014]`, and non-overlap mean gap `+0.008047` with interval `[+0.007323, +0.008772]`; these round to the manuscript and TXT artifact values.

The fit-determinism statement remains consistent with the source: CHMM initialization and the relevant copula estimators do not consume RNG during fitting. The CRN runner therefore compares the same fitted parameterization while varying only simulation streams.

The MSGARCH smoke test is now correctly opt-in through `CHMM_TEST_MSGARCH=1`, and the default suite skips it with a printed explanation. This resolves the previous runtime/documentation mismatch for the ordinary test command.

## Narrative flow and correctness

The paper’s cross-asset section now has a sound progression: it discloses the overlap in the main ETF/constituent basket, introduces the six-name comparison basket, distinguishes static-fit dependence error from rolling-refit improvement, and limits the copula construction to cross-sectional dependence. The new uncertainty wording correctly calls the interval Monte-Carlo precision for a fixed-fit simulation design rather than sampling uncertainty about new data (`sections/results.tex:70`; `sections/cross_asset_appendix.tex:174-177`).

The earlier narrative corrections remain effective:

- walk-forward stress claims are scoped to CHMM-N at `K in {3, 18}`;
- rolling-refit evidence is limited to correlation MAE rather than unsupported KS claims;
- the six-name panel is described as representatives from six selected GICS sectors;
- the DQ, EM-monotonicity, log-space, package-entrypoint, and Makefile statements are appropriately scoped or documented.

The paper README retains older dated status entries using historical wording such as “systematic.” This is understandable as a chronological audit log, but the newest status entry should remain the authoritative wording if the README is later condensed.

## Verification

- `make distclean && make` completed successfully.
- Final paper output: 76 pages.
- Final `paper.log`: no warning, overfull/underfull, undefined-reference, or label-rerun matches.
- Model `git diff --check`: clean.
- Default no-R test command: `113/113` passed.
- MSGARCH opt-in path was not rerun in this pass; it requires the R/renv setup and intentionally runs a substantially slower R-side MCMC smoke test.

## Recommended disposition

The paper and model are technically acceptable for the reviewed scope. The only code change warranted by this pass is replacing the deprecated `lgamma` API. The README’s historical status log can remain, but future edits should preserve the newest fixed-fit Monte-Carlo wording as the current interpretation.
