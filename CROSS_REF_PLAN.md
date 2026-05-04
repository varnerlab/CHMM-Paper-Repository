# Cross-Reference Plan: CHMM-paper ↔ SM-CHMM-AR-Paper for arXiv

**Date:** 2026-05-04
**Scope:** Two sibling preprints by the same authors, both arXiv-bound, with overlapping algorithmic content. Decide whether/how the two papers should cite each other and in what order to post.

**Decision:** Plan B (asymmetric: drop CHMM → SM, keep SM → CHMM). See §4.

---

## 0. Implementation status (last updated 2026-05-04)

Decision adopted: **Plan B**. Work done so far:

| Item | Repo | File | Status |
|---|---|---|---|
| Drop CHMM → SM cite (`baselines_appendix.tex:122`); replace with `\citet{yu2010hidden}` | CHMM-paper | `sections/baselines_appendix.tex` | **Done** (2026-05-04) |
| Remove orphan `@article{alswaidan2026smchmm,...}` from CHMM bib | CHMM-paper | `references.bib` | **Done** (2026-05-04) |
| Fix SM-side bib title to match actual CHMM-paper title (§1a bug) | SM-CHMM-AR-Paper | `references.bib:5` | **Done** (2026-05-04) |
| Fill live CHMM arXiv ID into SM bib; delete `note={arXiv ID to be filled in...}` | SM-CHMM-AR-Paper | `references.bib:7-8` | Pending arXiv post of CHMM-paper |
| Submit CHMM-paper to arXiv | CHMM-paper | n/a | Pending |
| Submit SM-paper to arXiv (after CHMM ID is in SM bib) | SM-CHMM-AR-Paper | n/a | Pending |
| Update `SM-CHMM-AR-Paper/plan-cross-paper-citations.md` to note step 3 (CHMM v2) no longer required under Plan B | SM-CHMM-AR-Paper | `plan-cross-paper-citations.md` | Pending |

CHMM-paper is now self-contained (no `\cite{alswaidan2026smchmm}` remains in prose) and can be posted to arXiv at any time. No CHMM v2 upload is required.

---

## 1. Inventory of the current cross-reference state

### 1a. SM-CHMM-AR-Paper → CHMM-paper

Three formal `\cite{alswaidan2026chmm}` calls, all in algorithmic-attribution positions:

| File:line | Context | What it credits |
|---|---|---|
| `sections/estimation.tex:68` | Laplace SM-CHMM-L-AR variant: "weighted-median location estimator with a weighted-mean-absolute-deviation (WMAD) scale, following the closed-form Laplace M-step developed in the companion equity-returns CHMM paper \citep{alswaidan2026chmm}." | Closed-form Laplace M-step |
| `sections/algorithms_appendix.tex:147` | Algorithm 2 inline comment: "weighted LAD + weighted-median / WMAD M-step of \citet{alswaidan2026chmm}." | Same |
| `sections/algorithms_appendix.tex:192` | Algorithm 3 plug-in init step 1: "Laplace weighted median \citep{alswaidan2026chmm}." | Same |

Bib entry: `SM-CHMM-AR-Paper/references.bib:4-10` — placeholder `arXiv:XXXX.XXXXX`, with `note={arXiv ID to be filled in after CHMM-paper is posted}`.

**Bug to fix in the SM bib (independent of this plan):** the `title` field reads *"A Regime-Switching Continuous Hidden Markov Model as a Reference Synthetic-Data Generator for Equity Returns: Extended Evaluation, Semi-Markov Ablation, and Regime-Conditional Value-at-Risk"*. The CHMM-paper's actual title (per `paper.tex:69` and `:99`) is *"Continuous Hidden Markov Models for Equity Returns: Spectral Rank, Heavy-Tail Emission Families, and Regime-Conditional Value-at-Risk"*. The SM-side bib entry was written against an earlier title and never refreshed. Fix this together with the arXiv ID step.

### 1b. CHMM-paper → SM-CHMM-AR-Paper

One formal `\cite{alswaidan2026smchmm}` call, in an appendix:

| File:line | Context | What it credits |
|---|---|---|
| `sections/baselines_appendix.tex:122` | SM-CHMM baseline paragraph: "the explicit-duration HSMM construction of the companion volatility paper \cite{alswaidan2026smchmm}: a hidden semi-Markov extension of the CHMM in which the geometric sojourn distribution of the Markov chain is replaced by a per-state explicit-duration family chosen by AIC from {Pareto, negative binomial, geometric}." | Explicit-duration HSMM construction; provides the conceptual foil for the CHMM's appendix baseline panel |

Bib entry: `CHMM-paper/references.bib:19-24` — no `journal` field, no arXiv ID, only `note={Manuscript in preparation, not yet submitted.}`. The cite renders cleanly (the note becomes the bibliography body), but there is no machine-resolvable link.

### 1c. Pre-existing plan in the SM repo

`SM-CHMM-AR-Paper/plan-cross-paper-citations.md` already exists and proposes:

1. Post CHMM-paper to arXiv first (no edits required).
2. Post SM-paper second, after filling the CHMM arXiv ID into `SM-CHMM-AR-Paper/references.bib`.
3. Upload CHMM v2 with the SM arXiv ID filled into `CHMM-paper/references.bib`.

