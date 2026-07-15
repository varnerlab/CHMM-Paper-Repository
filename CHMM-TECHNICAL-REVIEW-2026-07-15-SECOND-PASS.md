# CHMM Paper Technical Review — Second Pass

Review date: 2026-07-15

Repositories reviewed:

- Paper: `CHMM-Paper-Repository`, commit `76224baaffe41f39e11c17874148eeed80454277`
- Model: `CHMM-Model-Repository`, commit `f8064e87c6505d0cd3f12578d8939b814faab66a`

Scope: a fresh end-to-end review of the compiled manuscript, with emphasis on
technical accuracy, statistical interpretation, claim strength, narrative
flow, and agreement with the companion implementation and result artefacts.

## Verdict

The response commit resolves the six issues in the preceding Codex review: the
Student-t degrees-of-freedom update is now scoped as a surrogate block update,
`K^star = 3` is presented as a BIC/CAIC parsimony choice, the finite-memory
claim is narrowed, the rebuild driver returns failure correctly, and the GED
and ES-envelope wording is accurate.

The paper is technically close, but this second pass found three substantive
claim/estimator issues, two lower-priority accuracy/reproducibility issues, and
several narrative/layout improvements. None invalidates the CHMM equations or
the reported headline numbers. The most important remaining correction is to
stop treating a DQ non-rejection at `p = 0.06` as evidence that CHMM-N is
comparatively better than contenders with `p = 0.04` and `p = 0.01`.

## Findings

### 1. High: the DQ test does not establish a comparative strict-tail advantage

The Results say that CHMM-N at `K^star = 3` has a “strict-tail advantage,” and
the Conclusion says the Engle-Manganelli test “favoured” it over the filtered
bootstrap and CAViaR (`sections/results.tex:97`;
`sections/conclusion.tex:1`). The underlying DQ p-values at `alpha = 0.01` are
`0.06`, `0.04`, and `0.01`, respectively (Table 4).

That pattern supports only the descriptive statement that CHMM-N was the sole
row not rejected at the chosen 5% threshold. Failure to reject is not evidence
that the null is true, and one p-value falling just above 0.05 while another
falls just below it does not establish a significant difference between the
models. The paper itself also notes that this tail tier is power-bounded.

Recommended correction: replace “advantage” and “favoured” with wording such
as: “CHMM-N at `K^star = 3` was the only tested row not rejected by DQ at
`alpha = 0.01` (`p = 0.06`), but no pairwise superiority test was conducted and
the result is power-bounded.” A genuine comparative claim would require a
pairwise loss-based test or another formally defined model-comparison design.

### 2. High: the Gamma-sojourn HSMM is not a maximum-likelihood estimator as implemented

The Gamma-sojourn table is captioned “Maximum-likelihood Gamma-sojourn HSMM”
(`sections/sensitivity_appendix.tex:404`), and the runner repeatedly labels the
fit “ML.” The same paragraph and the code state that the Gamma shape and scale
are updated by method of moments on expected duration counts
(`sections/sensitivity_appendix.tex:399`;
`CHMM-Model-Repository/runners/baselines/run_hsmm_ml_gamma.jl:4-9,87-97,318-378`).

A method-of-moments duration update does not maximise the expected complete-data
log-likelihood of the truncated discrete-Gamma duration model. The overall
procedure therefore is not ordinary maximum-likelihood EM, and it does not
inherit the EM monotonic-ascent guarantee merely because its E-step is an HSMM
forward-backward recursion.

Recommended correction: rename this row and runner as a
“method-of-moments Gamma-sojourn HSMM” or “HSMM with a moment-updated Gamma
duration block,” and treat the result as a sensitivity experiment. If an ML
label is required, replace the moment update with numerical maximisation of the
posterior-weighted truncated discrete-Gamma duration objective and verify the
observed-likelihood trace.

### 3. Medium: the proposed stress-fold remedy contradicts the reported evidence

The Conclusion says that a time-varying transition matrix “would address” the
W2 COVID and W4 rate-hike folds (`sections/conclusion.tex:3`). In contrast, the
Results say that no tested refit cadence can anticipate an unseen shift, the
Discussion says refitting did not save W2 or W4, and Table S37 says “no cadence
closes” those folds (`sections/results.tex:145-146`;
`sections/discussion.tex:5`; Table S37).

Rolling refit is also not equivalent to a time-varying transition model, and a
particle filter with fixed parameters does not by itself adapt to a structural
break. The untested extensions are plausible research directions, not remedies
demonstrated by this study.

Recommended correction: say that covariate-dependent transitions, online
change-point detection, or parameter learning are candidates to test against
these failures. Do not say they “would address” the folds until evaluated in a
like-for-like walk-forward design.

### 4. Medium: “first evidence” overstates the appendix HSMM sensitivity

The Conclusion calls the plug-in Pareto and moment-updated Gamma results “first
evidence that non-geometric durations restore the temporal channel”
(`sections/conclusion.tex:3`). This is too strong for three reasons:

