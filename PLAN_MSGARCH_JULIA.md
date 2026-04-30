# Plan: Bayesian MS-GARCH reference re-run in Julia (Turing.jl)

## Goal

Address peer-review Tier 1 item: "MS-GARCH `MSGARCH` R-package re-run (Ardia 2019, $K \in \{2, 3, 4, 6\}$) added to Table 2. Until this is in the body, the comparison-class claim that 'the multi-state benefit is specific to the CHMM scaffold' is unsupported. (R1, R2.)"

The user requested staying within the Julia ecosystem. Since no production-quality MS-GARCH package exists in Julia (ARCHModels.jl has GARCH/EGARCH/TGARCH/DCC but not regime-switching), implement the Ardia 2019 Bayesian MS-GARCH directly in Turing.jl, which is already a CHMM-Model dependency.

## Why Bayesian (not frequentist)

The MSGARCH R package (Ardia et al. 2019, JSS) uses fully Bayesian estimation by design:
- The MS-GARCH likelihood is multimodal with persistent local optima at low IS KS pass rates (the body's in-house frequentist version plateaus at 27-37% IS KS for $K \in \{2, 3, 6\}$).
- Constrained priors (Beta on persistence, location-scale on intercepts) regularise the parameter space and avoid the boundary-pinning failure modes that frequentist MLE hits.
- Posterior sampling produces simulation paths that average over parameter uncertainty, which is the right object for the synthetic-data-generator evaluation.

A "better frequentist MS-GARCH" addresses estimator quality but does not match the reviewer's reference methodology. A Turing.jl Bayesian re-fit is methodologically equivalent to the R package; the difference is the inference engine, not the model.

## Model specification (per-state GARCH(1,1) with regime switching)

For each latent state $k \in \{1, \ldots, K\}$:
$$
\sigma_{k,t}^2 = \omega_k + \alpha_k\, r_{t-1}^2 + \beta_k\, \sigma_{k,t-1}^2,
\qquad r_t \mid s_t = k \sim \mathcal{N}(0, \sigma_{k,t}^2)
$$

Latent state $s_t \in \{1, \ldots, K\}$ follows a Markov chain with transition matrix $\mathbf{T}$. The Hamilton (1989) forward filter integrates over the latent state at each $t$.

**Priors** (Ardia 2019 conventions):
- $\omega_k \sim \mathrm{HalfNormal}(0.1)$ — strict positivity, weakly informative.
- $\alpha_k \sim \mathrm{Beta}(2, 5)$ — concentrates around small values typical for daily returns.
- $\beta_k \sim \mathrm{Beta}(5, 2)$ — concentrates around persistent values.
- Stationarity constraint: $\alpha_k + \beta_k < 1$ (rejection-sample or use a transformed parameterisation).
- $\mathbf{T}$ rows: Dirichlet$(\alpha_{\text{Dir}} = 1)$ — uniform on the simplex.

**Inference**: NUTS via Turing's default sampler. Target 4 chains $\times$ 2,000 iterations (1,000 burn-in). Convergence diagnostic: $\hat{R} < 1.05$ on every parameter, ESS $> 200$ per chain on the $\sigma_k^2$ marginals.

## Validation protocol (do this BEFORE reporting SPY numbers)

MS-GARCH MCMC is notoriously prone to label switching, multi-modality, and silent fitting failures. Three validation steps are mandatory before publishing any SPY results:

1. **Simulated-from-the-model recovery test**: Simulate $T = 2{,}516$ days from a known $(\boldsymbol\omega, \boldsymbol\alpha, \boldsymbol\beta, \mathbf{T})$ at $K = 2$, run the Turing estimator, verify the posterior 95% credible intervals cover the true parameters on $\ge 95\%$ of $20$ replicates. If recovery fails, the model code is wrong; do not proceed.

2. **Frequentist sanity check**: Compare the posterior mode at $K = 2$ to the existing in-house frequentist fit. They should agree on the regime parameters within $\sim 10\%$. Posterior should be tighter than the bootstrap CI of the frequentist estimate; if not, MCMC is not mixing.

3. **Label-switching check**: Inspect chain traces for the per-state $\omega_k$, $\alpha_k$, $\beta_k$ marginals. If chains visibly switch labels mid-run, apply identifying constraints (e.g., $\omega_1 < \omega_2 < \cdots$ or sort states by unconditional volatility before reporting). Without this, the per-state posteriors are meaningless.

## Integration with the paper

Once validated, run on the SPY IS window at $K \in \{2, 3, 4, 6\}$:

1. Generate $1{,}000$ posterior-predictive simulation paths per $K$ (matching the body Table 2 protocol).
2. Compute IS / OoS KS pass rate at $\alpha = 0.05$, mean simulated excess kurtosis, $|G_t|$ ACF-MAE, $G_t$ ACF-MAE, OoS sample CRPS.
3. Replace the in-house MS-GARCH rows in Table 2 with the Bayesian rows. Keep an appendix entry noting the frequentist baseline plateau as the contrast.
4. Update the body sentence at [sections/results.tex:81](sections/results.tex#L81) ("The MS-GARCH benchmark plateaus at $34$--$36\%$ IS KS across $K \in \{2, 3, 6\}$, so the multi-state benefit is specific to the CHMM scaffold") with the Bayesian numbers and revise the framing accordingly.

## Two outcomes, both informative

- **Bayesian MS-GARCH stays at $\sim 30\%$ IS KS**: the body claim is vindicated. Multi-state regime switching with GARCH innovations cannot match CHMM at this $T_{\text{IS}}$ on this dataset, regardless of estimator quality. The paper gets stronger because the deferred control is now in the body.
- **Bayesian MS-GARCH lifts materially (e.g., to $60$+%)**: the panel ordering shifts and the body framing must change. The honest restatement is that the multi-state benefit is shared by MS-GARCH (under proper Bayesian estimation) and CHMM, with the per-axis trade-offs (KS vs.\ ACF-MAE vs.\ kurtosis) deciding between them. This is also a stronger paper because it's a more nuanced and accurate framing.

## File layout

- `CHMM-Model/run_msgarch_bayesian.jl` — main script: load SPY IS, run validation, fit at $K \in \{2, 3, 4, 6\}$, generate paths, output metrics.
- `CHMM-Model/src/MSGARCHBayesian.jl` (new module) — Turing.jl model definition, posterior simulation utilities, label-switching post-processing.
- `CHMM-Model/test/test_msgarch_bayesian.jl` — recovery test on simulated data ($K = 2$, multiple seeds).
- `CHMM-Model/results/msgarch_bayesian/` — output: per-$K$ trace files, posterior summaries, simulated paths, KS / kurt / ACF metrics.
- `CHMM-paper/results/robustness/msgarch_bayesian.csv` — paper-side artefact for direct table import.

## Effort estimate

- Model implementation in Turing: 2-3 hours.
- Validation (recovery test + label-switching diagnostics + frequentist sanity): 1-2 hours.
- SPY runs at $K \in \{2, 3, 4, 6\}$: 30 min - 2 hours per $K$ (MCMC); largely unattended.
- Paper integration (Table 2 row replacement, body sentence update, appendix entry): 30 min.

Total active time: 4-6 hours. Wall-clock with MCMC: 8-12 hours including unattended runtime.

## Risks and mitigations

| Risk | Mitigation |
|------|------------|
| MCMC fails to mix at $K = 6$ (high-dimensional posterior, $30+$ parameters) | Start with $K = 2$, work up. If $K = 6$ fails, report $K \in \{2, 3, 4\}$ only and flag in the body. |
| Label switching contaminates per-state posteriors | Apply post-hoc state-sorting by unconditional volatility before reporting any per-state quantity. |
| Stationarity constraint $\alpha + \beta < 1$ produces high MCMC rejection rate | Use Tanh / inverse-logit reparameterisation: $\alpha = \tilde\alpha\,(1 - \tilde\beta)$, $\beta = \tilde\beta$, both in $(0, 1)$. Stationarity becomes automatic. |
| Posterior-predictive paths inherit any bug in the simulator | Validate on the recovery test: simulated-from-model paths must match the true marginal within sampling error before SPY runs. |
| Long runtime makes iteration painful | Cache fitted models with JLD2; expose a `--smoke` mode that runs $K = 2$ at $200$ iterations for debugging. |

## Decision gate

Do not begin SPY runs until:
1. Recovery test passes ($\ge 95\%$ coverage of true parameters on $20$ simulated replicates at $K = 2$).
2. Frequentist sanity check passes ($K = 2$ posterior mode within $10\%$ of in-house frequentist MLE).
3. Label-switching diagnostic shows either no switching or a working post-processing fix.

If any of the three fails, escalate to the user before continuing — do not silently report degraded numbers.

## Open questions for the user before starting

1. **Confirm priors**: the Beta(2,5) on $\alpha_k$ and Beta(5,2) on $\beta_k$ above are reasonable defaults for daily equity returns; the MSGARCH R package uses similar but not identical defaults. Worth aligning exactly to the R package's `MSGARCH::CreateSpec` defaults? (Adds documentation cost; small substantive impact.)
2. **Confirm MCMC budget**: 4 chains $\times$ 2,000 iterations is the default. If runtime is prohibitive at $K = 6$, can reduce to 2 chains $\times$ 1,000 with shorter burn-in and report wider posterior CIs.
3. **Confirm $K$ grid**: peer review asks for $K \in \{2, 3, 4, 6\}$. The body's in-house MS-GARCH only reports $K \in \{2, 3, 6\}$. Adding $K = 4$ for parity with the R-package convention is recommended.
