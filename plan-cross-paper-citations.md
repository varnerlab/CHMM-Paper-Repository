# Publishing plan: CHMM-paper and SM-CHMM-AR-Paper

Two companion papers are ready to post to arXiv. Each cites the other,
so the submission order matters. Both manuscripts currently compile
cleanly; the cross-citations use placeholder arXiv IDs (or no journal
field at all) that need to be filled in at submission.

## Asymmetry that drives the order

The two cross-references are not symmetric in weight:

- **SM-CHMM-AR-Paper cites CHMM-paper in three load-bearing places.**
  `sections/estimation.tex:68` and `sections/algorithms_appendix.tex:147,192`
  attribute the closed-form weighted-LAD / weighted-median / WMAD M-step
  for the Laplace variant to the CHMM paper. This is a real algorithmic
  dependency, not a courtesy reference.

- **CHMM-paper cites SM-CHMM-AR-Paper in one sentence.**
  `sections/var_backtest.tex:69` notes that the Pareto-sojourn pattern
  is consistent with preliminary results in a companion paper. Soft
  reference; no equations or numbers depend on it.

Posting CHMM first means SM v1 ships with a live CHMM arXiv ID at the
substantive citations. The reverse order forces SM v1 to point at a
placeholder for the algorithm it reuses, which is the worse failure
mode.

## Submission sequence

1. **Post `CHMM-paper` first.** Submit as-is and record the arXiv ID
   you receive. The current bib entry for SM-CHMM-AR
   (`alswaidan2026smchmm` in `CHMM-paper/references.bib`) just carries
   `note={Manuscript in preparation}` with no `journal` field. The
   in-text citation at `sections/var_backtest.tex:69` already calls SM
   "a companion paper in preparation," which is consistent with that
   bib state, so v1 of CHMM is internally coherent without edits.

2. **Post `SM-CHMM-AR-Paper` second.** Before uploading, open
   `SM-CHMM-AR-Paper/references.bib`, find the entry
   `alswaidan2026chmm`, replace `arXiv:XXXX.XXXXX` in the `journal`
   field with the CHMM arXiv ID from Step 1, delete the `note` line,
   and rebuild. Then submit and record the new SM arXiv ID.

3. **Upload a v2 of `CHMM-paper`.** Two coordinated edits:

   a. `CHMM-paper/references.bib`: in the `alswaidan2026smchmm` entry,
      *add* a `journal={arXiv preprint arXiv:<SM-ID>}` line (the entry
      currently has no `journal` field) and *delete* the existing
      `note={Manuscript in preparation}` line.

   b. `CHMM-paper/sections/var_backtest.tex:69`: change "a companion
      paper in preparation \citep{alswaidan2026smchmm}" to "a companion
      paper \citep{alswaidan2026smchmm}" (drop "in preparation"). The
      paper is no longer in preparation once it has an arXiv ID.

   Rebuild and upload as v2 on arXiv. arXiv accepts author-initiated
   v2 replacements without re-review.

End state: each paper cites the other by live arXiv ID, and the prose
wording in CHMM no longer claims SM is unpublished.

## Alternative: same-day submission

Submit both papers on the same day. If arXiv assigns IDs in the same
announcement cycle, the IDs can be pre-populated (or coordinated with
arXiv), eliminating the v2 step. Use this if the timing is convenient;
otherwise the three-step sequence above is the clean default. The
prose edit in 3(b) still applies under same-day submission.
