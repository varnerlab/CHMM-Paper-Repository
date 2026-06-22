# arXiv Readiness — CHMM Equity-Returns Paper

*Continuous Hidden Markov Models for Equity Returns: Heavy-Tail Emission Families and
Regime-Conditional Value-at-Risk* — Alswaidan, Jin, Varner.
**Ready to upload.** The source was test-compiled with pdflatex only (no BibTeX, as arXiv
runs it): 68 pp, 0 undefined refs/cites, 0 missing figures.

---

## What I did

- Verified every headline table against the model code — all match.
- Regenerated and saved the one missing artifact (the K=18 quarterly-refit numbers).
- Bibliography: removed 19 uncited entries, fixed 3 mistyped entry types, added arXiv/DOI
  fields to 8 preprints, and added the one missing citation (Benjamini–Hochberg, 1995).
  Now 96 entries, 0 unused, 0 undefined.
- Fixed a cosmetic rounding (Gaussian-copula in-sample MAE 0.030 → 0.029).
- Fixed the Data-Availability repository URLs to the current repos under varnerlab account.
- Rebuilt `paper.pdf`.

## To upload

Bundle and upload — the bibliography is pre-built and verified:

- Include `paper.tex`, `sections/`, `references.bib`, the figures, and **`paper.bbl`**
  (it's gitignored; rebuild with `make`, which produces it). arXiv won't run BibTeX, so the
  `.bbl` must be in the upload.
- Verified to compile on arXiv's pdflatex-only setup (68 pp, 0 undefined, 0 missing figures).
- Set the category (`q-fin.ST`).

## Optional — repo cleanup before going public

The Data-Availability statement points readers to the two GitHub repos. Before making them
public, consider removing internal planning / working notes that readers don't need:

- **Paper repo:** `AUDIT_2026-06-16.md`, `CROSS_REF_PLAN.md`, `PROFF_PREP.md`,
  `REVIEW_FINDINGS.md`, `code-review-issues.md`, `critical-issues-to-fix.md`, and this
  `ARXIV_READINESS.md`. Keep `README.md`.
- **Model repo** (`CHMM-Model-Repository`): `CLAUDE.md` (AI-assistant notes); optionally
  `_attic/runners/README.md` and `results/SPY/Main-Body-Selection-Note.md`. Keep `README.md`,
  `RUNNERS.md`, `SPECIFICATION.md`, and `docs/`.
