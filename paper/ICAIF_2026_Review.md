# ICAIF 2026 Peer Review: Paper_v8.tex

**Venue:** ACM International Conference on AI in Finance (ICAIF '26), Bocconi University, Milan, November 14-17, 2026.
**Proceedings:** ACM Digital Library (archival).
**Deadline:** August 2, 2026.
**Submission portal:** Microsoft CMT.
**Review process:** Double-blind, no rebuttal.
**Submission under review:** `Paper_v8.tex` (59 pages, compiled 2026-04-21).
**Reviewer:** Reviewer #X, ICAIF '26 Program Committee (simulated).

---

## Overall Recommendation: **Reject as submitted. Encourage resubmission after re-architecting to meet the ICAIF '26 conference format.**

The underlying science is solid and well-aligned with the ICAIF topic scope (Trading & Asset Management; Risk Management). The submission in its current form, however, cannot be sent to the program committee for technical review because it violates every structural submission rule of the conference. All content-level strengths noted below presume a re-architected 8-page submission. The authors should not interpret this as a rejection of the work itself, only of the present manuscript's compatibility with the venue.

### Scores (1 = poor, 10 = excellent)

| Criterion                                      | Score | Notes                                                                                        |
| ---------------------------------------------- | :---: | -------------------------------------------------------------------------------------------- |
| Format compliance (length, template, blinding) |   1   | Multiple hard violations; see compliance checklist.                                          |
| Topic fit for ICAIF                            |   9   | Clean fit to "Trading & Asset Management" and secondary fit to "Risk Management".            |
| Technical novelty                              |   7   | CHMM at small K without jumps is a real contribution over the cited discrete-HMM baseline.   |
| Methodological soundness                       |   8   | Baum-Welch, ECM for Student-t, quantile-based init, log-space FB, profile MLE for copula nu. |
| Experimental rigor                             |   9   | Seven-metric panel, 1000 paths, IS/OoS split, six-ticker generalization, VaR/ES backtest.    |
| Writing clarity                                |   7   | Pipeline A / Pipeline B labeling in v8 is excellent; main-text prose is dense.               |
| Reproducibility signals                        |   8   | Named scripts, seed values, public data.                                                     |

---

## 1. Compliance checklist against ICAIF '26 submission rules

Every row below is a hard rule in the ICAIF '26 Call for Papers. The current submission fails on seven of ten.

| Rule                                                                                        | Required                                                      | Present in `Paper_v8`                                                    | Status |
| ------------------------------------------------------------------------------------------- | ------------------------------------------------------------- | ------------------------------------------------------------------------ | ------ |
| Page limit                                                                                  | 8 pages total in ACM sigconf two-column, figures + refs incl. | 59 pages in single-column 11pt article class                             | FAIL   |
| Template                                                                                    | Latest ACM article template, `sigconf` class with `anonymous` | `\documentclass[11pt,a4paper]{article}`                                  | FAIL   |
| Anonymization (double-blind)                                                                | No author names, affiliations, or email addresses             | Full author block with three names, Cornell affiliation, email addresses | FAIL   |
| Self-citation in third person                                                               | "Byrd et al." style, never "our previous work"                | Third-person citation style already used ("\citet{alswaidan2026hybrid}") | PASS   |
| Supplementary material / appendices                                                         | Not accepted; papers must be self-contained                   | `supplemental_v8.tex` is 1269 lines                                      | FAIL   |
| Concurrent submission                                                                       | Not permitted under any other venue                           | Cannot verify from source; authors must self-declare                     | N/A    |
| Max 6 papers per author                                                                     | Hard cap                                                      | Cannot verify from source; authors must self-declare                     | N/A    |
| PDF submission                                                                              | Required                                                      | `Paper_v8.pdf` builds cleanly                                            | PASS   |
| Topic fit                                                                                   | One of nine declared areas                                    | "Trading & Asset Management" + "Risk Management & Fraud Detection"       | PASS   |
| Ethics / dual submission statement                                                          | Required in submission form                                   | Not in manuscript; will be handled in CMT                                | N/A    |

**Seven mandatory failures**, any one of which is sufficient grounds for desk-rejection without review. These must be fixed before the paper can be evaluated on its technical contribution.

---

## 2. Paper summary (as I would write it in a PC meeting)

The authors propose a family of continuous hidden Markov models (CHMMs) with Gaussian, Student-t, and Laplace per-state emissions, trained end-to-end by Baum-Welch / ECM from raw annualized excess log returns. The central empirical claim is that at a single moderate state resolution ($K=18$), the continuous model reproduces the three canonical stylized facts (heavy tails, negligible linear ACF, persistent volatility clustering in $|G_t|$) without the Poisson-jump mechanism that the authors' cited discrete-HMM prior paper (Alswaidan et al. 2026) requires. The framework is evaluated with a seven-metric panel (KS, Anderson-Darling, kurtosis, ACF-MAE, Wasserstein-1, Hellinger, quantile coverage) against twelve competitors on SPY, then generalized to five additional tickers. A cross-asset extension applies SIM, Gaussian copula, and Student-t copula dependence on top of the per-asset CHMM marginals, with Student-t copula degrees of freedom selected by profile MLE ($\nu^* = 6$). A VaR / Expected-Shortfall backtest and per-ticker out-of-sample price simulation serve as utility consumers.

The v8 revision introduces explicit "Pipeline A" (single-index trained CHMM) and "Pipeline B" (cross-asset dependence on Pipeline A marginals) labeling throughout. This labeling is, in this reviewer's opinion, the single cleanest editorial improvement in the submission and should be preserved through any re-architecting.

---

## 3. Strengths (what I would defend if the paper reached PC discussion)

1. **A concrete, testable, falsifiable claim at the heart of the paper.** "Continuous HMM at $K=18$ matches the three stylized facts without jumps" is a sharp hypothesis and the seven-metric panel tests it honestly. Result lines in Table 2 (KS IS 94.7%, AD IS 86.5%, ACF-MAE 0.0513, kurtosis 5.02 vs observed 7.68) are the right kind of evidence.

2. **Emission-family ablation is well-designed.** Comparing CHMM-N, CHMM-t, CHMM-L at identical K and identical initialization cleanly isolates the emission-shape effect. The finding that CHMM-L lifts simulated kurtosis closest to observed ($6.76$ vs $7.68$) without adding a tunable shape parameter is an interesting practical result.

3. **Cross-asset extension is honestly adversarial.** Pipeline B reports a bad number (SIM's 31.5% IS KS on JPM) alongside the good numbers. This is the correct way to present a negative result in a simulation paper. The Student-t copula profile-MLE curve in the appendix is the right diagnostic.

4. **Reproducibility signals are strong.** Seeds are specified (20260420, 20260421), OoS window is precisely delimited, script filenames are named in the results section, and the accompanying code repository has a `results/README.md` that maps every artifact to its generating pipeline.

5. **The v8 Pipeline A / Pipeline B orientation framing is genuinely clarifying.** This kind of explicit pipeline labeling should be more widely adopted in computational finance papers that mix univariate and multi-asset analyses.

---

## 4. Weaknesses that matter even if the format issues were fixed

1. **The central novelty claim needs a tighter framing for an 8-page conference paper.** The paper currently pitches itself against twelve competitors across seven metrics across six tickers across three emission families across a K-sweep of seven values, plus a cross-asset extension, plus a VaR / ES backtest, plus a price-simulation section. This is at least three separate papers, and none of the three gets the 8 pages it would need to land cleanly. In an ICAIF-format resubmission the authors will have to pick *one* of:
   (a) "CHMM-N vs. discrete-HMM-with-jumps on stylized facts" (the cleanest single-thread story);
   (b) "Emission-family ablation in CHMMs for financial time series" (N vs. t vs. L is enough on its own);
   (c) "Rank-reordering copulas vs. SIM on per-asset CHMM marginals" (the Pipeline B story).
   Trying to keep all three in 8 pages will produce an incoherent paper.

2. **The Ryden et al. limitation is not cited explicitly as a motivating gap.** The paper references "the Ryd\'{e}n et al.\ limitation" in equation (ACF-MAE) but the reader is left to reconstruct the argument. For the abbreviated conference version the tension between mixture-of-Gaussians HMMs and volatility clustering should be the first paragraph of the introduction, not an appendix citation.

3. **The GRU baseline is underpowered and should probably be dropped.** A single-layer GRU with hidden width 32, 20 epochs, Adam $\eta = 10^{-3}$, Gaussian head is not a credible deep-generative benchmark as of 2026. At ICAIF, a reviewer from the Generative AI track will flag this immediately. Either upgrade to a TimeGAN / diffusion baseline or remove the row. Removing it is safer in 8 pages.

4. **Bin-T NJ is a mid-paper invention that deserves its own sentence of motivation.** It is currently introduced in Table 2 as if the reader already knows why discrete-HMM with Student-t-in-bin emissions is an interesting intermediate point. It is, but the paper has to say so explicitly.

5. **The VaR / ES backtest is a one-ticker utility check, not a utility evaluation.** Reporting VaR and ES on SPY only is a necessary but not sufficient utility signal for a conference that cares about financial downstream consumers. If kept, it should acknowledge this scope limit.

6. **NVDA OoS KS of 55.8% under CHMM-N is the elephant in the room.** The paper correctly attributes this to stationarity violation and shows walk-forward recovery on JPM, but it does not show walk-forward on NVDA where the gap is largest. A skeptical reviewer will ask why.

7. **Table T3's OoS results contradict its IS results** (Gaussian-copula OoS KS 51.5% on NVDA, 53.0% on JPM) without enough discussion. The paper acknowledges the point but a conference reviewer will want a one-sentence interpretation in the table text, not only in a paragraph.

---

## 5. Detailed comments by section

### Introduction
- First paragraph of `introduction_v8.tex` should state the concrete claim ("CHMM at $K=18$ reproduces all three stylized facts without jumps") rather than the broader "family of continuous hidden Markov models" framing. Conference-length papers should lead with the punchline.
- Cite Ryd\'{e}n, T\"{e}ras\"{v}irta, \AA sbrink (1998) on the mixture-HMM-vs-volatility-clustering issue in the first paragraph, not only in the methods.

### Methods
- Section 3 "CHMM Definition and EM Updates" is clean and can survive near-verbatim into an 8-page version at roughly 1.5 pages.
- Section 3.x "Cross-Asset Dependence (Pipeline B)" opening orientation paragraph (added in v8) is excellent and should be kept.
- Equation numbering is consistent. No issues.

### Results
- **Pipeline A and Pipeline B labels in subsection titles are a real improvement.** Keep them. They are orthogonal to the ICAIF format requirements and will help reviewers in any venue.
- Table 2 (twelve-model comparison) cannot survive in 8 pages. Cut Bootstrap (keep Block-BS), cut Gaussian i.i.d. (row is degenerate), cut Laplace i.i.d. (row is sub-CHMM-L by construction). This reduces to about seven rows and fits.
- Table T1a (state-resolution sweep) should be an inline sentence, not a table. "$K \in \{3, 6, ..., 21\}$; $K=18$ wins IS KS, OoS KS, Wasserstein-1; margins under 1pp" is one line.
- Table T2 should stay as a compact block with CHMM-N rows only per ticker; CHMM-t and CHMM-L rows can be absorbed into a single sentence listing the kurtosis ordering. 6 rows instead of 18 saves a full page.
- Figure 7 (cross-asset correlation heatmap) is the visual centerpiece of the Pipeline B argument and should be retained even at the cost of another figure.
- Price fans (current Figures 6 across SPY and NVDA with three emission families each) should become a single figure with one ticker and CHMM-N only, or be dropped entirely. They are charming but do not carry the argument.
- VaR / ES backtest (current Section) should be compressed to a single two-line paragraph naming the result, and the full table moved out.

### Discussion
- "Cross-Asset Robustness and OoS Degradation on NVDA and JPM (Pipeline A)" paragraph is one of the better pieces of writing in the paper. Keep it, shorten by 30%.
- "Why Copulas Beat SIM on Cross-Asset Fidelity (Pipeline B)" paragraph should survive at roughly half length.
- The limitations list is six items long. An 8-page conference paper should have three at most.

### Supplemental
- Not permitted in ICAIF '26. Must be eliminated entirely, or split into: (a) content that fits inline in 8 pages, (b) content that goes into a separate archival version hosted elsewhere (arXiv) and referenced as "Author et al. working paper" without de-anonymizing.
- The walk-forward table specifically is content that would add to the paper; the authors should consider keeping at least the JPM recovery number in the main text.

---

## 6. Required changes for a compliant ICAIF '26 resubmission

The following list is a hard requirements list. Without each item, the resubmission will be desk-rejected.

1. **Reformat to ACM `acmart` class, `sigconf` option, with `anonymous` option enabled.** Expect approximately 2x compression from single-column 11pt article to ACM two-column.
2. **Reduce total page count to 8 pages including all figures and references.**
3. **Remove author identification.** Delete the `\author{...}` block. Replace with ACM's `anonymous` macro which produces an empty author field. Remove email addresses, institutional affiliations, and thank-you acknowledgments that reveal identity. Do not add them back in any form.
4. **Delete `supplemental_v8.tex`.** Preserve content either inline (where essential) or in a companion arXiv preprint that does not breach anonymity.
5. **Choose one of three story arcs** (see weakness #1). Single-paper submissions at ICAIF succeed by being narrow and definitive, not broad and surveyish.
6. **Self-citation of the prior discrete-HMM paper is already in third person**, which is compliant. Verify that the bibliography entry itself does not include DOI / arXiv ID strings that de-anonymize the authors.
7. **Drop the GRU baseline** or replace with a credible 2026-era deep-generative benchmark; the current GRU is both too weak to be informative and too heavyweight to explain in 0.3 pages.
8. **Explicit ethics / data provenance statement.** SPY price data is public via Polygon or similar; include a one-line statement. No privacy concerns.
9. **All figures must be reproducible from the source code named in the paper.** This is already the case per the accompanying repo's `results/README.md`.

### Optional but recommended

10. **Keep the Pipeline A / Pipeline B labeling from v8.** It is a distinguishing feature that separates this submission from the crowded space of HMM-for-finance papers.
11. **Promote the JPM walk-forward recovery (49.0% to 64.3% OoS KS) to the main text as a limitation-with-remedy.** Reviewers reward papers that show the limit of their method and a concrete way past it.
12. **Add a one-sentence connection to regulator use cases** (synthetic-data generation for stress testing) in the introduction. This aligns with "Risk Management & Fraud Detection" and broadens the perceived impact.

---

## 7. Minor comments

- The title is 22 words. ICAIF titles are typically 8 to 12 words. Consider "A Continuous HMM for Synthetic Equity Returns: Cross-Asset Copula Extensions".
- "Excess growth rate $G_t$" is non-standard nomenclature in finance papers; "excess log return" is more recognizable to the ICAIF audience.
- Figure color scales are consistent (RdBu for correlation, viridis for transition matrices). Good.
- Caption in Figure cross-asset correlation lists panels (a-d) by position; this is correct. Do not switch to panel letters inside the figure itself in an 8-page version (no space).
- The v8 `Paper_v8.tex` top-of-file comment block listing v7 to v8 changes is useful internally but must be removed from the camera-ready.
- Table T2 uses the label `tab:cross_asset` (per-ticker marginal) and Table T3 uses `tab:cross_asset_sim_copula` (cross-asset). The label mismatch between `cross_asset` (T2) and `cross_asset_sim_copula` (T3) reads backwards (the T3 label is the one that should say "cross_asset" since that is the multi-asset table). Rename for the camera-ready.

---

## 8. Summary for the program chairs

| Field                              | Value                                                                              |
| ---------------------------------- | ---------------------------------------------------------------------------------- |
| Desk-reject recommended            | Yes (format non-compliance is fatal at submission stage)                           |
| Would I review the resubmission?   | Yes, with interest                                                                 |
| Confidence in this review          | 4 / 5 (familiar with the stylized-facts / HMM literature and with ACM sigconf norms) |
| Conflict of interest               | None declared                                                                      |

**Path forward for the authors.** This paper has a real technical contribution. The re-architected ICAIF submission should be an 8-page paper whose thesis is: "A continuous HMM with a single moderate state count matches all three canonical stylized facts of equity returns without the jump mechanism required by the discrete baseline, and composes cleanly with rank-reordering copulas for multi-asset extension." Everything else in the current manuscript, the seven-metric panel, the VaR/ES backtest, the price fans, the emission-family ablation, the K-sweep, is evidence in support of that thesis, not co-equal claims. Write the paper that defends one thesis well, and park the rest in an arXiv companion.
