# Plan: arXiv preprint + ICAIF ACM submission

Goal: ship two artifacts from the current manuscript without a full journal-revision cycle.

1. **arXiv preprint (near-term).** Post the existing manuscript with a compliant abstract and the cheapest set of framing / rigor fixes from the simulated peer review. No new data. Minimal new experiments (one ablation, one significance correction, one row promotion).
2. **ICAIF ACM conference paper (medium-term).** A focused 8-9 page subset of the arXiv version, scoped to the strongest angle for an AI-in-finance audience. Keeps the empirical scaffold; drops appendix-heavy material that does not fit the page budget.

The simulated peer review (`peer-review.md`) lists 28 actionable items across four tiers. We address only the items that (a) materially change the paper's claims, (b) are cheap given existing infrastructure, or (c) are required by venue guidelines. The rest is logged here as deferred to a journal-revision pass.

---

## arXiv constraints

- **Abstract limit: 1920 characters.** The current abstract (paper.tex lines 117-122) is ~5,000 characters across four dense paragraphs. It must be cut to roughly 300 words / 1900 characters.
- Plain-prose preferred; basic LaTeX math allowed but should not dominate.
- No license issues with our content.

## ICAIF ACM constraints

- Page limit (recent ICAIF: 8-9 pages + references in ACM sigconf format).
- Audience: AI / ML in finance practitioners and academics. Less tolerance for heavy probability-theory derivations; more tolerance for empirical depth and operational claims.
- Reproducibility valued (we have a public Julia reproducer, which is a strength).

---

## What to implement (and what to skip)

### Implement before arXiv post

These are cheap, address the most pressing reviewer points, and improve the paper materially.

1. **Trim the abstract to <= 1900 characters.** Lead with the held-out-clean $K^\star = 6$ headline and the walk-forward-median caveat. Move detailed numeric tables out of the abstract. Keep one sentence each on cross-ticker, copula, conditional VaR, and limitations. Drop the parenthetical citations (Hamilton 1994 etc.) from the abstract and keep them in the introduction.
2. **Rewrite the abstract framing on ML HSMM (R1 + R3 consensus).** The strongest single-window OoS KS row is ML HSMM-N at $K^\star = 3$, not CHMM. The abstract should say "CHMM and ML HSMM are complementary scaffolds with KS / ACF / kurtosis trade-offs that select between them by use case", instead of leading with the CHMM-only KS numbers. This is a one-paragraph rewrite, no new data.
3. **CHMM-t $\nu_{\min} = 4$ ablation (R1 + R2 consensus).** Re-run CHMM-t at $K = 18$ with $\nu_{\min} = 4$, no penalty. Add the row to Table 2. If the resulting kurtosis lands inside the bootstrap CI of observed (likely), demote the unpenalized $\nu_{\min} = 2.1$ row to an appendix with a one-line footnote that the wider bracket was a bracket-choice artefact. Keep the penalized $\lambda = 20$ row as the IS-calibrated heavy-tail entry. The Julia code already supports per-state $\nu_k$ brackets; this is a parameter change, not an architectural change.
4. **Multiple-testing correction on the Christoffersen-cc panel (R2).** Apply Benjamini-Hochberg to the $\sim 48$ Christoffersen-cc tests across Tables `cond_var`, `cond_var_all_families`, and `walkforward_cond_var`. Report the BH-corrected joint pass rate in the body of `var_backtest.tex`. This is a one-page Julia / Python script over existing p-values.
5. **Promote TCN-architecture QuantGAN row from Appendix `quantgan_tcn` into Table 2 (R3).** The 3-conv-layer baseline already in the body is the authors' own admitted negative control. The TCN rebuild row exists in the appendix and is the right deep-generative comparator. This is a row move, not new compute.
6. **Add a bootstrap-as-synthetic-data-generator framing paragraph in Section 4 (R3).** The bootstrap row already in Table 2 (99.7\% IS / 92.1\% OoS KS) is on par with the best CHMM operating point on the headline metric. Rather than framing it as a "non-parametric distributional ceiling", explicitly compare CHMM-vs-bootstrap on each abstract use case (privacy / licensing / parametric-controlled stress). State the conclusion: "Bootstrap dominates CHMM on raw OoS KS at this OoS sample size; CHMM dominates on parametric controllability and on the structural use cases the bootstrap cannot serve". One paragraph, no new compute.
7. **Acknowledge the cross-ticker dominant-mode minimum (33\% on NEM) in the abstract spectral-rank sentence (R3).** Replace "the rank constraint is non-binding at $K \ge 3$" with "the rank constraint is non-binding at the cross-ticker median ($75.6\%$ dominant-mode share) but binding at the cross-ticker minimum ($32.6\%$ on NEM)." One sentence.

