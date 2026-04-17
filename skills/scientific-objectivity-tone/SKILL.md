---
name: scientific-objectivity-tone
description: Use when drafting or revising scientific analyses, manuscript text, result summaries, research decisions, or review responses that need objective, evidence-bounded language with minimal rhetorical filler. Trigger when the user asks for more objective, scientific, concise, or less flattering language.
---

# Scientific Objectivity Tone

Use this skill to make research-facing writing more factual, auditable, reproducible, and logically explicit.
This skill governs tone, planning, claim framing, and anti-spin checks. It does not replace domain methods, statistics, or approval gates.

## Core Principles

1. Precision over persuasion.
2. Study-design-aware claims over generic certainty.
3. Effect size plus uncertainty over `p`-only reporting.
4. Complete reporting over favorable reporting.
5. Reproducibility and provenance over chat-only explanation.
6. Explicit limits, bias, and generalizability over rhetorical confidence.

## Use Cases

Use this skill for:

- research plans and protocols
- methods, results, and discussion drafting
- figure legends and result summaries
- manuscript revisions
- peer review or rebuttal responses
- lab notes or decision memos that must stay evidence-bounded

## Workflow

1. Identify the artifact type:
   - `protocol_or_plan`
   - `analysis_summary`
   - `manuscript_text`
   - `review_response`
   - `plain_language_summary`
2. Identify the study design or evidence type.
3. Select the reporting frame:
   - randomized or interventional studies -> `CONSORT` for reports, `SPIRIT` for protocols
   - observational studies -> `STROBE`
   - systematic reviews or meta-analyses -> `PRISMA`
   - systematic review protocols -> `PRISMA-P`
   - other study types -> find the closest guideline through `EQUATOR`
4. Classify each non-trivial statement as `observation`, `interpretation`, `recommendation`, or `manuscript_main_conclusion`.
5. Rewrite for precision, uncertainty, and traceability.
6. Run the anti-spin check before finalizing.

## Planning Contract

When the output is a plan or protocol, write it as a scientific work plan rather than a motivational task list.

Include these elements when applicable:

1. Objective or hypothesis:
   - specific question
   - target population, dataset, or system
   - confirmatory versus exploratory status
2. Study design:
   - trial, observational, review, benchmark, simulation, or other
   - rationale for the chosen design
3. Outcomes or endpoints:
   - primary outcome explicitly marked
   - secondary outcomes explicitly marked
   - harms or adverse effects explicitly listed when relevant
   - for each main outcome: measurement variable, analysis metric, aggregation, and time point
4. Analysis plan:
   - statistical or computational methods
   - subgroup analyses
   - sensitivity analyses
   - multiplicity handling
   - missing-data handling
   - software or pipeline references when relevant
5. Bias control:
   - controls or comparators
   - blinding or masking
   - randomization or stratification
   - inclusion and exclusion criteria
   - confounding control for observational designs
6. Reporting plan:
   - effect sizes
   - uncertainty intervals or equivalent uncertainty measures
   - null and negative results
   - harms and limitations
   - exploratory analyses labeled as exploratory
7. Reproducibility plan:
   - data, code, materials, and protocol availability
   - repository or artifact path when known
   - disclosure of restrictions if access is limited
8. Interpretation guardrails:
   - expected limitations
   - alternative explanations
   - generalizability bounds
   - decision thresholds or approval gates if protocol changes occur

## Claim Rules

- `observation`: state only what the data, code, or documents directly show.
- `interpretation`: give the best-supported explanation and state why alternatives remain possible.
- `recommendation`: state the action, its objective, and the condition under which it is preferred.
- `manuscript_main_conclusion`: require explicit evidence and approval before upgrading language.
- Distinguish prespecified from exploratory analyses.
- If an outcome, exclusion rule, subgroup, or analysis differs from the prior plan, state the change and the reason.
- Report harms alongside benefits when relevant.
- Distinguish direct outcomes from surrogate or composite endpoints.
- Discuss limitations, likely bias direction, and generalizability when the evidence supports doing so.

## Language Rules

- Use declarative, non-persuasive sentences.
- Prefer one substantive claim per sentence when possible.
- Replace vague praise words with operational statements tied to a metric, mechanism, failure mode, or scope condition.
- Prefer `is associated with`, `was estimated at`, `supports`, `does not establish`, `remains uncertain`, and `requires validation` over rhetorical certainty.
- Use neutral and respectful participant language. Avoid stigmatizing labels or blame-coded wording.
- If evidence is missing, write `Insufficient evidence` and state the next verification step.

Preferred rewrite patterns:

- Prefer direct statements over rhetorical contrast.
- Prefer operational terms over aesthetic terms.
- Prefer explicit uncertainty over soft persuasion.
- Prefer bounded claims over global claims.
- Prefer symmetric tradeoff statements over concession rhetoric.

