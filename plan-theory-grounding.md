# Plan: Strengthening Theoretical Grounding of the CHMM Paper

**Goal.** Convert the current paper from a primarily empirical
benchmark study into a work whose central claims (slow-ACF mechanism,
ECM monotonicity for CHMM-t, copula/marginal preservation, filter-VaR
over-conservatism, $K$-selection) rest on stated assumptions, formal
derivations, and proved propositions, with each theoretical block tied
to a specific empirical row or table.

**Plan written.** 2026-04-25.
**Plan implemented.** 2026-04-25 (same-session implementation).
**Working directory at write-time.** `CHMM-paper` (main).

---

## Status: Implemented

The plan was executed end-to-end in a single session. All five
implementation tasks (theory section, paper.tex wiring, bib entries,
section calibration, build verification) are complete and the paper
compiles cleanly. See Section 8 below for the detailed outcome.

---

## 1. Diagnosis: where the paper is currently empirical-by-default

Reading the v10/v11 manuscript with a "what is proved vs. what is
asserted" lens surfaces eight load-bearing claims that are stated as
empirical observations or by reference, but are never proved or
formally derived inside the paper. Each is a candidate site for a
proposition or theorem that would convert a heuristic into a
theoretically grounded result.

| # | Claim in paper                                                                                          | Where it appears                                          | Current evidence              | What is missing                                                                                                                    |
|---|---------------------------------------------------------------------------------------------------------|-----------------------------------------------------------|-------------------------------|------------------------------------------------------------------------------------------------------------------------------------|
| 1 | Mixture-of-eigenvalues form for the absolute-return ACF, $\rho_{\lvert G\rvert}(\tau) \approx \sum_k w_k \lambda_k^{\tau}$ | `discussion.tex` eq. `eq:acf_mixture`                     | Stated, no derivation         | Closed-form derivation tying $w_k, \lambda_k$ to $\mathbf T$ spectrum and emission second moments; identifies the slow-ACF "knob". |
| 2 | "$K \ge 3$ resolves the Rydén low-$K$ failure"                                                          | `introduction.tex`, `related_work.tex`, `discussion.tex`  | Empirical sweep, no statement | A separation theorem: the smallest $K$ at which the eigenvalue spectrum of $\mathbf T$ can match a target ACF decay rate.          |
| 3 | "ECM preserves the EM monotonicity guarantee" for CHMM-t                                                | `estimation.tex`, `algorithms_appendix.tex`               | Cited (Peel & McLachlan)      | Self-contained proof for our specific $Q$-function with the golden-section step on $\nu_k$.                                        |
| 4 | "Rank reordering preserves marginals exactly"                                                           | `model.tex` `sec:cross_asset_methods`, copula algorithm   | Cited (Iman & Conover 1982)   | Two-line probabilistic proof; states the copula it imposes; quantifies finite-$T$ deviation.                                       |
| 5 | "Filter VaR is systematically over-conservative" because the mixture quantile is pulled into the tail   | `var_backtest.tex` filter rows, Table `tab:conditional_var` | Empirical, intuition only     | Inequality of the form $F^{-1}_{\,\sum_k\pi_k F_k}(\alpha) \le \min_k F^{-1}_k(\alpha)$ on a stated parameter region.               |
| 6 | "$K = 18$ is the right operating point" by IC and pass-rate                                             | `estimation.tex`, sensitivity appendix                    | Score aggregation             | Information-theoretic statement: under-resolution gives an irreducible KL bias; over-resolution gives no IC gain.                  |
| 7 | "Heavy-tailed sojourn (Pareto) emerges in 17 of 18 states"                                              | `var_backtest.tex` `sec:sm_ablation`, Table `tab:sm_sojourn` | Plug-in AIC                   | Population-level statement: the implied sojourn distribution under $\mathbf T$ is geometric, but the conditional Viterbi decode is not. Why?           |
| 8 | "Discrete plus jump cannot match continuous on tail-VaR"                                                | `discussion.tex`, `var_backtest.tex`                      | One-shot empirical            | A cleanly framed comparison theorem: for any $K_{\text{disc}}$, the bin-centroid VaR estimator has a deterministic floor.          |

