# arXiv Readiness: This Paper vs. arXiv:2603.10202

Date: 2026-04-27
Compared:
- **Current**: "A Regime-Switching Continuous Hidden Markov Model as a Reference Synthetic-Data Generator for Equity Returns" (Alswaidan, Jin, Varner; 57 pp, ~22.2k words, 84 refs)
- **Prior**: arXiv:2603.10202 "Hybrid Hidden Markov Model for Modeling Equity Excess Growth Rate Dynamics: A Discrete-State Approach with Jump-Diffusion" (Alswaidan, Varner; 36 pp; posted 2026-04-03)

Note: 2603.10202 is the same group's prior preprint, so this is really "v2/successor vs. v1" rather than two unrelated submissions. The question becomes whether the new paper clears the bar that the earlier one already cleared.

---

## Where the new paper is clearly stronger

- **Single, sharp contribution.** The prior paper bolts jump-diffusion onto an HMM as a hybrid; the framing is "we combine A and B." This paper's claim is one sentence: a vanilla CHMM at moderate $K$ reproduces all three stylized facts simultaneously, and the spectral identity $\rho_{|G|}(\tau)=\sum_{k\ge 2} w_k\lambda_k^\tau$ explains why. That is a publishable result on its own; the prior paper's contribution reads more like a methodology demo.
- **Theoretical content.** New paper has a `theory.tex` with the closed-form ACF identity, identifiability/consistency/ECM-monotonicity propositions cited from standard results, and an explicit $K$-rank reading of the low-$K$ failure of Rydén-era HMMs. The prior paper is largely descriptive.
- **Empirical breadth.** New paper runs a 7-metric panel (KS, AD, kurt, ACF-MAE, CRPS, Kupiec LR, ES envelope) across IS+OoS, three emission families (N/t/L), seven $K$ values, six tickers, and three dependence layers (SIM, Gaussian copula, t-copula). Prior paper relied on KS/AD plus Monte Carlo. Block-bootstrap KS, multi-seed stability, and DM tests on CRPS are all present.
- **Baseline coverage.** Headline panel covers iid bootstrap, Gaussian, Laplace, GARCH(1,1), GARCH(1,1)-t, MS-GARCH; extended panel adds EGARCH, GJR-GARCH, HAR-RV, MS-GARCH $K=3$, SM-CHMM, and a real QuantGAN row (D1 in `arxiv-prep-review.md` confirms the WGAN was actually re-run under the new metric panel rather than cited).
- **Production polish.** 57 pp, 84 references, ~22.2k words, clean PDF build with no undefined refs (per the prep review). Custom macros, `placeins`+`\FloatBarrier` discipline, hyperref metadata, descriptive labels (the M-coded `tab:m7_*` etc. were renamed in D6a). PDF metadata title/keywords match the paper.
- **Reproducibility.** Companion `CHMM-Model.jl` repo with public API and `run_full_rebuild.jl` entry point; the prep review documents the model-repo cleanup (D2-D6) so reviewers landing on the GitHub link see a coherent tree, not v9/v10 detritus. Prior paper does not advertise a code release in its abstract.

## Where it is at parity or slightly weaker

- **Length.** 57 pp vs. 36 pp. Defensible given the wider experiment grid, but on the long end for an arXiv preprint; most of the bulk is in the appendix. Tradeoff, not a blocker.
- **Author list change.** Cade Jin is added; if 2603.10202 is the closest cite, this paper should explicitly position itself relative to it in `related_work.tex` (currently only 11 lines, no self-citation). A reviewer landing here from the prior preprint will look for the delta in one sentence.

## Remaining gaps before posting

From `arxiv-prep-review.md` plus a spot-check on 2026-04-27:

- **S7 not yet executed.** 12 body sites still call `Appendix~\ref{sec:supplementary}` instead of granular subsection labels (`sec:supp_algorithms`, `sec:m7_baselines`, `sec:supp_cross_asset`, etc.). Verified in `estimation.tex:16`, `model.tex:170,177`, `results.tex:16,21,57,74,110,145`, `discussion.tex:5,33,36`, `theory.tex:5,78`, `related_work.tex:8`, `conclusion.tex:11`. ~30 min of search-and-replace, would meaningfully improve navigability.
- **S4-S6 status unclear.** Orphan supplementary subsections, unused figure files in `figs/`, and unused proposition labels are listed as Phase 1 work but not marked DONE. Worth a final sweep.
- **S2/S3 appear done.** No remaining hits for "Walk-Forward Summary," "MMD," "Christoffersen," or `\LRind`.
- **Self-citation to 2603.10202.** If posting this as a sibling preprint, add a one-line situating sentence in the intro and a `references.bib` entry.

## Verdict

This paper is more ambitious, more rigorous, and better presented than 2603.10202. The prior preprint already cleared arXiv's bar with thinner empirical and theoretical content, so on absolute terms this one is well past the threshold. The blockers are cosmetic: S7 appendix routing and S4-S6 final cleanup. Could ship today and address S7 in v2; recommended path is a 1-2 hour pass to land them in v1.
