# Publishing plan: CHMM-paper and SM-CHMM-AR-Paper

Two companion papers are ready to post to arXiv. Each cites the other (a
shared algorithmic component goes each way), so the submission order
matters. Both manuscripts currently compile cleanly; the cross-citations
use placeholder arXiv IDs that need to be filled in at submission.

## Submission sequence

1. **Post `SM-CHMM-AR-Paper` first.** Submit as-is and record the arXiv ID
   you receive.

2. **Post `CHMM-paper` second.** Before uploading, open
   `CHMM-paper/references.bib`, find the entry `alswaidan2026smchmm`,
   replace `arXiv:XXXX.XXXXX` with the ID from Step 1, delete the `note`
   line, and rebuild. Then submit and record the new arXiv ID.

3. **Upload a v2 of `SM-CHMM-AR-Paper`.** Open
   `SM-CHMM-AR-Paper/references.bib`, find `alswaidan2026chmm`, replace
   the placeholder with the CHMM-paper ID from Step 2, delete the `note`,
   rebuild, and upload as v2 on arXiv. arXiv accepts author-initiated v2
   replacements without re-review.

End state: each paper cites the other by live arXiv ID.

## Alternative

Submit both papers on the same day. If arXiv assigns IDs in the same
announcement cycle, the IDs can be pre-populated (or coordinated with
arXiv), eliminating the v2 step. Use this if the timing is convenient;
otherwise the three-step sequence above is the clean default.
