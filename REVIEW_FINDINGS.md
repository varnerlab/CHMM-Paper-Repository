# Full-paper review findings — 2026-06-11 (/review-section, all sections + abstract, verified against varnerlab/CHMM-Model clone)

> **STATUS 2026-06-11 (second pass): ALL FINDINGS FIXED AND VERIFIED.** The first fix pass left ~10 broken doubled-text replacements ("the main text main", leftover "Body" tokens) and ~15 skipped items; a second pass closed every CRITICAL/IMPORTANT/SUGGESTED item below, plus the knock-ons: cross-asset presentation relabeled to the checked-in K=3 run throughout (abstract SIM 0.077, Gaussian OoS 0.204, gap 0.005), Laplace scale standardized to b_k, supplementary theorem weight renamed a_k, GED partition counts reconciled (11 at p=3.0 / 13 Gaussian-like / 1 at 1.6 / 4 Laplace), scholz1987ksample added to the bib. Verified: clean pdflatex+bibtex build (67 pp, 0 undefined refs/cites), all detection greps clean (body/headline/operating point/scaffold/recipe, \ref{sec:}, doubled text, itemize, positional pointers, untilded \citep, straight quotes, em dashes), abstract 243 words.

TLDR: Main body (intro, related work, methods, theory, results, discussion, conclusion) is nearly clean — the earlier sweeps worked. The supplement was never swept: 11 hard `\ref{sec:...}` pointers, ~135 "body" tokens, 32 "headline", 23 "operating point", 9 "scaffold", one `itemize`, one leftover "Pipeline B" caption, five doubled-text broken edits ("The body the body …") that render in the PDF, and systematic present-tense findings. Code verification found ~25 prose-vs-artifact mismatches. Good news: the CRSP cross-decade run is real (runner + results + 5.7 MB CRSP csv checked into the code repo; every number matches).

## CRITICAL

### 1. Section self-references (zero tolerance) — hard refs, all 11
| file:line | offending | fix |
|---|---|---|
| cross_asset_appendix.tex:79 | `Section~\ref{sec:cvine_supp}` | end sentence at `Table~\ref{tab:cross_asset_supp_summary}`; drop the C-vine pointer |
| baselines_appendix.tex:113 | `(Appendix~\ref{sec:quantgan_supp})` | drop — the QuantGAN construction is the preceding subsubsection |
| sensitivity_appendix.tex:10 | `Appendix~\ref{sec:cross_ticker_k6_panel}` | state K-robust pattern directly, cite `(Table~\ref{tab:cross_ticker})` |
| sensitivity_appendix.tex:102 | `Appendix~\ref{sec:sensitivity_table}` | "the companion K-sweep artefact in the code repository" |
| sensitivity_appendix.tex:107 | `Appendix~\ref{sec:spectral_rank}` | "(Table~\ref{tab:spectral_rank})" |
| sensitivity_appendix.tex:121 | table row `SPY (body Appendix~\ref{sec:spectral_rank})` | `SPY (Table~\ref{tab:spectral_rank})` |
| sensitivity_appendix.tex:139 | `Appendix~\ref{sec:k_selection_kfold_pre2020}` | "per the pre-2020 k-fold cross-validation" |
| sensitivity_appendix.tex:197 | caption `Appendix~\ref{sec:supp_misc}` | "consistent with the rate-sweep value 8.43 at λ=20" |
| sensitivity_appendix.tex:283 | `Appendix~\ref{sec:christoffersen_power}` | "(Table~\ref{tab:christoffersen_power})" |
| sensitivity_appendix.tex:377 | `(Appendix~\ref{sec:supp_robustness})` | "and across the cross-asset universe" |
| sensitivity_appendix.tex:467 | `Appendix~\ref{sec:chmm_t_shared_nu}` | "the shared-ν fit (Table~\ref{tab:chmm_t_shared_nu})" |

Main body + paper.tex: **zero** hits (both detection greps clean).

### 2. Broken doubled-text edits (render in PDF — fix first)
- metrics_appendix.tex:67 "The body the body VaR back-test reports…" → "The main text reports only the unconditional Kupiec LR_uc statistic~\citep{kupiec1995techniques}."
- cross_asset_appendix.tex:116 "The body the body cross-asset analysis reports… . the body discussion attributes" (also lowercase sentence start) → "The static IS fit gave OoS off-diagonal MAE 0.209 against IS 0.027 (Table~\ref{tab:cross_asset}). We attributed the gap to the stationarity-scope limit…"
- sensitivity_appendix.tex:4 "consistent with the spectral mechanism of the body spectral mechanism" → "consistent with the single-dominant-mode spectral mechanism"
- sensitivity_appendix.tex:73 "The body the body spectral mechanism states…" → "The main text states the algebraic upper bound:…"
- sensitivity_appendix.tex:347 "the substantive reading for the body the body cross-ticker analysis…" → rewrite per agent fix (drop both)

