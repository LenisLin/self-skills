# 展示疾病相关基因在器官和阶段中的表达。使用附带的模拟数据生成 PNG、PDF 和 RDS。
args <- commandArgs(trailingOnly = TRUE)
out <- if (length(args)) args[[1]] else "."
entry <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1])
shared <- file.path(dirname(normalizePath(entry)), "_shared", "hesta_panels.R")
status <- system2(file.path(R.home("bin"), "Rscript"), c(shQuote(shared), "5e", shQuote(out)))
if (status != 0L) stop("Plotting failed with exit status ", status)
for (suffix in c(".png", ".pdf", "_simulated.rds")) {
  source <- file.path(out, paste0("5e", suffix))
  target <- file.path(out, paste0("disease_gene_organ_stage_heatmap", suffix))
  if (!file.rename(source, target)) stop("Could not rename ", source, " to ", target)
}
