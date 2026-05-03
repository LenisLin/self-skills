---
name: scientific-objectivity-tone
description: Use when drafting or revising scientific analyses, manuscript text, result summaries, research decisions, protocols, or review responses that need objective, evidence-bounded language. Trigger when the user asks for more objective, scientific, concise, less flattering, less persuasive, or anti-hype wording.
---

# Scientific Objectivity Tone

Make research-facing writing factual, auditable, and bounded by evidence. This skill governs tone and claim framing; it does not replace statistics, domain methods, reporting guidelines, or approval gates.

## Use For

- protocols, analysis plans, and decision memos
- methods, results, discussion, figure legends, and summaries
- peer review responses and rebuttals
- plain-language science summaries that must avoid hype

## Core Rules

- Match claims to study design: randomized evidence can support stronger causal language than observational, benchmark, simulation, in vitro, or exploratory evidence.
- Distinguish `observation`, `interpretation`, `recommendation`, and `main conclusion`.
- State association versus causation explicitly.
- Prefer effect sizes plus uncertainty over `p` values alone.
- Report null, negative, and harmful findings alongside favorable results.
- Mark prespecified versus exploratory analyses.
- Name limitations, likely bias direction, and generalizability bounds when they affect interpretation.
- If evidence is missing, write `Insufficient evidence` and name the next verification step.

## Language Rules

- Use direct, neutral sentences with one substantive claim where possible.
- Replace praise or reassurance with observable design, metric, mechanism, failure mode, or scope.
- Prefer `is associated with`, `was estimated at`, `supports`, `does not establish`, `remains uncertain`, and `requires validation`.
- Avoid motivational, sales-like, flattering, or certainty-signaling language.
- Use respectful participant language and avoid blame-coded labels.

## Output Shapes

For analyses and conclusions:

1. Claim or conclusion
2. Evidence basis
3. Uncertainty or limitation
4. Implication or next verification step

For plans and protocols:

1. Objective
2. Design
3. Outcomes
4. Analysis
5. Bias control
6. Reproducibility
7. Limits and decision criteria

For review responses:

1. Reviewer issue
2. Change made, or reason no change was made
3. Supporting method, data, or citation
4. Non-defensive closing sentence when needed

## Anti-Spin Check

Revise before sending if the text:

- implies benefit when the primary result is null or inconclusive
- upgrades association to causation without a supporting design
- emphasizes favorable secondary, subgroup, or post hoc findings over the primary analysis
- omits relevant harms, negative results, exclusions, or missing-data implications
- extrapolates beyond the population, endpoint, time point, setting, or dataset
- uses hype words instead of effect estimates, uncertainty, or limitations

## Hard Bans

- Do not flatter the user.
- Do not hide recommendations inside observations.
- Do not replace missing evidence with confidence language.
- Do not imply rigor, robustness, or reproducibility without naming the supporting design or analysis feature.
- Do not summarize a scientific plan as preferences, vibes, or motivation.

Use `references/authoritative-guidance.md` only when revising the skill or adapting it to a new study type.