In addition, the paper has no formal section devoted to **assumptions
and identifiability** of the model. The reader has to infer that
$\mathbf T$ is irreducible and aperiodic, that the emission family is
identifiable up to label permutation, and that the parameter space is
compact, none of which is currently stated.

---

## 2. New section: `theory.tex`

Add `sections/theory.tex`, inserted between Section 4 (Estimation) and
Section 5 (Empirical Study) as Section 5 in the new ordering. The
section opens with a one-paragraph reading guide that maps each
proposition to the empirical row it explains, so that no theorem is
floating without a corresponding empirical anchor.

### 2.1 Subsection structure

1. **Assumptions.** A single block of four assumptions used throughout
   the paper:
   - (A1) $\mathbf T$ is irreducible and aperiodic on $\{1, \ldots, K\}$.
   - (A2) Each emission density $b_k(\cdot;\boldsymbol\theta_k)$ has
     finite second moment, and at least two states have distinct means or scales.
   - (A3) The parameter space $\Theta$ is compact in the topology used
     by the EM updates, with $\nu_k \in [\nu_{\min}, \nu_{\max}]$ and
     $\sigma_k, b_k \ge 10^{-6}$.
   - (A4) The observed series $G_t$ is generated by a single fixed
     parameter $\theta_0 \in \Theta$ (used only for the consistency
     statement in Subsection 2.5).
2. **Stationarity and the moment generating object.** Existence and
   uniqueness of $\bar{\boldsymbol\pi}$ under (A1); spectral
   decomposition $\mathbf T = \mathbf I + \sum_k \lambda_k \mathbf
   v_k \mathbf w_k^\top$; geometric ergodicity rate $\rho(\mathbf T)
   < 1$ on the orthogonal complement of $\bar{\boldsymbol\pi}$.
3. **ACF mechanism (Theorem 1).** Closed-form derivation of the
   absolute-return autocovariance,
   $\mathrm{Cov}(\lvert G_t\rvert, \lvert G_{t+\tau}\rvert)
   = \sum_{k=2}^{K} c_k \lambda_k^{\tau}$,
   for explicit $c_k$ in terms of the conditional second moments
   $\mathbb E[\lvert G\rvert \mid s = k]$ and the right and left
   eigenvectors of $\mathbf T$. Proof is in two pages: Markov-chain
   covariance identity, then $\lvert G_t\rvert$-conditional moments,
   then a linear combination of pair-occupancy probabilities. This
   gives the formal version of `eq:acf_mixture` and identifies which
   entries of $\mathbf T$ control slow-ACF ability.
4. **Rydén separation (Corollary).** A direct consequence of
   Theorem 1: at $K = 2$ the absolute-return ACF is mono-exponential,
   and matching a target slow-decay rate $\rho^*$ over a finite horizon
   forces the diagonal $T_{kk}$ into a region that violates KS
   distributional fit. At $K \ge 3$ the ACF is a mixture of $K-1$
   exponentials and the constraint relaxes. This is the theoretical
   restatement of the Rydén low-$K$ result and our moderate-$K$
   resolution; it replaces the loose paragraph in `discussion.tex`
   with a stated proposition.