That plan is sound. This document expands the "can we drop the cross-cite" question the existing plan does not address, and reconciles to the same submission order at the end.

### 1d. Model repos (sanity check)

- `SM-CHMM-AR-Model/README.md` describes its scaffold as "built on the CHMM scaffold and extended with semi-Markov sojourns and AR(1) emissions" — explicit dependency in code documentation.
- `CHMM-Model/README.md` publishes the canonical bib key `alswaidan2026chmm` already used by SM-paper.
- The two model repos are openly cross-aware; the question is purely about the paper preprints.

---

## 2. The "can we drop the cross-citation?" question, broken out by direction

The two directions are not symmetric. They should be evaluated separately.

### 2a. SM → CHMM (the 3 algorithmic attributions): **should not drop**

These are not pointer citations. They credit a specific closed-form derivation (weighted-median location + WMAD scale for the Laplace EM M-step) that the CHMM paper develops in its estimation section / algorithms appendix. Dropping them would force one of:

1. **Re-derive the Laplace M-step inside SM-paper.** Doable but adds material the SM-paper currently does not need to host; it is a pure scope expansion for no benefit.
2. **Cite a textbook source instead of the CHMM-paper.** The weighted-median estimator is classical (e.g., Bloomfield-Steiger 1983), but the *closed-form weighted-MAD-with-bias-correction-for-the-Laplace-EM-M-step* recipe used by SM-CHMM-L-AR is the CHMM-paper's specific construction. A textbook substitute exists for the location update only, not for the joint location-scale recipe; replacing the cite would be technically defensible only with a partial textbook substitute plus an unattributed scale formula.
3. **Just drop the citation.** Poor scholarly practice and creates an attribution gap that any careful reader (or peer reviewer comparing the two preprints) will flag.

The existing three-citation pattern is correct. **Keep all three.**

### 2b. CHMM → SM (the 1 baseline-appendix attribution): **dispensable, with a small rewrite**

This citation lives in `baselines_appendix.tex` — appendix scope, baseline panel. Its role is to (i) explain what the SM-CHMM baseline is, and (ii) point the reader to the longer treatment.

The construction itself is essentially a re-application of textbook explicit-duration HSMM (Yu 2010 is already cited in the same paragraph at L125). The CHMM-paper's *own* SM-CHMM baseline is fitted by a plug-in Viterbi-AR(1)-resampling estimator that is described in full in the same appendix and is **not** the SM-paper's joint-EM construction. So the `\cite{alswaidan2026smchmm}` is a courtesy pointer rather than an algorithmic dependency.

