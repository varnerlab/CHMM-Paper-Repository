• Verdict

  Major revisions

  The paper is ambitious, unusually thorough in benchmarking, and commendably candid about some negative findings. But in its current form I would not recommend acceptance in Royal Society Open
  Science. The central problem is not lack of effort; it is that several headline claims are stronger than the design supports, especially around state-count selection, the theoretical “resolution”
  of the low-(K) issue, and the operational VaR narrative.

  Main findings

  1. The paper’s headline operating point is contaminated by test-set reuse, yet the abstract, introduction, and conclusion still present K = 18 as if it were a supported main choice. In the body the
     authors explicitly admit that K = 18 was chosen using the same 2024–2026 OoS window later used for VaR evaluation and that none of the clean selection criteria pick K = 18 (sections/
     results.tex:50, sections/results.tex:52). But the introduction still says K = 18 “wins or ties every IS and OoS distributional pass-rate metric” (sections/introduction.tex:19), the abstract
     presents a single “moderate state resolution” success story without foregrounding the contamination (paper.tex:113), and the conclusion repeats that K = 18 was selected by metric wins (sections/
     conclusion.tex:3). That is a core inferential problem, not a cosmetic caveat.
  2. The theoretical “Rydén separation as a (K)-rank statement” is overstated and, as written, not convincing. The step from |λ2| -> 1 to “the stationary mixture collapses to one emission density” is
     not generally established by the argument given (sections/theory.tex:185, sections/theory.tex:203). A two-state chain can have very persistent states without its stationary distribution
     concentrating near a simplex vertex. Likewise, the K >= 3 proof sketch argues from non-uniqueness of a linear system, but that does not show that a valid HMM with admissible weights/
     eigenstructure can both match the target ACF and preserve the marginal in the claimed way (sections/theory.tex:207). Yet this corollary is used to support strong framing in the introduction and
     conclusion (sections/introduction.tex:10, sections/conclusion.tex:9). The exact ACF decomposition theorem looks fine; the interpretive corollary is where the overreach occurs.
  3. The “utility” section uses a weak VaR/ES criterion that flatters the models before the paper later shows the operational VaR construction fails. The standard at the start of Section 7 is whether
     simulated VaR/ES envelopes “bracket” the observed historical values (sections/var_backtest.tex:6, sections/var_backtest.tex:40). That is not a strong backtesting argument; with wide enough
     simulated envelopes many models will pass. The later filter-based one-step-ahead backtest is the operationally relevant test, and it fails Kupiec for all three CHMM families at both levels
     (sections/var_backtest.tex:163, sections/var_backtest.tex:172, sections/var_backtest.tex:220). The paper is honest about that failure, which is good, but then the earlier “well calibrated as
     risk consumers” language should be toned down substantially.
  4. The semi-Markov extension is too provisional to support the strength of the claims made for it. The SM models are not fit by a full semi-Markov likelihood; they are plug-in constructions built
     from a Viterbi path of the flat model, with per-state duration families chosen afterward (sections/var_backtest.tex:67, sections/var_backtest.tex:68). Despite that, the text calls SM a “risk-
     calibration upgrade” and draws relatively strong comparative conclusions (sections/var_backtest.tex:88, sections/var_backtest.tex:115). For RSOS, that is probably salvageable, but only if the
     authors reframe SM as an exploratory ablation rather than a mature competing model class.
  5. The empirical scope is narrower than the framing suggests. Most substantive claims are anchored to one ticker, SPY. The cross-asset extension uses six assets only, and the paper itself reports
     major OoS degradation on NVDA and JPM (sections/introduction.tex:26, sections/introduction.tex:28, sections/conclusion.tex:14, sections/conclusion.tex:19). That does not invalidate the SPY
     study, but it does mean the paper should stop short of broad claims about “equity returns” unless the generalization evidence is materially strengthened.

  What I would say in the report

  The manuscript has real strengths: broad benchmarking, reproducibility scaffolding, and an unusually honest presentation of the filter-VaR failure. I also think the exact spectral ACF
  representation is useful and the integrative angle is a legitimate contribution for RSOS.

  But I would recommend major revision, not acceptance. The revision would need to do three things.

  1. Rebuild the headline empirical narrative around a clean selection protocol. Either make K = 3 or K = 9 the main operating point, or present a preregistered-style split where K = 18 is explicitly
     a post hoc multi-objective choice and all headline claims are qualified accordingly.
  2. Rewrite the theory section so it distinguishes clearly between:
      - results that are exact and proved,
      - plausible interpretations,
      - empirical conjectures.
        The current corollary about low-(K) failure should be weakened unless a much more rigorous argument is supplied.
  3. Reframe the risk section. The operational headline is currently negative: the real-time filter-based regime-conditional VaR is not calibrated. That is acceptable, but then the earlier “utility”
     claims based on envelope bracketing should be demoted to descriptive context, not presented as evidence of risk-model adequacy.

  Secondary comments

  The paper is also too long and repetitive for its current argumentative clarity. The strongest GARCH-family comparator appears to be GARCH-t, but it is not in the main comparison table; that
  weakens the fairness of the headline panel. The abstract is overloaded. The SM section should be labeled more cautiously as plug-in. And the manuscript should remove any residual language implying
  that the low-(K) problem is theoretically solved rather than empirically mitigated.

  Bottom line

  If I were reviewing for Royal Society Open Science, my honest recommendation would be:

  Major revisions required before the paper is publishable.

  The work is promising and likely salvageable, but the current version still overstates what its theory and validation design can support.