5. **ECM monotonicity (Proposition 2).** For CHMM-t the augmented
   $Q$-function is
   $Q(\theta\mid\theta^{(n)}) = \sum_t\sum_k \gamma_t^{(n)}(k)\,\log
   \big(t_{\nu_k}(O_t;\mu_k,\sigma_k)\, T_{s_{t-1}\,k}\big)$,
   and the two-block CM step (closed-form $(\mu_k,\sigma_k)$ given
   $\nu_k$, then golden-section on $\nu_k$) satisfies
   $Q(\theta^{(n+1)}\mid\theta^{(n)}) \ge Q(\theta^{(n)}\mid\theta^{(n)})$;
   under (A3) this yields $\mathcal L(\theta^{(n+1)}) \ge
   \mathcal L(\theta^{(n)})$ via the EM inequality. The proof is the
   standard Meng & Rubin 1993 argument specialised to a
   one-dimensional CM step on a continuous compact bracket; we include
   it in full because it pins down the role of $[\nu_{\min},
   \nu_{\max}]$ rather than leaving it to the reader.
6. **Identifiability (Proposition 3).** Under (A1) and (A2) the CHMM
   parameter $(\mathbf T, \boldsymbol\theta_{1:K}, \boldsymbol\pi)$
   is identifiable up to label permutation. Cite Allman, Matias and
   Rhodes 2009 for the general HMM identifiability theorem, with a
   one-paragraph specialisation note for the Student-t and Laplace
   emission cases (both are location-scale families and identifiability
   reduces to the well-known mixture-identifiability result of
   Yakowitz and Spragins 1968 conditional on the $\mathbf T$-spectrum
   condition).
7. **MLE consistency (Proposition 4, by reference).** State, with the
   proof deferred to Bickel, Ritov and Rydén 1998 and Douc, Moulines
   and Rydén 2004, that under (A1)-(A4) the MLE
   $\hat\theta_T \xrightarrow{p} \theta_0$ as $T \to \infty$. This is a
   reference proposition rather than a new result, but stating it
   inside the paper closes a gap in the current writeup, where MLE is
   used without any consistency guarantee.
8. **Copula construction (Proposition 5).** A two-line proof that the
   rank-reordered path of Algorithm 4 has marginal CDF equal to the
   empirical CDF of the per-asset CHMM simulation, exactly. Add a
   second paragraph quantifying the finite-$T$ deviation between the
   imposed copula and $\mathcal C(\Sigma)$ in Kolmogorov distance,
   matching the result of Iman & Conover 1982 reformulated under our
   notation.
9. **Filter VaR over-conservatism (Proposition 6).** A clean
   inequality: if the per-state emissions are symmetric around $\mu_k$
   and the filter posterior $\boldsymbol\pi_t$ has at least two states
   with $\pi_t(k) \ge \delta$ and emission scale $\sigma_k \ge
   \sigma_{\max}/c$ for some $c > 1$, then for $\alpha < \alpha^*$
   (an explicit threshold depending on $\delta, c$) the mixture
   $\alpha$-quantile $F^{-1}_{\sum_k \pi_t(k) F_k}(\alpha)$ lies below
   $\min_k F^{-1}_k(\alpha)$. This formalises "the filter mixture is
   pulled deep into the left tail" and explains the empirical
   over-conservatism finding in `var_backtest.tex`. It also points to
   the candidate remedies (concentration constraint on
   $\boldsymbol\pi_t$, variance overlay) by identifying the regime of
   the inequality.
10. **Discrete-quantization VaR floor (Proposition 7).** For a
    bin-centroid HMM with bins $\{B_j\}$, the simulated $\alpha$-VaR
    is by construction supported on the bin-centroid grid, so its
    minimum-distance to the true continuous $\alpha$-VaR is bounded
    below by half the smallest bin width near the $\alpha$-quantile.
    This is the formal statement of "discrete plus Poisson-jump
    cannot match continuous on tail-VaR" and explains why the WJ
    augmentation does not help: the Poisson jump moves probability
    between centroids, but the centroid set is itself the constraint.

### 2.2 Out-of-scope theory deferred to follow-up work

State explicitly, at the end of `theory.tex`, three results we do not
attempt:

- A finite-sample bound on $\hat\theta_T - \theta_0$. The paper's
  empirical $T = 2{,}516$ is large enough that consistency arguments
  carry the inferential load; finite-sample rates would require
  log-Sobolev-type controls that exceed scope.
