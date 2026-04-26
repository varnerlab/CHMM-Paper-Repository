# Plan: Tighten Paper for arXiv Submission

## Goal

Trim the paper to arXiv abstract limits, remove deferred/companion-work content, deduplicate code-and-repo mentions, and prune supplementary subsections that are not referenced from the main body. Anchor abstract length and framing to the Varner-group style (~250 words, ~1700 chars).

## Audit summary (from review pass)

- **Abstract:** 3,025 chars / 389 words. arXiv hard limit on the submission abstract field is 1,920 chars. Target ~1,700 chars / ~250 words.
- **Code/repo mentions in main body:** five places (abstract, intro contribution iv, model.tex closing paragraph, conclusion data-availability paragraph, supplementary `sec:supp_chmm_api`). Should collapse to one canonical mention in the data-availability paragraph plus the appendix listing.
- **Filter-VaR / regime-conditional VaR:** flagged as companion-paper work, but currently spread across `sec:filter_var_note` (var_backtest), a discussion paragraph, `sec:supp_filter_var`, and Proposition 5. Cut the body and supplementary versions; keep one sentence in conclusion future-work.
- **Stub appendix subsections:** `sec:stylized_facts_supp` is a single figure whose numerics already appear in the body; the appendix-internal "Transition Matrix Structure", "Stationary Distributions and Residence Times", "Example Simulated Trajectories" subsections are unreferenced filler with content that does not survive the body. Cut.
- **Supplementary intro paragraph:** prose table-of-contents that duplicates the section headings. Cut.
- **Cross-reference health:** body cites only five specific supplementary subsection labels (`sec:supp_robustness`, `sec:ks_power`, `sec:ks_block_bootstrap`, `sec:non_us_asset_supp`, `sec:supp_misc`) plus one supplementary table (`tab:per_pair_offdiag_mae`). Everything else is reached only through the umbrella `\ref{sec:supplementary}`. That is acceptable; the cuts below trim the unreferenced volume.

## Steps

### Step 1. Cut filter-VaR / companion-work content

- **Delete** `var_backtest.tex` lines 43–46 (the `sec:filter_var_note` subsection). Section 7 becomes Section 7 = VaR/ES envelope only, which passes cleanly.
- **Delete** the discussion paragraph at `discussion.tex` lines 35–36 ("Filter-VaR over-conservatism is an open operational question.").
- **Delete** `supplementary.tex` lines 74–85 (`sec:supp_filter_var`).
- **Delete** Proposition 5 (`prop:filter_var`) in `sec:supp_propositions` (it underwrites only the deleted filter-VaR discussion). Update the supplementary intro list of propositions to drop the filter-VaR mention.
- **Keep** the conclusion future-work sentence (already present): "operational regime-conditional VaR is a companion-paper direction."
- **Keep** the discussion limitations sentence in `discussion.tex:39`.

### Step 2. Trim the abstract

Target: ~1,700 chars / ~250 words. Cuts:

- Drop the closing "The companion Julia package CHMM-Model.jl ships as a co-equal deliverable..." sentence.
- Compress the "No single benchmark dominates..." sentence to a single short clause.
- Drop the per-variant kurtosis numbers (5.0 / 14.6 / 6.8); the introduction repeats them.
- Drop the CRPS / Diebold-Mariano clause.
- Keep: spectral identity, three-emission scaffold, headline KS / ACF numbers, VaR envelope, copula MAE.

### Step 3. Deduplicate code/repo mentions

- **Cut** the abstract sentence about CHMM-Model.jl (covered in step 2).
- **Trim** introduction contribution (iv) (`introduction.tex:9`) to a one-clause pointer at the data-availability statement, or drop it from the contributions list (now four contributions instead of five).
- **Cut** `model.tex:162` (the "mirrors the model definition above through a single CHMM type..." paragraph). The pseudocode in the appendix already covers this.
- **Keep** the `conclusion.tex:9–11` data-and-code-availability paragraph; trim "ships as a co-equal deliverable" phrasing to "the companion Julia package CHMM-Model.jl is released alongside this paper at <url>."
- **Keep** `sec:supp_chmm_api` (verbatim block); update the supplementary intro pointer to it.

### Step 4. Cut stub appendix subsections

- **Delete** `sec:stylized_facts_supp` (sensitivity_appendix.tex:1–11). Numerics are in `sec:descriptive`. The figure can be referenced from there if you want it preserved, otherwise drop.
- **Delete** the four prose-plus-figure subsections in `sensitivity_appendix.tex` lines 120–312:
  - "Emission Distributions Across State Resolutions"
  - "Transition Matrix Structure"
  - "Stationary Distributions and Residence Times"
  - "Example Simulated Trajectories (Illustrative, IS-Fitted CHMM-N)"
- **Trim** the `supplementary.tex:1` intro paragraph: cut the prose TOC; keep maybe one sentence of orientation.

### Step 5. Verify

- Recompile `paper.tex` to confirm no broken `\ref{}` after deletions.
- Recount abstract chars/words.
- Re-run the cross-reference check on supplementary labels.

## Out of scope (not done in this pass)

- The 5 unreferenced per-asset price-fan figures in `baselines_appendix.tex` (`fig:price_fan_*`). They serve as asset-coverage evidence; defer the cut decision.
- The CHMM-diagnostic figure pairs at `K = 18` for emission families (`fig:emissions_families`, `fig:residence_families`, `fig:is_families`, `fig:is_families_L`, `fig:oos_families`, `fig:oos_families_L`, `fig:convergence_families`). They sit inside the multi-emission appendix block which the body does reach via the umbrella ref. Defer.
- The `K`-sweep IS/OoS panel figures (`fig:k_sweep_*`, 8 figs). Same deferral logic.
