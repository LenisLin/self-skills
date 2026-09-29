"""
02_patient_level_expression.py

Purpose
-------
Summarize target-gene expression at the patient × compartment level.

Inputs
------
- data/processed/cells.parquet
- configs/target_genes.txt

Outputs
-------
- results/patient_expression.csv

Prerequisite
------------
Run after 01_prepare_cells.py.
"""

from pathlib import Path

import pandas as pd


DATA_PATH = Path("data/processed/cells.parquet")
GENE_PATH = Path("configs/target_genes.txt")
OUTPUT_PATH = Path("results/patient_expression.csv")


def summarize_patient_expression(cells: pd.DataFrame, genes: list[str]) -> pd.DataFrame:
    """Return patient-level detection and mean expression for target genes."""
    expression = cells.melt(
        id_vars=["patient_id", "compartment"],
        value_vars=genes,
        var_name="gene",
        value_name="expression",
    )
    return (
        expression.groupby(["patient_id", "compartment", "gene"], observed=True)
        .agg(
            n_cells=("expression", "size"),
            detection_fraction=("expression", lambda x: (x > 0).mean()),
            mean_expression=("expression", "mean"),
        )
        .reset_index()
    )


# Load the prepared cell-level expression table and predefined target-gene panel.
cells = pd.read_parquet(DATA_PATH)
genes = [gene for gene in GENE_PATH.read_text().splitlines() if gene]

# Collapse cell-level measurements to the patient × compartment × gene level.
patient_expression = summarize_patient_expression(cells, genes)

# Save the patient-level table for downstream cohort comparisons and visualization.
OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
patient_expression.to_csv(OUTPUT_PATH, index=False)
