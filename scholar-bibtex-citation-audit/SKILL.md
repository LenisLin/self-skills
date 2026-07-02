---
name: scholar-bibtex-citation-audit
description: Use when Codex must refresh or replace LaTeX BibTeX entries in references.bib from Google Scholar, preserve citation keys used in .tex files, audit BibTeX consistency, and report citation semantic risks. Trigger for workflows involving references.bib, Google Scholar BibTeX, Chrome Scholar sessions, citation key restore, LaTeX \cite consistency, suspicious bibliography replacements, or semantic citation review.
---

# Scholar BibTeX Citation Audit

Execute this workflow as a rigorous, index-preserving bibliography replacement and citation-audit process for LaTeX projects. Treat the workflow as low-freedom: do not skip backup, index tracking, suspicious-entry handling, citation key restore, static checks, or final reporting.

## Global Rules

- Work on `references.bib` unless the user explicitly specifies another BibTeX file.
- Preserve entry order and process replacements by entry index, not by citation key.
- Never append replacement entries when the intended operation is replacement.
- Use the current local Chrome session for Google Scholar operations when Scholar fetching is required. Robot-check and verification state live in that browser session.
- Do not replace entries while a robot check is active or unresolved.
- Do not write semantic risk comments into `main.tex` or any `.tex` file. Report semantic risks only in the conversation.
- Do not modify prose citations or body text unless the user explicitly asks for text edits.
- Prefer restoring BibTeX keys to match existing manuscript citations over changing manuscript citation keys.
- State assumptions and uncertainty explicitly, especially for suspicious matches and title drift.

## A. Batch Replacement Preparation

1. Confirm that the working file is `references.bib`.
2. Immediately create a complete backup, for example `references.bib.backup-YYYYMMDD-HHMMSS`.
3. Parse `references.bib` and record each entry in appearance order:
   - index, for example entry 1 or entry 2
   - original citation key
   - title
   - DOI
   - year
4. Perform all later replacements by index, not by key lookup, and do not append replacement entries.
5. Open local Chrome and enter Google Scholar.
6. Use the current Chrome session for Scholar because robot-check state and verification state are tied to that session.
7. Do not run the whole batch invisibly in the background. Process entries one by one and continuously monitor the foreground page.
8. If a robot check appears, immediately pause, tell the user to verify manually, and continue the same entry only after the user says verification has passed.

## B. Single-Entry Google Scholar BibTeX Retrieval

For entry index `i`:

1. Read the title from the current BibTeX entry at index `i`.
2. Put the title into the Google Scholar search box.
3. Click the Scholar `Search` button or equivalently open the URL in the current Chrome session:
   `https://scholar.google.com/scholar?q=<encoded title>`
4. Wait for the search results page to finish loading.
5. Check whether the page entered a robot check:
   - If yes, stop the current loop.
   - Do not replace any content.
   - Ask the user to verify manually.
   - After the user says verification passed, resume from the same entry index `i`.
6. Read candidate result titles from the search results.
7. Compare each candidate title to the original title with normalized title matching:
   - ignore case differences
   - remove extra symbols
   - preserve and compare key tokens
   - mark token mismatches such as `scBaseCamp` versus `scBaseCount` as suspicious
8. If the first result clearly matches, select the first result.
9. If the first result does not match, inspect later results.
10. If no result is reliably matched, record the entry as `suspicious` and do not auto-replace it.
11. After finding the correct result, click its `Cite` button.
12. Wait for the citation dialog to appear.
13. Click the `BibTeX` link in the dialog.
14. Open the BibTeX page in the current Chrome session.
15. Read the complete BibTeX text from the page body.
16. Do not use a background HTTP request as a substitute for the Chrome page, because robot checks and Scholar session state may make background requests fail or return different content.
17. Replace the complete BibTeX entry at index `i` in `references.bib` with the retrieved BibTeX text.
18. Save `references.bib` immediately.
19. Write a log entry containing:
   - index
   - original key
   - new Scholar key
   - original title
   - Scholar title
   - status: `success`, `suspicious`, `no result`, or `robot check`
20. Continue to entry index `i+1`.

## C. Suspicious Entry Rules

