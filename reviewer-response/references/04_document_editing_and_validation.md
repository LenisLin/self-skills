# Document Reading, Editing, and Validation

Publication files are read-only unless the author identifies the files and requests editing. Use the project's approved environment and available document tools; do not hard-code a machine-specific interpreter or install dependencies merely for inspection.

## Read Current Files

1. Read DOCX as a read-only OOXML ZIP package when extracting source text. Preserve paragraph and table-cell order and retain the tracked-change information relevant to the task; distinguish current text from deleted text.
2. Inspect headers, footers, notes, comments, and relationships when they affect the requested content. Do not treat extraction labels for embedded objects as text placeholders without checking their relationships.
3. Write temporary extractions outside publication directories. Finish extraction before reading its output. Do not derive rendered page or line numbers from XML paragraph indices.
4. Inventory workbook sheets and inspect structure before assuming headers. With pandas, use `ExcelFile` and a first `read_excel(..., header=None)` pass; use workbook-native inspection for formulas, styles, merged cells, and dimensions.

## Authorized Editing

1. Confirm the exact target and permitted changes, inspect the latest file, and retain a recoverable pre-edit copy before changing a binary document.
2. Define context-rich anchors, expected occurrence counts, and post-edit checks before writing. If matches differ from expectation, stop that replacement and inspect the current document again.
3. Edit only the authorized text and formatting. Preserve citation fields, bookmarks, relationships, styles, embedded objects, images, section properties, and other unaffected content. Avoid automatic run merging in citation-bearing paragraphs.
4. Preserve reviewer numbering and heading hierarchy. Use native DOCX lists for response bullets, with bold descriptive lead-ins; keep modification paragraphs outside the list. Apply quotation, caption, and location formatting from `03_manuscript_changes_and_matrices.md`.
5. Use the existing document typography unless a different style is requested. In plain text or ordinary Markdown, state the intended quotation color in author-facing delivery notes rather than inserting formatting instructions into the reviewer-facing letter or claiming that a color has been applied.

## Equations

Use the LaTeX draft representation specified in `01_response_planning_and_drafting.md`. For DOCX, preserve existing native equations unless conversion is requested. Confirm the required representation before a requested conversion: literal LaTeX text, linear LaTeX inside native objects, and structured Word equations are different deliverables.

Do not silently convert every numeric literal to an equation. Preserve symbols, subscripts, superscripts, fractions, and surrounding text, and report whether equation rendering was actually checked.

## Validate Against the Pre-Edit Baseline

1. Check ZIP integrity and XML well-formedness for an edited DOCX.
2. Compare before/after text and verify replacement counts against the authorized changes. Distinguish pre-existing package features from newly introduced defects.
3. Check that fields, references, relationships, images, equation content, and unaffected package parts remain preserved. Ensure temporary artifacts did not enter the final package.
4. Check balanced quotation marks, the agreed quotation color, bold labels and locations, native list boundaries, equation representation, and unresolved line/page placeholders.
5. Inspect rendered pagination and layout when a renderer is available. Otherwise report visual pagination and equation wrapping as unchecked; XML checks do not establish visual equivalence.
6. For workbook edits, confirm that unrelated sheets, cells, formulas, and styles remain unchanged. Compare numeric values with a justified tolerance and text exactly. Validate joins against the actual key contract rather than assuming every target row needs a distinct source row.
