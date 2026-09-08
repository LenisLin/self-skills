# Manuscript Changes and Comparison Matrices

Use the source roles and historical-match decisions in `02_evidence_scope_and_claims.md`. Completed-change narration concerns the review-round baseline to the current manuscript; the proposed-change matrix concerns the current manuscript to its next version.

## End-of-Response Changes

Complete the substantive response first. Introduce each individual completed change with its objective, action, and exact location, then quote the current text:

To clarify [objective], we revised the **Methods, "[current subsection title]" subsection (Lines XXX-XXX, Page XX)**, as follows:

"[Verbatim current manuscript text.]"

This is a teaching pattern: replace its content fields with verified wording. Preserve location placeholders only while the actual line and page numbers remain unresolved. A generic modification heading does not replace the purpose-led sentence. Do not use bullets or numbered lists in this block.

## Quotations and Locations

1. Extract quoted manuscript, supplementary, or table text verbatim from the latest current source. Wrap each separately quoted passage in ASCII double quotation marks. Keep revision-process narration outside the quotation.
2. Use one fixed quotation color, default `#1F4E79`, unless the author specifies another. Apply it to quoted source text, not reviewer comments or response narration. Preserve source italics, citations, and equations within quotations.
3. Bold the section, quoted subsection title, and line/page information in the introduction, not the entire introductory sentence. Preserve the actual section hierarchy and exact subsection title.
4. Preserve paragraph boundaries and source order. Do not join nonadjacent excerpts into an apparently continuous quotation. Close each separately quoted passage without leaving a standalone closing-quote paragraph.
5. Use `(Lines XXX-XXX, Page XX)` before pagination is verified; use `Pages XX-XX` for a page range. For distinct locations, associate each line range with its corresponding page or pages, separated clearly when necessary.
6. After an author editing pass, reread the affected source, remove superseded proposals, and refresh quotations and locations. Never inherit old line/page numbers without checking their version.
7. Identify unchanged supporting text as existing content rather than a completed revision. Omit an unnecessary modification block; label unapplied replacement or insertion wording as proposed.

## Figures and Tables

- Retain the exact current number and full title of an existing item. Put the title immediately beside or below the insertion and bold the caption title, not the entire legend. Panel insertions retain the parent title.
- For an existing figure the author will insert manually, supply one labeled insertion placeholder and its exact parent title. Do not generate, crop, or embed a preview.
- Give a response-only item a unique reviewer-comment-specific identifier, such as `Table R2-3.2`, and a descriptive title. Preserve necessary units, abbreviations, and symbol explanations.
- When a changed legend is part of the claimed manuscript revision, quote its exact current text in the final modification block. For tables, quote actual titles, headers, or contents, not an invented sentence describing the editing process.

## Proposed-Change Matrix

After the complete response, give a separate comparison matrix whenever additional manuscript or supplementary-text changes are proposed. Each row contains the file/section, type (`replacement`, `insertion`, or `deletion`), complete searchable current text or insertion anchor, and complete exact proposed text. For deletion, identify the full deleted text and leave the proposed-text cell empty.

Make every row self-contained; never substitute `see above`, `same as above`, or a reference to another quotation for its contents. Include only necessary current-to-next changes for this comment, not completed baseline-to-current revisions or optional unrelated cleanup.

Preserve existing citation fields and verified reference numbering. If final numbering is pending for a new citation, use the source's exact verified title in square brackets; do not use generic citation placeholders.

## Section-Specific Wording

- Results: state the observed finding and attach its figure citation directly; retain a short setup only when needed to define the comparison.
- Methods: describe procedures actually performed, without figure citations or lists of analyses not performed.
- Legends: identify displayed data, panels, encodings, annotations, and scale; keep interpretation in Results or Discussion.
- Discussion: state supported conclusions and future validation needs directly. Keep reviewer-facing rebuttals such as `does not imply` or `should not be interpreted as` in the response, not manuscript replacement text. Factual negative findings remain appropriate.