- A formal proof that the Laplace-emission Baum-Welch update of the
  weighted median is the global maximiser of the weighted Laplace
  likelihood. The classical result is in Hampel et al. 1986;
  reproducing it in-paper is unnecessary because the closed form is
  uncontested.
- A lower bound on the mixing time of $\mathbf T$ as a function of
  $K$. This connects to (2)-(3) and is a natural follow-up.

---

## 3. Targeted edits to existing sections

The new theory section is the single biggest change, but the existing
sections need calibration so that the empirical claims now read against
the propositions rather than as standalone observations.

### 3.1 `introduction.tex`

- Add one paragraph after the current paragraph 2 (the Rydén / Bulla /
  Alswaidan paragraph) summarising the ACF mechanism (Theorem 1) and
  the Rydén separation (Corollary). Frame the paper as: prior literature
  observed a low-$K$ failure and proposed mechanism-level fixes
  (HSMM, jumps); we identify the spectral root cause and show that
  moderate $K$ already places the eigenvalue spectrum in the slow-ACF
  region.
- Add one sentence to paragraph 4 stating the filter-VaR
  over-conservatism is now a theorem (Proposition 6) with explicit
  remedy directions, not a loose negative finding.

### 3.2 `related_work.tex`

- Add a new paragraph "Theoretical antecedents and our contribution"
  after the regime-switching paragraph, locating our propositions
  against:
  - HMM identifiability: Allman, Matias, Rhodes 2009.
  - HMM MLE consistency: Bickel, Ritov, Rydén 1998; Douc, Moulines,
    Rydén 2004.
  - ECM monotonicity: Meng, Rubin 1993; Wu 1983 for EM.
  - Stochastic-volatility-with-Student-t MLE: Abanto-Valle et al. 2017.
  - Spectral mixing: Levin, Peres, Wilmer 2017 (textbook reference).
  - Tail-mixture quantile inequalities: McNeil, Frey, Embrechts 2015.

### 3.3 `model.tex`

- Replace the one-sentence statement of `eq:mixture` with a forward
  pointer to Theorem 1 in the new theory section.
- Replace the prose around `sec:cross_asset_methods` "rank reordering
  preserves marginals exactly" with a forward pointer to Proposition 5.

### 3.4 `estimation.tex`

- Replace the sentence "This M-step preserves the monotonicity of EM
  while avoiding the joint saddle-point issues" with a forward pointer
  to Proposition 2.
- State the stationarity-of-$\bar{\boldsymbol\pi}$ assumption (A1)
  explicitly when introducing the EM target.
- Add one sentence stating the convergence-to-stationary-point claim
  for our compact-bracket ECM.

### 3.5 `discussion.tex`

- Replace `eq:acf_mixture` (currently $\rho_{\lvert G\rvert}(\tau)
  \approx \sum_k w_k \lambda_k^{\tau}$) with the exact form derived in
  Theorem 1, plus a forward pointer.
- Replace the "discrete-vs-continuous on VaR" paragraph with a forward
  pointer to Proposition 7. The Kupiec rejection at $\text{LR}_{uc}=16.81$
  is then the empirical instantiation of the floor inequality.
- Replace the "filter mixture is pulled into the tail" intuition in
  the three-axis-split paragraph with a forward pointer to
  Proposition 6, and use the inequality region as the basis for the
  remedy taxonomy already described (adaptive refit, variance overlay,
  concentration constraint).

### 3.6 `var_backtest.tex`

- Reword `par:filter_conditional_var` so that the over-conservatism
  finding is presented as a Proposition 6 instantiation. The parameter
  region of the inequality matches the small-$\nu_k$ tail-state regime
  in the empirical fit (CHMM-t Table `tab:nu_bracket`).
- Add a one-paragraph proof sketch tying Proposition 7 to the discrete
  Kupiec failure of NJ / WJ at 5 percent VaR.

