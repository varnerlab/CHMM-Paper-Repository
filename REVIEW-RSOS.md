# Reviewer Report, Royal Society Open Science

**Manuscript:** A Regime-Switching Continuous Hidden Markov Model as a Reference Synthetic-Data Generator for Equity Returns: Extended Evaluation, Semi-Markov Ablation, and Regime-Conditional Value-at-Risk

**Authors:** Alswaidan, Jin, Varner

**Reviewer recommendation:** Accept after minor revisions.

---

## 1. Summary of the manuscript

The paper develops a family of continuous hidden Markov models (CHMM-N, CHMM-t, CHMM-L) trained by a single log-space Baum-Welch / ECM scaffold, and benchmarks them as synthetic data generators for daily SPY excess returns against eleven alternatives spanning non-parametric, parametric, regime-switching, and deep generative families. The contribution is positioned as integrative rather than as a new estimator: a unified scaffold across three emission families, a twelve-generator panel evaluated on a seven-metric battery (KS, AD, kurtosis, ACF-MAE, Wasserstein-1, Hellinger, quantile coverage), an extended Track-A panel adding MMD, signature-MMD, discriminator AUC, leverage, aggregational kurtosis, and joint p-value coverage, a semi-Markov ablation, a smoother-versus-filter regime-conditional VaR comparison, and a cross-asset extension via SIM and Gaussian / Student-t copulas. A theoretical section assembles seven propositions (closed-form spectral ACF, Ryden separation as a K-rank statement, ECM monotonicity, identifiability, MLE consistency, rank-reordering marginal preservation, mixture-quantile inequality for filter-VaR, bin-centroid VaR floor) anchoring each operational claim to a stated result.

## 2. Verdict and headline assessment

In the scope of Royal Society Open Science, which evaluates technical soundness rather than perceived importance, the manuscript clears the bar. The empirical work is reproducible (single global seed, Julia code repository, Manifest.toml pinning), the metric battery is unusually broad and well argued, the negative findings (filter-VaR Kupiec failure, OoS degradation on NVDA and JPM, K equals 18 not being likelihood-optimal under a clean held-out criterion) are surfaced honestly rather than buried, and the theoretical scaffolding is consistent with the empirical claims. I therefore recommend **Accept after minor revisions**, with the revisions concentrated on framing, scope discipline, and a small number of statistical-power caveats that should be made more visible to the reader. None of the issues I raise threaten the core contribution.

## 3. Strengths

1. **Honest negative findings.** The filter-based regime-conditional VaR fails Kupiec, is presented as such, and is grounded in a stated mixture-quantile inequality (Proposition 4) rather than waved away. The paper's separation of the smoother-based diagnostic (which depends on future observations) from the operationally correct filter-based one-step-ahead backtest is a refreshingly clean conceptual move and is unusual in this literature. The appended remarks on candidate remedies (concentration constraint, state-conditional variance overlay) are constructive.
2. **Reproducibility scaffolding.** A single global seed (20260420), additively derived per-experiment sub-seeds, a public code repository, pinned Julia environment, and CSV artefact paths cited inline (e.g., results/robustness/k_selection_validation.csv) place the paper at the strong end of reproducibility for this venue.
3. **Comparator breadth.** Twelve baselines on the headline panel and an additional GARCH-family suite (EGARCH, GJR-GARCH, GARCH-t, HAR-RV, MS-GARCH at K equals 3), QuantGAN, window-diffusion, and MS-GARCH at K equals 2 together remove most of the natural "you did not compare to my favourite generator" objection.
4. **Theory anchored to specific empirical rows.** Section 5's propositions are not decorative: each one is tied by a sentence or table reference to an empirical row. The bin-centroid VaR-floor result (Proposition 8) and the mixture-quantile inequality (Proposition 4) explain otherwise puzzling empirical patterns.
5. **Self-aware K selection.** The paper explicitly flags that K equals 18 is not the held-out-log-likelihood-optimal state count (the clean re-selection picks K equals 3 by held-out log-likelihood and K equals 9 by held-out KS) and defends the choice on multi-metric grounds. Many papers in this corner of the literature do not even acknowledge the IC-versus-held-out tension.
6. **Pipeline split (A vs B) is documented at every callsite.** The repeated "pipeline note" paragraphs guard against the common confusion between per-asset and joint multi-asset evaluation. The schematic in Figure 1 is clear.

## 4. Issues to address (minor)

### 4.1 Statistical power on Christoffersen / Kupiec at alpha equals 0.01