### 3. Soft self-pointers ("the body X", above/below) — exhaustive line lists
- metrics_appendix.tex: 1, 48, 60, 62(×2), 64(heading), 67, 113(×2), 138(caption ×2)
- algorithms_appendix.tex: 2 ("of the Methods"), 47, 222, 244
- cross_asset_appendix.tex: 4(×2), 33, 40, 65, 78, 116, 153, 156, 159; positional: 197 "reported above"
- baselines_appendix.tex: 5 ("main-body"), 57, 80(heading "Body operating-point summary"), 81(×2), 86(caption), 125 ("construction above", "rows below"), 175(×2), 234, 239(caption), 245(row "Two-step (body construction)"), 251(row); positional: 113 "are below…further down"; 127 cataphoric "Three structural observations follow."; commented banned vocab at 102-103
- supplementary.tex: 1(×2), 17, 31, 58(×4 + "binding axis"), 84, 117, 144, 159(×2), 172, 176, 179, 182, 210, 246, 247, 287, 290; positional: 162 "slice above", 166 "result above", 312 "in Methods", 332 "Referenced from the discussion…" (delete)
- sensitivity_appendix.tex: 4, 9(×2), 10(×3), 16, 68(×3), 73, 78, 102(×3), 121, 126, 133(×2), 139(×2), 141, 165(×3), 169, 187, 197(×2), 213(×6), 218, 252(×3), 263, 283(×4), 285-287(comment — delete), 292, 316, 321(×3), 326, 343(×2), 347(×4), 377, 396, 442, 464(×3), 467(×4), 472, 474, 479(×2), 492(row "Body window:"), 501, 503(×2), 505(×7)

Replacement policy: name the table (`Table~\ref{tab:model_comparison}`), name the choice ("the $K^\star=3$ default", "the main-text λ=20 choice"), or "the main text" sparingly. "headline" → "main"; "operating point" → "state count"/"$K$"/"default"; "scaffold" → drop or "framework"/"estimator"; "recipe"/"Production reading… consumers should deploy" → plain recommendation ("In practice the three state resolutions are interchangeable on KS; $K=18$ gives the best kurtosis fidelity; $K^\star=3$ remains the default."). Vocab counts: body 135 / headline 32 / operating point 23 / scaffold 9 / recipe 2 — all in supplement files only.

### 4. Other mechanical criticals
- **itemize**: sensitivity_appendix.tex:248-251 → prose: "Power was asymmetric across α. At α=0.05 (~28.6 expected breaches), Christoffersen-cc reached 80% power against ρ≥0.20 (83.9%) and essentially full power at ρ=0.50. At α=0.01 (~5.7 expected breaches) it reached 80% power only at ρ≥0.50 (81.5%); at ρ=0.20 the rejection rate was 42.6%."
- **Pipeline framing**: cross_asset_appendix.tex:170 caption "(Pipeline B, …)" → "(multi-asset construction; Student-t copula on CHMM-N marginals…)" (line-104 caption already uses the correct form)
- **External structure numbers in cites**: theory.tex:3 ("§22.2; Ch.~3"); supplementary.tex:58 ("Section~22.2; Chapter~3"); supplementary.tex:42 ("\citet{lindsay1995mixture}, Chapter~3"); supplementary.tex:47 ("\citet{bickel1998asymptotic} (Theorem~1)"); sensitivity:257 hand-typed "(2004, JBES)" → cite works whole
- **Soft lists**: baselines:28/30/32 "For (i)/(ii)" → "To address the dependence concern… / To address the binarisation concern…"; methods.tex:100 "The first is… The second is… The third is…" → make the metrics the subjects
- **Ref-as-subject**: methods:18 (Assumption ref); algorithms:41, 75 ("Proposition states…"), 78 ("Algorithm 1 is…"), 225 ("Figure plots…"); sensitivity:9, 107, 139 ("Body Table reports…"); baselines:81 ("Read together with Table…"), 198 ("The headline conclusion of Table… survives"); supplementary:312, 332 ("Table lists/summarises…")
- **Present-tense findings (C4)** — systematic in supplement: sensitivity (≈25 spots incl. 343, 377, 283, 213, 311, 316, 345, 401 + list at agent report); cross_asset (66, 111, 116, 118, 148, 153, 156, 159, 162, 165, 195); baselines (23, 30, 32, 53, 78, 108, 116, 119, 122, 125, 168, 196, 198, 229, 256); algorithms (226-227, 237, 240); metrics (113); supplementary (36, 89, 162, 168, 170, 176, 179, 182, 210, 243-245, 287). Main body: intro:5 "breaks down"→"broke down"; abstract "exceed it"→"exceeded it"; results:43 "is a per-ticker observation"→"was"; discussion:3 "does not save"→"did not save".
- **Sentence-initial acronyms**: methods:61 caption "EM alternates…"; algorithms:75 "CM-1 and CM-3 are…"; baselines:53 "CHMM-GED is…", 168 "QuantGAN is…", 196 "SV-AR(1)/MSM…"; sensitivity:213 "IS / OoS KS pass rates…", 377 "CHMM-GED carries…"; supplementary:162 "AIC, BIC, HQC…". Borderline ticker/heading starts: cross_asset:39/41/155/158, conclusion:1 "CHMM-L sat…".
- **Stiff connective**: metrics:113 "The headline reads as follows." → "Two patterns stand out (Table~\ref{tab:christoffersen_var})."