It can be removed at the cost of:
- Rewriting one phrase: "the explicit-duration HSMM construction of the companion volatility paper \cite{alswaidan2026smchmm}" → "an explicit-duration HSMM extension of the CHMM in the spirit of \citet{yu2010hidden}".
- Deleting the `alswaidan2026smchmm` bib entry from `CHMM-paper/references.bib` (or leaving it; orphan entries are harmless under `unsrtnat` because uncited entries don't render).
- Accepting that the CHMM-paper no longer publicly signposts the SM-paper's existence (the SM-paper still cites CHMM, so discoverability remains one-way — sufficient for reverse search via Semantic Scholar / Google Scholar).

The `\cite` is dispensable. Whether to drop it depends on preference, not necessity.

---

## 3. Three viable plans

### Plan A — Keep both directions (matches the existing `plan-cross-paper-citations.md`)

Bidirectional citation, requires staged arXiv submission.

**Steps:**
1. Submit CHMM-paper to arXiv. The existing `alswaidan2026smchmm` bib entry's `note={Manuscript in preparation, not yet submitted.}` renders cleanly; the SM-paper does not yet need to be live for CHMM v1 to be valid.
2. Record CHMM arXiv ID. In `SM-CHMM-AR-Paper/references.bib` entry `alswaidan2026chmm`:
   - Replace `journal={arXiv preprint arXiv:XXXX.XXXXX}` with the live ID.
   - Delete the `note={arXiv ID to be filled in after CHMM-paper is posted}` line.
   - **Fix the title field** to match the actual CHMM-paper title (see §1a bug).
3. Submit SM-paper to arXiv. Record SM arXiv ID.
4. Upload CHMM v2 with `journal={arXiv preprint arXiv:<SM-ID>}` added and the `note={Manuscript in preparation}` removed in `CHMM-paper/references.bib` entry `alswaidan2026smchmm`. No prose edits in CHMM-paper.

**Pros:** Maximum discoverability; both readerships find the other paper through the bibliography; honest signposting that two related works exist.
**Cons:** Requires the v2 upload step on the CHMM side; coupling between the two release schedules.

### Plan B — Asymmetric: drop CHMM → SM, keep SM → CHMM (RECOMMENDED if you want to minimize coupling)

Cuts the one dispensable citation and decouples the two release schedules.

**Steps:**
1. In `CHMM-paper/sections/baselines_appendix.tex:122`, edit:
   - From: "the explicit-duration HSMM construction of the companion volatility paper \cite{alswaidan2026smchmm}"
   - To: "an explicit-duration HSMM extension of the CHMM in the spirit of \citet{yu2010hidden}"
   (The `\citet{yu2010hidden}` cite later in the same paragraph at L125 already exists in the bib; verify with `grep yu2010hidden references.bib`.)
2. Optionally remove the now-orphan `@article{alswaidan2026smchmm, ...}` entry from `CHMM-paper/references.bib`. Orphan removal is cosmetic; leaving it costs nothing.
3. Submit CHMM-paper to arXiv. No v2 needed, ever.
4. Steps 2-3 of Plan A apply on the SM side: fill the CHMM arXiv ID and the title fix into `SM-CHMM-AR-Paper/references.bib`, then submit SM-paper.

**Pros:** No coupling between release schedules. CHMM-paper is fully self-contained from v1. SM-paper still credits CHMM for the Laplace M-step (as it should). One-way citation graph is the cleanest topology for two related preprints: SM is downstream of CHMM in the algorithmic dependency, so the citation graph mirroring that ordering reads naturally.
**Cons:** Reader of CHMM-paper does not find the SM-paper through the bibliography. Discoverability is one-way (still works via reverse-citation tools).

### Plan C — Drop both directions

Not recommended. Forces re-derivation of the Laplace M-step inside SM-paper or leaves an unattributed gap. The SM → CHMM citations are real algorithmic dependencies (§2a). Cutting them is poor scholarship.

---

## 4. Recommendation

**Plan B.** The asymmetry matches the actual algorithmic dependency (SM borrows from CHMM, not vice versa), avoids the v2 dance, and the one-way citation graph is the cleanest topology for two related preprints by the same authors. The cost is one short prose edit in `baselines_appendix.tex` and the loss of one passive forward-reference in CHMM-paper to a paper that the reader will find anyway via reverse citation lookup.

Plan A is also defensible if you specifically want CHMM-paper readers to discover SM-paper through the bibliography. The existing `plan-cross-paper-citations.md` in the SM repo prescribes Plan A; both are coherent, and the choice is preference, not correctness.

---

## 5. Concrete edit checklist

### If Plan B (recommended) — **adopted 2026-05-04**

In `CHMM-paper`:
- [x] `sections/baselines_appendix.tex:122`: replace the cited phrase per §3 Plan B step 1. *(Done 2026-05-04: the phrase now reads "drawing on an explicit-duration HSMM extension of the CHMM in the spirit of \citet{yu2010hidden}".)*
- [x] (Optional) `references.bib`: remove the `@article{alswaidan2026smchmm, ...}` entry. *(Done 2026-05-04.)*
- [ ] Submit CHMM-paper to arXiv. Record the ID.

In `SM-CHMM-AR-Paper`:
- Partial: see sub-items.
  - [x] **Fix the `title` field** to: `{Continuous Hidden Markov Models for Equity Returns: Spectral Rank, Heavy-Tail Emission Families, and Regime-Conditional Value-at-Risk}`. *(Done 2026-05-04 at `references.bib:5`.)*
  - [ ] Replace `journal={arXiv preprint arXiv:XXXX.XXXXX}` with the live CHMM arXiv ID *(pending CHMM arXiv post)*.
  - [ ] Delete the `note={arXiv ID to be filled in after CHMM-paper is posted}` line *(pending CHMM arXiv post)*.
- [ ] Submit SM-CHMM-AR-Paper to arXiv.
- [ ] Update `SM-CHMM-AR-Paper/plan-cross-paper-citations.md` to note that step 3 (CHMM v2) is no longer required under Plan B.

### If Plan A (existing-plan-compatible)

In `CHMM-paper`:
- [ ] No prose edits.
- [ ] Submit CHMM-paper to arXiv. Record the ID.
- [ ] After SM-paper is on arXiv: edit `references.bib:19-24` to add `journal={arXiv preprint arXiv:<SM-ID>}` and delete the `note={Manuscript in preparation, not yet submitted.}` line. Upload CHMM v2.

In `SM-CHMM-AR-Paper`:
- [ ] Same edits as Plan B step 1 above (live CHMM ID + delete-note + fix-title).
- [ ] Submit SM-CHMM-AR-Paper to arXiv.

---

## 6. Direct answer to the user's question

**Q: Can we drop the cross-citation?**

Asymmetrically, yes. The CHMM → SM citation (1 site, in an appendix) is a courtesy pointer that can be replaced by a textbook reference (Yu 2010, already cited nearby). Dropping it makes CHMM-paper self-contained and removes the need for a CHMM v2 arXiv upload after SM-paper is posted.

The SM → CHMM citations (3 sites, in the estimation section and algorithms appendix) are real algorithmic attributions for the closed-form Laplace M-step. They should be kept; the alternative is re-deriving the M-step inside SM-paper, which is a pure scope expansion for no benefit.

**Best path:** Plan B above. Drop CHMM → SM, keep SM → CHMM, post CHMM-paper first (no coupling, no v2), then post SM-paper with the live CHMM arXiv ID in its bib. Fix the SM-side bib title bug at the same step.