Do not automatically accept a replacement in any of these cases:

1. The Scholar title and original title are clearly different.
2. Important title tokens are inconsistent.
3. Scholar returns a different paper.
4. Scholar has no result.
5. The result is a dataset, repository, software record, or web page.
6. The result involves a version update.
7. The target project or repository explicitly requires citing a different paper.

Record these entries as `suspicious` and ask for human confirmation.

Already confirmed exceptions from this workflow:

- Entry 60: `scBaseCount` is a version update; accept it.
- Entry 66: `Stack` is the original paper explicitly requested by the Hugging Face repository; accept it.

## D. Citation Key Restore After Replacement

Scholar BibTeX may change keys, for example:

```bibtex
@article{wei2025vcworld,
```

Manuscript text may still cite the old key, for example:

```latex
\cite{wei_vcworld_2025}
```

After Scholar content replacement, perform key restore as a separate operation:

1. Read the initial backup file.
2. Extract the old key for each backup entry by index.
3. Read the current `references.bib`.
4. For each entry, replace only the key in the first line, such as `@type{new_key,`.
5. Preserve Scholar-updated fields such as `title`, `author`, `journal`, and `year`.
6. Do not overwrite Scholar-updated entries with full backup entries.
7. If the backup was created after a key had already been changed, use the key actually cited in the manuscript as authoritative.
8. Scan all `\cite{...}` usages in `main.tex`.
9. If the manuscript cites a key that does not exist in the BibTeX file, prefer restoring the BibTeX key over changing the manuscript text.
10. The final requirement is that every citation key used in the manuscript exists in `references.bib`.

## E. BibTeX Static Checks

After replacement and key restore, check:

1. `references.bib` entry count matches the backup entry count.
2. No duplicate keys exist.
3. No duplicate titles exist.
4. No duplicate DOIs exist.
5. No entry is missing `title`.
6. No entry is missing `year`.
7. No entry is missing `author`.
8. No obvious mojibake or garbled text exists.
9. BibTeX braces are balanced.
10. No `noauthor`, `unknown`, or clearly wrong title remains.
11. Compare current titles with backup titles by index to detect title drift.
12. Do not treat human-confirmed title drift as an error.

## F. Manuscript Citation Consistency Checks

1. Scan all `.tex` files, including at least `main.tex`.
2. Extract citation commands including:
   - `\cite{...}`
   - `\citep{...}`
   - `\citet{...}`
   - `\parencite{...}`
   - `\textcite{...}`
3. Split multi-key citations, for example `\cite{a,b,c}`.
4. Check that each key exists in `references.bib`.
5. Output every missing key with:
   - file name
   - line number
   - missing key
6. Fix missing keys until the count is 0.
7. Check again that the BibTeX file has no duplicate key.
8. Proceed to semantic review only after this check passes.

## G. Citation Semantic Review

Report semantic review findings only in the conversation. Do not write `% CITATION-RISK` or equivalent comments into `main.tex`.

1. Read `main.tex`.
2. Find each sentence or paragraph containing a citation.
3. For each citation key, read from `references.bib`:
   - title
   - author
   - journal
   - year
4. Judge whether the manuscript claim and the cited reference match.
5. Use these risk levels:
   - `high`: the citation is likely unable to support the claim.
   - `medium`: the citation is related, but the claim is stronger than the literature support.
   - `low`: the citation is basically reasonable, but the expression could be more precise.
6. For each risk item, report only in the conversation:
   - `main.tex` line number
   - original sentence or claim summary
   - current citation key
   - risk level
   - why it is suspicious
   - suggestion: add citation, replace citation, split the sentence, or weaken wording
7. Do not automatically insert `% CITATION-RISK`.
8. Do not automatically modify manuscript text unless the user explicitly asks for edits.

## H. Final Delivery Format

At the end of each round, report:

1. How many entries were replaced.
2. Which entries are suspicious.
3. Which entries were accepted after human confirmation.
4. Whether citation keys were restored.
5. Whether any manuscript citation keys are missing from `references.bib`.
6. Whether any duplicate key, title, or DOI remains.
7. Semantic risk list, only in the conversation.
8. Whether files were modified, and exactly which files were modified.
