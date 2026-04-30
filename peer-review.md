# Simulated Peer Review: *A Continuous Hidden Markov Model as a Reference Synthetic-Data Generator for Equity Returns*

**Manuscript:** Alswaidan, Jin, Varner. CHMM-paper, draft as of 2026-04-29.
**Target tier:** Mid-to-high-tier (e.g., *Quantitative Finance*, *Journal of Financial Econometrics*, *Journal of Empirical Finance*, *Journal of Computational Finance*).

The skill template's metabolic-engineering personas were reframed for the actual domain: financial-time-series synthetic data, Markov-switching econometrics, and risk-management back-testing. Three reviewers are simulated below, followed by a consolidated punch-list.

---

## Reviewer 1 (Moderate): Senior Markov-Switching Econometrician

### Summary
The paper studies a continuous hidden Markov model (CHMM) trained by Baum-Welch as a synthetic-data generator for daily equity returns, with four interchangeable emission families (Gaussian, Student-t, Laplace, GED) sharing a single ECM scaffold, and applies a folklore mixture-of-eigenvalues identity for the absolute-return ACF to recast the well-known Rydén et al. (1998) low-K failure as an empirical rank statement on the deflated transition matrix. The empirical study is anchored on SPY 2014-2026 with a sector-balanced 30-ticker panel and a six-asset Student-t copula extension. The paper is competently executed and the writing is dense but precise; the headline claims look defensible, with several rough edges that should be tightened before publication.

### Strengths
1. **Unified scaffold across four emission families.** The architectural framing in §3.2 and Algorithm 1 is genuinely useful: a single forward-backward log-space recursion and quantile-based initialization, with the M-step as the only branch point. The CHMM-GED variant (per-state shape $p_k \in [0.5, 3.0]$) is a clean extension that nests CHMM-N and CHMM-L as boundary cases.
2. **Honest separation of held-out-clean operating points.** §4.2 is unusually careful: $K^\star = 6$ (held-out per-obs log-likelihood + held-out KS on the strictly pre-2020 slice) and $K^\star = 3$ (BIC) are flagged as the headline defaults, while the $K = 18$ block is consistently labeled an "extended-state-resolution sensitivity reference" selected by a non-held-out multi-objective rule. This kind of book-keeping is rare and welcome.
3. **Regime-conditional Christoffersen-cc back-test.** §4.6 is the strongest empirical section. The construction (forward filter through $\mathcal{F}_{t-1}$, predictive mixture CDF, IS-fixed parameters) cleanly separates the regime-switching value proposition from the unconditional Kupiec result, and the four-family extension in Table A.6 shows the pass is intrinsic to the latent-state forecast rather than to Gaussian emissions.
4. **Walk-forward + refit transparency.** The 24-row walk-forward conditional-VaR table (Table A.7) and the quarterly/monthly refit cadence on the 30-ticker panel are exactly the diagnostics a careful reader wants. The W2 (COVID) and W4 (2022 rate-hike onset) failures are acknowledged rather than buried.