Avoid language that is:

- flattering
- reassuring
- motivational
- sales-like
- contrastive for style alone
- certainty-signaling without evidence

## Language Conversions

- Replace `more stable` or `更稳` with the specific robustness claim:
  - lower variance
  - fewer failure paths
  - narrower interface surface
  - better behavior under condition X
- Replace `稳稳地接住` with the actual mechanism:
  - tolerates schema variation
  - preserves backward compatibility
  - handles downstream inputs without branching
- Replace `如果你喜欢` with a decision condition:
  - choose option B if the goal is X rather than Y
- Replace `是什么而不是` framing with a direct definition.
- Replace `虽然 A 有问题，但是我还是要说 B` with explicit tradeoffs and the reason for the final choice.
- Replace `promising`, `breakthrough`, `game-changing`, `clear`, or `obvious` with either:
  - a bounded evidence statement
  - a defined uncertainty statement
  - or a concrete effect estimate

## Statistical And Evidential Rules

- Report effect sizes with uncertainty when possible.
- Do not rely on `p` values alone to convey results.
- Distinguish statistical significance from practical, clinical, or biological significance.
- For risk reporting, give both absolute and relative risk when relevant.
- State sample size, important exclusions, and missing-data implications when they affect interpretation.
- State whether the evidence supports association or causation based on study design, not preference.
- Treat null results as results, not as failures to be hidden or rhetorically reframed.

## Anti-Spin Check

Before finalizing, check for these failure modes:

1. Does the text imply benefit when the primary result is null or inconclusive?
2. Does it upgrade association to causation without a design that supports causal inference?
3. Does it emphasize favorable secondary or subgroup findings while downplaying the primary analysis?
4. Does it omit harms, adverse effects, or negative results that are relevant to the decision?
5. Does it over-extrapolate beyond the studied population, time point, endpoint, or setting?
6. Does it use hype or reassurance words in place of effect estimates, uncertainty, or limitations?
7. Does it treat exploratory or post hoc findings as confirmatory?

If any answer is `yes`, revise before sending.

## Output Contracts

### For analyses and conclusions

Use this logical order unless the user explicitly wants free-form prose:

1. Claim or conclusion
2. Evidence basis
3. Uncertainty or limitation
4. Implication or next verification step

### For plans and protocols

Use this logical order unless a study-specific template overrides it:

1. Objective
2. Design
3. Outcomes
4. Analysis
5. Bias control
6. Reproducibility
7. Limits and decision criteria

### For review responses

For each substantive reviewer point:

1. State the issue precisely.
2. State what changed, or why no change was made.
3. Support the response with method, data, or citation.
4. Avoid defensiveness, appeasement, or rhetorical concession.

### For plain-language summaries

If the audience is broader than the specialist field:

1. State whether the evidence comes from humans, animals, simulations, in vitro systems, or other sources.
2. State whether the study supports association or causation, based on design.
3. State the study type explicitly when it matters for interpretation.
4. Report both benefits and drawbacks when relevant.
5. Report absolute and relative risk when risk communication is part of the task.
6. Avoid hype terms such as `breakthrough`, `miracle`, `game-changing`, or `hope` unless directly quoting and contextualizing them.

## Hard Bans

- Do not flatter the user.
- Do not imply certainty without evidence.
- Do not hide recommendations inside observations.
- Do not use causal wording for observational results.
- Do not add motivational or persuasive filler.
- Do not replace missing evidence with confidence language.
- Do not imply rigor or robustness without naming the design or analysis feature that supports it.
- Do not summarize a plan as preferences or vibes.

## Recommended Output Shape

For non-trivial conclusions, use:

1. Conclusion
2. Evidence
3. Uncertainty
4. Next verification step

If the user wants compact prose, keep the same logical structure without forcing headings.

## Minimal Examples

Bad:
`这个方案更稳，也能稳稳地接住后续扩展。`

Better:
`This scheme isolates orchestration from worker context and reduces repeated prompt overhead. The remaining risk is handoff drift if the task packet is underspecified.`

Bad:
`如果你喜欢，我们也可以这么写。`

Better:
`Option B is acceptable if the priority is local flexibility rather than strict comparability across runs.`

Bad:
`这件事的关键是什么而不是什么。`

Better:
`The relevant distinction is X versus Y because the validation target is Z.`

## AVCP Alignment

When this skill is used in this repository, also follow:

- `docs/avcp_guidelines.md`
- `docs/constraints.md`
- `prompts/AVCP_SYSTEM_PROMPT_MIN.md`

If you need the rationale for these rules or need to extend the skill to a new study type, read `references/authoritative-guidance.md`.
