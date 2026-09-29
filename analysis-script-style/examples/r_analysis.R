# Script: 02_patient_level_expression.R
# Purpose: Summarize target-gene expression at the patient x compartment level.
# Inputs: data/processed/cells.rds; configs/target_genes.txt
# Outputs: results/patient_expression.csv
# Prerequisite: Run after 01_prepare_cells.R

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(tidyr)
})

DATA_PATH <- "data/processed/cells.rds"
GENE_PATH <- "configs/target_genes.txt"
OUTPUT_PATH <- "results/patient_expression.csv"

summarize_patient_expression <- function(cells, genes) {
  #' Return patient-level detection and mean expression for target genes.
  cells %>%
    select(patient_id, compartment, all_of(genes)) %>%
    pivot_longer(
      cols = all_of(genes),
      names_to = "gene",
      values_to = "expression"
    ) %>%
    group_by(patient_id, compartment, gene) %>%
    summarise(
      n_cells = n(),
      detection_fraction = mean(expression > 0),
      mean_expression = mean(expression),
      .groups = "drop"
    )
}

# Load the prepared cell-level expression table and predefined target-gene panel.
cells <- readRDS(DATA_PATH)
genes <- read_lines(GENE_PATH)

# Collapse cell-level measurements to the patient x compartment x gene level.
patient_expression <- summarize_patient_expression(cells, genes)

# Save the patient-level table for downstream cohort comparisons and visualization.
dir.create(dirname(OUTPUT_PATH), recursive = TRUE, showWarnings = FALSE)
write_csv(patient_expression, OUTPUT_PATH)