### Weaknesses
1. **The cross-ticker headline panel (Table 4) is run at $K = 18$ rather than at the held-out-clean $K^\star = 6$.** The paper says (§4.4) that a "held-out-clean rebuild at $K^\star = 6$ produces an OoS KS distribution matching the $K = 18$ headline within sampling error (Appendix sec:cross_ticker_k6_panel)" but the body table is the $K = 18$ one. If the held-out version matches, why not promote it to body? Right now the body advertises a non-held-out cross-ticker headline alongside a held-out single-asset headline; the inconsistency invites a reviewer challenge that the paper does not need to take. Suggested fix: move the $K^\star = 6$ rebuild to the body and demote $K = 18$ to a footnote.
2. **The penalised CHMM-t at $\lambda = 20$ is uniform across the 30-ticker panel, but Table A.10 (per_ticker_lambda) shows $\hat\lambda^\star \in \{0, 10, 20\}$ varies by ticker.** QQQ optimum is $\lambda = 0$ and SPY/JPM/AAPL optima are $\lambda = 10$. Three of six tickers are "over-shrunk" at the body $\lambda = 20$. Either drop the uniform claim and present $\lambda$ as a per-ticker hyperparameter (with a short cross-validation recipe), or restrict the headline to the two heavy-tail tickers (NVDA, JNJ) where $\lambda = 20$ is the per-ticker optimum.
3. **Title overclaim: "reference synthetic-data generator".** The empirical scope is daily US equities (SPY + 30 large-caps + a six-asset US copula). Appendix sec:non_us_asset_supp documents that GLD/SLV ETFs collapse to 0% OoS KS under the static IS-fitted CHMM, which is a useful honest limitation but it materially restricts the "reference" claim. Either soften the title to "for daily equity returns" (already partially in the subtitle) and explicitly scope the contribution to that universe in the abstract's first sentence, or extend the empirical study to FX and commodities.
4. **The "novelty" of the spectral identity is hedged but the framing wobbles.** §3.3 and the introduction call the identity "textbook material in the regime-switching literature (Hamilton 1994; Krolzig 1997; Timmermann 2000)" and cite the contribution as the application to recast the Rydén failure as a rank statement. That's the right framing, but the abstract still leads with "the mechanism is a closed-form mixture-of-eigenvalues identity ...", which a casual reader may parse as a derivation claim. Recommend re-wording the abstract to put the identity in the third person ("we apply the textbook identity of Hamilton (1994), Krolzig (1997), and Timmermann (2000) to recast ...") so the contribution is unambiguous.
5. **Practical identifiability at $K = 18$ is fragile and the discussion is too brief.** §5 ("Closing the kurtosis gap") notes 11/18 effective CHMM-N states and 12/18 CHMM-t states under a standardized-distance single-linkage diagnostic, with 13/18 CHMM-t states pinned at the upper $\nu$ bracket on SPY. The body framing ("a representational-economy observation rather than a degeneracy") is defensible but a single sentence is too thin. A reviewer needs at least a paragraph on whether the 11 effective states are stable across seeds, and what the OoS KS would look like at $K = 11$ with random initialization at the merged centers.

### Questions for Authors
1. The held-out $K^\star = 6$ rebuild on the 30-ticker panel matches the $K = 18$ headline "within sampling error". What is the actual KS distribution under that rebuild, and where does it sit relative to the $K = 18$ panel quantile-by-quantile?
2. The quantile-based initialization is presented as the mechanism that "makes Baum-Welch reach a non-degenerate $K \ge 3$ fit". How does it compare to a K-means-on-residuals init (which is the Bilmes 1998 default) at $K = 6$ and $K = 18$ on SPY? A side-by-side ablation in the discussion would close this.
3. The block-bootstrap KS recalibration in §B.2 reports only IS pass rates. Does the same block-aware recalibration on the OoS window change the CHMM-vs-GARCH ordering qualitatively? The asymptotic ordering at OoS is GARCH(1,1)-$t$ ≈ CHMM-t; under a block-aware OoS test, do they diverge?

### Requested Experiments / Analyses
- **A held-out-clean $K^\star = 6$ cross-ticker panel in the body**, with the $K = 18$ panel demoted to appendix. The paper already has the data; this is editorial.
- **A per-ticker $\hat\lambda^\star$ recipe** for the penalised CHMM-t. Either a short cross-validation procedure (one-sentence definition + a column added to Table 4) or a published lookup table; the per-ticker optima in Table A.10 should be promoted.
- **A seed-stability check on the effective-state count at $K = 18$.** Run the standardized-distance diagnostic across the ten multi-seed replicates of Table A.4 and report the distribution of the effective state count for each emission family.

### Minor Comments
- Abstract sentence "the closed-form mixture-of-eigenvalues identity for the absolute-return ACF over the non-unit eigenvalues of the transition matrix (Hamilton 1994; Krolzig 1997; Timmermann 2000)" reads as a derivation claim on first pass; recommend explicit "we apply the textbook identity of ..." framing.
- Table 1 caption is dense; consider splitting the header into a multi-line caption with the variant annotations broken out.
- $K = 21$ outperforms $K = 18$ on several rows of Table A.1 (sensitivity sweep) but $K = 18$ is the body operating point. A one-sentence justification for the $18$ vs $21$ choice would close this.
- Several tables (Tables 1, 4, A.3) carry asterisks/daggers in the row labels; please add a single legend block near the front rather than repeating the convention in every caption.
- "30-ticker panel" includes Health Care representatives that drive the OoS failure tail (LLY, UNH). Consider acknowledging that sector representativeness in the panel is itself a sampling decision; an equally weighted random draw of 30 large-caps would land at a different OoS tail.

### Recommendation
**Minor Revision.** The science is solid and the empirical study is honest. The required fixes are presentational (held-out-clean cross-ticker headline, abstract framing of the identity, title scoping) plus one paragraph on the practical-identifiability question.

---

## Reviewer 2 (Hard): Financial Econometrics / Statistical-Testing Methodologist

