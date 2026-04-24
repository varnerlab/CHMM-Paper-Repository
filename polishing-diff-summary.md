# Polishing Diff Summary (`polishing-tier1` vs `main`)

Three commits, 27 textual fixes, 10 files touched, +35 / -37 lines.

| Commit | Tier | Theme |
|---|---|---|
| `02b3b91` | 1 | False claims and numerical inconsistencies (blockers) |
| `e85ecf4` | 2 | Overclaims, attributions, framing |
| `38aaa7b` | 3 | Wording, precision, flow bridges |

Files changed:

| File | +/- | Tier(s) |
|---|---|---|
| `paper.tex` (abstract) | +4 / -4 | 1 |
| `references.bib` | +1 / -2 | 1 |
| `sections/introduction.tex` | +6 / -5 | 2, 3 |
| `sections/related_work.tex` | +2 / -2 | 1, 2 |
| `sections/model.tex` | +2 / -3 | 2 |
| `sections/results.tex` | +12 / -11 | 1, 2, 3 |
| `sections/var_backtest.tex` | +5 / -5 | 1, 2, 3 |
| `sections/discussion.tex` | +1 / -1 | 2 |
| `sections/conclusion.tex` | +2 / -4 | 2, 3 |

---

## Tier 1 — Blockers (`02b3b91`)

Factual inconsistencies, false claims in the abstract, and a bibliography placeholder.

### Abstract (`paper.tex`)
- **"Truncated C-vine copula at fifty assets"** → "truncated C-vine variant reported as a visual reference on the same universe." The 50-asset C-vine does not exist in the paper; the only C-vine is a visual-only appendix panel on the same six equities.
- **"AUC closest to 0.5 of any row in the panel, ahead of ... diffusion"** → "AUC closest to 0.5 among parametric and Markov-switching rows, second only to a window-diffusion baseline on AUC." The body (`results.tex:335`) acknowledges diffusion's AUC IS 0.565 is closer to 0.5 than CHMM-t's 0.607.
- **"jointly set the best-in-panel Kupiec ... at the 1% and 5% levels"** → "tie for the best-in-panel Kupiec at 1% (LR_uc = 0.01), with MS-GARCH alone leading at 5%." Matches Section 6.1 numbers.
- **"$1.75\%$ breach rate"** → $1.7\%$ (aligned with every other occurrence in the body).

### Body
- **`sections/var_backtest.tex:161`**: "CHMM-t is the single CHMM family that passes both tests at both confidence levels" → "the CHMM family that passes both tests at both confidence levels with margin; CHMM-L clears all four thresholds but marginally at the 5% Kupiec." CHMM-L also passes per `tab:conditional_var`; the distinction is the margin.
- **`sections/var_backtest.tex:43`**: "$\sim 126\%$ IS" kurtosis overshoot → "$\sim 90\%$ IS." Arithmetic: (14.57 − 7.68)/7.68 ≈ 0.897.
- **`sections/related_work.tex:9`**: "daily Swedish equity returns" → "daily equity-index return series." Rydén, Teräsvirta & Åsbrink (1998) analyzed equity-index returns, not Swedish equities.
- **`sections/results.tex:223-240`** (state-resolution sensitivity subsection): phantom K-sweep numbers replaced with values from `tab:sensitivity`. Specifically:
  - K=3 → K=18 → K=21 IS KS: (88.7, 95.2, 96.5) → (88.8, 95.6, 96.1)
  - K=3 → K=18 → K=21 OoS KS: (92.8, 94.0, 94.9) → (77.1, 81.7, 86.6) — the impossibly high 94.0% OoS KS was replaced.
  - IS AD gain: 88.3% → 88.4% at K=18; OoS AD at K=18: 88.7% → 73.2%.
  - ACF-MAE range: (0.0453, 0.0505, 0.0503) → (0.0466, 0.0509, 0.0532).
  - Kurtosis range: (3.70 at K=9, 5.13 at K=6, 5.03 at K=18) → (3.80 at K=3, 5.26 at K=6, 4.98 at K=18).
  - $W_1$ endpoint at K=3: 0.119 → 0.130; at K=18: 0.101 → 0.110.
  - Hellinger endpoint: 0.079 → 0.0836 at K=3; 0.077 → 0.0805 at K=18.

### Bibliography
- **`references.bib`** (`alswaidan2026smchmm`): `journal={arXiv preprint arXiv:XXXX.XXXXX}` and the trailing `note={arXiv ID to be filled in...}` lines removed; replaced with `note={Manuscript in preparation}`.

---

## Tier 2 — Significant (`e85ecf4`)

Overclaims, weak attributions, and framing issues.

