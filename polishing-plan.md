# CHMM Paper Polishing Plan

Created 2026-04-24. Issues identified during a review for vague statements, unsupported/false claims, citation accuracy, and flow from abstract to conclusion. Items are grouped by severity and ordered for implementation: each tier can be landed as a single pass.

---

## Tier 1 — Blockers (must fix before sharing externally)

These are factual inconsistencies, false claims in the abstract, or a missing arXiv ID. They are the highest-risk items because a reviewer reading the abstract and the body side by side will catch them immediately.

### T1.1 — Remove unsupported "C-vine copula at fifty assets" claim from abstract
**Where:** `paper.tex:116` (abstract)
**Problem:** Abstract asserts "a truncated C-vine copula at fifty assets," but the only C-vine in the paper is a single visual panel in `sections/cross_asset_appendix.tex:79,85` over the same six tickers. `sections/conclusion.tex:27` and `sections/discussion.tex:77` explicitly list 424-asset vine copulas as *future* work.
**Fix:** Change to "Gaussian and Student-t copulas on six equities, with a truncated C-vine variant as a visual reference on the same universe."
**Effort:** 1 line edit. **Risk:** low.

### T1.2 — Fix false AUC claim in abstract
**Where:** `paper.tex:112`
**Problem:** Abstract says CHMM-t has AUC "closest to 0.5 of any row in the panel, ahead of ... diffusion ... baselines." But `sections/results.tex:335` and Table 2 show Window-diffusion AUC IS = 0.565 (closer to 0.5 than CHMM-t's 0.607).
**Fix:** Restate as "the smallest MMD of any row and the discriminator AUC closest to 0.5 among parametric and Markov-switching rows (second only to the window-diffusion baseline on AUC; see Section 5.6)."
**Effort:** 1-2 line edit. **Risk:** low.

### T1.3 — Soften the Kupiec "jointly best-in-panel" claim in abstract
**Where:** `paper.tex:113`
**Problem:** Claim of joint top-ranking at both 1% and 5% is only true at 1%. At 5%, MS-GARCH alone leads (LR_uc = 0.26 vs SM-CHMM-N 0.82 — see `sections/var_backtest.tex:104-105`, `sections/model.tex:213`). Discussion already concedes this (`sections/discussion.tex:66`).
**Fix:** "a semi-Markov CHMM ablation and a two-regime MS-GARCH baseline tie for the best-in-panel Kupiec statistic at 1% ($\text{LR}_{\text{uc}} = 0.01$), with MS-GARCH alone leading at 5%."
**Effort:** 1 sentence rewrite. **Risk:** low.

### T1.4 — Fix "CHMM-t is the single CHMM family that passes both tests" overclaim
**Where:** `sections/results.tex:161` (and any echo in discussion)
**Problem:** Table `tab:conditional_var` (`sections/var_backtest.tex:177`) shows CHMM-L conditional passes all four tests too (LR_uc = 3.26 and 3.83, LR_ind = 0.01 and 2.25, all < 3.84). The distinguishing feature is the *margin* of the pass, not whether it is a pass.
**Fix:** "CHMM-t is the only variant that clears both tests at both confidence levels with margin; CHMM-L also passes but marginally at the 5% Kupiec (LR_uc = 3.83, critical value 3.84)."
**Effort:** 2-3 sentence rewrite in this paragraph. **Risk:** low.

### T1.5 — Correct the Rydén, Teräsvirta, Åsbrink (1998) data attribution
**Where:** `sections/related_work.tex:9`
**Problem:** Text says "daily Swedish equity returns." The authors are Swedish but the 1998 JAE paper analyzes the S&P 500 index. `sections/introduction.tex:7` already avoids this country label.
**Fix:** Change "daily Swedish equity returns" to "daily equity-index returns" (mirroring the introduction). Verify against the original paper before committing.
**Effort:** 1 line edit + 1 verification step. **Risk:** low once verified.

### T1.6 — Resolve internal CHMM-N at K=18 numerical inconsistency
**Where:** `sections/results.tex:43`, `sections/results.tex:201` (Table 1), `sections/results.tex:223`, `sections/results.tex:246`, `sections/results.tex:382` (cross-asset SPY)
**Problem:** CHMM-N at K=18 on SPY reports different IS/OoS KS pairs in different subsections:
  - 43: IS 94.7% / OoS 82.4%
  - 201 (Table 1): IS 93.8% / OoS 84.2%
  - 223: IS 95.2% / OoS 94.0%  ← the 94.0% OoS is the most suspect; it appears nowhere else
  - 246 / Table: 84.2% OoS (matches Table 1)
  - 382 (cross-asset): IS 95.5% / OoS 81.4%
**Fix plan:**
  1. Identify the authoritative table (likely Table 1, `tab:model_comparison`) and pin the canonical numbers.
  2. Re-check the K-sensitivity appendix run — 94.0% OoS at K=18 is unlikely. If it is a run artifact from a different seed or windowing, either regenerate or explicitly footnote "values from the K-sweep pipeline use the sub-seed 20260422 and may differ at the second decimal from Table 1."
  3. Rewrite `results.tex:43` and `results.tex:223` to reference the authoritative table and use its numbers, or explain the mismatch in a one-line footnote.
**Effort:** medium — may require re-running the K-sweep or re-reading the sensitivity artefact. **Risk:** medium (could expose a real bug in the K-sweep script).

### T1.7 — Replace placeholder arXiv ID in `alswaidan2026smchmm`
**Where:** `references.bib:18-24` (and citation at `sections/var_backtest.tex:69`)
**Problem:** `journal={arXiv preprint arXiv:XXXX.XXXXX}` with a note saying "arXiv ID to be filled in after SM-CHMM-AR-Paper is posted." Cannot submit with this placeholder.
**Fix:** Either (a) post the companion paper and paste the arXiv ID, or (b) change the in-text citation to "companion paper in preparation" and keep the bib entry with `note={manuscript in preparation}`, dropping the `arXiv:XXXX.XXXXX` line.
**Effort:** 1-line bib edit + 1-line prose edit. **Risk:** low if going with option (b).

### T1.8 — Fix "$1.75\%$" vs "$1.7\%$" breach-rate mismatch
**Where:** `paper.tex:115` (abstract) vs `sections/results.tex:302`, `sections/var_backtest.tex:52`, `sections/discussion.tex:24`, `sections/conclusion.tex:10`
**Problem:** Abstract says 1.75%, every other occurrence says 1.7%. Pick the exact number from the underlying artefact and replace everywhere.
**Fix:** Check the raw VaR back-test output; edit the abstract to match the body (almost certainly 1.7%).
**Effort:** 1 line edit after a grep. **Risk:** low.

### T1.9 — Fix the CHMM-t kurtosis-overshoot arithmetic mismatch
**Where:** `sections/discussion.tex:38` says "$\sim 90\%$" overshoot; `sections/var_backtest.tex:43` says "$\sim 126\%$ IS."
**Problem:** (14.57 − 7.68)/7.68 = 0.897, so 90% is correct. "126%" appears wrong.
**Fix:** Replace "$\sim 126\%$" with "$\sim 90\%$" in `var_backtest.tex:43`, or whatever the author intended (e.g., ratio 14.57/7.68 ≈ 1.90, still not 126).
**Effort:** 1 line edit. **Risk:** low.

---

## Tier 2 — Significant but not blocking

Claims that are technically defensible as written but misleading or over-stated. Fix these in the same polishing pass as Tier 1.

### T2.1 — Verify `alswaidan2026hybrid` arXiv ID is live
**Where:** `references.bib:11-16`
**Problem:** `arXiv:2603.10202` is the prior paper by A.A. & J.V. Verify the paper is posted on arXiv as of today (2026-04-24). If not, same resolution path as T1.7.
**Effort:** 1 arXiv lookup. **Risk:** low.

### T2.2 — Soften the "select $K=18$ jointly by the four information criteria" framing
**Where:** `sections/introduction.tex:15`
**Problem:** The ICs flatten over $\{15, 18, 21\}$ (see `sections/estimation.tex:73-75`, `sections/results.tex:41-42`); $K=18$ is picked on *ranked-average IC plus distributional score*, not ICs alone.
**Fix:** "$K = 18$ sits inside the IC-minimizing band $\{15, 18, 21\}$ (AIC, BIC, HQC, CAIC per \citet{nguyen2018hidden}) and wins or ties every distributional pass-rate metric within that band."
**Effort:** 1-sentence rewrite. **Risk:** low.

### T2.3 — Weaken over-credit for Hamilton 1989
**Where:** `sections/introduction.tex:4`
**Problem:** "introduced to economics by \citet{hamilton1989new}" is standard shorthand but Goldfeld & Quandt (1973, *J. Econometrics*) introduced Markov switching regressions 16 years earlier.
**Fix:** "popularized in macroeconometrics by \citet{hamilton1989new}."
**Effort:** 1-word change. **Risk:** low.

### T2.4 — Weaken three "in the spirit of TimeGAN" attributions
**Where:** `sections/introduction.tex:18`, `sections/model.tex:181`, `sections/related_work.tex:29-30`
**Problem:** The paper's GRU is a single-layer GRU with Gaussian head and NLL loss — this is a standard sequence-density baseline. TimeGAN is architecturally different (embedder + supervised + adversarial triple loss).
**Fix:** Replace "in the spirit of \citet{yoon2019timegan}" with "a standard GRU-based autoregressive density baseline," keeping the TimeGAN citation only when genuinely referring to the GAN literature.
**Effort:** 3 edits. **Risk:** low.

### T2.5 — Remove editorial "reviewers expect to see" in methods
**Where:** `sections/model.tex:198`
**Problem:** Meta-commentary does not belong in methods prose.
**Fix:** Delete that sentence; keep the adjacent technical content.
**Effort:** 1 line deletion. **Risk:** none.

### T2.6 — Define TSTR / QLIKE at first use or remove the forward reference
**Where:** `sections/var_backtest.tex:114` says TSTR HAR was "already introduced in the Extended Evaluation panel," but the extended-evaluation section does not define TSTR or QLIKE.
**Fix:** Add one sentence at the first mention in `sections/results.tex` defining TSTR ("train-on-synthetic, test-on-real") and QLIKE (the quasi-likelihood forecast loss). Alternatively, drop the "already introduced" phrase and define it on its first real use in `var_backtest.tex`.
**Effort:** 1 paragraph edit. **Risk:** low.

### T2.7 — Trim redundancy between discussion and conclusion
**Where:** `sections/conclusion.tex:10` ≈ `sections/discussion.tex:24` (discrete-HMM head-to-head paragraph)
**Problem:** Conclusion restates the discussion near-verbatim.
**Fix:** Shorten the conclusion paragraph to the headline contrast (kurtosis + VaR Kupiec failure) and drop the parameter-count recap.
**Effort:** 3-4 line edit. **Risk:** low.

### T2.8 — Document the "expected triggers" arithmetic for the WJ jump process once, cleanly
**Where:** `sections/results.tex:99`, `sections/discussion.tex:25`, `sections/var_backtest.tex:53`
**Problem:** "$\sim 0.005\%$ of time steps" and "fewer than one time step per IS or OoS window" are both defensible but stated redundantly and slightly loosely.
**Fix:** In one place, state: "expected number of jump triggers = $\epsilon T \approx 0.13$ per IS window ($T = 2{,}516$) and $\approx 0.03$ per OoS window ($T = 572$)"; in the other two places, cross-reference this.
**Effort:** 3 small edits. **Risk:** low.

### T2.9 — Make the "central finding" framing consistent
**Where:** `sections/results.tex:133` vs `sections/discussion.tex` / `sections/conclusion.tex`
**Problem:** "This is the central finding of this paper" is declared at 133 for the Rydén-resolution point, but the discussion and conclusion frame the central finding as a multi-part claim including VaR calibration.
**Fix:** Either state "one of two headline findings" at 133, or reframe the discussion/conclusion to put Rydén-resolution as the central finding and the rest as corollaries.
**Effort:** 1-2 line edit. **Risk:** low.

---

## Tier 3 — Polishing / minor

Low-stakes wording, precision, and style fixes. Batch in a final pass.

### T3.1 — Drop the "digital twin" framing
**Where:** `sections/introduction.tex:1`
**Fix:** Replace with "synthetic-data generator" (consistent with the rest of the paper). The phrase is used only once and has no domain-specific definition here.

### T3.2 — Align stylized-fact lists between abstract and body
**Where:** `paper.tex:109` (five facts) vs `sections/introduction.tex:1` and `sections/related_work.tex:2` (three facts).
**Fix:** In the introduction's first paragraph, expand to mention that Section 5.6 additionally evaluates the leverage effect and aggregational Gaussianity (consistent with abstract). No abstract change needed.

### T3.3 — Remove marketing phrasing "first-class design choice"
**Where:** `sections/introduction.tex:13`
**Fix:** "the same EM scaffold accommodates Gaussian, Student-t, and Laplace emissions with only the M-step differing."

### T3.4 — Replace "companion" soft reference for `alswaidan2026smchmm` consistently
**Where:** `sections/var_backtest.tex:69` (and anywhere else that cites it)
**Fix:** "consistent with preliminary results we report for the CBOE VIX in a companion paper (in preparation)." (coordinates with T1.7.)

### T3.5 — Quantify "within 10% of the CHMM-N values"
**Where:** `sections/results.tex:147`
**Fix:** State the absolute differences (e.g., "within 0.006 on ACF-MAE and 0.009 on $W_1$").

### T3.6 — Tone down editorial macro framing
**Where:** `sections/results.tex:357`
**Fix:** Replace the "AI trade" and "financials bell-wether" clauses with factual descriptors (realized vol change; realized drift shift IS vs OoS).

### T3.7 — Clarify the "GARCH MMD = 0.0" footnote
**Where:** `sections/results.tex:270`, `sections/results.tex:324` (Table 2 footnote)
**Fix:** Either state the numeric floor ("below display precision at $< 10^{-6}$") or, if genuinely zero due to the bandwidth issue, explain the mechanism in one sentence.

### T3.8 — Verify and correct conclusion ACF-MAE range
**Where:** `sections/conclusion.tex:8` claims "ACF-MAE of 0.046--0.051."
**Problem:** Table 1 and the sensitivity table put CHMM variants at 0.0507-0.0565. The 0.046 lower bound is not in Table 1.
**Fix:** Either source the 0.046 from the K-sweep appendix (and cite it), or update to "0.051-0.056" matching Table 1.

### T3.9 — Add one-sentence flow bridges
**Where:** `sections/results.tex:341` → `sec:cross_asset_univariate`; and introduction end → Scope paragraph to preview the VaR axes.
**Fix:** One sentence each.

### T3.10 — Inline "weaken 'closest deep-learning analog'"
**Where:** `sections/related_work.tex:30`
**Fix:** Drop "closest" (no comparison made).

---

## Implementation plan

**Pass 1 (Tier 1, single commit on a branch).** Do all T1 items in one editing session. For T1.6 and T1.9 this requires cross-checking the raw artefacts in `results/` before touching prose. Suggested order:

1. Grep all breach-rate and kurtosis-overshoot mentions (T1.8, T1.9).
2. Run one K-sweep output check or table re-read for T1.6 — decide the canonical numbers.
3. Edit abstract (T1.1, T1.2, T1.3, T1.8).
4. Edit results/discussion/conclusion for T1.4, T1.6, T1.9.
5. Edit related-work for T1.5 after verifying Rydén et al.
6. Edit bib for T1.7 (drop placeholder or paste real ID).
7. Compile paper locally with `make` or latexmk; check `paper.pdf` for the changed passages.

**Pass 2 (Tier 2).** Batch into a second commit. Lower-risk rewrites plus T2.1 verification for the prior paper's arXiv ID.

**Pass 3 (Tier 3).** A final polish-only commit, no substantive claim changes.

Estimated total time: Tier 1 half a day (T1.6 is the wildcard if the K-sweep needs a re-run); Tier 2 an hour; Tier 3 half an hour. Do not merge to `main` without rebuilding `paper.pdf` and diffing the abstract / Table 1 values by eye.
