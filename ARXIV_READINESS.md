# arXiv Readiness — CHMM Equity-Returns Paper

*Continuous Hidden Markov Models for Equity Returns: Heavy-Tail Emission Families and
Regime-Conditional Value-at-Risk* — Alswaidan, Jin, Varner.
Checked 2026-06-21. **Compiles clean (67 pp, 0 undefined refs/cites). Two things to decide
before upload; the rest is optional.**

---

## Must do before upload

- [ ] **Bundle `paper.bbl`.** It's gitignored; arXiv won't run BibTeX. Build once, add it to
      the tarball with `paper.tex`, `sections/`, `figs/`, `references.bib`.
- [ ] **Pick the canonical repo URLs.** Data-Availability (`sections/conclusion.tex:12`) says
      `varnerlab/CHMM-Paper` and `varnerlab/CHMM-Model`; the README and dir name use
      `CHMM-Paper-Repository` / `CHMM-Model-Repository`. Make them agree and confirm both are
      public/live.

## Optional (your call)

- [ ] **Slim the tarball:** `figs/` has 102 PDFs, paper uses 17. The rest are
      regenerable from the model repo.
- [ ] **Bib polish:** ~19 unused entries in `references.bib`; only 1 DOI / 9 arXiv IDs of 114.
- [ ] Abstract is 290 words (fits arXiv's char cap; trim toward ~250 if you like).
- [ ] Regenerate the committed `paper.pdf` so the tagged PDF matches final source.

## Data verification (2026-06-21)

Reconciled every load-bearing table against the model-repo artifacts
(`CHMM-Model-Repository/results/`): **Table 2, the cross-asset copula tables, the
regime-conditional VaR panel, the walk-forward 19/24 result, and the K\*=3 / K\*=6 / K=18
cross-ticker refit all match.** The numbers are sound. One residual cosmetic item:

- [ ] **Cosmetic:** Gaussian-copula IS off-diag MAE is **0.029** in the artifact but printed
      **0.030** (rounding; Student-t at 0.027 still leads — conclusion unchanged). Fix or leave.

> **K=18 quarterly refit — resolved.** The appendix block (`tab:cross_ticker_quarterly_refit`,
> `sensitivity_appendix.tex` ~L328–337) had no checked-in artifact because the runner defaults
> to K=3. Regenerated 2026-06-21 with `SECTOR_PANEL_K=18`: the output matches the paper exactly
> — median **83.0%**, mean **77.2 ± 21.2**, IQR **[62.0, 95.4]**, **7/30** failures, and all five
> per-ticker rows (LLY 83.7, UNH 47.3, NEM 15.4, HD 82.2, NFLX 61.5). The artifact is now saved
> as `CHMM-Model-Repository/results/sector_panel/sector_panel_quarterly_refit_k18.{csv,txt}`
> (the default `sector_panel_quarterly_refit.{csv,txt}` remains the K=3 run). No paper edit needed.

## Already verified — no action

Clean compile, 67 pp, 0 undefined refs/cites, 0 multiply-defined labels, 0 over/underfull
boxes. All 95 cited keys defined. All 17 referenced figures present. No leftover
TODO/FIXME markers. COI / Author-Contributions / Data-Availability statements present
(`conclusion.tex:6–12`). Prior stale-Table-2 blocker resolved (CSV now matches).
