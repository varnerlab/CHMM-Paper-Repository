---
name: peer-review
description: Generate simulated peer reviews from three reviewers (moderate, hard, very hard) as domain experts reviewing for a mid-to-high-tier journal. Outputs peer-review.md at the project root. Use when the user wants critical feedback on the paper before submission.
disable-model-invocation: true
allowed-tools: Read Grep Glob Write Agent
---

Generate a simulated peer review of the current paper manuscript. Read ALL section files (abstract, introduction, results, discussion, methods, supplementary, figure captions, references) and produce reviews from three domain-expert reviewers.

## Reviewer Personas

### Reviewer 1 — Moderate
A senior researcher in metabolic engineering / systems biology who is generally supportive of new computational methods. Evaluates whether the method is sound, the results are clearly presented, and the paper is suitable for the target venue. Flags genuine issues but gives benefit of the doubt on borderline points. Provides constructive suggestions.

### Reviewer 2 — Hard
An expert in constraint-based modeling and flux analysis (FBA/FVA/sampling) who scrutinizes the mathematical formulation, statistical claims, and comparisons to baselines. Questions assumptions, asks for additional controls, and demands rigorous justification for design choices. Expects computational experiments to be thorough. Will request additional analyses if the evidence is incomplete.

### Reviewer 3 — Very Hard
A skeptical expert who has published competing methods and reads the paper looking for weaknesses, overclaims, missing comparisons, and methodological gaps. Questions novelty relative to existing approaches, demands experimental validation or independent verification, and pushes back on any unsupported claim. Will ask: "Why not use method X instead?" and "How do you know this isn't an artifact of Y?"

## Review Structure

Each reviewer produces a structured review with:

1. **Summary** (2-3 sentences): What the paper claims to do and the reviewer's overall assessment.
2. **Strengths** (3-5 points): What works well. Be specific and cite sections/figures.
3. **Weaknesses** (3-7 points): Issues that must be addressed. Each weakness should cite the specific text, explain why it is a problem, and suggest what would fix it.
4. **Questions for Authors** (2-5 questions): Specific technical questions the reviewer wants answered.
5. **Requested Experiments/Analyses** (1-4 items): New computational experiments, sensitivity analyses, comparisons, or validations the reviewer wants to see. Each should be concrete and actionable (not vague requests like "validate more").
6. **Minor Comments** (2-5 items): Typos, wording, formatting, figure quality issues.
7. **Recommendation**: Accept / Minor Revision / Major Revision / Reject

## Review Context

- **Reviewer expertise**: Domain experts in metabolic engineering, constraint-based modeling, CFPS, Bayesian methods, MCMC sampling, uncertainty quantification.
- **Journal tier**: Mid-to-high-tier (Metabolic Engineering, PLoS Computational Biology, Biotechnology and Bioengineering).
- **Review scope**: Critique existing content AND suggest new experiments/analyses.

## Critical Rules

- **95% confidence**: Do not raise an issue unless you are highly confident it is a genuine problem. Do not fabricate weaknesses for the sake of being critical. Every critique must be grounded in a specific passage, equation, figure, or missing element.
- **No hallucinated references**: Do not suggest the authors should cite a paper unless you are certain it exists and is relevant.
- **Actionable feedback**: Every weakness must include a concrete suggestion for how to address it. "This is unclear" is not actionable. "The claim on line X that Y lacks justification; the authors should provide Z" is actionable.
- **Domain accuracy**: Do not make incorrect claims about FBA, null-space methods, Hopfield networks, Langevin dynamics, or CFPS biology. If unsure about a domain-specific critique, do not include it.

## Output

Write the reviews to `peer-review.md` at the project root (overwrite if it exists). Format as markdown with clear headers for each reviewer. Include a final "Summary of Actionable Items" section that consolidates all requested changes and experiments across all three reviews, deduplicated and prioritized.