At T_OoS equals 572 with alpha equals 0.01 the expected breach count is roughly 5.7. The Christoffersen LR_ind statistic on so few breaches has very low power and a small absolute number of clustered breaches inflates LR_ind sharply. The manuscript already concedes this in places (Section 7.3 acknowledges "small-sample concern that applies most sharply at alpha equals 0.01"), but the concession is local. I would like to see a single short paragraph in the discussion that quantifies the issue: a parametric bootstrap of LR_ind under a true breach rate of 0.01 with T equals 572, reporting the 5 / 95 percentile band, would let readers calibrate the LR_ind numbers against MC noise rather than against the chi-squared critical value alone. The MC bootstrap appears to already be in `results/robustness/kupiec_mc_ci.csv` for LR_uc; extending it to LR_ind would require only additional script work and would strengthen the operational claims.

### 4.2 Multiplicity in the seven-plus-seven metric battery

Fourteen metrics across two windows times twelve to sixteen generators is a large grid, and the paper sometimes makes claims of the form "CHMM-t leads on metric X" when X is one of many comparisons. Two suggestions: (i) state once at the top of Section 6.3 that no multiple-comparison correction is applied and that headline rankings are intended as descriptive rather than as hypothesis tests on a per-metric basis; (ii) consider a single composite ranking (e.g., a Borda count or average normalised rank across the panel) so that the "CHMM-t at the distributional frontier" claim has one number behind it rather than being assembled informally from multiple individually-leading rows.

### 4.3 The K equals 18 selection

The paper handles this honestly already, but I would tighten the presentation by (a) lifting the held-out re-selection table (current Table 2, Section 6.2) into a one-sentence flag in the abstract or introduction so that readers do not arrive at the K equals 18 operating point believing it was log-likelihood-optimal, and (b) adding a mini-panel (one row per metric) showing how the headline twelve-generator comparison would re-rank if computed at K equals 3 or K equals 9. The discussion notes that "a parallel version of the main panel at K equals 3 and K equals 9 would re-rank some rows of Table 5 in CHMM-F's favour on ACF-MAE", which is the right caveat but stops short of actually showing it. A small two-row sensitivity panel would close the loop.

### 4.4 OoS degradation on NVDA and JPM

The paper already attributes these failures to non-stationarity of the 2024 to 2026 regime and shows that quarterly walk-forward refit recovers JPM by roughly 15 percentage points of OoS KS. Two refinements would help. First, the residual gap of 35 percentage points on JPM after walk-forward refit is striking and the manuscript only gestures at "a more fundamental distributional shift". Either a per-quarter breakdown of where in 2024 to 2026 the gap concentrates, or a brief sensitivity to bin width / refit cadence, would let the reader judge whether the residual gap is concentrated in a single sub-window or pervasive. Second, the paper draws a strong "stationarity scope point" framing from a sample of two assets out of six. I would weaken the language to acknowledge that two-of-six is a small base for diagnosing a structural property of the model class.

### 4.5 Theoretical section: precedent attribution

Section 5 is honest about its propositions being assembled rather than novel, and Table 4 traces each result to its closest precedent. Two requests. (i) Theorem 1 (closed-form spectral ACF) is stated as a "specialisation" of Hamilton 1989 / Fruwirth-Schnatter 2006. This is fair but understated: the specific closed form for the absolute-return ACF under heavy-tailed emissions, with explicit c_k coefficients, is, as far as I know, not in the cited precedents in this exact form. The specialisation is more substantive than the table row suggests. (ii) Proposition 4 (mixture-quantile inequality for filter-VaR) credits McNeil-Frey-Embrechts. The inequality F^(-1)(alpha) less than or equal to min_k F_k^(-1)(alpha) is a one-line corollary of monotonicity, but pinning it down as the operational mechanism behind the filter-VaR Kupiec failure is the contribution and that should be flagged more prominently in the text, not only in the table.

### 4.6 Filter-VaR remedies

The paper proposes two remedies (concentration constraint on the filter posterior; state-conditional variance overlay) and notes that the Section 7.3 lambda sweep on per-state degrees-of-freedom shrinkage does not move the filter-VaR breach rate. This is an honest closed loop, but I would push for one explicit experiment in the revision: try the concentration-constraint remedy (e.g., replace the filter posterior with a one-hot at the argmax state) and report whether it actually closes the Kupiec gap in the predicted direction. If it does, the inequality has a constructive companion result and the paper's negative finding becomes a partial positive. If it does not, the filter-VaR axis becomes a more robust open-problem statement than the current "left as future work" framing.

### 4.7 Cross-asset universe of six is small

