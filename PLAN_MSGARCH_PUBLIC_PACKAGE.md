# Plan: Spin out a public Julia MS-GARCH package alongside the CHMM paper

**Status:** Drafted 2026-04-30. Parked pending discussion with Prof. Varner. Companion to `PLAN_MSGARCH_JULIA.md` (which covers the in-paper Bayesian re-fit). This document covers the open-science / public-package question.

## What the peer review actually demands

Priority-1 item 1 (peer-review.md, R1 W1 / R2 W1 / R3 RE1). The binding language is **R2 W1**:

> *"either re-run MS-GARCH with the `MSGARCH` R package and report the result, or weaken the 'multi-state benefit' claim to 'in our re-implementation' wording throughout the body"*

So the door is open for a non-R alternative, but only if the re-implementation is at parity with Ardia et al. (2019, JSS). A naked frequentist Nelder-Mead self-fit (the current state) is exactly what they reject.

## Three guardrails for reviewer acceptance

A Julia MS-GARCH self-implementation is acceptable iff all three hold:

1. **Match the Ardia 2019 model spec.** Same priors (Beta on alpha/beta, half-Normal on omega, Dirichlet rows on T), Hamilton (1989) forward filter, NUTS via Turing, label-switching post-processing by unconditional volatility. PLAN_MSGARCH_JULIA.md already specifies this correctly.
2. **Cross-validate against the R package on a public benchmark.** Reproduce one published number from Ardia 2019 (SMI returns is the standard) within Monte Carlo error using the Julia code; put the cross-check in an appendix. This converts "self-implementation" into "validated re-implementation" and is the difference between R3 accepting and rejecting.
3. **Release it as a standalone registered Julia package**, not as a buried `src/MSGARCH.jl` script. Registered = citable, indexable, verifiable.

## Julia ecosystem gap (as of 2026-04)

| Package | MS-GARCH support |
|---|---|
| ARCHModels.jl (Broda / Paolella) | GARCH / EGARCH / TGARCH / DCC, no regime switching |
| MarSwitching.jl (Dadej, JOSS 2024) | MS regression, MS-GARCH listed as planned, not implemented |
| HiddenMarkovModels.jl (Dalle, JOSS 2024) | generic emissions, no GARCH recursion |
| HMMBase.jl | maintenance mode, no GARCH |
| Turing.jl | tutorial example only, not a package |
| **R: MSGARCH (Ardia 2019, JSS)** | reference implementation, only one in any language |
| Python: arch (Sheppard) | single-regime only |

A registered Julia MS-GARCH would be first-of-its-kind in the Julia ecosystem and the only maintained non-R implementation in any language.

## Recommended split: two artefacts that cite each other

- **MSGARCHTuring.jl** (new repo, registered in General). Pure MS-GARCH module, JOSS-style README, recovery tests, cross-validation against R MSGARCH on SMI returns. Target a JOSS (Journal of Open Source Software) software paper as a 2-page companion.
- **CHMM-Model** (this repo) depends on `MSGARCHTuring`, drops the embedded `src/MSGARCH.jl`, runs the Table-2 panel using the public package.

The CHMM paper itself goes to arXiv (q-fin.ST + stat.AP) and later targets one of:

- Journal of Financial Econometrics (Oxford, OA option)
- Quantitative Finance (T&F, OA option)
- Studies in Nonlinear Dynamics & Econometrics (De Gruyter, OA)
- Journal of Empirical Finance (Elsevier, OA)

Cornell-tied OA venue: arXiv is Cornell-hosted, which covers the preprint side. No Cornell-published econometrics OA journal exists. JOSS is the strongest software-companion play.

## Open-science framing impact

R3 W1 calls the current contribution list "thin" (engineering scaffold + standard empirical study). A public Julia MS-GARCH adds a third contribution leg:

1. Empirical: CHMM stylized-fact reproduction at low K.
2. Methodological: unified four-emission ECM scaffold.
3. **Software / open science: first registered Julia MS-GARCH, validated against the R reference, enabling Julia-native regime-switching volatility research without an R bridge.**

Leg 3 answers R3's "novelty is thin" critique without requiring a theoretical breakthrough.

## Risk if cross-validation is skipped

If the Julia Bayesian MS-GARCH lands near 30% IS KS (matching the existing frequentist plateau), reviewers will suspect estimator quality, not model failure, **unless** an R-package cross-check is reported. Without the cross-check, R3 will read it as "still a self-implementation." With the cross-check showing parity on SMI, the same number becomes a substantive finding about MS-GARCH itself on this data.

## Open questions for the professor

1. Spin-out vs. embedded module: is the JOSS / public-package effort worth the reframing benefit, or is the in-paper Bayesian rerun (PLAN_MSGARCH_JULIA.md scope) sufficient?
2. Cross-validation depth: is a single SMI reproduction enough, or does the parity check need to span multiple datasets / multiple K?
3. Authorship of MSGARCHTuring.jl: same author block as the paper, or a different / wider one given a software contribution context?
4. Timeline coupling: ship the package before, with, or after the arXiv preprint? (Before is strongest for the contribution claim; with adds coordination cost.)
5. Maintenance commitment: a registered package implies ongoing maintenance. Is this scoped within thesis / postdoc time, or does it need a co-maintainer?

## Decision gate

Do not start the spin-out work until items 1 and 5 above are resolved with the professor. The in-paper Bayesian rerun (PLAN_MSGARCH_JULIA.md) can proceed independently and is the prerequisite for either path.