### 5. Prose vs. code/artifact mismatches (verify/fix before submission)
| where | paper says | repo says |
|---|---|---|
| methods:100 | "stationary i.i.d. bootstrap~\cite{politis1994stationary}" | plain i.i.d. resample (Efron-style; Politis-Romano used only for block-bootstrap diagnostics) — fix cite (needs efron1979 bib entry) |
| methods:98 | t-copula "correlation optimised out at each ν" | Σ fixed via Kendall-τ (ρ=sin(πτ/2)); ν grid-searched (src/CrossAsset.jl:234-253) |
| methods:4 | "data sources described in the acknowledgments" | no acknowledgments section; it's the Data Availability Statement |
| methods:100 | paths "length T matching the fitting window" | OoS scored with OoS-length (572) paths |
| algorithms:86 | ν⁽⁰⁾ = 10 | ν_init = 6.0 |
| algorithms:26,169 | S₁ ~ Categorical(π) | S₁ from stationary distribution of fitted T̂ |
| algorithms:227 | IS mixture kurtosis 17.34 | 17.44 |
| algorithms:237 | "thirteen states at p=3.0" | eleven at exactly 3.0 (thirteen Gaussian-like ≥1.85) |
| algorithms:240 | band 12.5–15.1; heavy count {4,5} | 12.25–15.12; Laplace-like {3,4,5}, non-Gaussian constant 5/18 |
| algorithms:62,86 | μ bracket [μ̂±5α] | widened to cover data range |
| cross_asset:66 | AIC differential −30.2 vs Gaussian | wrong: 6143.37 is the ν=5 profile LL, no Gaussian-copula LL exists; penalty sign +2 — delete/recompute |
| cross_asset:71 caption | "CHMM-N marginals held fixed while ν varied" | profile uses rank-PIT pseudo-observations; marginals never enter |
| cross_asset:111 | C-vine families {Gaussian,t,Clayton,Gumbel}; 0.235 @ K=18 | code has only {Gaussian,t}; checked-in Table-T3: 0.236 @ K=3 |
| cross_asset:197 | ν*=6.5 at LL 6158.1; Gaussian 0.202 | 6158.0; checked-in 0.204 (K=3) |
| baselines:5 | negative control at T_OoS vs R_OoS | runs at T_IS vs R_IS |
| baselines:122,125 | "AIC-sojourn" selection | raw log-likelihood pick (NB vs truncated Pareto; geometric fallback) — no AIC |
| baselines:175 | "Taylor 1986 / Harvey-Ruiz-Shephard 1994" bare names | bib has taylor1982financial (year clash); no HRS entry — add harvey1994multivariate + \citep |
| sensitivity:180-182 | kurtosis-CI sd 11.5/9.0/5.6 | artifact: 74.4/13.5/16.9 (all other columns match) |
| supplementary:89 | stitch date Nov 18, 2025 | code/results: 2025-11-19 (Polygon's last day is 11-18) |
| supplementary:344 + results:102 | "Quarterly: 7/30" vs prose "8/30" | repo quarterly refit: 8/30 (7/30 is the K=18 count) — state K in both |
| supplementary:295 caption | cross-asset "K=18" KS medians 77.0/97.8/98.8/97.2 | checked-in run is K=3: 71.0/88.8/89.5/90.0 — check in the K=18 outputs or relabel (systemic; also 0.076/0.202/0.235 vs K=3 0.077/0.204/0.236, affects abstract 0.076) |
| results:45 | ν grid "[4,12] unit-spaced" | actual grid {2,3,4,5,6,8,10,15,20,30}; comparator 0.030/0.076 are the K=18-table values |
| results:43 | monthly cadence 86.7%, 5/30 "(Table stationarity_scope)" | in no paper table (only code-repo sector_panel_monthly_refit.txt, K=18) — re-anchor to tab:cross_ticker_quarterly_refit + add monthly row |
| results:36 | shared-ν ACF cell **0.0235** | CSV: 0.0236 (bold would move to penalised row 0.0235) |
| conclusion:3 | "3/24 persistent rejections"; "80.5% vs 67.7%" | 5/24 rejections (3 only at α=0.01: W2×2, W4-K18); 80.5 is K*=3 single-window vs 67.7 K=18 walk-forward — mispaired (like-for-like: 62.1 vs 67.7) |
| conclusion:12 | "package CHMM-Model.jl"; URL varnerlab/CHMM-paper | unregistered repo "CHMM-Model" (no name field in Project.toml); URL is CHMM-Paper (capital P); CRSP data not covered by availability claim |
| abstract | "four heavy-tailed emission families (Gaussian, …)" | Gaussian isn't heavy-tailed → "a Gaussian baseline plus Student-t, Laplace, and generalised-error alternatives" |
| theory:12 | K=2 ACF "ρ(τ)=λ₂^τ" | identity gives w₂λ₂^τ, w₂<1 — add the weight |

**Unverifiable (no checked-in artifact)**: supplementary:159 pre-OoS K re-selection block; supplementary:179 rate-sweep values; λ-CV at K=18; GLD static numbers (cross_asset:156); per-pair MAE file + |Δ|∈[0.04,0.19] (cross_asset:162); full t-copula MLE procedure description (baselines:234 — numbers real, implementation absent); GARCH-t ν̂=6.89 (baselines:116); "partition replicates across 10 seeds" (sensitivity:377 — multiseed artifact records headline metrics only); DM "only Gaussian significantly worse" p-table (metrics:62); split-adjustment claim (methods:4).

**CRSP cross-decade: VERIFIED** — runner, results, and crsp_1994_2006.csv all in code repo; every number matches. Memory updated.

## IMPORTANT
- **Abstract**: 324 words (>300 cap). Cuts: drop "with an Engle-Manganelli…strict-tail test" clause; compress ECM sentence.
- **Intro**: approach paragraph (line 3) only 4 sentences — split the two semicolon compounds; "two things the usual generators do not offer" is uncited AND overlaps the "In this study" closer (line 5) — keep positioning only in closer. CHMM expansion differs from abstract ("continuous-emission" vs "continuous").
- **Structure**: standalone §4 "Spectral Mechanism" (459 words) reads as methods-plus-results bridge; consider folding identity+assumptions into Methods as a closing subsection and the K-rank empirics into Empirical Study (consistent with the title trim that dropped "Spectral Rank"). Section title "Empirical Study" deviates from the "Results" convention (author's call). Float budget OK: exactly 3 main tables + architecture figure.
- **Lead sentences (numbers in leads / missing action / IS-OoS spelled out)**: results:72 ("SPY OoS" → spell out; tab:cond_var shows only 2 families not 4; ¶ is 4 sentences — merge with :102), results:102 (no-action lead; GLD + cross-decade enter cold — add half-sentence setup); theory:12 (93.6% and 0.76/0.326 in lead); sensitivity:68/187/283/316/343/464/467/501; baselines:53/196/256; cross_asset:148/156/162/197; supplementary:162/168/182 (log-lik colon-dumps → generic lead + S-table); algorithms:240.
- **Citations missing**: Politis-Romano bare-year (baselines:30, sensitivity:146); Calvet-Fisher, Merton bare-year (baselines:175,196); Bulla-Bulla (baselines:125); Yu (sensitivity:396); Allman-Matias-Rhodes (supplementary:36); Rydén (metrics:26, sensitivity:133); Christoffersen first-use (sensitivity:218, intro:5); DM (metrics:62); CRPS estimator (metrics:56); AD test (metrics:13 — needs Scholz-Stephens bib entry); Cont (related_work:1, methods:105); ECM monotonicity (methods:89); t-copula density source (cross_asset:16); "4–10 range typically reported" (cross_asset:66); "mode collapse" → cite takahashi/kwon (related_work:5, drop "axis").
- **Untilded cites**: metrics:5,29,67; algorithms:2,75; cross_asset:7,10,13,197; supplementary:21,33,42,58,77.
- **Methods gaps**: penalised CHMM-t (λ=20) never introduced though sector/cross-ticker results use it — add one clause; no software statement (add "implemented in Julia in the companion repository CHMM-Model"); vendor-stitch KS p=1.00 result is a finding duplicated in supplement — keep verdict only; "Given the model M" transition carries math; quantile-init causal claim → motivation phrasing.
- **QuantGAN placement inconsistency**: related_work:5 says "extended panel", methods:100 says appendix, but the row is in the MAIN table — reconcile all three.
- **Discussion**: "1990s random initialisations…degenerate" uncited + wording clash with methods ("overlapping"); "two to three orders of magnitude" parameter claim unsourced; closing 4-extension list duplicates conclusion:3 item-for-item — compress discussion close, let conclusion own it. Conclusion:1 GED clause duplicates discussion:1 verbatim (28 words).
- **Related work**: para 3 and 4 are 5 sentences; para 4 spans three themes — refocus on copula+evaluation, move change-point closer to Discussion; "fails the KS test" is this paper's finding presented as literature claim — re-attribute; "Finally," opener — drop.
- **Data availability**: scope vendor sentence to 2014-2026 windows; add CRSP sourcing/licensing clause (CRSP typically forbids redistribution).
- **Hyphen stacks (worst)**: "state-resolution-robust default", "kurtosis-fidelity sensitivity reference", "extended-state-resolution…", "headline-OoS regime-conditional construction", "static-fit-stale", "low-equity-correlation gold ETF", "portfolio-optimisation or tail-risk-budgeting loop", "proper-scoring-rule complement", "volatility-aware conditional-coverage comparison" — unwind per agent fixes.
- **Notation**: scalar w_k vs eigenvector **w**_k collision (theory:7, supplementary:62-67 → rename a_k/c_k); Laplace scale b_k vs β_k flip (algorithms, β collides with backward variable); Σ_cop undefined (cross_asset:195); Δ overloaded (cross_asset:162 vs 174); M(t;α,p) undefined (supplementary:42); r^(p) rank symbol undefined (supplementary:51); KS F_n/G_m/n/m prose definitions (metrics:5); algorithms figure b_{s_t} vs text f_k (methods:61).
- **Self-editing the main text from the supplement**: sensitivity:283 «the body sentence "…" should be qualified to…» → make supplement self-contained ("the α=0.01 tier should be read as power-limited rather than as a clean pass").

## SUGGESTED (compact)
- Range style: normalize "$a$-$b$" single hyphens (sensitivity:501/503, supplementary:162, dates at sensitivity:469-492) → "--" or "to"; pick one convention (recent main-body prose uses "to").
- Delete commented-out banned-vocab blocks (baselines:102-103, sensitivity:285-287).
- "The substantive read/reading is" → "The conclusion is"; "The mechanism is the obvious one" → "is direct"; "Sampling-error reads" → "checks"; "-ization/-isation" consistency (sensitivity:133); inline "Reading:" vs \paragraph{Reading.} (sensitivity:126/464); straight quotes → `` '' (baselines:23/28); "temporally-aware" → "temporally aware"; spaced slashes "complex / non-diagonalisable" → "and".
- Abstract: "slow ACF decay" → spell out autocorrelation; GED capitalisation align with intro; "passed…on the main window" → "main out-of-sample window".
- results:1 "main-paper value of K" → drop body-synonym; results:3 "six benchmark generators" → seven (or tiers); results:43 "K=18 kurtosis-match check" repeated 2×/sentence; results:72 dangling modifier + "19/24 rows at α=0.05" ambiguity (5% is the test level).
- cross_asset: "an order of magnitude larger" → ~7.7×; "Fig." vs "Figure" consistency; caption seed → "seed root 20260422"; "(panel (a) is observed)" caption precision.
- metrics headings: "ACF-MAE." / "VaR / ES Envelope" acronym-initial — optional reword; baselines:127 "Three structural observations follow." delete; baselines:122 verbless fragment merge; sensitivity:11 hardcoded results path → "the per-ticker CSV in the companion repository".

## Per-file CLEAN summary
intro/abstract: structure conforms (motivation→gap→approach→closer, no contributions ¶, no subsections); related_work: flat, no dashes; theory: symbols all defined, numerics verified; methods: C1/C7/C12 clean, no subsubsections; results: C1-C3/C12 clean, all 6 paragraph leads structurally sound except 72/102, tables match CSVs except flagged; discussion: 3 paragraphs, arc complete; conclusion: clean except number errors; appendices: hierarchy (subsection→subsubsection→paragraph) is intentional and fine.

Full per-finding rewrites live in the session agent reports (session 35f34440, agents a504…/a2ba…/a510…/a8f9…/a032…/a9a8…/a243…/aa12…/a80f…/a33d…).
