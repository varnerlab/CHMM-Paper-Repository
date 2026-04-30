# Plan: Reference MS-GARCH baseline via RCall (chosen path)

**Status:** Drafted 2026-04-30. Supersedes the in-Julia Bayesian rebuild
proposed in `PLAN_MSGARCH_JULIA.md` for the resubmission timeline; the
Turing.jl path is parked but kept as a candidate medium-term software
contribution (see `PLAN_MSGARCH_PUBLIC_PACKAGE.md`).

## Decision

Use [RCall.jl](https://juliainterop.github.io/RCall.jl/) to invoke the CRAN
`MSGARCH` package (Ardia et al. 2019, JSS) directly from the existing
Julia harness. The fitted-model output replaces the in-house Nelder-Mead
self-fit rows in Table 2 with the reference Bayesian fit. The in-house
frequentist module (`src/MSGARCH.jl`) is kept as a sanity-check baseline,
not removed.

## Why RCall over the alternatives

The reviewer-binding language is R2 W1: *"either re-run MS-GARCH with the
`MSGARCH` R package and report the result, or weaken the 'multi-state
benefit' claim to 'in our re-implementation' wording throughout the body."*
RCall driving the actual CRAN package satisfies this literally. The
trade-offs against the two other candidate paths:

- **Native Turing.jl rebuild** (the original `PLAN_MSGARCH_JULIA.md`
  scope). Larger effort (4 to 6 hours active plus 8 to 12 hours wall
  clock for MCMC), requires its own validation gate (recovery test,
  label-switching diagnostic, frequentist sanity check), and still needs
  an R cross-check before reviewers will accept it as the reference.
  RCall removes the validation gate because the engine is the reference.
- **Public Julia package** (the `PLAN_MSGARCH_PUBLIC_PACKAGE.md` scope).
  Strongest answer to R3 W1's "novelty is thin" critique because it adds
  a software contribution leg, but largest scope (registered package,
  JOSS companion). Decoupled from the resubmission and revisited later.

## Reproducibility contract

The peer-review concern that motivates this work is that the in-house fit
is not at parity with the reference. Reviewers will accept the RCall path
only if the version stack is pinned and reproducible by anyone with R
installed. The contract:

1. **R version.** R >= 4.2 is required (enforced in `r_msgarch/setup.R`).
   The exact version used to generate the paper Table 2 numbers is
   recorded in `results/msgarch_reference/summary.txt`.
2. **MSGARCH version.** Pinned to 2.51 (current CRAN as of 2026-04). Bumps
   require regenerating the headline artefacts and updating the version
   footnote in the manuscript.
3. **Transitive R dependencies.** Pinned via `renv` (Posit). The
   `r_msgarch/renv.lock` file is committed; `renv::restore()` reproduces
   the exact library on any machine.
4. **Seed policy.** Both fit and simulate calls require an explicit
   integer seed argument from the Julia caller. The runner derives
   per-K seeds from `SEED + K` (fit) and `SEED + 100 + K` /
   `SEED + 200 + K` (IS / OoS simulate), matching the harness convention.
5. **Round-trip integrity.** The fitted model is serialised as a raw byte
   vector on the R side and stored on the Julia struct, so simulation
   uses the same posterior draws that the fit produced. No re-fit at
   simulate time.

## Code layout (sibling repo `CHMM-Model`)

- `r_msgarch/setup.R` initialises `renv`, installs `MSGARCH`, snapshots
  `renv.lock`.
- `r_msgarch/fit_msgarch.R` exposes `fit_msgarch_ref` and
  `simulate_msgarch_ref`, both stateless, both seed-required.
- `r_msgarch/README.md` documents the version-pinning contract.
- `src/MSGARCHReference.jl` is the Julia bridge: `MyMSGARCHReferenceModel`
  struct, `fit_msgarch_reference`, `simulate_msgarch_reference`,
  `msgarch_reference_versions`. Lazy R-session bootstrap, descriptive
  errors when MSGARCH is missing.
- `run_msgarch_reference.jl` is the runner: K in {2, 3, 4}, 1000 paths,
  same SPY IS / OoS as `run_msgarch_baselines.jl`. Writes
  `results/msgarch_reference/{models_K{K}.jld2, sims_K{K}.jld2,
  metrics.csv, summary.txt, fit_log.txt}`.
- `test/test_msgarch_reference.jl` is a smoke test (fit + simulate at
  K = 2 with a tiny MCMC budget), guarded so it skips cleanly when R is
  unavailable.

## Reviewer-facing artefact

The deliverable for the resubmission is a single CSV row per K in
`results/msgarch_reference/metrics.csv`, embedded in the Table 2 source
the same way the existing `run_msgarch_higher_k.jl` numbers are. The
companion `summary.txt` records R version, MSGARCH version, platform,
timestamp, fit budget, and seed, so a reviewer can verify the row is
reproducible without running the code themselves.

## Headline reframing path under each outcome

The two outcomes flagged in `PLAN_MSGARCH_JULIA.md` continue to apply:

- **Reference MS-GARCH stays at ~30% IS KS.** Body claim is vindicated.
  The multi-state regime-switching benefit at this T_IS on this dataset
  is not an estimator-quality artefact; it is a model-class property.
  Replace the in-house rows in Table 2; keep the body framing.
- **Reference MS-GARCH lifts materially (e.g. 60%+).** Panel ordering
  shifts. Restate the body claim as "the multi-state benefit is shared
  by reference MS-GARCH and CHMM, with per-axis trade-offs deciding
  between them." Update the Table 2 footnote and the discussion section
  on baseline parity.

Either outcome strengthens the paper because the deferred control is in
the body.

## Risks and mitigations

| Risk | Mitigation |
|------|------------|
| Reviewer not running R locally | Output artefacts (`metrics.csv`, `summary.txt`) ship in the repo, so the paper number is checkable from the file alone. |
| MSGARCH version drift on CRAN | `renv.lock` pins the exact version; bump only as a deliberate manuscript update. |
| RCall and R session-state leakage | Bridge module isolates session state under one `_ensure_r_session` singleton; no globals are read or written outside the `r_msgarch/` working directory. |
| MCMC budget too small for K = 4 stability | Default budget is the Ardia 2019 reference budget (12500 / 2500 / thin 10). If K = 4 fails to mix, fall back to K in {2, 3} with an explanatory footnote. |
| Reproducer machine has wrong R | `setup.R` errors with R < 4.2; the bridge module errors with a setup hint when MSGARCH is absent. |

## Decision gate

Proceed without further professor sign-off. The scope is bounded (no
Bayesian rewrite, no public package, no new methodology), the
reproducibility contract is mechanical (`renv` snapshot), and the
reviewer-binding language is satisfied literally. If the run produces an
unexpected lift to 60%+ IS KS (the second outcome above), revisit the
body framing before the resubmission diff is finalised.