### Implement only if time permits before arXiv

8. **OoS block-aware KS as a side-by-side body column (R2, item 13).** The data exists in Appendix `ks_block_bootstrap_oos`; the change is presenting it next to the asymptotic OoS KS in Table 2. Adds two columns to the headline table.
9. **Move full one-shot $(\Sigma, \nu)$ Student-$t$ copula MLE result into the body (R2, item 11).** The data exists in Appendix `full_tcopula_mle`. One sentence in Section 4 stating $\hat\nu_{\text{full}} = 6.40$ vs $\hat\nu_{\text{two-step}} = 6.00$ confirms the body $\nu^\star$ is robust.
10. **Per-asset failure-count reporting in the cross-asset table (R3, item 17).** Add a "$2/6$ assets fail OoS KS" footnote to Table 4. One footnote.

### Skip for arXiv (defer to journal revision)

| Item | Reason for skipping |
|------|---------------------|
| MS-GARCH `MSGARCH` R-package re-run (R1 + R2 Tier 1) | Requires R install outside our Julia pipeline; logged as deferred control. |
| $K_{\text{eff}}$-corrected information-criterion re-rank (R2 Tier 2) | Substantive rewrite; defer to journal revision. |
| Sector-stratified random draw of 30 large-caps (R1 Tier 3) | Data-collection task. |
| Independent-decade validation 1994-2004 (R3 Tier 2) | Data unavailable on Polygon / Alpaca; documented in `alpaca_depth_probe`. |
| Random-init Rydén replication at $K = 3$ (R3 Tier 2) | Defer; $K = 2$ replication already in body. |
| Initialization-robustness sweep at $K \in \{6, 18\}$ (R1 Tier 2) | Defer; would add another supplementary table. |
| Conditional-VaR with quarterly-refit forward filter (R2 Tier 2) | Substantive; defer. |
| Per-ticker $\hat\lambda^\star$ rule across cross-ticker panel (R1 Tier 3) | Already documented as the production recipe; full-panel rerun defer. |
| Bootstrap-CI mid-point as kurtosis target (R1 Tier 3) | Cosmetic reframe; defer. |
| NEM diagnostic at $K \in \{3, 6, 18\}$ (R3 Tier 2) | Defer; one-ticker followup. |

---

## ICAIF focused-version scope

ICAIF rewards a clean operational story over an exhaustive empirical sweep. Two viable angles for the focused submission. We pick **(A)** as the primary candidate and keep **(B)** as a fallback.

### Angle (A): "Regime-conditional VaR via a unified four-emission CHMM scaffold" (recommended)

This is the most operationally compelling subset. The Christoffersen-cc construction is the headline; the four-emission-family panel is the architectural contribution; SPY plus the 30-ticker generalisation is the empirical evidence.

**Keep:** Sections 1 (introduction trimmed), 2 (model + estimation, theory cut to a half-page corollary), 4 (results: SPY headline + walk-forward + conditional VaR), 5 (discussion trimmed).

**Cut for ICAIF page budget:** Section 2 spectral-mechanism proof (move to a one-paragraph statement plus arXiv reference); Section 4 cross-asset copula (entire Pipeline B); the Rydén replication; the leverage-effect diagnostic; the $K_{\text{eff}}$ paragraph; baseline-implementation caveats. Most appendices not referenced by the kept sections are dropped.