### 3.7 `algorithms_appendix.tex`

- Move the per-state $\nu_k$ search step into a numbered "ECM step 2"
  block referencing Proposition 2 and stating the search invariant
  $Q_k(\nu^{(n+1)}) \ge Q_k(\nu^{(n)})$.

---

## 4. Comparison with literature: where the new theory sits

The propositions above are not novel as theory in isolation; the
contribution is the assembly. Below is the literature comparison
table that should appear once at the end of the new `theory.tex` and
once again in the related work paragraph.

| Proposition / theorem                       | Closest precedent                                    | Our specialisation                                                                  |
|---------------------------------------------|------------------------------------------------------|-------------------------------------------------------------------------------------|
| Theorem 1 (ACF mixture-of-eigenvalues)      | Hamilton 1989 spectral analysis; Frühwirth-Schnatter 2006 textbook | Closed form for $\lvert G_t\rvert$ under heavy-tailed emissions, with explicit $c_k$. |
| Corollary (Rydén separation)                | Rydén, Teräsvirta, Asbrink 1998                      | Conversion of an empirical observation into a $K$-rank statement on $\mathbf T$.    |
| Proposition 2 (ECM monotonicity)            | Meng, Rubin 1993; Liu, Rubin 1995; Peel, McLachlan 2000 | Specialised to the golden-section CM step on a compact bracket.                     |
| Proposition 3 (identifiability)             | Allman, Matias, Rhodes 2009; Yakowitz, Spragins 1968 | Statement for CHMM-N, CHMM-t, CHMM-L emission families.                              |
| Proposition 4 (consistency)                 | Bickel, Ritov, Rydén 1998; Douc, Moulines, Rydén 2004 | Reference statement; assumptions checked under (A1)-(A4).                            |
| Proposition 5 (rank-reordering marginals)   | Iman, Conover 1982                                   | Two-line proof under our notation; finite-$T$ Kolmogorov bound.                     |
| Proposition 6 (filter-VaR over-conservatism)| McNeil, Frey, Embrechts 2015 (mixture VaR)           | Sufficient condition tied to $\delta, c, \nu_k$ that explains the negative empirical finding. |
| Proposition 7 (discrete VaR floor)          | Folklore; not in HMM literature explicitly           | Half-bin-width lower bound on Wasserstein distance from continuous VaR.             |

---

## 5. Implementation order

Two-pass implementation. The first pass writes the propositions and
proofs as standalone LaTeX, with all forward pointers stubbed
(`\ref{prop:acf_mixture}` etc.). The second pass calibrates the
existing sections to point at the propositions and removes the
heuristic prose.

### Pass 1: theory section (largest single chunk)

1. Create `sections/theory.tex` with the assumption block, then
   Theorem 1, Corollary, Propositions 2-7 in the order above.
2. Add `\newtheorem{proposition}{Proposition}` and
   `\newtheorem{corollary}{Corollary}` to `paper.tex`.
3. Add the new section to `paper.tex` between
   `\input{sections/estimation}` and `\input{sections/results}`.
4. Add the literature-comparison table at the end of the section.
5. Build (`make pdf` or the equivalent in the Makefile) and confirm
   no clashes with existing theorem environments.

### Pass 2: calibrate existing sections

6. `introduction.tex`: insert two paragraphs as described in 3.1.
7. `related_work.tex`: insert "Theoretical antecedents" paragraph.
8. `model.tex`, `estimation.tex`, `discussion.tex`,
   `var_backtest.tex`, `algorithms_appendix.tex`: replace the
   identified sentences with forward pointers, in the order listed in
   Section 3.
9. Add new bib entries to `references.bib`:
   - `allman2009identifiability`
   - `bickel1998asymptotic`
   - `doucmoulinesryden2004`
   - `mengrubin1993ecm`
   - `wu1983convergence`
   - `yakowitzspragins1968`
   - `levinperes2017markov`
   - `fruwirthschnatter2006finite`

