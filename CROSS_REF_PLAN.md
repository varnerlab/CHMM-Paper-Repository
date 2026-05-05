# Cross-Reference Plan: CHMM-paper and SM-CHMM-AR-Paper

**Date:** 2026-05-05 (refreshed after the review-response sweep; the original cross-reference resolution from 2026-05-04 still stands, with one mechanical follow-up: the CHMM-paper title was trimmed on 2026-05-05 from "Continuous Hidden Markov Models for Equity Returns: Spectral Rank, Heavy-Tail Emission Families, and Regime-Conditional Value-at-Risk" to "Continuous Hidden Markov Models for Equity Returns: Heavy-Tail Emission Families and Regime-Conditional Value-at-Risk", so the SM-paper bib's `title` field needs a one-line resync at the same time as the arXiv-ID backfill in Step 2 below.)
**Audience:** Co-authors preparing both preprints for arXiv.

---

## The situation in plain language

We have two related preprints by the same author team going to arXiv:

1. **CHMM-paper** (this repo): the equity-returns CHMM paper.
2. **SM-CHMM-AR-Paper** (sibling repo at `~/Desktop/Project-Repos/SM-CHMM-AR-Paper`): the VIX semi-Markov paper.

The two papers share some algorithmic content. Specifically, the SM-paper reuses the closed-form Laplace M-step (weighted median location, weighted MAD scale) that is derived in the CHMM-paper. So the SM-paper needs to give the CHMM-paper credit. The reverse direction was less essential: the CHMM-paper had a single courtesy citation to the SM-paper in an appendix, but the construction it pointed to (an explicit-duration HSMM) is already covered by a textbook reference (Yu, 2010) cited in the same paragraph.

We decided to use a **one-way citation** approach (called "Plan B" below):

- **SM-paper cites CHMM-paper** in three places (the Laplace M-step credit). These citations stay.
- **CHMM-paper does NOT cite SM-paper.** The one previous citation was replaced by the Yu (2010) reference.

The benefit: the two papers can be submitted to arXiv independently. The CHMM-paper does NOT need a follow-up "v2" upload after the SM-paper goes live. The SM-paper still needs the live CHMM arXiv ID before its own submission, so the submission order is fixed: **CHMM-paper first, then SM-paper**.

All paper-side edits on the CHMM side are complete. CHMM-paper is fully self-contained and rebuilt cleanly on 2026-05-05 (66 pages after the review-response sweep, no undefined-citation warnings, no orphan bib entries). The remaining SM-paper bib edit is two lines (title resync + arXiv-ID backfill); both happen in Step 2.

---

## What you (the professor) need to do at arXiv submission time

There are three steps. Steps 1 and 3 are arXiv uploads. Step 2 is a small bib edit in the SM-paper repo, between the two uploads.

### Step 1: Submit CHMM-paper to arXiv

- The PDF to upload is `CHMM-paper/paper.pdf` (current build, 2026-05-04, 63 pages).
- No edits are needed in the CHMM-paper repo before submission.
- After arXiv accepts the submission, **record the arXiv ID**. It will look like `arXiv:2605.NNNNN` (the exact prefix depends on the announcement month).

### Step 2: Update the SM-paper bib with the new CHMM title and the CHMM arXiv ID

Two small, mechanical edits. The first resyncs the title field after the 2026-05-05 CHMM title trim; the second backfills the live CHMM arXiv ID. Both happen in the same edit so the SM-paper's three SM-to-CHMM citations resolve correctly.

- Open `SM-CHMM-AR-Paper/references.bib`.
- Find the first entry, `@article{alswaidan2026chmm, ...}`, at lines 4 to 10. It currently looks like:

  ```
  @article{alswaidan2026chmm,
    title={Continuous Hidden Markov Models for Equity Returns: Spectral Rank, Heavy-Tail Emission Families, and Regime-Conditional Value-at-Risk},
    author={Alswaidan, Abdulrahman and Jin, Cade and Varner, Jeffrey D.},
    journal={arXiv preprint arXiv:XXXX.XXXXX},
    note={arXiv ID to be filled in after CHMM-paper is posted},
    year={2026}
  }
  ```

- Replace the `title` value with the trimmed-on-2026-05-05 CHMM title:

  ```
    title={Continuous Hidden Markov Models for Equity Returns: Heavy-Tail Emission Families and Regime-Conditional Value-at-Risk},
  ```

- Replace `arXiv:XXXX.XXXXX` with the real CHMM arXiv ID from Step 1. For example, if the ID is `2605.12345`, the line becomes:

  ```
    journal={arXiv preprint arXiv:2605.12345},
  ```

- Delete the line `note={arXiv ID to be filled in after CHMM-paper is posted},` entirely.
- Rebuild the SM-paper: `cd ~/Desktop/Project-Repos/SM-CHMM-AR-Paper && make clean && make`.
- Confirm `paper.pdf` is fresh and that the bibliography shows the new title and the live CHMM arXiv ID.

### Step 3: Submit SM-paper to arXiv

- The PDF to upload is `SM-CHMM-AR-Paper/paper.pdf` (after the rebuild in Step 2).
- No further edits are required in CHMM-paper.
- Record the SM arXiv ID for your own records.

That is the full submission flow. There is no Step 4.

---

## Why we picked this approach (one paragraph)

The SM-paper's three CHMM citations credit a real algorithmic contribution: the closed-form weighted-median plus weighted-MAD recipe for the Laplace EM M-step. Removing those would force re-deriving the M-step inside the SM-paper, a pure scope expansion for no benefit. The CHMM-paper's one SM citation was different in character: it was a courtesy pointer in an appendix paragraph rather than an algorithmic dependency, and the same paragraph already cited Yu (2010) for the underlying explicit-duration HSMM construction. Replacing the SM cite with a stronger Yu (2010) cite kept the paragraph honest while making CHMM-paper self-contained. The asymmetry also matches the actual dependency direction (SM is built on top of CHMM), so a one-way citation graph reads naturally.

---

## What is already done (no action needed from you)

| Item | Repo | File | Status |
|---|---|---|---|
| Replace the one CHMM-to-SM citation with `\citet{yu2010hidden}` | CHMM-paper | `sections/baselines_appendix.tex` | Done 2026-05-04 |
| Remove orphan `@article{alswaidan2026smchmm,...}` from CHMM bib | CHMM-paper | `references.bib` | Done 2026-05-04 |
| Fix SM-side bib title field to match the actual CHMM-paper title | SM-CHMM-AR-Paper | `references.bib:5` | Done 2026-05-04 (superseded by 2026-05-05 title trim; needs one-line resync at Step 2) |
| Clean rebuild of CHMM-paper, verify zero undefined-citation warnings | CHMM-paper | (build) | Done 2026-05-05 (66 pages after review-response sweep) |
| Update SM-side `plan-cross-paper-citations.md` to reflect Plan B | SM-CHMM-AR-Paper | `plan-cross-paper-citations.md` | Done 2026-05-04 |

Verification (post `make clean && make` on 2026-05-05): final `paper.pdf` is 66 pages, 1{,}535{,}474 bytes; `paper.log` and `paper.blg` contain zero `Citation undefined` / `Reference undefined` warnings and zero references to the removed `alswaidan2026smchmm` key. The only residual log warnings are pre-existing float-placement notices, which are unrelated to the cross-reference plan.

---

## Background and detailed analysis (optional reading)

The remainder of this document records the analysis that led to the chosen plan. Co-authors who only need the action items can stop reading here.

### Inventory of cross-references (state at decision time)

#### SM-CHMM-AR-Paper -> CHMM-paper

Three formal citation calls, all crediting a specific algorithmic recipe:

| File:line | Context | What it credits |
|---|---|---|
| `sections/estimation.tex:68` | Laplace SM-CHMM-L-AR variant: "weighted-median location estimator with a weighted-mean-absolute-deviation (WMAD) scale, following the closed-form Laplace M-step developed in the companion equity-returns CHMM paper \citep{alswaidan2026chmm}." | Closed-form Laplace M-step |
| `sections/algorithms_appendix.tex:147` | Algorithm 2 inline comment: "weighted LAD + weighted-median / WMAD M-step of \citet{alswaidan2026chmm}." | Same |
| `sections/algorithms_appendix.tex:192` | Algorithm 3 plug-in init step 1: "Laplace weighted median \citep{alswaidan2026chmm}." | Same |

Bib entry: `SM-CHMM-AR-Paper/references.bib:4-10`. Title field was corrected on 2026-05-04 to match the then-current CHMM-paper title; the CHMM title was further trimmed on 2026-05-05 (dropped the "Spectral Rank" subtitle), so the SM-paper bib `title` field needs a one-line resync at the same time as the arXiv-ID backfill in Step 2 above. The `journal` field still has the placeholder `arXiv:XXXX.XXXXX` to be filled in at submission.

#### CHMM-paper -> SM-CHMM-AR-Paper

There used to be one citation in the appendix baselines paragraph at `sections/baselines_appendix.tex:122`. It has been removed and replaced with `\citet{yu2010hidden}`. The orphan bib entry `@article{alswaidan2026smchmm,...}` has been removed from `CHMM-paper/references.bib`.

### Plans considered and why we picked Plan B

We considered three options:

1. **Plan A (bidirectional citation):** Keep both directions. Requires a CHMM v2 upload after the SM-paper is on arXiv, to backfill the SM arXiv ID into the CHMM bib. Defensible, but adds a coordination step and a second upload.
2. **Plan B (asymmetric, ADOPTED):** Drop the one CHMM-to-SM citation, keep the three SM-to-CHMM citations. CHMM-paper becomes self-contained from v1; only the SM-paper needs to wait for the CHMM arXiv ID. No CHMM v2 needed.
3. **Plan C (drop both directions):** Rejected. The three SM-to-CHMM citations credit a real algorithmic dependency. Removing them is poor scholarly practice; any careful reader comparing the two preprints would flag the gap.

Plan B was chosen because the asymmetry matches the actual algorithmic dependency direction (SM is built on top of CHMM, not the other way around), it avoids the v2 upload, and it decouples the two release schedules.

### Note on discoverability

Under Plan B, a reader of CHMM-paper does not find the SM-paper through the bibliography. Discoverability is one-way. This is acceptable because Semantic Scholar, Google Scholar, and arXiv all support reverse-citation lookup: anyone reading CHMM-paper can find papers that cite it (including the SM-paper) within a few clicks. The cost of one-way citation graph is small; the gain in submission simplicity is large.
