# Paper II: arxiv vs repo diff analysis

Comparison of Paper II ("Continuous Hidden Markov Models for Equity Returns: Heavy-Tail
Emission Families and Regime-Conditional Value-at-Risk") as published on arxiv against the
current repository LaTeX source.

- Version A (repo): current working tree, `CHMM-Paper-Repository/paper.tex` + `sections/*.tex`.
- Version B (arxiv): `arXiv:2606.23492v1 [q-fin.ST]`, 22 Jun 2026, text extracted from the
  published PDF via `pdftotext -layout`.

Bottom line: the repo is a strictly later, more carefully hedged revision. Every substantive
change moves in one direction, toward narrower scope, softer claims, corrected terminology, or
added supporting evidence. No change broadens scope or strengthens a claim beyond arxiv, and no
reported numeric result changed where both versions report it.

## Verdict: which framing is more accurate

The repo version. Three reasons.

1. It corrects a genuine overclaim. Arxiv says the CHMM is differentiated "on use cases
   neither alternative can serve"; the repo scopes that to the i.i.d. bootstrap only (which
   carries no latent state), and concedes HSMM-based heads are possible but deferred to a
   companion paper. The arxiv wording overstated the case against the semi-Markov benchmark.
2. It fixes a terminology mismatch. Arxiv body text repeatedly says "kurtosis" where the
   measured and tabulated quantity is excess kurtosis (Table 1 "Exc. Kurt"); the repo says
   "excess kurtosis" throughout. In one arxiv sentence this produced a literal mismatch,
   comparing "simulated excess kurtosis" against "observed kurtosis."
3. It replaces assertion with evidence at K = 2. The arxiv states the tight-rank-bound K = 2
   case in prose only; the repo instantiates it with a fitted spectrum, a Table S5 panel, a
   Table S29 row, and a four-family K = 2 fit.

The one honest cost of the more careful framing: the repo hedges the ACF claim to "matched
within our lag-252 MAE tolerance," which is more defensible but weaker than arxiv's flat
"reproduced." Net, arxiv reads cleaner and more confident; the repo reads more defensible and
is the version to cite in the thesis and defense.

## Diff by region

Characterization tags: [precision] terminology/number precision, [scope] scope narrowing,
[soften] softened claim, [correct] corrected overclaim, [evidence] added supporting evidence,
[caveat] new qualifier, [structure] table/section change.

### Abstract, Introduction, Related Work, Methods, Theory

| Location | Repo (A) | Arxiv (B) | Tag |
|---|---|---|---|
| Abstract | "separates the temporal and distributional channels of the low-state Gaussian limitation" | "separates the temporal and distributional sides of the original failure" | [soften] neutral "limitation" replaces loaded "failure"; "channels" aligns with the two-channel framing |
| Abstract | "narrowed the excess kurtosis gap" | "narrowed the kurtosis gap" | [precision] |
| Introduction | "We separate the low-K Gaussian limitation into two possible failure channels" | "The Ryden failure combines two constraints" | [soften] presents the split as the authors' analytical move, not an intrinsic property of a Ryden "failure" |
| Introduction | "Ryden's own outlier-reduced subseries broke on the temporal channel; on our non-outlier-reduced data the distributional channel binds instead." | ABSENT in arxiv | [scope] localizes which channel binds and pre-empts an apples-to-oranges objection |
| Introduction / Related Work | "excess kurtosis" (distributional-channel parenthetical; SV unimodality ceiling; baseline separation; evaluation-metric list) | "kurtosis" in the same four places | [precision] |
| Methods | New footnote: "'Conditional' here means conditioning on the latent regime ... It is distinct from the conditional Value-at-Risk (CVaR), equivalently the expected shortfall (ES) ... and from the Christoffersen conditional-coverage property." | ABSENT in arxiv | [caveat] separates regime-conditional VaR from CVaR/ES and from Christoffersen coverage |
| Methods (Evaluation) | "read against the observed excess kurtosis on the same window" | "read against the observed kurtosis on the same window" | [precision] removes a simulated-excess vs observed-plain mismatch |
| Theory (Spectral mechanism) | New sentence: "The fitted SPY K = 2 chain confirms this empirically: a single non-unit eigenvalue carries 100% of the lag-1 |G| ACF ... (lambda_2 = 0.94 Gaussian, 0.95 shared-nu Student-t)" | ABSENT in arxiv | [evidence] backs the previously assertion-only spectral argument with fitted eigenvalues |