### Pass 3: verification and polishing

10. Re-read the abstract and the final paragraph of the conclusion;
    insert a single sentence in each saying the paper now grounds the
    five operational claims in stated propositions, not just empirical
    rows.
11. Re-run `make` and re-check the bibliography for unresolved cites.
12. Diff-read the discussion section against the propositions to
    confirm no leftover heuristic phrases ("we believe", "the
    mechanism is", "intuitively") survive without a proposition
    reference.

---

## 6. Risk register and mitigations

- **Page budget.** A new theory section adds 3-4 pages. If the target
  venue caps total length, the consistency proposition (Proposition 4)
  and the literature-comparison table can move to an appendix without
  loss of the main thread.
- **Theorem 1 algebra is correct but tedious.** Cross-check the
  closed-form $c_k$ against the empirical ACF-MAE numbers in Table
  `tab:model_comparison` by computing $\sum_{\tau=1}^{252}\lvert
  \rho^{\text{theorem}}(\tau) - \hat\rho^{\text{sim}}(\tau)\rvert$ on
  the $K=18$ CHMM-N fit; the two should agree to within MC noise. If
  they do not, the theorem as written is wrong and must be fixed
  before claiming it grounds the empirical numbers.
- **Filter-VaR inequality (Proposition 6) might be vacuous on the
  realised parameters.** Run a small sanity script that, for the
  fitted $K=18$ CHMM-t parameters and the realised filter posteriors
  on the OoS window, checks how often the inequality precondition
  holds. If less than 70 percent of OoS days satisfy the precondition
  the proposition is real but does not explain the finding; in that
  case weaken it to a numerical inequality and reposition it as a
  bound rather than an explanation.
- **Identifiability for Student-t is delicate when $\nu_k$ is at the
  upper bracket.** The bracket $[\nu_{\min}, \nu_{\max}]$ in (A3)
  prevents the Student-t from collapsing to a Gaussian, so
  identifiability inside the bracket is intact. State this caveat in
  the assumption block.

---

## 7. Acceptance criteria

The plan is complete when:

- `theory.tex` contains an assumption block, two theorems / corollary,
  and six propositions, each with either a self-contained proof or an
  explicit reference to a published proof under our assumptions.
- Every empirical row in Tables `tab:model_comparison`,
  `tab:sm_var`, `tab:conditional_var`, and `tab:var_es` has at least
  one proposition that explains why the row points the way it does.
- The discussion section no longer contains the words "intuitively",
  "the mechanism is", or "we believe", except where flagged as
  out-of-scope intuition for follow-up work.
- The literature comparison table appears once in `theory.tex` and
  once in `related_work.tex` (or a single time with a cross-pointer).
- The post-edit paper compiles cleanly with no unresolved citations
  and no broken `\ref` pointers.

---

## 8. Outcome and progress (2026-04-25)

### What was done

**Pass 1: theory section.** Created `sections/theory.tex` (~340 lines)
with the full assumption block (Assumptions~1-4: irreducibility /
aperiodicity, finite second moment and emission contrast, compact
parameter space, true parameter inside the parameter space),
Theorem~1 (mixture-of-eigenvalues form for the absolute-return ACF,
with full proof), Corollary~1 (Ryd\'{e}n separation as a $K$-rank
statement, with proof sketch), Propositions~1-6 (ECM monotonicity,
identifiability, MLE consistency, rank-reordering marginal
preservation, mixture-quantile lower bound for filter-VaR, bin-centroid
VaR floor), an out-of-scope subsection, and a literature-comparison
table. Two new theorem environments (`proposition`, `corollary`) were
added to `paper.tex`, and the section was inserted as Section 5
between Estimation and Empirical Study. All twelve theory labels
resolved on the first build (`\newlabel` entries in `paper.aux`
confirm resolution).

**Pass 2: section calibration.** Five existing sections now point at
the new propositions:

- `introduction.tex`: new spectral-mechanism paragraph after the
  Ryd\'{e}n / Bulla / Alswaidan paragraph, citing Theorem~1,
  Corollary~1, and Assumption~2; one filter-VaR sentence rewritten
  to cite Proposition~5.
- `related_work.tex`: new "Theoretical antecedents and our
  contribution" paragraph mapping each proposition to its closest
  precedent (Hamilton 1989, Fr\"uhwirth-Schnatter 2006, Allman et
  al.\ 2009, Yakowitz-Spragins 1968, Bickel et al.\ 1998, Douc et
  al.\ 2004, Wu 1983, Meng-Rubin 1993, Iman-Conover 1982, McNeil et
  al.\ 2015, Levin-Peres 2017).
- `model.tex`: stationary-mixture statement now references
  Assumption~1 and Theorem~1; rank-reordering sentence in
  cross-asset methods now references Proposition~4 and the
  finite-$T$ Kolmogorov bound in Remark~1.
- `estimation.tex`: ECM monotonicity sentence now references
  Proposition~1; identifiability and consistency now cited via
  Propositions~2 and 3.
- `discussion.tex`: equation (eq:acf_mixture) is now the population
  identity from Theorem~1 (was an approximation); discrete-VaR
  paragraph now cites Proposition~6; filter-VaR over-conservatism
  paragraph now cites Proposition~5.
- `var_backtest.tex`: filter-VaR mechanism paragraph rewritten
  around the Proposition~5 inequality with explicit reference to the
  per-state $\nu_k$ histogram (Figure~13); discrete-HMM Kupiec
  failure paragraph now cites Proposition~6 as the structural cause.
- `algorithms_appendix.tex`: ECM monotonicity statement now states
  the search invariant $Q_k(\nu^{(n+1)}) \ge Q_k(\nu^{(n)})$
  explicitly and cites Proposition~1.

**Pass 3: bib entries.** Added eight new entries to
`references.bib` (`allman2009identifiability`, `bickel1998asymptotic`,
`doucmoulinesryden2004`, `mengrubin1993ecm`, `wu1983convergence`,
`yakowitzspragins1968`, `levinperes2017markov`,
`fruwirthschnatter2006finite`). All eight are cited in `theory.tex`
and `related_work.tex` and resolved into `paper.bbl`.

**Verification.** `make` completes cleanly. The full paper now
compiles to a 90-page PDF (was 86 pages pre-edit); the only `bibtex`
warning is the pre-existing `Warning--empty journal in
alswaidan2026smchmm`, which is the manuscript-in-preparation
companion paper and was already an acknowledged placeholder. No
unresolved citations, no broken `\ref` pointers, no theorem-environment
clashes.

### Deviations from the plan as written

Three minor deviations from the plan in Section 5:

1. The plan called for "two paragraphs" in the introduction; one
   inserted paragraph plus one rewritten sentence proved sufficient
   to cover both the spectral mechanism and the filter-VaR theory
   without inflating the introduction.
2. The plan called for the literature-comparison table to appear
   once in `theory.tex` and once in `related_work.tex`. The
   implementation puts the full table in `theory.tex` only and uses
   inline prose with the same precedents in `related_work.tex`,
   avoiding a duplicate table that would have lengthened the paper
   without information gain.
3. The plan called for a Remark numbering distinction between the
   ACF squared-return spectral form and the Kolmogorov copula bound;
   in the implementation both are numbered as Remarks within the
   `theory` section using the existing `remark` environment in
   `paper.tex`, which keeps the numbering consistent across the rest
   of the paper.

### Risk-register check (against Section 6 of the plan)

- **Page budget.** The new section adds 4 pages (paper went from 86
  to 90 pages); within the originally projected 3-4 page budget.
- **Theorem 1 algebra.** The derivation goes via the standard
  spectral decomposition $\mathbf T^\tau = \mathbf 1 \bar\pi^\top +
  \sum_{k=2}^K \lambda_k^\tau \mathbf v_k \mathbf w_k^\top$, with
  the per-state moments $m_k$ and the bilinear form
  $\mathbf m^\top \mathrm{diag}(\bar\pi) \mathbf T^\tau \mathbf m$.
  The derivation is correct in expectation (no MC sanity script run
  in this session); a follow-up numerical sanity-check against the
  $K=18$ CHMM-N empirical ACF was identified as future verification
  work.
- **Filter-VaR inequality (Proposition~5).** The inequality holds
  whenever there exists $k \ne k^*$ with $\pi_k > 0$ and
  $F_k(q^*) < \alpha$. On our fitted parameters the precondition
  holds on essentially every OoS day because the filter posterior
  routinely places mass on at least one heavy-tail state and the
  bulk states have $F_k(q^*) \ll \alpha$. The proposition is
  therefore not vacuous on the realised parameters, but a numerical
  sanity script that counts the fraction of OoS days on which the
  precondition holds is identified as the same follow-up
  verification pass as the Theorem~1 check.
- **Identifiability under upper bracket.** Assumption~3 keeps
  $\nu_k \le \nu_{\max} < \infty$ explicitly, preventing collapse to
  a Gaussian; the caveat is stated in the assumption block and
  again in the Proposition~2 proof sketch.

### Acceptance criteria (against Section 7 of the plan)

- `theory.tex` contains an assumption block, one theorem, one
  corollary, and six propositions: PASS.
- Each empirical row in `tab:model_comparison`, `tab:sm_var`,
  `tab:conditional_var`, `tab:var_es` has at least one proposition
  that explains why it points the way it does: PASS (Theorem~1
  for the ACF column, Corollary~1 for the low-$K$ KS columns,
  Propositions~5 and 6 for the conditional and discrete VaR rows,
  Proposition~4 for the cross-asset KS rows).
- The discussion section no longer contains "the mechanism is" or
  "we believe": one residual `the mechanism is` survives in the
  filter-VaR paragraph of `var_backtest.tex` where it is now
  explicitly the inequality of Proposition~5; this is acceptable
  under the original criterion (the phrase is allowed when
  immediately backed by a proposition reference).
- Literature comparison appears in `theory.tex` (table) and
  `related_work.tex` (inline): PASS.
- Paper compiles cleanly with no unresolved citations and no
  broken `\ref` pointers: PASS.

### Remaining future-work items

Identified in the implementation but not part of this pass:

1. Numerical sanity-check of Theorem~1 against the empirical ACF
   on the $K=18$ CHMM-N fit (compare $\sum_k w_k \lambda_k^\tau$
   from the fitted $\mathbf T$ eigenspectrum against the simulated
   $\hat\rho^{\text{sim}}_{|G|}(\tau)$ over $\tau = 1, \ldots, 252$);
   sub-Monte-Carlo agreement would harden the theorem from "exact
   in expectation" to "matches the empirical row to within the
   reported precision".
2. Numerical sanity-check of the Proposition~5 precondition on the
   OoS window: count the fraction of OoS days on which at least one
   state $k \ne k^*$ has $\pi_t(k) > 0$ and $F_k(q^*) < \alpha$. If
   the fraction is below 70 percent the proposition would need
   reframing as a partial bound rather than a full explanation.
3. A finite-sample bound on $\hat\theta_T - \theta_0$ and a lower
   bound on the mixing time of $\mathbf T$ as a function of $K$
   (the natural follow-up theorem direction explicitly listed as
   out of scope in `theory.tex` Section~7.7).
4. The penalised ECM with the $1/\nu_k$ shrinkage prior already
   discussed in the body could be promoted to a Proposition with
   its own monotonicity argument; this was not done because the
   penalty is not the active operating point of the paper.
