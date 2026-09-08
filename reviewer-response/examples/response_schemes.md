# Worked Response Schemes

These are fictional, non-scientific teaching examples. Their stated facts and completed actions are supplied assumptions, not claims about a real manuscript. Replace them with verified project content. Formatting and evidence rules remain owned by the references; plain Markdown does not apply the specified quotation color.

## 1. Existing Content: Explain Without Inventing a Revision

Use when the baseline and current Methods both define an input record and no further wording change is needed.

**Reviewer comment:** Please define what constitutes an input record.

**Response:** We thank the reviewer for requesting clarification of the term "input record." In the Methods, "Terminology" subsection, an input record is defined as one entry received before processing. We use that definition throughout the workflow.

A direct explanation and source location are sufficient here. Do not add a completed-change block when nothing changed.

## 2. Several Requests: Bridge, Descriptive Bullets, Then Changes

Assume the reviewer asks about processing order and incomplete records. Both changes below have been verified in the current Methods.

**Reviewer comment:** Please clarify when records were checked and how incomplete records were handled.

**Response:** We appreciate the reviewer's request for a clearer description of processing order and record handling. We clarified these two aspects of the workflow:

- **Processing order.** Records were checked before analysis.
- **Incomplete records.** Records without identifiers were excluded at that check.

These details identify when the check occurred and which records it removed.

To clarify the processing order, we revised the **Methods, "Record processing" subsection (Lines XXX-XXX, Page XX)**, as follows:

"Records were checked before analysis."

To specify the handling of incomplete records, we revised the **Methods, "Record eligibility" subsection (Lines XXX-XXX, Page XX)**, as follows:

"Records without identifiers were excluded at the initial check."

Omit the bridge and bullets when one continuous explanation is clearer. The number of points follows the actual requests, not a fixed three-point template.

## 3. Completed Evaluation: Action, Figure, Result, Interpretation

Assume a supplied execution log confirms the expected step order, Figure 2 is titled "Recorded workflow order.", and the quoted Results sentence is already in the current manuscript. The author will insert the figure manually.

**Reviewer comment:** Please verify the reported processing order and show the corresponding figure.

**Response:** We thank the reviewer for recommending verification of the reported step order. We compared the execution log with the sequence described in the Methods.

[Insert Figure 2 here]
**Figure 2. Recorded workflow order.**

The log recorded preprocessing before analysis. This agrees with the sequence described in the Methods.

To report the observed execution order, we revised the **Results, "Workflow verification" subsection (Lines XXX-XXX, Page XX)**, as follows:

"The execution log recorded preprocessing before analysis (Figure 2)."

Use this form only when the evaluation and manuscript change are verified. Do not generate an image preview for the insertion placeholder.

## 4. Acknowledge and Correct a Description

Assume inconsistent descriptions have been confirmed and the current Methods now contain the quoted correction.

**Reviewer comment:** The descriptions of preprocessing and model training are inconsistent. Please clarify their order.

**Response:** We acknowledge that inconsistent descriptions obscured the order of preprocessing and model training. We revised the Methods to present the stages in their execution order: preprocessing was completed before model training began.

To clarify the sequence, we revised the **Methods, "Processing sequence" subsection (Lines XXX-XXX, Page XX)**, as follows:

"Preprocessing was completed before model training began."

`We apologize that ...` is also appropriate for an established reporting error. Use `We acknowledge the reviewer's concern about ...` when recognizing the concern without conceding an unverified premise.

## 5. An Unmet Request: Acknowledge the Actual Gap

Assume independent replication was requested but has not been performed; the supplied evidence concerns only the original implementation.

**Reviewer comment:** Please provide an independent replication of the implementation.

**Response:** We appreciate the reviewer's request for independent replication. This evaluation has not yet been performed. The available evidence concerns the original implementation; independent replication is still needed to assess reproducibility across implementations.

Do not invent a completed analysis, figure, or manuscript modification. Add available substantive evidence when supplied and directly relevant.

## 6. Overview Comment: Keep the Reply Proportionate

Assume the following numbered responses separately address terminology, workflow reporting, and document consistency.

**Reviewer comment:** The terminology, workflow reporting, and consistency between the manuscript and supplementary material require attention, as detailed below.

**Response:** We thank the reviewer for the careful assessment of terminology, workflow reporting, and consistency between the manuscript and supplementary material. We address these concerns in the numbered responses below.

An overview does not require repeating the subsequent evidence or creating a separate manuscript change.

## 7. A Pending Revision: Complete the Reply, Then Show the Matrix

Assume the current Methods define the input record but omit the output record. The author supplies both definitions below and requests proposed wording, not a file edit.

**Reviewer comment:** Please distinguish an input record from an output record in the terminology definitions.

**Response:** We agree that the distinction between input and output records needs to be explicit. An input record is one entry received before processing; an output record is the corresponding processed entry. These definitions distinguish the two stages of the workflow.

Proposed manuscript change, not yet applied:

| File/section | Type | Current verbatim text | Exact proposed text |
|---|---|---|---|
| Manuscript / Methods / "Terminology" | replacement | An input record is one entry received before processing. | An input record is one entry received before processing. An output record is the corresponding processed entry. |

Do not say `we revised` for this pending change. After the author applies it, reread the current text before describing the revision as completed or quoting its location.