### Summary
The paper proposes a CHMM-based synthetic-data generator with a unified ECM scaffold over four emission families and benchmarks it against a panel of conditional-volatility, regime-switching, deep-generative, and stochastic-volatility competitors on SPY plus a 30-ticker generalisation. The methodology is competent and the appendix material is unusually thorough, but several methodological choices need stronger justification, the comparison panel has a couple of structural weaknesses, and the $K = 18$ "sensitivity reference" frame is doing more headline work than the held-out-clean text claims.

### Strengths
1. **Multi-objective metric panel.** §3.5 and Tables 1, A.1, A.3 evaluate KS, AD, kurtosis, $|G_t|$/raw-$G_t$ ACF-MAE, $W_1$, Hellinger, and CRPS in parallel. This is the right multi-axis evaluation for a synthetic-data generator and avoids the common mistake of optimizing a single proper score.
2. **Block-bootstrap KS recalibration.** §B.2 is a real contribution. The asymptotic two-sample KS is mildly lenient on volatility-clustering generators with the wrong marginal, and the block-aware recalibration sharpens the GARCH(1,1)-vs-CHMM ordering ($26.8\% \to 6.8$-$17.4\%$ for GARCH; $94.8\% \to 81$-$92\%$ for CHMM-N). The CHMM family's modest block-bootstrap penalty is a substantive defense against the "your KS is inflated by within-window dependence" objection.
3. **KS power calibration.** Table B.1 anchors the OoS pass rate against the right two ceilings (100% on $R_{\text{OoS}}$ resamples; 90% on $R_{\text{IS}}$ resamples). This makes the $76$-$86\%$ OoS pass rates interpretable.
4. **ECM monotonicity, identifiability, MLE consistency** are stated as Propositions 1-3 with the right citations (Wu 1983; Meng-Rubin 1993; Allman-Matias-Rhodes 2009; Bickel-Ritov-Rydén 1998; Douc-Moulines-Rydén 2004). This is the bare minimum for a methodology paper but it is done correctly here, which is unfortunately not the default.