**Title candidate:** *Regime-conditional Value-at-Risk for daily US equities: a four-emission continuous HMM under unified ECM.*

### Angle (B): "Synthetic-data generator for daily equity returns" (fallback)

This is closer to the current paper's framing but tighter. The headline is the four-emission-family stylized-fact panel and the walk-forward median; the conditional VaR is one of several diagnostics, not the centerpiece.

**Keep:** stylized facts, KS pass rates, walk-forward median, four-emission panel, cross-ticker panel.

**Cut:** Conditional VaR (or compress to one paragraph), copula (entire Pipeline B), spectral derivation, leverage effect, much of the appendix material.

**Title candidate:** *A four-emission continuous HMM scaffold reproduces three Cont stylized facts on daily US equity returns.*

We commit to (A) unless the user indicates otherwise. (A) is the stronger empirical contribution per page; (B) competes more directly with established generative-model papers and is harder to differentiate at the ICAIF page budget.

---

## Concrete TODO list (ordered)

### Phase 1: arXiv post

- [ ] **(P1.1)** Rewrite abstract to <= 1900 characters with ML HSMM framing fix and cross-ticker minimum acknowledgement. Verify with `wc -c`.
- [ ] **(P1.2)** Run CHMM-t $\nu_{\min} = 4$ ablation in CHMM-Model repo. Add row to Table 2 in `results.tex`. Demote unpenalized $\nu_{\min} = 2.1$ row to appendix.
- [ ] **(P1.3)** BH correction script over the $\sim 48$ Christoffersen-cc p-values. Add a one-paragraph result to `var_backtest.tex` reporting the BH-corrected joint pass rate.
- [ ] **(P1.4)** Promote TCN QuantGAN row from Appendix `quantgan_tcn` into Table 2.
- [ ] **(P1.5)** Add bootstrap-vs-CHMM use-case paragraph to Section 4.
- [ ] **(P1.6)** Final pass: spell-check, em-dash check (project rule: no `---` in prose), citation check, build paper.pdf.
- [ ] **(P1.7)** Tag arXiv version in CHMM-paper repo; submit to arXiv (q-fin.ST or stat.AP primary).

### Phase 2: ICAIF submission

- [ ] **(P2.1)** Decide angle (A) vs (B) with user.
- [ ] **(P2.2)** Branch `icaif-conf` from arXiv-tag commit. Create new top-level `icaif.tex` from ACM sigconf template.
- [ ] **(P2.3)** Port kept sections; cut dropped sections per angle decision. Compress appendices to a single ~1-page consolidated supplement (or move to arXiv version reference).
- [ ] **(P2.4)** Verify page budget under ACM sigconf format. Iterate if over.
- [ ] **(P2.5)** Address ICAIF-specific reviewer-anticipation: emphasise reproducibility (Julia package), explicit operational deployment recipe, and the walk-forward-median honest-headline framing.
- [ ] **(P2.6)** Submit to ICAIF on track deadline.

### Phase 3 (optional, post-ICAIF): journal revision

If we target a journal afterwards, the deferred items in the skip table become the revision agenda. The MS-GARCH R re-run and the $K_{\text{eff}}$-corrected IC are the two highest-priority deferred items.

---

## Risks and watch items

- **CHMM-t $\nu_{\min} = 4$ ablation may degrade IS KS materially.** The unpenalized run pinned to $\nu_{\min} = 2.1$ for a reason: at $\nu_{\min} = 4$, the EM may push some states to upper-bracket pinning instead. If so, the row should be reported with both bracket choices and a brief discussion, not as a clean replacement.
- **The BH correction may flip one or two of the 48 Christoffersen rows from "pass" to "fail at corrected level".** This is a real risk and we should report whatever the corrected result is, not pre-decide.
- **arXiv abstract trim has to keep the limitation statements** (cross-ticker $11/30$ failures, OoS Gaussian-vs-t copula indistinguishability, GLD/SLV non-equity scope failure). These are exactly the items the simulated reviewers approved of; cutting them to fit the character budget would be a net negative.
