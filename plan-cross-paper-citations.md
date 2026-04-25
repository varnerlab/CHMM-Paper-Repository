# Publishing plan: CHMM-paper and SM-CHMM-AR-Paper

Both papers are ready for arXiv and cross-cite each other. Submission
order matters because cross-citations need live arXiv IDs.

## Order: CHMM first, then SM-CHMM-AR

SM cites CHMM's closed-form Laplace M-step in three places
(`estimation.tex:68`, `algorithms_appendix.tex:147,192`) — a real
algorithmic dependency. CHMM cites SM in one sentence as preliminary
results (`var_backtest.tex:69`). Posting CHMM first lets SM v1 ship
with a live CHMM ID at the substantive citations.

## Steps

1. **Post CHMM-paper.** No edits needed; current `alswaidan2026smchmm`
   bib entry says "Manuscript in preparation," matching the in-text
   wording. Record the CHMM arXiv ID.

2. **Post SM-CHMM-AR-Paper.** In `SM-CHMM-AR-Paper/references.bib`,
   entry `alswaidan2026chmm`: replace `arXiv:XXXX.XXXXX` in `journal`
   with the CHMM ID, delete the `note` line, rebuild, submit. Record
   the SM arXiv ID.

3. **Upload CHMM v2.** In `CHMM-paper/references.bib`, entry
   `alswaidan2026smchmm`: add `journal={arXiv preprint arXiv:<SM-ID>}`
   and delete `note={Manuscript in preparation}`. In
   `CHMM-paper/sections/var_backtest.tex:69`: drop "in preparation"
   from "a companion paper in preparation." Rebuild and upload as v2.

## Alternative

Submit same day. If arXiv issues IDs in the same announcement cycle,
pre-populate both bib entries and skip the v2 step. The prose edit in
Step 3 still applies.