### Weaknesses
1. **The MS-GARCH baseline panel is fit by grid-initialised Nelder-Mead in a repo-native implementation, not by a standard estimator.** §B.5 reports MS-GARCH at $K \in \{2, 3, 4, 6\}$ plateauing at $27$-$37\%$ IS KS, with the paper concluding the multi-state benefit is "specific to the CHMM scaffold rather than to multi-state regime-switching per se". This is a load-bearing claim and a Nelder-Mead grid-init implementation is not a fair MS-GARCH baseline. The standard reference implementation is the **MSGARCH** R package (Ardia et al. 2019, JSS), which uses a constrained-Bayesian estimator with proper-prior regularisation. Recommend re-running the MS-GARCH rows under that estimator (or a comparable Python/Julia equivalent), or softening the conclusion to "in our re-implementation, MS-GARCH does not close the gap; we have not exhausted the MS-GARCH literature here."
2. **The QuantGAN row is a self-acknowledged strawman.** §B.4 documents that the implementation is a three-conv-layer convolutional WGAN, materially smaller than the seven-block TCN of Wiese et al. (2020) with Lambert-W input pre-processing that "the original authors credit with most of the tail-fidelity". The row hits 0% IS/OoS KS and the paper labels it "the panel's deep-generative negative control rather than a verdict on the WGAN literature". I appreciate the honesty, but a 0% row in the comparison table is going to be read as a competitive defeat regardless of the caveat. Either drop the QuantGAN row entirely (and replace with a "deep generative excluded; see appendix B.4 for caveats"), or retrain with the original Wiese et al. architecture on the same window.
3. **The IS KS pass rate is computed on simulated paths tested against the same observed series the model was fit to.** This is standard but it is also the in-sample equivalent of evaluating a regression's $R^2$ on its training set. The OoS pass rate and walk-forward median are the substantive numbers. I would prefer to see the abstract lead with the walk-forward median ($67.7\%$ at $K = 18$, $62.1\%$ at $K^\star = 3$) rather than the single-window IS/OoS pair, since the single-window OoS happens to sit at the upper end of the walk-forward distribution. The current framing makes the headline number look sharper than the walk-forward distribution supports.
4. **The Christoffersen-cc test at $\alpha = 0.01$ on $T_{\text{OoS}} = 572$ has weak power.** §4.6 and Appendix B.7 acknowledge the test reaches $\ge 80\%$ power only at breach-clustering eigenvalues $\rho \ge 0.50$ at $\alpha = 0.01$, against $\rho \ge 0.20$ at $\alpha = 0.05$. The "passes Christoffersen-cc cleanly at every $(K, \alpha)$" headline therefore reads stronger than the underlying test power supports for the $\alpha = 0.01$ rows. Recommend a second sentence in the body (not just the appendix) clarifying that the $\alpha = 0.01$ pass is conditional on the breach-clustering eigenvalue being $\rho \le 0.50$, with the actual confidence interval.
5. **The Kendall's-$\tau$ inversion $\rho_{ij} = \sin(\pi \tau_{ij}/2)$ is exact for the Gaussian copula but only approximately valid for the Student-t copula.** §3.4 cites Embrechts-Lindskog-McNeil 2002 and McNeil-Frey-Embrechts 2015, which is fine, but the resulting $\hat\Sigma$ is symmetric-not-PSD and is projected by clipping eigenvalues to $10^{-8}$ (§C.1). At $d = 6$ this is probably benign; at $d = 30$ it could distort the Student-t MLE non-trivially. Either run the full-MLE Student-t copula on the six-asset universe and verify the $\nu^\star = 6$ choice is stable, or scope the copula claim to $d = 6$ explicitly.
6. **The cross-asset OoS off-diagonal MAE rises from 0.027 IS to 0.209 OoS, an 8x deterioration; quarterly refit reduces to 0.185.** The IS fit is sharp (Student-t $0.027$ vs Gaussian $0.030$ vs SIM $0.076$), but on OoS the Gaussian and Student-t copulas are statistically indistinguishable. The headline "$\nu^\star = 6$ excludes the Gaussian limit" is therefore an IS claim; on OoS the dependence-model choice is inert. The discussion should frame this honestly: the copula choice matters at IS calibration, not at OoS deployment.
7. **Practical identifiability at $K = 18$ is acknowledged (§5) but the implications for the reported standard errors are not.** If 11/18 CHMM-N states are effectively identifiable, the parameter count for AIC/BIC at $K = 18$ is wrong (it credits 18 state-specific $(\mu_k, \sigma_k)$ pairs and an $18 \times 18$ transition matrix), and the spectral diagnostic (§3.3) on the deflated $\hat{\mathbf T}$ is conditional on the effective state count, not the nominal 18. The paper says rank$(\hat{\mathbf T} - \mathbf 1\bar{\boldsymbol\pi}^\top) = 17$ at numerical tolerance $10^{-10}$ (Table A.5), but at the practical-identifiability tolerance the effective rank is closer to 10. This is worth a paragraph.

