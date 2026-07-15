# CHMM Technical Review: Final Rerun 2

Date: 2026-07-14  
Scope: `CHMM-Paper-Repository` at `6e96671` and `CHMM-Model-Repository` at `531d076`  
Focus: technical accuracy, narrative flow, cross-repository consistency, and reproducibility after the strict-CRN response.

## Verdict

The two substantive findings from the previous review are resolved. The new CRN simulator uses explicit component streams, and the uncertainty runner now fits the same deterministic parameterization as the headline pipeline. The reported CSV values reproduce the manuscript means and intervals. I found no new high-severity correctness or narrative issue.

Two verification gaps remain: the new CRN overloads are not exercised by the Julia test suite, and the documented test runtime is not representative when R is installed and the optional MSGARCH smoke test runs.

## Findings

### 1. Medium: the new strict-CRN simulation path has no automated regression test

The response adds two new core methods, `simulate(..., crn_seed)` for Gaussian and Student-t copulas (`src/CrossAsset.jl:552-598`). The 89-test suite contains no references to `CrossAsset`, `MyGaussianCopulaModel`, `MyStudentTCopulaModel`, `crn_seed`, or `seed_uncertainty`, so `Pkg.test()` does not exercise the code that produces the new paper evidence.

This matters because the implementation duplicates the rank-reordering simulator rather than sharing a tested helper with the existing three-argument methods. A later change to marginal simulation, rank handling, or path layout could make the CRN runner diverge while the advertised 89/89 suite remains green. Add a small deterministic cross-asset fixture that checks at least: repeated calls with the same CRN seed are bitwise reproducible; Gaussian and Student-t calls use the same marginal-path draws for each asset; the Student-t mixing stream changes only the copula ranks; and the returned tensor has the documented `T x d x n_paths` shape. Also add a runner-level smoke test that recomputes one or two rows of the stored uncertainty artifact.

The implementation itself is technically coherent: it reseeds the base-normal stream identically for both copulas, assigns marginal streams per asset, and gives Student-t mixing its own stream (`src/CrossAsset.jl:523-537`, `:558-595`).

### 2. Low: test-runtime documentation needs an R-enabled qualification

The no-R path is reproducible: with R hidden from `PATH`, `GKSwstype=100 julia --project=. -e 'using Pkg; Pkg.test()'` completed with `89` passes in `1m39s`. With R installed, the optional MSGARCH test takes the branch at `test/test_msgarch_reference.jl:34-105` and runs a 1,500-draw R MCMC smoke test. On this environment it did not finish after more than five minutes and had to be stopped.

The README says to expect roughly two minutes plus first-run precompilation (`README.md:126-132`) without stating that an R-enabled run can be substantially longer. This is a reproducibility/documentation issue, not evidence of an algorithmic failure. Either qualify the runtime estimate as the no-R path, or gate the MSGARCH smoke test behind an explicit environment variable and document the longer optional path.

## Technical accuracy and narrative flow

The strict-CRN revision is now accurately described. The runner uses explicit per-path component seeds (`runners/cross_asset/run_seed_uncertainty.jl:97-101`), and the Student-t chi-square stream no longer shifts the Gaussian/marginal streams. The fitting claim is also supported by the source: the Gaussian and Student-t copula estimators are rank/Kendall/profile calculations, while CHMM initialization is quantile-based and the fitting code contains no random draws (`src/CrossAsset.jl:172-260`; `src/Compute.jl:279-401`).

The paper’s new wording is appropriately narrower. It calls the interval Monte-Carlo precision for a fixed-fit simulation rather than sampling uncertainty about new-data copula performance (`sections/results.tex:70`; `sections/cross_asset_appendix.tex:174-177`). The main and non-overlap values in the manuscript agree with the artifact: recomputation from 20 rows gives main mean gap `+0.005484`, interval `[+0.004953, +0.006014]`, and non-overlap mean gap `+0.008047`, interval `[+0.007323, +0.008772]`, which round to the reported values.

The prior narrative corrections remain in place: overlap is disclosed before the non-overlapping basket, GICS wording is scoped to six selected sectors, rolling refit claims are limited to correlation MAE, and the walk-forward stress claims are scoped to the tested CHMM-N configurations. The “stable across replicates” language is preferable to the earlier unsupported “systematically better” claim.

## Resolved prior findings

- Same-seed resets being mislabeled as CRN: resolved by explicit component streams.
- Across-seed fits differing from headline fits: resolved by documenting and using deterministic fitting without inert fit-seed calls.
- Unquantified path-to-path noise: replaced with a fixed-fit 20-replicate Monte-Carlo precision analysis.
- Unsupported “every generator” stress-fold claim: scoped to CHMM-N at `K in {3, 18}`.
- Unsupported quarterly-refit `0/6` KS claim: removed; rolling evidence is limited to correlation MAE.
- Overbroad EM monotonicity, log-space probability, DQ-scope, GICS, package-entrypoint, and Makefile claims: corrected or documented in the current repositories.

## Verification performed

- Clean paper build: `make distclean && make` completed successfully; final output is 76 pages and the final `paper.log` has no warning, overfull/underfull, undefined-reference, or label-rerun matches.
- Artifact arithmetic: `seed_uncertainty.csv` reproduces the means, standard deviations, and 95% t-intervals printed in `seed_uncertainty.txt` and the manuscript.
- Model hygiene: latest model commit passes `git diff --check`.
- Tests without R: `89/89` passed in `1m39s` with headless GR enabled.
- Tests with R: optional MSGARCH branch did not complete within more than five minutes in this environment; it was stopped, so the R-enabled suite is not certified here.

## Recommended disposition

The paper and model are technically acceptable after the CRN correction. Before treating the repository as fully regression-protected, add tests for the new CRN simulator and clarify the R-enabled test-runtime contract. No further manuscript-level change is required for the cross-asset uncertainty narrative.
