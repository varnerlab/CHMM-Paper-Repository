# Refining Paper: Title-vs-Content Audit and Fixes

Scope: v10 draft (`paper/sections/*_v10.tex`, `paper/Paper_v10.tex`).

Goal: eliminate every contradiction between section / subsection / paragraph titles and the content they introduce.

---

## Findings

### Hard contradictions (numeric / factual)

**#1 — "Seven-Model Comparison (Pipeline A)"** — `results_v10.tex:75`
- Body at line 80 says *"the twelve generators"*; table caption at line 180 says *"Twelve-model comparison on SPY"*; table itself has 12 model rows.
- Fix: rename to `Twelve-Generator Comparison (Pipeline A)`.

**#2 — "Extended Evaluation: MMD, Signature-MMD, Discriminator AUC, Leverage, Aggregational Gaussianity, and Simulation p-Values"** — `results_v10.tex:266`
- Title enumerates 6 axes. Line 271 reinforces *"six evaluation axes"*. But the subsection has 7 paragraphs of content — the extra one is `\paragraph{Unconditional 1% and 5% VaR: Kupiec and Christoffersen tests.}` at line 319.
- Fix: add "Kupiec/Christoffersen VaR" to the title; change "six" → "seven" on line 271.

**#3 — "Wasserstein, Hellinger, and Coverage Are Monotonic."** — `results_v10.tex:245`
- Body at 246 admits Coverage is flat (100% at every K). Full sweep (`supplemental_v10.tex:124–130`) shows $W_1$ and H both non-monotone across K ∈ {3,6,9,12,15,18,21}; only the K=3 → K=18 endpoints improve monotonically.
- Fix: rename so the claim matches what is actually shown — improvement at the endpoints, flat coverage.

**#4 — "Kurtosis Is Non-Monotonic and Peaks in the Plateau Band."** — `results_v10.tex:240`
- Body says peak is at K=6 (5.13); supplemental table confirms (K=6 → 5.26). The plateau band {15,18,21} sits below the peak (4.89, 4.98, 3.83).
- Fix: rename so the stated peak location matches the body — peak at K=6, not in the plateau.

### Soft claim-vs-evidence mismatches

**#5 — "Kurtosis: CHMM-L matches observed, CHMM-t overshoots, CHMM-N understates."** — body claim on line 664
- Title is directionally OK. But the body's *"closest to observed on four of six assets"* is off by one: CHMM-L wins 3 of 6 (SPY, JNJ, AAPL); CHMM-N wins NVDA and JPM; CHMM-t wins QQQ.
- Fix: change "four" → "three" in body (line 664).

**#6 — "Distributional Fidelity Saturates in the K ∈ {15, 18, 21} Band."** — `results_v10.tex:229`
- Supplemental table shows IS KS still climbing through that band (93.9 → 95.6 → 96.1; 2.2pp spread) and K=15 dropping below K=12 (94.6). "Saturates" overclaims.
- Fix: soften "Saturates" → "Plateaus".

---

## Implementation progress

- [x] **Task 1** — Create `refining-paper.md` plan file.
- [x] **Task 2 (Fix #1)** — Rename *Seven-Model Comparison* → *Twelve-Generator Comparison*.
- [x] **Task 3 (Fix #2)** — Extend title and fix "six" → "seven" for Extended Evaluation.
- [x] **Task 4 (Fix #3)** — Rename Wasserstein/Hellinger/Coverage monotonicity paragraph.
- [ ] **Task 5 (Fix #4)** — Rename kurtosis peak paragraph.
- [ ] **Task 6 (Fix #5)** — Body: "four of six" → "three of six" for CHMM-L.
- [ ] **Task 7 (Fix #6)** — Soften "Saturates" → "Plateaus".

---

## Process

After each fix:
1. Apply edit.
2. Update this file's checkbox + add a one-line outcome note below.
3. Commit with a focused message and push to `origin/main`.

## Outcomes log

- Task 1: plan file created.
- Task 2: `results_v10.tex:75` — subsection title changed to `Twelve-Generator Comparison (Pipeline A)`. Body ("twelve generators", line 80) and table caption ("Twelve-model comparison", line 180) now agree with the header. Label `sec:model_comparison` preserved, so all `\ref{}` and `\cref{}` call sites are unaffected.
- Task 3: `results_v10.tex:266` — subsection title extended with `Unconditional VaR (Kupiec/Christoffersen)` so the header lists all seven paragraphs in the body (MMD, Signature-MMD, Discriminator AUC, Leverage, Aggregational Gaussianity, Unconditional VaR, Simulation p-Values). Line 271 updated from "six evaluation axes" → "seven evaluation axes" with the Kupiec/Christoffersen axis named explicitly. Label `sec:extended_evaluation` preserved.
- Task 4: `results_v10.tex:245` — paragraph title replaced with `Wasserstein and Hellinger Improve Net Across the Sweep; Coverage is Saturated at 100\%`. The body is rewritten to (a) acknowledge minor non-monotone oscillations of $W_1$ and H at intermediate $K$ (per `supplemental_v10.tex` Table `tab:sensitivity`), (b) keep the net endpoint-to-endpoint improvement claim, and (c) clarify that 100% coverage is a floor check, not a monotonic signal.