### Questions for Authors
1. Does the block-bootstrap recalibration in Table B.2 hold up on the OoS window? The asymptotic OoS ordering is CHMM-t $\approx$ GARCH(1,1)-$t$ at $80$-$86\%$; what does block-aware OoS look like?
2. The Wilks 95% profile-LL CI for $\nu^\star$ is $[6, 7]$ on the unit-spaced grid (Appendix C.1); the parametric bootstrap CI confirms $[6, 7]$. What is the parametric bootstrap CI under the **full** Student-t copula MLE (not the Kendall's-$\tau$-inversion + profile-MLE-on-$\nu$ approach)? The two-step estimator may be biased toward the Gaussian limit.
3. The CHMM-t per-state $\nu_k$ ECM lower-bracket pinning at $\nu_{\min} = 2.1$ is the headline kurtosis-overshoot mechanism (§5). Why $\nu_{\min} = 2.1$ rather than $\nu_{\min} = 3$ (the standard threshold for finite kurtosis)? At $\nu_k = 2.1$ the per-state kurtosis is undefined.
4. What is the multi-seed std on the Kupiec $\text{LR}_{\text{uc}}^{1\%}$ statistic? Table A.4 reports $2.12 \pm 1.25$ for CHMM-N, which is a wide band relative to the critical value $3.841$. The single-seed $\text{LR}_{\text{uc}}^{1\%} = 1.62$ in Table 6 sits comfortably below threshold, but a one-std move in the wrong direction would put it on the boundary.

### Requested Experiments / Analyses
- **Re-run MS-GARCH at $K \in \{2, 3, 4, 6\}$ under the MSGARCH R package (or equivalent reference implementation)** and compare to the Nelder-Mead numbers in §B.5. If the gap to CHMM persists, the conclusion strengthens; if it narrows, the body framing needs softening.
- **Block-bootstrap KS recalibration on the OoS window.** This is one extra column for Table B.2 and would address a real gap.
- **Full Student-t copula MLE (not Kendall's-$\tau$ inversion + profile MLE) on the six-asset universe.** Profile MLE on the inverted $\hat\Sigma$ is biased toward the Gaussian limit when the marginal kurtosis differs across assets; a one-shot likelihood-based check is the right control.
- **A single paragraph reconciling the practical-identifiability $K_{\text{eff}}$ with the spectral-rank claim in §3.3.** The numerical full-rank check at tolerance $10^{-10}$ does not address the practical-identifiability question.

### Minor Comments
- §3.3, Eq. (5): the symbol $w_k$ is overloaded with the EM posterior-weight $\gamma_t(k)$ in the wider paper. Consider renaming to $\omega_k$ or similar.
- Table B.2: "asymp pass\%" and "blkL\%" could be aligned; right now the percentage signs are inconsistent across the row.
- §5, paragraph "Stationarity scope and operational deployment": the citation block (Pástor-Stambaugh 2001; Andreou-Ghysels 2002; Ang-Timmermann 2012) is correct but the discussion of structural breaks is one sentence; given that 11/30 OoS failures are driven by structural breaks, this paragraph deserves expansion.
- The notation $\Phi(\cdot; \mu_k, \sigma_k)$ in Eq. (8) for the CHMM-N predictive CDF should be the family-appropriate CDF $F_k(\cdot; \boldsymbol\theta_k)$ for the body claim that the regime-conditional pass extends to all four emission families; the current $\Phi$ implies Gaussian.
- Reference [alswaidan2026hybrid] and [alswaidan2026smchmm] are 2026 self-citations. Please add a venue or "in preparation" / "submitted" marker so reviewers can verify status.

### Recommendation
**Major Revision.** The methodology is competent but the MS-GARCH and QuantGAN baselines are weaker than the body framing claims, the IS KS metric is doing more work than the OoS evidence supports, the practical-identifiability question at $K = 18$ is unresolved, and the cross-asset OoS performance does not support the dependence-model selection claim made on IS. None of this is fatal; all of it is fixable.

---

## Reviewer 3 (Very Hard): Skeptical Author of Competing Methods

### Summary
The paper claims a CHMM with quantile-initialised Baum-Welch and four interchangeable emission families is a "reference synthetic-data generator for equity returns". The claim rests on a single-window SPY headline plus a 30-ticker generalisation panel, evaluated against a panel of competitors that the authors themselves caveat (MS-GARCH "repo-native"; QuantGAN "materially smaller than the original"; SM-CHMM under a "plug-in estimator" rather than full ML; HSMM at $K = 18$ "deferred as a companion-paper extension"). The theoretical contribution is explicitly a textbook identity from Hamilton (1994) / Krolzig (1997) / Timmermann (2000) applied to the Rydén (1998) low-K instance. Stylized-fact reproduction at the daily-equity level is the evaluation suite. Given the breadth of competing methods on this problem (Bulla-Bulla 2006 ML HSMM; the Calvet-Fisher MSM family with an exact filter; modern signature-based deep generators; the rough-volatility literature), the headline "reference" claim is not supported by the evidence.

### Strengths
1. **Spectral-rank diagnostic and the per-mode panel.** Table 2 + Appendix A.5 (numerical full-rank check at $K = 18$) + the cross-ticker effective-rank panel are genuinely informative. The honesty about the cross-ticker dominant-mode share dropping to a median of $0.76$ (versus $0.94$ on SPY) is exactly the kind of caveating the field needs more of.
2. **Walk-forward + 24-row conditional-VaR table.** Table A.7 is the most informative single artifact in the manuscript. The decision to publish W2 (COVID) and W4 (rate-hike) failures rather than restrict the back-test to "stable" windows is the right one.
3. **Honest non-equity stress test.** The GLD/SLV failure to 0% OoS KS in §sec:non_us_asset_supp is the kind of negative result authors usually omit. Keep it.

### Weaknesses
1. **The "reference synthetic-data generator" claim is unsupported.** The empirical evaluation is daily US equities. There is no FX (which has known asymmetric tail and fat-tail-of-fat-tail structure), no commodities (the GLD/SLV row collapses entirely), no fixed-income, no intraday data, and no volatility-of-volatility evaluation. A "reference" generator on a literature that includes the rough-volatility family (Gatheral-Jaisson-Rosenbaum 2018), MSM with full filter (Calvet-Fisher 2004 do this), the Heston / SABR family on options data, and the recent diffusion-model literature on financial time series (e.g., Rasul et al. 2021, cited but not reproduced) needs to either substantially broaden the evaluation suite or scope the claim to "for daily US-equity stylized-fact reproduction". I strongly recommend the latter; the title and abstract should both reflect it.
2. **The "co-headline" ML HSMM-N at $K^\star = 3$ wins the OoS KS column at $91.0\%$.** Table 1 reports HSMM-N OoS KS 91.0% versus the best CHMM row at $85.7\%$. The authors hand-wave this in §4.3 ("HSMM wins KS at $K = 3$ but the absolute-return ACF-MAE matches the i.i.d. baseline level ... because the fitted Pareto sojourn concentrates probability mass on a single low-volatility state"). If the simplest competitor in the panel beats the proposed method on the headline distributional metric, the body framing of "CHMM as the joint-fit row" needs to engage that directly. Suggested fix: the CHMM-vs-HSMM trade-off is real and should be made the body comparison rather than buried in one paragraph; the framing should be "CHMM and HSMM are complementary" rather than "CHMM is the headline".
3. **The theoretical contribution is explicitly an application of folklore, not a new identity.** The intro and §3.3 say so directly (Hamilton 1994 §22.2; Krolzig 1997 Ch. 3; Timmermann 2000). The substantive content reduces to: "we show empirically that on SPY 2014-2024, a single non-unit eigenvalue carries 93.6% of the lag-1 ACF at $K = 18$, so the rank bound is non-binding". The cross-ticker median is 0.76. This is a useful empirical observation but it does not constitute a methodological contribution; the theoretical apparatus in §3.3 over-states the novelty by structuring the section as if it were deriving the identity rather than applying it. This is a venue-fit question: at *Journal of Financial Econometrics* or *Quantitative Finance* the contribution may suffice (the empirical study is solid), but a top-tier venue (*JoF*, *RFS*) needs more.
4. **The QuantGAN comparison is a strawman (admitted by authors).** §B.4 says the implementation is "a repo-native approximation ... materially smaller than the original temporal convolutional network of Wiese et al. (2020) ... plus Lambert-W input pre-processing that the original authors credit with most of the tail-fidelity". A 0%-pass-rate row against a method whose original implementation is known to work is not a valid baseline. Either drop the row or run the actual Wiese et al. architecture. The claim that "GAN-based generators fail volatility-clustering tests" is supported only at the level of *this implementation*, not at the level of the WGAN literature.
5. **MS-GARCH at $K \in \{2, 3, 4, 6\}$ in §B.5 is fit by Nelder-Mead grid-init in a repo-native implementation.** Same complaint as Reviewer 2. The MSGARCH R package (Ardia-Bluteau-Boudt-Catania-Trottier 2019, *Journal of Statistical Software*) is the standard reference. The conclusion that "the multi-state benefit is specific to the CHMM scaffold rather than to multi-state regime-switching per se" is a strong claim that requires a strong baseline.
6. **No leverage-effect, asymmetric-volatility, or skewness diagnostic.** The Cont (2001) stylized facts list also includes negative skewness, the leverage effect (negative correlation between returns and future absolute returns), and gain-loss asymmetry. The paper evaluates only three (heavy tails, no linear ACF, slow $|G_t|$ ACF). A CHMM with symmetric per-state emissions (Gaussian, Laplace, GED, symmetric-t) cannot reproduce the leverage effect by construction. This is a known limitation of symmetric-emission HMMs and should be evaluated explicitly: report the empirical leverage correlation $\text{Corr}(G_t, |G_{t+1}|)$ for SPY and for each generator. If CHMM matches GARCH(1,1)-Gaussian on this axis (both should fail), say so.
7. **The KS-pass-rate metric is sensitive to the OoS window length.** $T_{\text{OoS}} = 572$ for SPY. The walk-forward median KS is 67.7% across six folds; the single-window OoS sits at 78.3%. The ranking of generators on a single OoS window is not stable across the walk-forward folds: GARCH(1,1) beats CHMM-N on KS in W4. The headline "CHMM achieves $76$-$79\%$ OoS KS" reads more confidently than the walk-forward distribution supports.

### Questions for Authors
1. Why is the appropriate competitor not Bulla-Bulla (2006) ML HSMM at $K = 3$ on daily data, with the proper Yu (2010) explicit-duration forward-backward? The paper has the ML HSMM-N at $K^\star = 3$ in Table 1 winning on OoS KS, and admits the $K = 18$ extension "collapses to a near-degenerate optimum". The natural read is that the right method on this dataset is ML HSMM at low $K$, not CHMM at $K \in \{6, 18\}$. What's the argument against?
2. Why no rough-volatility comparator? The Gatheral-Jaisson-Rosenbaum (2018) rough Bergomi family is the dominant single-asset volatility model in the post-2020 literature and reproduces the slow $|G_t|$ ACF and heavy-tailed marginals. A direct comparison would be load-bearing.
3. The IS observed kurtosis is $7.68$ and the OoS observed kurtosis is $5.29$, a 31% drop. The headline "CHMM-N matches OoS kurtosis $5.29$ within $0.03$" is a per-window match, not a generator-property match. Across the walk-forward, simulated kurtosis is $2.4$-$6.8$ (Table A.2) versus realised in $2.5$-$5.7$. What is the across-fold correlation between simulated and realised kurtosis? If it is low, the "match" is incidental.
4. The dependence-layer choice (§4.5): on OoS, the Gaussian and Student-t copulas are within $0.007$ off-diagonal MAE on six assets. Why is the body still claiming a Student-t copula when the OoS evidence is null?
5. The penalised CHMM-t at $\lambda = 20$ is held-out-clean by the authors' own definition (§5). The unpenalised CHMM-t IS kurtosis is $14.4$, which the authors say is a "single-state ECM lower-bracket pinning artefact". What does the paper look like if you simply set $\nu_{\min} = 4$ (finite kurtosis bound) instead of $\nu_{\min} = 2.1$ + $\lambda = 20$ exponential prior? The penalty is doing the work of a more sensible bracket.

### Requested Experiments / Analyses
- **An ML HSMM at $K = 18$** (Yu 2010 explicit-duration forward-backward, AIC-selected per-state Pareto sojourn) on the same SPY window, in the body. The plug-in estimator in §B.5 is not a valid HSMM baseline by the authors' own caveat; the paper's strongest result (HSMM-N $K^\star = 3$ winning OoS) demands a higher-$K$ comparator.
- **A leverage-effect column** in Table 1: report $\text{Corr}(G_t, |G_{t+1}|)$ for observed and each generator, IS and OoS.
- **A re-run of MS-GARCH and QuantGAN under reference implementations** (MSGARCH R package; full Wiese et al. 2020 TCN architecture). If the gap closes, the body framing changes; if it persists, the claim strengthens.
- **A walk-forward distribution as the primary headline metric**, not the single-window OoS. The single window is in the right tail of the walk-forward distribution; the median (67.7%) is the honest summary.

### Minor Comments
- The title "reference synthetic-data generator for equity returns" should be scoped to "for daily US-equity-return stylized facts" or similar.
- The 30-ticker panel is described as "sector-balanced" but is "10 GICS sectors x 3 large-cap representatives". A random-draw or capitalisation-weighted panel would generalise more cleanly; the current sample-design decision is itself a confounder.
- §B.4: dropping the QuantGAN row (or replacing with the original Wiese et al. architecture) would strengthen the paper.
- Several appendix sub-results (Tables A.10 per-ticker $\hat\lambda^\star$; A.4 multi-seed; per_family_kurt) should be cross-referenced more aggressively in the body; right now they feel like backup material that does not enter the headline interpretation.
- The Manifest.toml + global seed policy (§A.1) is an exemplary reproducibility setup; consider promoting this to a bullet in the abstract or methods, as it differentiates the paper.

### Recommendation
**Major Revision.** The empirical study is honest and the appendix material is unusually thorough, but the "reference generator" framing is not supported by the evaluation suite, the strongest competitor (ML HSMM at $K = 3$) wins the headline OoS KS column and is not properly engaged in the body, and three of the four major baselines (MS-GARCH, QuantGAN, SM-CHMM) are admitted strawmen. Either the framing is rescoped to "a competitive synthetic-data generator on daily US-equity stylized facts, with explicit comparison to ML HSMM at low $K$" (which I would accept), or the empirical study is broadened (rough volatility, ML HSMM at higher $K$, FX/commodities, leverage effect) to support the broader claim.

---

## Summary of Actionable Items (Consolidated, Deduplicated, Prioritised)

### P0 (Must address; raised by 2+ reviewers)

1. **Promote the held-out-clean cross-ticker rebuild ($K^\star = 6$) to the body.** Move the $K = 18$ panel to appendix. (R1, R2)
2. **Re-run MS-GARCH at $K \in \{2, 3, 4, 6\}$ under a reference implementation** (MSGARCH R package or equivalent). Either confirm or soften the conclusion that "the multi-state benefit is specific to the CHMM scaffold". (R2, R3)
3. **Drop the QuantGAN row or re-run with the original Wiese et al. (2020) TCN architecture.** A 0%-pass-rate row from a self-acknowledged smaller re-implementation is not a valid deep-generative baseline. (R2, R3)
4. **Reframe the title and abstract from "reference synthetic-data generator" to a scope-explicit version.** "for daily US-equity stylized-fact reproduction" or similar. (R1, R3)
5. **Engage the ML HSMM-$K^\star = 3$ co-headline in the body.** It wins the OoS KS column; the current single-paragraph treatment is insufficient. Run an ML HSMM at $K = 18$ for full comparability. (R3)
6. **Walk-forward median should be the headline, not single-window OoS.** Single OoS sits in the right tail of the walk-forward distribution. (R2, R3)
7. **Add a leverage-effect / asymmetry diagnostic.** Report $\text{Corr}(G_t, |G_{t+1}|)$ for observed and each generator; if symmetric-emission CHMMs fail this stylized fact (as expected), document the limitation. (R3)

### P1 (Should address; raised by one reviewer with substantive evidence)

8. **Per-ticker $\hat\lambda^\star$ recipe for penalised CHMM-t.** Three of six body tickers are over-shrunk at the uniform $\lambda = 20$. Either publish a per-ticker procedure or restrict the headline to the heavy-tail tickers. (R1)
9. **Practical identifiability paragraph.** $K_{\text{eff}} = 11/18$ for CHMM-N, $12/18$ for CHMM-t, with 13/18 CHMM-t states pinned at the upper $\nu$ bracket. Reconcile with the spectral-rank-17 claim and the AIC/BIC parameter count. (R1, R2)
10. **Block-bootstrap KS recalibration on the OoS window.** Currently only IS. (R2)
11. **Full Student-t copula MLE on the six-asset universe** (not Kendall's-$\tau$ inversion + profile MLE). Verify $\nu^\star = 6$ is stable. (R2)
12. **Rephrase abstract framing of the spectral identity.** Currently reads as a derivation claim; should be explicit application of Hamilton (1994) / Krolzig (1997) / Timmermann (2000). (R1)
13. **Christoffersen-cc test power at $\alpha = 0.01$.** State the $\rho \le 0.50$ caveat in the body, not just the appendix. (R2)
14. **Soften the cross-asset dependence claim on OoS.** $\nu^\star = 6$ excludes the Gaussian limit on IS; on OoS the two copulas are statistically indistinguishable. (R2)

### P2 (Polish; presentational or expansion items)

15. Quantile-init vs K-means-init ablation at $K \in \{6, 18\}$. (R1)
16. Seed-stability of the effective-state count across the multi-seed replicates of Table A.4. (R1)
17. Notation: rename $w_k$ in Eq. (5) to avoid clash with EM posterior weight $\gamma_t(k)$. (R2)
18. Eq. (8) predictive CDF: replace $\Phi(\cdot; \mu_k, \sigma_k)$ with family-appropriate $F_k(\cdot; \boldsymbol\theta_k)$. (R2)
19. References: tag [alswaidan2026hybrid] and [alswaidan2026smchmm] with venue/status. (R2)
20. Multi-seed Kupiec $\text{LR}_{\text{uc}}^{1\%}$ std reporting; the $\pm 1.25$ band brackets the critical value. (R2)
21. $\nu_{\min} = 2.1$ vs $\nu_{\min} = 4$ ablation; the lower bracket has undefined per-state kurtosis and the penalty is doing bracket-correction work. (R3)
22. Cross-reference Tables A.4, A.10, and the per-family kurtosis appendix in the body more aggressively. (R3)
23. Caveat the "sector-balanced 30-ticker panel" sample design as one decision among many. (R1, R3)
24. Title/abstract scoping language for "reference" claim. (R1, R3, also P0 #4 above)

### Recommendations summary

| Reviewer | Recommendation |
| --- | --- |
| R1 (Moderate) | Minor Revision |
| R2 (Hard) | Major Revision |
| R3 (Very Hard) | Major Revision |

**Editor-style read:** Major Revision. The science is sound and the empirical study is honest, but the headline framing (title, abstract, choice of body operating points, choice of baselines) outruns the evidence in three places that need to be tightened: the "reference" claim, the strength of the comparison panel (MS-GARCH, QuantGAN, ML HSMM at higher $K$), and the practical-identifiability question at $K = 18$. None of the issues are fatal; the paper has a clear path to acceptance after addressing the P0 items.