The load-bearing hedges present in both versions verbatim: "Under the diagnostics used here,"
"does not establish a general power-law or multi-scale approximation," "on these daily
US-equity data and metrics," "We make no formal privacy guarantee," the EM convergence caveats,
and the KS-as-descriptive-score disclaimer.

### Results, Discussion, Conclusion

| Location | Repo (A) | Arxiv (B) | Tag |
|---|---|---|---|
| Results | "matched, through the mixture-of-eigenvalues sum, the slow absolute growth-rate ACF within our lag-252 MAE tolerance" | "reproduced, through the mixture-of-eigenvalues sum (6), the slow absolute growth-rate ACF" | [soften] adds explicit tolerance qualifier |
| Results | "where the Ryden K = 2 to 3 Gaussian setup, fit jointly by ML, judged the ACF fit unsatisfactory" | "that the Ryden setup could not recover" | [soften] verb weakened; adds "fit jointly by ML" |
| Results | "the closest heavy-tail approach without a penalty hyperparameter" | "the cleanest heavy-tail match without a penalty hyperparameter" | [soften] |
| Results + Table 1 caption | bootstrap "structurally unable to produce a regime-conditional VaR ... and HSMM-based heads are left as a companion-paper direction" | CHMM "differentiated on use cases neither alternative can serve" | [correct] narrows "structurally unable" to the bootstrap only |
| Discussion | "The low-K Gaussian limitation has two possible failure channels" | "Two issues combine in the Ryden et al. low-K failure" | [soften] de-attributes the "failure" from Ryden |
| Discussion | "Ryden, whose subseries were outlier-reduced, found the marginal adequate and the slow ACF the one hard fact; on our non-outlier-reduced SPY data the marginal channel binds instead." | ABSENT in arxiv | [scope] attributes the divergence to outlier reduction |
| Discussion | "IS KS pass rate fell to 79.0% ... ACF-MAE stayed essentially constant (0.0501 versus 0.0462) ... single persistent mode (lambda_2 = 0.942)" | "IS KS pass rate fell well below the 91.5% ... ACF-MAE stayed essentially constant" (no numbers) | [evidence] adds concrete K = 2 figures |
| Discussion | "matched within our lag-252 MAE tolerance at any K >= 2, independent of initialisation" | "With modern initialisation the ACF was reproduced at any K >= 2" | [soften] drops the "modern initialisation" credit and adds the tolerance hedge |
| Discussion | "Switching to a heavy-tailed emission narrowed the gap but did not close it." | "Switching to a heavy-tailed emission closed most of the gap." | [soften] |
| Discussion | New paragraph: "This reading may look like it inverts Ryden ... The difference is the data, not a contradiction ... On the ACF we agree with his in-principle limit ... we match the absolute growth-rate ACF only within our lag-252 MAE tolerance, and the structural fix for genuinely slow decay is the semi-Markov chain of Bulla." | ABSENT in arxiv | [caveat] explicit Ryden reconciliation; concedes the finite-mode limit |
| Conclusion | "These results motivate five extensions, the first of which points outside the model class ... a dedicated maximum-likelihood explicit-duration HSMM ... is thus the primary next direction" (with Pareto-sojourn 17/18 states and Gamma-sojourn HSMM beating CHMM-N on ACF-MAE evidence) | "These results motivate four extensions." (no sojourn-law extension) | [structure] adds the out-of-class sojourn extension as the primary next step |
| Conclusion | "Each of these four ... while the sojourn-law extension is the one that leaves the finite geometric-memory ceiling behind." | "Each extension targets one limitation ..." | [caveat] distinguishes the out-of-class extension from the four in-framework ones |

Substantively identical between versions: the cross-ticker paragraph (median 69.1%, 11/30,
quarterly-refit 84.7%, 8/30), the copula paragraph (MAE 0.027 / 0.209 / 0.185, nu* = 6), the
full VaR paragraph (p_cc, breach rates, DQ p-values), the walk-forward K* = 3 vs K = 18 figures
(62.1% vs 67.7%), the GLD/W2/W4 scope statement, and all author/data-availability statements.

### Appendix and Supplementary, Tables

Same appendix skeleton in both: A.1 to A.10, and every A.7.x / A.8.x / A.9.x subsection appears
in both. No appendix subsection was wholly added or removed. The differences cluster around one
added analysis, the K = 2 state count.