The cross-asset extension is restricted to six tickers, which the paper acknowledges. The claim that "the copula-ahead-of-SIM ordering replicates the discrete-marginal ordering of Alswaidan 2026 and is intrinsic to the rank-reordering construction" is a strong generalisation off six tickers. I would either soften the language or, if the data are accessible, run the same comparison on a larger sub-universe (e.g., the S&P 100) under a vine or factor copula to back the claim. The discussion already lists "vine or factor copulas for tractability" as future work, so the suggestion is not orthogonal to the paper's stated direction.

### 4.8 Length and structure

The main text plus appendices is substantial (roughly 3,400 lines of TeX, references included). The seven appendices are useful but the main body retains a lot of detail that could move to them. In particular Section 6.3 (Twelve-Generator Comparison) carries paragraph-by-paragraph commentary on every baseline; condensing the negative-control rows (Gaussian i.i.d., GRU, QuantGAN) into a shorter "negative controls" paragraph would tighten the narrative. This is not a blocking concern for RSOS, which does not enforce a length cap, but it would improve readability for non-specialist readers.

### 4.9 GARCH-t should be a headline row

Table 6 (the GARCH-family suite) shows that GARCH-t with nu equals 6.89 attains the smallest ACF-MAE in any GARCH row (0.0316), passes Kupiec at both alpha levels with LR_uc near 0.01, and produces simulated kurtosis (15.13) close to CHMM-t's (14.57). The text correctly notes that GARCH-t "slightly beats CHMM-t on ACF-MAE while CHMM-t is materially ahead on KS / AD". For an integrative-evaluation paper this comparison is the natural headline competitor, not the plain Gaussian GARCH(1,1) that lives in Table 5. I would either lift GARCH-t into the main twelve-row comparison or add an explicit "GARCH-t vs CHMM-t" summary row to the abstract / introduction's headline numbers. As written, a reader stopping at Table 5 would walk away under-informed about the closest GARCH-family competitor.

### 4.10 Minor presentational items

* Abstract sentence "honest negative finding" is appropriate but the abstract reads as long. The third sentence (the proposition list) could be moved to a "Theory" sentence in the introduction and the abstract could be cut by roughly 30 percent without information loss.
* The "data and code availability" paragraph references two GitHub repositories (CHMM-paper, CHMM-Model). I confirmed the repository names appear consistently; please verify both URLs resolve at submission time and that the Manifest.toml is the one used to produce the paper's numbers.
* Several caption headlines start with bold and a trailing period (good, consistent), but a few captions in the appendix sections do not use the same convention. A pass for caption uniformity is worth one editing cycle.
* The macro `\revtodo` is still defined in paper.tex with the comment "remove once filter-based re-runs land". A grep for `\revtodo{` should confirm there are no leftover red placeholders in the camera-ready.

## 5. Items I checked and found to be sound

* The Baum-Welch and ECM derivations in the algorithms appendix are standard and correct in form.
* Quantile-based initialisation is the right default for the regime-collapse failure mode the Ryden 1998 setup is vulnerable to, and the K equals 2 replication in Appendix `ryden_replication` directly supports this.
* The closed-form spectral expression for the absolute-return autocovariance (Theorem 1) is correctly derived; the proof uses the standard spectral decomposition of T and the conditional independence of the emissions given the state sequence.
* The rank-reordering marginal-preservation result (Proposition 5) is two lines and is correct: a permutation of a sample preserves the empirical CDF.
* The bin-centroid VaR-floor inequality (Proposition 8) is elementary and correctly worded; the Poisson-jump invariance is the right structural observation.
* The pipeline schematic (Figure 1) is consistent with the empirical sections.

## 6. Final recommendation

**Accept after minor revisions.** The paper is technically sound, honestly evaluated, broadly compared, and reproducible. The recommended revisions (explicit MC bootstrap on LR_ind at alpha equals 0.01, multiplicity caveat, K-sensitivity mini-panel, JPM walk-forward sub-window breakdown, GARCH-t lifted into the headline panel, presentational tightening) are scoped to one revision cycle and do not require additional model development. Nothing in my review is a blocker.

Royal Society Open Science is the right venue: the paper's contribution is integrative and reproducibility-oriented rather than methodologically novel in a single direction, and the journal's evaluation criteria (technical soundness, reproducibility, methodological transparency) match the paper's strengths. A higher-prestige venue might push back on the "integrative rather than novel-estimator" framing; RSOS will not, and should not.

---

*Reviewer disclosure: this review is written in the voice of an external statistical-finance reviewer with no prior involvement in the work. Length: roughly 1,700 words. Time spent: approximately 90 minutes equivalent.*