### Introduction (`sections/introduction.tex`)
- **K-selection framing**: "select $K=18$ jointly by the four information criteria ... and by our multi-metric distributional score" → "$K=18$ sits inside the IC-minimizing band $\{15, 18, 21\}$ ... and, within that band, wins or ties every IS and OoS distributional pass-rate metric."
- **Hamilton 1989 over-credit**: "introduced to economics by Hamilton (1989)" → "popularized in macroeconometrics by Hamilton (1989)." Goldfeld & Quandt (1973) introduced Markov switching to econometrics 16 years earlier.
- **TimeGAN framing for the GRU baseline**: "in the spirit of Yoon et al. (TimeGAN)" → "autoregressive density baseline." The architecture is a standard single-layer GRU with Gaussian head and NLL loss, not GAN-based.

### Model (`sections/model.tex`)
- **Same TimeGAN correction**: "following the deep-baseline tradition of TimeGAN" → "following the GRU baseline of [prior paper]; recurrent-generator architectures for financial time series are also the subject of the TimeGAN family" (demoted to a loose reference).
- **Editorial aside removed**: "it functions as a deep-generative negative control that reviewers at generator-oriented venues expect to see. The row therefore strengthens rather than threatens the CHMM narrative..." → "it functions as a deep-generative negative control for Section 5.6."

### Related work (`sections/related_work.tex`)
- **"closest deep-learning analog of the prior paper's neural baseline"** → the "closest" language dropped; no architectural comparison is actually made.

### Results / VaR (`sections/results.tex`, `sections/var_backtest.tex`, `sections/discussion.tex`)
- **TSTR / QLIKE defined inline** at first use in `sections/var_backtest.tex:114`; "already introduced in the Extended Evaluation panel" (false) removed.
- **Jump-trigger arithmetic**: `sections/results.tex:99` now gives concrete expected counts ($\epsilon T \approx 0.13$ per IS window, $\approx 0.03$ per OoS window). `sections/discussion.tex:25` cross-references Section 5.2 rather than restating the percentage.
- **"Central finding" framing** (`sections/results.tex:133`): "This is the central finding of this paper" → "This is the first of two headline findings," referencing the regime-conditional VaR result as the second.

### Conclusion (`sections/conclusion.tex`)
- **Discrete-HMM head-to-head paragraph**: 3 sentences → 1 sentence. The discussion already spells out the kurtosis / aggregational / VaR-Kupiec comparison, so the conclusion now keeps only the headline contrast.

### Verified (no code change)
- **`alswaidan2026hybrid` arXiv ID 2603.10202** confirmed live (posted 2026-03-10, revised 2026-04-02).

---

## Tier 3 — Polish (`38aaa7b`)

Wording precision and flow improvements.

### Introduction (`sections/introduction.tex`)
- **"digital twin"** removed; replaced with "useful downstream."
- **Stylized-fact list aligned with abstract**: first paragraph now notes that Section 5.6 additionally evaluates the leverage effect and aggregational Gaussianity, the remaining two Cont facts.
- **"Emission family is a first-class design choice"** → "The same EM scaffold accommodates Gaussian, Student-t, and Laplace emissions with only the M-step differing."
- **Flow bridge** added at the end of the intro previewing the unconditional and regime-conditional VaR axes before the Scope paragraph.

### Results / VaR
- **`sections/results.tex:147`**: "within 10% of the CHMM-N values" → "within 0.006 (ACF-MAE) and 0.010 ($W_1$) of the CHMM-N values."
- **`sections/results.tex:357`**: editorial "NVDA the dominant high-volatility driver of the AI trade, and JPM the financials bell-wether" → factual "higher realized volatility on NVDA, a different realized drift on JPM."
- **`sections/results.tex:270`**: GARCH MMD $= 0.0$ footnote clarified as "falls below the table's three-significant-digit precision ($<10^{-4}$)."
- **`sections/var_backtest.tex:69`**: "matches the finding of [alswaidan2026smchmm]" → "consistent with preliminary results we report ... in a companion paper in preparation," matching the `Manuscript in preparation` bib note.
- **Flow bridge** added between the extended-evaluation summary and the Cross-Asset Univariate subsection (`sections/results.tex:342`).

### Conclusion (`sections/conclusion.tex`)
- **ACF-MAE range**: "0.046–0.051" → "0.047–0.053 across the K sweep"; GARCH reference 0.047 → 0.048 (both corrected against Tables `sensitivity` and `sensitivity_multi`).

---

## Build status

`paper.pdf` regenerated at every commit. Final PDF: 72 pages, no new LaTeX warnings, no undefined citations or references.

## Next steps

- Review the branch: `git diff main..polishing-tier1`.
- If satisfied, merge (fast-forward or squash) onto `main`, or open a PR.
- Outstanding concerns not addressed by this branch are documented in `polishing-plan.md` and are all out of scope for Tier 1–3 (e.g., re-running the K-sweep to produce authoritative sensitivity numbers, posting the SM-CHMM companion paper to arXiv, or migrating to skew-t emissions).