| Location | Change | Tag |
|---|---|---|
| Table S5 (A.7.4), "Per-mode contribution to the absolute growth-rate ACF identity" | Repo adds a third panel, K = 2 (single mode: |lambda| = 0.942, |a_k lambda_k| = 0.252, cum = 1.000, "rank bound tight"). Arxiv has two panels (K = 18, K = 3). Caption updated to "as well-satisfied at K = 2 and K = 3 as at K = 18." | [structure] instantiates the previously asserted tight-bound K = 2 case |
| Table S29 (A.10), "Pre-OoS held-out K-selection for CHMM-N" | Repo adds a K = 2 row across all four validation designs. Arxiv rows start at K = 3. | [structure] extends the held-out sweep down to K = 2 |
| A.7.6, Ryden K = 2 replication | Repo expands from ~6 lines with no numbers to a quantified argument: K = 2 IS KS 79.0% vs 91.5%, ACF-MAE 0.0501, simulated excess kurtosis 2.57, a four-family K = 2 fit (Gaussian 76.8% / 2.56, Student-t 91.6% / 6.24, GED 90.0% / 4.11), and lambda_2 = 0.942 Gaussian / 0.954 Student-t carrying 100% of the lag-1 |G| ACF. Conclusion reframed to "the binding low-K constraint was the marginal shape rather than the number of decay modes." | [evidence] |
| A.7.4 spectral-rank prose | Repo: "at K = 2 the bound is tight ... which the fitted K = 2 spectrum confirms." Arxiv states it as an assertion only. | [evidence] |
| A.10 K-selection prose | Arxiv: "held-out two-sample KS selected K* = 9." Repo: "held-out two-sample KS nominally selected K = 2, but this validation slice is a structural-break period ... so its KS ranking is not discriminating," plus a passage ruling out K = 2 on the full window (BIC 8532 at K = 3 vs 8700 at K = 2; heavy tail 2.56 vs 7.68; IS KS 76.8% vs 91.5%). | [caveat] reworks the KS-selection claim as a consequence of adding the K = 2 row |
| Terminology (pervasive) | Repo "excess kurtosis" where arxiv body text and some captions say "kurtosis" (e.g. Table S3 metric row; A.7.7 / A.7.8 prose). Several arxiv captions already read "excess kurtosis," so this is a consistency pass, not a numeric change. | [precision] |

## Themes

1. Terminology precision: "kurtosis" to "excess kurtosis" throughout, matching the reported
   quantity.
2. Ryden reframed from "failure/contradiction" to "data difference," via de-attributed wording,
   two new outlier-reduction sentences, and a full reconciliation paragraph that concedes the
   in-principle finite-mode limit.
3. Softened ACF claims: "reproduced" to "matched within our lag-252 MAE tolerance"; "closed most
   of the gap" to "narrowed the gap but did not close it"; "cleanest match" to "closest approach."
4. Corrected baseline overclaim: only the i.i.d. bootstrap, not the HSMM, is structurally barred
   from the downstream heads.
5. New K = 2 analysis: Table S5 panel, Table S29 row, expanded A.7.6, empirical-confirmation
   wording in A.7.4 and the theory section, reworked A.10 K-selection prose.
6. Future work broadened from four to five extensions, adding the explicit-duration semi-Markov /
   heavy-tailed-sojourn model as the primary out-of-class next direction, with supporting evidence.
7. New disambiguation footnote separating regime-conditional VaR from CVaR/ES and Christoffersen
   coverage.

## What did not change

- All reported numeric results where both versions overlap (KS rates, excess kurtosis point
  estimates, ACF-MAE, eigenvalues, p_cc and DQ p-values, copula off-diagonal MAE, walk-forward
  figures).
- The core spectral-ACF-identity contribution statement relative to Hamilton, Krolzig, and
  Timmermann is verbatim-equivalent: both call the bilinear identity and its eigendecomposition
  "textbook material in the regime-switching literature," the Markov spectral decomposition
  "standard," and both state the same contribution sentence (recasting the empirical Ryden low-K
  failure as a rank statement on T - 1*pi^T, and the empirical demonstration that the rank
  constraint was not what limited the fit at moderate K).
- The A.3 formal statements (Assumptions 1 to 2, Propositions 1 to 2) and the numeric tables
  S4, S6, S8, S9, S13, S30 to S32.
- No citations were added or removed.