- Bulla and Bulla are already cited for recovering the ACF fit with an HSMM;
- the main `K = 3` ML HSMM-N row has worse `|G_t|` ACF-MAE than CHMM-N
  (`0.0629` versus `0.0462`); and
- the supporting improvement comes from the method-of-moments Gamma sensitivity
  at `K = 18`, while the plug-in Pareto estimator is explicitly not ML and
  degenerates at that state count.

Recommended correction: call this “preliminary within-study sensitivity
evidence at `K = 18`.” Keep the important counter-result visible: the headline
`K = 3` ML HSMM improved marginal KS but regressed to the i.i.d. ACF-MAE floor.

### 5. Low: the preferred heavy-tail variant has no defined joint selection criterion

The Results call shared-nu CHMM-t the “best joint marginal-fit and heavy-tail”
row (`sections/results.tex:3`). It has the highest OoS KS among the CHMM rows,
but CHMM-L and CHMM-GED are closer to observed excess kurtosis, as the next
clause acknowledges. No composite score, Pareto rule, or predeclared weighting
defines “best joint.”

Recommended correction: say that shared-nu CHMM-t provided the preferred
trade-off—best CHMM OoS KS and a smaller kurtosis gap than CHMM-N without a
penalty hyperparameter—or explicitly define a joint selection rule.

### 6. Low: paper-repository build documentation is stale and contradicts the model repo

The paper README says the current draft is 67 pages and that
`run_full_rebuild.jl` rebuilds every paper artefact (`README.md:53-54,104`). The
compiled PDF is 76 pages. The corrected model repository now describes that
driver as the headline pipeline and directs users to the full runner map, so
the paper README has retained the old, broader contract.

Recommended correction: update the page count to 76 (or avoid hard-coding it)
and describe `run_full_rebuild.jl` as the headline rebuild, with `RUNNERS.md` as
the authoritative complete artefact map.

## Narrative flow

The central argument now has a coherent spine:

1. split the historical low-state Gaussian failure into temporal and marginal
   channels;
2. use the spectral identity to diagnose the temporal channel;
3. select a parsimonious operating state count;
4. compare emission families and benchmark generators;
5. test cross-ticker transfer, cross-asset dependence, and conditional VaR; and
6. close with the stationarity boundary.

The remaining problem is density rather than ordering.

- The abstract is 325 words and carries the data universes, spectral result,
  emission result, VaR result, copula result, two benchmark caveats, and scope
  limitation. Reducing it toward roughly 200–250 words would make the main
  contribution easier to identify.
- Results paragraphs repeatedly combine estimates, caveats, appendix pointers,
  interpretation, and use-case recommendations. Short subheadings—state-count
  choice, emission/baseline comparison, cross-ticker transfer, cross-asset
  dependence, VaR, and stationarity stress—would materially improve auditability.
- The Conclusion is two very long paragraphs and introduces the strongest HSMM
  claim only from appendix evidence. It should synthesize the main findings,
  then list future work more compactly without upgrading appendix sensitivities
  into headline conclusions.
- Table 1's caption is long enough to compete with the Results prose. Move the
  implementation qualifications for MSGARCH and QuantGAN to table notes or the
  appendix and leave the caption focused on population, metrics, and bolding.

## Presentation and build observations

- The 76-page PDF renders cleanly in the sampled body, bibliography, and
  appendix pages; I found no clipped figures, overlapping text, missing glyphs,
  or broken references in the rendered document.
- The existing `paper.log` contains one `Overfull \\hbox` warning of 6.44861 pt
  in `sections/results.tex:13-43`, the main comparison table. The likely source
  is the unbreakable seven-column `\\multicolumn` note at line 33. Shorten that
  note or allow it to wrap.
- The final Conclusion cites “Tables 1 and S32” for the walk-forward
  `K = 3` versus `K = 18` median comparison, but Table 1 contains only the
  `K = 3` main block. Cite Table S32 alone, or the actual `K = 18` sensitivity
  table as well.

## Verification performed

- Read the compiled main paper end to end and audited the relevant appendix
  sections against the LaTeX sources.
- Rendered all 76 PDF pages and visually inspected representative pages across
  the title/abstract, each main section, tables, bibliography, algorithms,
  diagnostics, and final appendix tables.
- Cross-checked the DQ, HSMM, state-selection, copula, and rebuild claims against
  their companion runner code and committed result artefacts.
- Confirmed that both repositories were clean before this review file was
  added.
- Did not rerun the full empirical pipeline; this pass validates the checked-in
  manuscript, code paths, logs, and result artefacts rather than independently
  recomputing every simulation.

## Recommended disposition

Correct Findings 1–3 before submission. Finding 2 is an estimator-label issue,
not evidence that the reported Gamma-HSMM numbers are numerically wrong, but it
must be fixed for methodological accuracy. Findings 4–6 and the narrative
edits should be handled in the same editorial pass. After those changes, the
paper's central CHMM result, spectral derivation, state-count rationale, and
main-window VaR arithmetic are supportable within the carefully stated daily
US-equity scope.
