# CHMM Technical Review: Final Rerun

Date: 2026-07-14  
Scope: `CHMM-Paper-Repository` at `cce7839` and `CHMM-Model-Repository` at `3d328ea`  
Review dimensions: technical accuracy, reproducibility, narrative flow, and consistency between manuscript, runners, and stored artifacts.

## Verdict

The earlier high-severity issues are corrected, and the manuscript is substantially more accurate. The remaining cross-asset uncertainty paragraph should not be accepted as written: it calls a same-seed reset “common random numbers” even though the two simulators consume different random variates, and its fit seeds do not match the headline fit. Those issues do not invalidate the reported descriptive MAE values, but they weaken the claim that the new interval isolates path-to-path simulation noise.

## Findings

### 1. Medium: the seed panel is paired by seed, but not common-random-number simulation

The paper says that both copulas are “drawing ... from the same seed” and labels the design common random numbers (`sections/results.tex:70`; `sections/cross_asset_appendix.tex:177`). The model runner resets the global RNG before each call (`runners/cross_asset/run_seed_uncertainty.jl:86-90`). That creates repeatable same-seed replicates, but it does not create the same underlying random inputs:

- `_sample_gaussian_copula` consumes correlated normals only (`src/CrossAsset.jl:383-388`).
- `_sample_t_copula` consumes correlated normals and an additional chi-square draw for every simulated observation (`src/CrossAsset.jl:397-404`).
- The downstream marginal simulation also consumes RNG after the copula draw.

Consequently, resetting the seed gives a paired seed design, not strict CRN variance reduction. The reported paired gaps and t-intervals remain valid as descriptive paired-by-seed summaries, subject to the usual Monte Carlo assumptions, but the manuscript should not attribute their precision to common random numbers. Either implement an explicit shared base-random-input interface for both copulas, or replace “common random numbers” with “same seed per replicate (paired seed design)” throughout and soften the variance-reduction implication.

### 2. Medium: the across-seed panel does not hold the headline fit fixed

The uncertainty runner fits each marginal with `FIT_SEED + 1000*b + j` (`runners/cross_asset/run_seed_uncertainty.jl:73-81`). The headline main runner relies on the single global `Random.seed!(SEED)` and then fits the models (`runners/headline/run_cross_asset_sim_copula.jl:19-22`, followed by the fit block), while the non-overlap headline runner uses `SEED + j` for its marginal fits (`runners/cross_asset/run_nonoverlap_basket.jl:88-94`). Thus the 20-replicate panel uses a different fitted CHMM/copula parameterization from the reported single-seed rows.

Within the new panel, the fit is fixed and only simulation is repeated, so its internal description is coherent. However, its comparison with the headline values and its conclusion that the gap is beyond “path-to-path noise” are confounded by a fit-seed change. For a clean Monte Carlo-noise check, save or reuse the exact fitted models from the headline run, then vary only the simulation seed. Separately report fit-seed sensitivity if that is of interest.

### 3. Low: “systematic” and “resolved beyond simulation noise” need narrower statistical wording

The 20 seed replicates support the observed paired mean gap under this fixed-data, fixed-fit simulation experiment, and the stored CSV/TXT values are internally consistent. However, a 95% t-interval over 20 deterministic simulation seeds is a Monte Carlo precision interval, not sampling uncertainty for the real-world copula or a test of population superiority. Given Findings 1–2, the wording in `sections/results.tex:70` and `sections/cross_asset_appendix.tex:177` should say something like “the mean gap was stable across the 20 simulation-seed replicates under this design” rather than “systematically better” or “resolved beyond simulation noise.”

The non-overlap result should receive the same qualification: the artifact reports a paired gap of `+0.0082` with interval `[+0.0072, +0.0092]`, but that interval describes this fixed-fit simulation exercise, not a general claim about copula performance.

## Narrative and consistency assessment

The narrative flow is now materially improved. The paper moves from the main six-asset composition, explicitly acknowledges ETF/constituent overlap, introduces the six-name comparison basket, then separates static-fit dependence error from rolling-refit improvement. The paragraph also correctly states that rank reordering supplies cross-sectional dependence but does not claim joint temporal dynamics (`sections/results.tex:70`).

The following earlier problems are resolved in the current commits:

- Walk-forward stress-fold claims are scoped to CHMM-N at `K in {3, 18}`, rather than every generator.
- The unsupported quarterly-refit `0/6` KS claim has been removed; the rolling table is limited to correlation MAE.
- EM monotonicity and the log-space probability claims are narrowed/corrected.
- The DQ statement is scoped to all 16 tested rows and identifies the surviving configuration.
- The “one per GICS sector” wording is corrected to six selected sectors.
- The empty `src/ContinuousHMM.jl` entrypoint is documented as metadata-only, with `Include.jl` identified as the research harness entrypoint.
- The Makefile now uses four post-BibTeX `pdflatex` passes and the clean build converges without final cross-reference warnings.

One minor prose improvement remains: avoid repeating “systematic” in both the main text and appendix until the seed design is corrected or the claim is rephrased as a fixed-fit Monte Carlo result. This will make the narrative match the actual evidential scope without changing the substantive cross-asset conclusion that the rolling refit has the larger reported effect.

## Verification performed

- Clean paper build: `make distclean && make` completed successfully; output was a 76-page PDF and the final `paper.log` had no `Warning`, `Overfull`, `Underfull`, undefined-reference, or label-rerun matches.
- Model artifact hygiene: `git diff --check` is clean for the latest response commit.
- Seed artifact: `results/cross_asset/seed_uncertainty.csv` and `.txt` agree with the manuscript values for both baskets.
- Test harness: `GKSwstype=100 julia --project=. -e 'using Pkg; Pkg.test()'` starts and reaches the walk-forward tests, but did not finish within approximately four minutes on this environment and was stopped. The README claim that the complete suite runs to completion is therefore not independently verified in this review.

## Recommended disposition

Accept the substantive model and narrative corrections, but revise the seed-uncertainty runner and manuscript wording before treating the cross-asset OoS gap as a quantified simulation-noise result. The minimum acceptable correction is to use “paired same-seed replicates,” disclose the different fit-seed convention, and restrict the inference to the fixed-fit Monte Carlo experiment.
